import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../data/local/database.dart';
import '../domain/categories.dart';
import '../domain/reminder_engine.dart';
import '../features/items/item_detail_screen.dart';

Color statusColor(BuildContext context, DueStatus s) => switch (s) {
      DueStatus.overdue => Theme.of(context).colorScheme.error,
      DueStatus.today => const Color(0xFFF97316),
      DueStatus.next7 => const Color(0xFFF59E0B),
      DueStatus.next30 => const Color(0xFF8B5CF6),
      DueStatus.upcoming => const Color(0xFF10B981),
      DueStatus.noDate => Theme.of(context).colorScheme.outline,
    };

String statusLabel(DueStatus s) => switch (s) {
      DueStatus.overdue => 'Overdue',
      DueStatus.today => 'Due today',
      DueStatus.next7 => 'Next 7 days',
      DueStatus.next30 => 'Next 30 days',
      DueStatus.upcoming => 'Upcoming',
      DueStatus.noDate => 'No date',
    };

/// How full the countdown ring is: full at 30+ days left, empty when due.
double ringFraction(DateTime? due, DateTime today) {
  if (due == null) return 1;
  return (daysUntil(due, today) / 30).clamp(0.0, 1.0);
}

class ItemTile extends StatelessWidget {
  const ItemTile({super.key, required this.item, required this.today, this.customNames = const {}});

  final Item item;
  final DateTime today;
  final Map<String, String> customNames;

  @override
  Widget build(BuildContext context) {
    final due = item.dueDate;
    final status = statusFor(due, today);
    final color = statusColor(context, status);
    final catColor = categoryColor(item.categoryKey);
    final subtitle = [
      categoryName(item.categoryKey, customNames),
      if (due != null) fmtDate(due),
      if (item.amountMinor != null) fmtMoney(item.amountMinor!, item.currency),
    ].join(' · ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => ItemDetailScreen(itemId: item.id))),
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(width: 5, color: catColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                child: Row(children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: Stack(alignment: Alignment.center, children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: ringFraction(due, today)),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, _) => CircularProgressIndicator(
                          value: v,
                          strokeWidth: 3.5,
                          strokeCap: StrokeCap.round,
                          color: color,
                          backgroundColor: color.withValues(alpha: 0.15),
                        ),
                      ),
                      Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: catColor.withValues(alpha: 0.15), shape: BoxShape.circle),
                        child: Text(categoryEmoji(item.categoryKey), style: const TextStyle(fontSize: 19)),
                      ),
                    ]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                      Text(item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall),
                    ]),
                  ),
                  if (due != null)
                    Semantics(
                      label: countdownLabel(due, today),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          countdownLabel(due, today),
                          style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12.5),
                        ),
                      ),
                    ),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.message});
  final IconData icon;
  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Brand.indigo.withValues(alpha: 0.1)),
              child: ShaderMask(
                shaderCallback: (r) => Brand.gradient.createShader(r),
                child: Icon(icon, size: 48, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(message!, textAlign: TextAlign.center),
            ],
          ]),
        ),
      );
}

/// Today as a calendar date in the phone's timezone.
DateTime todayDate() => dateOnly(DateTime.now());
