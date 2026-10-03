// Two-way sync between the phone (Drift) and the cloud (Cloud Firestore, see
// firestore_remote_store.dart; any RemoteStore works).
//
//   push: upsert every dirty row, parents first (family before items...)
//   pull: fetch rows where rev > last pulled rev, apply them unless the local
//         copy is still dirty (a local edit wins until it has been pushed)
//
// Conflicts: last push wins per row; deletes win over edits (the store keeps
// deleted_at once set). Renewals are append-only.
import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/reminder_engine.dart';
import '../local/database.dart';

/// The server side, behind an interface so tests can use a fake.
abstract class RemoteStore {
  String? get userId;

  /// Upserts rows and returns them as stored (with the server's `rev`).
  Future<List<Map<String, dynamic>>> upsert(String table, List<Map<String, dynamic>> rows);

  /// Rows with rev > [sinceRev], ordered by rev, at most [limit].
  Future<List<Map<String, dynamic>>> fetchSince(String table, int sinceRev, int limit);

  /// Uploads a file to the private attachments bucket.
  Future<void> uploadFile(String storagePath, String localPath, String mimeType);

  /// Downloads a file from the attachments bucket to [localPath].
  Future<void> downloadFile(String storagePath, String localPath);
}

enum SyncPhase { idle, syncing, error, signedOut }

class SyncStatus {
  const SyncStatus(this.phase, {this.lastSynced, this.message});
  final SyncPhase phase;
  final DateTime? lastSynced;
  final String? message;
}

class SyncService {
  SyncService(this.db, this.remote, {this.onPulledChanges, this.pageSize = 500});

  final AppDatabase db;
  final RemoteStore remote;
  final int pageSize;

  /// Called after a pull changed items (so notifications can be re-booked).
  final Future<void> Function()? onPulledChanges;

  final _status = StreamController<SyncStatus>.broadcast();
  SyncStatus _current = const SyncStatus(SyncPhase.idle);
  Stream<SyncStatus> get status => _status.stream;
  SyncStatus get current => _current;

  Timer? _debounce;
  Future<void>? _running;
  bool _again = false;

  void _emit(SyncStatus s) {
    _current = s;
    _status.add(s);
  }

  /// Runs a sync a few seconds from now; repeated calls collapse into one.
  void schedule({Duration delay = const Duration(seconds: 3)}) {
    _debounce?.cancel();
    _debounce = Timer(delay, () => run().catchError((_) {}));
  }

  /// One full push + pull. Concurrent calls share the running sync.
  Future<void> run() async {
    if (remote.userId == null) {
      _emit(const SyncStatus(SyncPhase.signedOut));
      return;
    }
    if (_running != null) {
      _again = true;
      return _running;
    }
    _running = () async {
      _emit(SyncStatus(SyncPhase.syncing, lastSynced: _current.lastSynced));
      try {
        do {
          _again = false;
          await push();
          await pull();
        } while (_again);
        _emit(SyncStatus(SyncPhase.idle, lastSynced: DateTime.now()));
      } catch (e) {
        _emit(SyncStatus(SyncPhase.error,
            lastSynced: _current.lastSynced, message: 'Sync failed. Will retry.'));
        rethrow;
      } finally {
        _running = null;
      }
    }();
    return _running;
  }

  void dispose() {
    _debounce?.cancel();
    _status.close();
  }

  // ------------------------------------------------------------------ push

