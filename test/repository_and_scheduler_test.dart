import 'package:drift/drift.dart' show Value;
import 'package:nolatefees/data/item_repository.dart';
import 'package:nolatefees/data/local/database.dart';
import 'package:nolatefees/data/notifications/notification_scheduler.dart';
import 'package:nolatefees/domain/reminder_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'helpers.dart';

void main() {
  late AppDatabase db;
  late FakeGateway gateway;
  late NotificationScheduler scheduler;
  late ItemRepository repo;
  final now = DateTime.utc(2026, 10, 1, 6); // 1 Oct 2026, 11:30 IST

  setUpAll(tzdata.initializeTimeZones);

  setUp(() {
    db = memoryDb();
    gateway = FakeGateway();
    scheduler = NotificationScheduler(db, gateway,
        location: tz.getLocation('Asia/Kolkata'), limit: 60, clock: () => now);
    repo = ItemRepository(db, clock: () => now, onChanged: scheduler.reconcile);
  });

  tearDown(() => db.close());

  Future<String> addCar({DateTime? due}) => repo.saveItem(
        title: 'Car Insurance',
        categoryKey: 'vehicle.insurance',
        dueDate: due ?? DateTime.utc(2026, 11, 30),
        recurrenceUnit: RecurrenceUnit.year,
        amountMinor: 1245000,
      );

  test('saving an item books its 7 default notifications', () async {
    final id = await addCar();
    expect(gateway.booked.length, 7);
    expect(gateway.booked.values.every((b) => b.payload == id), isTrue);
    expect((await db.select(db.scheduledNotifications).get()).length, 7);
    final item = (await repo.getItem(id))!;
    expect(item.dueDate, DateTime.utc(2026, 11, 30));
  });

  test('editing the date re-books, deleting cancels everything', () async {
    final id = await addCar();
    await repo.saveItem(id: id, title: 'Car Insurance', categoryKey: 'vehicle.insurance', dueDate: DateTime.utc(2026, 12, 15));
    expect(gateway.booked.length, 7);
    expect(gateway.booked.values.map((b) => formatDate(b.at)), contains('2026-12-15'));
    expect(gateway.booked.values.map((b) => formatDate(b.at)), isNot(contains('2026-11-30')));

    await repo.deleteItem(id);
    expect(gateway.booked, isEmpty);
    expect(await db.select(db.scheduledNotifications).get(), isEmpty);
    final tomb = (await repo.getItem(id))!;
    expect(tomb.deletedAt, isNotNull); // soft delete
  });

  test('reconcile is idempotent', () async {
    await addCar();
    final cancelsBefore = gateway.cancels;
    final booked = Map.of(gateway.booked);
    await scheduler.reconcile();
    await scheduler.reconcile();
    expect(gateway.booked, booked);
    expect(gateway.cancels, cancelsBefore);
  });

  test('renewal moves the due date, keeps history and re-books', () async {
    final id = await addCar();
    final item = (await repo.getItem(id))!;
    final next = nextDueDate(item.dueDate!, item.recurrenceUnit, item.recurrenceEvery);
    await repo.renew(id, newDue: next, amountMinor: 1300000, notes: 'Same insurer');

    final renewed = (await repo.getItem(id))!;
    expect(renewed.dueDate, DateTime.utc(2027, 11, 30));
    expect(renewed.startDate, DateTime.utc(2026, 11, 30));
    expect(renewed.amountMinor, 1300000);
    final history = await repo.watchRenewals(id).first;
    expect(history.single.previousDue, DateTime.utc(2026, 11, 30));
    expect(history.single.newDue, DateTime.utc(2027, 11, 30));
    expect(history.single.amountMinor, 1300000);
    expect(gateway.booked.values.map((b) => formatDate(b.at)).toSet(),
        containsAll(['2027-10-31', '2027-11-29', '2027-11-30']));
    expect(gateway.booked.values.any((b) => b.at.year == 2026), isFalse);
  });

  test('snooze adds an alert one day later and skips earlier ones', () async {
    final id = await addCar(due: DateTime.utc(2026, 10, 3)); // alerts: 2 Oct, 3 Oct, 4 Oct
    expect(gateway.booked.length, 3);
    await repo.snooze(id, const Duration(days: 1));
    final times = gateway.booked.values.map((b) => b.at.toUtc()).toList()..sort();
    expect(times.first, now.add(const Duration(days: 1)));
    expect(times.length, 3); // snooze (2 Oct 11:30) + 3 Oct + 4 Oct; 2 Oct 09:00 was dropped
  });

  test('archived items and disabled notifications book nothing', () async {
    final id = await addCar();
    await repo.setArchived(id, true);
    expect(gateway.booked, isEmpty);
    await repo.setArchived(id, false);
    expect(gateway.booked.length, 7);
    await repo.updateProfile(const ProfilesCompanion(notificationsEnabled: Value(false)));
    expect(gateway.booked, isEmpty);
  });

  test('profile default schedule applies to items without their own', () async {
    await repo.updateProfile(const ProfilesCompanion(defaultOffsets: Value([7, 1]), defaultNotifyMinutes: Value(20 * 60)));
    await addCar();
    expect(gateway.booked.length, 2);
    expect(gateway.booked.values.every((b) => b.at.hour == 20), isTrue);
  });

  test('caps the number of pending notifications', () async {
    for (var i = 0; i < 20; i++) {
      await repo.saveItem(title: 'Item $i', categoryKey: 'custom.other', dueDate: DateTime.utc(2027, 1, 1 + i));
    }
    expect(gateway.booked.length, 60);
  });

  test('deleting a family member detaches their items', () async {
    final dad = await repo.saveFamilyMember(name: 'Dad', relation: 'parent', emoji: '👴');
    final id = await repo.saveItem(
        title: 'Health Insurance', categoryKey: 'insurance.health', dueDate: DateTime.utc(2027), familyMemberId: dad);
    await repo.deleteFamilyMember(dad);
    expect((await repo.getItem(id))!.familyMemberId, isNull);
    expect(await repo.watchFamily().first, isEmpty);
  });
}
