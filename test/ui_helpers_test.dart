// Small pure helpers behind the colourful UI and formatting.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nolatefees/core/format.dart';
import 'package:nolatefees/core/theme.dart';
import 'package:nolatefees/domain/categories.dart';
import 'package:nolatefees/domain/reminder_engine.dart';
import 'package:nolatefees/widgets/item_tile.dart';

void main() {
  final today = DateTime.utc(2026, 10, 3);

  group('countdown ring', () {
    test('full at 30+ days, empty when due or overdue, proportional between', () {
      expect(ringFraction(DateTime.utc(2026, 12, 31), today), 1.0);
      expect(ringFraction(DateTime.utc(2026, 11, 2), today), 1.0);
      expect(ringFraction(DateTime.utc(2026, 10, 18), today), closeTo(0.5, 1e-9));
      expect(ringFraction(today, today), 0.0);
      expect(ringFraction(DateTime.utc(2026, 9, 1), today), 0.0);
      expect(ringFraction(null, today), 1.0);
    });
  });

  group('category colours', () {
    test('every built-in category has its own colour', () {
      final colours = {for (final c in builtInCategories) c.key: categoryColor('${c.key}.x')};
      final named = colours.entries.where((e) => e.key != 'custom').map((e) => e.value).toSet();
      expect(named, hasLength(builtInCategories.length - 1));
    });

    test('sub-categories share their parent colour; custom ones get teal', () {
      expect(categoryColor('vehicle.puc'), categoryColor('vehicle.insurance'));
      expect(categoryColor('custom:1234'), const Color(0xFF14B8A6));
      expect(categoryColor('unknown.thing'), const Color(0xFF64748B));
    });
  });

  group('themes', () {
    test('light and dark themes use the brand colours', () {
      final light = buildTheme(Brightness.light);
      final dark = buildTheme(Brightness.dark);
      expect(light.colorScheme.brightness, Brightness.light);
      expect(dark.colorScheme.brightness, Brightness.dark);
      expect(light.floatingActionButtonTheme.backgroundColor, Brand.pink);
      expect(Brand.gradient.colors.first, Brand.indigo);
    });
  });

  group('labels', () {
    test('status labels cover every bucket', () {
      expect(DueStatus.values.map(statusLabel).toSet(), hasLength(DueStatus.values.length));
    });

    test('countdown wording at the edges', () {
      expect(countdownLabel(DateTime.utc(2026, 10, 4), today), 'Due tomorrow');
      expect(countdownLabel(DateTime.utc(2026, 10, 2), today), 'Expired yesterday');
      expect(countdownLabel(DateTime.utc(2027, 10, 3), today), '365 days left');
    });

    test('notification wording for each offset', () {
      expect(reminderBody('PUC', 30), '⚠️ PUC expires in 30 days');
      expect(reminderBody('PUC', 14), '⚠️ PUC expires in 2 weeks');
      expect(reminderBody('PUC', 7), '🔔 PUC expires next week');
      expect(reminderBody('PUC', 1), '🚨 PUC expires tomorrow');
      expect(reminderBody('PUC', 0), '🚨 PUC expires today');
      expect(reminderBody('PUC', -1), '❗ PUC expired yesterday');
      expect(reminderBody('PUC', -3), '❗ PUC expired 3 days ago');
    });

    test('offset labels', () {
      expect(offsetLabel(0), 'On the day');
      expect(offsetLabel(1), '1 day before');
      expect(offsetLabel(-1), '1 day after');
      expect(offsetLabel(30), '30 days before');
      expect(offsetLabel(-5), '5 days after');
    });
  });

  group('money', () {
    test('parseMoney accepts rupee symbols, commas and decimals', () {
      expect(parseMoney('₹12,450'), 1245000);
      expect(parseMoney('1250.50'), 125050);
      expect(parseMoney('0.1'), 10);
      expect(parseMoney(''), isNull);
      expect(parseMoney('abc'), isNull);
    });

    test('fmtMoney uses Indian grouping for INR', () {
      expect(fmtMoney(1245000, 'INR'), '₹12,450.00');
      expect(fmtMoney(123456789, 'INR'), '₹12,34,567.89');
      expect(fmtMoney(1999, 'USD'), '\$19.99');
    });
  });

  group('categories', () {
    test('names and emojis resolve for built-in, custom and unknown keys', () {
      expect(categoryName('vehicle.puc'), 'PUC');
      expect(categoryName('vehicle'), 'Vehicle');
      expect(categoryName('custom:abc', {'abc': 'Pet vaccine'}), 'Pet vaccine');
      expect(categoryName('custom:missing'), 'Custom');
      expect(categoryEmoji('documents.passport'), '📄');
      expect(categoryEmoji('custom:abc'), '✏️');
      expect(categoryEmoji('nope'), '📌');
    });

    test('every sub-category key starts with its parent key', () {
      for (final c in builtInCategories) {
        for (final s in c.children) {
          expect(s.key.startsWith('${c.key}.'), isTrue, reason: s.key);
          expect(parentOf(s.key), same(c));
        }
      }
    });
  });

  group('recurrence edge cases', () {
    test('leap day renewals land on 28 Feb in normal years and back on 29 Feb', () {
      expect(addRecurrence(DateTime.utc(2028, 2, 29), RecurrenceUnit.year, 1), DateTime.utc(2029, 2, 28));
      expect(addRecurrence(DateTime.utc(2028, 2, 29), RecurrenceUnit.year, 4), DateTime.utc(2032, 2, 29));
    });

    test('31st monthly renewals clamp but do not drift', () {
      final jan31 = DateTime.utc(2027, 1, 31);
      expect(addRecurrence(jan31, RecurrenceUnit.month, 1), DateTime.utc(2027, 2, 28));
      expect(addRecurrence(jan31, RecurrenceUnit.month, 2), DateTime.utc(2027, 3, 31));
      expect(addRecurrence(jan31, RecurrenceUnit.month, 3), DateTime.utc(2027, 4, 30));
    });

    test('status changes exactly at the 7 and 30 day boundaries', () {
      expect(statusFor(today.add(const Duration(days: 7)), today), DueStatus.next7);
      expect(statusFor(today.add(const Duration(days: 8)), today), DueStatus.next30);
      expect(statusFor(today.add(const Duration(days: 30)), today), DueStatus.next30);
      expect(statusFor(today.add(const Duration(days: 31)), today), DueStatus.upcoming);
    });
  });
}