  Future<void> push() async {
    final uid = remote.userId!;

    final profile = await (db.select(db.profiles)..where((p) => p.dirty.equals(true))).getSingleOrNull();
    if (profile != null) {
      final out = await remote.upsert('profiles', [profileToJson(profile, uid)]);
      await (db.update(db.profiles)..where((p) => p.id.equals('me'))).write(
          ProfilesCompanion(dirty: const Value(false), rev: Value(_rev(out.first))));
    }

    final family = await (db.select(db.familyMembers)..where((t) => t.dirty.equals(true))).get();
    await _pushRows('family_members', family.map((r) => familyToJson(r, uid)).toList(),
        {for (final r in family) r.id: r.updatedAt},
        (id, v, rev) => (db.update(db.familyMembers)..where((t) => t.id.equals(id) & t.updatedAt.equals(v)))
            .write(FamilyMembersCompanion(dirty: const Value(false), rev: Value(rev))));

    final cats = await (db.select(db.customCategories)..where((t) => t.dirty.equals(true))).get();
    await _pushRows('categories', cats.map((r) => categoryToJson(r, uid)).toList(),
        {for (final r in cats) r.id: r.updatedAt},
        (id, v, rev) => (db.update(db.customCategories)..where((t) => t.id.equals(id) & t.updatedAt.equals(v)))
            .write(CustomCategoriesCompanion(dirty: const Value(false), rev: Value(rev))));

    final items = await (db.select(db.items)..where((t) => t.dirty.equals(true))).get();
    await _pushRows('items', items.map((r) => itemToJson(r, uid)).toList(),
        {for (final r in items) r.id: r.updatedAt},
        (id, v, rev) => (db.update(db.items)..where((t) => t.id.equals(id) & t.updatedAt.equals(v)))
            .write(ItemsCompanion(dirty: const Value(false), rev: Value(rev))));

    final renewals = await (db.select(db.renewals)..where((t) => t.dirty.equals(true))).get();
    await _pushRows('renewals', renewals.map((r) => renewalToJson(r, uid)).toList(),
        {for (final r in renewals) r.id: r.updatedAt},
        (id, v, rev) => (db.update(db.renewals)..where((t) => t.id.equals(id) & t.updatedAt.equals(v)))
            .write(RenewalsCompanion(dirty: const Value(false), rev: Value(rev))));

    // Files first, then their rows, so a row never points at a missing file.
    final pending = await (db.select(db.attachments)
          ..where((a) => a.uploadPending.equals(true) & a.deletedAt.isNull() & a.localPath.isNotNull()))
        .get();
    for (final a in pending) {
      try {
        await remote.uploadFile('$uid/${a.storagePath}', a.localPath!, a.mimeType);
      } catch (_) {
        // File storage unavailable (offline, or not enabled): keep the file on
        // the phone and retry next sync. Never block the rest of the sync.
        continue;
      }
      await (db.update(db.attachments)..where((t) => t.id.equals(a.id)))
          .write(const AttachmentsCompanion(uploadPending: Value(false)));
    }
    final atts = await (db.select(db.attachments)
          ..where((t) => t.dirty.equals(true) & (t.uploadPending.equals(false) | t.deletedAt.isNotNull())))
        .get();
    await _pushRows('attachments', atts.map((r) => attachmentToJson(r, uid)).toList(),
        {for (final r in atts) r.id: r.updatedAt},
        (id, v, rev) => (db.update(db.attachments)..where((t) => t.id.equals(id) & t.updatedAt.equals(v)))
            .write(AttachmentsCompanion(dirty: const Value(false), rev: Value(rev))));
  }

  /// [versions] holds each row's updatedAt as read; a row edited again while
  /// the push was in flight stays dirty and goes out next time.
  Future<void> _pushRows(String table, List<Map<String, dynamic>> rows, Map<String, DateTime> versions,
      Future<int> Function(String id, DateTime version, int rev) markClean) async {
    for (var i = 0; i < rows.length; i += pageSize) {
      final batch = rows.sublist(i, (i + pageSize).clamp(0, rows.length));
      final stored = await remote.upsert(table, batch);
      await db.transaction(() async {
        for (final s in stored) {
          final id = s['id'] as String;
          await markClean(id, versions[id]!, _rev(s));
        }
      });
    }
  }

  // ------------------------------------------------------------------ pull

