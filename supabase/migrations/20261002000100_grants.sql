-- Explicit Data API access for signed-in users. RLS (in the init migration)
-- still limits every row to its owner; anon gets nothing.
grant usage on schema public to authenticated;
grant select, insert, update, delete on
  profiles, family_members, categories, items, renewals, attachments, devices, notification_log
  to authenticated;
-- The rev trigger calls nextval() as the signed-in user.
grant usage, select on sequence sync_rev to authenticated;
revoke all on
  profiles, family_members, categories, items, renewals, attachments, devices, notification_log
  from anon;
