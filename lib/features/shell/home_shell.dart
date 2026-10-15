import 'package:flutter/material.dart';

import '../calendar/calendar_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../items/all_items_screen.dart';
import '../items/item_form_screen.dart';
import '../settings/settings_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  static const _pages = [DashboardScreen(), CalendarScreen(), AllItemsScreen(), SettingsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _pages),
      floatingActionButton: _tab == 3
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ItemFormScreen())),
              icon: const Icon(Icons.add),
              label: const Text('Add Reminder'),
            ),
      bottomNavigationBar: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month),
                label: 'Calendar',
              ),
              NavigationDestination(
                icon: Icon(Icons.list_alt_outlined),
                selectedIcon: Icon(Icons.list_alt),
                label: 'All Items',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
    );
  }
}
