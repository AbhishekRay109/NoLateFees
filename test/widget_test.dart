import 'package:duemate/app.dart';
import 'package:duemate/app_services.dart';
import 'package:duemate/data/attachment_service.dart';
import 'package:duemate/data/backup/export_service.dart';
import 'package:duemate/data/item_repository.dart';
import 'package:duemate/data/local/database.dart';
import 'package:duemate/data/notifications/notification_scheduler.dart';
import 'package:duemate/domain/reminder_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'helpers.dart';

void main() {
  setUpAll(tzdata.initializeTimeZones);

  late AppDatabase db;
  late AppServices services;
  late FakeGateway gateway;

  setUp(() {
    db = memoryDb();
    gateway = FakeGateway();
    final repo = ItemRepository(db);
    services = AppServices(
      db: db,
      repo: repo,
      scheduler: NotificationScheduler(db, gateway, location: tz.getLocation('Asia/Kolkata'), limit: 60),
      export: ExportService(db),
      attachments: AttachmentService(repo),
    );
  });

  tearDown(() => db.close());

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [servicesProvider.overrideWithValue(services)],
      child: const DueMateApp(),
    ));
    await tester.pumpAndSettle();
  }

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
    expect(find.text('2'), findsOneWidget); // things to renew in the next 30 days
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
}