  Future<void> pull() async {
    var itemsChanged = false;

    await _pullTable('profiles', (row) async {
      final local = await db.select(db.profiles).getSingle();
      if (local.dirty) return;
      await (db.update(db.profiles)..where((p) => p.id.equals('me'))).write(profileFromJson(row));
    });
    await _pullTable('family_members', (row) async {
      if (await _isDirty(db.familyMembers, row['id'])) return;
      await db.into(db.familyMembers).insertOnConflictUpdate(familyFromJson(row));
    });
    await _pullTable('categories', (row) async {
      if (await _isDirty(db.customCategories, row['id'])) return;
      await db.into(db.customCategories).insertOnConflictUpdate(categoryFromJson(row));
    });
    await _pullTable('items', (row) async {
      if (await _isDirty(db.items, row['id'])) return;
      await db.into(db.items).insertOnConflictUpdate(itemFromJson(row));
      itemsChanged = true;
    });
    await _pullTable('renewals', (row) async {
      if (await _isDirty(db.renewals, row['id'])) return;
      await db.into(db.renewals).insertOnConflictUpdate(renewalFromJson(row));
    });
    await _pullTable('attachments', (row) async {
      if (await _isDirty(db.attachments, row['id'])) return;
      // Keep localPath (local only) if we already have the file.
      await db.into(db.attachments).insert(attachmentFromJson(row),
          onConflict: DoUpdate((_) => attachmentFromJson(row)));
    });

    if (itemsChanged) await onPulledChanges?.call();
  }

  Future<void> _pullTable(String table, Future<void> Function(Map<String, dynamic> row) apply) async {
    final state = await (db.select(db.syncState)..where((s) => s.tableNameKey.equals(table)))
        .getSingleOrNull();
    var since = state?.lastRev ?? 0;
    var advanced = true;
    while (true) {
      final rows = await remote.fetchSince(table, since, pageSize);
      if (rows.isEmpty) break;
      await db.transaction(() async {
        for (final row in rows) {
          await apply(row);
        }
        final maxRev = rows.map(_rev).reduce((a, b) => a > b ? a : b);
        advanced = maxRev > since;
        if (advanced) since = maxRev;
        await db.into(db.syncState).insertOnConflictUpdate(
            SyncStateCompanion(tableNameKey: Value(table), lastRev: Value(since)));
      });
      // A store may re-send rows near the cursor (Firestore overlaps by a
      // minute to cover clock skew); stop if the cursor didn't move.
      if (rows.length < pageSize || !advanced) break;
    }
  }

  Future<bool> _isDirty<T extends Table, D>(TableInfo<T, D> table, Object? id) async {
    final row = await (db.selectOnly(table)
          ..addColumns([table.columnsByName['dirty']!])
          ..where((table.columnsByName['id']! as GeneratedColumn<String>).equals(id as String)))
        .getSingleOrNull();
    if (row == null) return false;
    return row.read(table.columnsByName['dirty']! as GeneratedColumn<bool>) ?? false;
  }

  static int _rev(Map<String, dynamic> row) => (row['rev'] as num).toInt();
}

// ==================================================================== mapping
// Local rows <-> Firestore documents. Server column names are snake_case; dates are
// 'yyyy-mm-dd'; times are 'HH:MM:SS'; enums are their names.

String? _date(DateTime? d) => d == null ? null : formatDate(d);
DateTime? _parseDate(Object? s) => s == null ? null : DateTime.parse('${s as String}T00:00:00Z');
String? _ts(DateTime? d) => d?.toUtc().toIso8601String();
DateTime? _parseTs(Object? s) => s == null ? null : DateTime.parse(s as String);

String? minutesToTime(int? m) => m == null
    ? null
    : '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}:00';
int? timeToMinutes(Object? s) {
  if (s == null) return null;
  final parts = (s as String).split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}

List<int>? _intList(Object? v) => v == null ? null : (v as List).map((e) => (e as num).toInt()).toList();

Map<String, dynamic> profileToJson(Profile p, String uid) => {
      'id': uid,
      'display_name': p.displayName,
      'email': p.email,
      'phone': p.phone,
      'photo_url': p.photoUrl,
      'timezone': p.timezone,
      'default_notify_at': minutesToTime(p.defaultNotifyMinutes),
      'default_offsets': p.defaultOffsets,
      'currency': p.currency,
    };

