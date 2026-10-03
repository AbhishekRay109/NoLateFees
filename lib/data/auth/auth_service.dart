// Sign-in, behind an interface so screens and tests don't depend on Firebase.
import 'dart:async';

/// The signed-in person, as far as the app cares.
class AppUser {
  const AppUser({required this.uid, this.name, this.email, this.phone, this.photoUrl});

  final String uid;
  final String? name;
  final String? email;
  final String? phone;
  final String? photoUrl;
}

/// Result of asking for an SMS code.
sealed class PhoneVerification {
  const PhoneVerification();
}

/// The SMS was sent; ask the user for the code.
class CodeSent extends PhoneVerification {
  const CodeSent(this.verificationId, {this.resendToken});
  final String verificationId;
  final int? resendToken;
}

/// Android read the SMS by itself and the user is already signed in.
class AutoVerified extends PhoneVerification {
  const AutoVerified(this.user);
  final AppUser user;
}

/// Friendly, user-facing failure. [code] is for logs and tests.
class AuthFailure implements Exception {
  const AuthFailure(this.code, this.message);
  final String code;
  final String message;

  @override
  String toString() => 'AuthFailure($code): $message';
}

/// Thrown when the user backs out of a sign-in sheet. Not an error to show.
class AuthCancelled implements Exception {
  const AuthCancelled();
}

abstract class AuthService {
  AppUser? get currentUser;
  Stream<AppUser?> userChanges();

  bool get googleAvailable;

  Future<AppUser> signInWithGoogle();

  /// Sends a code to [phoneE164] (e.g. +919876543210).
  Future<PhoneVerification> sendPhoneCode(String phoneE164, {int? resendToken});

  Future<AppUser> confirmPhoneCode(String verificationId, String smsCode);

  Future<void> signOut();

  /// Deletes the sign-in account. May throw AuthFailure('requires-recent-login').
  Future<void> deleteAccount();
}

// ---------------------------------------------------------------- validation

/// Turns what people type into E.164. Ten-digit numbers are assumed to be
/// Indian (+91). Returns null if it can't be a valid number.
String? normalizePhone(String input, {String defaultCountryCode = '+91'}) {
  var s = input.replaceAll(RegExp(r'[\s\-().]'), '');
  if (s.isEmpty) return null;
  if (s.startsWith('00')) s = '+${s.substring(2)}';
  if (!s.startsWith('+')) {
    if (s.startsWith('0')) s = s.substring(1);
    if (defaultCountryCode == '+91' && s.length == 12 && s.startsWith('91')) {
      s = '+$s';
    } else {
      s = '$defaultCountryCode$s';
    }
  }
  if (!RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(s)) return null;
  if (s.startsWith('+91') && !RegExp(r'^\+91[6-9]\d{9}$').hasMatch(s)) return null;
  return s;
}

bool isValidEmail(String input) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(input.trim());

/// "+919876543210" → "+91 98765 43210" for display.
String formatPhone(String e164) {
  if (RegExp(r'^\+91\d{10}$').hasMatch(e164)) {
    return '+91 ${e164.substring(3, 8)} ${e164.substring(8)}';
  }
  return e164;
}

/// "Sumaiya Mansoor" → "SM", for avatars.
String initialsOf(String? name) {
  final parts = (name ?? '').trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '🙂';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
}
