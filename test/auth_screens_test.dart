import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nolatefees/app.dart';
import 'package:nolatefees/app_services.dart';
import 'package:nolatefees/data/auth/auth_service.dart';
import 'package:nolatefees/features/auth/phone_sign_in_screen.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

import 'helpers.dart';

void main() {
  setUpAll(tzdata.initializeTimeZones);

  late AppServices services;
  late FakeAuthService auth;

  setUp(() {
    auth = FakeAuthService();
    services = buildServices(auth: auth);
  });

  tearDown(() => services.db.close());

  Future<void> pumpApp(WidgetTester tester, {bool onboarded = false}) async {
    usePhoneScreen(tester);
    if (onboarded) await tester.runAsync(() => markOnboarded(services));
    await tester.pumpWidget(ProviderScope(
      overrides: [servicesProvider.overrideWithValue(services)],
      child: const NoLateFeesApp(),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> tapAndSettle(WidgetTester tester, Finder f) async {
    await tester.ensureVisible(f);
    await tester.tap(f);
    await settleDb(tester);
  }

  group('welcome screen', () {
    testWidgets('shows Google, phone and skip when sign-in is set up', (tester) async {
      await pumpApp(tester);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with phone number'), findsOneWidget);
      expect(find.text('Continue without an account'), findsOneWidget);
      expect(find.textContaining('Firebase is connected'), findsNothing);
    });

    testWidgets('hides Google when it is not configured', (tester) async {
      auth.googleAvailable = false;
      await pumpApp(tester);
      expect(find.text('Continue with Google'), findsNothing);
      expect(find.text('Continue with phone number'), findsOneWidget);
    });

    testWidgets('Google sign-in prefills the profile, then opens the dashboard', (tester) async {
      await pumpApp(tester);
      await tapAndSettle(tester, find.text('Continue with Google'));

      expect(find.text('About you'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Asha Rao'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'asha@example.com'), findsOneWidget);

      await tapAndSettle(tester, find.text('Let\'s go'));
      expect(find.textContaining(', Asha 👋'), findsOneWidget);
      final p = await tester.runAsync(() => services.repo.profile());
      expect(p!.onboarded, isTrue);
      expect(p.email, 'asha@example.com');
    });

    testWidgets('closing the Google picker shows no error', (tester) async {
      auth.googleResult = const AuthCancelled();
      await pumpApp(tester);
      await tapAndSettle(tester, find.text('Continue with Google'));
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.textContaining('failed'), findsNothing);
    });

    testWidgets('a Google failure shows its friendly message', (tester) async {
      auth.googleResult = const AuthFailure('app-not-authorized', 'This build isn\'t registered with Firebase yet.');
      await pumpApp(tester);
      await tapAndSettle(tester, find.text('Continue with Google'));
      expect(find.text('This build isn\'t registered with Firebase yet.'), findsOneWidget);
    });

    testWidgets('continue without an account goes to the profile screen', (tester) async {
      await pumpApp(tester);
      await tapAndSettle(tester, find.text('Continue without an account'));
      expect(find.text('About you'), findsOneWidget);
      expect(services.signedIn, isFalse);
    });
  });

  group('phone sign-in', () {
    Future<void> openPhone(WidgetTester tester) async {
      await pumpApp(tester);
      await tapAndSettle(tester, find.text('Continue with phone number'));
      expect(find.text('Your phone number'), findsOneWidget);
    }

    testWidgets('a bad number is caught before anything is sent', (tester) async {
      await openPhone(tester);
      await tester.enterText(find.byKey(const Key('phoneField')), '12345');
      await tapAndSettle(tester, find.text('Send code'));
      expect(find.textContaining('Enter a valid mobile number'), findsOneWidget);
      expect(auth.sentTo, isEmpty);
    });

    testWidgets('code flow: wrong code, then right code, then verified phone on profile', (tester) async {
      await openPhone(tester);
      await tester.enterText(find.byKey(const Key('phoneField')), '98765 43210');
      await tapAndSettle(tester, find.text('Send code'));

      expect(auth.sentTo, ['+919876543210']);
      expect(find.text('We sent a code to +91 98765 43210.'), findsOneWidget);
      expect(find.text('Resend in ${resendSeconds}s'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('codeField')), '111111'); // auto-submits at 6 digits
      await settleDb(tester);
      expect(find.textContaining('That code didn\'t work'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('codeField')), '123456');
      await settleDb(tester);

      expect(find.text('About you'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '+91 98765 43210'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
      final p = await tester.runAsync(() => services.repo.profile());
      expect(p!.phone, '+919876543210');
    });

    testWidgets('resend waits for the countdown and reuses the resend token', (tester) async {
      await openPhone(tester);
      await tester.enterText(find.byKey(const Key('phoneField')), '9876543210');
      await tapAndSettle(tester, find.text('Send code'));

      await tester.tap(find.text('Resend in ${resendSeconds}s'));
      await tester.pump();
      expect(auth.sentTo, hasLength(1)); // disabled while counting down

      await tester.pump(const Duration(seconds: resendSeconds + 1));
      expect(find.text('Resend code'), findsOneWidget);
      await tapAndSettle(tester, find.text('Resend code'));
      expect(auth.sentTo, hasLength(2));
      expect(auth.resendTokens, [null, 7]);
      await tester.pump(const Duration(seconds: resendSeconds + 1));
    });

    testWidgets('change number goes back to the number field', (tester) async {
      await openPhone(tester);
      await tester.enterText(find.byKey(const Key('phoneField')), '9876543210');
      await tapAndSettle(tester, find.text('Send code'));
      await tapAndSettle(tester, find.text('Change number'));
      expect(find.byKey(const Key('phoneField')), findsOneWidget);
      await tester.pump(const Duration(seconds: resendSeconds + 1));
    });

    testWidgets('Android auto-verification skips the code screen', (tester) async {
      auth.sendCodeResult = const AutoVerified(AppUser(uid: 'p-2', phone: '+919876543210'));
      await openPhone(tester);
      await tester.enterText(find.byKey(const Key('phoneField')), '9876543210');
      await tapAndSettle(tester, find.text('Send code'));
      expect(find.text('About you'), findsOneWidget);
    });

    testWidgets('a send failure (e.g. SMS quota) is shown', (tester) async {
      auth.sendCodeResult = const AuthFailure('quota-exceeded', 'SMS limit reached for today.');
      await openPhone(tester);
      await tester.enterText(find.byKey(const Key('phoneField')), '9876543210');
      await tapAndSettle(tester, find.text('Send code'));
      expect(find.text('SMS limit reached for today.'), findsOneWidget);
    });

    testWidgets('a short code asks for all 6 digits', (tester) async {
      await openPhone(tester);
      await tester.enterText(find.byKey(const Key('phoneField')), '9876543210');
      await tapAndSettle(tester, find.text('Send code'));
      await tester.enterText(find.byKey(const Key('codeField')), '123');
      await tapAndSettle(tester, find.text('Verify'));
      expect(find.text('Enter the 6-digit code from the SMS.'), findsOneWidget);
      await tester.pump(const Duration(seconds: resendSeconds + 1));
    });
  });

  group('profile screen', () {
    testWidgets('validates email and phone', (tester) async {
      await pumpApp(tester);
      await tapAndSettle(tester, find.text('Continue without an account'));
      await tester.enterText(find.byKey(const Key('nameField')), 'Asha');
      await tester.enterText(find.byKey(const Key('emailField')), 'asha@');
      await tester.enterText(find.byKey(const Key('profilePhoneField')), '123');
      await tapAndSettle(tester, find.text('Let\'s go'));
      expect(find.text('That email doesn\'t look right'), findsOneWidget);
      expect(find.text('Enter a valid mobile number'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('emailField')), 'asha@example.com');
      await tester.enterText(find.byKey(const Key('profilePhoneField')), '09876543210');
      await tapAndSettle(tester, find.text('Let\'s go'));
      final p = await tester.runAsync(() => services.repo.profile());
      expect(p!.email, 'asha@example.com');
      expect(p.phone, '+919876543210');
    });
  });

  group('settings account section', () {
    Future<void> openSettings(WidgetTester tester) async {
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
    }

    testWidgets('signed out: profile card and a sign-in entry', (tester) async {
      await pumpApp(tester, onboarded: true);
      await openSettings(tester);
      expect(find.text('Asha'), findsOneWidget);
      expect(find.text('On this phone only'), findsOneWidget);
      expect(find.text('Sign in to back up and sync'), findsOneWidget);
      expect(find.text('Delete account'), findsNothing);
    });

    testWidgets('sign in from settings returns to settings, signed in', (tester) async {
      await pumpApp(tester, onboarded: true);
      await openSettings(tester);
      await tapAndSettle(tester, find.text('Sign in to back up and sync'));
      expect(find.text('Sign in'), findsOneWidget);
      await tapAndSettle(tester, find.text('Continue with Google'));
      expect(find.text('Signed in. Your reminders are syncing.'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);
      await tester.drag(find.ancestor(of: find.text('Sign out'), matching: find.byType(Scrollable)).first,
          const Offset(0, 2000));
      await tester.pumpAndSettle();
      expect(find.text('Synced to your account'), findsOneWidget);
      expect(find.text('asha@example.com'), findsOneWidget);
      // Name typed during onboarding wins over the Google name.
      expect(find.text('Asha'), findsOneWidget);
    });

    testWidgets('edit profile from the card', (tester) async {
      await pumpApp(tester, onboarded: true);
      await openSettings(tester);
      await tapAndSettle(tester, find.text('Asha'));
      expect(find.text('Edit profile'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('nameField')), 'Asha Rao');
      await tapAndSettle(tester, find.text('Save'));
      expect(find.text('Asha Rao'), findsOneWidget);
      expect(find.text('Profile saved.'), findsOneWidget);
    });

    testWidgets('sign out asks first, then returns to the welcome screen', (tester) async {
      // Database writes must happen before the app is pumped (see settleDb).
      await tester.runAsync(() async => services.completeSignIn(await auth.signInWithGoogle()));
      await pumpApp(tester, onboarded: true);
      await openSettings(tester);
      await tapAndSettle(tester, find.text('Sign out'));
      expect(find.text('Sign out?'), findsOneWidget);
      await tapAndSettle(tester, find.text('Continue'));
      expect(auth.signOutCalls, 1);
      expect(find.text('Never pay a late fee again.'), findsOneWidget);
    });
  });
}
