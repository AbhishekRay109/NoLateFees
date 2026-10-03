import 'package:firebase_core/firebase_core.dart';

/// Build-time settings, passed with --dart-define-from-file=env.json (see
/// docs/FIREBASE_SETUP.md). With no Firebase values the app runs fully
/// offline: no sign-in, no sync, everything else works.
class AppConfig {
  /// Where bug reports and feedback go (Settings → Contact us).
  static const supportEmail = 'nolatefeesadmin@gmail.com';

  static const firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const firebaseAppId = String.fromEnvironment('FIREBASE_APP_ID');
  static const firebaseSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const firebaseStorageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');

  /// The *Web* OAuth client id from Firebase (Authentication → Sign-in method
  /// → Google → Web SDK configuration). Google Sign-In on Android needs it.
  static const googleServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

  /// AdMob banner unit id. Defaults to Google's test banner, which is safe to
  /// tap; put the real one in env.json before publishing (docs/ADS_SETUP.md).
  static const admobBannerId =
      String.fromEnvironment('ADMOB_BANNER_ID', defaultValue: 'ca-app-pub-3940256099942544/9214589741');

  /// Set ADS_ENABLED=false to build without ads.
  static const adsEnabled = bool.fromEnvironment('ADS_ENABLED', defaultValue: true);

  static bool get cloudEnabled =>
      firebaseApiKey.isNotEmpty &&
      firebaseAppId.isNotEmpty &&
      firebaseSenderId.isNotEmpty &&
      firebaseProjectId.isNotEmpty;

  static bool get googleSignInEnabled => cloudEnabled && googleServerClientId.isNotEmpty;

  /// Options passed to Firebase.initializeApp, so no google-services.json is needed.
  static FirebaseOptions get firebaseOptions => FirebaseOptions(
        apiKey: firebaseApiKey,
        appId: firebaseAppId,
        messagingSenderId: firebaseSenderId,
        projectId: firebaseProjectId,
        storageBucket: firebaseStorageBucket.isEmpty ? null : firebaseStorageBucket,
      );
}
