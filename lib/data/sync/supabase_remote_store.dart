import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'sync_service.dart';

const attachmentsBucket = 'attachments';

class SupabaseRemoteStore implements RemoteStore {
  SupabaseRemoteStore(this.client);

  final SupabaseClient client;

  @override
  String? get userId => client.auth.currentUser?.id;

  @override
  Future<List<Map<String, dynamic>>> upsert(String table, List<Map<String, dynamic>> rows) async {
    if (rows.isEmpty) return const [];
    final res = await client.from(table).upsert(rows).select('id, rev');
    return List<Map<String, dynamic>>.from(res);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSince(String table, int sinceRev, int limit) async {
    final res = await client.from(table).select().gt('rev', sinceRev).order('rev').limit(limit);
    return List<Map<String, dynamic>>.from(res);
  }

  @override
  Future<void> uploadFile(String storagePath, String localPath, String mimeType) async {
    await client.storage.from(attachmentsBucket).upload(storagePath, File(localPath),
        fileOptions: FileOptions(contentType: mimeType, upsert: true));
  }

  @override
  Future<void> downloadFile(String storagePath, String localPath) async {
    final bytes = await client.storage.from(attachmentsBucket).download(storagePath);
    final file = File(localPath);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
  }
}
