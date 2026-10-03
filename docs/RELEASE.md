# Releasing NoLateFees on Google Play

## Once

1. **Pick the final application id.** It is `com.nolatefees.app` in `android/app/build.gradle.kts` (`applicationId`) and can never change after the first upload. Change it now if you'd rather use a domain you own, reversed (e.g. `in.yourname.nolatefees`), and register the new id in Firebase too.
2. **Create an upload key** and keep it backed up somewhere safe (losing it means asking Google to reset it):
   ```bash
   keytool -genkey -v -keystore ~/nolatefees-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
3. Create `android/key.properties` (git-ignored):
   ```properties
   storePassword=...
   keyPassword=...
   keyAlias=upload
   storeFile=/absolute/path/to/nolatefees-upload.jks
   ```
   The release build picks it up automatically instead of the test key `android/app/ci-test.jks`.
   Add this key's SHA-1 and SHA-256 to Firebase (Project settings → Your apps), and also the **App signing key** fingerprints from Play Console → Setup → App signing, or Google and phone sign-in fail in the Play version.
4. **Play Console** ($25 one-time): create the app, enable **Play App Signing**.
5. **Privacy policy**: a one-page site (GitHub Pages is free). Say what's stored (reminders, optional attachments, name/email/phone if you sign in), where (on the phone; Google Firebase, Mumbai region, if signed in), and how to delete (Settings → Delete account).
6. **Data safety form**: name, email address and phone number (account, optional), device or other IDs (advertising ID, used by AdMob), files (attachments, optional), no data shared with third parties, data encrypted in transit, users can request deletion.
7. **App content**: contains ads (one AdMob banner, see [ADS_SETUP.md](ADS_SETUP.md)), target audience 18+.

## Every release

```bash
flutter test
# bump version in pubspec.yaml, e.g. 0.1.1+2 (the +N must always increase)
flutter build appbundle --release --dart-define-from-file=env.json
# output: build/app/outputs/bundle/release/app-release.aab
```

Upload to **Testing → Internal testing** first, install from the Play link on your own phone, run the Part 2 checklist in `docs/TESTING.md`, then promote.

## The 12-testers rule

New **personal** developer accounts must run a **closed test with at least 12 testers opted in for 14 days in a row** before production access is granted. Start this as early as possible:

1. Testing → Closed testing → create a track, upload a build.
2. Add testers by email list (a Google Group is easiest).
3. Share the opt-in link; each tester must accept and install, and stay opted in for 14 days.
4. Then apply for production access in the Dashboard.

Organization accounts (need a D-U-N-S number) are exempt.

## Before the public launch

- Firebase: turn on Firestore backups (point-in-time recovery or scheduled backups), set a budget alert if on Blaze, and enable App Check.
- The launcher icon comes from `assets/logo/logo.png` via `dart run flutter_launcher_icons`.
