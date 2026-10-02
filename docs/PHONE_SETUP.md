# Run DueMate on your Android phone

From a fresh computer to the full test pass. Steps 1 to 5 are one-time setup.

## 1. Install the tools on your computer (one time)

1. **Android Studio**: download from developer.android.com/studio and install it with the defaults. On first launch let the setup wizard install the **Android SDK**, **SDK Platform-Tools** and an Android platform.
2. In Android Studio: **Settings → Languages & Frameworks → Android SDK → SDK Tools** tab, tick **Android SDK Command-line Tools (latest)**, click Apply.
3. **Flutter**: follow docs.flutter.dev/get-started/install for your OS (Windows, macOS or Linux → Android). Use the **stable** channel, version **3.47 or newer**. Make sure `flutter` works in a new terminal: `flutter --version`.
4. Accept the Android licences and check everything:
   ```bash
   flutter doctor --android-licenses     # press y for each
   flutter doctor
   ```
   You need green ticks for **Flutter** and **Android toolchain**. Chrome, Xcode and Visual Studio can stay red, they're not needed.
5. **Windows only**: if the phone isn't detected later, install your phone maker's USB driver (Samsung, Xiaomi, etc. publish one) or Google's USB driver from the SDK Manager.

## 2. Connect the phone

1. Phone: **Settings → Developer options → USB debugging** on (you've done this).
   - **Xiaomi / Redmi / POCO**: also turn on **Install via USB** and **USB debugging (Security settings)** in Developer options. They need a SIM and a Mi account signed in.
   - **Oppo / Realme / Vivo**: also turn on **Disable permission monitoring** if it exists, and allow **Install via USB**.
2. Plug the phone into the computer with a cable that carries **data** (some charging cables don't).
3. On the phone, pull down the notification shade, tap the USB notification and choose **File transfer**.
4. A popup asks **"Allow USB debugging?"**. Tick **Always allow from this computer** and tap **Allow**.
5. On the computer:
   ```bash
   flutter devices
   ```
   Your phone should be listed, e.g. `Redmi Note 13 (mobile) • 1a2b3c4d • android-arm64`.
   - Shows **unauthorized**: unplug, on the phone go to Developer options → **Revoke USB debugging authorizations**, plug in again and accept the popup.
   - Not listed at all: try another cable or USB port, re-select File transfer, and run `adb kill-server && adb devices`.

## 3. Get the code ready

```bash
cd duemate                # the unzipped folder
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze           # expect: No issues found!
flutter test              # expect: All tests passed!
```

If you changed any code, fix anything `analyze` or `test` reports before going further. If you only edited `env.json`, both should still pass as before.

## 4. First run: offline mode (no account)

```bash
flutter run
```

The first build downloads Gradle and Android libraries and can take 5–15 minutes. Later builds take under a minute. The app opens on the phone showing **"Nothing to track yet"**.

While `flutter run` is running in the terminal: press `r` to reload after a code change, and `q` to quit.

## 5. Install a proper build for the real tests

Debug builds are slow and some phones stop them in the background, which makes notification tests unreliable. For Part 2 of the checklist, install a release build:

```bash
# offline mode
flutter run --release

# or with cloud sync, once env.json has your Supabase URL and publishable key
flutter run --release --dart-define-from-file=env.json
```

After it opens you can unplug the phone. The app stays installed and works on its own.

## 6. Full test pass

Work through `docs/TESTING.md` in this order and tick each line:

1. **Part 2: Manual test on a phone.** Do the **Notifications** block first, because it matters most: the 2-minute test, tapping the notification, **Renewed**, **Snooze** with the app swiped away, the **reboot** test, then edit, delete and turning notifications off. Then do the Renewal and "Everything else" blocks.
2. **Battery check.** If your phone is Xiaomi, Oppo, Vivo, Realme, OnePlus or Samsung, repeat the reboot and swipe-away tests. If an alert doesn't arrive: **Settings → Apps → DueMate → Battery → No restrictions** (on Xiaomi also **Autostart → on**), then retest. Note the difference.
3. **Part 3 + Part 4: cloud sync**, only if you've set up Supabase. Run the release build with `--dart-define-from-file=env.json` on the phone. Use an emulator (Android Studio → Device Manager → create a Pixel device) as the second device:
   ```bash
   flutter devices                                        # note both device ids
   flutter run --release -d <phone-id> --dart-define-from-file=env.json
   flutter run -d <emulator-id> --dart-define-from-file=env.json
   ```

## 7. If something goes wrong

Capture the logs while you reproduce the problem:

```bash
adb logcat -c                      # clear old logs
adb logcat | grep -iE "flutter|duemate|notification"
```

Useful checks:

| Problem | Check |
|---|---|
| No notifications at all | Settings → Apps → DueMate → Notifications is on; in the app, Settings → Notifications is on |
| Notification arrives late | Expected with Exact timing off (a few minutes). Turn on Exact timing in the app's Settings to compare |
| Nothing after reboot | Battery set to "No restrictions"; on Xiaomi, Autostart on |
| See what's scheduled | `adb shell dumpsys alarm \| grep -A3 app.duemate` |
| Build fails with "SDK not found" or licences | `flutter doctor -v`, then `flutter doctor --android-licenses` |
| Build fails with Gradle or Java errors | `flutter clean && flutter pub get`, then build again; send the last 30 lines of the error |
| Sign-in code never arrives | Check spam; the free Supabase email sender only allows a few emails an hour |

For each failed checklist line, note the phone model and Android version, what you expected, what happened, and attach the log output.
