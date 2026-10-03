import 'package:firebase_core/firebase_core.dart';

/// Build-time settings, passed with --dart-define-from-file=env.json (see
/// docs/FIREBASE_SETUP.md). With no Firebase values the app runs fully
/// offline: no sign-in, no sync, everything else works.
class AppConfig {
  static const firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const firebaseAppId = String.fromEnvironment('FIREBASE_APP_ID');
  static const firebaseSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const firebaseStorageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');

  /// The *Web* OAuth client id from Firebase (Authentication → Sign-in method
  /// → Google → Web SDK configuration). Google Sign-In on Android needs it.
  static const googleServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

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
