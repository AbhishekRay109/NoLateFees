# NoLateFees production release QA checklist

Use this checklist for **each release candidate**, not just during development. A release is ready only when every applicable release-gate case below passes on the exact build intended for Play. A skipped, blocked, or unverified case is not a pass.

Many cases are also covered by automated tests; [QA_AUTOMATION.md](QA_AUTOMATION.md) shows which ones, and which still need a phone or the Play Console.

## Release record

Complete this before testing. Use a fresh copy of this record for each candidate.

| Field | Value |
|---|---|
| Version name / version code | |
| Git commit or source revision | |
| Candidate build date | |
| Build source (CI/local) and build link | |
| Android device model / Android version | |
| Second device model / Android version (if used) | |
| Tester(s) / test date(s) | |
| Firebase project / test account(s) | |
| AdMob mode (test / production) | |
| Play track / installed version | |

### Result and severity

- Mark a case **PASS** only after performing the steps and observing every expected result.
- Mark **FAIL** when observed behavior differs; record reproduction steps and attach sanitized evidence.
- Mark **BLOCKED** when the case could not be run. A blocked mandatory case prevents release.
- Mark **N/A** only when the case genuinely does not apply; record why and who approved it.
- **P0 / release blocker:** data loss or exposure, broken sign-in or core reminder behavior, crash/data corruption, policy or signing failure.
- **P1 / major:** important feature unusable or unreliable without a safe workaround.
- **P2 / minor:** cosmetic or low-impact issue with no material policy, data, or core-flow impact.

Do not include passwords, OTPs, personal data, advertising IDs, or production user records in screenshots, logs, or bug reports.

## 1. Candidate and automated quality gates

- [ ] **BLD-01 (P0)** Verify the candidate version name and monotonically increasing version code match the intended release. Confirm the package/application ID is the established `com.nolatefees.app`.
- [ ] **BLD-02 (P0)** Run `flutter analyze`; require zero analysis errors. Resolve any warnings newly introduced by the candidate.
- [ ] **BLD-03 (P0)** Run `flutter test`; require all tests to pass. Record the command output and test count.
- [ ] **BLD-04 (P0)** Build the release Android App Bundle using the documented production configuration. Require a successful build with no test/development configuration accidentally included.
- [ ] **BLD-05 (P0)** Verify the `.aab` is signed with the intended upload key and can be uploaded to the intended Play track. Never use the public CI test key for a Play release.
- [ ] **BLD-06 (P0)** Install the candidate from the Play internal/closed testing track on a physical device. Confirm Play installation, launch, app label, launcher icon, and version information are correct.
- [ ] **BLD-07 (P1)** Confirm the release build starts with the intended Firebase and AdMob configuration; it must not silently behave like an unconfigured development build.
- [ ] **BLD-08 (P0)** Review startup and normal-flow logs for uncaught exceptions, repeated errors, or sensitive values. Do not accept a crash-free test result if logs show a reproducible underlying failure.

## 2. Install, onboarding, permissions, and account lifecycle

