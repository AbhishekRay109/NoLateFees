// Pure Dart: no Flutter, no database. Everything about "when should we remind"
// lives here so it can be unit tested on its own.
import 'package:timezone/timezone.dart' as tz;

enum RecurrenceUnit { none, day, week, month, year }

/// Where an item sits on the dashboard. Always computed, never stored.
enum DueStatus { overdue, today, next7, next30, upcoming, noDate }

/// Default schedule: 30, 14, 7, 3, 1 days before, on the day, 1 day after.
const defaultOffsets = <int>[30, 14, 7, 3, 1, 0, -1];

/// 09:00, as minutes since midnight.
const defaultNotifyMinutes = 9 * 60;

/// A calendar date with no time and no timezone. Represented as a UTC
/// midnight DateTime so arithmetic never crosses a DST boundary.
DateTime dateOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day);

int _daysInMonth(int year, int month) => DateTime.utc(year, month + 1, 0).day;

/// Moves [date] forward by [every] × [unit]. Month and year steps clamp to the
/// end of the month: 31 Jan + 1 month = 28/29 Feb, 29 Feb 2028 + 1 year = 28 Feb 2029.
DateTime addRecurrence(DateTime date, RecurrenceUnit unit, int every) {
  final d = dateOnly(date);
  switch (unit) {
    case RecurrenceUnit.none:
      return d;
    case RecurrenceUnit.day:
      return d.add(Duration(days: every));
    case RecurrenceUnit.week:
      return d.add(Duration(days: 7 * every));
    case RecurrenceUnit.month:
    case RecurrenceUnit.year:
      final months = unit == RecurrenceUnit.month ? every : every * 12;
      final total = d.month - 1 + months;
      final y = d.year + total ~/ 12;
      final m = total % 12 + 1;
      final day = d.day.clamp(1, _daysInMonth(y, m));
      return DateTime.utc(y, m, day);
  }
}

/// The next due date after a renewal. Non-repeating items keep their date
/// (the user must pick one by hand).
DateTime nextDueDate(DateTime due, RecurrenceUnit unit, int every) =>
    addRecurrence(due, unit, every);

/// Whole days from [today] to [due]; negative when overdue.
int daysUntil(DateTime due, DateTime today) =>
    dateOnly(due).difference(dateOnly(today)).inDays;

DueStatus statusFor(DateTime? due, DateTime today) {
  if (due == null) return DueStatus.noDate;
  final days = daysUntil(due, today);
  if (days < 0) return DueStatus.overdue;
  if (days == 0) return DueStatus.today;
  if (days <= 7) return DueStatus.next7;
  if (days <= 30) return DueStatus.next30;
  return DueStatus.upcoming;
}

/// "5 days left", "Due today", "Expired 2 days ago".
String countdownLabel(DateTime due, DateTime today) {
  final d = daysUntil(due, today);
  if (d == 0) return 'Due today';
  if (d == 1) return 'Due tomorrow';
  if (d > 1) return '$d days left';
  if (d == -1) return 'Expired yesterday';
  return 'Expired ${-d} days ago';
}

/// Notification text for an alert [offsetDays] before the due date.
String reminderBody(String title, int offsetDays) {
  if (offsetDays > 1) {
    if (offsetDays == 7) return '🔔 $title expires next week';
    if (offsetDays == 14) return '⚠️ $title expires in 2 weeks';
    return '⚠️ $title expires in $offsetDays days';
  }
  if (offsetDays == 1) return '🚨 $title expires tomorrow';
  if (offsetDays == 0) return '🚨 $title expires today';
  if (offsetDays == -1) return '❗ $title expired yesterday';
  return '❗ $title expired ${-offsetDays} days ago';
}

/// Everything the engine needs to know about an item.
class ReminderInput {
  const ReminderInput({
    required this.itemId,
    required this.title,
    required this.dueDate,
    this.offsets,
    this.notifyMinutes,
    this.snoozedUntil,
    this.active = true,
  });

  final String itemId;
  final String title;
  final DateTime? dueDate;
  final List<int>? offsets; // null = profile default
  final int? notifyMinutes; // null = profile default
  final DateTime? snoozedUntil; // instant
  final bool active;
}

/// One notification that should exist on the device.
class ReminderInstance {
  const ReminderInstance({
    required this.key,
    required this.itemId,
    required this.fireAt,
    required this.title,
    required this.body,
    required this.offsetDays,
  });

