import 'package:flutter_test/flutter_test.dart';
import 'package:nolatefees/app_services.dart';
import 'package:nolatefees/data/auth/auth_service.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

import 'helpers.dart';

void main() {
  setUpAll(tzdata.initializeTimeZones);

  group('normalizePhone', () {
    test('ten-digit Indian mobile numbers get +91', () {
      expect(normalizePhone('9876543210'), '+919876543210');
      expect(normalizePhone('98765 43210'), '+919876543210');
      expect(normalizePhone('98765-43210'), '+919876543210');
      expect(normalizePhone('(987) 654-3210'), '+919876543210');
    });

    test('leading 0, 0091, 91 and +91 forms are all understood', () {
      expect(normalizePhone('09876543210'), '+919876543210');
      expect(normalizePhone('00919876543210'), '+919876543210');
      expect(normalizePhone('919876543210'), '+919876543210');
      expect(normalizePhone('+91 98765 43210'), '+919876543210');
    });

    test('Indian numbers must be mobile numbers (start 6-9, 10 digits)', () {
      expect(normalizePhone('5876543210'), isNull);
      expect(normalizePhone('987654321'), isNull);
      expect(normalizePhone('98765432101'), isNull);
      expect(normalizePhone('+9198765'), isNull);
    });

    test('other countries pass through when written with +', () {
      expect(normalizePhone('+1 415 555 2671'), '+14155552671');
      expect(normalizePhone('+44 7911 123456'), '+447911123456');
      expect(normalizePhone('+971 50 123 4567'), '+971501234567');
    });

    test('a different default country code is used for local numbers', () {
      expect(normalizePhone('4155552671', defaultCountryCode: '+1'), '+14155552671');
    });

    test('rubbish is rejected', () {
      expect(normalizePhone(''), isNull);
      expect(normalizePhone('   '), isNull);
      expect(normalizePhone('abcdefghij'), isNull);
      expect(normalizePhone('+0123456789'), isNull);
      expect(normalizePhone('12'), isNull);
    });
  });

  test('isValidEmail', () {
    expect(isValidEmail('asha@example.com'), isTrue);
    expect(isValidEmail('  asha.rao+bills@mail.co.in '), isTrue);
    expect(isValidEmail('asha@'), isFalse);
    expect(isValidEmail('asha@example'), isFalse);
    expect(isValidEmail('asha example.com'), isFalse);
    expect(isValidEmail(''), isFalse);
  });

  test('formatPhone groups Indian numbers and leaves others alone', () {
    expect(formatPhone('+919876543210'), '+91 98765 43210');
    expect(formatPhone('+14155552671'), '+14155552671');
  });

  test('initialsOf', () {
    expect(initialsOf('Sumaiya Mansoor'), 'SM');
    expect(initialsOf('asha'), 'A');
    expect(initialsOf('  Mary   Jane  Watson '), 'MW');
    expect(initialsOf(''), '🙂');
    expect(initialsOf(null), '🙂');
  });

  group('AppServices account flow', () {
    late AppServices services;
    late FakeAuthService auth;
    late FakeRemote remote;

    setUp(() {
      auth = FakeAuthService();
      remote = FakeRemote();
      services = buildServices(auth: auth, remote: remote);
    });

    tearDown(() async {
      services.dispose();
      await services.db.close();
    });

    test('cloudAvailable follows whether sign-in is wired up', () {
      expect(services.cloudAvailable, isTrue);
      final offline = buildServices();
      expect(offline.cloudAvailable, isFalse);
      expect(offline.signedIn, isFalse);
      offline.db.close();
    });

    test('a fresh profile is not onboarded; saving the profile finishes onboarding', () async {
      expect((await services.repo.profile()).onboarded, isFalse);
      await services.saveProfile(name: '  Asha Rao ', email: ' asha@example.com ', phone: '+919876543210');
      final p = await services.repo.profile();
      expect(p.onboarded, isTrue);
      expect(p.displayName, 'Asha Rao');
      expect(p.email, 'asha@example.com');
      expect(p.phone, '+919876543210');
    });

    test('an empty email is stored as nothing', () async {
      await services.saveProfile(name: 'Asha', email: '   ');
      expect((await services.repo.profile()).email, isNull);
    });

    test('sign-in fills empty profile fields but never overwrites typed ones', () async {
      await services.saveProfile(name: 'Ashu', phone: '+919876543210');
      await mergeUserIntoProfile(
        services.repo,
        const AppUser(uid: 'u', name: 'Asha Rao', email: 'asha@example.com', phone: '+919999999999', photoUrl: 'https://x/y.png'),
      );
      final p = await services.repo.profile();
      expect(p.displayName, 'Ashu');
      expect(p.phone, '+919876543210');
      expect(p.email, 'asha@example.com');
      expect(p.photoUrl, 'https://x/y.png');
    });

    test('merging the same user twice changes nothing the second time', () async {
      const user = AppUser(uid: 'u', name: 'Asha');
      await mergeUserIntoProfile(services.repo, user);
      await services.sync!.run();
      expect((await services.repo.profile()).dirty, isFalse);
      await mergeUserIntoProfile(services.repo, user);
      expect((await services.repo.profile()).dirty, isFalse); // nothing new to upload
    });

    test('completing sign-in uploads what was added before signing in', () async {
      await services.repo.saveItem(title: 'Bike PUC', categoryKey: 'vehicle.puc', dueDate: DateTime.utc(2027, 1, 10));
      final user = await auth.signInWithGoogle();
      await services.completeSignIn(user);
      expect(remote.tables['items']!.values.single['title'], 'Bike PUC');
      expect((await services.repo.profile()).displayName, 'Asha Rao');
      expect(remote.tables['profiles']!.values.single['email'], 'asha@example.com');
    });

    test('the local onboarded flag is never uploaded', () async {
      await services.saveProfile(name: 'Asha');
      await services.completeSignIn(await auth.signInWithGoogle());
      expect(remote.tables['profiles']!.values.single.containsKey('onboarded'), isFalse);
    });

    test('sign out pushes, signs out and clears the phone (back to the welcome screen)', () async {
      await services.saveProfile(name: 'Asha');
      await services.completeSignIn(await auth.signInWithGoogle());
      await services.repo.saveItem(title: 'Rent', categoryKey: 'finance.rent', dueDate: DateTime.utc(2027, 2, 1));

      await services.signOut();
      expect(auth.signOutCalls, 1);
      expect(await services.repo.activeItems(), isEmpty);
      expect((await services.repo.profile()).onboarded, isFalse);
      // The edit made just before signing out reached the cloud.
      expect(remote.tables['items']!.values.map((r) => r['title']), contains('Rent'));
    });

    test('delete account deletes the sign-in and clears the phone', () async {
      await services.completeSignIn(await auth.signInWithGoogle());
      await services.repo.saveItem(title: 'Rent', categoryKey: 'finance.rent');
      await services.deleteAccount();
      expect(auth.deleteCalls, 1);
      expect(await services.repo.activeItems(), isEmpty);
    });

    test('delete account that needs a fresh login keeps the phone data and reports why', () async {
      await services.completeSignIn(await auth.signInWithGoogle());
      await services.repo.saveItem(title: 'Rent', categoryKey: 'finance.rent');
      auth.deleteError = const AuthFailure('requires-recent-login', 'sign in again');
      await expectLater(services.deleteAccount(), throwsA(isA<AuthFailure>()));
      expect(await services.repo.activeItems(), hasLength(1));
    });

    test('signed out: delete account just clears the phone', () async {
      await services.repo.saveItem(title: 'Rent', categoryKey: 'finance.rent');
      await services.deleteAccount();
      expect(auth.deleteCalls, 0);
      expect(await services.repo.activeItems(), isEmpty);
    });
  });
}
