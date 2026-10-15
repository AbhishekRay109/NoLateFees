// Builds every service once at startup and exposes them to the widget tree
// through Riverpod. Tests build AppServices with in-memory fakes instead.
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

import 'data/attachment_service.dart';
import 'data/backup/export_service.dart';
import 'data/item_repository.dart';
import 'data/local/database.dart';
import 'data/notifications/local_notifications.dart';
import 'data/notifications/notification_scheduler.dart';

const dailyTaskName = 'duemate-daily-reconcile'; // kept: renaming would register a second job

class AppServices {
  AppServices({
    required this.db,
    required this.repo,
    required this.scheduler,
    required this.export,
    required this.attachments,
    this.notifications,
  }) {
    repo.onChanged = scheduler.reconcile;
  }

  final AppDatabase db;
  final ItemRepository repo;
  final NotificationScheduler scheduler;
  final ExportService export;
  final AttachmentService attachments;
  final LocalNotifications? notifications; // null in tests

  static Future<AppServices> create() async {
    final location = await initTimezone();
    final db = AppDatabase.open();
    final notifications = LocalNotifications();
    final scheduler = NotificationScheduler(db, notifications,
        location: location, limit: Platform.isIOS ? 60 : 400);
    final repo = ItemRepository(db);
    final services = AppServices(
      db: db,
      repo: repo,
      scheduler: scheduler,
      export: ExportService(db),
      attachments: AttachmentService(repo),
      notifications: notifications,
    );
    await services._recordTimezone(location);
    return services;
  }

  /// Called once the UI is up.
  Future<void> start() async {
    await scheduler.reconcile();
    if (Platform.isAndroid) {
      await Workmanager().registerPeriodicTask(dailyTaskName, dailyTaskName,
          frequency: const Duration(hours: 24),
          existingWorkPolicy: ExistingPeriodicWorkPolicy.keep);
    }
  }

  /// On app resume: pick up a timezone change and top up notifications.
  Future<void> onResume() async {
    final location = await initTimezone();
    if (location.name != scheduler.location.name) {
      scheduler.location = location;
      await _recordTimezone(location);
    }
    await scheduler.reconcile();
  }

  Future<void> _recordTimezone(tz.Location location) async {
    final p = await repo.profile();
    if (p.timezone != location.name) {
      await repo.updateProfile(ProfilesCompanion(timezone: Value(location.name)));
    }
  }

  /// Saves the profile screen and marks onboarding done.
  Future<void> saveProfile({required String name, String? email, String? phone}) async {
    await repo.updateProfile(ProfilesCompanion(
      displayName: Value(name.trim()),
      email: Value(email == null || email.trim().isEmpty ? null : email.trim()),
      phone: Value(phone),
      onboarded: const Value(true),
    ));
  }

  /// Erases every reminder, setting and notification on this phone.
  Future<void> eraseAllData() async {
    await scheduler.clear();
    await db.wipe();
  }
}

// ------------------------------------------------------------------ providers

final servicesProvider = Provider<AppServices>((ref) => throw UnimplementedError('override in main'));

final repoProvider = Provider<ItemRepository>((ref) => ref.watch(servicesProvider).repo);

final itemsProvider = StreamProvider<List<Item>>((ref) => ref.watch(repoProvider).watchItems());

final allItemsProvider =
    StreamProvider<List<Item>>((ref) => ref.watch(repoProvider).watchItems(includeArchived: true));

final itemProvider = StreamProvider.family<Item?, String>((ref, id) => ref.watch(repoProvider).watchItem(id));

final renewalsProvider =
    StreamProvider.family<List<Renewal>, String>((ref, id) => ref.watch(repoProvider).watchRenewals(id));

final attachmentsProvider =
    StreamProvider.family<List<Attachment>, String>((ref, id) => ref.watch(repoProvider).watchAttachments(id));

final profileProvider = StreamProvider<Profile>((ref) => ref.watch(repoProvider).watchProfile());

final familyProvider = StreamProvider<List<FamilyMember>>((ref) => ref.watch(repoProvider).watchFamily());

final customCategoriesProvider =
    StreamProvider<List<CustomCategory>>((ref) => ref.watch(repoProvider).watchCustomCategories());
