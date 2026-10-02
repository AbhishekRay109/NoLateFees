import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:duemate/data/local/database.dart';
import 'package:duemate/data/notifications/notification_scheduler.dart';
import 'package:duemate/data/sync/sync_service.dart';
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

/// An in-memory Supabase: assigns `rev` from one sequence, sets updated_at,
/// and refuses to clear deleted_at, like the triggers in the migration.
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
