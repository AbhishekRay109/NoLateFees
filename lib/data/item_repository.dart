// All reads and writes the screens do. Every write lands in SQLite, then
// calls [onChanged] so notifications are reconciled. There is no network.
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../domain/reminder_engine.dart';
import 'local/database.dart';

typedef ChangeListener = Future<void> Function();

class ItemRepository {
  ItemRepository(this.db, {ChangeListener? onChanged, DateTime Function()? clock})
      : _onChanged = onChanged, // ignore: prefer_initializing_formals
        _clock = clock ?? DateTime.now;

  final AppDatabase db;
  ChangeListener? _onChanged;
  final DateTime Function() _clock;
  static const _uuid = Uuid();

  set onChanged(ChangeListener? listener) => _onChanged = listener;

  String newId() => _uuid.v7();

  Future<void> _changed() async => _onChanged?.call();

  // ---------------------------------------------------------------- reads

  Stream<List<Item>> watchItems({bool includeArchived = false}) {
    final q = db.select(db.items)
      ..where((i) => i.deletedAt.isNull())
      ..orderBy([
        (i) => OrderingTerm(expression: i.dueDate, nulls: NullsOrder.last),
        (i) => OrderingTerm(expression: i.title),
      ]);
    if (!includeArchived) q.where((i) => i.archived.equals(false));
    return q.watch();
  }

  Future<List<Item>> activeItems() => (db.select(db.items)
        ..where((i) => i.deletedAt.isNull() & i.archived.equals(false)))
      .get();

  Stream<Item?> watchItem(String id) =>
      (db.select(db.items)..where((i) => i.id.equals(id))).watchSingleOrNull();

  Future<Item?> getItem(String id) =>
      (db.select(db.items)..where((i) => i.id.equals(id))).getSingleOrNull();

  Stream<List<Renewal>> watchRenewals(String itemId) => (db.select(db.renewals)
        ..where((r) => r.itemId.equals(itemId) & r.deletedAt.isNull())
        ..orderBy([(r) => OrderingTerm.desc(r.renewedAt)]))
      .watch();

  Stream<List<Attachment>> watchAttachments(String itemId) =>
      (db.select(db.attachments)
            ..where((a) => a.itemId.equals(itemId) & a.deletedAt.isNull())
            ..orderBy([(a) => OrderingTerm.asc(a.createdAt)]))
          .watch();

  Stream<Profile> watchProfile() => db.select(db.profiles).watchSingle();
  Future<Profile> profile() => db.select(db.profiles).getSingle();

  Stream<List<FamilyMember>> watchFamily() => (db.select(db.familyMembers)
        ..where((f) => f.deletedAt.isNull())
        ..orderBy([(f) => OrderingTerm.asc(f.sortOrder), (f) => OrderingTerm.asc(f.name)]))
      .watch();

  Stream<List<CustomCategory>> watchCustomCategories() =>
      (db.select(db.customCategories)..where((c) => c.deletedAt.isNull())).watch();

  // ---------------------------------------------------------------- items

  /// Creates or updates an item. Pass [id] null to create.
  Future<String> saveItem({
    String? id,
    required String title,
    required String categoryKey,
    DateTime? dueDate,
    DateTime? startDate,
    RecurrenceUnit recurrenceUnit = RecurrenceUnit.none,
    int recurrenceEvery = 1,
    List<int>? reminderOffsets,
    int? notifyMinutes,
    String? provider,
    String? referenceNo,
    int? amountMinor,
    String? notes,
    String? familyMemberId,
  }) async {
    final now = _clock();
    final itemId = id ?? newId();
    final companion = ItemsCompanion(
      id: Value(itemId),
      title: Value(title.trim()),
      categoryKey: Value(categoryKey),
      dueDate: Value(dueDate == null ? null : dateOnly(dueDate)),
      startDate: Value(startDate == null ? null : dateOnly(startDate)),
      recurrenceUnit: Value(recurrenceUnit),
      recurrenceEvery: Value(recurrenceEvery),
      reminderOffsets: Value(reminderOffsets),
      notifyMinutes: Value(notifyMinutes),
      provider: Value(_blankToNull(provider)),
      referenceNo: Value(_blankToNull(referenceNo)),
      amountMinor: Value(amountMinor),
      notes: Value(_blankToNull(notes)),
      familyMemberId: Value(familyMemberId),
      updatedAt: Value(now),
    );
    if (id == null) {
      await db.into(db.items).insert(companion.copyWith(createdAt: Value(now)));
    } else {
      await (db.update(db.items)..where((i) => i.id.equals(id))).write(companion);
    }
    await _changed();
    return itemId;
  }

