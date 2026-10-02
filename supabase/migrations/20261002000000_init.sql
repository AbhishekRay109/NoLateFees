-- DueMate: Supabase (Postgres) schema, V1 + V1.5
-- Apply with: supabase db push   (put this file in supabase/migrations/0001_init.sql)
-- The app keeps the same tables in Drift (SQLite) on the phone. The phone is the source of
-- truth for the UI; Postgres is the backup/sync copy.

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------
create type recurrence_unit as enum ('none', 'day', 'week', 'month', 'year');
create type item_status     as enum ('active', 'archived');   -- "overdue/due soon" is computed, never stored

-- ---------------------------------------------------------------------------
-- Sync helper: every synced row gets a server revision number from one sequence.
-- Clients pull "rows where rev > my last rev". Deletes are soft (deleted_at) so they sync too.
-- ---------------------------------------------------------------------------
create sequence sync_rev;

create or replace function bump_rev() returns trigger language plpgsql as $$
begin
  -- A deleted row stays deleted: a stale offline edit cannot resurrect it.
  if tg_op = 'UPDATE' and old.deleted_at is not null and new.deleted_at is null then
    new.deleted_at := old.deleted_at;
  end if;
  new.rev        := nextval('sync_rev');
  new.updated_at := now();
  return new;
end $$;

-- ---------------------------------------------------------------------------
-- profiles: one row per auth user (settings live here)
-- ---------------------------------------------------------------------------
create table profiles (
  id                 uuid primary key references auth.users(id) on delete cascade,
  display_name       text,
  timezone           text    not null default 'Asia/Kolkata',     -- IANA name
  default_notify_at  time    not null default '09:00',
  default_offsets    int[]   not null default '{30,14,7,3,1,0,-1}', -- days before due (negative = after)
  currency           char(3) not null default 'INR',
  plan               text    not null default 'free',             -- free | premium (set by billing webhook later)
  rev                bigint  not null default 0,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- family_members (V1.5): "Me", "Dad", "Car"... an item can optionally belong to one
-- ---------------------------------------------------------------------------
create table family_members (
  id          uuid primary key,                 -- generated on the phone (UUIDv7)
  user_id     uuid not null references auth.users(id) on delete cascade,
  name        text not null,
  relation    text,                             -- self | spouse | parent | child | vehicle | other
  emoji       text,
  sort_order  int  not null default 0,
  rev         bigint not null default 0,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  deleted_at  timestamptz
);

-- ---------------------------------------------------------------------------
-- categories: only USER-CREATED ones are stored. Built-in categories ship inside the app
-- with stable string keys ("vehicle.insurance", "mobile.recharge"...), so nothing to sync.
-- ---------------------------------------------------------------------------
create table categories (
  id          uuid primary key,
  user_id     uuid not null references auth.users(id) on delete cascade,
  parent_key  text,                             -- built-in parent, e.g. 'home', or null
  name        text not null,
  icon        text,
  rev         bigint not null default 0,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  deleted_at  timestamptz
);

-- ---------------------------------------------------------------------------
-- items: the thing that expires / is due. Reminder schedule is stored ON the item as data.
-- ---------------------------------------------------------------------------
create table items (
  id                uuid primary key,
  user_id           uuid not null references auth.users(id) on delete cascade,
  family_member_id  uuid references family_members(id),
  category_key      text not null,              -- built-in key ('vehicle.insurance') or 'custom:<uuid>'
  title             text not null check (length(title) between 1 and 120),
  provider          text,
  reference_no      text,                       -- policy / account number (consider masking in UI)
  amount_minor      bigint,                     -- paise; avoids float money
  currency          char(3) not null default 'INR',
  start_date        date,
  due_date          date,                       -- a calendar DATE, not a timestamp. null = no expiry
  recurrence_unit   recurrence_unit not null default 'none',
  recurrence_every  int not null default 1 check (recurrence_every > 0),
  reminder_offsets  int[],                      -- null = use profile default_offsets
  notify_at         time,                       -- null = use profile default_notify_at
  snoozed_until     timestamptz,
  status            item_status not null default 'active',
  notes             text,
  extra             jsonb not null default '{}', -- category-specific: {"vehicle_no":"KA01AB1234"}
  rev               bigint not null default 0,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  deleted_at        timestamptz
);

-- ---------------------------------------------------------------------------
-- renewals: append-only history. Renewing = insert a row here + move items.due_date forward.
-- ---------------------------------------------------------------------------
create table renewals (
  id            uuid primary key,
  item_id       uuid not null references items(id) on delete cascade,
  user_id       uuid not null references auth.users(id) on delete cascade,
  previous_due  date not null,
  new_due       date not null,
  amount_minor  bigint,
  provider      text,
  notes         text,
  renewed_at    timestamptz not null default now(),
  rev           bigint not null default 0,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  deleted_at    timestamptz
);

-- ---------------------------------------------------------------------------
-- attachments: metadata only; the file lives in the private Storage bucket "attachments"
-- at path {user_id}/{item_id}/{attachment_id}.{ext}
-- ---------------------------------------------------------------------------
create table attachments (
  id            uuid primary key,
  item_id       uuid not null references items(id) on delete cascade,
  user_id       uuid not null references auth.users(id) on delete cascade,
  storage_path  text not null,
  file_name     text not null,
  mime_type     text not null check (mime_type in ('application/pdf','image/jpeg','image/png')),
  size_bytes    int  not null check (size_bytes <= 10 * 1024 * 1024),
  ocr           jsonb,                          -- V2: extracted fields, kept for "confirm" UI
  rev           bigint not null default 0,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  deleted_at    timestamptz
);

-- ---------------------------------------------------------------------------
-- V2 only (server push). Not needed for launch; included so the shape is agreed.
-- ---------------------------------------------------------------------------
create table devices (
  id          uuid primary key,
  user_id     uuid not null references auth.users(id) on delete cascade,
  fcm_token   text not null unique,
  platform    text not null,                    -- android | ios
  last_seen   timestamptz not null default now()
);

-- One row per reminder that was delivered, from either path. The key is deterministic:
--   instance_key = item_id || ':' || due_date || ':' || offset_days
-- The phone writes it when a local notification fires/opens; the server cron skips keys that exist.
create table notification_log (
  instance_key  text primary key,
  user_id       uuid not null references auth.users(id) on delete cascade,
  item_id       uuid not null,
  delivered_via text not null,                  -- local | push
  delivered_at  timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Triggers
-- ---------------------------------------------------------------------------
create or replace function bump_rev_simple() returns trigger language plpgsql as $$
begin
  new.rev := nextval('sync_rev');
  new.updated_at := now();
  return new;
end $$;

create trigger t_rev before insert or update on profiles       for each row execute function bump_rev_simple();
create trigger t_rev before insert or update on family_members for each row execute function bump_rev();
create trigger t_rev before insert or update on categories     for each row execute function bump_rev();
create trigger t_rev before insert or update on items          for each row execute function bump_rev();
create trigger t_rev before insert or update on renewals       for each row execute function bump_rev();
create trigger t_rev before insert or update on attachments    for each row execute function bump_rev();

-- Create the profile row when someone signs up.
create or replace function handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)));
  return new;
