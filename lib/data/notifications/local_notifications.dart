// flutter_local_notifications behind NotificationGateway, plus the handlers
// for the notification buttons (View / Renewed / Snooze).
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../item_repository.dart';
import '../local/database.dart';
import 'notification_scheduler.dart';

const actionRenewed = 'renewed';
const actionSnooze = 'snooze';

const _upcomingChannel = AndroidNotificationDetails(
  'upcoming',
  'Upcoming renewals',
  channelDescription: 'Reminders before something expires',
  importance: Importance.defaultImportance,
  priority: Priority.defaultPriority,
  actions: [
    AndroidNotificationAction(actionRenewed, 'Renewed', showsUserInterface: true),
    AndroidNotificationAction(actionSnooze, 'Snooze 1 day'),
  ],
);

const _urgentChannel = AndroidNotificationDetails(
  'urgent',
  'Due today and overdue',
  channelDescription: 'Reminders for things due tomorrow, today or already expired',
  importance: Importance.high,
  priority: Priority.high,
  actions: [
    AndroidNotificationAction(actionRenewed, 'Renewed', showsUserInterface: true),
    AndroidNotificationAction(actionSnooze, 'Snooze 1 day'),
  ],
);

const _darwin = DarwinNotificationDetails(categoryIdentifier: 'reminder');

/// Loads the timezone database and returns the phone's zone.
Future<tz.Location> initTimezone() async {
  tzdata.initializeTimeZones();
  try {
    final info = await FlutterTimezone.getLocalTimezone();
    final loc = tz.getLocation(info.identifier);
    tz.setLocalLocation(loc);
    return loc;
  } catch (_) {
    final loc = tz.getLocation('Asia/Kolkata');
    tz.setLocalLocation(loc);
    return loc;
  }
}

class LocalNotifications implements NotificationGateway {
  LocalNotifications([FlutterLocalNotificationsPlugin? plugin])
      : plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin plugin;

  /// [onTap] receives the item id and the action pressed ('' for a plain tap).
  Future<void> init({void Function(String itemId, String action)? onTap}) async {
    await plugin.initialize(
      settings: InitializationSettings(
        android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          notificationCategories: [
            DarwinNotificationCategory('reminder', actions: [
              DarwinNotificationAction.plain(actionRenewed, 'Renewed',
                  options: {DarwinNotificationActionOption.foreground}),
              DarwinNotificationAction.plain(actionSnooze, 'Snooze 1 day'),
            ]),
          ],
        ),
      ),
      onDidReceiveNotificationResponse: (r) {
        final id = r.payload;
        if (id == null) return;
        if (r.actionId == actionSnooze) {
          onSnoozeInForeground?.call(id);
        } else {
          onTap?.call(id, r.actionId ?? '');
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationBackgroundHandler,
    );
  }

  /// Set by main(): snooze pressed while the app is running.
  void Function(String itemId)? onSnoozeInForeground;

  /// Item id + action if the app was launched by tapping a notification.
  Future<(String, String)?> launchDetails() async {
    final d = await plugin.getNotificationAppLaunchDetails();
    final r = d?.notificationResponse;
    if (d?.didNotificationLaunchApp != true || r?.payload == null) return null;
    return (r!.payload!, r.actionId ?? '');
  }

  /// Asks for permission to show notifications. Returns true if granted.
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final android = plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? false;
    }
    final ios = plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    return await ios?.requestPermissions(alert: true, badge: true, sound: true) ?? false;
  }

  /// Android 12+: asks for exact alarm access. Returns true if granted.
  Future<bool> requestExactAlarms() async {
    if (!Platform.isAndroid) return true;
    final android = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestExactAlarmsPermission() ?? false;
  }

  Future<bool> canScheduleExact() async {
    if (!Platform.isAndroid) return true;
    final android = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.canScheduleExactNotifications() ?? false;
  }

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime at,
    required String payload,
    required bool exact,
    required bool urgent,
  }) async {
    final useExact = exact && await canScheduleExact();
    await plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: at,
      payload: payload,
      notificationDetails: NotificationDetails(
          android: urgent ? _urgentChannel : _upcomingChannel, iOS: _darwin),
      androidScheduleMode: useExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancel(int id) => plugin.cancel(id: id);

  @override
  Future<void> cancelAll() => plugin.cancelAll();
}

/// Runs in a background isolate when "Snooze" is pressed and the app is not
/// running. Opens the database, snoozes, and re-books notifications.
@pragma('vm:entry-point')
void notificationBackgroundHandler(NotificationResponse r) async {
  if (r.actionId != actionSnooze || r.payload == null) return;
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase.open();
  try {
    await snoozeAndReconcile(db, r.payload!);
  } catch (e) {
    debugPrint('Background snooze failed: $e');
  } finally {
    await db.close();
  }
}

/// Shared by the background isolate and the daily job.
Future<void> snoozeAndReconcile(AppDatabase db, String? itemId) async {
  final location = await initTimezone();
  final gateway = LocalNotifications();
  await gateway.init();
  final scheduler = NotificationScheduler(db, gateway,
      location: location, limit: Platform.isIOS ? 60 : 400);
  if (itemId != null) {
    await ItemRepository(db).snooze(itemId, const Duration(days: 1));
  }
  await scheduler.reconcile();
}
