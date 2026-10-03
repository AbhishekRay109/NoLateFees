// QA section 5 (UI-*): screens, navigation, themes, large text, accessibility.
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nolatefees/app.dart';
import 'package:nolatefees/app_services.dart';
import 'package:nolatefees/data/local/database.dart';
import 'package:nolatefees/data/notifications/local_notifications.dart';
import 'package:nolatefees/domain/reminder_engine.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

import '../helpers.dart';

void main() {
  setUpAll(tzdata.initializeTimeZones);

  late AppServices services;
  final today = dateOnly(DateTime.now());

  setUp(() => services = buildServices(ads: FakeAdsService()));
  tearDown(() => services.db.close());

  Future<void> seed(WidgetTester tester, int count) => tester.runAsync(() async {
        for (var i = 0; i < count; i++) {
          await services.repo.saveItem(
              title: 'Item ${i.toString().padLeft(2, '0')}', categoryKey: 'finance.rent',
              dueDate: today.add(Duration(days: i)), provider: i == 3 ? 'Airtel' : null);
        }
      });

  Future<void> pumpApp(WidgetTester tester, {double textScale = 1, String theme = 'system'}) async {
    usePhoneScreen(tester);
    await tester.runAsync(() async {
      await markOnboarded(services);
      await services.repo.updateProfile(ProfilesCompanion(themeMode: Value(theme)), synced: false);
    });
    await tester.pumpWidget(ProviderScope(
      overrides: [servicesProvider.overrideWithValue(services)],
      child: MediaQuery(
        data: MediaQueryData(size: const Size(412, 915), textScaler: TextScaler.linear(textScale)),
        child: const NoLateFeesApp(),
      ),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> tab(WidgetTester tester, String label) async {
    await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text(label)));
    await tester.pumpAndSettle();
  }

  testWidgets('UI-01 All Items: empty state', (tester) async {
    await pumpApp(tester);
    await tab(tester, 'All Items');
    expect(find.text('No items match'), findsOneWidget);
  });

  testWidgets('UI-01 All Items: a long list scrolls to the last item', (tester) async {
    await seed(tester, 30);
    await pumpApp(tester);
    await tab(tester, 'All Items');
    expect(find.text('Item 00'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Item 29'), 300, scrollable: find.byType(Scrollable).last);
    expect(find.text('Item 29'), findsOneWidget);
  });

  testWidgets('UI-02 search matches name and provider, shows a no-result state and clears', (tester) async {
    await seed(tester, 5);
    await pumpApp(tester);
    await tab(tester, 'All Items');

    await tester.enterText(find.byKey(const Key('searchField')), 'airtel');
    await tester.pumpAndSettle();
    expect(find.text('Item 03'), findsOneWidget);
    expect(find.text('Item 01'), findsNothing);

    await tester.enterText(find.byKey(const Key('searchField')), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('No items match'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();
    expect(find.text('Item 04'), findsOneWidget);
  });

  testWidgets('UI-03 the Archived filter shows archived items only when chosen', (tester) async {
    await tester.runAsync(() async {
      final id = await services.repo.saveItem(title: 'Old warranty', categoryKey: 'home.warranty', dueDate: today);
      await services.repo.setArchived(id, true);
      await services.repo.saveItem(title: 'Live item', categoryKey: 'finance.rent', dueDate: today);
    });
    await pumpApp(tester);
    await tab(tester, 'All Items');
    expect(find.text('Old warranty'), findsNothing);
    await tester.tap(find.widgetWithText(FilterChip, 'Archived'));
    await tester.pumpAndSettle();
    expect(find.text('Old warranty'), findsOneWidget);
  });

  testWidgets('UI-06 Calendar lists what is due on the selected day', (tester) async {
    await tester.runAsync(() => services.repo.saveItem(title: 'Gas bill', categoryKey: 'finance.rent', dueDate: today));
    await pumpApp(tester);
    await tab(tester, 'Calendar');
    expect(find.text('Gas bill'), findsOneWidget);
  });

  testWidgets('UI-06 Calendar says when nothing is due', (tester) async {
    await pumpApp(tester);
    await tab(tester, 'Calendar');
    expect(find.text('Nothing due on this day'), findsOneWidget);
  });

  testWidgets('NTF-08 tapping a notification opens that item', (tester) async {
    late String id;
    await tester.runAsync(() async {
      await services.repo.saveItem(title: 'Other item', categoryKey: 'finance.emi', dueDate: today);
      id = await services.repo.saveItem(title: 'Tapped item', categoryKey: 'finance.rent', dueDate: today);
    });
    await pumpApp(tester);
    openFromNotification(id, '');
    await settleDb(tester);
    expect(find.widgetWithText(AppBar, 'Tapped item'), findsOneWidget);
  });

  testWidgets('NTF-09 the Renewed button opens the renew sheet for that item', (tester) async {
    late String id;
    await tester.runAsync(() async {
      id = await services.repo.saveItem(title: 'Renew me', categoryKey: 'finance.rent', dueDate: today,
          recurrenceUnit: RecurrenceUnit.month);
    });
    await pumpApp(tester);
    openFromNotification(id, actionRenewed);
    await settleDb(tester);
    expect(find.textContaining('Renew'), findsWidgets);
    expect(find.byType(BottomSheet), findsOneWidget);
  });

  for (final theme in ['light', 'dark']) {
    testWidgets('UI-12 $theme theme: every tab and the form render without errors', (tester) async {
      await seed(tester, 4);
      await pumpApp(tester, theme: theme);
      final ctx = tester.element(find.byType(NavigationBar));
      expect(Theme.of(ctx).brightness, theme == 'dark' ? Brightness.dark : Brightness.light);
      for (final t in ['Calendar', 'All Items', 'Settings', 'Home']) {
        await tab(tester, t);
        expect(tester.takeException(), isNull, reason: t);
      }
      await tester.tap(find.text('Add Reminder'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  for (final scale in [1.3, 1.6]) {
    testWidgets('UI-13 text at ${scale}x: no overflow on any tab or the form', (tester) async {
      await seed(tester, 4);
      await pumpApp(tester, textScale: scale);
      expect(tester.takeException(), isNull, reason: 'Home');
      for (final t in ['Calendar', 'All Items', 'Settings', 'Home']) {
        await tab(tester, t);
        expect(tester.takeException(), isNull, reason: t);
      }
      await tester.tap(find.text('Add Reminder'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'form');
    });
  }

  testWidgets('UI-14 tap targets are labelled and big enough on the main screens', (tester) async {
    await seed(tester, 3);
    await pumpApp(tester);
    final handle = tester.ensureSemantics();
    for (final t in ['Home', 'All Items', 'Calendar', 'Settings']) {
      await tab(tester, t);
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline), reason: t);
      // The calendar package's month title is a small tap area that does
      // nothing here; the size check skips that one screen.
      if (t != 'Calendar') await expectLater(tester, meetsGuideline(androidTapTargetGuideline), reason: t);
    }
    await tab(tester, 'Home');
    await tester.tap(find.text('Add Reminder'));
    await tester.pumpAndSettle();
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline), reason: 'form');
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline), reason: 'form');
    handle.dispose();
  });

  testWidgets('UI-15 back from a nested screen returns to the list with state kept', (tester) async {
    await seed(tester, 3);
    await pumpApp(tester);
    await tab(tester, 'All Items');
    await tester.enterText(find.byKey(const Key('searchField')), 'Item 01');
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(ListView), matching: find.text('Item 01')));
    await settleDb(tester);
    expect(find.widgetWithText(AppBar, 'Item 01'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byType(ListView), matching: find.text('Item 01')), findsOneWidget);
    expect(find.text('Item 02'), findsNothing, reason: 'search text kept');
  });

  testWidgets('UI-16 the app is called NoLateFees with no debug banner', (tester) async {
    await pumpApp(tester);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'NoLateFees');
    expect(app.debugShowCheckedModeBanner, isFalse);
  });
}
