import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_services.dart';
import '../../data/local/database.dart';
import '../../domain/categories.dart';
import '../../domain/reminder_engine.dart';
import '../../widgets/item_tile.dart';

enum ItemSort { dueDate, recentlyAdded, title }

/// Search, filter and sort, all on the phone. Pure so it can be unit tested.
List<Item> filterItems(
  List<Item> items, {
  String query = '',
  String? categoryParent,
  DueStatus? status,
  String? memberId,
  bool showArchived = false,
  ItemSort sort = ItemSort.dueDate,
  required DateTime today,
}) {
  final q = query.trim().toLowerCase();
  final out = items.where((i) {
    if (!showArchived && i.archived) return false;
    if (q.isNotEmpty &&
        !i.title.toLowerCase().contains(q) &&
        !(i.provider?.toLowerCase().contains(q) ?? false) &&
        !(i.referenceNo?.toLowerCase().contains(q) ?? false) &&
        !(i.notes?.toLowerCase().contains(q) ?? false)) {
      return false;
    }
    if (categoryParent != null) {
      final parent = i.categoryKey.startsWith('custom:') ? 'custom' : i.categoryKey.split('.').first;
      if (parent != categoryParent) return false;
    }
    if (status != null && statusFor(i.dueDate, today) != status) return false;
    if (memberId != null && i.familyMemberId != memberId) return false;
    return true;
  }).toList();

  switch (sort) {
    case ItemSort.dueDate:
      out.sort((a, b) {
        if (a.dueDate == null) return b.dueDate == null ? 0 : 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
    case ItemSort.recentlyAdded:
      out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    case ItemSort.title:
      out.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
  }
  return out;
}

class AllItemsScreen extends ConsumerStatefulWidget {
  const AllItemsScreen({super.key});

  @override
  ConsumerState<AllItemsScreen> createState() => _AllItemsScreenState();
}

class _AllItemsScreenState extends ConsumerState<AllItemsScreen> {
  final _search = TextEditingController();
  String? _category;
  DueStatus? _status;
  String? _member;
  bool _archived = false;
  ItemSort _sort = ItemSort.dueDate;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(allItemsProvider).value ?? const <Item>[];
    final family = ref.watch(familyProvider).value ?? const [];
    final customNames = {for (final c in ref.watch(customCategoriesProvider).value ?? const <CustomCategory>[]) c.id: c.name};
    final today = todayDate();
    final items = filterItems(all,
        query: _search.text,
        categoryParent: _category,
        status: _status,
        memberId: _member,
        showArchived: _archived,
        sort: _sort,
        today: today);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All items'),
        actions: [
          PopupMenuButton<ItemSort>(
            tooltip: 'Sort',
            icon: const Icon(Icons.sort),
            initialValue: _sort,
            onSelected: (s) => setState(() => _sort = s),
            itemBuilder: (_) => const [
              PopupMenuItem(value: ItemSort.dueDate, child: Text('By expiry date')),
              PopupMenuItem(value: ItemSort.recentlyAdded, child: Text('Recently added')),
              PopupMenuItem(value: ItemSort.title, child: Text('By name')),
            ],
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          // A plain TextField rather than SearchBar: SearchBar's tap area has
          // no label for TalkBack.
          child: TextField(
            key: const Key('searchField'),
            controller: _search,
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search name, provider, policy no.',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(_search.clear)),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _dropdownChip<String>(
                label: _category == null ? 'Category' : builtInCategories.firstWhere((c) => c.key == _category).name,
                selected: _category != null,
                options: {for (final c in builtInCategories) c.key: '${c.emoji} ${c.name}'},
                onSelected: (v) => setState(() => _category = v),
              ),
              _dropdownChip<DueStatus>(
                label: _status == null ? 'Status' : statusLabel(_status!),
                selected: _status != null,
                options: {for (final s in DueStatus.values) s: statusLabel(s)},
                onSelected: (v) => setState(() => _status = v),
              ),
              if (family.isNotEmpty)
                _dropdownChip<String>(
                  label: _member == null ? 'Person' : family.firstWhere((f) => f.id == _member).name,
                  selected: _member != null,
                  options: {for (final f in family) f.id: f.name},
                  onSelected: (v) => setState(() => _member = v),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: const Text('Archived'),
                  selected: _archived,
                  onSelected: (v) => setState(() => _archived = v),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const EmptyState(icon: Icons.search_off, title: 'No items match')
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: items.length,
                  itemBuilder: (_, i) => ItemTile(item: items[i], today: today, customNames: customNames),
                ),
        ),
      ]),
    );
  }

  Widget _dropdownChip<T>({
    required String label,
    required bool selected,
    required Map<T, String> options,
    required ValueChanged<T?> onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: PopupMenuButton<T?>(
        onSelected: onSelected,
        itemBuilder: (_) => [
          PopupMenuItem<T?>(value: null, child: const Text('Any')),
          for (final e in options.entries) PopupMenuItem<T?>(value: e.key, child: Text(e.value)),
        ],
        child: Chip(
          label: Text(label),
          avatar: Icon(Icons.arrow_drop_down, color: selected ? Theme.of(context).colorScheme.primary : null),
          backgroundColor: selected ? Theme.of(context).colorScheme.secondaryContainer : null,
        ),
      ),
    );
  }
}
