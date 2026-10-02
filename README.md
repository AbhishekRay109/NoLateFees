# DueMate

One app that remembers every date you don't want to remember: insurance, PUC, passport, recharges, EMIs, subscriptions, warranties.

Flutter app, offline-first. The phone's SQLite database (Drift) is the source of truth and reminders are local notifications, so **the app works with no server and no account**. Supabase is optional: when it's configured and the user signs in, everything is backed up and synced across phones.

Design notes: `design/duemate-design.md` in the project files (stack choice, data model, sync and notification design).

## What's in V1

- Dashboard: Overdue / Due today / Next 7 days / Next 30 days / Upcoming / No date, with a "things to renew" count
- Add/edit reminder in under 30 seconds: 8 built-in categories with ~50 types, custom categories
- Configurable alerts per item (30, 14, 7, 3, 1 days before, on the day, 1 day after by default, or any custom offset) and notification time
- Recurring renewals (monthly, 3/6 months, yearly, custom), **Renewed** flow with automatic next date and renewal history
- Notification buttons: **Renewed** (opens the renew sheet) and **Snooze 1 day** (works with the app closed)
- PDF/JPG/PNG attachments (private bucket, signed download)
- Family members and vehicles, with filters
- Search, filter by category/status/person, sort, archive
- Monthly calendar
- Settings: default time and schedule, exact-timing opt-in, theme, currency, name
- Export CSV, JSON backup and restore, sign in with email code, sync, sign out, delete account

## Project layout

```text
lib/
  domain/              pure Dart, no Flutter
    reminder_engine.dart   when to remind, recurrence, status, schedule diff
    categories.dart        built-in categories (shipped in the app, not stored)
  data/
    local/database.dart    Drift tables (mirror of the Supabase schema)
    item_repository.dart   every read/write the screens do
    notifications/         reconcile() + flutter_local_notifications gateway
    sync/                  push/pull with Supabase, JSON mapping
    backup/                CSV/JSON export and import
    attachment_service.dart
  features/            screens: dashboard, items, calendar, settings, auth
  widgets/
  app_services.dart    wiring + Riverpod providers
  main.dart            startup, background job, notification taps
supabase/
  migrations/          schema, RLS, storage bucket, grants
  functions/delete-account/
test/                  41 tests: engine, scheduler, repository, sync, export, widgets
docs/
  TESTING.md           how to test, step by step
  RELEASE.md           signing and Play Store release
```

## Quick start

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # only after changing database.dart
flutter test
flutter run            # offline mode, no account needed
```

With cloud sync (after the Supabase setup in [docs/TESTING.md](docs/TESTING.md#part-3-set-up-supabase-cloud-sync)):

```bash
cp env.example.json env.json      # fill in your project URL and publishable key
flutter run --dart-define-from-file=env.json
```

## How the important parts work

**Reminders.** Each item stores its schedule as data (`reminder_offsets`, `notify_minutes`). `NotificationScheduler.reconcile()` computes the alerts that should exist (nearest 400 on Android, 60 on iOS, which caps pending notifications at 64), compares them with the `scheduled_notifications` table, and books or cancels only the difference. It runs after every change, on app open and resume, after a sync, and once a day from WorkManager. Reboots are handled by the plugin's boot receiver. Alarms are inexact by default (no special permission); exact timing is an opt-in in Settings.

**Sync.** Every write goes to SQLite first with `dirty = true`. Sync pushes dirty rows (upsert), then pulls rows whose server `rev` is newer than the last pull. A row still dirty locally is never overwritten by a pull. Deletes are soft (`deleted_at`) and the server refuses to undelete, so a delete always beats a stale edit.

**Dates.** Due dates are calendar dates (`yyyy-mm-dd`), never timestamps, so a reminder can't shift a day because of time zones. Status (overdue, due soon) is computed when the screen is drawn, never stored.

## Not in this version

These are in the design but deliberately left for later: Google sign-in (email code works now), Firebase Crashlytics and server push (FCM), OCR, home-screen widget, payments. iOS builds are configured but have not been run on a device yet.
