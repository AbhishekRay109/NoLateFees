// QA section 4 (NTF-*): what gets booked with Android, when, and with what text.
// The device-only parts (delivery while locked, after reboot, OEM battery
// savers) stay in the manual checklist; everything that decides *what* is
// booked is checked here.
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:nolatefees/data/backup/export_service.dart';
import 'package:nolatefees/data/item_repository.dart';
import 'package:nolatefees/data/local/database.dart';
import 'package:nolatefees/data/notifications/notification_scheduler.dart';
import 'package:nolatefees/domain/reminder_engine.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../helpers.dart';

/// Records everything the scheduler asks Android for, including the flags.
class RecordingGateway implements NotificationGateway {
  final booked = <int, ({String title, String body, tz.TZDateTime at, String payload, bool exact, bool urgent})>{};
  int cancelAllCalls = 0;

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime at,
    required String payload,
    required bool exact,
    required bool urgent,
  }) async =>
      booked[id] = (title: title, body: body, at: at, payload: payload, exact: exact, urgent: urgent);

  @override
  Future<void> cancel(int id) async => booked.remove(id);

  @override
  Future<void> cancelAll() async {
    cancelAllCalls++;
    booked.clear();
  }
}

void main() {
  setUpAll(tzdata.initializeTimeZones);

  late AppDatabase db;
  late RecordingGateway gateway;
  late NotificationScheduler scheduler;
  late ItemRepository repo;
  late DateTime now;
  tz.Location kolkata() => tz.getLocation('Asia/Kolkata');

  NotificationScheduler build({String zone = 'Asia/Kolkata', int limit = 400}) => NotificationScheduler(
      db, gateway, location: tz.getLocation(zone), limit: limit, clock: () => now);

  setUp(() {
    db = memoryDb();
    gateway = RecordingGateway();
    now = DateTime.utc(2027, 3, 1, 3, 30); // 09:00 in Kolkata
    scheduler = build();
    repo = ItemRepository(db, clock: () => now, onChanged: () => scheduler.reconcile());
  });

  tearDown(() => db.close());

  List<String> times() {
    final out = gateway.booked.values.map((b) => '${formatDate(b.at)} ${b.at.hour}:${b.at.minute.toString().padLeft(2, '0')}').toList()
      ..sort();
    return out;
  }

  test('NTF-01/07 each offset fires at the chosen time: before, on and after the due date', () async {
    await repo.saveItem(
        title: 'Bike PUC', categoryKey: 'vehicle.puc', dueDate: DateTime.utc(2027, 3, 20),
        reminderOffsets: const [7, 1, 0, -2], notifyMinutes: 18 * 60 + 30);
    expect(times(), ['2027-03-13 18:30', '2027-03-19 18:30', '2027-03-20 18:30', '2027-03-22 18:30']);
    expect(gateway.booked.values.every((b) => b.at.location.name == 'Asia/Kolkata'), isTrue);
  });

  test('NTF-07 alerts already in the past are never booked', () async {
    // Due in 2 days; the 30/14/7/3 day alerts are already gone.
    await repo.saveItem(title: 'Recharge', categoryKey: 'mobile.recharge', dueDate: DateTime.utc(2027, 3, 3));
    expect(times(), ['2027-03-02 9:00', '2027-03-03 9:00', '2027-03-04 9:00']);
  });

  test("NTF-07 today's alert is skipped once its time has passed", () async {
    now = DateTime.utc(2027, 3, 1, 4, 0); // 09:30 in Kolkata
    await repo.saveItem(title: 'EMI', categoryKey: 'finance.emi', dueDate: DateTime.utc(2027, 3, 1),
        reminderOffsets: const [0, -1]);
    expect(times(), ['2027-03-02 9:00']);
  });

  test('NTF-07 an overdue item keeps nothing booked once all its alerts have passed', () async {
    await repo.saveItem(title: 'Old', categoryKey: 'custom.other', dueDate: DateTime.utc(2027, 1, 1));
    expect(gateway.booked, isEmpty);
  });

  test('NTF-08 every alert carries the item id, so a tap opens that item', () async {
    final a = await repo.saveItem(title: 'A', categoryKey: 'finance.rent', dueDate: DateTime.utc(2027, 4, 1));
    final b = await repo.saveItem(title: 'B', categoryKey: 'finance.emi', dueDate: DateTime.utc(2027, 4, 2));
    final byPayload = <String, int>{};
    for (final x in gateway.booked.values) {
      byPayload[x.payload] = (byPayload[x.payload] ?? 0) + 1;
      expect(x.title, x.payload == a ? 'A' : 'B');
    }
    expect(byPayload.keys.toSet(), {a, b});
  });

  test('NTF-09/10 snooze: alert tomorrow at the same time, earlier ones dropped, renewal clears it', () async {
    final id = await repo.saveItem(title: 'Insurance', categoryKey: 'vehicle.insurance',
        dueDate: DateTime.utc(2027, 3, 1), reminderOffsets: const [0, -1, -3]);
    expect(times(), ['2027-03-02 9:00', '2027-03-04 9:00']);

    now = DateTime.utc(2027, 3, 1, 4, 0); // tapped Snooze at 09:30
    await repo.snooze(id, const Duration(days: 1));
    expect(times(), ['2027-03-02 9:30', '2027-03-04 9:00']);
    final snoozeAlert = gateway.booked.values.firstWhere((b) => b.at.minute == 30);
    expect(snoozeAlert.body, contains('Insurance'));
    expect(snoozeAlert.payload, id);

    await repo.renew(id, newDue: DateTime.utc(2028, 3, 1));
    expect(gateway.booked.values.any((b) => b.at.year == 2027), isFalse);
  });

  test('NTF-11 changing offsets and time replaces the whole schedule', () async {
    final id = await repo.saveItem(title: 'Rent', categoryKey: 'finance.rent', dueDate: DateTime.utc(2027, 3, 10),
        reminderOffsets: const [3, 0]);
    final oldIds = gateway.booked.keys.toSet();
    await repo.saveItem(id: id, title: 'Rent', categoryKey: 'finance.rent', dueDate: DateTime.utc(2027, 3, 10),
        reminderOffsets: const [5, 1], notifyMinutes: 20 * 60);
    expect(times(), ['2027-03-05 20:00', '2027-03-09 20:00']);
    expect(gateway.booked.keys.toSet().intersection(oldIds), isEmpty);
    expect(await db.select(db.scheduledNotifications).get(), hasLength(2));
  });

  test('NTF-11 renaming an item updates the text of already booked alerts', () async {
    final id = await repo.saveItem(title: 'Car', categoryKey: 'vehicle.insurance', dueDate: DateTime.utc(2027, 3, 10),
        reminderOffsets: const [1]);
    await repo.saveItem(id: id, title: 'Scooter', categoryKey: 'vehicle.insurance', dueDate: DateTime.utc(2027, 3, 10),
        reminderOffsets: const [1]);
    expect(gateway.booked.values.single.body, contains('Scooter'));
    expect(gateway.booked.values.single.title, 'Scooter');
  });

  test('NTF-12 deleting an item with an alert minutes away cancels it', () async {
    now = DateTime.utc(2027, 3, 1, 3, 25); // 08:55, alert at 09:00
    final id = await repo.saveItem(title: 'Now', categoryKey: 'custom.other', dueDate: DateTime.utc(2027, 3, 1),
        reminderOffsets: const [0]);
    expect(gateway.booked, hasLength(1));
    await repo.deleteItem(id);
    expect(gateway.booked, isEmpty);
    expect(await db.select(db.scheduledNotifications).get(), isEmpty);
  });

  test('NTF-13 turning notifications off clears everything; on again re-books', () async {
    await repo.saveItem(title: 'A', categoryKey: 'finance.rent', dueDate: DateTime.utc(2027, 4, 1));
    final count = gateway.booked.length;
    await repo.updateProfile(const ProfilesCompanion(notificationsEnabled: Value(false)));
    expect(gateway.booked, isEmpty);
    await repo.saveItem(title: 'B', categoryKey: 'finance.emi', dueDate: DateTime.utc(2027, 4, 2));
    expect(gateway.booked, isEmpty, reason: 'new items stay silent while off');
    await repo.updateProfile(const ProfilesCompanion(notificationsEnabled: Value(true)));
    expect(gateway.booked, hasLength(count * 2));
  });

  test('NTF-04/05 the exact-timing setting is passed to Android, off by default', () async {
    await repo.saveItem(title: 'A', categoryKey: 'finance.rent', dueDate: DateTime.utc(2027, 4, 1));
    expect(gateway.booked.values.every((b) => !b.exact), isTrue);
    await repo.updateProfile(const ProfilesCompanion(exactAlarms: Value(true)));
    await scheduler.clear();
    await scheduler.reconcile();
    expect(gateway.booked.values.every((b) => b.exact), isTrue);
  });

  test('alerts 1 day before or later are marked urgent; earlier ones are not', () async {
    await repo.saveItem(title: 'A', categoryKey: 'finance.rent', dueDate: DateTime.utc(2027, 4, 1),
        reminderOffsets: const [7, 2, 1, 0, -1]);
    final urgentByDay = {for (final b in gateway.booked.values) b.at.day: b.urgent};
    expect(urgentByDay, {25: false, 30: false, 31: true, 1: true, 2: true});
  });

  test('NTF-15 a timezone change keeps the due date and moves alerts to 09:00 local', () async {
    final id = await repo.saveItem(title: 'Visa', categoryKey: 'documents.visa', dueDate: DateTime.utc(2027, 3, 20),
        reminderOffsets: const [0]);
    expect(times(), ['2027-03-20 9:00']);
    scheduler.location = tz.getLocation('America/New_York');
    await scheduler.reconcile();
    final b = gateway.booked.values.single;
    expect((b.at.location.name, formatDate(b.at), b.at.hour), ('America/New_York', '2027-03-20', 9));
    expect((await repo.getItem(id))!.dueDate, DateTime.utc(2027, 3, 20));
  });

  test('NTF-16 alerts stay at 09:00 local across a daylight-saving change', () async {
    scheduler = build(zone: 'Europe/London');
    repo.onChanged = () => scheduler.reconcile();
    // UK clocks go forward on 28 March 2027.
    await repo.saveItem(title: 'TV licence', categoryKey: 'custom.other', dueDate: DateTime.utc(2027, 3, 29),
        reminderOffsets: const [2, 1, 0]);
    final local = gateway.booked.values.map((b) => (b.at.day, b.at.hour)).toSet();
    expect(local, {(27, 9), (28, 9), (29, 9)});
    final utcHours = gateway.booked.values.map((b) => (b.at.day, b.at.toUtc().hour)).toSet();
    expect(utcHours, {(27, 9), (28, 8), (29, 8)});
  });

  test('NTF-17 above the pending limit the nearest alerts win and later ones top up', () async {
    scheduler = build(limit: 20);
    repo.onChanged = () => scheduler.reconcile();
    for (var i = 0; i < 30; i++) {
      await repo.saveItem(title: 'Item $i', categoryKey: 'custom.other',
          dueDate: DateTime.utc(2027, 3, 2).add(Duration(days: i)), reminderOffsets: const [0]);
    }
    expect(gateway.booked, hasLength(20));
    final latest = gateway.booked.values.map((b) => b.at).reduce((a, b) => a.isAfter(b) ? a : b);
    expect(formatDate(latest), '2027-03-21');

    now = DateTime.utc(2027, 3, 12); // ten alerts have fired
    await scheduler.reconcile();
    expect(gateway.booked, hasLength(20));
    expect(gateway.booked.values.every((b) => b.at.isAfter(now)), isTrue);
    final days = gateway.booked.values.map((b) => formatDate(b.at)).toList()..sort();
    expect((days.first, days.last), ('2027-03-12', '2027-03-31'));
  });

  test('NTF-17 a large library reconciles without churn when nothing changed', () async {
    for (var i = 0; i < 150; i++) {
      await db.into(db.items).insert(ItemsCompanion.insert(
          id: 'i$i', title: 'Item $i', categoryKey: 'custom.other', recurrenceUnit: RecurrenceUnit.none,
          dueDate: Value(DateTime.utc(2027, 4, 1).add(Duration(days: i)))));
    }
    await scheduler.reconcile();
    final first = Map.of(gateway.booked);
    expect(first, hasLength(400));
    await scheduler.reconcile();
    expect(gateway.booked.keys, first.keys);
  });

  test('NTF-19 notification text names the item only: no amount, policy number or notes', () async {
    await repo.saveItem(
        title: 'Health cover', categoryKey: 'insurance.health', dueDate: DateTime.utc(2027, 3, 10),
        provider: 'Star Health', referenceNo: 'POL-998877', amountMinor: 2500000, notes: 'PIN 4321');
    expect(gateway.booked, isNotEmpty);
    for (final b in gateway.booked.values) {
      expect(b.body, contains('Health cover'));
      for (final secret in ['POL-998877', '25,000', '25000', 'PIN 4321', 'Star Health']) {
        expect(b.body.contains(secret) || b.title.contains(secret), isFalse, reason: secret);
      }
    }
  });

  test('sign-out style clear() cancels all and forgets what was booked', () async {
    await repo.saveItem(title: 'A', categoryKey: 'finance.rent', dueDate: DateTime.utc(2027, 4, 1));
    await scheduler.clear();
    expect(gateway.cancelAllCalls, 1);
    expect(await db.select(db.scheduledNotifications).get(), isEmpty);
  });

  test('backup restore books alerts for the restored items', () async {
    await repo.saveItem(title: 'Passport', categoryKey: 'documents.passport', dueDate: DateTime.utc(2027, 6, 1));
    final json = await ExportService(db).toJson();

    final db2 = memoryDb();
    addTearDown(db2.close);
    final g2 = RecordingGateway();
    final s2 = NotificationScheduler(db2, g2, location: kolkata(), limit: 400, clock: () => now);
    await ExportService(db2).importJson(json);
    await s2.reconcile();
    expect(g2.booked, hasLength(7));
  });
}
