import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart' show Size;
import 'package:flutter_test/flutter_test.dart';
import 'package:nolatefees/app_services.dart';
import 'package:nolatefees/data/attachment_service.dart';
import 'package:nolatefees/data/backup/export_service.dart';
import 'package:nolatefees/data/item_repository.dart';
import 'package:nolatefees/data/local/database.dart';
import 'package:nolatefees/data/notifications/notification_scheduler.dart';
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

/// AppServices on an in-memory database.
AppServices buildServices({AppDatabase? db, NotificationGateway? gateway}) {
  final database = db ?? memoryDb();
  final repo = ItemRepository(database);
  final scheduler = NotificationScheduler(database, gateway ?? FakeGateway(),
      location: tz.getLocation('Asia/Kolkata'), limit: 60);
  return AppServices(
    db: database,
    repo: repo,
    scheduler: scheduler,
    export: ExportService(database),
    attachments: AttachmentService(repo),
  );
}

/// Marks onboarding done so the app opens on the home screen.
Future<void> markOnboarded(AppServices s, {String name = 'Asha'}) => s.saveProfile(name: name);

/// A Pixel-8-sized test surface (412 x 915 logical pixels).
void usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
}

/// Lets real database work started by a tap finish, then settles the UI.
/// Don't await database writes inside tester.runAsync once the app is
/// pumped: a stream query waiting on the fake clock can hold drift's lock,
/// and the write then waits forever. Trigger writes through the UI instead.
Future<void> settleDb(WidgetTester tester, {int rounds = 5}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump(const Duration(milliseconds: 50));
  }
  await tester.pumpAndSettle();
}