- [ ] **ACC-01 (P0)** Fresh install and first launch: welcome screen renders correctly, all sign-in choices are readable, and the user can continue without an account.
- [ ] **ACC-02 (P1)** Complete the offline profile/onboarding flow with a valid name. Confirm the dashboard greeting uses the saved name after closing and reopening the app.
- [ ] **ACC-03 (P1)** Submit an empty name and malformed email during profile entry. Confirm field-level validation is clear, blocks invalid submission, and does not crash.
- [ ] **ACC-04 (P1)** Deny notification permission on the first prompt. Confirm onboarding remains usable, the app does not repeatedly trap the user in a permission prompt, and the user can enable notifications later in system settings.
- [ ] **ACC-05 (P1)** Grant notification permission after initially denying it. Confirm notifications can be scheduled after returning to the app.
- [ ] **ACC-06 (P0)** Sign in with a designated Google test account. Confirm the expected account is selected, authentication completes, and the account is visible in Firebase Authentication.
- [ ] **ACC-07 (P1)** Cancel the Google account picker. Confirm the user returns to the prior screen without a false success state or app error.
- [ ] **ACC-08 (P0)** Sign in with the configured Firebase test phone number and test OTP. Confirm the verification flow completes and the phone is shown as verified.
- [ ] **ACC-09 (P1)** Enter an invalid phone number and an incorrect OTP. Confirm each is rejected with a useful message and the flow remains recoverable.
- [ ] **ACC-10 (P1)** Exercise OTP resend: verify the countdown, disabled period, resend action, and resulting verification attempt behave correctly.
- [ ] **ACC-11 (P1)** Verify a real SMS number only once, if needed and approved. Confirm billing/SMS limits are understood; do not repeatedly request real OTPs.
- [ ] **ACC-12 (P0)** Create reminders as a guest, then sign in from Settings. Confirm local data is retained and appears in the signed-in account rather than being replaced by an empty cloud account.
- [ ] **ACC-13 (P1)** Edit profile name and available account fields. Confirm saved values survive app restart and, when signed in, are consistent on another device.
- [ ] **ACC-14 (P0)** Sign out. Confirm the welcome screen is shown, the prior account's data is no longer visible locally, and its pending reminders do not fire on that signed-out installation.
- [ ] **ACC-15 (P0)** Sign back in to the same account. Confirm the account's cloud data returns and local reminders are scheduled again.
- [ ] **ACC-16 (P0)** On a disposable test account, use in-app account deletion. Confirm recent-auth requirements are explained if applicable, deletion completes only after confirmation, and the Firebase Auth user and that user's cloud data are removed.
- [ ] **ACC-17 (P0)** Verify account deletion also handles associated cloud attachments and leaves no other user's data affected. Record any retention or failed-cleanup behavior for resolution.

## 3. Reminder lifecycle, dates, recurrence, and dashboard

- [ ] **REM-01 (P0)** Create an item in each built-in category and a representative type in each category. Confirm sensible defaults, saved values, and correct category/type labels.
- [ ] **REM-02 (P1)** Create a custom category and item. Confirm it can be selected, displayed, edited, and remains available after app restart.
- [ ] **REM-03 (P0)** Create an item with required fields omitted or malformed. Confirm validation identifies the issue and no partial/invalid item is saved.
- [ ] **REM-04 (P0)** Save an item with a due date in the past, today, within 7 days, within 30 days, beyond 30 days, and no date. Confirm each appears in the correct dashboard bucket.
- [ ] **REM-05 (P0)** Confirm dashboard counts (To renew, Overdue, Tracking) reflect the test records and update immediately after add, edit, archive, renew, and delete.
- [ ] **REM-06 (P1)** Edit each important item field, including name, category/type, date, person/vehicle, amount, recurrence, alert offsets, and notification time. Reopen the item and verify saved values.
- [ ] **REM-07 (P0)** Delete a reminder with future alerts. Confirm it disappears from active lists and its old scheduled alerts are cancelled.
- [ ] **REM-08 (P1)** Archive and unarchive an item. Confirm archived items are absent from normal active views, visible when archived items are requested, and restored without data loss.
- [ ] **REM-09 (P0)** Renew a recurring item. Confirm the previous due date, new date, optional amount, and renewal history are correct and the next alerts are recalculated.
- [ ] **REM-10 (P0)** Renew a non-recurring item. Confirm the user must choose a new date and the app does not invent a recurrence.
- [ ] **REM-11 (P0)** Check monthly renewals on the 29th, 30th, and 31st, including a leap-year February. Confirm month-end dates clamp to the last valid day and later recurrence remains correct.
- [ ] **REM-12 (P1)** Check yearly renewal across leap day and year boundaries. Confirm resulting dates and displayed history are correct.
- [ ] **REM-13 (P1)** Check custom recurrence intervals and every supported preset (monthly, 3 months, 6 months, yearly, and no-repeat). Verify computed next dates.
- [ ] **REM-14 (P1)** Verify renewal history remains available after app restart, sync, and backup/restore.
- [ ] **REM-15 (P1)** Verify dashboard countdown wording and colors at overdue, due today, and bucket boundaries (7 and 30 days); ensure there are no off-by-one date shifts.

## 4. Notifications, operating system behavior, and time

