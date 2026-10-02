import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app_services.dart';
import '../../core/format.dart';
import '../../data/local/database.dart';
import '../../data/sync/sync_service.dart';
import '../../widgets/offsets_picker.dart';
import '../auth/sign_in_screen.dart';
import 'family_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(servicesProvider);
    final repo = services.repo;
    final profile = ref.watch(profileProvider).value;
    final email = ref.watch(userEmailProvider).value;
    final sync = ref.watch(syncStatusProvider).value;
    if (profile == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    void snack(String t) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _header(context, 'Account & backup'),
          if (services.supabase == null)
            const ListTile(
              leading: Icon(Icons.cloud_off_outlined),
              title: Text('Offline mode'),
              subtitle: Text('Cloud backup is not set up in this build. Use Export to keep a backup.'),
            )
          else if (email == null)
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Sign in to back up and sync'),
              subtitle: const Text('Your reminders stay on this phone until you sign in.'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignInScreen())),
            )
          else ...[
            ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: Text(email),
              subtitle: Text(_syncText(sync)),
              trailing: IconButton(
                tooltip: 'Sync now',
                icon: const Icon(Icons.sync),
                onPressed: () => services.sync?.run().then((_) => snack('Synced.'), onError: (_) => snack('Sync failed. Check your connection.')),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              subtitle: const Text('Removes your data from this phone. It stays in your account.'),
              onTap: () async {
                if (await _confirm(context, 'Sign out?', 'Your reminders will be removed from this phone and its notifications stop. Sign in again to get them back.') ==
                    true) {
                  await services.signOut();
                }
              },
            ),
          ],
          ListTile(
            leading: const Icon(Icons.table_view_outlined),
            title: const Text('Export to CSV'),
            subtitle: const Text('Open in Excel or Google Sheets'),
            onTap: () async => _share(await services.export.toCsv(), 'duemate.csv', 'text/csv'),
          ),
          ListTile(
            leading: const Icon(Icons.save_alt),
            title: const Text('Export backup (JSON)'),
            subtitle: const Text('Save to Google Drive or send to yourself'),
            onTap: () async => _share(await services.export.toJson(), 'duemate-backup.json', 'application/json'),
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Import backup'),
            onTap: () async {
              final files = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: const ['json']);
              if (files.isEmpty || files.first.path == null) return;
              try {
                final n = await services.export.importJson(await File(files.first.path!).readAsString());
                await services.scheduler.reconcile();
                services.sync?.schedule();
                snack('Imported $n items.');
              } catch (_) {
                snack('That file is not a DueMate backup.');
              }
            },
          ),
          _header(context, 'Reminders'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            value: profile.notificationsEnabled,
            onChanged: (v) async {
              if (v) await services.notifications?.requestPermission();
              await repo.updateProfile(ProfilesCompanion(notificationsEnabled: Value(v)), synced: false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Default notification time'),
            trailing: Text(fmtMinutes(profile.defaultNotifyMinutes)),
            onTap: () async {
              final m = profile.defaultNotifyMinutes;
              final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: m ~/ 60, minute: m % 60));
              if (t != null) await repo.updateProfile(ProfilesCompanion(defaultNotifyMinutes: Value(t.hour * 60 + t.minute)));
            },
          ),
          const ListTile(
            leading: Icon(Icons.notifications_active_outlined),
            title: Text('Default reminder schedule'),
            subtitle: Text('Used for items where you didn\'t pick your own'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: OffsetsPicker(
              value: profile.defaultOffsets,
              onChanged: (v) => repo.updateProfile(ProfilesCompanion(defaultOffsets: Value(v))),
            ),
          ),
          if (Platform.isAndroid)
            SwitchListTile(
              secondary: const Icon(Icons.alarm),
              title: const Text('Exact timing'),
              subtitle: const Text('Off: reminders may arrive a few minutes late, which saves battery.'),
              value: profile.exactAlarms,
              onChanged: (v) async {
                if (v && !(await services.notifications?.requestExactAlarms() ?? false)) {
                  snack('Allow "Alarms & reminders" for DueMate in system settings, then try again.');
                  return;
                }
                await repo.updateProfile(ProfilesCompanion(exactAlarms: Value(v)), synced: false);
              },
            ),
          if (Platform.isAndroid)
            const ListTile(
              leading: Icon(Icons.battery_alert_outlined),
              title: Text('Not getting reminders?'),
              subtitle: Text('Some phones (Xiaomi, Oppo, Vivo, Realme, OnePlus) stop apps in the background. '
                  'In system settings, set DueMate\'s battery usage to "No restrictions".'),
            ),
          _header(context, 'Family'),
          ListTile(
            leading: const Icon(Icons.family_restroom),
            title: const Text('Family & vehicles'),
            subtitle: const Text('Track Dad\'s insurance, Mom\'s passport, the bike\'s PUC…'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FamilyScreen())),
          ),
          _header(context, 'Appearance'),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Your name'),
            subtitle: Text(profile.displayName ?? 'Not set'),
            onTap: () async {
              final name = await _askText(context, 'Your name', profile.displayName ?? '');
              if (name != null) {
                await repo.updateProfile(ProfilesCompanion(displayName: Value(name.isEmpty ? null : name)));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Theme'),
            trailing: DropdownButton<String>(
              value: profile.themeMode,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: 'system', child: Text('System')),
                DropdownMenuItem(value: 'light', child: Text('Light')),
                DropdownMenuItem(value: 'dark', child: Text('Dark')),
              ],
              onChanged: (v) => repo.updateProfile(ProfilesCompanion(themeMode: Value(v!)), synced: false),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.currency_rupee),
            title: const Text('Currency'),
            trailing: DropdownButton<String>(
              value: profile.currency,
              underline: const SizedBox.shrink(),
              items: [
                for (final c in const ['INR', 'USD', 'EUR', 'GBP', 'AED', 'SGD', 'AUD', 'CAD'])
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: (v) => repo.updateProfile(ProfilesCompanion(currency: Value(v!))),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.public),
            title: const Text('Time zone'),
            subtitle: Text(profile.timezone),
          ),
          if (email != null) ...[
            _header(context, 'Danger zone'),
            ListTile(
              leading: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
              title: Text('Delete account', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              subtitle: const Text('Permanently deletes your account, reminders and documents.'),
              onTap: () async {
                if (await _confirm(context, 'Delete your account?', 'This permanently deletes everything. It cannot be undone.') == true) {
                  try {
                    await services.deleteAccount();
                    snack('Your account was deleted.');
                  } catch (_) {
                    snack('Could not delete the account. Check your connection and try again.');
                  }
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  static String _syncText(SyncStatus? s) {
    if (s == null) return 'Backed up to your account';
    return switch (s.phase) {
      SyncPhase.syncing => 'Syncing…',
      SyncPhase.error => 'Sync failed. Will retry when you\'re online.',
      _ => s.lastSynced == null ? 'Backed up to your account' : 'Last synced ${fmtMinutes(s.lastSynced!.hour * 60 + s.lastSynced!.minute)}',
    };
  }

  static Future<void> _share(String content, String fileName, String mime) async {
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, fileName));
    await file.writeAsString(content);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path, mimeType: mime)], subject: 'DueMate export'));
  }

  static Widget _header(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
        child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
      );

  static Future<bool?> _confirm(BuildContext context, String title, String body) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Continue')),
          ],
        ),
      );

  static Future<String?> _askText(BuildContext context, String title, String initial) {
    final c = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(controller: c, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('Save')),
        ],
      ),
    );
  }
}