  /// Soft delete: the row stays with deleted_at set and every screen hides it.
  Future<void> deleteItem(String id) async {
    final now = _clock();
    await db.transaction(() async {
      await (db.update(db.items)..where((i) => i.id.equals(id))).write(
          ItemsCompanion(deletedAt: Value(now), updatedAt: Value(now)));
      await (db.update(db.attachments)..where((a) => a.itemId.equals(id))).write(
          AttachmentsCompanion(deletedAt: Value(now), updatedAt: Value(now)));
    });
    await _changed();
  }

  Future<void> setArchived(String id, bool archived) async {
    await (db.update(db.items)..where((i) => i.id.equals(id))).write(ItemsCompanion(
        archived: Value(archived), updatedAt: Value(_clock())));
    await _changed();
  }

  /// Marks the item renewed: records history and moves the due date forward.
  Future<void> renew(
    String itemId, {
    required DateTime newDue,
    int? amountMinor,
    String? provider,
    String? notes,
  }) async {
    final now = _clock();
    await db.transaction(() async {
      final item = await getItem(itemId);
      if (item == null) throw StateError('Item $itemId not found');
      final previous = item.dueDate ?? dateOnly(now);
      await db.into(db.renewals).insert(RenewalsCompanion.insert(
            id: newId(),
            itemId: itemId,
            previousDue: previous,
            newDue: dateOnly(newDue),
            amountMinor: Value(amountMinor),
            provider: Value(_blankToNull(provider)),
            notes: Value(_blankToNull(notes)),
            renewedAt: Value(now),
            createdAt: Value(now),
            updatedAt: Value(now),
          ));
      await (db.update(db.items)..where((i) => i.id.equals(itemId))).write(ItemsCompanion(
        dueDate: Value(dateOnly(newDue)),
        startDate: Value(previous),
        amountMinor: amountMinor == null ? const Value.absent() : Value(amountMinor),
        provider: _blankToNull(provider) == null ? const Value.absent() : Value(provider!.trim()),
        snoozedUntil: const Value(null),
        archived: const Value(false),
        updatedAt: Value(now),
        ));
    });
    await _changed();
  }

  Future<void> snooze(String itemId, Duration by) async {
    final now = _clock();
    await (db.update(db.items)..where((i) => i.id.equals(itemId))).write(ItemsCompanion(
        snoozedUntil: Value(now.add(by)), updatedAt: Value(now)));
    await _changed();
  }

  // ---------------------------------------------------------------- attachments

  Future<void> addAttachment({
    required String id,
    required String itemId,
    required String fileName,
    required String mimeType,
    required int sizeBytes,
    required String localPath,
  }) async {
    await db.into(db.attachments).insert(AttachmentsCompanion.insert(
          id: id,
          itemId: itemId,
          fileName: fileName,
          mimeType: mimeType,
          sizeBytes: sizeBytes,
          localPath: Value(localPath),
        ));
    await _changed();
  }

  Future<void> deleteAttachment(String id) async {
    await (db.update(db.attachments)..where((a) => a.id.equals(id))).write(
        AttachmentsCompanion(
            deletedAt: Value(_clock()), updatedAt: Value(_clock())));
    await _changed();
  }

  // ---------------------------------------------------------------- family & categories

  Future<String> saveFamilyMember({String? id, required String name, String? relation, String? emoji}) async {
    final memberId = id ?? newId();
    await db.into(db.familyMembers).insertOnConflictUpdate(FamilyMembersCompanion(
          id: Value(memberId),
          name: Value(name.trim()),
          relation: Value(relation),
          emoji: Value(emoji),
          updatedAt: Value(_clock()),
            ));
    await _changed();
    return memberId;
  }

  Future<void> deleteFamilyMember(String id) async {
    final now = _clock();
    await db.transaction(() async {
      await (db.update(db.familyMembers)..where((f) => f.id.equals(id)))
          .write(FamilyMembersCompanion(deletedAt: Value(now), updatedAt: Value(now)));
      await (db.update(db.items)..where((i) => i.familyMemberId.equals(id))).write(
          ItemsCompanion(familyMemberId: const Value(null), updatedAt: Value(now)));
    });
    await _changed();
  }

  Future<String> addCustomCategory(String name, {String? parentKey}) async {
    final id = newId();
    await db.into(db.customCategories).insert(CustomCategoriesCompanion.insert(
        id: id, name: name.trim(), parentKey: Value(parentKey)));
    await _changed();
    return id;
  }

  // ---------------------------------------------------------------- settings

  Future<void> updateProfile(ProfilesCompanion changes) async {
    await (db.update(db.profiles)..where((p) => p.id.equals('me'))).write(changes);
    await _changed();
  }

  static String? _blankToNull(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();
}
