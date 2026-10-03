import 'package:drift/drift.dart' show Value;
import 'package:nolatefees/data/item_repository.dart';
import 'package:nolatefees/data/local/database.dart';
import 'package:nolatefees/data/sync/sync_service.dart';
import 'package:nolatefees/domain/reminder_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  late FakeRemote remote;
  late AppDatabase phoneA, phoneB;
  late ItemRepository repoA, repoB;
  late SyncService syncA, syncB;

  setUp(() {
    remote = FakeRemote();
    phoneA = memoryDb();
    phoneB = memoryDb();
    repoA = ItemRepository(phoneA);
    repoB = ItemRepository(phoneB);
    syncA = SyncService(phoneA, remote);
    syncB = SyncService(phoneB, remote);
  });

  tearDown(() async {
    await phoneA.close();
    await phoneB.close();
  });

  test('an item created on phone A appears on phone B with its history', () async {
    final id = await repoA.saveItem(
      title: 'Passport',
      categoryKey: 'documents.passport',
      dueDate: DateTime.utc(2030, 5, 1),
      reminderOffsets: [180, 90, 30],
      notifyMinutes: 8 * 60,
      amountMinor: 150000,
      provider: 'MEA',
    );
    await repoA.renew(id, newDue: DateTime.utc(2040, 5, 1), amountMinor: 200000);
    await syncA.run();

    final a = (await repoA.getItem(id))!;
    expect(a.dirty, isFalse);
    expect(a.rev, greaterThan(0));
    expect(remote.tables['items']![id]!['user_id'], 'user-1');
    expect(remote.tables['items']![id]!['due_date'], '2040-05-01');
    expect(remote.tables['items']![id]!['notify_at'], '08:00:00');

    await syncB.run();
    final b = (await repoB.getItem(id))!;
    expect(b.title, 'Passport');
    expect(b.dueDate, DateTime.utc(2040, 5, 1));
    expect(b.reminderOffsets, [180, 90, 30]);
    expect(b.notifyMinutes, 480);
    expect(b.amountMinor, 200000);
    expect(b.recurrenceUnit, RecurrenceUnit.none);
    expect(b.dirty, isFalse);
    final history = await repoB.watchRenewals(id).first;
    expect(history.single.previousDue, DateTime.utc(2030, 5, 1));
  });

  test('pull only fetches what changed since last time', () async {
    await repoA.saveItem(title: 'A', categoryKey: 'custom.other', dueDate: DateTime.utc(2027));
    await syncA.run();
    await syncB.run();
    final calls = remote.upsertCalls;
    await syncB.run(); // nothing dirty, nothing new
    expect(remote.upsertCalls, calls);
    final state = await phoneB.select(phoneB.syncState).get();
    expect(state.firstWhere((s) => s.tableNameKey == 'items').lastRev, greaterThan(0));
  });

  test('delete on one phone wins over a stale edit on the other', () async {
    final id = await repoA.saveItem(title: 'Netflix', categoryKey: 'subscriptions.netflix', dueDate: DateTime.utc(2026, 11, 5));
    await syncA.run();
    await syncB.run();

    await repoA.deleteItem(id);
    await syncA.run();

    await repoB.saveItem(id: id, title: 'Netflix Premium', categoryKey: 'subscriptions.netflix', dueDate: DateTime.utc(2026, 11, 5));
    await syncB.run();

    expect(remote.tables['items']![id]!['deleted_at'], isNotNull);
    expect((await repoB.getItem(id))!.deletedAt, isNotNull);
    expect(await repoB.watchItems().first, isEmpty);
  });

  test('a local unsynced edit is not overwritten by a pull', () async {
    final id = await repoA.saveItem(title: 'Rent', categoryKey: 'finance.rent', dueDate: DateTime.utc(2026, 11, 1));
    await syncA.run();
    await syncB.run();

    remote.serverEdit('items', id, {'title': 'Rent (server)'});
    await repoB.saveItem(id: id, title: 'Rent (phone B)', categoryKey: 'finance.rent', dueDate: DateTime.utc(2026, 11, 1));
    await syncB.pull(); // pull before push: must not clobber the local edit
    expect((await repoB.getItem(id))!.title, 'Rent (phone B)');

    await syncB.run(); // last push wins
    expect(remote.tables['items']![id]!['title'], 'Rent (phone B)');
  });

  test('family members push before items that reference them', () async {
    final mom = await repoA.saveFamilyMember(name: 'Mom', relation: 'parent');
    await repoA.saveItem(title: "Mom's passport", categoryKey: 'documents.passport', dueDate: DateTime.utc(2031), familyMemberId: mom);
    await syncA.run();
    await syncB.run();
    final items = await repoB.watchItems().first;
    expect(items.single.familyMemberId, mom);
    expect((await repoB.watchFamily().first).single.name, 'Mom');
  });

  test('attachments upload the file first, then the row', () async {
    final id = await repoA.saveItem(title: 'Car', categoryKey: 'vehicle.insurance', dueDate: DateTime.utc(2027));
    await repoA.addAttachment(
        id: 'att-1', itemId: id, fileName: 'Policy.PDF', mimeType: 'application/pdf', sizeBytes: 1000, localPath: '/tmp/x.pdf');
    await syncA.run();
    expect(remote.files.keys.single, 'user-1/$id/att-1.pdf');
    expect(remote.tables['attachments']!['att-1']!['storage_path'], 'user-1/$id/att-1.pdf');

    await syncB.run();
    final onB = await repoB.watchAttachments(id).first;
    expect(onB.single.storagePath, '$id/att-1.pdf');
    expect(onB.single.localPath, isNull); // downloaded on first open
    expect(onB.single.uploadPending, isFalse);
  });

  test('settings sync between phones', () async {
    await repoA.updateProfile(const ProfilesCompanion(
        defaultNotifyMinutes: Value(7 * 60 + 30), defaultOffsets: Value([60, 7, 0]), displayName: Value('Sumaiya')));
    await syncA.run();
    await syncB.run();
    final p = await repoB.profile();
    expect(p.defaultNotifyMinutes, 450);
    expect(p.defaultOffsets, [60, 7, 0]);
    expect(p.displayName, 'Sumaiya');
  });

  test('signed out: sync does nothing', () async {
    remote.userId = null;
    await repoA.saveItem(title: 'X', categoryKey: 'custom.other');
    await syncA.run();
    expect(remote.tables, isEmpty);
    expect(syncA.current.phase, SyncPhase.signedOut);
  });

  test('time and date helpers round-trip', () {
    expect(minutesToTime(9 * 60), '09:00:00');
    expect(timeToMinutes('18:45:00'), 18 * 60 + 45);
    expect(timeToMinutes(null), isNull);
  });
}
