import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../app_services.dart';
import '../../core/format.dart';
import '../../data/local/database.dart';
import '../../domain/reminder_engine.dart';
import '../../widgets/item_tile.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focused = DateTime.now();
  DateTime _selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(itemsProvider).value ?? const <Item>[];
    final byDay = <DateTime, List<Item>>{};
    for (final i in items) {
      if (i.dueDate != null) byDay.putIfAbsent(dateOnly(i.dueDate!), () => []).add(i);
    }
    final selectedItems = byDay[dateOnly(_selected)] ?? const <Item>[];
    final today = todayDate();

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(children: [
        TableCalendar<Item>(
          firstDay: DateTime.utc(2000),
          lastDay: DateTime.utc(2100),
          focusedDay: _focused,
          startingDayOfWeek: StartingDayOfWeek.monday,
          availableCalendarFormats: const {CalendarFormat.month: 'Month'},
          // Labels so TalkBack reads the month arrows.
          headerStyle: const HeaderStyle(
            leftChevronIcon: Icon(Icons.chevron_left, semanticLabel: 'Previous month'),
            rightChevronIcon: Icon(Icons.chevron_right, semanticLabel: 'Next month'),
          ),
          selectedDayPredicate: (d) => isSameDay(d, _selected),
          eventLoader: (d) => byDay[dateOnly(d)] ?? const [],
          onDaySelected: (selected, focused) => setState(() {
            _selected = selected;
            _focused = focused;
          }),
          onPageChanged: (f) => _focused = f,
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(fmtDate(_selected), style: Theme.of(context).textTheme.titleSmall),
          ),
        ),
        Expanded(
          child: selectedItems.isEmpty
              ? const EmptyState(icon: Icons.event_busy, title: 'Nothing due on this day')
              : ListView(
                  padding: const EdgeInsets.only(bottom: 96),
                  children: [for (final i in selectedItems) ItemTile(item: i, today: today)],
                ),
        ),
      ]),
    );
  }
}
