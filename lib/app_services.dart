// Builds every service once at startup and exposes them to the widget tree
// through Riverpod. Tests build AppServices with in-memory fakes instead.
import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

import 'core/config.dart';
import 'data/attachment_service.dart';
import 'data/backup/export_service.dart';
import 'data/item_repository.dart';
import 'data/local/database.dart';
import 'data/notifications/local_notifications.dart';
import 'data/notifications/notification_scheduler.dart';
import 'data/sync/supabase_remote_store.dart';
import 'data/sync/sync_service.dart';

const dailyTaskName = 'duemate-daily-reconcile';

class AppServices {
  AppServices({
    required this.db,
    required this.repo,
    required this.scheduler,
    required this.export,
    required this.attachments,
    this.notifications,
    this.sync,
    this.supabase,
  }) {
    repo.onChanged = () async {
      await scheduler.reconcile();
      sync?.schedule();
    };
  }

  final AppDatabase db;
  final ItemRepository repo;
  final NotificationScheduler scheduler;
  final ExportService export;
  final AttachmentService attachments;
  final LocalNotifications? notifications; // null in tests
  final SyncService? sync; // null when Supabase is not configured
  final SupabaseClient? supabase;
  StreamSubscription<dynamic>? _connectivity;

  static Future<AppServices> create() async {
    final location = await initTimezone();
    final db = AppDatabase.open();
    final notifications = LocalNotifications();

    SupabaseClient? client;
    RemoteStore? remote;
    if (AppConfig.cloudEnabled) {
      await Supabase.initialize(url: AppConfig.supabaseUrl, publishableKey: AppConfig.supabaseKey);
      client = Supabase.instance.client;
      remote = SupabaseRemoteStore(client);
    }

    final scheduler = NotificationScheduler(db, notifications,
        location: location, limit: Platform.isIOS ? 60 : 400);
    final sync = remote == null
        ? null
        : SyncService(db, remote, onPulledChanges: scheduler.reconcile);
    final repo = ItemRepository(db);
    final services = AppServices(
      db: db,
      repo: repo,
      scheduler: scheduler,
      export: ExportService(db),
      attachments: AttachmentService(repo, remote: remote),
      notifications: notifications,
      sync: sync,
      supabase: client,
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
    final s = sync;
    if (s != null) {
      unawaited(s.run().catchError((_) {}));
      supabase!.auth.onAuthStateChange.listen((event) {
        if (event.event == AuthChangeEvent.signedIn) unawaited(s.run().catchError((_) {}));
      });
      _connectivity = Connectivity().onConnectivityChanged.listen((results) {
        if (results.any((r) => r != ConnectivityResult.none)) s.schedule(delay: const Duration(seconds: 1));
      });
    }
  }

  /// On app resume: pick up a timezone change, top up notifications, sync.
  Future<void> onResume() async {
    final location = await initTimezone();
    if (location.name != scheduler.location.name) {
      scheduler.location = location;
      await _recordTimezone(location);
    }
    await scheduler.reconcile();
    sync?.schedule(delay: Duration.zero);
  }

  Future<void> _recordTimezone(tz.Location location) async {
    final p = await repo.profile();
    if (p.timezone != location.name) {
      await repo.updateProfile(ProfilesCompanion(timezone: Value(location.name)));
    }
  }

  bool get signedIn => supabase?.auth.currentUser != null;

  /// Pushes anything unsynced, then erases this phone's copy.
  Future<void> signOut() async {
    try {
      await sync?.run();
    } catch (_) {}
    await supabase?.auth.signOut();
    await scheduler.clear();
    await db.wipe();
  }

  /// Deletes the account and all cloud data via the delete-account function.
  Future<void> deleteAccount() async {
    if (supabase != null && signedIn) {
      await supabase!.functions.invoke('delete-account', method: HttpMethod.post);
      await supabase!.auth.signOut();
    }
    await scheduler.clear();
    await db.wipe();
  }

  void dispose() {
    _connectivity?.cancel();
    sync?.dispose();
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

final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final sync = ref.watch(servicesProvider).sync;
  if (sync == null) return Stream.value(const SyncStatus(SyncPhase.signedOut));
  return sync.status;
});

/// Current signed-in user's email, or null.
final userEmailProvider = StreamProvider<String?>((ref) async* {
  final client = ref.watch(servicesProvider).supabase;
  if (client == null) {
    yield null;
    return;
  }
  yield client.auth.currentUser?.email;
  yield* client.auth.onAuthStateChange.map((s) => s.session?.user.email);
});
