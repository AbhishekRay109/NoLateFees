# Testing NoLateFees

Four parts. Parts 1 and 2 need nothing but Flutter and a phone or emulator. Parts 3 and 4 add sign-in and cloud sync.

| Part | What | Needs |
|---|---|---|
| 1 | Automated tests | Flutter |
| 2 | Manual test on a phone, offline mode | Android phone or emulator |
| 3 | Set up Firebase | Free Firebase project ([FIREBASE_SETUP.md](FIREBASE_SETUP.md)) |
| 4 | Manual sign-in and sync tests | Two devices (phone + emulator is fine) |

---

## Part 1: Automated tests

Prerequisites: Flutter stable **3.47 or newer** (`flutter --version`).

```bash
cd nolatefees
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze        # expect: No issues found!
flutter test           # expect: All tests passed! (120 tests)
```

What they cover:

| File | Covers |
|---|---|
| `test/reminder_engine_test.dart` | Your spec example (30 Nov 2026 → 31 Oct, 16 Nov, 23 Nov, 27 Nov, 29 Nov, 30 Nov, 1 Dec at 09:00), custom offsets and times, past alerts dropped, snooze, month-end and leap-year renewals, status buckets, DST, the 60/400 cap |
| `test/repository_and_scheduler_test.dart` | Save books 7 notifications; edit re-books; delete cancels; renew moves the date, keeps history, re-books; snooze; archive; default schedule; reconcile is idempotent |
| `test/sync_test.dart` | Phone A → server → phone B; incremental pull; delete beats a stale edit; local unsynced edit survives a pull; family before items; attachments upload before their row; a failed upload doesn't block sync; a broken cursor can't loop; settings and profile sync |
| `test/export_and_filter_test.dart` | CSV escaping, JSON backup round-trip, old DueMate backups still import, dashboard grouping, search/filter/sort |
| `test/widget_test.dart` | Welcome screen, offline onboarding, empty dashboard, dashboard sections, counters and countdowns, Add Reminder flow and validation, navigation |
| `test/auth_test.dart` | Phone number cleanup (+91, 0 prefix, spaces), email check, initials, profile merge after sign-in, onboarding, sign out and delete account |
| `test/auth_screens_test.dart` | Google sign-in (success, cancel, error), phone OTP (bad number, wrong code, resend timer, auto-verify), profile screen, Settings account card |
| `test/firestore_sync_test.dart` | The real Firestore backend against an in-memory Firestore: per-user folders, delete wins, incremental pulls, two phones syncing end to end |
| `test/ui_helpers_test.dart` | Countdown ring, category colours, themes, labels, money formatting, leap-day and month-end renewals |
| `test/migration_test.dart` | Upgrading a version-1 database keeps data and adds the profile fields |

Run one file: `flutter test test/sync_test.dart`. Run one test: `flutter test --plain-name "renewal moves"`.

---

## Part 2: Manual test on a phone (offline mode)

### Get it running

1. Install Android Studio, open **Device Manager**, create a Pixel emulator with a recent Android image. Or plug in an Android phone with **USB debugging** on (Settings → About phone → tap Build number 7 times → Developer options → USB debugging).
2. `flutter devices` should list it.
3. `flutter run` (no `--dart-define`), so the app runs fully offline with no account.

### Checklist

Tick each one. Anything that fails, note the step and what you saw.

**Adding and the dashboard**

- [ ] First launch shows the welcome screen with the NoLateFees logo. In an offline build it says sign-in switches on once Firebase is connected; tap **Get started**.
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
- [ ] **Time zone**: Android Settings → System → Date & time → change zone. Return to the app; Settings → Time zone shows the new zone and the next reminders are still at your chosen local time.

**Phones that kill background apps.** On Xiaomi, Oppo, Vivo, Realme or OnePlus, repeat the reboot and swipe-away tests. If alerts don't arrive, set NoLateFees's battery usage to "No restrictions" and retest. Note which phone.

---

## Part 3: Set up Firebase (sign-in and cloud sync)

Follow [FIREBASE_SETUP.md](FIREBASE_SETUP.md) steps 1 to 8. Then build the APK from GitHub Actions (or `flutter run --dart-define-from-file=env.json` locally).

---

## Part 4: Manual sign-in and sync tests

Use two devices signed in to the same account: your phone (A) and a second phone, emulator, or the same phone after uninstall/reinstall (B).

**Sign-in**

- [ ] Fresh install → welcome screen with the logo, **Continue with Google**, **Continue with phone number** and **Continue without an account**.
- [ ] **Google** → account picker → "About you" is prefilled with name, email and photo → **Let's go** → dashboard greets you by first name.
- [ ] Close the account picker without choosing: no error, still on the welcome screen.
- [ ] **Phone** with the test number `99999 00001`: the code screen shows "+91 99999 00001". Type a wrong code → "That code didn't work". Type `123456` → signs in and opens "About you" with the phone marked **Verified**.
- [ ] Phone with letters or 5 digits → "Enter a valid mobile number".
- [ ] "Resend in 30s" counts down, then **Resend code** is tappable.
- [ ] Settings shows the gradient profile card with your initials or photo, email/phone and "Synced to your account". Tap it → **Edit profile** → change the name → Save → card updates.

**Sync**

- [ ] On A, choose **Continue without an account**, add 3 items, then Settings → **Sign in to back up and sync** → Google. Within a few seconds Settings → Cloud sync shows "Last synced …".
- [ ] Firebase console → **Firestore → Data → users → (your id) → items**: the 3 documents are there with `due_date` like `2026-11-30` and a `server_updated_at` time.
- [ ] Sign in on B with the same account. The 3 items appear, with reminders booked (check one item's "Next reminders").
- [ ] Edit an item's date on A → on B, pull down on the dashboard (or reopen the app) → the date changed.
- [ ] Renew on B → the history shows on A.
- [ ] Delete on A while B is in **airplane mode** and edits the same item. Turn B's network on. The item ends up deleted on both.
- [ ] Only if Storage is set up: add a PDF on A; on B, open the item and tap the file: it downloads and opens.
- [ ] Security check: sign in on B with a **different** Google account. It sees none of the first account's items.
- [ ] **Sign out** on B: its data is removed from the phone, notifications stop, and the welcome screen shows. Sign back in: everything returns.
- [ ] **Delete account** (Settings → Danger zone) on a throwaway account: its documents disappear from Firestore and the user from Authentication → Users. If it says to sign in again first, sign out, sign in, retry.

## Reporting a problem

For each failure, note: the checklist line, phone model and Android version, what you expected, what happened. `flutter run` output or `adb logcat | grep -i flutter` from the moment it happened helps most.