- [ ] **NTF-01 (P0)** Schedule an on-the-day alert a few minutes ahead with the app foregrounded. Confirm it arrives at the selected time within expected Android timing tolerance.
- [ ] **NTF-02 (P0)** Repeat with the phone locked and app in the background. Confirm the notification is visible and readable with the correct reminder and due date.
- [ ] **NTF-03 (P0)** Repeat with the app swiped away from recents. Confirm delivery and notification actions work.
- [ ] **NTF-04 (P1)** With exact timing disabled, confirm an inexact alert still arrives within Android's expected delivery window. Do not treat ordinary inexact-alarm delay as an exact-timing guarantee.
- [ ] **NTF-05 (P1)** Enable exact timing through Settings and the Android permission flow. Confirm permission is requested only for this opt-in, and exact scheduling works when permission is granted.
- [ ] **NTF-06 (P1)** Deny/revoke exact-alarm access. Confirm the app remains usable and provides an understandable fallback or explanation rather than crashing.
- [ ] **NTF-07 (P0)** Verify each configured alert offset (including before, on, and after the due date) is scheduled at the selected notification time and that past alerts are not booked.
- [ ] **NTF-08 (P0)** Tap the notification body. Confirm the correct item opens, not just the generic dashboard.
- [ ] **NTF-09 (P0)** Tap **Renewed** on a notification. Confirm the renewal flow opens for that item and saves the correct new date/history.
- [ ] **NTF-10 (P0)** Tap **Snooze 1 day** with the app closed. Confirm the current notification is dismissed and the reminder is rescheduled for tomorrow.
- [ ] **NTF-11 (P0)** Edit the due date and alert schedule. Confirm obsolete notifications are cancelled and only the new schedule fires.
- [ ] **NTF-12 (P0)** Delete an item with an imminent notification. Confirm no old notification fires.
- [ ] **NTF-13 (P1)** Turn notifications off in app Settings. Confirm reminders stop; turn them back on and confirm eligible reminders are reconciled.
- [ ] **NTF-14 (P0)** Reboot the phone without opening the app. Confirm a future reminder remains scheduled and arrives after reboot.
- [ ] **NTF-15 (P1)** Change the device time zone and return to the app. Confirm date-only due dates do not shift and alerts remain at the intended local notification time.
- [ ] **NTF-16 (P1)** Exercise a daylight-saving time transition where available or use the automated DST tests. Confirm due dates remain stable and alert times are recalculated correctly.
- [ ] **NTF-17 (P1)** Create more reminders than the platform pending-notification limit. Confirm the nearest eligible reminders are scheduled, the scheduler remains stable, and later reminders are reconciled as earlier ones pass.
- [ ] **NTF-18 (P1)** On at least one battery-restricted manufacturer device (e.g. Xiaomi, Oppo, Vivo, Realme, OnePlus, or Samsung), repeat background and reboot tests; document OS battery settings required for reliable delivery.
- [ ] **NTF-19 (P1)** Confirm notification text does not expose unnecessary sensitive item details on the lock screen beyond the app's intended behavior.

## 5. Browse, search, family/vehicle, calendar, attachments, and appearance

- [ ] **UI-01 (P1)** Open All Items with empty, one-item, and many-item data sets. Confirm empty states, rows, navigation, and scrolling are correct.
- [ ] **UI-02 (P1)** Search by item name and provider/details. Confirm matching, clearing the search, and no-result state behave correctly.
- [ ] **UI-03 (P1)** Filter by category, status, and person/vehicle; combine filters and clear them. Confirm only matching records appear.
- [ ] **UI-04 (P1)** Sort by each available option and verify ordering, including ties and items with no due date.
- [ ] **UI-05 (P1)** Add, edit, and remove a family member and vehicle. Associate reminders and verify dashboard/filter behavior before and after removal.
- [ ] **UI-06 (P1)** Open Calendar with due reminders. Confirm date markers, month navigation, selected-day list, and item navigation correspond to the actual due dates.
- [ ] **UI-07 (P1)** Attach supported PDF, JPG, and PNG files. Confirm attachment names/details display and each file opens successfully.
- [ ] **UI-08 (P1)** Attempt a file above the documented size limit and an unsupported file. Confirm a clear error, no partial attachment, and no app crash.
- [ ] **UI-09 (P1)** Remove an attachment and confirm it no longer appears or opens; verify cloud cleanup behavior when signed in.
- [ ] **UI-10 (P1)** Inspect Home, All Items, Calendar, Settings, sign-in, and add/edit screens. Confirm ads appear only on Home and All Items, with no interstitial/pop-up ads.
- [ ] **UI-11 (P1)** With test ads enabled, confirm the banner loads without covering navigation, controls, or content. With network unavailable/ad unavailable, confirm no awkward blank banner gap.
- [ ] **UI-12 (P0)** Verify Light, Dark, and System themes on key screens and dialogs. Confirm text, controls, and contrast remain usable.
- [ ] **UI-13 (P1)** Increase Android font/display size to the largest practical setting. Confirm text does not clip, overlap, or make critical actions unreachable.
- [ ] **UI-14 (P1)** Use TalkBack or Android accessibility scanner on onboarding, dashboard, reminder form, and Settings. Confirm controls have meaningful labels, focus order, and reachable actions.
- [ ] **UI-15 (P1)** Rotate or resize the app if the device supports it, background/resume the app, and navigate back from nested screens. Confirm state is not unexpectedly lost and there is no broken layout.
- [ ] **UI-16 (P1)** Confirm app name, launcher icon, splash/first-launch branding, and store screenshots represent the shipped app and contain no debug/test labels.

