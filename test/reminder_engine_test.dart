import 'package:duemate/domain/reminder_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  late tz.Location kolkata;

  setUpAll(() {
    tzdata.initializeTimeZones();
    kolkata = tz.getLocation('Asia/Kolkata');
  });

  ReminderInput item({DateTime? due, List<int>? offsets, int? minutes, DateTime? snoozed, bool active = true}) =>
      ReminderInput(
        itemId: 'car',
        title: 'Car Insurance',
        dueDate: due ?? DateTime.utc(2026, 11, 30),
        offsets: offsets,
        notifyMinutes: minutes,
        snoozedUntil: snoozed,
        active: active,
      );

  group('instancesFor', () {
    test('spec example: 30 Nov 2026 with 30,14,7,3,1,0,-1 at 09:00', () {
      final out = instancesFor(item(), now: DateTime.utc(2026, 10, 1), location: kolkata);
      expect(out.map((r) => formatDate(r.fireAt)).toList(), [
        '2026-10-31',
        '2026-11-16',
        '2026-11-23',
        '2026-11-27',
        '2026-11-29',
        '2026-11-30',
        '2026-12-01',
      ]);
      for (final r in out) {
        expect((r.fireAt.hour, r.fireAt.minute), (9, 0));
        expect(r.fireAt.location, kolkata);
      }
      // 09:00 IST is 03:30 UTC.
      expect(out.first.fireAt.toUtc(), DateTime.utc(2026, 10, 31, 3, 30));
    });

    test('uses per-item offsets and time when set', () {
      final out = instancesFor(item(offsets: [90, 60, 1], minutes: 18 * 60 + 30),
          now: DateTime.utc(2026, 1, 1), location: kolkata);
      expect(out.map((r) => r.offsetDays), [90, 60, 1]);
      expect(out.last.fireAt.hour, 18);
      expect(out.last.fireAt.minute, 30);
    });

    test('drops alerts that are already in the past', () {
      final now = tz.TZDateTime(kolkata, 2026, 11, 28, 12);
      final out = instancesFor(item(), now: now, location: kolkata);
      expect(out.map((r) => r.offsetDays), [1, 0, -1]);
    });

    test('nothing for archived items or items with no date', () {
      expect(instancesFor(item(active: false), now: DateTime.utc(2026), location: kolkata), isEmpty);
      expect(
          instancesFor(const ReminderInput(itemId: 'x', title: 'x', dueDate: null),
              now: DateTime.utc(2026), location: kolkata),
          isEmpty);
    });

    test('snooze skips alerts before it and adds one at the snooze time', () {
      final snoozed = tz.TZDateTime(kolkata, 2026, 11, 29, 10).toUtc();
      final now = tz.TZDateTime(kolkata, 2026, 11, 28, 10);
      final out = instancesFor(item(snoozed: snoozed), now: now, location: kolkata);
      expect(out.first.key, 'car:2026-11-30:snooze');
      expect(out.first.fireAt.isAtSameMomentAs(snoozed), isTrue);
      expect(out.skip(1).map((r) => r.offsetDays), [0, -1]); // the 29th 09:00 alert is skipped
    });

    test('keys are deterministic and change when the due date changes', () {
      final a = instancesFor(item(), now: DateTime.utc(2026), location: kolkata);
      final b = instancesFor(item(), now: DateTime.utc(2026), location: kolkata);
      expect(a.map((r) => r.key), b.map((r) => r.key));
      expect(a.first.key, 'car:2026-11-30:30');
      final renewed = instancesFor(item(due: DateTime.utc(2027, 11, 30)), now: DateTime.utc(2026), location: kolkata);
      expect(renewed.first.key, 'car:2027-11-30:30');
    });

    test('duplicate offsets produce one alert', () {
      final out = instancesFor(item(offsets: [7, 7, 1]), now: DateTime.utc(2026), location: kolkata);
      expect(out.length, 2);
    });

    test('respects DST in zones that have it', () {
      final ny = tz.getLocation('America/New_York');
      // US DST ends 1 Nov 2026; both alerts still at 09:00 local.
      final out = instancesFor(item(due: DateTime.utc(2026, 11, 3), offsets: [3, 1]),
          now: DateTime.utc(2026, 10, 1), location: ny);
      expect(out.map((r) => r.fireAt.hour), [9, 9]);
      expect(out[0].fireAt.toUtc().hour, 13); // EDT, UTC-4
      expect(out[1].fireAt.toUtc().hour, 14); // EST, UTC-5
    });
  });

  group('addRecurrence', () {
    test('yearly, monthly, quarterly, weekly, daily', () {
      final d = DateTime.utc(2026, 11, 30);
      expect(addRecurrence(d, RecurrenceUnit.year, 1), DateTime.utc(2027, 11, 30));
      expect(addRecurrence(d, RecurrenceUnit.month, 1), DateTime.utc(2026, 12, 30));
      expect(addRecurrence(d, RecurrenceUnit.month, 3), DateTime.utc(2027, 2, 28));
      expect(addRecurrence(d, RecurrenceUnit.week, 2), DateTime.utc(2026, 12, 14));
      expect(addRecurrence(d, RecurrenceUnit.day, 28), DateTime.utc(2026, 12, 28));
      expect(addRecurrence(d, RecurrenceUnit.none, 1), d);
    });

    test('clamps to month end', () {
      expect(addRecurrence(DateTime.utc(2026, 1, 31), RecurrenceUnit.month, 1), DateTime.utc(2026, 2, 28));
      expect(addRecurrence(DateTime.utc(2028, 1, 31), RecurrenceUnit.month, 1), DateTime.utc(2028, 2, 29));
      expect(addRecurrence(DateTime.utc(2028, 2, 29), RecurrenceUnit.year, 1), DateTime.utc(2029, 2, 28));
      expect(addRecurrence(DateTime.utc(2026, 8, 31), RecurrenceUnit.month, 6), DateTime.utc(2027, 2, 28));
    });

    test('crosses years', () {
      expect(addRecurrence(DateTime.utc(2026, 12, 15), RecurrenceUnit.month, 1), DateTime.utc(2027, 1, 15));
      expect(addRecurrence(DateTime.utc(2026, 11, 15), RecurrenceUnit.month, 14), DateTime.utc(2028, 1, 15));
    });
  });

  group('status and labels', () {
    final today = DateTime.utc(2026, 11, 20);
    test('statusFor buckets', () {
      expect(statusFor(null, today), DueStatus.noDate);
      expect(statusFor(DateTime.utc(2026, 11, 18), today), DueStatus.overdue);
      expect(statusFor(today, today), DueStatus.today);
      expect(statusFor(DateTime.utc(2026, 11, 27), today), DueStatus.next7);
      expect(statusFor(DateTime.utc(2026, 11, 28), today), DueStatus.next30);
      expect(statusFor(DateTime.utc(2026, 12, 20), today), DueStatus.next30);
      expect(statusFor(DateTime.utc(2026, 12, 21), today), DueStatus.upcoming);
    });

    test('countdown and notification text', () {
      expect(countdownLabel(DateTime.utc(2026, 11, 25), today), '5 days left');
      expect(countdownLabel(DateTime.utc(2026, 11, 21), today), 'Due tomorrow');
      expect(countdownLabel(today, today), 'Due today');
      expect(countdownLabel(DateTime.utc(2026, 11, 18), today), 'Expired 2 days ago');
      expect(reminderBody('Passport', 30), '⚠️ Passport expires in 30 days');
      expect(reminderBody('Passport', 1), '🚨 Passport expires tomorrow');
      expect(reminderBody('Passport', 0), '🚨 Passport expires today');
      expect(reminderBody('Passport', -1), '❗ Passport expired yesterday');
    });
  });

  group('planSchedule and diffSchedule', () {
    test('keeps only the nearest alerts across items', () {
      final items = [
        for (var i = 0; i < 20; i++)
          ReminderInput(itemId: 'i$i', title: 'Item $i', dueDate: DateTime.utc(2027, 1, 1 + i)),
      ];
      final plan = planSchedule(items, now: DateTime.utc(2026, 1, 1), location: kolkata, limit: 60);
      expect(plan.length, 60); // 20 items × 7 alerts = 140, capped
      for (var i = 1; i < plan.length; i++) {
        expect(plan[i].fireAt.isBefore(plan[i - 1].fireAt), isFalse);
      }
    });

    test('diff books new, cancels removed, re-books changed', () {
      final now = DateTime.utc(2026, 1, 1);
      final desired = instancesFor(item(offsets: [7, 1]), now: now, location: kolkata);
      final scheduled = {
        desired[0].key: (osId: 1, fireAt: desired[0].fireAt.toUtc(), body: desired[0].body), // unchanged
        desired[1].key: (osId: 2, fireAt: desired[1].fireAt.toUtc().add(const Duration(hours: 1)), body: desired[1].body), // moved
        'gone:2026-01-01:0': (osId: 3, fireAt: DateTime.utc(2026, 6), body: 'x'), // deleted item
      };
      final diff = diffSchedule(desired, scheduled);
      expect(diff.toCancel..sort(), [2, 3]);
      expect(diff.toSchedule.map((r) => r.key), [desired[1].key]);
      expect(diffSchedule(desired, {
        for (final d in desired) d.key: (osId: 0, fireAt: d.fireAt.toUtc(), body: d.body),
      }).isEmpty, isTrue);
    });
  });
}