ProfilesCompanion profileFromJson(Map<String, dynamic> j) => ProfilesCompanion(
      displayName: Value(j['display_name'] as String?),
      email: Value(j['email'] as String?),
      phone: Value(j['phone'] as String?),
      photoUrl: Value(j['photo_url'] as String?),
      timezone: Value(j['timezone'] as String),
      defaultNotifyMinutes: Value(timeToMinutes(j['default_notify_at'])!),
      defaultOffsets: Value(_intList(j['default_offsets'])!),
      currency: Value((j['currency'] as String).trim()),
      rev: Value(SyncService._rev(j)),
      dirty: const Value(false),
    );

Map<String, dynamic> familyToJson(FamilyMember f, String uid) => {
      'id': f.id,
      'user_id': uid,
      'name': f.name,
      'relation': f.relation,
      'emoji': f.emoji,
      'sort_order': f.sortOrder,
      'created_at': _ts(f.createdAt),
      'deleted_at': _ts(f.deletedAt),
    };

FamilyMembersCompanion familyFromJson(Map<String, dynamic> j) => FamilyMembersCompanion(
      id: Value(j['id'] as String),
      name: Value(j['name'] as String),
      relation: Value(j['relation'] as String?),
      emoji: Value(j['emoji'] as String?),
      sortOrder: Value((j['sort_order'] as num?)?.toInt() ?? 0),
      createdAt: Value(_parseTs(j['created_at'])!),
      updatedAt: Value(_parseTs(j['updated_at'])!),
      deletedAt: Value(_parseTs(j['deleted_at'])),
      rev: Value(SyncService._rev(j)),
      dirty: const Value(false),
    );

Map<String, dynamic> categoryToJson(CustomCategory c, String uid) => {
      'id': c.id,
      'user_id': uid,
      'parent_key': c.parentKey,
      'name': c.name,
      'icon': c.icon,
      'created_at': _ts(c.createdAt),
      'deleted_at': _ts(c.deletedAt),
    };

CustomCategoriesCompanion categoryFromJson(Map<String, dynamic> j) => CustomCategoriesCompanion(
      id: Value(j['id'] as String),
      parentKey: Value(j['parent_key'] as String?),
      name: Value(j['name'] as String),
      icon: Value(j['icon'] as String?),
      createdAt: Value(_parseTs(j['created_at'])!),
      updatedAt: Value(_parseTs(j['updated_at'])!),
      deletedAt: Value(_parseTs(j['deleted_at'])),
      rev: Value(SyncService._rev(j)),
      dirty: const Value(false),
    );

Map<String, dynamic> itemToJson(Item i, String uid) => {
      'id': i.id,
      'user_id': uid,
      'family_member_id': i.familyMemberId,
      'category_key': i.categoryKey,
      'title': i.title,
      'provider': i.provider,
      'reference_no': i.referenceNo,
      'amount_minor': i.amountMinor,
      'currency': i.currency,
      'start_date': _date(i.startDate),
      'due_date': _date(i.dueDate),
      'recurrence_unit': i.recurrenceUnit.name,
      'recurrence_every': i.recurrenceEvery,
      'reminder_offsets': i.reminderOffsets,
      'notify_at': minutesToTime(i.notifyMinutes),
      'snoozed_until': _ts(i.snoozedUntil),
      'status': i.archived ? 'archived' : 'active',
      'notes': i.notes,
      'extra': jsonDecode(i.extra),
      'created_at': _ts(i.createdAt),
      'deleted_at': _ts(i.deletedAt),
    };

