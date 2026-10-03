// The real Firestore backend, run against an in-memory Firestore.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' show Value;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nolatefees/data/item_repository.dart';
import 'package:nolatefees/data/local/database.dart';
import 'package:nolatefees/data/sync/firestore_remote_store.dart';
import 'package:nolatefees/data/sync/sync_service.dart';

import 'helpers.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  String? uid;
  late FirestoreRemoteStore remote;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    uid = 'alice';
    remote = FirestoreRemoteStore(firestore, currentUid: () => uid);
  });

  Map<String, dynamic> row(String id, [Map<String, dynamic> extra = const {}]) =>
      {'id': id, 'user_id': uid, 'title': 'Item $id', 'rev': 0, 'updated_at': 'x', 'deleted_at': null, ...extra};

  group('FirestoreRemoteStore', () {
    test('writes under users/{uid}/{table} without client-only fields', () async {
      final out = await remote.upsert('items', [row('a')]);
      expect(out.single['id'], 'a');
      expect(out.single['rev'], greaterThan(0));

      final doc = await firestore.doc('users/alice/items/a').get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['title'], 'Item a');
      expect(doc.data()!.containsKey('user_id'), isFalse);
      expect(doc.data()!.containsKey('rev'), isFalse);
      expect(doc.data()!['server_updated_at'], isA<Timestamp>());
    });

    test('fetchSince returns rows with id, rev and updated_at, oldest first', () async {
      await remote.upsert('items', [row('a')]);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await remote.upsert('items', [row('b')]);
      final rows = await remote.fetchSince('items', 0, 100);
      expect(rows.map((r) => r['id']), ['a', 'b']);
      expect(rows.first['rev'], lessThanOrEqualTo(rows.last['rev'] as int));
      expect(rows.first.containsKey('server_updated_at'), isFalse);
      expect(DateTime.parse(rows.first['updated_at'] as String).isUtc, isTrue);
    });

    test('fetchSince respects the limit', () async {
      for (final id in ['a', 'b', 'c']) {
        await remote.upsert('items', [row(id)]);
      }
      expect(await remote.fetchSince('items', 0, 2), hasLength(2));
    });

    test('fetchSince skips rows older than the cursor minus the overlap', () async {
      await firestore.doc('users/alice/items/old').set({
        'title': 'old',
        'server_updated_at': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
      });
      await remote.upsert('items', [row('new')]);
      final cursor = DateTime.now().subtract(const Duration(minutes: 30)).millisecondsSinceEpoch;
      final rows = await remote.fetchSince('items', cursor, 100);
      expect(rows.map((r) => r['id']), ['new']);
    });

    test('a stale edit cannot undelete a row', () async {
      await remote.upsert('items', [row('a', {'deleted_at': '2026-10-01T00:00:00Z'})]);
      await remote.upsert('items', [row('a', {'title': 'edited offline', 'deleted_at': null})]);
      final doc = await firestore.doc('users/alice/items/a').get();
      expect(doc.data()!['deleted_at'], '2026-10-01T00:00:00Z');
      expect(doc.data()!['title'], 'edited offline');
    });

    test('accounts are separate', () async {
      await remote.upsert('items', [row('a')]);
      uid = 'bob';
      expect(await remote.fetchSince('items', 0, 100), isEmpty);
      expect(remote.userId, 'bob');
    });

    test('deleteAllUserData removes every table for this user only', () async {
      await remote.upsert('items', [row('a'), row('b')]);
      await remote.upsert('renewals', [row('r')]);
      await remote.upsert('profiles', [row('me')]);
      uid = 'bob';
      await remote.upsert('items', [row('z')]);
      uid = 'alice';

      await remote.deleteAllUserData();
      for (final t in ['items', 'renewals', 'profiles']) {
        expect((await firestore.collection('users/alice/$t').get()).docs, isEmpty, reason: t);
      }
      expect((await firestore.collection('users/bob/items').get()).docs, hasLength(1));
    });

    test('file transfer without Storage configured fails clearly', () async {
      expect(() => remote.uploadFile('alice/item/a.pdf', '/tmp/a.pdf', 'application/pdf'), throwsStateError);
      expect(() => remote.downloadFile('alice/item/a.pdf', '/tmp/a.pdf'), throwsStateError);
    });
  });

  group('two phones syncing through Firestore', () {
    late AppDatabase phoneA, phoneB;
    late ItemRepository repoA, repoB;
    late SyncService syncA, syncB;

    setUp(() {
      phoneA = memoryDb();
      phoneB = memoryDb();
      repoA = ItemRepository(phoneA);
      repoB = ItemRepository(phoneB);
      syncA = SyncService(phoneA, remote);
      syncB = SyncService(phoneB, remote);
    });

    tearDown(() async {
      syncA.dispose();
      syncB.dispose();
      await phoneA.close();
      await phoneB.close();
    });

    test('items, renewals, family and profile reach the other phone', () async {
      final dad = await repoA.saveFamilyMember(name: 'Dad', emoji: '👨');
      final id = await repoA.saveItem(
        title: 'Health Insurance',
        categoryKey: 'insurance.health',
        dueDate: DateTime.utc(2027, 3, 31),
        familyMemberId: dad,
        amountMinor: 2450000,
      );
      await repoA.renew(id, newDue: DateTime.utc(2028, 3, 31));
      await repoA.updateProfile(const ProfilesCompanion(displayName: Value('Asha'), phone: Value('+919876543210')));
      await syncA.run();

      expect((await repoA.getItem(id))!.dirty, isFalse);
      expect((await firestore.doc('users/alice/items/$id').get()).data()!['due_date'], '2028-03-31');

      await syncB.run();
      final b = (await repoB.getItem(id))!;
      expect(b.title, 'Health Insurance');
      expect(b.dueDate, DateTime.utc(2028, 3, 31));
      expect(b.familyMemberId, dad);
      expect(b.amountMinor, 2450000);
      expect(await repoB.watchRenewals(id).first, hasLength(1));
      expect((await repoB.watchFamily().first).single.name, 'Dad');
      final profile = await repoB.profile();
      expect(profile.displayName, 'Asha');
      expect(profile.phone, '+919876543210');
    });

    test('an edit on B comes back to A', () async {
      final id = await repoA.saveItem(title: 'Rent', categoryKey: 'finance.rent', dueDate: DateTime.utc(2026, 11, 5));
      await syncA.run();
      await syncB.run();

      await Future<void>.delayed(const Duration(milliseconds: 5));
      await repoB.saveItem(id: id, title: 'House rent', categoryKey: 'finance.rent', dueDate: DateTime.utc(2026, 12, 5));
      await syncB.run();
      await syncA.run();

      final a = (await repoA.getItem(id))!;
      expect(a.title, 'House rent');
      expect(a.dueDate, DateTime.utc(2026, 12, 5));
    });

    test('delete on A beats a stale offline edit on B', () async {
      final id = await repoA.saveItem(title: 'Netflix', categoryKey: 'subscriptions.netflix', dueDate: DateTime.utc(2026, 11, 1));
      await syncA.run();
      await syncB.run();

      await repoA.deleteItem(id);
      await syncA.run();
      await repoB.saveItem(id: id, title: 'Netflix premium', categoryKey: 'subscriptions.netflix', dueDate: DateTime.utc(2026, 11, 1));
      await syncB.run();
      await syncA.run();

      expect((await firestore.doc('users/alice/items/$id').get()).data()!['deleted_at'], isNotNull);
      expect(await repoA.activeItems(), isEmpty);
      expect(await repoB.activeItems(), isEmpty);
    });

    test('running sync again with nothing new changes nothing', () async {
      await repoA.saveItem(title: 'PUC', categoryKey: 'vehicle.puc', dueDate: DateTime.utc(2026, 12, 1));
      await syncA.run();
      await syncA.run();
      expect((await firestore.collection('users/alice/items').get()).docs, hasLength(1));
      expect(await repoA.activeItems(), hasLength(1));
    });

    test('signed out: nothing is uploaded', () async {
      uid = null;
      await repoA.saveItem(title: 'PUC', categoryKey: 'vehicle.puc');
      await syncA.run();
      expect((await repoA.activeItems()).single.dirty, isTrue);
    });
  });
}
