import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_services.dart';
import 'core/theme.dart';
import 'data/local/database.dart';
import 'data/notifications/local_notifications.dart';
import 'features/onboarding/welcome_screen.dart';
import 'features/items/item_detail_screen.dart';
import 'features/shell/home_shell.dart';

final navigatorKey = GlobalKey<NavigatorState>();

/// Opens an item from a notification tap. "Renewed" opens the renew sheet.
void openFromNotification(String itemId, String action) {
  final nav = navigatorKey.currentState;
  if (nav == null) return;
  nav.push(MaterialPageRoute(
    builder: (_) => ItemDetailScreen(itemId: itemId, openRenew: action == actionRenewed),
  ));
}

class NoLateFeesApp extends ConsumerStatefulWidget {
  const NoLateFeesApp({super.key});

  @override
  ConsumerState<NoLateFeesApp> createState() => _NoLateFeesAppState();
}

class _NoLateFeesAppState extends ConsumerState<NoLateFeesApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) ref.read(servicesProvider).onResume();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).value;
    final themeMode = switch (profile?.themeMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    return MaterialApp(
      title: 'NoLateFees',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: switch (profile) {
        null => const Scaffold(body: Center(child: CircularProgressIndicator())),
        Profile(onboarded: false) => const WelcomeScreen(),
        _ => const HomeShell(),
      },
    );
  }
}
