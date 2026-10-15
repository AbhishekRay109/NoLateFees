# Testing NoLateFees

Two parts: the automated suite, which needs only Flutter, and a manual pass on a phone or emulator.

## Part 1: Automated tests

Prerequisites: Flutter stable **3.47 or newer** (`flutter --version`).

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze        # expect: No issues found!
flutter test           # expect: All tests passed!
```

GitHub CI (`.github/workflows/ci.yml`) runs `analyze` and `test` on every pull request and on `main`.

| File | Covers |
|---|---|
| `test/reminder_engine_test.dart` | The spec example (30 Nov 2026 → 31 Oct, 16 Nov, 23 Nov, 27 Nov, 29 Nov, 30 Nov, 1 Dec at 09:00), custom offsets and times, past alerts dropped, snooze, month-end and leap-year renewals, status buckets, DST, the 60/400 cap |
| `test/repository_and_scheduler_test.dart` | Save books 7 notifications; edit re-books; delete cancels; renew moves the date, keeps history, re-books; snooze; archive; default schedule; reconcile is idempotent |
| `test/export_and_filter_test.dart` | CSV escaping, JSON backup round-trip, old DueMate backups still import, dashboard grouping, search/filter/sort |
| `test/widget_test.dart` | Welcome screen (no login), onboarding, empty dashboard, dashboard sections, counters and countdowns, Add Reminder flow and validation, navigation, Contact us |
| `test/format_test.dart` | Phone number cleanup (+91, 0 prefix, spaces), email check, initials, onboarding, erase all data |
| `test/ui_helpers_test.dart` | Countdown ring, category colours, themes, labels, money formatting, leap-day and month-end renewals |
| `test/migration_test.dart` | Upgrading a v1 database and a v2 (cloud sync era) database keeps every row; v3 drops the sync columns |
| `test/production_release_gate_test.dart` | Critical journeys: edits replace obsolete alerts, deletion cancels alerts, renewal history and relationships survive backup and restore |
| `test/qa/` | One test per QA case id: reminders (REM), notifications (NTF), screens, themes, large text and accessibility (UI), backup and import (DAT), build config and the local-only guarantees (BLD, POL, LOC). `flutter test --plain-name "NTF-17"` runs one case |

Run one file: `flutter test test/migration_test.dart`. Run one test: `flutter test --plain-name "renewal moves"`.

---

## Part 2: Manual test on a phone (offline mode)

### Get it running

1. Install Android Studio, open **Device Manager**, create a Pixel emulator with a recent Android image. Or plug in an Android phone with **USB debugging** on (Settings → About phone → tap Build number 7 times → Developer options → USB debugging).
2. `flutter devices` should list it.
3. `flutter run`.

### Checklist

Tick each one. Anything that fails, note the step and what you saw.

**Adding and the dashboard**

- [ ] First launch shows the welcome screen with the NoLateFees logo, three feature rows (one says "Private by design") and **Get started**. There is no sign-in.
- [ ] "About you": **Let's go** with an empty name says "Please enter your name". Enter a name and a bad email ("abc") → "That email doesn't look right". Fix it → dashboard.
- [ ] The dashboard has a colourful gradient header greeting you by first name, with three counters (To renew, Overdue, Tracking), and "Nothing to track yet" with an **Add Reminder** button.
- [ ] Add: pick 🚗 Vehicle → Vehicle Insurance. The name fills in and Renewal pre-selects **Every year**.
- [ ] Pick a date 5 days from today, tap **SAVE**. Android 13+ asks for notification permission **now** (not at first launch). Allow it.
- [ ] Dashboard shows it under **NEXT 7 DAYS** with "5 days left" in an orange pill and a countdown ring around the icon; **To renew** says 1.
- [ ] Add an item dated 2 days ago → it appears under **OVERDUE** as "Expired 2 days ago".
- [ ] Add a Passport ~6 months out → **UPCOMING**. **To renew** does not count it; **Tracking** does.

**Notifications (the most important part)**

- [ ] Quick test: Settings → turn on **Exact timing** (accept the system screen). Add an item due **today**, in "Remind me" keep only **On the day**, set **Notification time** to 2 minutes from now. Lock the phone. The notification arrives with **Renewed** and **Snooze 1 day** buttons.
- [ ] Repeat with Exact timing **off**: it still arrives, possibly a few minutes late. That's expected.
- [ ] Tap the notification body → the app opens on that item.
- [ ] Tap **Renewed** on a notification → app opens with the renew sheet already showing the next date.
- [ ] Swipe the app away from recents, trigger another notification, tap **Snooze 1 day** → notification goes away; open the item: "Snoozed until …" tomorrow.
- [ ] **Reboot**: schedule an alert 3 minutes out, then restart the phone (or `adb reboot`). Don't open the app. The notification still arrives.
- [ ] **Edit**: change an item's date. Its detail page's "Next reminders" list moves to the new date; the old alert doesn't fire.
- [ ] **Delete**: delete an item with an alert a few minutes away. It doesn't fire.
- [ ] **Turn off** Settings → Notifications. Nothing fires. Turn it back on, alerts are back.
- [ ] Optional, to see what's booked: `adb shell dumpsys alarm | grep -A3 com.nolatefees.app` lists pending alarms.

**Renewal**

- [ ] Open an item that repeats yearly → **Renewed**. Previous expiry shows; New expiry is one year later. Enter an amount, save.
- [ ] The countdown moved by a year, and **Renewal history** shows "old date → new date" with the amount.
- [ ] Renew a monthly item due on 31 Jan: the next date is 28 Feb (29 in a leap year).
- [ ] A "Doesn't repeat" item asks you to pick the new date.

**Everything else**

- [ ] Item → **Add PDF / photo** → pick a PDF. It's listed; tapping opens it. A file over 10 MB is refused with a message.
- [ ] Settings → **Family & vehicles** → add "Dad". Edit an item → More details → Belongs to: Dad. Dashboard shows filter chips; "Dad" shows only his items.
- [ ] **All Items**: search by provider name, filter by category and status, sort by name, show archived.
- [ ] **Calendar**: dots on due dates; tapping a day lists its items.
- [ ] Settings → **Export to CSV** → open in Sheets: one row per item.
- [ ] Settings → **Export backup (JSON)** → save it. Uninstall the app, reinstall, **Import backup** → everything is back, with notifications.
- [ ] **Airplane mode**: add, edit, renew, delete. Everything works.
- [ ] Theme: Light / Dark / System all look right.
- [ ] Settings → **Erase all data** → confirm. The app returns to the welcome screen and no old notifications fire.
- [ ] **Time zone**: Android Settings → System → Date & time → change zone. Return to the app; Settings → Time zone shows the new zone and the next reminders are still at your chosen local time.

**Phones that kill background apps.** On Xiaomi, Oppo, Vivo, Realme or OnePlus, repeat the reboot and swipe-away tests. If alerts don't arrive, set NoLateFees's battery usage to "No restrictions" and retest. Note which phone.

