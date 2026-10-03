import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_services.dart';
import '../../core/theme.dart';
import '../../data/local/database.dart';
import '../../domain/reminder_engine.dart';
import '../../widgets/brand.dart';
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
                  _Hero(
                    greeting: '${_greeting()}${name == null ? '' : ', ${name.split(' ').first}'} 👋',
                    renew: count,
                    overdue: items.where((i) => statusFor(i.dueDate, today) == DueStatus.overdue).length,
                    total: items.length,
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
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
                      child: Row(children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(color: statusColor(context, entry.key), shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          statusLabel(entry.key).toUpperCase(),
                          style: theme.textTheme.labelLarge?.copyWith(
                              color: statusColor(context, entry.key), letterSpacing: 1.1, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(width: 6),
                        Text('${entry.value.length}', style: theme.textTheme.labelMedium),
                      ]),
                    ),
                    for (final (i, item) in entry.value.indexed)
                      ItemTile(key: ValueKey(item.id), item: item, today: today, customNames: customNames)
                          .animate(key: ValueKey('a-${item.id}'))
                          .fadeIn(delay: (40 * i).ms, duration: 300.ms)
                          .slideY(begin: 0.12, curve: Curves.easeOut),
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
          selectedColor: Brand.pink.withValues(alpha: 0.2),
          onSelected: (_) => setState(() => _member = id),
        ),
      );
}

class _Hero extends StatelessWidget {
  const _Hero({required this.greeting, required this.renew, required this.overdue, required this.total});
  final String greeting;
  final int renew;
  final int overdue;
  final int total;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        decoration: BoxDecoration(
          gradient: Brand.gradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: Brand.violet.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 10))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(greeting,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            const BrandLogo(size: 36),
          ]),
          const SizedBox(height: 4),
          Text(
            renew == 0 ? 'You\'re all caught up. Nice!' : 'Here\'s what needs you soon.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 16),
          Row(children: [
            _Stat(key: const Key('statRenew'), value: renew, label: 'To renew\nin 30 days', emoji: '⏳'),
            const SizedBox(width: 10),
            _Stat(key: const Key('statOverdue'), value: overdue, label: 'Overdue\nnow', emoji: '🔥'),
            const SizedBox(width: 10),
            _Stat(key: const Key('statTotal'), value: total, label: 'Tracking\nin total', emoji: '📋'),
          ]),
        ]),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.08, curve: Curves.easeOut);
}

class _Stat extends StatelessWidget {
  const _Stat({super.key, required this.value, required this.label, required this.emoji});
  final int value;
  final String label;
  final String emoji;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value.toDouble()),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (_, v, _) => Text('${v.round()}',
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
            ),
            Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11.5, height: 1.2)),
          ]),
        ),
      );
}
