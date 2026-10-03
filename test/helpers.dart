import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' show ValueListenable, ValueNotifier;
import 'package:flutter/widgets.dart' show Key, Size, SizedBox, Widget;
import 'package:flutter_test/flutter_test.dart';
import 'package:nolatefees/app_services.dart';
import 'package:nolatefees/data/ads/ads_service.dart';
import 'package:nolatefees/data/attachment_service.dart';
import 'package:nolatefees/data/auth/auth_service.dart';
import 'package:nolatefees/data/backup/export_service.dart';
import 'package:nolatefees/data/item_repository.dart';
import 'package:nolatefees/data/local/database.dart';
import 'package:nolatefees/data/notifications/notification_scheduler.dart';
import 'package:nolatefees/data/sync/sync_service.dart';
import 'package:timezone/timezone.dart' as tz;

AppDatabase memoryDb() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
}

class FakeGateway implements NotificationGateway {
  final booked = <int, ({String body, tz.TZDateTime at, String payload})>{};
  int cancels = 0;

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
      booked[id] = (body: body, at: at, payload: payload);

  @override
  Future<void> cancel(int id) async {
    cancels++;
    booked.remove(id);
  }

  @override
  Future<void> cancelAll() async => booked.clear();
}

/// An in-memory backend: assigns `rev` from one sequence, sets updated_at,
/// and refuses to clear deleted_at, like FirestoreRemoteStore.
class FakeRemote implements RemoteStore {
  FakeRemote({this.userId = 'user-1'});

  @override
  String? userId;
  final tables = <String, Map<String, Map<String, dynamic>>>{};
  final files = <String, String>{};
  int _rev = 0;
  int upsertCalls = 0;

  @override
  Future<List<Map<String, dynamic>>> upsert(String table, List<Map<String, dynamic>> rows) async {
    upsertCalls++;
    final t = tables.putIfAbsent(table, () => {});
    final out = <Map<String, dynamic>>[];
    for (final r in rows) {
      final id = r['id'] as String;
      final old = t[id];
      final next = {...?old, ...r};
      if (old != null && old['deleted_at'] != null && r['deleted_at'] == null) {
        next['deleted_at'] = old['deleted_at'];
      }
      next['rev'] = ++_rev;
      next['updated_at'] = DateTime.now().toUtc().toIso8601String();
      next['created_at'] ??= next['updated_at'];
      t[id] = next;
      out.add({'id': id, 'rev': next['rev']});
    }
    return out;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSince(String table, int sinceRev, int limit) async {
    final rows = (tables[table]?.values ?? const <Map<String, dynamic>>[])
        .where((r) => (r['rev'] as int) > sinceRev)
        .toList()
      ..sort((a, b) => (a['rev'] as int).compareTo(b['rev'] as int));
    return rows.take(limit).map((r) => {...r}).toList();
  }

  @override
  Future<void> uploadFile(String storagePath, String localPath, String mimeType) async =>
      files[storagePath] = localPath;

  @override
  Future<void> downloadFile(String storagePath, String localPath) async {}

  /// Simulates another phone editing a row on the server.
  void serverEdit(String table, String id, Map<String, dynamic> changes) {
    final row = tables[table]![id]!;
    row.addAll(changes);
    row['rev'] = ++_rev;
    row['updated_at'] = DateTime.now().toUtc().toIso8601String();
  }
}

/// Scripted sign-in for widget and service tests.
class FakeAuthService implements AuthService {
  FakeAuthService({this.googleAvailable = true});

  @override
  bool googleAvailable;

  final _changes = StreamController<AppUser?>.broadcast();
  AppUser? _user;

  /// What the next call returns, or throws when it is an Exception.
  Object googleResult = const AppUser(uid: 'g-1', name: 'Asha Rao', email: 'asha@example.com', photoUrl: null);
  Object sendCodeResult = const CodeSent('verif-1', resendToken: 7);
  String validCode = '123456';
  final sentTo = <String>[];
  final resendTokens = <int?>[];
  int signOutCalls = 0;
  int deleteCalls = 0;
  AuthFailure? deleteError;

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser?> userChanges() => _changes.stream;

  void _set(AppUser? u) {
    _user = u;
    _changes.add(u);
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    final r = googleResult;
    if (r is Exception) throw r;
    _set(r as AppUser);
    return r;
  }

  @override
  Future<PhoneVerification> sendPhoneCode(String phoneE164, {int? resendToken}) async {
    sentTo.add(phoneE164);
    resendTokens.add(resendToken);
    final r = sendCodeResult;
    if (r is Exception) throw r;
    if (r is AutoVerified) _set(r.user);
    return r as PhoneVerification;
  }

  @override
  Future<AppUser> confirmPhoneCode(String verificationId, String smsCode) async {
    if (smsCode != validCode) {
      throw const AuthFailure('invalid-verification-code', 'That code didn\'t work. Check it and try again.');
    }
    final user = AppUser(uid: 'p-1', phone: sentTo.isEmpty ? null : sentTo.last);
    _set(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    _set(null);
  }

  @override
  Future<void> deleteAccount() async {
    deleteCalls++;
    if (deleteError != null) throw deleteError!;
  }
}

/// AppServices on an in-memory database, with optional fake cloud pieces.
AppServices buildServices({
  AppDatabase? db,
  NotificationGateway? gateway,
  AuthService? auth,
  RemoteStore? remote,
  AdsService? ads,
}) {
  final database = db ?? memoryDb();
  final repo = ItemRepository(database);
  final scheduler = NotificationScheduler(database, gateway ?? FakeGateway(),
      location: tz.getLocation('Asia/Kolkata'), limit: 60);
  return AppServices(
    db: database,
    repo: repo,
    scheduler: scheduler,
    export: ExportService(database),
    attachments: AttachmentService(repo, remote: remote),
    auth: auth,
    remote: remote,
    ads: ads,
    sync: remote == null ? null : SyncService(database, remote, onPulledChanges: scheduler.reconcile),
  );
}

/// Marks onboarding done so the app opens on the home screen.
Future<void> markOnboarded(AppServices s, {String name = 'Asha'}) => s.saveProfile(name: name);

/// A Pixel-8-sized test surface (412 x 915 logical pixels).
void usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
}

/// Lets real database work started by a tap finish, then settles the UI.
/// Don't await database writes inside tester.runAsync once the app is
/// pumped: a stream query waiting on the fake clock can hold drift's lock,
/// and the write then waits forever. Trigger writes through the UI instead.
Future<void> settleDb(WidgetTester tester, {int rounds = 5}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump(const Duration(milliseconds: 50));
  }
  await tester.pumpAndSettle();
}

/// Stands in for AdMob: a 50px placeholder instead of a real banner.
class FakeAdsService implements AdsService {
  FakeAdsService({bool ready = true}) : _ready = ValueNotifier(ready);

  final ValueNotifier<bool> _ready;
  int starts = 0;

  @override
  ValueListenable<bool> get ready => _ready;

  set isReady(bool v) => _ready.value = v;

  @override
  Future<void> start() async => starts++;

  @override
  Widget buildBanner(double width) => SizedBox(key: const Key('fakeBanner'), width: width, height: 50);
}
