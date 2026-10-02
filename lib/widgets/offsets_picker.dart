import 'package:flutter/material.dart';

import '../core/format.dart';

const presetOffsets = <int>[90, 60, 30, 14, 7, 3, 1, 0, -1];

/// Checkboxes for "remind me N days before", plus "Add custom".
class OffsetsPicker extends StatelessWidget {
  const OffsetsPicker({super.key, required this.value, required this.onChanged});

  final List<int> value;
  final ValueChanged<List<int>> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = {...presetOffsets, ...value}.toList()..sort((a, b) => b.compareTo(a));
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final d in options)
          FilterChip(
            label: Text(offsetLabel(d)),
            selected: value.contains(d),
            onSelected: (on) {
              final next = {...value};
              on ? next.add(d) : next.remove(d);
              onChanged(next.toList()..sort((a, b) => b.compareTo(a)));
            },
          ),
        ActionChip(
          avatar: const Icon(Icons.add, size: 18),
          label: const Text('Custom'),
          onPressed: () async {
            final d = await _askDays(context);
            if (d != null) onChanged(({...value, d}.toList()..sort((a, b) => b.compareTo(a))));
          },
        ),
      ],
    );
  }

  Future<int?> _askDays(BuildContext context) {
    final controller = TextEditingController();
    var after = false;
    return showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Custom reminder'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Days'),
            ),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Before')),
                ButtonSegment(value: true, label: Text('After')),
              ],
              selected: {after},
              onSelectionChanged: (s) => setState(() => after = s.first),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final n = int.tryParse(controller.text.trim());
                if (n == null || n < 0 || n > 365) return;
                Navigator.pop(ctx, after ? -n : n);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
