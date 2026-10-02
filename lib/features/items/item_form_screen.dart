import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_services.dart';
import '../../core/format.dart';
import '../../data/backup/export_service.dart';
import '../../data/local/database.dart';
import '../../domain/categories.dart';
import '../../domain/reminder_engine.dart';
import '../../widgets/offsets_picker.dart';

/// Add (item == null) or edit an item.
class ItemFormScreen extends ConsumerStatefulWidget {
  const ItemFormScreen({super.key, this.item});
  final Item? item;

  @override
  ConsumerState<ItemFormScreen> createState() => _ItemFormScreenState();
}

/// Renewal choices shown as radio buttons: label → (unit, every).
const _recurrenceChoices = <String, (RecurrenceUnit, int)>{
  "Doesn't repeat": (RecurrenceUnit.none, 1),
  'Every month': (RecurrenceUnit.month, 1),
  'Every 3 months': (RecurrenceUnit.month, 3),
  'Every 6 months': (RecurrenceUnit.month, 6),
  'Every year': (RecurrenceUnit.year, 1),
};

class _ItemFormScreenState extends ConsumerState<ItemFormScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _title, _provider, _reference, _amount, _notes, _every;
  late String _categoryKey;
  DateTime? _due;
  late RecurrenceUnit _unit;
  late int _everyN;
  bool _customRecurrence = false;
  List<int>? _offsets; // null = profile default
  int? _notifyMinutes; // null = profile default
  String? _member;
  bool _titleEdited = false;
  bool _saving = false;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final i = widget.item;
    _title = TextEditingController(text: i?.title ?? '');
    _provider = TextEditingController(text: i?.provider ?? '');
    _reference = TextEditingController(text: i?.referenceNo ?? '');
    _amount = TextEditingController(
        text: i?.amountMinor == null ? '' : (i!.amountMinor! / 100).toStringAsFixed(i.amountMinor! % 100 == 0 ? 0 : 2));
    _notes = TextEditingController(text: i?.notes ?? '');
    _categoryKey = i?.categoryKey ?? 'vehicle.insurance';
    _due = i?.dueDate;
    _unit = i?.recurrenceUnit ?? suggestedRecurrence(_categoryKey);
    _everyN = i?.recurrenceEvery ?? 1;
    _every = TextEditingController(text: '$_everyN');
    _customRecurrence = !_recurrenceChoices.values.contains((_unit, _everyN));
    _offsets = i?.reminderOffsets;
    _notifyMinutes = i?.notifyMinutes;
    _member = i?.familyMemberId;
    _titleEdited = i != null;
    if (i == null) _title.text = categoryName(_categoryKey);
  }

  @override
  void dispose() {
    for (final c in [_title, _provider, _reference, _amount, _notes, _every]) {
      c.dispose();
    }
    super.dispose();
  }

  void _pickCategory(String key) {
    setState(() {
      _categoryKey = key;
      if (!_isEdit) {
        _unit = suggestedRecurrence(key);
        _everyN = 1;
        _customRecurrence = false;
      }
      if (!_titleEdited) _title.text = categoryName(key);
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _due ?? now.add(const Duration(days: 30)),
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 30),
      helpText: 'Expiry / due date',
    );
    if (picked != null) setState(() => _due = dateOnly(picked));
  }

  Future<void> _pickTime(int fallback) async {
    final m = _notifyMinutes ?? fallback;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: m ~/ 60, minute: m % 60));
    if (t != null) setState(() => _notifyMinutes = t.hour * 60 + t.minute);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_due == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pick an expiry or due date.')));
      return;
    }
    setState(() => _saving = true);
    final services = ref.read(servicesProvider);
    final firstItem = (await services.repo.activeItems()).isEmpty;
    await services.repo.saveItem(
      id: widget.item?.id,
      title: _title.text,
      categoryKey: _categoryKey,
      dueDate: _due,
      startDate: widget.item?.startDate,
      recurrenceUnit: _unit,
      recurrenceEvery: _customRecurrence ? (int.tryParse(_every.text) ?? 1).clamp(1, 120) : _everyN,
      reminderOffsets: _offsets,
      notifyMinutes: _notifyMinutes,
      provider: _provider.text,
      referenceNo: _reference.text,
      amountMinor: parseMoney(_amount.text),
      notes: _notes.text,
      familyMemberId: _member,
    );
    // Ask for notification permission after the first save, when the reason is obvious.
    if (firstItem && !_isEdit) await services.notifications?.requestPermission();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).value;
    final family = ref.watch(familyProvider).value ?? const [];
    final custom = ref.watch(customCategoriesProvider).value ?? const [];
    final parent = _categoryKey.startsWith('custom:') ? 'custom' : _categoryKey.split('.').first;
    final category = builtInCategories.firstWhere((c) => c.key == parent);
    final defaultOffsetsList = profile?.defaultOffsets ?? defaultOffsets;
    final defaultTime = profile?.defaultNotifyMinutes ?? defaultNotifyMinutes;
    final recurrenceKey = _customRecurrence
        ? 'Custom'
        : _recurrenceChoices.entries
            .firstWhere((e) => e.value == (_unit, _everyN), orElse: () => _recurrenceChoices.entries.first)
            .key;

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit reminder' : 'Add Reminder')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            _label('What do you want to track?'),
            Wrap(spacing: 8, runSpacing: 4, children: [
              for (final c in builtInCategories)
                ChoiceChip(
                  label: Text('${c.emoji} ${c.name}'),
                  selected: parent == c.key,
                  onSelected: (_) => _pickCategory(c.children.first.key),
                ),
            ]),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _categoryKey,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Type'),
              items: [
                for (final s in category.children) DropdownMenuItem(value: s.key, child: Text(s.name)),
                if (parent == 'custom')
                  for (final c in custom) DropdownMenuItem(value: 'custom:${c.id}', child: Text(c.name)),
              ],
              onChanged: (k) => k == null ? null : _pickCategory(k),
            ),
            if (parent == 'custom')
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('New category'),
                  onPressed: _newCustomCategory,
                ),
              ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Name'),
              textCapitalization: TextCapitalization.sentences,
              maxLength: 120,
              onChanged: (_) => _titleEdited = true,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Give it a name' : null,
            ),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Expiry / due date', suffixIcon: Icon(Icons.event)),
                child: Text(_due == null ? 'Pick a date' : fmtDate(_due!)),
              ),
            ),
            _label('Renewal'),
            RadioGroup<String>(
              groupValue: recurrenceKey,
              onChanged: (k) => setState(() {
                if (k == 'Custom') {
                  _customRecurrence = true;
                  if (_unit == RecurrenceUnit.none) _unit = RecurrenceUnit.month;
                } else if (k != null) {
                  _customRecurrence = false;
                  final (unit, every) = _recurrenceChoices[k]!;
                  _unit = unit;
                  _everyN = every;
                }
              }),
              child: Column(children: [
                for (final k in [..._recurrenceChoices.keys, 'Custom'])
                  RadioListTile<String>(value: k, title: Text(k), dense: true, contentPadding: EdgeInsets.zero),
              ]),
            ),
            if (_customRecurrence)
              Row(children: [
                const Text('Every '),
                SizedBox(
                  width: 72,
                  child: TextFormField(controller: _every, keyboardType: TextInputType.number, textAlign: TextAlign.center),
                ),
                const SizedBox(width: 8),
                DropdownButton<RecurrenceUnit>(
                  value: _unit == RecurrenceUnit.none ? RecurrenceUnit.month : _unit,
                  items: [
                    for (final u in [RecurrenceUnit.day, RecurrenceUnit.week, RecurrenceUnit.month, RecurrenceUnit.year])
                      DropdownMenuItem(value: u, child: Text('${u.name}s')),
                  ],
                  onChanged: (u) => setState(() => _unit = u!),
                ),
              ]),
            _label('Remind me'),
            OffsetsPicker(
              value: _offsets ?? defaultOffsetsList,
              onChanged: (v) => setState(() => _offsets = v),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule),
              title: const Text('Notification time'),
              trailing: Text(fmtMinutes(_notifyMinutes ?? defaultTime)),
              onTap: () => _pickTime(defaultTime),
            ),
            const SizedBox(height: 8),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text('More details'),
              initiallyExpanded: _isEdit,
              childrenPadding: const EdgeInsets.only(bottom: 8),
              children: [
                TextFormField(controller: _provider, decoration: const InputDecoration(labelText: 'Provider / company')),
                const SizedBox(height: 12),
                TextFormField(controller: _reference, decoration: const InputDecoration(labelText: 'Policy / account number')),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amount,
                  decoration: InputDecoration(labelText: 'Amount', prefixText: profile?.currency == 'INR' || profile == null ? '₹ ' : null),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => (v != null && v.trim().isNotEmpty && parseMoney(v) == null) ? 'Enter a number' : null,
                ),
                if (family.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    initialValue: _member,
                    decoration: const InputDecoration(labelText: 'Belongs to'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('—')),
                      for (final f in family) DropdownMenuItem(value: f.id, child: Text('${f.emoji ?? ''} ${f.name}'.trim())),
                    ],
                    onChanged: (v) => setState(() => _member = v),
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(controller: _notes, decoration: const InputDecoration(labelText: 'Notes'), maxLines: 3),
              ],
            ),
            if (_due != null && _unit != RecurrenceUnit.none)
              Text('Next renewal after this: ${fmtDate(nextDueDate(_due!, _unit, _customRecurrence ? (int.tryParse(_every.text) ?? 1) : _everyN))} '
                  '(${recurrenceLabel(_unit, _customRecurrence ? (int.tryParse(_every.text) ?? 1) : _everyN).toLowerCase()})',
                  style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: const Text('SAVE'),
          ),
        ),
      ),
    );
  }

  Future<void> _newCustomCategory() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New category'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Add')),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    final id = await ref.read(repoProvider).addCustomCategory(name);
    setState(() {
      _categoryKey = 'custom:$id';
      if (!_titleEdited) _title.text = name;
    });
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(text, style: Theme.of(context).textTheme.titleSmall),
      );
}