end $$;

create trigger on_auth_user_created after insert on auth.users
  for each row execute function handle_new_user();

-- ---------------------------------------------------------------------------
-- Indexes (small on purpose: dashboard/search/filter run on the phone's SQLite, not here)
-- ---------------------------------------------------------------------------
create index items_user_rev        on items          (user_id, rev);       -- sync pull
create index items_user_due        on items          (user_id, due_date)   -- V2 cron + web dashboard
  where deleted_at is null and status = 'active';
create index renewals_user_rev     on renewals       (user_id, rev);
create index renewals_item         on renewals       (item_id, renewed_at desc);
create index attachments_user_rev  on attachments    (user_id, rev);
create index attachments_item      on attachments    (item_id);
create index family_user_rev       on family_members (user_id, rev);
create index categories_user_rev   on categories     (user_id, rev);
create index devices_user          on devices        (user_id);
create index notif_log_user        on notification_log (user_id, delivered_at);

-- ---------------------------------------------------------------------------
-- Row Level Security: a user only ever sees their own rows
-- ---------------------------------------------------------------------------
alter table profiles         enable row level security;
alter table family_members   enable row level security;
alter table categories       enable row level security;
alter table items            enable row level security;
alter table renewals         enable row level security;
alter table attachments      enable row level security;
alter table devices          enable row level security;
alter table notification_log enable row level security;

create policy own on profiles for all
  using (id = auth.uid()) with check (id = auth.uid());

do $$
declare t text;
begin
  foreach t in array array['family_members','categories','items','renewals','attachments','devices','notification_log'] loop
    execute format(
      'create policy own on %I for all using (user_id = auth.uid()) with check (user_id = auth.uid())', t);
  end loop;
end $$;

-- ---------------------------------------------------------------------------
-- Storage: private bucket, files readable only by their owner via short-lived signed URLs
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('attachments', 'attachments', false, 10485760,
        array['application/pdf','image/jpeg','image/png']);

create policy "own files" on storage.objects for all
  using      (bucket_id = 'attachments' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id = 'attachments' and (storage.foldername(name))[1] = auth.uid()::text);

-- Delete account: deleting the auth user cascades every table above. The Edge Function that
-- does it must also remove storage objects under {user_id}/ first.
