import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nolatefees/app.dart';
import 'package:nolatefees/app_services.dart';
import 'package:nolatefees/domain/reminder_engine.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

import 'helpers.dart';

void main() {
  setUpAll(tzdata.initializeTimeZones);

  late AppServices services;
  late FakeGateway gateway;

  setUp(() {
    gateway = FakeGateway();
    services = buildServices(gateway: gateway);
  });

  tearDown(() => services.db.close());

  Future<void> pumpApp(WidgetTester tester, {bool onboarded = true}) async {
    usePhoneScreen(tester);
    if (onboarded) await tester.runAsync(() => markOnboarded(services));
    await tester.pumpWidget(ProviderScope(
      overrides: [servicesProvider.overrideWithValue(services)],
      child: const NoLateFeesApp(),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('a fresh install opens on the welcome screen', (tester) async {
    await pumpApp(tester, onboarded: false);
    expect(find.text('Never pay a late fee again.'), findsOneWidget);
    // No Firebase in this build: offline note and a plain "Get started".
    expect(find.textContaining('Firebase is connected'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('Continue with Google'), findsNothing);
  });

  testWidgets('offline onboarding: name, then home screen with a greeting', (tester) async {
    await pumpApp(tester, onboarded: false);
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    // Name is required.
    await tester.tap(find.text('Let\'s go'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter your name'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('nameField')), 'Sumaiya Mansoor');
    await tester.tap(find.text('Let\'s go'));
    await settleDb(tester);

    expect(find.textContaining(', Sumaiya 👋'), findsOneWidget);
    expect(find.text('Add Reminder'), findsOneWidget);
    final p = await tester.runAsync(() => services.repo.profile());
    expect(p!.onboarded, isTrue);
  });

  testWidgets('empty dashboard invites the first reminder', (tester) async {
    await pumpApp(tester);
    expect(find.text('Nothing to track yet'), findsOneWidget);
    expect(find.text('Add Reminder'), findsOneWidget);
  });

  testWidgets('dashboard groups items by urgency', (tester) async {
    final today = dateOnly(DateTime.now());
    await tester.runAsync(() async {
      await services.repo.saveItem(
          title: 'Car Insurance', categoryKey: 'vehicle.insurance', dueDate: today.subtract(const Duration(days: 2)));
      await services.repo.saveItem(
          title: 'Jio Recharge', categoryKey: 'mobile.recharge', dueDate: today.add(const Duration(days: 5)));
      await services.repo.saveItem(
          title: 'Passport', categoryKey: 'documents.passport', dueDate: today.add(const Duration(days: 183)));
    });
    await pumpApp(tester);

    expect(find.text('OVERDUE'), findsOneWidget);
    expect(find.text('NEXT 7 DAYS'), findsOneWidget);
    expect(find.text('UPCOMING'), findsOneWidget);
    expect(find.text('Expired 2 days ago'), findsOneWidget);
    expect(find.text('5 days left'), findsOneWidget);
    expect(find.text('183 days left'), findsOneWidget);
    expect(find.byKey(const Key('statOverdue')), findsOneWidget);
    expect(find.descendant(of: find.byKey(const Key('statRenew')), matching: find.text('2')), findsOneWidget);
    expect(find.descendant(of: find.byKey(const Key('statOverdue')), matching: find.text('1')), findsOneWidget);
    expect(find.descendant(of: find.byKey(const Key('statTotal')), matching: find.text('3')), findsOneWidget);
  });

  testWidgets('add reminder flow saves an item and books notifications', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Add Reminder'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'My Car Insurance');
    await tester.tap(find.text('Pick a date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      await tester.tap(find.text('SAVE'));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();

    final items = await tester.runAsync(() => services.repo.activeItems());
    expect(items!.single.title, 'My Car Insurance');
    expect(items.single.recurrenceUnit, RecurrenceUnit.year);
    expect(gateway.booked, isNotEmpty);
    expect(find.text('My Car Insurance'), findsOneWidget);
  });

  testWidgets('add reminder needs a name', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Add Reminder'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();
    final items = await tester.runAsync(() => services.repo.activeItems());
    expect(items, isEmpty);
    expect(find.text('SAVE'), findsOneWidget); // still on the form
  });

  testWidgets('bottom navigation reaches every tab', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.list_alt_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Offline mode'), findsOneWidget);
    expect(find.text('Asha'), findsOneWidget); // profile card
    expect(find.text('On this phone only'), findsOneWidget);
    expect(find.text('Add Reminder'), findsNothing); // no FAB on Settings
  });
}
