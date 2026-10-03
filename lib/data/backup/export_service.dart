// Export to CSV/JSON and import a JSON backup. The JSON backup is the only
// backup for people who never sign in, so import must round-trip it exactly.
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/categories.dart';
import '../../domain/reminder_engine.dart';
import '../local/database.dart';
import '../sync/sync_service.dart';

const backupFormatVersion = 1;

class ExportService {
  ExportService(this.db);
  final AppDatabase db;

  Future<List<Item>> _items() =>
      (db.select(db.items)..where((i) => i.deletedAt.isNull())..orderBy([(i) => OrderingTerm(expression: i.dueDate)])).get();

  /// Spreadsheet-friendly list of items. No ids, no secrets.
  Future<String> toCsv() async {
    final rows = <List<String>>[
      ['Title', 'Category', 'Due date', 'Repeats', 'Provider', 'Reference', 'Amount', 'Currency', 'Notes'],
      for (final i in await _items())
        [
          i.title,
          categoryName(i.categoryKey),
          i.dueDate == null ? '' : formatDate(i.dueDate!),
          recurrenceLabel(i.recurrenceUnit, i.recurrenceEvery),
          i.provider ?? '',
          i.referenceNo ?? '',
          i.amountMinor == null ? '' : (i.amountMinor! / 100).toStringAsFixed(2),
          i.currency,
          i.notes ?? '',
        ],
    ];
    return rows.map((r) => r.map(_csvCell).join(',')).join('\r\n');
  }

  /// Full backup (items, renewals, family, custom categories, settings).
  /// Attachment files are not included.
  Future<String> toJson() async {
    const uid = 'backup';
    final profile = await db.select(db.profiles).getSingle();
    final renewals = await (db.select(db.renewals)..where((r) => r.deletedAt.isNull())).get();
    final family = await (db.select(db.familyMembers)..where((f) => f.deletedAt.isNull())).get();
    final cats = await (db.select(db.customCategories)..where((c) => c.deletedAt.isNull())).get();
    return const JsonEncoder.withIndent('  ').convert({
      'app': 'NoLateFees',
      'format': backupFormatVersion,
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'profile': profileToJson(profile, uid)..remove('id'),
      'family_members': [for (final f in family) _strip(familyToJson(f, uid))],
      'categories': [for (final c in cats) _strip(categoryToJson(c, uid))],
      'items': [for (final i in await _items()) _strip(itemToJson(i, uid))],
      'renewals': [for (final r in renewals) _strip(renewalToJson(r, uid))],
    });
  }

  /// Restores a backup made by [toJson]. Existing rows with the same id are
  /// replaced; nothing is deleted. Returns the number of items imported.
  Future<int> importJson(String source) async {
    final data = jsonDecode(source) as Map<String, dynamic>;
    // Backups made before the rename say 'DueMate'; both are accepted.
    if (!const ['NoLateFees', 'DueMate'].contains(data['app']) || data['format'] != backupFormatVersion) {
      throw const FormatException('This file is not a NoLateFees backup.');
    }
    final now = DateTime.now().toUtc().toIso8601String();
    Map<String, dynamic> prep(Object? row) =>
        {...(row as Map<String, dynamic>), 'rev': 0, 'updated_at': now, 'created_at': row['created_at'] ?? now};

    final items = (data['items'] as List?) ?? const [];
    await db.transaction(() async {
      for (final f in (data['family_members'] as List?) ?? const []) {
        await db.into(db.familyMembers).insertOnConflictUpdate(
            familyFromJson(prep(f)).copyWith(dirty: const Value(true)));
      }
      for (final c in (data['categories'] as List?) ?? const []) {
        await db.into(db.customCategories).insertOnConflictUpdate(
            categoryFromJson(prep(c)).copyWith(dirty: const Value(true)));
      }
      for (final i in items) {
        await db.into(db.items).insertOnConflictUpdate(itemFromJson(prep(i)).copyWith(dirty: const Value(true)));
      }
      for (final r in (data['renewals'] as List?) ?? const []) {
        await db.into(db.renewals).insertOnConflictUpdate(
            renewalFromJson(prep(r)).copyWith(dirty: const Value(true)));
      }
      final p = data['profile'];
      if (p is Map<String, dynamic>) {
        await (db.update(db.profiles)..where((x) => x.id.equals('me')))
            .write(profileFromJson({...p, 'rev': 0}).copyWith(dirty: const Value(true)));
      }
    });
    return items.length;
  }

  static Map<String, dynamic> _strip(Map<String, dynamic> m) => m..remove('user_id');

  static String _csvCell(String v) =>
      (v.contains(',') || v.contains('"') || v.contains('\n')) ? '"${v.replaceAll('"', '""')}"' : v;
}

String recurrenceLabel(RecurrenceUnit unit, int every) {
  if (unit == RecurrenceUnit.none) return "Doesn't repeat";
  if (every == 1) {
    return switch (unit) {
      RecurrenceUnit.day => 'Every day',
      RecurrenceUnit.week => 'Every week',
      RecurrenceUnit.month => 'Every month',
      RecurrenceUnit.year => 'Every year',
      RecurrenceUnit.none => "Doesn't repeat",
    };
  }
  if (unit == RecurrenceUnit.month && every == 3) return 'Every 3 months';
  if (unit == RecurrenceUnit.month && every == 6) return 'Every 6 months';
  return 'Every $every ${unit.name}s';
}
