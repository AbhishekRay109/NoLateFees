import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../app_services.dart';
import '../../core/format.dart';
import '../../data/attachment_service.dart';
import '../../data/backup/export_service.dart';
import '../../data/local/database.dart';
import '../../data/notifications/notification_scheduler.dart';
import '../../domain/categories.dart';
import '../../domain/reminder_engine.dart';
import '../../widgets/item_tile.dart';
import 'item_form_screen.dart';
import 'renew_sheet.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  const ItemDetailScreen({super.key, required this.itemId, this.openRenew = false});
  final String itemId;
  final bool openRenew;

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  bool _renewOpened = false;

  void _snack(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final itemAsync = ref.watch(itemProvider(widget.itemId));
    return itemAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => const Scaffold(body: EmptyState(icon: Icons.error_outline, title: 'Could not load this item')),
      data: (item) {
        if (item == null || item.deletedAt != null) {
          return Scaffold(appBar: AppBar(), body: const EmptyState(icon: Icons.delete_outline, title: 'This item was deleted'));
        }
        if (widget.openRenew && !_renewOpened) {
          _renewOpened = true;
          WidgetsBinding.instance.addPostFrameCallback((_) => showRenewSheet(context, item));
        }
        return _buildItem(context, item);
      },
    );
  }

  Widget _buildItem(BuildContext context, Item item) {
    final services = ref.read(servicesProvider);
    final repo = services.repo;
    final profile = ref.watch(profileProvider).value;
    final renewals = ref.watch(renewalsProvider(item.id)).value ?? const [];
    final attachments = ref.watch(attachmentsProvider(item.id)).value ?? const [];
    final customNames = {for (final c in ref.watch(customCategoriesProvider).value ?? const <CustomCategory>[]) c.id: c.name};
    final today = todayDate();
    final status = statusFor(item.dueDate, today);
    final theme = Theme.of(context);

    final upcoming = instancesFor(
      toReminderInput(item),
      now: DateTime.now(),
      location: services.scheduler.location,
      fallbackOffsets: profile?.defaultOffsets ?? defaultOffsets,
      fallbackNotifyMinutes: profile?.defaultNotifyMinutes ?? defaultNotifyMinutes,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ItemFormScreen(item: item))),
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              switch (v) {
                case 'archive':
                  await repo.setArchived(item.id, !item.archived);
                case 'delete':
                  final ok = await _confirmDelete(context);
                  if (ok == true) {
                    await repo.deleteItem(item.id);
                    if (context.mounted) Navigator.of(context).pop();
                  }
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'archive', child: Text(item.archived ? 'Unarchive' : 'Archive (done, no more reminders)')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          ListTile(
            leading: Text(categoryEmoji(item.categoryKey), style: const TextStyle(fontSize: 32)),
            title: Text(categoryName(item.categoryKey, customNames)),
            subtitle: Text(item.archived ? 'Archived' : statusLabel(status)),
          ),
          if (item.dueDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: statusColor(context, status).withValues(alpha: 0.12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(countdownLabel(item.dueDate!, today),
                        style: theme.textTheme.headlineSmall?.copyWith(color: statusColor(context, status))),
                    const SizedBox(height: 4),
                    Text('Expiry: ${fmtDate(item.dueDate!)}'),
                    Text(recurrenceLabel(item.recurrenceUnit, item.recurrenceEvery)),
                    if (item.snoozedUntil != null && item.snoozedUntil!.isAfter(DateTime.now()))
                      Text('Snoozed until ${fmtDate(item.snoozedUntil!)} ${fmtMinutes(item.snoozedUntil!.hour * 60 + item.snoozedUntil!.minute)}'),
                  ]),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.autorenew),
                  label: const Text('Renewed'),
                  onPressed: () => showRenewSheet(context, item),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.snooze),
                  label: const Text('Snooze 1 day'),
                  onPressed: () async {
                    await repo.snooze(item.id, const Duration(days: 1));
                    _snack('We\'ll remind you again tomorrow.');
                  },
                ),
              ),
            ]),
          ),
          _section(context, 'Details'),
          if (item.provider != null) _row('Provider', item.provider!),
          if (item.referenceNo != null) _row('Policy / account no.', item.referenceNo!),
          if (item.amountMinor != null) _row('Amount', fmtMoney(item.amountMinor!, item.currency)),
          if (item.startDate != null) _row('Start date', fmtDate(item.startDate!)),
          if (item.notes != null) _row('Notes', item.notes!),
          _section(context, 'Next reminders'),
          if (upcoming.isEmpty)
            const ListTile(dense: true, title: Text('No more reminders scheduled for this date.')),
          for (final r in upcoming.take(8))
            ListTile(
              dense: true,
              leading: const Icon(Icons.notifications_outlined),
              title: Text(r.body),
              subtitle: Text(_when(r.fireAt)),
            ),
          _section(context, 'Documents'),
          for (final a in attachments)
            ListTile(
              leading: Icon(a.mimeType == 'application/pdf' ? Icons.picture_as_pdf_outlined : Icons.image_outlined),
              title: Text(a.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text('${(a.sizeBytes / 1024).ceil()} KB${a.uploadPending ? ' · not backed up yet' : ''}'),
              onTap: () async {
                try {
                  await services.attachments.open(a);
                } on AttachmentUnavailable {
                  _snack('Sign in to download this file.');
                } catch (_) {
                  _snack('Could not open this file. Check your connection.');
                }
              },
              trailing: IconButton(
                tooltip: 'Remove',
                icon: const Icon(Icons.close),
                onPressed: () => repo.deleteAttachment(a.id),
              ),
            ),
          ListTile(
            leading: const Icon(Icons.attach_file),
            title: const Text('Add PDF / photo'),
            onTap: () async {
              try {
                await services.attachments.pickAndAttach(item.id);
              } on AttachmentTooLarge {
                _snack('Files must be 10 MB or smaller.');
              } catch (_) {
                _snack('Could not attach that file.');
              }
            },
          ),
          _section(context, 'Renewal history'),
          if (renewals.isEmpty) const ListTile(dense: true, title: Text('No renewals yet.')),
          for (final r in renewals)
            ListTile(
              dense: true,
              leading: const Icon(Icons.history),
              title: Text('${fmtDate(r.previousDue)} → ${fmtDate(r.newDue)}'),
              subtitle: Text([
                'Renewed ${fmtDate(r.renewedAt)}',
                if (r.provider != null) r.provider!,
                if (r.notes != null) r.notes!,
              ].join(' · ')),
              trailing: r.amountMinor == null ? null : Text(fmtMoney(r.amountMinor!, item.currency)),
            ),
        ],
      ),
    );
  }

  String _when(tz.TZDateTime t) => '${fmtDate(t)}, ${fmtMinutes(t.hour * 60 + t.minute)}';

  Widget _section(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
        child: Text(title, style: Theme.of(context).textTheme.titleSmall),
      );

  Widget _row(String label, String value) => ListTile(
        dense: true,
        title: Text(label, style: Theme.of(context).textTheme.bodySmall),
        subtitle: Text(value, style: Theme.of(context).textTheme.bodyLarge),
      );

  Future<bool?> _confirmDelete(BuildContext context) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete this item?'),
          content: const Text('Its reminders, documents and history will be removed.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
          ],
        ),
      );
}