ItemsCompanion itemFromJson(Map<String, dynamic> j) => ItemsCompanion(
      id: Value(j['id'] as String),
      familyMemberId: Value(j['family_member_id'] as String?),
      categoryKey: Value(j['category_key'] as String),
      title: Value(j['title'] as String),
      provider: Value(j['provider'] as String?),
      referenceNo: Value(j['reference_no'] as String?),
      amountMinor: Value((j['amount_minor'] as num?)?.toInt()),
      currency: Value(((j['currency'] as String?) ?? 'INR').trim()),
      startDate: Value(_parseDate(j['start_date'])),
      dueDate: Value(_parseDate(j['due_date'])),
      recurrenceUnit: Value(RecurrenceUnit.values.byName(j['recurrence_unit'] as String)),
      recurrenceEvery: Value((j['recurrence_every'] as num).toInt()),
      reminderOffsets: Value(_intList(j['reminder_offsets'])),
      notifyMinutes: Value(timeToMinutes(j['notify_at'])),
      snoozedUntil: Value(_parseTs(j['snoozed_until'])),
      archived: Value(j['status'] == 'archived'),
      notes: Value(j['notes'] as String?),
      extra: Value(jsonEncode(j['extra'] ?? {})),
      createdAt: Value(_parseTs(j['created_at'])!),
      updatedAt: Value(_parseTs(j['updated_at'])!),
      deletedAt: Value(_parseTs(j['deleted_at'])),
      rev: Value(SyncService._rev(j)),
      dirty: const Value(false),
    );

Map<String, dynamic> renewalToJson(Renewal r, String uid) => {
      'id': r.id,
      'item_id': r.itemId,
      'user_id': uid,
      'previous_due': _date(r.previousDue),
      'new_due': _date(r.newDue),
      'amount_minor': r.amountMinor,
      'provider': r.provider,
      'notes': r.notes,
      'renewed_at': _ts(r.renewedAt),
      'created_at': _ts(r.createdAt),
      'deleted_at': _ts(r.deletedAt),
    };

RenewalsCompanion renewalFromJson(Map<String, dynamic> j) => RenewalsCompanion(
      id: Value(j['id'] as String),
      itemId: Value(j['item_id'] as String),
      previousDue: Value(_parseDate(j['previous_due'])!),
      newDue: Value(_parseDate(j['new_due'])!),
      amountMinor: Value((j['amount_minor'] as num?)?.toInt()),
      provider: Value(j['provider'] as String?),
      notes: Value(j['notes'] as String?),
      renewedAt: Value(_parseTs(j['renewed_at'])!),
      createdAt: Value(_parseTs(j['created_at'])!),
      updatedAt: Value(_parseTs(j['updated_at'])!),
      deletedAt: Value(_parseTs(j['deleted_at'])),
      rev: Value(SyncService._rev(j)),
      dirty: const Value(false),
    );

Map<String, dynamic> attachmentToJson(Attachment a, String uid) => {
      'id': a.id,
      'item_id': a.itemId,
      'user_id': uid,
      'storage_path': '$uid/${a.storagePath}',
      'file_name': a.fileName,
      'mime_type': a.mimeType,
      'size_bytes': a.sizeBytes,
      'created_at': _ts(a.createdAt),
      'deleted_at': _ts(a.deletedAt),
    };

/// Server paths are "{uid}/{itemId}/{file}"; locally we keep "{itemId}/{file}".
AttachmentsCompanion attachmentFromJson(Map<String, dynamic> j) {
  final path = j['storage_path'] as String;
  final slash = path.indexOf('/');
  return AttachmentsCompanion(
    id: Value(j['id'] as String),
    itemId: Value(j['item_id'] as String),
    storagePath: Value(slash < 0 ? path : path.substring(slash + 1)),
    fileName: Value(j['file_name'] as String),
    mimeType: Value(j['mime_type'] as String),
    sizeBytes: Value((j['size_bytes'] as num).toInt()),
    uploadPending: const Value(false),
    createdAt: Value(_parseTs(j['created_at'])!),
    updatedAt: Value(_parseTs(j['updated_at'])!),
    deletedAt: Value(_parseTs(j['deleted_at'])),
    rev: Value(SyncService._rev(j)),
    dirty: const Value(false),
  );
}
