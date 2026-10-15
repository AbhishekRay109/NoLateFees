import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nolatefees/data/item_repository.dart';
import 'package:nolatefees/data/local/database.dart';

void main() {
  late Directory dir;
  late File file;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    dir = Directory.systemTemp.createTempSync('nlf-migration');
    file = File('${dir.path}/app.sqlite');
  });

  tearDown(() => dir.deleteSync(recursive: true));

  test('upgrading a version-1 install keeps data and adds the profile fields', () async {
    // Make a current database, then turn it back into what v1 looked like.
    var db = AppDatabase(NativeDatabase(file));
    final repo = ItemRepository(db);
    await repo.updateProfile(const ProfilesCompanion(displayName: Value('Asha')));
    await repo.saveItem(title: 'Passport', categoryKey: 'documents.passport', dueDate: DateTime.utc(2030, 1, 1));
    for (final c in ['email', 'phone', 'onboarded']) {
      await db.customStatement('ALTER TABLE profiles DROP COLUMN $c');
    }
    await db.customStatement('PRAGMA user_version = 1');
    await db.close();

    db = AppDatabase(NativeDatabase(file));
    final upgraded = ItemRepository(db);
    final p = await upgraded.profile();
    expect(p.displayName, 'Asha');
    expect(p.email, isNull);
    expect(p.phone, isNull);
    expect(p.onboarded, isFalse); // existing users see the new welcome screen once
    expect((await upgraded.activeItems()).single.title, 'Passport');

    await upgraded.updateProfile(const ProfilesCompanion(email: Value('asha@example.com')));
    expect((await upgraded.profile()).email, 'asha@example.com');
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, 3);
    await db.close();
  });

  test('upgrading a version-2 (cloud sync) install keeps every row and drops the sync columns', () async {
    // Make a current database, then add back what the v2 sync build had.
    var db = AppDatabase(NativeDatabase(file));
    var repo = ItemRepository(db);
    await repo.updateProfile(const ProfilesCompanion(displayName: Value('Asha'), onboarded: Value(true)));
    final member = await repo.saveFamilyMember(name: 'Ammi');
    final id = await repo.saveItem(
        title: 'Passport', categoryKey: 'documents.passport', dueDate: DateTime.utc(2030, 1, 1), familyMemberId: member);
    await repo.renew(id, newDue: DateTime.utc(2040, 1, 1));
    await repo.addAttachment(
        id: 'a1', itemId: id, fileName: 'scan.pdf', mimeType: 'application/pdf', sizeBytes: 10, localPath: '/x/a1.pdf');
    for (final t in ['family_members', 'categories', 'items', 'renewals', 'attachments']) {
      await db.customStatement('ALTER TABLE $t ADD COLUMN rev INTEGER NOT NULL DEFAULT 0');
      await db.customStatement('ALTER TABLE $t ADD COLUMN dirty INTEGER NOT NULL DEFAULT 1');
    }
    await db.customStatement('ALTER TABLE profiles ADD COLUMN rev INTEGER NOT NULL DEFAULT 0');
    await db.customStatement('ALTER TABLE profiles ADD COLUMN dirty INTEGER NOT NULL DEFAULT 0');
    await db.customStatement('ALTER TABLE profiles ADD COLUMN photo_url TEXT');
    await db.customStatement("ALTER TABLE attachments ADD COLUMN storage_path TEXT NOT NULL DEFAULT ''");
    await db.customStatement('ALTER TABLE attachments ADD COLUMN upload_pending INTEGER NOT NULL DEFAULT 1');
    await db.customStatement(
        'CREATE TABLE sync_state (table_name_key TEXT NOT NULL PRIMARY KEY, last_rev INTEGER NOT NULL DEFAULT 0)');
    await db.customStatement('PRAGMA user_version = 2');
    await db.close();

    db = AppDatabase(NativeDatabase(file));
    repo = ItemRepository(db);
    final p = await repo.profile();
    expect(p.displayName, 'Asha');
    expect(p.onboarded, isTrue);
    final item = (await repo.activeItems()).single;
    expect(item.dueDate, DateTime.utc(2040, 1, 1));
    expect(item.familyMemberId, member);
    expect(await repo.watchRenewals(id).first, hasLength(1));
    expect((await repo.watchAttachments(id).first).single.localPath, '/x/a1.pdf');

    Future<List<String>> columns(String table) async =>
        (await db.customSelect('PRAGMA table_info($table)').get()).map((r) => r.read<String>('name')).toList();
    for (final t in ['profiles', 'family_members', 'categories', 'items', 'renewals', 'attachments']) {
      expect(await columns(t), isNot(contains('rev')), reason: t);
      expect(await columns(t), isNot(contains('dirty')), reason: t);
    }
    expect(await columns('attachments'), isNot(contains('upload_pending')));
    expect(await columns('profiles'), isNot(contains('photo_url')));
    final tables = await db.customSelect("SELECT name FROM sqlite_master WHERE type = 'table'").get();
    expect(tables.map((r) => r.read<String>('name')), isNot(contains('sync_state')));
    final indexes = await db.customSelect("SELECT name FROM sqlite_master WHERE type = 'index'").get();
    expect(indexes.map((r) => r.read<String>('name')), containsAll(['items_due', 'renewals_item']));
    expect((await db.customSelect('PRAGMA user_version').getSingle()).data.values.single, 3);
    await db.close();
  });

  test('a fresh database starts at version 3 with one empty profile', () async {
    final db = AppDatabase(NativeDatabase(file));
    final p = await ItemRepository(db).profile();
    expect(p.id, 'me');
    expect(p.onboarded, isFalse);
    expect(db.schemaVersion, 3);
    await db.close();
  });
}
