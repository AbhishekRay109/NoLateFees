// The phone's database. It is the source of truth for every screen; Firestore
// only holds a backup copy (see data/sync). Synced tables mirror the
// documents under users/{uid}/ and add `dirty` (changed here, not pushed yet).
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../domain/reminder_engine.dart';

part 'database.g.dart';

/// A calendar date stored as 'yyyy-mm-dd' text, read back as UTC midnight.
/// Storing a DateTime would shift the day for users west/east of UTC.
class DateOnlyConverter extends TypeConverter<DateTime, String> {
  const DateOnlyConverter();
  @override
  DateTime fromSql(String fromDb) => DateTime.parse('${fromDb}T00:00:00Z');
  @override
  String toSql(DateTime value) => formatDate(value);
}

/// [30, 7, 1] stored as '30,7,1'.
class IntListConverter extends TypeConverter<List<int>, String> {
  const IntListConverter();
  @override
  List<int> fromSql(String fromDb) => fromDb.isEmpty
      ? <int>[]
      : fromDb.split(',').map(int.parse).toList();
  @override
  String toSql(List<int> value) => value.join(',');
}

mixin SyncColumns on Table {
  IntColumn get rev => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();
}

/// Exactly one row, id = 'me'. Synced to `profiles` (id = auth user id).
class Profiles extends Table {
  TextColumn get id => text().withDefault(const Constant('me'))();
  TextColumn get displayName => text().nullable()();
  TextColumn get email => text().nullable()(); // v2
  TextColumn get phone => text().nullable()(); // v2, E.164 e.g. +919876543210
  TextColumn get photoUrl => text().nullable()(); // v2
  TextColumn get timezone => text().withDefault(const Constant('Asia/Kolkata'))();
  IntColumn get defaultNotifyMinutes =>
      integer().withDefault(const Constant(9 * 60))(); // 09:00
  TextColumn get defaultOffsets => text()
      .map(const IntListConverter())
      .withDefault(const Constant('30,14,7,3,1,0,-1'))();
  TextColumn get currency => text().withDefault(const Constant('INR'))();
  TextColumn get themeMode => text().withDefault(const Constant('system'))(); // local only
  BoolColumn get exactAlarms => boolean().withDefault(const Constant(false))(); // local only
  BoolColumn get notificationsEnabled => boolean().withDefault(const Constant(true))(); // local only
  BoolColumn get onboarded => boolean().withDefault(const Constant(false))(); // v2, local only
  IntColumn get rev => integer().withDefault(const Constant(0))();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class FamilyMembers extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get relation => text().nullable()();
  TextColumn get emoji => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class CustomCategories extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get parentKey => text().nullable()();
  TextColumn get name => text()();
  TextColumn get icon => text().nullable()();

  @override
  String get tableName => 'categories';
  @override
  Set<Column> get primaryKey => {id};
}

class Items extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get familyMemberId => text().nullable()();
  TextColumn get categoryKey => text()();
  TextColumn get title => text().withLength(min: 1, max: 120)();
  TextColumn get provider => text().nullable()();
  TextColumn get referenceNo => text().nullable()();
  IntColumn get amountMinor => integer().nullable()();
  TextColumn get currency => text().withDefault(const Constant('INR'))();
  TextColumn get startDate => text().map(const DateOnlyConverter()).nullable()();
  TextColumn get dueDate => text().map(const DateOnlyConverter()).nullable()();
  IntColumn get recurrenceUnit => intEnum<RecurrenceUnit>()();
  IntColumn get recurrenceEvery => integer().withDefault(const Constant(1))();
  TextColumn get reminderOffsets =>
      text().map(const IntListConverter()).nullable()(); // null = profile default
  IntColumn get notifyMinutes => integer().nullable()(); // null = profile default
  DateTimeColumn get snoozedUntil => dateTime().nullable()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  TextColumn get extra => text().withDefault(const Constant('{}'))(); // JSON

  @override
  Set<Column> get primaryKey => {id};
}

class Renewals extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get previousDue => text().map(const DateOnlyConverter())();
  TextColumn get newDue => text().map(const DateOnlyConverter())();
  IntColumn get amountMinor => integer().nullable()();
  TextColumn get provider => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get renewedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Attachments extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get storagePath => text()(); // {userId}/{itemId}/{id}.{ext}; userId filled at upload
  TextColumn get fileName => text()();
  TextColumn get mimeType => text()();
  IntColumn get sizeBytes => integer()();
  TextColumn get localPath => text().nullable()(); // local only
  BoolColumn get uploadPending => boolean().withDefault(const Constant(true))(); // local only

  @override
  Set<Column> get primaryKey => {id};
}

/// Local only: which notifications are booked with the OS right now.
class ScheduledNotifications extends Table {
  IntColumn get osId => integer().autoIncrement()();
  TextColumn get instanceKey => text().unique()();
  TextColumn get itemId => text()();
  DateTimeColumn get fireAt => dateTime()();
  TextColumn get body => text()();
}

/// Local only: pull cursor per synced table.
class SyncState extends Table {
  TextColumn get tableNameKey => text()();
  IntColumn get lastRev => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {tableNameKey};
}

@DriftDatabase(tables: [
  Profiles,
  FamilyMembers,
  CustomCategories,
  Items,
  Renewals,
  Attachments,
  ScheduledNotifications,
  SyncState,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// The on-device database file "duemate.sqlite" (name kept so existing
  /// installs keep their data after the NoLateFees rename). Shared across isolates so
  /// a Snooze pressed in the background shows up on screen straight away.
  factory AppDatabase.open() => AppDatabase(driftDatabase(
      name: 'duemate', native: const DriftNativeOptions(shareAcrossIsolates: true)));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await customStatement(
              'CREATE INDEX items_due ON items (due_date) WHERE deleted_at IS NULL');
          await customStatement('CREATE INDEX items_category ON items (category_key)');
          await customStatement('CREATE INDEX renewals_item ON renewals (item_id)');
          await customStatement('CREATE INDEX attachments_item ON attachments (item_id)');
          await into(profiles).insert(const ProfilesCompanion());
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v2: user info from the login/profile screens.
            await m.addColumn(profiles, profiles.email);
            await m.addColumn(profiles, profiles.phone);
            await m.addColumn(profiles, profiles.photoUrl);
            await m.addColumn(profiles, profiles.onboarded);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Erases everything (used on sign-out so another account can't inherit data).
  Future<void> wipe() => transaction(() async {
        for (final t in allTables) {
          await delete(t).go();
        }
        await into(profiles).insert(const ProfilesCompanion());
      });
}
