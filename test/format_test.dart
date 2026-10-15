import 'package:flutter_test/flutter_test.dart';
import 'package:nolatefees/app_services.dart';
import 'package:nolatefees/core/format.dart';
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

  group('AppServices profile and data', () {
    late AppServices services;

    setUp(() => services = buildServices());
    tearDown(() => services.db.close());

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

    test('erase all data clears reminders, alerts and the profile (back to the welcome screen)', () async {
      final gateway = FakeGateway();
      final s = buildServices(gateway: gateway);
      addTearDown(s.db.close);
      await s.saveProfile(name: 'Asha');
      await s.repo.saveItem(title: 'Rent', categoryKey: 'finance.rent', dueDate: DateTime.now().add(const Duration(days: 40)));
      expect(gateway.booked, isNotEmpty);

      await s.eraseAllData();
      expect(await s.repo.activeItems(), isEmpty);
      expect(gateway.booked, isEmpty);
      final p = await s.repo.profile();
      expect(p.onboarded, isFalse);
      expect(p.displayName, isNull);
    });
  });
}
