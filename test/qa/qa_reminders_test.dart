// QA section 3 (REM-*): reminder lifecycle, dates, recurrence and dashboard.
// Case ids match docs/PRODUCTION_QA_CHECKLIST.md.
import 'package:flutter_test/flutter_test.dart';
import 'package:nolatefees/app_services.dart';
import 'package:nolatefees/data/backup/export_service.dart';
import 'package:nolatefees/domain/categories.dart';
import 'package:nolatefees/domain/reminder_engine.dart';
import 'package:nolatefees/features/dashboard/dashboard_screen.dart';
import 'package:nolatefees/features/items/all_items_screen.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

import '../helpers.dart';

void main() {
  setUpAll(tzdata.initializeTimeZones);

  late AppServices services;
  late FakeGateway gateway;
  final today = dateOnly(DateTime.now());
  DateTime inDays(int d) => today.add(Duration(days: d));

  setUp(() {
    gateway = FakeGateway();
    services = buildServices(gateway: gateway);
  });

  tearDown(() => services.db.close());

  test('REM-01 every built-in category and type saves with its label and suggested repeat', () async {
    var n = 0;
    for (final c in builtInCategories) {
      for (final s in c.children) {
        final id = await services.repo.saveItem(
          title: 'QA ${s.name}',
          categoryKey: s.key,
          dueDate: inDays(200 + n++),
          recurrenceUnit: suggestedRecurrence(s.key),
        );
        final item = (await services.repo.getItem(id))!;
        expect(item.categoryKey, s.key);
        expect(categoryName(item.categoryKey), s.name);
        expect(categoryEmoji(item.categoryKey), c.emoji);
        expect(item.recurrenceUnit, s.recurrence ?? c.defaultRecurrence, reason: s.key);
        expect(item.reminderOffsets, isNull, reason: 'new items use the default schedule');
      }
    }
    expect(await services.repo.activeItems(), hasLength(n));
    expect(n, greaterThanOrEqualTo(40));
  });

  test('REM-01 sensible defaults: 30/14/7/3/1/0/-1 days at 09:00', () async {
    final p = await services.repo.profile();
    expect(p.defaultOffsets, defaultOffsets);
    expect(p.defaultNotifyMinutes, 9 * 60);
    expect(p.notificationsEnabled, isTrue);
    expect(p.exactAlarms, isFalse, reason: 'exact alarms are opt-in');
  });

  test('REM-02 custom category: saved, shown, filterable and kept after edits', () async {
    final catId = await services.repo.addCustomCategory('  Pet vaccines ');
    final cats = await services.repo.watchCustomCategories().first;
    expect(cats.single.name, 'Pet vaccines');
    final names = {for (final c in cats) c.id: c.name};

    final id = await services.repo.saveItem(title: 'Rabies shot', categoryKey: 'custom:$catId', dueDate: inDays(40));
    final item = (await services.repo.getItem(id))!;
    expect(categoryName(item.categoryKey, names), 'Pet vaccines');
    expect(categoryEmoji(item.categoryKey), '✏️');
    final items = await services.repo.watchItems().first;
    expect(filterItems(items, categoryParent: 'custom', today: today).single.id, id);

    await services.repo.saveItem(id: id, title: 'Rabies booster', categoryKey: 'custom:$catId', dueDate: inDays(41));
    expect((await services.repo.getItem(id))!.categoryKey, 'custom:$catId');
  });

  test('REM-03 titles are trimmed and blank optional fields stored as nothing', () async {
    final id = await services.repo.saveItem(
        title: '  Car insurance  ', categoryKey: 'vehicle.insurance', provider: '   ', referenceNo: '', notes: ' ');
    final item = (await services.repo.getItem(id))!;
    expect(item.title, 'Car insurance');
    expect(item.provider, isNull);
    expect(item.referenceNo, isNull);
    expect(item.notes, isNull);
  });

  test('REM-04 each due date lands in the right dashboard bucket', () async {
    final cases = <String, (DateTime?, DueStatus)>{
      'past': (inDays(-3), DueStatus.overdue),
      'yesterday': (inDays(-1), DueStatus.overdue),
      'today': (today, DueStatus.today),
      'tomorrow': (inDays(1), DueStatus.next7),
      'in 7': (inDays(7), DueStatus.next7),
      'in 8': (inDays(8), DueStatus.next30),
      'in 30': (inDays(30), DueStatus.next30),
      'in 31': (inDays(31), DueStatus.upcoming),
      'in 400': (inDays(400), DueStatus.upcoming),
      'no date': (null, DueStatus.noDate),
    };
    for (final e in cases.entries) {
      await services.repo.saveItem(title: e.key, categoryKey: 'custom.other', dueDate: e.value.$1);
    }
    final groups = groupByStatus(await services.repo.watchItems().first, today);
    for (final e in cases.entries) {
      expect(groups[e.value.$2]!.map((i) => i.title), contains(e.key), reason: e.key);
    }
    expect(groups.keys.toList(), DueStatus.values, reason: 'sections show in urgency order');
  });

  test('REM-05 dashboard counts follow add, edit, archive, renew and delete', () async {
    Future<(int, int, int)> counts() async {
      final items = await services.repo.watchItems().first;
      final overdue = items.where((i) => statusFor(i.dueDate, today) == DueStatus.overdue).length;
      return (needsAttention(items, today), overdue, items.length);
    }

    final a = await services.repo.saveItem(title: 'A', categoryKey: 'finance.rent', dueDate: inDays(-2),
        recurrenceUnit: RecurrenceUnit.month);
    expect(await counts(), (1, 1, 1));
    final b = await services.repo.saveItem(title: 'B', categoryKey: 'finance.emi', dueDate: inDays(100));
    expect(await counts(), (1, 1, 2));
    await services.repo.saveItem(id: b, title: 'B', categoryKey: 'finance.emi', dueDate: inDays(5));
    expect(await counts(), (2, 1, 2));
    await services.repo.setArchived(b, true);
    expect(await counts(), (1, 1, 1));
    await services.repo.renew(a, newDue: inDays(60));
    expect(await counts(), (0, 0, 1));
    await services.repo.deleteItem(a);
    expect(await counts(), (0, 0, 0));
  });

  test('REM-06 every editable field saves and reads back', () async {
    final member = await services.repo.saveFamilyMember(name: 'Papa', relation: 'parent');
    final id = await services.repo.saveItem(title: 'X', categoryKey: 'custom.other');
    await services.repo.saveItem(
      id: id,
      title: 'Health cover',
      categoryKey: 'insurance.health',
      dueDate: DateTime.utc(2027, 3, 15),
      startDate: DateTime.utc(2026, 3, 15),
      recurrenceUnit: RecurrenceUnit.month,
      recurrenceEvery: 6,
      reminderOffsets: const [45, 10, 0],
      notifyMinutes: 18 * 60 + 30,
      provider: 'Star Health',
      referenceNo: 'POL-123/45',
      amountMinor: 1234567,
      notes: 'Family floater\nrenew online',
      familyMemberId: member,
    );
    final i = (await services.repo.getItem(id))!;
    expect(i.title, 'Health cover');
    expect(i.categoryKey, 'insurance.health');
    expect(i.dueDate, DateTime.utc(2027, 3, 15));
    expect(i.startDate, DateTime.utc(2026, 3, 15));
    expect(i.recurrenceUnit, RecurrenceUnit.month);
    expect(i.recurrenceEvery, 6);
    expect(i.reminderOffsets, [45, 10, 0]);
    expect(i.notifyMinutes, 18 * 60 + 30);
    expect(i.provider, 'Star Health');
    expect(i.referenceNo, 'POL-123/45');
    expect(i.amountMinor, 1234567);
    expect(i.notes, 'Family floater\nrenew online');
    expect(i.familyMemberId, member);
  });

  test('REM-06 a date picked late in the evening is stored as that calendar day', () async {
    final id = await services.repo.saveItem(
        title: 'Late pick', categoryKey: 'custom.other', dueDate: DateTime(2027, 6, 10, 23, 59));
    expect((await services.repo.getItem(id))!.dueDate, DateTime.utc(2027, 6, 10));
  });

  test('REM-07 deleting hides the item everywhere and cancels its alerts', () async {
    final keep = await services.repo.saveItem(title: 'Keep', categoryKey: 'finance.rent', dueDate: inDays(20));
    final gone = await services.repo.saveItem(title: 'Gone', categoryKey: 'finance.emi', dueDate: inDays(20));
    await services.repo.deleteItem(gone);
    expect(gateway.booked.values.every((b) => b.payload == keep), isTrue);
    expect(gateway.booked, isNotEmpty);
    expect((await services.repo.watchItems(includeArchived: true).first).map((i) => i.id), [keep]);
    expect(await services.export.toCsv(), isNot(contains('Gone')));
  });

  test('REM-08 archive hides and silences an item; unarchive restores it unchanged', () async {
    final id = await services.repo.saveItem(
        title: 'Old phone warranty', categoryKey: 'home.warranty', dueDate: inDays(50), provider: 'Croma', amountMinor: 999);
    final before = (await services.repo.getItem(id))!;
    final booked = gateway.booked.length;
    expect(booked, greaterThan(0));

    await services.repo.setArchived(id, true);
    expect(await services.repo.watchItems().first, isEmpty);
    expect((await services.repo.watchItems(includeArchived: true).first).single.archived, isTrue);
    final all = await services.repo.watchItems(includeArchived: true).first;
    expect(filterItems(all, today: today), isEmpty);
    expect(filterItems(all, showArchived: true, today: today), hasLength(1));
    expect(gateway.booked, isEmpty);

    await services.repo.setArchived(id, false);
    final after = (await services.repo.getItem(id))!;
    expect(after.archived, isFalse);
    expect((after.title, after.dueDate, after.provider, after.amountMinor),
        (before.title, before.dueDate, before.provider, before.amountMinor));
    expect(gateway.booked, hasLength(booked));
  });

  test('REM-09 renewing a repeating item records history and re-books the next alerts', () async {
    final due = inDays(3);
    final id = await services.repo.saveItem(
        title: 'Netflix', categoryKey: 'subscriptions.netflix', dueDate: due,
        recurrenceUnit: RecurrenceUnit.month, amountMinor: 64900, reminderOffsets: const [1, 0]);
    await services.repo.snooze(id, const Duration(days: 1));
    final next = nextDueDate(due, RecurrenceUnit.month, 1);

    await services.repo.renew(id, newDue: next, amountMinor: 79900, provider: ' Netflix India ');
    final item = (await services.repo.getItem(id))!;
    expect(item.dueDate, next);
    expect(item.startDate, due);
    expect(item.amountMinor, 79900);
    expect(item.provider, 'Netflix India');
    expect(item.snoozedUntil, isNull, reason: 'renewing clears a snooze');

    final history = await services.repo.watchRenewals(id).first;
    expect(history.single.previousDue, due);
    expect(history.single.newDue, next);
    expect(history.single.amountMinor, 79900);

    final keys = gateway.booked.values.map((b) => dateOnly(b.at)).toSet();
    expect(keys, {next.subtract(const Duration(days: 1)), next});
  });

  test('REM-09 renewing an archived item brings it back', () async {
    final id = await services.repo.saveItem(title: 'PUC', categoryKey: 'vehicle.puc', dueDate: inDays(-10));
    await services.repo.setArchived(id, true);
    await services.repo.renew(id, newDue: inDays(170));
    expect((await services.repo.getItem(id))!.archived, isFalse);
  });

  test('REM-09 several renewals keep the full history, newest first', () async {
    final id = await services.repo.saveItem(
        title: 'Rent', categoryKey: 'finance.rent', dueDate: DateTime.utc(2027, 1, 5), recurrenceUnit: RecurrenceUnit.month);
    for (var m = 2; m <= 4; m++) {
      await services.repo.renew(id, newDue: DateTime.utc(2027, m, 5));
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    final history = await services.repo.watchRenewals(id).first;
    expect(history.map((r) => r.newDue.month), [4, 3, 2]);
  });

  test('REM-10 a one-time item does not invent a next date', () {
    final due = DateTime.utc(2027, 8, 1);
    expect(nextDueDate(due, RecurrenceUnit.none, 1), due);
    expect(recurrenceLabel(RecurrenceUnit.none, 1), "Doesn't repeat");
    for (final key in ['vehicle.puc', 'documents.passport', 'insurance.travel', 'home.warranty']) {
      expect(suggestedRecurrence(key), RecurrenceUnit.none, reason: key);
    }
  });

  test('REM-10 renewing an item that had no date starts history from today', () async {
    final id = await services.repo.saveItem(title: 'Gym', categoryKey: 'subscriptions.gym');
    await services.repo.renew(id, newDue: inDays(30));
    final h = (await services.repo.watchRenewals(id).first).single;
    expect(h.previousDue, today);
    expect((await services.repo.getItem(id))!.dueDate, inDays(30));
  });

  group('REM-11 month-end renewals', () {
    DateTime m(int y, int mo, int d) => DateTime.utc(y, mo, d);

    test('29th, 30th and 31st January clamp to the end of February', () {
      for (final day in [29, 30, 31]) {
        expect(addRecurrence(m(2027, 1, day), RecurrenceUnit.month, 1), m(2027, 2, 28), reason: '2027-01-$day');
        expect(addRecurrence(m(2028, 1, day), RecurrenceUnit.month, 1), m(2028, 2, 29), reason: 'leap 2028-01-$day');
      }
    });

    test('30-day months clamp the 31st', () {
      expect(addRecurrence(m(2027, 3, 31), RecurrenceUnit.month, 1), m(2027, 4, 30));
      expect(addRecurrence(m(2027, 5, 31), RecurrenceUnit.month, 1), m(2027, 6, 30));
      expect(addRecurrence(m(2027, 8, 31), RecurrenceUnit.month, 1), m(2027, 9, 30));
      expect(addRecurrence(m(2027, 10, 31), RecurrenceUnit.month, 1), m(2027, 11, 30));
    });

    test('the 28th and earlier never move', () {
      var d = m(2027, 1, 28);
      for (var i = 0; i < 24; i++) {
        d = addRecurrence(d, RecurrenceUnit.month, 1);
        expect(d.day, 28);
      }
    });

    test('December rolls into January of the next year', () {
      expect(addRecurrence(m(2027, 12, 31), RecurrenceUnit.month, 1), m(2028, 1, 31));
      expect(addRecurrence(m(2027, 11, 30), RecurrenceUnit.month, 3), m(2028, 2, 29));
    });
  });

  group('REM-12 yearly renewals', () {
    test('leap day goes to 28 Feb, then 29 Feb again in the next leap year', () {
      expect(addRecurrence(DateTime.utc(2028, 2, 29), RecurrenceUnit.year, 1), DateTime.utc(2029, 2, 28));
      expect(addRecurrence(DateTime.utc(2028, 2, 29), RecurrenceUnit.year, 4), DateTime.utc(2032, 2, 29));
    });

    test('31 December stays 31 December', () {
      expect(addRecurrence(DateTime.utc(2026, 12, 31), RecurrenceUnit.year, 1), DateTime.utc(2027, 12, 31));
    });

    test('renewal history shows the leap-day step correctly', () async {
      final id = await services.repo.saveItem(
          title: 'Passport', categoryKey: 'documents.passport', dueDate: DateTime.utc(2028, 2, 29),
          recurrenceUnit: RecurrenceUnit.year, recurrenceEvery: 10);
      final next = nextDueDate(DateTime.utc(2028, 2, 29), RecurrenceUnit.year, 10);
      expect(next, DateTime.utc(2038, 2, 28));
      await services.repo.renew(id, newDue: next);
      final h = (await services.repo.watchRenewals(id).first).single;
      expect((h.previousDue, h.newDue), (DateTime.utc(2028, 2, 29), DateTime.utc(2038, 2, 28)));
    });
  });

  test('REM-13 every preset and custom interval computes the right next date', () {
    final d = DateTime.utc(2027, 1, 15);
    final cases = <(RecurrenceUnit, int), (DateTime, String)>{
      (RecurrenceUnit.month, 1): (DateTime.utc(2027, 2, 15), 'Every month'),
      (RecurrenceUnit.month, 3): (DateTime.utc(2027, 4, 15), 'Every 3 months'),
      (RecurrenceUnit.month, 6): (DateTime.utc(2027, 7, 15), 'Every 6 months'),
      (RecurrenceUnit.year, 1): (DateTime.utc(2028, 1, 15), 'Every year'),
      (RecurrenceUnit.none, 1): (d, "Doesn't repeat"),
      (RecurrenceUnit.day, 1): (DateTime.utc(2027, 1, 16), 'Every day'),
      (RecurrenceUnit.day, 28): (DateTime.utc(2027, 2, 12), 'Every 28 days'),
      (RecurrenceUnit.week, 1): (DateTime.utc(2027, 1, 22), 'Every week'),
      (RecurrenceUnit.week, 2): (DateTime.utc(2027, 1, 29), 'Every 2 weeks'),
      (RecurrenceUnit.month, 2): (DateTime.utc(2027, 3, 15), 'Every 2 months'),
      (RecurrenceUnit.year, 5): (DateTime.utc(2032, 1, 15), 'Every 5 years'),
    };
    cases.forEach((rule, want) {
      expect(nextDueDate(d, rule.$1, rule.$2), want.$1, reason: '$rule');
      expect(recurrenceLabel(rule.$1, rule.$2), want.$2, reason: '$rule');
    });
  });

  test('REM-13 daily and weekly steps ignore daylight saving (pure dates)', () {
    // 30 March 2025 is the EU clock change; dates must not slip a day.
    expect(addRecurrence(DateTime.utc(2025, 3, 29), RecurrenceUnit.day, 1), DateTime.utc(2025, 3, 30));
    expect(addRecurrence(DateTime.utc(2025, 3, 27), RecurrenceUnit.week, 1), DateTime.utc(2025, 4, 3));
  });

  test('REM-14 renewal history survives backup and restore', () async {
    final id = await services.repo.saveItem(
        title: 'Car insurance', categoryKey: 'vehicle.insurance', dueDate: DateTime.utc(2027, 4, 1),
        recurrenceUnit: RecurrenceUnit.year);
    await services.repo.renew(id, newDue: DateTime.utc(2028, 4, 1), amountMinor: 1500000, notes: 'via agent');
    final restored = buildServices();
    addTearDown(restored.db.close);
    await restored.export.importJson(await services.export.toJson());
    final h = (await restored.repo.watchRenewals(id).first).single;
    expect((h.previousDue, h.newDue, h.amountMinor, h.notes),
        (DateTime.utc(2027, 4, 1), DateTime.utc(2028, 4, 1), 1500000, 'via agent'));
  });

  group('REM-15 countdown wording at every boundary', () {
    final t = DateTime.utc(2027, 1, 10);
    test('labels', () {
      expect(countdownLabel(DateTime.utc(2027, 1, 8), t), 'Expired 2 days ago');
      expect(countdownLabel(DateTime.utc(2027, 1, 9), t), 'Expired yesterday');
      expect(countdownLabel(t, t), 'Due today');
      expect(countdownLabel(DateTime.utc(2027, 1, 11), t), 'Due tomorrow');
      expect(countdownLabel(DateTime.utc(2027, 1, 17), t), '7 days left');
      expect(countdownLabel(DateTime.utc(2027, 2, 9), t), '30 days left');
    });

    test('no off-by-one from the time of day or the local timezone', () {
      expect(daysUntil(DateTime.utc(2027, 1, 11), DateTime(2027, 1, 10, 23, 59)), 1);
      expect(daysUntil(DateTime.utc(2027, 1, 11), DateTime(2027, 1, 10, 0, 1)), 1);
      expect(statusFor(DateTime.utc(2027, 1, 10), DateTime(2027, 1, 10, 23, 59)), DueStatus.today);
    });

    test('across a year end and a leap day', () {
      expect(daysUntil(DateTime.utc(2028, 1, 1), DateTime.utc(2027, 12, 31)), 1);
      expect(daysUntil(DateTime.utc(2028, 3, 1), DateTime.utc(2028, 2, 28)), 2);
    });
  });
}
