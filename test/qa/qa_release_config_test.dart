// QA sections 1 and 8 (BLD-*, POL-*): checks on the files that decide what
// ships: app id, version, signing, permissions, and that the app stays
// local-only (no cloud, sign-in or ad SDKs, no network access).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nolatefees/core/config.dart';

String read(String path) => File(path).readAsStringSync();

void main() {
  final gradle = read('android/app/build.gradle.kts');
  final manifest = read('android/app/src/main/AndroidManifest.xml');
  final pubspec = read('pubspec.yaml');

  test('BLD-01 the app id is com.nolatefees.app', () {
    expect(gradle, contains('applicationId = "com.nolatefees.app"'));
    expect(gradle, contains('namespace = "com.nolatefees.app"'));
  });

  test('BLD-01 the version is name+code, and Android takes it from pubspec', () {
    final m = RegExp(r'^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$', multiLine: true).firstMatch(pubspec);
    expect(m, isNotNull, reason: 'pubspec version must look like 1.2.3+45');
    expect(int.parse(m!.group(4)!), greaterThan(0));
    expect(gradle, contains('versionCode = flutter.versionCode'));
    expect(gradle, contains('versionName = flutter.versionName'));
  });

  test('BLD-05 release bundles refuse to build without your own upload key', () {
    expect(gradle, contains('rootProject.file("key.properties")'));
    expect(gradle, contains('bundleRelease'));
    expect(gradle, contains('throw GradleException'));
  });

  test('BLD-05 no real signing secrets are committed', () {
    final ignore = read('.gitignore');
    for (final entry in ['android/key.properties', '*.jks', '*.keystore']) {
      expect(ignore, contains(entry));
    }
    expect(File('android/key.properties').existsSync(), isFalse);
    final keystores = Directory('android')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.jks') || f.path.endsWith('.keystore'))
        .map((f) => f.path.replaceAll(r'\', '/'))
        .toList();
    expect(keystores, ['android/app/ci-test.jks'], reason: 'only the public test key is in the repo');
  });

  test('LOC-01 local-only: no cloud, sign-in or ad SDKs are bundled', () {
    for (final pkg in ['firebase_core', 'firebase_auth', 'cloud_firestore', 'firebase_storage', 'google_sign_in',
        'google_mobile_ads', 'connectivity_plus', 'http:', 'dio:']) {
      expect(pubspec, isNot(contains('  $pkg')), reason: '$pkg must not be a dependency');
    }
    expect(manifest, isNot(contains('com.google.android.gms.ads')));
    expect(File('app_config.json').existsSync(), isFalse);
    expect(File('firebase.json').existsSync(), isFalse);
  });

  test('POL-04/08 permissions are exactly these, and none of them is network access', () {
    final perms = RegExp(r'<uses-permission android:name="([^"]+)"').allMatches(manifest).map((m) => m.group(1)).toSet();
    expect(perms, {
      // No INTERNET: release builds cannot send data anywhere.
      'android.permission.POST_NOTIFICATIONS',
      'android.permission.RECEIVE_BOOT_COMPLETED',
      'android.permission.SCHEDULE_EXACT_ALARM', // opt-in only; USE_EXACT_ALARM is not allowed for this app type
    });
    expect(manifest, isNot(contains('android:debuggable="true"')));
    expect(manifest, isNot(contains('usesCleartextTraffic="true"')));
  });

  test('NTF-14 reminders are re-booked after a restart and after an app update', () {
    expect(manifest, contains('ScheduledNotificationBootReceiver'));
    expect(manifest, contains('android.intent.action.BOOT_COMPLETED'));
    expect(manifest, contains('android.intent.action.MY_PACKAGE_REPLACED'));
    expect(manifest, contains('ScheduledNotificationReceiver'));
    expect(manifest, contains('ActionBroadcastReceiver'), reason: 'Renewed / Snooze buttons');
  });

  test('POL-01 support contact is set', () {
    expect(AppConfig.supportEmail, 'nolatefeesadmin@gmail.com');
  });

  test('UI-16 the launcher label is NoLateFees', () {
    expect(manifest, contains('android:label="NoLateFees"'));
  });
}
