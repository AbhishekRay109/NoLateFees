import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app_services.dart';
import '../../core/config.dart';
import '../../core/format.dart';
import '../../data/local/database.dart';
import '../../widgets/offsets_picker.dart';
import '../../core/theme.dart';
import '../../widgets/brand.dart';
import '../onboarding/profile_setup_screen.dart';
import 'family_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(servicesProvider);
    final repo = services.repo;
    final profile = ref.watch(profileProvider).value;
    if (profile == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    void snack(String t) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _ProfileCard(profile: profile),
          _header(context, 'Your data'),
          const ListTile(
            leading: Icon(Icons.phone_android),
            title: Text('Stored on this phone only'),
            subtitle: Text('No account and no cloud. Export a backup to move your reminders to a new phone.'),
          ),
          ListTile(
            leading: const Icon(Icons.table_view_outlined),
            title: const Text('Export to CSV'),
            subtitle: const Text('Open in Excel or Google Sheets'),
            onTap: () async => _share(await services.export.toCsv(), 'nolatefees.csv', 'text/csv'),
          ),
          ListTile(
            leading: const Icon(Icons.save_alt),
            title: const Text('Export backup (JSON)'),
            subtitle: const Text('Save to Google Drive or send to yourself'),
            onTap: () async => _share(await services.export.toJson(), 'nolatefees-backup.json', 'application/json'),
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
                snack('Imported $n items.');
              } catch (_) {
                snack('That file is not a NoLateFees backup.');
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
              await repo.updateProfile(ProfilesCompanion(notificationsEnabled: Value(v)));
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
                  snack('Allow "Alarms & reminders" for NoLateFees in system settings, then try again.');
                  return;
                }
                await repo.updateProfile(ProfilesCompanion(exactAlarms: Value(v)));
              },
            ),
          if (Platform.isAndroid)
            const ListTile(
              leading: Icon(Icons.battery_alert_outlined),
              title: Text('Not getting reminders?'),
              subtitle: Text('Some phones (Xiaomi, Oppo, Vivo, Realme, OnePlus) stop apps in the background. '
                  'In system settings, set NoLateFees\'s battery usage to "No restrictions".'),
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
              onChanged: (v) => repo.updateProfile(ProfilesCompanion(themeMode: Value(v!))),
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
          _header(context, 'Danger zone'),
          ListTile(
            leading: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
            title: Text('Erase all data', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            subtitle: const Text('Deletes every reminder, document and setting from this phone.'),
            onTap: () async {
              if (await _confirm(context, 'Erase all data?',
                      'Everything in NoLateFees on this phone is deleted. Export a backup first if you want to keep it.') ==
                  true) {
                await services.eraseAllData();
                snack('All data erased.');
              }
            },
          ),
          _header(context, 'Contact us'),
          const _ContactCard(),
        ],
      ),
    );
  }

  static Future<void> _share(String content, String fileName, String mime) async {
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, fileName));
    await file.writeAsString(content);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path, mimeType: mime)], subject: 'NoLateFees export'));
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
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});
  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final name = profile.displayName;
    final details = [
      if (profile.email != null) profile.email!,
      if (profile.phone != null) formatPhone(profile.phone!),
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        gradient: Brand.gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Brand.violet.withValues(alpha: 0.3), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const ProfileSetupScreen(editing: true))),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: UserAvatar(initials: initialsOf(name), radius: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name ?? 'Add your name',
                      style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(details.isEmpty ? 'Tap to edit your profile' : details.join('\n'),
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9))),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22), borderRadius: BorderRadius.circular(8)),
                    child: const Text('On this phone only',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ]),
              ),
              const Icon(Icons.edit_outlined, color: Colors.white),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Mail link for bug reports and feedback, prefilled with app details.
Uri feedbackMailUri({String platform = ''}) => Uri(
      scheme: 'mailto',
      path: AppConfig.supportEmail,
      query: 'subject=${Uri.encodeComponent('NoLateFees feedback')}'
          '&body=${Uri.encodeComponent('Hi NoLateFees team,\n\n\n\n---\nPhone: $platform')}',
    );

class _ContactCard extends StatelessWidget {
  const _ContactCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Future<void> copy() async {
      await Clipboard.setData(const ClipboardData(text: AppConfig.supportEmail));
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Email address copied.')));
      }
    }

    return Card(
      key: const Key('contactCard'),
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(gradient: Brand.gradient, borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.mail_outline, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Found a bug or have feedback?',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('Please feel free to drop us a mail. We read every message.',
                    style: theme.textTheme.bodySmall),
              ]),
            ),
          ]),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onLongPress: copy,
            onTap: () async {
              final opened = await launchUrl(feedbackMailUri(platform: Platform.operatingSystemVersion))
                  .catchError((_) => false);
              if (!opened) await copy();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                Expanded(
                  child: Text(AppConfig.supportEmail,
                      style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 15)),
                ),
                IconButton(tooltip: 'Copy email', icon: const Icon(Icons.copy, size: 20), onPressed: copy),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
