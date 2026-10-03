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

  test('a failed file upload keeps the file pending and still syncs everything else', () async {
    final failing = _FailingFiles();
    final sync = SyncService(phoneA, failing);
    final id = await repoA.saveItem(title: 'Car', categoryKey: 'vehicle.insurance', dueDate: DateTime.utc(2027));
    await repoA.addAttachment(
        id: 'att-1', itemId: id, fileName: 'p.pdf', mimeType: 'application/pdf', sizeBytes: 10, localPath: '/tmp/p.pdf');
    await sync.run();

    expect(failing.tables['items']!.keys, [id]);
    expect(failing.tables['attachments'], isNull); // row waits for its file
    final att = (await repoA.watchAttachments(id).first).single;
    expect(att.uploadPending, isTrue);
    expect(att.dirty, isTrue);
  });

  test('a backend that ignores the cursor cannot make pull loop forever', () async {
    final stuck = _StuckCursor();
    await repoA.saveItem(title: 'X', categoryKey: 'custom.other');
    await SyncService(phoneA, stuck).run(); // push, then pull returns the same page forever
    final syncB2 = SyncService(phoneB, stuck);
    await syncB2.run().timeout(const Duration(seconds: 5));
    expect(await repoB.activeItems(), hasLength(1));
    expect(stuck.fetches, lessThan(20));
  });

  test('sync status goes syncing → idle with a last-synced time', () async {
    final phases = <SyncPhase>[];
    final sub = syncA.status.listen((s) => phases.add(s.phase));
    await repoA.saveItem(title: 'X', categoryKey: 'custom.other');
    await syncA.run();
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    expect(phases, contains(SyncPhase.syncing));
    expect(syncA.current.phase, isNot(SyncPhase.error));
    expect(syncA.current.lastSynced, isNotNull);
  });

  test('profile name, email and phone travel between phones', () async {
    await repoA.updateProfile(const ProfilesCompanion(
        displayName: Value('Asha'), email: Value('asha@example.com'), phone: Value('+919876543210')));
    await syncA.run();
    await syncB.run();
    final p = await repoB.profile();
    expect(p.email, 'asha@example.com');
    expect(p.phone, '+919876543210');
    expect(p.onboarded, isFalse); // local only: B still shows its own welcome
  });

  test('time and date helpers round-trip', () {
    expect(minutesToTime(9 * 60), '09:00:00');
    expect(timeToMinutes('18:45:00'), 18 * 60 + 45);
    expect(timeToMinutes(null), isNull);
  });
}

/// Uploads rows fine but every file upload fails (e.g. Storage not enabled).
class _FailingFiles extends FakeRemote {
  @override
  Future<void> uploadFile(String storagePath, String localPath, String mimeType) async =>
      throw StateError('File storage is not configured');
}

/// Returns the same rows whatever the cursor says.
class _StuckCursor extends FakeRemote {
  int fetches = 0;

  @override
  Future<List<Map<String, dynamic>>> fetchSince(String table, int sinceRev, int limit) {
    fetches++;
    return super.fetchSince(table, 0, limit);
  }
}