  /// Deterministic idempotency key: itemId:yyyy-mm-dd:offset (or :snooze).
  final String key;
  final String itemId;
  final tz.TZDateTime fireAt;
  final String title;
  final String body;
  final int? offsetDays; // null for a snooze alert

  @override
  String toString() => 'ReminderInstance($key @ $fireAt)';
}

String formatDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String instanceKey(String itemId, DateTime due, int offsetDays) =>
    '$itemId:${formatDate(due)}:$offsetDays';

/// All future alerts for one item, in [location]'s local time.
List<ReminderInstance> instancesFor(
  ReminderInput item, {
  required DateTime now,
  required tz.Location location,
  List<int> fallbackOffsets = defaultOffsets,
  int fallbackNotifyMinutes = defaultNotifyMinutes,
}) {
  final due = item.dueDate;
  if (!item.active || due == null) return const [];

  final minutes = item.notifyMinutes ?? fallbackNotifyMinutes;
  final offsets = (item.offsets ?? fallbackOffsets).toSet().toList()
    ..sort((a, b) => b.compareTo(a));
  final snoozed = item.snoozedUntil;
  final out = <ReminderInstance>[];

  for (final offset in offsets) {
    final day = dateOnly(due).subtract(Duration(days: offset));
    final fireAt = tz.TZDateTime(
        location, day.year, day.month, day.day, minutes ~/ 60, minutes % 60);
    if (!fireAt.isAfter(now)) continue;
    if (snoozed != null && fireAt.isBefore(snoozed)) continue;
    out.add(ReminderInstance(
      key: instanceKey(item.itemId, due, offset),
      itemId: item.itemId,
      fireAt: fireAt,
      title: item.title,
      body: reminderBody(item.title, offset),
      offsetDays: offset,
    ));
  }

  if (snoozed != null && snoozed.isAfter(now)) {
    out.add(ReminderInstance(
      key: '${item.itemId}:${formatDate(due)}:snooze',
      itemId: item.itemId,
      fireAt: tz.TZDateTime.from(snoozed, location),
      title: item.title,
      body: '⏰ Reminder: ${countdownLabel(due, tz.TZDateTime.from(snoozed, location))} for ${item.title}',
      offsetDays: null,
    ));
  }
  out.sort((a, b) => a.fireAt.compareTo(b.fireAt));
  return out;
}

/// Alerts for every item, nearest first, capped at [limit]. iOS keeps at most
/// 64 pending notifications per app, Android ~500, so we only book the nearest
/// ones and a daily job tops up the rest.
List<ReminderInstance> planSchedule(
  Iterable<ReminderInput> items, {
  required DateTime now,
  required tz.Location location,
  required int limit,
  List<int> fallbackOffsets = defaultOffsets,
  int fallbackNotifyMinutes = defaultNotifyMinutes,
}) {
  final all = <ReminderInstance>[
    for (final item in items)
      ...instancesFor(item,
          now: now,
          location: location,
          fallbackOffsets: fallbackOffsets,
          fallbackNotifyMinutes: fallbackNotifyMinutes),
  ]..sort((a, b) => a.fireAt.compareTo(b.fireAt));
  return all.take(limit).toList();
}

/// What has to change on the device to go from [scheduled] to [desired].
class ScheduleDiff {
  const ScheduleDiff({required this.toCancel, required this.toSchedule});

  /// OS notification ids to cancel.
  final List<int> toCancel;
  final List<ReminderInstance> toSchedule;

  bool get isEmpty => toCancel.isEmpty && toSchedule.isEmpty;
}

/// [scheduled] maps instance key → (OS id, fire time, body) of what is booked now.
/// An instance whose time or text changed is cancelled and booked again.
ScheduleDiff diffSchedule(
  List<ReminderInstance> desired,
  Map<String, ({int osId, DateTime fireAt, String body})> scheduled,
) {
  final desiredByKey = {for (final d in desired) d.key: d};
  final toCancel = <int>[];
  final toSchedule = <ReminderInstance>[];

  scheduled.forEach((key, s) {
    final want = desiredByKey[key];
    if (want == null ||
        !want.fireAt.isAtSameMomentAs(s.fireAt) ||
        want.body != s.body) {
      toCancel.add(s.osId);
    }
  });
  for (final d in desired) {
    final s = scheduled[d.key];
    if (s == null || !d.fireAt.isAtSameMomentAs(s.fireAt) || d.body != s.body) {
      toSchedule.add(d);
    }
  }
  return ScheduleDiff(toCancel: toCancel, toSchedule: toSchedule);
}
