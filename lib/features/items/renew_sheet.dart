import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_services.dart';
import '../../core/format.dart';
import '../../data/local/database.dart';
import '../../domain/reminder_engine.dart';

Future<void> showRenewSheet(BuildContext context, Item item) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => RenewSheet(item: item),
    );

class RenewSheet extends ConsumerStatefulWidget {
  const RenewSheet({super.key, required this.item});
  final Item item;

  @override
  ConsumerState<RenewSheet> createState() => _RenewSheetState();
}

class _RenewSheetState extends ConsumerState<RenewSheet> {
  late DateTime? _newDue;
  late final TextEditingController _amount, _provider, _notes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final i = widget.item;
    final base = i.dueDate ?? dateOnly(DateTime.now());
    _newDue = i.recurrenceUnit == RecurrenceUnit.none ? null : nextDueDate(base, i.recurrenceUnit, i.recurrenceEvery);
    _amount = TextEditingController(
        text: i.amountMinor == null ? '' : (i.amountMinor! / 100).toStringAsFixed(i.amountMinor! % 100 == 0 ? 0 : 2));
    _provider = TextEditingController(text: i.provider ?? '');
    _notes = TextEditingController();
  }

  @override
  void dispose() {
    _amount.dispose();
    _provider.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _newDue ?? now.add(const Duration(days: 365)),
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 30),
      helpText: 'New expiry date',
    );
    if (d != null) setState(() => _newDue = dateOnly(d));
  }

  Future<void> _save() async {
    if (_newDue == null) return _pick();
    setState(() => _saving = true);
    await ref.read(repoProvider).renew(
          widget.item.id,
          newDue: _newDue!,
          amountMinor: parseMoney(_amount.text),
          provider: _provider.text,
          notes: _notes.text,
        );
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Renewed. Next expiry ${fmtDate(_newDue!)}, reminders updated.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final i = widget.item;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Renew ${i.title}', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          if (i.dueDate != null) Text('Previous expiry: ${fmtDate(i.dueDate!)}'),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pick,
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'New expiry', suffixIcon: Icon(Icons.event)),
              child: Text(_newDue == null ? 'Pick a date' : fmtDate(_newDue!)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amount,
            decoration: const InputDecoration(labelText: 'Amount paid'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          TextField(controller: _provider, decoration: const InputDecoration(labelText: 'Provider')),
          const SizedBox(height: 12),
          TextField(controller: _notes, decoration: const InputDecoration(labelText: 'Notes')),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: const Text('Save renewal'),
          ),
        ],
      ),
    );
  }
}
