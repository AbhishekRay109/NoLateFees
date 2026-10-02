import 'package:duemate/data/backup/export_service.dart';
import 'package:duemate/data/item_repository.dart';
import 'package:duemate/data/local/database.dart';
import 'package:duemate/domain/reminder_engine.dart';
import 'package:duemate/features/dashboard/dashboard_screen.dart';
import 'package:duemate/features/items/all_items_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;
  late ItemRepository repo;

  setUp(() {
    db = memoryDb();
    repo = ItemRepository(db);
  });
  tearDown(() => db.close());

  test('CSV export has a header and escapes commas and quotes', () async {
    await repo.saveItem(
        title: 'Car Insurance', categoryKey: 'vehicle.insurance', dueDate: DateTime.utc(2026, 11, 30),
        recurrenceUnit: RecurrenceUnit.year, amountMinor: 1245000, provider: 'ABC, "Gold" plan');
    final csv = await ExportService(db).toCsv();
    final lines = csv.split('\r\n');
    expect(lines.first, 'Title,Category,Due date,Repeats,Provider,Reference,Amount,Currency,Notes');
    expect(lines[1], 'Car Insurance,Vehicle Insurance,2026-11-30,Every year,"ABC, ""Gold"" plan",,12450.00,INR,');
  });

  test('JSON backup restores into an empty phone', () async {
    final dad = await repo.saveFamilyMember(name: 'Dad', relation: 'parent');
    final id = await repo.saveItem(
        title: 'Health', categoryKey: 'insurance.health', dueDate: DateTime.utc(2027, 3, 1),
        recurrenceUnit: RecurrenceUnit.year, reminderOffsets: [30, 1], familyMemberId: dad);
    await repo.renew(id, newDue: DateTime.utc(2028, 3, 1), amountMinor: 2000000);
    final json = await ExportService(db).toJson();
    expect(json, isNot(contains('user_id')));

    final other = memoryDb();
    addTearDown(other.close);
    final n = await ExportService(other).importJson(json);
    expect(n, 1);
    final otherRepo = ItemRepository(other);
    final item = (await otherRepo.getItem(id))!;
    expect(item.dueDate, DateTime.utc(2028, 3, 1));
    expect(item.reminderOffsets, [30, 1]);
    expect(item.familyMemberId, dad);
    expect(item.dirty, isTrue); // will upload if the user signs in
    expect((await otherRepo.watchRenewals(id).first).single.amountMinor, 2000000);
  });

  test('import rejects other files', () async {
    expect(() => ExportService(db).importJson('{"hello": 1}'), throwsFormatException);
  });

  group('dashboard and list filters', () {
    final today = DateTime.utc(2026, 11, 20);

    Future<List<Item>> seed() async {
      await repo.saveItem(title: 'Overdue PUC', categoryKey: 'vehicle.puc', dueDate: DateTime.utc(2026, 11, 18));
      await repo.saveItem(title: 'Jio Recharge', categoryKey: 'mobile.recharge', dueDate: DateTime.utc(2026, 11, 25), provider: 'Jio');
      await repo.saveItem(title: 'Netflix', categoryKey: 'subscriptions.netflix', dueDate: DateTime.utc(2026, 12, 2));
      await repo.saveItem(title: 'Passport', categoryKey: 'documents.passport', dueDate: DateTime.utc(2027, 5, 21));
      await repo.saveItem(title: 'Gym', categoryKey: 'subscriptions.gym');
      return repo.watchItems().first;
    }

    test('groups into sections in order and counts what needs attention', () async {
      final items = await seed();
      final groups = groupByStatus(items, today);
      expect(groups.keys.toList(), [DueStatus.overdue, DueStatus.next7, DueStatus.next30, DueStatus.upcoming, DueStatus.noDate]);
      expect(needsAttention(items, today), 3);
    });

    test('search, category, status and sort', () async {
      final items = await seed();
      expect(filterItems(items, query: 'jio', today: today).single.title, 'Jio Recharge');
      expect(filterItems(items, categoryParent: 'subscriptions', today: today).map((i) => i.title), ['Netflix', 'Gym']);
      expect(filterItems(items, status: DueStatus.overdue, today: today).single.title, 'Overdue PUC');
      expect(filterItems(items, sort: ItemSort.title, today: today).first.title, 'Gym');
      expect(filterItems(items, today: today).last.title, 'Gym'); // no date sorts last
    });
  });
}
