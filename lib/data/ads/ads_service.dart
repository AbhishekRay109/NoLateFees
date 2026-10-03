// One small banner ad (Google AdMob). No pop-ups, no full-screen ads, no
// rewarded videos: the app must stay calm to use. Behind an interface so
// widget tests run without the ads plugin.
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/config.dart';

abstract class AdsService {
  /// True once consent (where the law needs it) and the SDK are ready.
  ValueListenable<bool> get ready;

  /// Asks for ad consent if needed (EU/UK), then starts the SDK. Never throws.
  Future<void> start();

  /// The banner for a slot [width] logical pixels wide.
  Widget buildBanner(double width);
}

class AdMobAdsService implements AdsService {
  AdMobAdsService({String? bannerUnitId}) : bannerUnitId = bannerUnitId ?? AppConfig.admobBannerId;

  final String bannerUnitId;
  final _ready = ValueNotifier(false);

  @override
  ValueListenable<bool> get ready => _ready;

  @override
  Future<void> start() async {
    try {
      await _updateConsent();
      if (!await ConsentInformation.instance.canRequestAds()) return;
      await MobileAds.instance.initialize();
      _ready.value = true;
    } catch (e) {
      debugPrint('Ads unavailable: $e');
    }
  }

  Future<void> _updateConsent() {
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        // Shows Google's consent form only where required (e.g. EU/UK).
        await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
        if (!done.isCompleted) done.complete();
      },
      (_) {
        if (!done.isCompleted) done.complete();
      },
    );
    return done.future;
  }

  @override
  Widget buildBanner(double width) => _AdMobBanner(key: ValueKey(width.truncate()), unitId: bannerUnitId, width: width);
}

class _AdMobBanner extends StatefulWidget {
  const _AdMobBanner({super.key, required this.unitId, required this.width});
  final String unitId;
  final double width;

  @override
  State<_AdMobBanner> createState() => _AdMobBannerState();
}

class _AdMobBannerState extends State<_AdMobBanner> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(widget.width.truncate());
    if (size == null || !mounted) return;
    final ad = BannerAd(
      adUnitId: widget.unitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        // No fill or offline: the slot simply stays collapsed.
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    );
    _ad = ad;
    await ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();
    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
