// Cloud Firestore + Firebase Storage as the sync backend.
//
// Layout (one private tree per user, locked down by firebase/firestore.rules):
//   users/{uid}/{table}/{id}      table = profiles | family_members | categories
//                                         | items | renewals | attachments
//   Storage: users/{uid}/attachments/{itemId}/{file}
//
// Rows are stored with the same snake_case fields the sync mapping uses, plus
// `server_updated_at` (a server timestamp). Its milliseconds act as the row's
// `rev`, so "pull rows with rev > cursor" becomes a timestamp range query.
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'sync_service.dart';

/// Server timestamps can commit slightly out of order; re-read this much
/// before the cursor so nothing is skipped. Re-applying a row is harmless.
const pullOverlap = Duration(minutes: 1);

class FirestoreRemoteStore implements RemoteStore {
  FirestoreRemoteStore(this.firestore, {required String? Function() currentUid, this.storage})
      : _uid = currentUid;

  final FirebaseFirestore firestore;
  final FirebaseStorage? storage;
  final String? Function() _uid;

  @override
  String? get userId => _uid();

  CollectionReference<Map<String, dynamic>> _col(String table) =>
      firestore.collection('users').doc(userId).collection(table);

  static int _revOf(Map<String, dynamic> data) {
    final t = data['server_updated_at'];
    return t is Timestamp ? t.millisecondsSinceEpoch : 0;
  }

  static Map<String, dynamic> _toRow(String id, Map<String, dynamic> data) {
    final rev = _revOf(data);
    return {
      ...data..remove('server_updated_at'),
      'id': id,
      'rev': rev,
      'updated_at': DateTime.fromMillisecondsSinceEpoch(rev, isUtc: true).toIso8601String(),
    };
  }

  @override
  Future<List<Map<String, dynamic>>> upsert(String table, List<Map<String, dynamic>> rows) async {
    final col = _col(table);
    final out = <Map<String, dynamic>>[];
    for (final row in rows) {
      final id = row['id'] as String;
      final ref = col.doc(id);
      await firestore.runTransaction((tx) async {
        final existing = await tx.get(ref);
        final data = Map<String, dynamic>.from(row)
          ..remove('id')
          ..remove('user_id')
          ..remove('rev')
          ..remove('updated_at');
        // Deletes win: a stale offline edit can't bring a deleted row back.
        final oldDeleted = existing.data()?['deleted_at'];
        if (oldDeleted != null && data['deleted_at'] == null) data['deleted_at'] = oldDeleted;
        data['server_updated_at'] = FieldValue.serverTimestamp();
        tx.set(ref, data);
      });
      final stored = await ref.get();
      out.add({'id': id, 'rev': _revOf(stored.data() ?? const {})});
    }
    return out;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSince(String table, int sinceRev, int limit) async {
    final from = sinceRev <= 0
        ? Timestamp.fromMillisecondsSinceEpoch(0)
        : Timestamp.fromMillisecondsSinceEpoch(sinceRev - pullOverlap.inMilliseconds);
    final snap = await _col(table)
        .where('server_updated_at', isGreaterThan: from)
        .orderBy('server_updated_at')
        .limit(limit)
        .get();
    return [for (final d in snap.docs) _toRow(d.id, d.data())];
  }

  String _storagePath(String storagePath) {
    // storagePath arrives as "{uid}/{itemId}/{file}".
    final rest = storagePath.substring(storagePath.indexOf('/') + 1);
    return 'users/$userId/attachments/$rest';
  }

  @override
  Future<void> uploadFile(String storagePath, String localPath, String mimeType) async {
    final s = storage;
    if (s == null) throw StateError('File storage is not configured');
    await s.ref(_storagePath(storagePath)).putFile(File(localPath), SettableMetadata(contentType: mimeType));
  }

  @override
  Future<void> downloadFile(String storagePath, String localPath) async {
    final s = storage;
    if (s == null) throw StateError('File storage is not configured');
    final file = File(localPath);
    await file.parent.create(recursive: true);
    await s.ref(_storagePath(storagePath)).writeToFile(file);
  }

  /// Deletes every document and file this user has (used by "Delete account").
  Future<void> deleteAllUserData() async {
    for (final table in const ['attachments', 'renewals', 'items', 'categories', 'family_members', 'profiles']) {
      while (true) {
        final snap = await _col(table).limit(400).get();
        if (snap.docs.isEmpty) break;
        final batch = firestore.batch();
        for (final d in snap.docs) {
          batch.delete(d.reference);
        }
        await batch.commit();
      }
    }
    final s = storage;
    if (s != null) {
      try {
        final root = await s.ref('users/$userId/attachments').listAll();
        for (final folder in root.prefixes) {
          final files = await folder.listAll();
          for (final f in files.items) {
            await f.delete();
          }
        }
      } catch (_) {
        // Storage not enabled or already empty.
      }
    }
  }
}
