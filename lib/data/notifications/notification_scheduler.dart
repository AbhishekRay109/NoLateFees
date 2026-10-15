// reconcile(): the one function that books notifications with the OS.
// It compares what *should* be scheduled (from the reminder engine) with what
// *is* scheduled (the scheduled_notifications table) and fixes the difference.
// Safe to call any number of times: after every write, after an import, on app
// open, on timezone change and from the daily background job.
import 'package:drift/drift.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../domain/reminder_engine.dart';
import '../local/database.dart';

/// The OS side, behind an interface so tests can use a fake.
abstract class NotificationGateway {
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime at,
    required String payload,
    required bool exact,
    required bool urgent,
  });
  Future<void> cancel(int id);
  Future<void> cancelAll();
}

class NotificationScheduler {
  NotificationScheduler(this.db, this.gateway,
      {required this.location, required this.limit, DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final AppDatabase db;
  final NotificationGateway gateway;

  /// The phone's timezone.
  tz.Location location;

  /// 60 on iOS (hard cap is 64), 400 on Android (cap ~500).
  final int limit;
  final DateTime Function() _clock;

  Future<void>? _running;
  bool _again = false;

  /// Runs [_reconcile], coalescing calls that arrive while one is in flight.
  Future<void> reconcile() async {
    if (_running != null) {
      _again = true;
      return _running;
    }
    _running = () async {
      try {
        do {
          _again = false;
          await _reconcile();
        } while (_again);
      } finally {
        _running = null;
      }
    }();
    return _running;
  }

  Future<void> _reconcile() async {
    final profile = await db.select(db.profiles).getSingle();
    final items = await (db.select(db.items)
          ..where((i) => i.deletedAt.isNull() & i.archived.equals(false) & i.dueDate.isNotNull()))
        .get();

    final desired = profile.notificationsEnabled
        ? planSchedule(
            items.map(toReminderInput),
            now: _clock(),
            location: location,
            limit: limit,
            fallbackOffsets: profile.defaultOffsets,
            fallbackNotifyMinutes: profile.defaultNotifyMinutes,
          )
        : <ReminderInstance>[];

    final rows = await db.select(db.scheduledNotifications).get();
    final scheduled = {
      for (final r in rows) r.instanceKey: (osId: r.osId, fireAt: r.fireAt, body: r.body),
    };
    final diff = diffSchedule(desired, scheduled);
    if (diff.isEmpty) return;

    for (final osId in diff.toCancel) {
      await gateway.cancel(osId);
      await (db.delete(db.scheduledNotifications)..where((s) => s.osId.equals(osId))).go();
    }
    for (final r in diff.toSchedule) {
      final osId = await db.into(db.scheduledNotifications).insert(
          ScheduledNotificationsCompanion.insert(
              instanceKey: r.key, itemId: r.itemId, fireAt: r.fireAt.toUtc(), body: r.body),
          mode: InsertMode.insertOrReplace);
      await gateway.schedule(
        id: osId,
        title: r.title,
        body: r.body,
        at: r.fireAt,
        payload: r.itemId,
        exact: profile.exactAlarms,
        urgent: (r.offsetDays ?? 0) <= 1,
      );
    }
  }

  /// Cancels everything (sign-out, notifications turned off).
  Future<void> clear() async {
    await gateway.cancelAll();
    await db.delete(db.scheduledNotifications).go();
  }
}

ReminderInput toReminderInput(Item i) => ReminderInput(
      itemId: i.id,
      title: i.title,
      dueDate: i.dueDate,
      offsets: i.reminderOffsets,
      notifyMinutes: i.notifyMinutes,
      snoozedUntil: i.snoozedUntil,
      active: i.deletedAt == null && !i.archived,
    );
