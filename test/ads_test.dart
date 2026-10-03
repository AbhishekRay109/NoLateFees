import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nolatefees/app.dart';
import 'package:nolatefees/app_services.dart';
import 'package:nolatefees/core/config.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

import 'helpers.dart';

void main() {
  setUpAll(tzdata.initializeTimeZones);

  late AppServices services;
  late FakeAdsService ads;

  setUp(() {
    ads = FakeAdsService();
    services = buildServices(ads: ads);
  });

  tearDown(() => services.db.close());

  Future<void> pumpApp(WidgetTester tester, {bool onboarded = true}) async {
    usePhoneScreen(tester);
    if (onboarded) await tester.runAsync(() => markOnboarded(services));
    await tester.pumpWidget(ProviderScope(
      overrides: [servicesProvider.overrideWithValue(services)],
      child: const NoLateFeesApp(),
    ));
    await tester.pumpAndSettle();
  }

  final banner = find.byKey(const Key('fakeBanner'));

  testWidgets('one banner on Home, sitting just above the bottom navigation', (tester) async {
    await pumpApp(tester);
    expect(banner, findsOneWidget);
    final adBottom = tester.getBottomLeft(banner).dy;
    final navTop = tester.getTopLeft(find.byType(NavigationBar)).dy;
    expect(adBottom, navTop);
    expect(tester.getSize(banner).width, tester.getSize(find.byType(NavigationBar)).width);
  });

  testWidgets('the Add Reminder button stays above the banner', (tester) async {
    await pumpApp(tester);
    final fabBottom = tester.getBottomLeft(find.byType(FloatingActionButton)).dy;
    expect(fabBottom, lessThanOrEqualTo(tester.getTopLeft(banner).dy));
  });

  testWidgets('banner on All Items, but never on Calendar or Settings', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.list_alt_outlined));
    await tester.pumpAndSettle();
    expect(banner, findsOneWidget);

    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();
    expect(banner, findsNothing);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(banner, findsNothing);
  });

  testWidgets('no ad while adding a reminder', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Add Reminder'));
    await tester.pumpAndSettle();
    expect(banner, findsNothing);
  });

  testWidgets('no ad on the welcome and sign-up screens', (tester) async {
    await pumpApp(tester, onboarded: false);
    expect(find.text('Never pay a late fee again.'), findsOneWidget);
    expect(banner, findsNothing);
  });

  testWidgets('takes no space until ads are ready (consent, SDK, offline)', (tester) async {
    ads.isReady = false;
    await pumpApp(tester);
    expect(find.byKey(const Key('adSlot')), findsNothing);

    ads.isReady = true;
    await tester.pumpAndSettle();
    expect(banner, findsOneWidget);
  });

  testWidgets('builds without ads show nothing', (tester) async {
    services = buildServices();
    await pumpApp(tester);
    expect(find.byKey(const Key('adSlot')), findsNothing);
  });

  test('defaults to Google test ads so development taps are safe', () {
    expect(AppConfig.admobBannerId, 'ca-app-pub-3940256099942544/9214589741');
    expect(AppConfig.adsEnabled, isTrue);
  });
}
