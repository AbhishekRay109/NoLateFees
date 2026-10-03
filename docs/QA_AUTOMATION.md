# QA automation map

Which cases in [PRODUCTION_QA_CHECKLIST.md](PRODUCTION_QA_CHECKLIST.md) the automated tests cover, and which still need a person with a phone or the Play Console.

Tests are named after the case ids, so `flutter test --plain-name "NTF-17"` runs one case.

## How to run

```bash
flutter analyze                     # expect: No issues found!
flutter test                        # all app tests, including test/qa/
flutter test test/qa/               # just the QA suite
cd firebase/rules-test && npm ci && npm test   # security rules in the Firebase emulator (needs Java 21 + Node 22)
```

GitHub CI (`.github/workflows/ci.yml`) runs all three on every pull request and on `main`.

**Automated gate:** a candidate passes the automated part of the release only when `flutter analyze` is clean, `flutter test` passes, and the security-rules job passes. The manual cases below still have to pass on the exact Play build.

## Coverage by case

✅ automated · 🟡 the logic is automated, but the device or console step is still manual · 📱 manual only

| Case | | Where |
|---|---|---|
| BLD-01 | ✅ | `qa_release_config_test`: app id, version format, version comes from pubspec |
| BLD-02, BLD-03 | ✅ | CI `flutter analyze` and `flutter test` |
| BLD-04, BLD-05 | 🟡 | `qa_release_config_test`: only the test key is committed, and Gradle refuses to build a release bundle without `key.properties`. Building and uploading the `.aab` is manual |
| BLD-06, BLD-08 | 📱 | Install from Play, read the logs |
| BLD-07 | ✅ | `qa_release_config_test`: real Firebase and AdMob ids, one project and one AdMob account, wired through CI into the APK |
| ACC-01, ACC-02, ACC-03 | ✅ | `widget_test`, `auth_screens_test` |
| ACC-04, ACC-05 | 📱 | Android permission dialogs |
| ACC-06, ACC-07 | 🟡 | `auth_screens_test` (success, cancel, error). A real Google account on the phone is manual |
| ACC-08, ACC-09, ACC-10 | 🟡 | `auth_screens_test` (wrong code, bad number, resend timer). A real OTP is manual |
| ACC-11 | 📱 | Real SMS (needs the Blaze plan) |
| ACC-12, ACC-13, ACC-14, ACC-15, ACC-16 | ✅ | `qa_account_sync_test`, `auth_test` |
| ACC-17 | 🟡 | `qa_account_sync_test`, `firestore_sync_test`: every cloud table is deleted for that user only. Storage file cleanup needs the Blaze plan and is manual |
| REM-01 to REM-15 | ✅ | `qa_reminders_test` (every category, buckets, counts, edits, archive, renew, month-end, leap year, intervals, wording) |
| NTF-01, NTF-02, NTF-03 | 🟡 | `qa_notifications_test` checks what is booked and when. Delivery while locked or swiped away is manual |
| NTF-04, NTF-05, NTF-06 | 🟡 | The exact-timing flag reaches Android. The permission screen is manual |
| NTF-07, NTF-11, NTF-12, NTF-13, NTF-15, NTF-16, NTF-17, NTF-19 | ✅ | `qa_notifications_test` |
| NTF-08, NTF-09, NTF-10 | 🟡 | `qa_notifications_test`, `qa_ui_test`: payload, open item, renew sheet, snooze. Tapping a real notification is manual |
| NTF-14 | 🟡 | `qa_release_config_test`: boot and app-update receivers are declared. A real reboot is manual |
| NTF-18 | 📱 | Xiaomi, Oppo, Vivo or Samsung battery savers |
| UI-01, UI-02, UI-03, UI-04, UI-06, UI-15, UI-16 | ✅ | `qa_ui_test`, `export_and_filter_test` |
| UI-05 | ✅ | `repository_and_scheduler_test`, `qa_data_test` (family member detach, restore) |
| UI-07, UI-08, UI-09 | 🟡 | `sync_test`, `qa_account_sync_test` (upload order, failure doesn't block sync). Picking and opening real files is manual |
| UI-10, UI-11 | ✅ | `ads_test`, `qa_release_config_test` (no pop-up, full-screen or video ad code anywhere) |
| UI-12, UI-13 | ✅ | `qa_ui_test`: light and dark, text at 1.3× and 1.6×, every tab and the form |
| UI-14 | 🟡 | `qa_ui_test`: every tap target is labelled and at least 48 dp (Calendar's month title excepted). A TalkBack walk-through is manual |
| DAT-01 to DAT-07 | ✅ | `qa_data_test` (restart, CSV, JSON, duplicates, broken files, all-or-nothing import) |
| DAT-08 | 📱 | Install over the previous Play version |
| DAT-09 | ✅ | `migration_test` |
| DAT-10 | 📱 | Low storage |
| SYN-01 to SYN-09, SYN-12, SYN-13, SYN-14 | ✅ | `qa_account_sync_test`, `sync_test`, `firestore_sync_test` |
| SYN-10 | ✅ | `firebase/rules-test`: signed-out, cross-user, unknown tables, faked timestamps, undelete, 10 MB file limit |
| SYN-11 | 🟡 | Upload and retry logic is automated. Storage itself needs the Blaze plan |
| POL-01 | 🟡 | Support email checked. The listing text is manual |
| POL-04, POL-08 | 🟡 | `qa_release_config_test`: exact permission list, no `USE_EXACT_ALARM`, no debuggable or cleartext. The Play forms are manual |
| POL-10 | 🟡 | Real ad ids in release, Google test ids in debug. Linking the store is manual |
| POL-02, POL-03, POL-05, POL-06, POL-07, POL-09, POL-11, POL-12, POL-13 | 📱 | Play Console, Firebase console, website |

## Issues the QA suite found and fixed

1. **Account deletion could lose cloud data.** If Google asked for a fresh sign-in before deleting the account, the cloud data was already gone but the account stayed, and the phone never re-uploaded it. Now everything on the phone is queued for upload again, so the account keeps its data (ACC-16).
2. **Search box had no TalkBack label** on All Items. It is now a labelled text field (UI-14).
3. **Calendar month arrows had no TalkBack label.** They now read "Previous month" and "Next month" (UI-14).
4. **A release bundle could be signed with the public test key** if `key.properties` was missing. Gradle now stops with a clear message (BLD-05).

## Known limits

- Android removes an app's alarms when it is force-stopped from Settings. They come back on the next restart of the phone or the next change in the app. This is how Android works, and it is worth one manual check (NTF-14).
- The theme choice (light, dark or system) stays on each phone and is not part of backups or sync. This is on purpose.
