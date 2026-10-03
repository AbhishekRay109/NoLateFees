// Builds every service once at startup and exposes them to the widget tree
// through Riverpod. Tests build AppServices with in-memory fakes instead.
import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show Value;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

import 'core/config.dart';
import 'data/attachment_service.dart';
import 'data/auth/auth_service.dart';
import 'data/auth/firebase_auth_service.dart';
import 'data/backup/export_service.dart';
import 'data/item_repository.dart';
import 'data/local/database.dart';
import 'data/notifications/local_notifications.dart';
import 'data/notifications/notification_scheduler.dart';
import 'data/sync/firestore_remote_store.dart';
import 'data/sync/sync_service.dart';

const dailyTaskName = 'duemate-daily-reconcile'; // kept: renaming would register a second job

class AppServices {
  AppServices({
    required this.db,
    required this.repo,
    required this.scheduler,
    required this.export,
    required this.attachments,
    this.notifications,
    this.sync,
    this.auth,
    this.remote,
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
  final SyncService? sync; // null when Firebase is not configured
  final AuthService? auth; // null when Firebase is not configured
  final RemoteStore? remote;
  StreamSubscription<dynamic>? _connectivity;
  StreamSubscription<dynamic>? _authSub;

  bool get cloudAvailable => auth != null;

  static Future<AppServices> create() async {
    final location = await initTimezone();
    final db = AppDatabase.open();
    final notifications = LocalNotifications();

    AuthService? auth;
    FirestoreRemoteStore? remote;
    if (AppConfig.cloudEnabled) {
      try {
        await Firebase.initializeApp(options: AppConfig.firebaseOptions);
        final fbAuth = FirebaseAuth.instance;
        auth = FirebaseAuthService(fbAuth, googleServerClientId: AppConfig.googleServerClientId);
        remote = FirestoreRemoteStore(
          FirebaseFirestore.instance,
          currentUid: () => fbAuth.currentUser?.uid,
          storage: AppConfig.firebaseStorageBucket.isEmpty ? null : FirebaseStorage.instance,
        );
      } catch (e) {
        // Bad config should never stop the app from opening: run offline.
        debugPrint('Firebase init failed, running offline: $e');
        auth = null;
        remote = null;
      }
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
      auth: auth,
      remote: remote,
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

  bool get signedIn => auth?.currentUser != null;

  /// After Google or phone sign-in: copy what we learned about the person
  /// into the profile (without overwriting what they typed), then sync.
  /// Anything added before signing in is uploaded to the account.
  Future<void> completeSignIn(AppUser user) async {
    await mergeUserIntoProfile(repo, user);
    final s = sync;
    if (s != null) {
      try {
        await s.run();
      } catch (_) {
        // Offline: it syncs later.
      }
    }
  }

  /// Saves the profile screen and marks onboarding done.
  Future<void> saveProfile({required String name, String? email, String? phone}) async {
    await repo.updateProfile(ProfilesCompanion(
      displayName: Value(name.trim()),
      email: Value(email == null || email.trim().isEmpty ? null : email.trim()),
      phone: Value(phone),
    ));
    await repo.updateProfile(const ProfilesCompanion(onboarded: Value(true)), synced: false);
  }

  /// Pushes anything unsynced, then erases this phone's copy.
  Future<void> signOut() async {
    try {
      await sync?.run();
    } catch (_) {}
    await auth?.signOut();
    await scheduler.clear();
    await db.wipe();
  }

  /// Deletes all cloud data and the sign-in account, then this phone's copy.
  Future<void> deleteAccount() async {
    if (auth != null && signedIn) {
      final r = remote;
      if (r is FirestoreRemoteStore) await r.deleteAllUserData();
      await auth!.deleteAccount();
      await auth!.signOut();
    }
    await scheduler.clear();
    await db.wipe();
  }

  void dispose() {
    _connectivity?.cancel();
    _authSub?.cancel();
    sync?.dispose();
  }
}

/// Fills empty profile fields from the sign-in provider. Pure enough to test.
Future<void> mergeUserIntoProfile(ItemRepository repo, AppUser user) async {
  final p = await repo.profile();
  String? pick(String? current, String? fromAuth) =>
      (current == null || current.trim().isEmpty) ? fromAuth : current;
  final name = pick(p.displayName, user.name);
  final email = pick(p.email, user.email);
  final phone = pick(p.phone, user.phone);
  final photo = pick(p.photoUrl, user.photoUrl);
  if (name == p.displayName && email == p.email && phone == p.phone && photo == p.photoUrl) return;
  await repo.updateProfile(ProfilesCompanion(
    displayName: Value(name),
    email: Value(email),
    phone: Value(phone),
    photoUrl: Value(photo),
  ));
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

/// The signed-in user, or null (also null when cloud isn't set up).
final authUserProvider = StreamProvider<AppUser?>((ref) async* {
  final auth = ref.watch(servicesProvider).auth;
  if (auth == null) {
    yield null;
    return;
  }
  yield auth.currentUser;
  yield* auth.userChanges();
});
