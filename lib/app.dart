import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_services.dart';
import 'data/notifications/local_notifications.dart';
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

class DueMateApp extends ConsumerStatefulWidget {
  const DueMateApp({super.key});

  @override
  ConsumerState<DueMateApp> createState() => _DueMateAppState();
}

class _DueMateAppState extends ConsumerState<DueMateApp> with WidgetsBindingObserver {
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
    final themeMode = switch (ref.watch(profileProvider).value?.themeMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    return MaterialApp(
      title: 'DueMate',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      home: const HomeShell(),
    );
  }

  ThemeData _theme(Brightness b) => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2E6FDB),
        brightness: b,
        inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      );
}
