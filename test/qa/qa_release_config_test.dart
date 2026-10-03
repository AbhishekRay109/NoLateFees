// QA sections 1 and 8 (BLD-*, POL-*): checks on the files that decide what
// ships: app id, version, signing, permissions, ads and configuration.
import 'dart:convert';
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
    for (final entry in ['android/key.properties', '*.jks', '*.keystore', 'env.json']) {
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

  test('BLD-07 the build config has your Firebase and AdMob ids, not test ones', () {
    final config = jsonDecode(read('app_config.json')) as Map<String, dynamic>;
    for (final key in ['FIREBASE_API_KEY', 'FIREBASE_APP_ID', 'FIREBASE_MESSAGING_SENDER_ID', 'FIREBASE_PROJECT_ID',
        'GOOGLE_SERVER_CLIENT_ID', 'ADMOB_APP_ID', 'ADMOB_BANNER_ID']) {
      expect((config[key] as String?)?.trim(), isNotEmpty, reason: key);
    }
    expect(config['FIREBASE_API_KEY'], startsWith('AIza'));
    expect(config['GOOGLE_SERVER_CLIENT_ID'], endsWith('.apps.googleusercontent.com'));
    expect(config['GOOGLE_SERVER_CLIENT_ID'], startsWith('${config['FIREBASE_MESSAGING_SENDER_ID']}-'),
        reason: 'the Web client id must belong to the same Firebase project');
    expect(config['FIREBASE_APP_ID'], contains(':android:'));
    expect(config['ADMOB_APP_ID'], matches(RegExp(r'^ca-app-pub-\d{16}~\d{10}$')));
    expect(config['ADMOB_BANNER_ID'], matches(RegExp(r'^ca-app-pub-\d{16}/\d{10}$')));
    expect(config['ADMOB_APP_ID'], isNot(startsWith('ca-app-pub-3940256099942544')), reason: 'Google test id');
    expect(config['ADMOB_BANNER_ID'], isNot(startsWith('ca-app-pub-3940256099942544')), reason: 'Google test id');
    expect((config['ADMOB_APP_ID'] as String).split('~').first, (config['ADMOB_BANNER_ID'] as String).split('/').first,
        reason: 'banner and app must be from the same AdMob account');
  });

  test('BLD-07 the CI build feeds that config and the AdMob app id into the APK', () {
    final ci = read('.github/workflows/apk.yml');
    expect(ci, contains('app_config.json'));
    expect(ci, contains('--dart-define-from-file=env.json'));
    expect(ci, contains('ADMOB_APP_ID'));
    expect(manifest, contains(r'android:value="${admobAppId}"'));
    expect(gradle, contains('manifestPlaceholders["admobAppId"]'));
  });

  test('POL-04/08 permissions are exactly what the store listing declares', () {
    final perms = RegExp(r'<uses-permission android:name="([^"]+)"').allMatches(manifest).map((m) => m.group(1)).toSet();
    expect(perms, {
      'android.permission.INTERNET',
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

  test('UI-10/POL-10 only banner ads: no pop-up, full-screen, video or app-open ads anywhere', () {
    final dart = Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
    for (final f in dart) {
      final src = f.readAsStringSync();
      for (final banned in ['InterstitialAd', 'RewardedAd', 'RewardedInterstitialAd', 'AppOpenAd']) {
        expect(src.contains(banned), isFalse, reason: '$banned in ${f.path}');
      }
    }
  });

  test('POL-10 debug builds fall back to Google test ads, never your real ad unit', () {
    expect(AppConfig.admobBannerId, startsWith('ca-app-pub-3940256099942544'),
        reason: 'tests and local runs use the test banner');
    expect(gradle, contains('ca-app-pub-3940256099942544~3347511713'));
  });

  test('POL-01 support contact is set', () {
    expect(AppConfig.supportEmail, 'nolatefeesadmin@gmail.com');
  });

  test('UI-16 the launcher label is NoLateFees', () {
    expect(manifest, contains('android:label="NoLateFees"'));
  });

  test('SYN-10 the security rules shipped with the app are the ones under test', () {
    final firebase = jsonDecode(read('firebase.json')) as Map<String, dynamic>;
    expect(firebase['firestore']['rules'], 'firebase/firestore.rules');
    expect(firebase['storage']['rules'], 'firebase/storage.rules');
    expect(File('firebase/rules-test/rules.test.mjs').existsSync(), isTrue);
  });
}
