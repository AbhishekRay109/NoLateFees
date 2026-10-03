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
    // Make a v2 database, then turn it back into what v1 looked like.
    var db = AppDatabase(NativeDatabase(file));
    final repo = ItemRepository(db);
    await repo.updateProfile(const ProfilesCompanion(displayName: Value('Asha')));
    await repo.saveItem(title: 'Passport', categoryKey: 'documents.passport', dueDate: DateTime.utc(2030, 1, 1));
    for (final c in ['email', 'phone', 'photo_url', 'onboarded']) {
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
    expect(version.data.values.single, 2);
    await db.close();
  });

  test('a fresh database starts at version 2 with one empty profile', () async {
    final db = AppDatabase(NativeDatabase(file));
    final p = await ItemRepository(db).profile();
    expect(p.id, 'me');
    expect(p.onboarded, isFalse);
    expect(db.schemaVersion, 2);
    await db.close();
  });
}
