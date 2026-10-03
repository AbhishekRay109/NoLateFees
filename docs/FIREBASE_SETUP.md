# Turning on sign-in and cloud sync (Firebase)

NoLateFees works fully offline without any of this. Do these steps once to switch on **Google sign-in, phone number (OTP) sign-in and cloud backup/sync**. Everything is done in a browser: no Android Studio, no code changes.

You'll need about 20 minutes, a Google account, and access to the GitHub repo's settings.

## How cloud sync works (and where your data lives)

- Every change is saved on the phone first, so the app is instant and works in airplane mode.
- When you're signed in and online, the app uploads what changed and downloads changes made on your other phones. It syncs on app open, a second after each change, when the internet comes back, and when you pull down on the dashboard.
- Your data is stored in **Cloud Firestore** (Google's database, region Mumbai) under `users/<your-user-id>/items`, `.../renewals`, `.../family_members` and so on. The security rules in [`firebase/firestore.rules`](../firebase/firestore.rules) make sure each account can only read and write its own folder.
- Attached PDFs and photos go to **Firebase Storage** under `users/<your-user-id>/attachments/`. This part is optional (see step 6).
- If two phones change the same item while offline, the last one to sync wins, and a delete always wins over an edit.

## The test signing key (why sign-in works on GitHub builds)

Google and phone sign-in only work in apps whose signing fingerprint is registered with Firebase. The repo includes a **test-only** key, `android/app/ci-test.jks`, so every GitHub build has the same fingerprints:

```text
SHA-1:   B4:86:49:3B:67:43:21:A0:67:25:FE:93:2B:34:5D:DF:E1:5B:B7:0F
SHA-256: 98:23:95:E3:4C:C6:C1:FC:F4:F2:D0:FA:05:FF:9B:04:8D:0A:33:23:FF:D6:BA:1A:8C:CD:B1:AA:4A:D1:D8:F8
```

Its password is public, so **never use it for the Play Store**. For the real release you make your own key (see [RELEASE.md](RELEASE.md)) and add its fingerprints to Firebase too.

---

## 1. Create the Firebase project

1. Open **https://console.firebase.google.com** and sign in.
2. **Create a project** → name it `NoLateFees` → Continue.
3. Google Analytics: you can turn it off for now → **Create project**.

## 2. Add the Android app

1. On the project overview page, click the **Android** icon ("Add app").
2. **Android package name:** `com.nolatefees.app` (exactly this).
3. **App nickname:** `NoLateFees`.
4. **Debug signing certificate SHA-1:** paste the SHA-1 above.
5. **Register app**, then **Download google-services.json**. You won't add this file to the code; you only copy a few values out of it in step 7. Click Next / Continue to console for the remaining screens.
6. Add the SHA-256 too: ⚙️ **Project settings** → **General** → scroll to **Your apps** → NoLateFees → **Add fingerprint** → paste the SHA-256 → Save.

## 3. Turn on Google sign-in

1. Left menu → **Build → Authentication** → **Get started**.
2. **Sign-in method** tab → **Google** → **Enable**.
3. Pick a **support email** (your Gmail) → **Save**.
4. Open **Google** again and expand **Web SDK configuration**. Copy the **Web client ID** (looks like `1234567890-abc...apps.googleusercontent.com`). That's `GOOGLE_SERVER_CLIENT_ID` in step 7.

## 4. Turn on phone number sign-in

1. Still in **Authentication → Sign-in method** → **Add new provider** → **Phone** → **Enable** → Save.
2. Add a test number so you can test without real SMS: on the same Phone page open **Phone numbers for testing** → add `+91 99999 00001` with code `123456` → Save. Signing in with that number never sends an SMS; you just type `123456`.
3. Real SMS: Firebase gives a small free allowance, but depending on your plan it may ask you to upgrade to the pay-as-you-go **Blaze** plan before real SMS are sent. Test numbers always work on the free plan. If real SMS don't arrive, check **Authentication → Settings → SMS region policy** allows India.

## 5. Create the database

1. Left menu → **Build → Firestore Database** → **Create database**.
2. Location: **asia-south1 (Mumbai)**. This can't be changed later.
3. Start in **production mode** → Create.
4. Open the **Rules** tab, delete what's there, paste the whole of [`firebase/firestore.rules`](../firebase/firestore.rules) from the repo → **Publish**.

## 6. (Optional) File attachments

Cloud copies of attached PDFs and photos need Firebase Storage, which requires the Blaze plan (it has a free monthly allowance, but a billing account must be added). Skip this and everything else still syncs; attachments simply stay on the phone they were added on.

If you want it: **Build → Storage** → **Get started** → same location → then the **Rules** tab → paste [`firebase/storage.rules`](../firebase/storage.rules) → **Publish**. Copy the bucket name shown at the top (like `nolatefees-xxxx.firebasestorage.app`).

## 7. Give the values to the build

Easiest: put them in `app_config.json` at the repo root (or send them to Claude in the project thread and it will commit the file). These values are not passwords: they ship inside every APK anyway, and the security rules are what protect the data. GitHub may still flag the API key as a "secret"; that alert can be closed as "used in tests / false positive". If you'd rather keep them out of the repo, use the GitHub secret below instead (it overrides the file).


Open the `google-services.json` you downloaded (any text editor) and find these values:

| Setting | Where in google-services.json |
|---|---|
| `FIREBASE_API_KEY` | `client[0].api_key[0].current_key` (starts with `AIza`) |
| `FIREBASE_APP_ID` | `client[0].client_info.mobilesdk_app_id` (like `1:1234567890:android:abc123`) |
| `FIREBASE_MESSAGING_SENDER_ID` | `project_info.project_number` |
| `FIREBASE_PROJECT_ID` | `project_info.project_id` |
| `FIREBASE_STORAGE_BUCKET` | `project_info.storage_bucket` (leave empty `""` if you skipped step 6) |
| `GOOGLE_SERVER_CLIENT_ID` | the Web client ID from step 3 |

Then on GitHub: the repo → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**.

- **Name:** `APP_ENV_JSON`
- **Secret:** the block below with your values filled in

```json
{
  "FIREBASE_API_KEY": "AIza...",
  "FIREBASE_APP_ID": "1:1234567890:android:abc123",
  "FIREBASE_MESSAGING_SENDER_ID": "1234567890",
  "FIREBASE_PROJECT_ID": "nolatefees-xxxx",
  "FIREBASE_STORAGE_BUCKET": "",
  "GOOGLE_SERVER_CLIENT_ID": "1234567890-abc.apps.googleusercontent.com"
}
```

These values identify your Firebase project; they are not passwords (the security rules are what protect the data), but keeping them in a secret keeps the repo tidy.

## 8. Build and install

1. GitHub repo → **Actions** → **Build APK** → **Run workflow** → pick the branch → **Run workflow**.
2. When it's green, the build log step "Write env.json" should list your six keys (it never prints the values).
3. On the Pixel, open the repo's **Releases** page, download `NoLateFees.apk` from the newest "NoLateFees test build" and install it.

The app id changed from the old DueMate test builds, so NoLateFees installs as a new app. Uninstall the old **DueMate** app (export a JSON backup first if you want to keep test data; NoLateFees can import it).

## 9. Check it works

- [ ] Fresh install → welcome screen shows **Continue with Google** and **Continue with phone number**.
- [ ] **Google**: pick your account → "About you" is filled with your name and email → **Let's go** → dashboard.
- [ ] Firebase console → **Authentication → Users**: your account is listed.
- [ ] Add a reminder. Firebase console → **Firestore Database → Data → users → (your id) → items**: it's there within a few seconds.
- [ ] **Phone**: Settings → Sign out → welcome screen → Continue with phone number → `99999 00001` → code `123456` → signed in.
- [ ] Second phone (or uninstall/reinstall): sign in with the same Google account → your reminders come back.

## Troubleshooting

| What you see | Fix |
|---|---|
| Welcome screen says sign-in switches on once Firebase is connected | The `APP_ENV_JSON` secret is missing or isn't valid JSON. Check the "Write env.json" step in the Actions log |
| "This build isn't registered with Firebase yet (SHA fingerprint missing)" | Add both SHA-1 and SHA-256 from above in Project settings → Your apps |
| Google: "Google sign-in failed" right away | `GOOGLE_SERVER_CLIENT_ID` must be the **Web** client ID (step 3), not the Android one; Google provider must be enabled |
| Phone: "This sign-in method isn't turned on" | Enable the Phone provider (step 4) |
| Phone: code never arrives for a real number | Use the test number, or check plan/SMS region policy (step 4.3) |
| Signed in, but nothing appears in Firestore | Firestore not created, or rules not published (step 5) |
| Attachments don't show on the second phone | Storage not set up (step 6); expected on the free plan |

## Building on your own computer (optional)

Save the same JSON as `env.json` in the project folder (it's git-ignored) and run `flutter run --dart-define-from-file=env.json`. Debug builds use the same test key, so sign-in works there too.