## 6. Offline, persistence, backup, import, and migration

- [ ] **DAT-01 (P0)** In airplane mode as a guest, create, view, edit, renew, archive, and delete reminders. Confirm every local operation works without Firebase or network access.
- [ ] **DAT-02 (P0)** Force-close and reopen while offline. Confirm saved records and renewal history persist and notification schedules are reconciled.
- [ ] **DAT-03 (P1)** Export CSV with representative values (commas, quotes, Unicode, empty fields, dates). Open in a spreadsheet and confirm rows/columns and escaping are correct.
- [ ] **DAT-04 (P0)** Export a JSON backup and inspect that it is valid and contains the expected data without credentials or unrelated account data.
- [ ] **DAT-05 (P0)** Import that backup on a clean test install. Confirm records, recurrence, history, family/vehicle associations, and supported settings are restored without duplicates or corruption.
- [ ] **DAT-06 (P1)** Import a legacy DueMate-format backup and a malformed/unsupported backup. Confirm compatible legacy data imports and invalid files fail clearly without damaging existing records.
- [ ] **DAT-07 (P1)** Cancel file selection or sharing during import/export. Confirm no false success message and the existing data remains unchanged.
- [ ] **DAT-08 (P0)** Install the candidate over the previous Play-track version with existing local data. Confirm the app opens, records remain, and reminder notifications are reconciled.
- [ ] **DAT-09 (P0)** Run database migration tests and upgrade a representative prior-version database. Confirm user data and profile fields survive; no destructive reset occurs.
- [ ] **DAT-10 (P1)** Test low-storage or file-access denial during attachment and backup operations if reproducible. Confirm explicit error handling and no damaged partial data.

## 7. Firebase sync, isolation, conflicts, and security rules

Run cloud cases only against designated test accounts and test data.

- [ ] **SYN-01 (P0)** Sign in on Device A, create representative reminders and settings, and confirm sync completes with a visible last-sync state and corresponding records under that user's Firebase path.
- [ ] **SYN-02 (P0)** Sign in to the same account on Device B. Confirm reminders, settings, profile, family/vehicle data, and renewal history arrive and local notifications are scheduled.
- [ ] **SYN-03 (P0)** Edit a reminder on A; refresh/reopen B. Confirm the new values arrive without duplicate records.
- [ ] **SYN-04 (P0)** Make changes offline on A, restore network, and confirm pending local changes sync without user data loss or duplicate uploads.
- [ ] **SYN-05 (P0)** Edit the same record offline on one device while deleting it on the other. Restore network and confirm deletion wins consistently on both devices.
- [ ] **SYN-06 (P1)** Keep a local unsynced edit while another device changes the cloud record. Confirm the unsynced local change is not silently overwritten and eventual state is understandable.
- [ ] **SYN-07 (P1)** Force a transient network failure during sync. Confirm the user is not shown a false synced success and retry succeeds after connectivity returns.
- [ ] **SYN-08 (P1)** Test repeated app resume/manual refresh after sync. Confirm sync is idempotent and does not duplicate reminders or cloud documents.
- [ ] **SYN-09 (P0)** Sign in to Device B with a different test account. Confirm none of Account A's records, attachments, or profile information are visible.
- [ ] **SYN-10 (P0)** Verify Firestore and Storage security rules reject unauthenticated access and cross-user reads/writes using the project's rules tests or Firebase emulator. Do not rely only on UI-level isolation.
- [ ] **SYN-11 (P1)** If Firebase Storage is enabled, upload an attachment on A, download/open on B, then delete it. Confirm failures are reported and do not prevent unrelated reminder sync.
- [ ] **SYN-12 (P0)** Sign out one device while another remains signed in. Confirm local account data and notifications are cleared only from the signed-out device; the cloud account and other device remain intact.
- [ ] **SYN-13 (P0)** Delete a disposable account and confirm another account's data is untouched; check Auth, Firestore, and Storage cleanup outcomes.
- [ ] **SYN-14 (P1)** Confirm date-only due dates and timestamps remain consistent between local storage and cloud after syncing across devices with different time zones.

