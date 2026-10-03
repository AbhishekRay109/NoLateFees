import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import 'app.dart';
import 'app_services.dart';
import 'data/local/database.dart';
import 'data/notifications/local_notifications.dart';

/// Android daily background job: re-books the nearest notifications.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, input) async {
    DartPluginRegistrant.ensureInitialized();
    final db = AppDatabase.open();
    try {
      await snoozeAndReconcile(db, null);
      return true;
    } catch (_) {
      return false;
    } finally {
      await db.close();
    }
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(callbackDispatcher);

  final services = await AppServices.create();
  final notifications = services.notifications!;
  await notifications.init(onTap: openFromNotification);
  notifications.onSnoozeInForeground =
      (itemId) => services.repo.snooze(itemId, const Duration(days: 1));

  runApp(ProviderScope(
    overrides: [servicesProvider.overrideWithValue(services)],
    child: const NoLateFeesApp(),
  ));

  await services.start();
  final launch = await notifications.launchDetails();
  if (launch != null) openFromNotification(launch.$1, launch.$2);
}
