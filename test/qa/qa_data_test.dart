// QA section 6 (DAT-*): offline use, persistence, CSV/JSON export and import.
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nolatefees/app_services.dart';
import 'package:nolatefees/data/local/database.dart';
import 'package:nolatefees/domain/reminder_engine.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

import '../helpers.dart';

void main() {
  setUpAll(tzdata.initializeTimeZones);

  late AppServices services;

  setUp(() => services = buildServices());
  tearDown(() => services.db.close());

  group('DAT-01/02 offline and after a restart', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('nlf_qa'));
    tearDown(() => dir.deleteSync(recursive: true));

    AppDatabase open() {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      return AppDatabase(NativeDatabase(File('${dir.path}/duemate.sqlite')));
    }

    test('everything works with no cloud at all and survives closing the app', () async {
      final first = buildServices(db: open());
      await first.saveProfile(name: 'Asha');
      final member = await first.repo.saveFamilyMember(name: 'Ammi', relation: 'parent');
      final id = await first.repo.saveItem(
          title: 'Scooter insurance', categoryKey: 'vehicle.insurance', dueDate: DateTime.utc(2027, 5, 1),
          recurrenceUnit: RecurrenceUnit.year, familyMemberId: member, amountMinor: 210000);
      final gone = await first.repo.saveItem(title: 'Delete me', categoryKey: 'custom.other');
      final arch = await first.repo.saveItem(title: 'Archive me', categoryKey: 'custom.other');
      await first.repo.renew(id, newDue: DateTime.utc(2028, 5, 1));
      await first.repo.deleteItem(gone);
      await first.repo.setArchived(arch, true);
      await first.db.close();

      final gateway = FakeGateway();
      final second = buildServices(db: open(), gateway: gateway);
      addTearDown(second.db.close);
      final p = await second.repo.profile();
      expect((p.displayName, p.onboarded), ('Asha', true));
      final items = await second.repo.watchItems(includeArchived: true).first;
      expect(items.map((i) => (i.title, i.archived)).toSet(), {('Scooter insurance', false), ('Archive me', true)});
      final item = (await second.repo.getItem(id))!;
      expect((item.dueDate, item.familyMemberId, item.amountMinor), (DateTime.utc(2028, 5, 1), member, 210000));
      expect(await second.repo.watchRenewals(id).first, hasLength(1));

      // Android keeps booked alarms across an app restart; the app remembers
      // them too, so reopening books nothing twice.
      final remembered = await second.db.select(second.db.scheduledNotifications).get();
      expect(remembered.map((r) => r.itemId).toSet(), {id});
      await second.scheduler.reconcile();
      expect(gateway.booked, isEmpty, reason: 'no duplicate alerts after a restart');
    });
  });

  group('DAT-03 CSV export', () {
    test('handles commas, quotes, new lines, Unicode, blanks and amounts', () async {
      await services.repo.saveItem(
          title: 'Mom\'s "Star" policy, family', categoryKey: 'insurance.health', dueDate: DateTime.utc(2027, 1, 5),
          recurrenceUnit: RecurrenceUnit.year, provider: 'स्टार हेल्थ', referenceNo: 'A,B', amountMinor: 1234505,
          notes: 'line one\nline two');
      await services.repo.saveItem(title: 'No date 🚗', categoryKey: 'custom.other');
      final csv = await services.export.toCsv();
      final lines = csv.split('\r\n');

      expect(lines.first, 'Title,Category,Due date,Repeats,Provider,Reference,Amount,Currency,Notes');
      expect(csv, contains('"Mom\'s ""Star"" policy, family",Health Insurance,2027-01-05,Every year,स्टार हेल्थ,"A,B",12345.05,INR,"line one\nline two"'));
      expect(csv, contains('No date 🚗,Anything else,,Doesn\'t repeat,,,,INR,'));
      expect(_parseCsv(csv), hasLength(3), reason: 'a CSV reader sees header + 2 rows');
      for (final row in _parseCsv(csv)) {
        expect(row, hasLength(9));
      }
    });

    test('contains no ids, user ids or internal fields', () async {
      final id = await services.repo.saveItem(title: 'Rent', categoryKey: 'finance.rent');
      final csv = await services.export.toCsv();
      expect(csv, isNot(contains(id)));
      expect(csv.toLowerCase(), isNot(contains('dirty')));
      expect(csv.toLowerCase(), isNot(contains('user_id')));
    });

    test('an empty library exports just the header', () async {
      expect((await services.export.toCsv()).split('\r\n'), hasLength(1));
    });
  });

  group('DAT-04/05 JSON backup and restore', () {
    Future<String> seed() async {
      await services.saveProfile(name: 'Asha', email: 'asha@example.com');
      await services.repo.updateProfile(const ProfilesCompanion(
          defaultOffsets: Value([10, 2]), defaultNotifyMinutes: Value(20 * 60)));
      final cat = await services.repo.addCustomCategory('Pets');
      final member = await services.repo.saveFamilyMember(name: 'Car KA-01', relation: 'vehicle', emoji: '🚗');
      final id = await services.repo.saveItem(
          title: 'Vet', categoryKey: 'custom:$cat', dueDate: DateTime.utc(2027, 2, 1),
          recurrenceUnit: RecurrenceUnit.month, recurrenceEvery: 3, familyMemberId: member,
          reminderOffsets: const [3, 0], notifyMinutes: 7 * 60);
      await services.repo.renew(id, newDue: DateTime.utc(2027, 5, 1), amountMinor: 50000);
      final deleted = await services.repo.saveItem(title: 'Deleted', categoryKey: 'custom.other');
      await services.repo.deleteItem(deleted);
      return services.export.toJson();
    }

    test('is valid JSON with only this person\'s data and no account internals', () async {
      final json = await seed();
      final data = jsonDecode(json) as Map<String, dynamic>;
      expect(data['app'], 'NoLateFees');
      expect(data['format'], 1);
      expect(data.keys, containsAll(['profile', 'family_members', 'categories', 'items', 'renewals']));
      expect((data['items'] as List).map((i) => i['title']), ['Vet'], reason: 'deleted items are left out');
      for (final word in ['user_id', '"dirty"', 'local_path', 'password', 'token', 'onboarded']) {
        expect(json.contains(word), isFalse, reason: word);
      }
    });

    test('restores items, history, family, categories and settings on a clean install', () async {
      final json = await seed();
      final fresh = buildServices();
      addTearDown(fresh.db.close);
      expect(await fresh.export.importJson(json), 1);

      final item = (await fresh.repo.watchItems().first).single;
      expect((item.title, item.recurrenceUnit, item.recurrenceEvery, item.notifyMinutes),
          ('Vet', RecurrenceUnit.month, 3, 7 * 60));
      expect(item.reminderOffsets, [3, 0]);
      expect((await fresh.repo.watchFamily().first).single.name, 'Car KA-01');
      expect((await fresh.repo.watchFamily().first).single.id, item.familyMemberId);
      expect((await fresh.repo.watchCustomCategories().first).single.name, 'Pets');
      expect((await fresh.repo.watchRenewals(item.id).first).single.amountMinor, 50000);
      final p = await fresh.repo.profile();
      expect((p.displayName, p.email, p.defaultNotifyMinutes), ('Asha', 'asha@example.com', 20 * 60));
      expect(p.defaultOffsets, [10, 2]);
    });

    test('importing the same backup twice creates no duplicates', () async {
      final json = await seed();
      final fresh = buildServices();
      addTearDown(fresh.db.close);
      await fresh.export.importJson(json);
      await fresh.export.importJson(json);
      expect(await fresh.repo.activeItems(), hasLength(1));
      expect(await fresh.repo.watchFamily().first, hasLength(1));
      expect(await fresh.repo.watchCustomCategories().first, hasLength(1));
      final id = (await fresh.repo.activeItems()).single.id;
      expect(await fresh.repo.watchRenewals(id).first, hasLength(1));
    });

    test('restoring keeps items that were already on the phone', () async {
      final json = await seed();
      final other = buildServices();
      addTearDown(other.db.close);
      await other.repo.saveItem(title: 'Already here', categoryKey: 'finance.rent');
      await other.export.importJson(json);
      expect((await other.repo.activeItems()).map((i) => i.title).toSet(), {'Already here', 'Vet'});
    });
  });

  group('DAT-06 legacy and broken backups', () {
    test('an old DueMate backup imports', () async {
      await services.repo.saveItem(title: 'Old', categoryKey: 'finance.rent');
      final legacy = (jsonDecode(await services.export.toJson()) as Map<String, dynamic>)..['app'] = 'DueMate';
      final fresh = buildServices();
      addTearDown(fresh.db.close);
      expect(await fresh.export.importJson(jsonEncode(legacy)), 1);
    });

    for (final bad in <String, String>{
      'not JSON': 'hello',
      'a CSV file': 'Title,Category\nRent,Finance',
      'another app': '{"app":"OtherApp","format":1,"items":[]}',
      'a newer format': '{"app":"NoLateFees","format":99,"items":[]}',
      'a JSON list': '[1,2,3]',
    }.entries) {
      test('${bad.key} is refused and existing data is untouched', () async {
        await services.repo.saveItem(title: 'Keep me', categoryKey: 'finance.rent');
        await expectLater(services.export.importJson(bad.value), throwsA(anything));
        expect((await services.repo.activeItems()).single.title, 'Keep me');
      });
    }

    test('a backup that breaks half-way imports nothing (all or nothing)', () async {
      await services.repo.saveItem(title: 'Good', categoryKey: 'finance.rent');
      final data = jsonDecode(await services.export.toJson()) as Map<String, dynamic>;
      final good = Map<String, dynamic>.from((data['items'] as List).single as Map)..['id'] = 'new-good';
      final broken = <String, dynamic>{'id': 'broken'}; // missing title, category...
      data['items'] = [good, broken];

      final fresh = buildServices();
      addTearDown(fresh.db.close);
      await fresh.repo.saveItem(title: 'Existing', categoryKey: 'finance.emi');
      await expectLater(fresh.export.importJson(jsonEncode(data)), throwsA(anything));
      expect((await fresh.repo.activeItems()).map((i) => i.title), ['Existing']);
    });
  });
}

/// A small RFC 4180 reader, to prove the export opens cleanly in a spreadsheet.
List<List<String>> _parseCsv(String s) {
  final rows = <List<String>>[];
  var row = <String>[];
  final cell = StringBuffer();
  var quoted = false;
  for (var i = 0; i < s.length; i++) {
    final c = s[i];
    if (quoted) {
      if (c == '"') {
        if (i + 1 < s.length && s[i + 1] == '"') {
          cell.write('"');
          i++;
        } else {
          quoted = false;
        }
      } else {
        cell.write(c);
      }
    } else if (c == '"') {
      quoted = true;
    } else if (c == ',') {
      row.add(cell.toString());
      cell.clear();
    } else if (c == '\r' && i + 1 < s.length && s[i + 1] == '\n') {
      row.add(cell.toString());
      cell.clear();
      rows.add(row);
      row = <String>[];
      i++;
    } else {
      cell.write(c);
    }
  }
  row.add(cell.toString());
  rows.add(row);
  return rows;
}
