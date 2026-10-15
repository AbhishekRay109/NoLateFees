// Picks PDF/JPG/PNG files, keeps a private copy on the phone, and opens them.
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'item_repository.dart';
import 'local/database.dart';

const maxAttachmentBytes = 10 * 1024 * 1024;

class AttachmentTooLarge implements Exception {}

class AttachmentUnavailable implements Exception {}

class AttachmentService {
  AttachmentService(this.repo);

  final ItemRepository repo;

  Future<Directory> _dir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'attachments'));
    await dir.create(recursive: true);
    return dir;
  }

  static String mimeFor(String fileName) {
    switch (p.extension(fileName).toLowerCase()) {
      case '.pdf':
        return 'application/pdf';
      case '.png':
        return 'image/png';
      default:
        return 'image/jpeg';
    }
  }

  /// Lets the user pick a file and attaches it. Returns false if cancelled.
  Future<bool> pickAndAttach(String itemId) async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (picked.isEmpty || picked.first.path == null) return false;
    final source = File(picked.first.path!);
    final size = await source.length();
    if (size > maxAttachmentBytes) throw AttachmentTooLarge();

    final id = repo.newId();
    final name = picked.first.name;
    final dest = p.join((await _dir()).path, '$id${p.extension(name).toLowerCase()}');
    await source.copy(dest);
    await repo.addAttachment(
        id: id, itemId: itemId, fileName: name, mimeType: mimeFor(name), sizeBytes: size, localPath: dest);
    return true;
  }

  /// Opens the file. Throws [AttachmentUnavailable] if its copy is gone
  /// (for example after restoring a backup on a new phone).
  Future<void> open(Attachment a) async {
    final path = a.localPath;
    if (path == null || !File(path).existsSync()) throw AttachmentUnavailable();
    await OpenFilex.open(path, type: a.mimeType);
  }
}