## 8. Play listing, privacy, policy, and operational readiness

- [ ] **POL-01 (P0)** Confirm the Play listing app name, short description, full description, icon, feature graphic, screenshots, category, and support contact are complete and truthful.
- [ ] **POL-02 (P0)** Open the published privacy policy URL from a logged-out browser. Confirm it loads without authentication and matches actual collection, storage, sharing, retention, and deletion behavior.
- [ ] **POL-03 (P0)** Open the web account-deletion request URL from a logged-out browser. Confirm it works, explains the request process, and does not require installing the app or signing in to access instructions.
- [ ] **POL-04 (P0)** Compare Play Data safety, Ads, App access, target audience, content rating, and permissions declarations against the shipped build and actual Firebase/AdMob behavior. Correct any mismatch before submission.
- [ ] **POL-05 (P0)** Confirm the Play reviewer's app-access instructions clearly explain that sign-in is optional and how to reach the app without an account; provide test credentials only through Play Console's secure review-instructions flow if required.
- [ ] **POL-06 (P0)** Confirm the production Google Sign-In configuration contains the Play App Signing SHA-1 and SHA-256 fingerprints in Firebase, and verify Google sign-in on the Play-installed build.
- [ ] **POL-07 (P0)** Confirm the Play-installed build's phone authentication works with the approved test flow and production Firebase configuration.
- [ ] **POL-08 (P1)** Confirm notification permissions, exact-alarm opt-in behavior, and any store declarations match Android/Play requirements for the target SDK and actual feature use.
- [ ] **POL-09 (P1)** Confirm Firebase App Check, Firestore/Storage rules, backups, and billing budget alerts are configured as intended before real user data or paid usage is enabled.
- [ ] **POL-10 (P1)** Confirm AdMob uses the correct production app/ad-unit configuration, test devices were used during QA, no tester clicked live ads, and the listing is linked when eligible.
- [ ] **POL-11 (P1)** Confirm an `app-ads.txt` file is published at the developer website location AdMob specifies, if required for the account.
- [ ] **POL-12 (P1)** Review Android vitals/crash reporting availability and assign an owner to monitor crashes, ANRs, reviews, and support requests after rollout.
- [ ] **POL-13 (P0)** Prepare staged rollout percentage, release notes, rollback/stop-rollout owner, and a support contact. Confirm the previous known-good version/release is identifiable.

## Defect log

Record one row per failure. Link evidence stored in an approved private location; redact personal or secret data.

| Case ID | Severity | Device / OS | Reproduction steps | Expected | Actual | Evidence / issue | Owner | Status |
|---|---|---|---|---|---|---|---|---|
| | | | | | | | | |

## Release decision

- [ ] Every applicable **P0** case passed on the exact candidate build.
- [ ] Every applicable **P1** case passed, or an explicitly documented, low-risk workaround was reviewed and accepted by the release owner.
- [ ] No unresolved P0/P1 defects remain; no mandatory case is blocked or silently skipped.
- [ ] Automated quality gates passed, and the Play-installed build was exercised on a physical device.
- [ ] Play listing, privacy, account deletion, Data safety, signing, and operational checks are complete.
- [ ] Test results and defect log have been reviewed and approved by the release owner.

**Decision:** [ ] GO  [ ] NO-GO  
**Release owner / date:**  
**Outstanding accepted risks and approver (if any):**

Any unchecked release-gate item, unresolved release-blocking defect, or mismatch between declared and actual app behavior means **NO-GO**.
