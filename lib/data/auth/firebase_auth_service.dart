// Firebase Auth: Google (via google_sign_in + Credential Manager) and phone OTP.
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_service.dart';

class FirebaseAuthService implements AuthService {
  FirebaseAuthService(this._auth, {String? googleServerClientId})
      : _serverClientId = googleServerClientId;

  final FirebaseAuth _auth;
  final String? _serverClientId;
  bool _googleReady = false;

  static AppUser? _map(User? u) => u == null
      ? null
      : AppUser(uid: u.uid, name: u.displayName, email: u.email, phone: u.phoneNumber, photoUrl: u.photoURL);

  @override
  AppUser? get currentUser => _map(_auth.currentUser);

  @override
  Stream<AppUser?> userChanges() => _auth.userChanges().map(_map);

  @override
  bool get googleAvailable => (_serverClientId ?? '').isNotEmpty;

  @override
  Future<AppUser> signInWithGoogle() async {
    if (!googleAvailable) {
      throw const AuthFailure('google-not-configured', 'Google sign-in is not set up in this build.');
    }
    final google = GoogleSignIn.instance;
    if (!_googleReady) {
      await google.initialize(serverClientId: _serverClientId);
      _googleReady = true;
    }
    try {
      final account = await google.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) throw const AuthFailure('no-id-token', 'Google did not return a sign-in token.');
      final cred = await _auth.signInWithCredential(GoogleAuthProvider.credential(idToken: idToken));
      return _map(cred.user)!;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) throw const AuthCancelled();
      throw AuthFailure('google-${e.code.name}', 'Google sign-in failed. Check your connection and try again.');
    } on FirebaseAuthException catch (e) {
      throw _friendly(e);
    }
  }

  @override
  Future<PhoneVerification> sendPhoneCode(String phoneE164, {int? resendToken}) {
    final done = Completer<PhoneVerification>();
    _auth
        .verifyPhoneNumber(
          phoneNumber: phoneE164,
          forceResendingToken: resendToken,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (credential) async {
            // Android auto-read the SMS.
            try {
              final result = await _auth.signInWithCredential(credential);
              if (!done.isCompleted) done.complete(AutoVerified(_map(result.user)!));
            } on FirebaseAuthException catch (e) {
              if (!done.isCompleted) done.completeError(_friendly(e));
            }
          },
          verificationFailed: (e) {
            if (!done.isCompleted) done.completeError(_friendly(e));
          },
          codeSent: (id, token) {
            if (!done.isCompleted) done.complete(CodeSent(id, resendToken: token));
          },
          codeAutoRetrievalTimeout: (_) {},
        )
        .catchError((Object e) {
      if (!done.isCompleted) {
        done.completeError(e is FirebaseAuthException ? _friendly(e) : e);
      }
    });
    return done.future;
  }

  @override
  Future<AppUser> confirmPhoneCode(String verificationId, String smsCode) async {
    try {
      final cred = await _auth.signInWithCredential(
          PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode));
      return _map(cred.user)!;
    } on FirebaseAuthException catch (e) {
      throw _friendly(e);
    }
  }

  @override
  Future<void> signOut() async {
    if (_googleReady) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}
    }
    await _auth.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _friendly(e);
    }
  }

  static AuthFailure _friendly(FirebaseAuthException e) => AuthFailure(e.code, switch (e.code) {
        'invalid-phone-number' => 'That phone number doesn\'t look right.',
        'invalid-verification-code' => 'That code didn\'t work. Check it and try again.',
        'session-expired' || 'code-expired' => 'The code expired. Tap "Resend code".',
        'too-many-requests' => 'Too many attempts. Wait a few minutes and try again.',
        'quota-exceeded' => 'SMS limit reached for today. Try Google sign-in or try again tomorrow.',
        'network-request-failed' => 'No connection. Check your internet and try again.',
        'requires-recent-login' => 'For safety, sign in again and then retry.',
        'account-exists-with-different-credential' =>
          'This email is already linked to another sign-in method. Use that one.',
        'app-not-authorized' || 'invalid-app-credential' || 'missing-client-identifier' =>
          'This build isn\'t registered with Firebase yet (SHA fingerprint missing).',
        'operation-not-allowed' => 'This sign-in method isn\'t turned on in Firebase.',
        _ => 'Sign-in failed. Please try again.',
      });
}
