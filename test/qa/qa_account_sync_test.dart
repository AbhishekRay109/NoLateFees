// QA sections 2 and 7 (ACC-*, SYN-*): accounts, sign-out/in, deletion and
// cloud sync, including the real Firestore store on an in-memory Firestore.
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nolatefees/app_services.dart';
import 'package:nolatefees/data/auth/auth_service.dart';
import 'package:nolatefees/data/sync/firestore_remote_store.dart';
import 'package:nolatefees/data/sync/sync_service.dart';
import 'package:nolatefees/domain/reminder_engine.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

import '../helpers.dart';

/// A backend that can be switched off to simulate losing the network.
class FlakyRemote extends FakeRemote {
  bool offline = false;

  @override
  Future<List<Map<String, dynamic>>> upsert(String table, List<Map<String, dynamic>> rows) {
    if (offline) throw Exception('network down');
    return super.upsert(table, rows);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSince(String table, int sinceRev, int limit) {
    if (offline) throw Exception('network down');
    return super.fetchSince(table, sinceRev, limit);
  }
}

void main() {
  setUpAll(tzdata.initializeTimeZones);

  final due = DateTime.utc(2030, 6, 15);
  final cleanup = <AppServices>[];

  AppServices phone({FakeRemote? remote, FakeGateway? gateway, FakeAuthService? auth}) {
    final s = buildServices(remote: remote, gateway: gateway, auth: auth);
    cleanup.add(s);
    return s;
  }

  tearDown(() async {
    for (final s in cleanup) {
      s.dispose();
      await s.db.close();
    }
    cleanup.clear();
  });

  group('accounts', () {
    test('ACC-12 reminders made as a guest move into the account on sign-in, nothing replaced', () async {
      final remote = FakeRemote();
      // The account already has data from another phone.
      final other = phone(remote: remote);
      await other.repo.saveItem(title: 'From other phone', categoryKey: 'finance.rent', dueDate: due);
      await other.sync!.run();

      final auth = FakeAuthService();
      final guest = phone(remote: remote, auth: auth);
      await guest.saveProfile(name: 'Asha');
      await guest.repo.saveItem(title: 'Guest item', categoryKey: 'vehicle.puc', dueDate: due);
      await guest.completeSignIn(await auth.signInWithGoogle());

      expect((await guest.repo.activeItems()).map((i) => i.title).toSet(), {'Guest item', 'From other phone'});
      expect(remote.tables['items']!.values.map((r) => r['title']).toSet(), {'Guest item', 'From other phone'});
      expect((await guest.repo.profile()).displayName, 'Asha', reason: 'typed name wins over Google name');
    });

    test('ACC-14 sign-out clears data and alerts from this phone, the cloud keeps it', () async {
      final remote = FakeRemote();
      final gateway = FakeGateway();
      final auth = FakeAuthService();
      final s = phone(remote: remote, gateway: gateway, auth: auth);
      await s.completeSignIn(await auth.signInWithGoogle());
      await s.repo.saveItem(title: 'Insurance', categoryKey: 'vehicle.insurance', dueDate: due);
      expect(gateway.booked, isNotEmpty);

      await s.signOut();
      expect(gateway.booked, isEmpty, reason: 'no reminders fire for a signed-out account');
      expect(await s.repo.watchItems(includeArchived: true).first, isEmpty);
      expect(await s.db.select(s.db.scheduledNotifications).get(), isEmpty);
      final p = await s.repo.profile();
      expect((p.onboarded, p.displayName, p.email), (false, null, null));
      expect(remote.tables['items']!.values.single['title'], 'Insurance');
    });

    test('ACC-15 signing back in brings the data and the alerts back', () async {
      final remote = FakeRemote();
      final gateway = FakeGateway();
      final auth = FakeAuthService();
      final s = phone(remote: remote, gateway: gateway, auth: auth);
      await s.completeSignIn(await auth.signInWithGoogle());
      final id = await s.repo.saveItem(title: 'Passport', categoryKey: 'documents.passport', dueDate: due);
      await s.repo.renew(id, newDue: DateTime.utc(2040, 6, 15));
      final booked = gateway.booked.length;
      await s.signOut();

      await s.completeSignIn(await auth.signInWithGoogle());
      final item = (await s.repo.getItem(id))!;
      expect(item.dueDate, DateTime.utc(2040, 6, 15));
      expect(await s.repo.watchRenewals(id).first, hasLength(1));
      expect(gateway.booked, hasLength(booked));
      expect((await s.repo.profile()).displayName, 'Asha Rao');
    });

    test('ACC-13 profile edits sync to the other phone', () async {
      final remote = FakeRemote();
      final a = phone(remote: remote);
      final b = phone(remote: remote);
      await a.saveProfile(name: 'Asha', email: 'asha@example.com', phone: '+919876543210');
      await a.sync!.run();
      await b.sync!.run();
      final p = await b.repo.profile();
      expect((p.displayName, p.email, p.phone), ('Asha', 'asha@example.com', '+919876543210'));
    });

    test('ACC-16 account deletion removes the cloud data, the sign-in and this phone\'s copy', () async {
      final firestore = FakeFirebaseFirestore();
      String? uid = 'alice';
      final remote = FirestoreRemoteStore(firestore, currentUid: () => uid);
      final auth = FakeAuthService();
      final s = buildServices(remote: remote, auth: auth);
      cleanup.add(s);
      await s.completeSignIn(await auth.signInWithGoogle());
      await s.repo.saveItem(title: 'Rent', categoryKey: 'finance.rent', dueDate: due);
      await s.sync!.run();
      expect((await firestore.collection('users/alice/items').get()).docs, hasLength(1));

      await s.deleteAccount();
      expect(auth.deleteCalls, 1);
      for (final t in ['items', 'profiles', 'renewals', 'family_members', 'categories', 'attachments']) {
        expect((await firestore.collection('users/alice/$t').get()).docs, isEmpty, reason: t);
      }
      expect(await s.repo.activeItems(), isEmpty);
    });

    test('ACC-16 if Google asks for a fresh sign-in, nothing is lost: the cloud copy is restored', () async {
      final firestore = FakeFirebaseFirestore();
      final remote = FirestoreRemoteStore(firestore, currentUid: () => 'alice');
      final auth = FakeAuthService();
      final s = buildServices(remote: remote, auth: auth);
      cleanup.add(s);
      await s.completeSignIn(await auth.signInWithGoogle());
      await s.repo.saveItem(title: 'Rent', categoryKey: 'finance.rent', dueDate: due);
      await s.sync!.run();

      auth.deleteError = const AuthFailure('requires-recent-login', 'Sign in again');
      await expectLater(s.deleteAccount(), throwsA(isA<AuthFailure>()));
      expect(await s.repo.activeItems(), hasLength(1), reason: 'phone keeps its data');
      await s.sync!.run();
      final cloud = await firestore.collection('users/alice/items').get();
      expect(cloud.docs.map((d) => d['title']), ['Rent'], reason: 'the account still has its data');
    });

    test('SYN-13 deleting one account leaves other accounts untouched', () async {
      final firestore = FakeFirebaseFirestore();
      final bobPhone = buildServices(remote: FirestoreRemoteStore(firestore, currentUid: () => 'bob'));
      cleanup.add(bobPhone);
      await bobPhone.repo.saveItem(title: 'Bob item', categoryKey: 'finance.rent', dueDate: due);
      await bobPhone.sync!.run();

      final auth = FakeAuthService();
      final alicePhone = buildServices(remote: FirestoreRemoteStore(firestore, currentUid: () => 'alice'), auth: auth);
      cleanup.add(alicePhone);
      await alicePhone.completeSignIn(await auth.signInWithGoogle());
      await alicePhone.repo.saveItem(title: 'Alice item', categoryKey: 'finance.rent', dueDate: due);
      await alicePhone.sync!.run();
      await alicePhone.deleteAccount();

      expect((await firestore.collection('users/bob/items').get()).docs.single['title'], 'Bob item');
      expect((await bobPhone.repo.activeItems()).single.title, 'Bob item');
    });
  });

  group('sync', () {
    test('SYN-01/02 everything reaches a second phone and its alerts are booked there', () async {
      final remote = FakeRemote();
      final a = phone(remote: remote);
      final gatewayB = FakeGateway();
      final b = phone(remote: remote, gateway: gatewayB);
      await a.saveProfile(name: 'Asha');
      final member = await a.repo.saveFamilyMember(name: 'Papa', relation: 'parent');
      final cat = await a.repo.addCustomCategory('Pets');
      final id = await a.repo.saveItem(title: 'Vet', categoryKey: 'custom:$cat', dueDate: due,
          familyMemberId: member, recurrenceUnit: RecurrenceUnit.year, reminderOffsets: const [7, 0]);
      await a.repo.renew(id, newDue: DateTime.utc(2031, 6, 15));
      await a.sync!.run();
      expect(a.sync!.current.phase, SyncPhase.idle);
      expect(a.sync!.current.lastSynced, isNotNull);

      await b.sync!.run();
      final item = (await b.repo.getItem(id))!;
      expect((item.title, item.categoryKey, item.familyMemberId, item.dueDate),
          ('Vet', 'custom:$cat', member, DateTime.utc(2031, 6, 15)));
      expect((await b.repo.watchFamily().first).single.name, 'Papa');
      expect((await b.repo.watchCustomCategories().first).single.name, 'Pets');
      expect(await b.repo.watchRenewals(id).first, hasLength(1));
      expect((await b.repo.profile()).displayName, 'Asha');
      expect(gatewayB.booked, hasLength(2));
    });

    test('SYN-03 an edit arrives on the other phone without duplicates', () async {
      final remote = FakeRemote();
      final a = phone(remote: remote);
      final b = phone(remote: remote);
      final id = await a.repo.saveItem(title: 'Rent', categoryKey: 'finance.rent', dueDate: due);
      await a.sync!.run();
      await b.sync!.run();
      await a.repo.saveItem(id: id, title: 'Rent (new flat)', categoryKey: 'finance.rent', dueDate: due, amountMinor: 2500000);
      await a.sync!.run();
      await b.sync!.run();
      final items = await b.repo.activeItems();
      expect(items, hasLength(1));
      expect((items.single.title, items.single.amountMinor), ('Rent (new flat)', 2500000));
    });

    test('SYN-04/07 offline changes wait, the error is shown, then everything uploads once', () async {
      final remote = FlakyRemote()..offline = true;
      final a = phone(remote: remote);
      final statuses = <SyncPhase>[];
      a.sync!.status.listen((s) => statuses.add(s.phase));

      final id = await a.repo.saveItem(title: 'Offline 1', categoryKey: 'finance.rent', dueDate: due);
      await a.repo.saveItem(title: 'Offline 2', categoryKey: 'finance.emi', dueDate: due);
      await a.repo.saveItem(id: id, title: 'Offline 1 edited', categoryKey: 'finance.rent', dueDate: due);
      await expectLater(a.sync!.run(), throwsA(anything));
      expect(a.sync!.current.phase, SyncPhase.error);
      expect(a.sync!.current.message, isNotEmpty);
      expect(a.sync!.current.lastSynced, isNull, reason: 'never claims a sync that did not happen');
      expect((await a.repo.activeItems()).every((i) => i.dirty), isTrue);

      remote.offline = false;
      await a.sync!.run();
      expect(a.sync!.current.phase, SyncPhase.idle);
      expect(remote.tables['items']!.values.map((r) => r['title']).toSet(), {'Offline 1 edited', 'Offline 2'});
      expect((await a.repo.activeItems()).every((i) => !i.dirty), isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(statuses, containsAllInOrder([SyncPhase.syncing, SyncPhase.error, SyncPhase.syncing, SyncPhase.idle]));
    });

    test('SYN-05 delete on one phone wins over an offline edit on the other, on both phones', () async {
      final remote = FakeRemote();
      final a = phone(remote: remote);
      final b = phone(remote: remote);
      final id = await a.repo.saveItem(title: 'PUC', categoryKey: 'vehicle.puc', dueDate: due);
      await a.sync!.run();
      await b.sync!.run();
      await b.repo.saveItem(id: id, title: 'PUC edited offline', categoryKey: 'vehicle.puc', dueDate: due);
      await a.repo.deleteItem(id);
      await a.sync!.run();
      await b.sync!.run();
      await a.sync!.run();
      expect(await a.repo.activeItems(), isEmpty);
      expect(await b.repo.activeItems(), isEmpty);
      expect(remote.tables['items']![id]!['deleted_at'], isNotNull);
    });

    test('SYN-08 syncing again and again uploads nothing new and creates no duplicates', () async {
      final remote = FakeRemote();
      final a = phone(remote: remote);
      await a.repo.saveItem(title: 'Rent', categoryKey: 'finance.rent', dueDate: due);
      await a.sync!.run();
      final calls = remote.upsertCalls;
      for (var i = 0; i < 5; i++) {
        await a.sync!.run();
      }
      expect(remote.upsertCalls, calls);
      expect(remote.tables['items'], hasLength(1));
      expect(await a.repo.activeItems(), hasLength(1));
    });

    test('SYN-08 two syncs started together share one run', () async {
      final remote = FakeRemote();
      final a = phone(remote: remote);
      await a.repo.saveItem(title: 'Rent', categoryKey: 'finance.rent', dueDate: due);
      await Future.wait([a.sync!.run(), a.sync!.run(), a.sync!.run()]);
      expect(remote.tables['items'], hasLength(1));
    });

    test('SYN-09 a different account sees none of the first account\'s data', () async {
      final firestore = FakeFirebaseFirestore();
      final alice = buildServices(remote: FirestoreRemoteStore(firestore, currentUid: () => 'alice'));
      final bob = buildServices(remote: FirestoreRemoteStore(firestore, currentUid: () => 'bob'));
      cleanup.addAll([alice, bob]);
      await alice.saveProfile(name: 'Alice', email: 'alice@example.com');
      await alice.repo.saveFamilyMember(name: 'Alice mum');
      await alice.repo.saveItem(title: 'Alice passport', categoryKey: 'documents.passport', dueDate: due);
      await alice.sync!.run();

      await bob.sync!.run();
      expect(await bob.repo.watchItems(includeArchived: true).first, isEmpty);
      expect(await bob.repo.watchFamily().first, isEmpty);
      expect((await bob.repo.profile()).email, isNull);
    });

    test('SYN-12 signing out one phone leaves the cloud and the other phone intact', () async {
      final remote = FakeRemote();
      final authA = FakeAuthService();
      final a = phone(remote: remote, auth: authA);
      final gatewayB = FakeGateway();
      final b = phone(remote: remote, gateway: gatewayB);
      await a.completeSignIn(await authA.signInWithGoogle());
      await a.repo.saveItem(title: 'Shared', categoryKey: 'finance.rent', dueDate: due);
      await a.sync!.run();
      await b.sync!.run();

      await a.signOut();
      await b.sync!.run();
      expect((await b.repo.activeItems()).single.title, 'Shared');
      expect(gatewayB.booked, isNotEmpty);
      expect(remote.tables['items']!.values.single['deleted_at'], isNull);
    });

    test('SYN-14 date-only due dates are identical on every phone', () async {
      final remote = FakeRemote();
      final a = phone(remote: remote);
      final b = phone(remote: remote);
      for (final d in [DateTime.utc(2028, 2, 29), DateTime.utc(2027, 12, 31), DateTime.utc(2027, 1, 1)]) {
        await a.repo.saveItem(title: formatDate(d), categoryKey: 'custom.other', dueDate: d);
      }
      await a.sync!.run();
      await b.sync!.run();
      for (final i in await b.repo.activeItems()) {
        expect(formatDate(i.dueDate!), i.title);
        expect(i.dueDate!.isUtc, isTrue);
      }
      expect(remote.tables['items']!.values.map((r) => r['due_date']).toSet(),
          {'2028-02-29', '2027-12-31', '2027-01-01'});
    });

    test('a failed file upload never blocks reminder sync', () async {
      final remote = _NoStorageRemote();
      final a = phone(remote: remote);
      final id = await a.repo.saveItem(title: 'With file', categoryKey: 'documents.passport', dueDate: due);
      await a.repo.addAttachment(
          id: 'att1', itemId: id, fileName: 'scan.pdf', mimeType: 'application/pdf', sizeBytes: 100, localPath: '/tmp/x.pdf');
      await a.sync!.run();
      expect(remote.tables['items']!.values.single['title'], 'With file');
      expect(remote.tables['attachments'], isNull, reason: 'the row waits until its file is uploaded');
    });
  });
}

class _NoStorageRemote extends FakeRemote {
  @override
  Future<void> uploadFile(String storagePath, String localPath, String mimeType) =>
      Future.error(StateError('Storage not enabled'));
}
