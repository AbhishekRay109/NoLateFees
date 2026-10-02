import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_services.dart';
import '../../data/local/database.dart';
import '../../widgets/item_tile.dart';

const _relations = <String, String>{
  'self': '🙂 Me',
  'spouse': '💑 Spouse',
  'parent': '👴 Parent',
  'child': '🧒 Child',
  'vehicle': '🚗 Vehicle',
  'other': '👤 Other',
};

class FamilyScreen extends ConsumerWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final family = ref.watch(familyProvider).value ?? const <FamilyMember>[];
    final repo = ref.watch(repoProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Family & vehicles')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add',
        onPressed: () => _edit(context, ref, null),
        child: const Icon(Icons.add),
      ),
      body: family.isEmpty
          ? const EmptyState(
              icon: Icons.family_restroom,
              title: 'No one added yet',
              message: 'Add family members or vehicles, then pick who an item belongs to.',
            )
          : ListView(children: [
              for (final f in family)
                ListTile(
                  leading: Text(f.emoji ?? '👤', style: const TextStyle(fontSize: 28)),
                  title: Text(f.name),
                  subtitle: Text(_relations[f.relation]?.substring(3) ?? ''),
                  onTap: () => _edit(context, ref, f),
                  trailing: IconButton(
                    tooltip: 'Remove',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => repo.deleteFamilyMember(f.id),
                  ),
                ),
            ]),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, FamilyMember? existing) async {
    final name = TextEditingController(text: existing?.name ?? '');
    var relation = existing?.relation ?? 'parent';
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(existing == null ? 'Add person or vehicle' : 'Edit'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, autofocus: true, decoration: const InputDecoration(labelText: 'Name (e.g. Dad, Bike)')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: relation,
              decoration: const InputDecoration(labelText: 'Type'),
              items: [for (final e in _relations.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
              onChanged: (v) => setState(() => relation = v!),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
          ],
        ),
      ),
    );
    if (result != true || name.text.trim().isEmpty) return;
    await ref.read(repoProvider).saveFamilyMember(
          id: existing?.id,
          name: name.text,
          relation: relation,
          emoji: _relations[relation]!.split(' ').first,
        );
  }
}
