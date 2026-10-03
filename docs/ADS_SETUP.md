# Ads (Google AdMob)

NoLateFees shows **one small banner** in a strip just above the bottom navigation, on the **Home** and **All Items** tabs only.

- No pop-ups, full-screen (interstitial) ads, video ads or ads you must watch.
- No ads on sign-in, the welcome screen, Add/Edit Reminder, Calendar, Settings, or in notifications.
- The strip takes no space until an ad has actually loaded, so offline or without a fill the screen looks exactly as before.
- The Add Reminder button always sits above the banner, so nobody taps an ad by accident (that also protects your AdMob account).

Out of the box every build uses **Google's test ads** (a banner labelled "Test Ad"). They earn nothing and are safe to tap. Do the steps below to earn real money.

## 1. Create the AdMob app and banner

1. Go to **https://admob.google.com** and sign in with your Google account. Fill in country (India), time zone and payment currency, accept the terms.
2. **Apps → Add app** → Android → "Is the app listed on a supported app store?" → **No** for now (link it to the Play listing after you publish) → app name `NoLateFees` → Add.
3. Copy the **App ID** (looks like `ca-app-pub-1234567890123456~1234567890`). This is `ADMOB_APP_ID`.
4. **Ad units → Add ad unit → Banner** → name it `Home banner` → Create.
5. Copy the **Ad unit ID** (looks like `ca-app-pub-1234567890123456/1234567890`, with a slash). This is `ADMOB_BANNER_ID`.

New ad units can take an hour or so before real ads fill; until then the strip simply stays hidden.

## 2. Add the IDs to the build

Edit the `APP_ENV_JSON` secret in GitHub (repo → Settings → Secrets and variables → Actions → `APP_ENV_JSON` → Update) and add two lines to the JSON:

```json
  "ADMOB_APP_ID": "ca-app-pub-1234567890123456~1234567890",
  "ADMOB_BANNER_ID": "ca-app-pub-1234567890123456/1234567890"
```

If you haven't set up Firebase yet, the secret can contain just these two keys. Then run **Actions → Build APK** again.

## 3. Rules to keep your AdMob account safe

- **Never tap the real ads in your own app**, and don't ask friends to. AdMob detects it and can suspend the account. While testing real IDs, add your Pixel as a test device: AdMob → Settings → **Test devices** → Add (the advertising ID is in Android Settings → Google → All services → Ads).
- Don't move the banner so it touches buttons, and don't add a second one on the same screen.

## 4. Before publishing on Google Play

- Play Console → **App content → Ads** → "Yes, my app contains ads".
- **Data safety** form: add "Device or other IDs" (Advertising ID) collected for advertising, shared with Google.
- **Privacy policy**: say the app shows ads from Google AdMob, which may use the advertising ID. Users in the EU/UK see Google's consent form automatically on first launch; the app already asks for it.
- **app-ads.txt**: AdMob asks you to put a small text file on your developer website (a free GitHub Pages site works). AdMob → Apps → View all apps → app-ads.txt shows the exact line.
- After the app is live, link it to the Play listing in AdMob (Apps → App settings → Add store).

## What to expect

A single banner earns little per user (banner rates in India are low), so treat it as a small extra that grows with users. AdMob pays out once your balance passes the payment threshold. If later you want more without hurting the experience, the friendliest options are a one-time **"Remove ads"** purchase or a small premium plan (family sharing, unlimited attachments) rather than more ads.

## Turning ads off

Build with `"ADS_ENABLED": false` in `env.json` / `APP_ENV_JSON` and the app contains no ads at all.
