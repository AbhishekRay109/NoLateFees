import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_services.dart';
import '../../data/local/database.dart';
import '../../domain/reminder_engine.dart';
import '../../widgets/item_tile.dart';

/// Groups items into dashboard sections, in display order. Pure, so it is
/// unit tested.
Map<DueStatus, List<Item>> groupByStatus(List<Item> items, DateTime today) {
  final groups = {for (final s in DueStatus.values) s: <Item>[]};
  for (final i in items) {
    groups[statusFor(i.dueDate, today)]!.add(i);
  }
  groups.removeWhere((_, v) => v.isEmpty);
  return groups;
}

/// "Things to renew": overdue + anything due in the next 30 days.
int needsAttention(List<Item> items, DateTime today) => items.where((i) {
      final s = statusFor(i.dueDate, today);
      return s != DueStatus.upcoming && s != DueStatus.noDate;
    }).length;

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String? _member; // null = everything

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemsProvider);
    final family = ref.watch(familyProvider).value ?? const [];
    final name = ref.watch(profileProvider).value?.displayName;
    final customNames = {for (final c in ref.watch(customCategoriesProvider).value ?? const <CustomCategory>[]) c.id: c.name};
    final today = todayDate();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: itemsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => const EmptyState(icon: Icons.error_outline, title: 'Could not load your reminders'),
          data: (all) {
            final items = _member == null ? all : all.where((i) => i.familyMemberId == _member).toList();
            final groups = groupByStatus(items, today);
            final count = needsAttention(items, today);
            return RefreshIndicator(
              onRefresh: () async => ref.read(servicesProvider).sync?.run().catchError((_) {}),
              child: ListView(
                padding: const EdgeInsets.only(bottom: 96),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Text('${_greeting()}${name == null ? '' : ', $name'} 👋',
                        style: theme.textTheme.titleMedium),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('$count', style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(count == 1 ? 'thing to renew\nin the next 30 days' : 'things to renew\nin the next 30 days'),
                      ),
                    ]),
                  ),
                  if (family.isNotEmpty)
                    SizedBox(
                      height: 56,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        children: [
                          _chip('Everything', null),
                          for (final f in family) _chip('${f.emoji ?? ''} ${f.name}'.trim(), f.id),
                        ],
                      ),
                    ),
                  if (items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 48),
                      child: EmptyState(
                        icon: Icons.event_available,
                        title: 'Nothing to track yet',
                        message: 'Tap "Add Reminder" to add your first insurance, recharge, document or bill.',
                      ),
                    ),
                  for (final entry in groups.entries) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                      child: Text(
                        statusLabel(entry.key).toUpperCase(),
                        style: theme.textTheme.labelLarge?.copyWith(
                            color: statusColor(context, entry.key), letterSpacing: 1.1),
                      ),
                    ),
                    for (final item in entry.value)
                      ItemTile(item: item, today: today, customNames: customNames),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _chip(String label, String? id) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: _member == id,
          onSelected: (_) => setState(() => _member = id),
        ),
      );
}
