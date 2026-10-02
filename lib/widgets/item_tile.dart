import 'package:flutter/material.dart';

import '../core/format.dart';
import '../data/local/database.dart';
import '../domain/categories.dart';
import '../domain/reminder_engine.dart';
import '../features/items/item_detail_screen.dart';

Color statusColor(BuildContext context, DueStatus s) => switch (s) {
      DueStatus.overdue => Theme.of(context).colorScheme.error,
      DueStatus.today => Colors.deepOrange,
      DueStatus.next7 => Colors.orange.shade700,
      DueStatus.next30 => Colors.amber.shade800,
      DueStatus.upcoming => Colors.green.shade600,
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
    final subtitle = [
      categoryName(item.categoryKey, customNames),
      if (due != null) fmtDate(due),
      if (item.amountMinor != null) fmtMoney(item.amountMinor!, item.currency),
    ].join(' · ');

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Text(categoryEmoji(item.categoryKey), style: const TextStyle(fontSize: 20)),
      ),
      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: due == null
          ? null
          : Semantics(
              label: countdownLabel(due, today),
              child: Text(
                countdownLabel(due, today),
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ),
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => ItemDetailScreen(itemId: item.id))),
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
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.outline),
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
