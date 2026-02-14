import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobBottomBanner extends StatefulWidget {
  const AdMobBottomBanner({super.key});

  @override
  State<AdMobBottomBanner> createState() => _AdMobBottomBannerState();
}

class _AdMobBottomBannerState extends State<AdMobBottomBanner> {
  BannerAd? _bannerAd;

  bool get _canShowAds {
    if (kIsWeb || bool.fromEnvironment('FLUTTER_TEST')) {
      return false;
    }

    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  String get _bannerAdUnitId {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'ca-app-pub-3940256099942544/6300978111';
      case TargetPlatform.iOS:
        return 'ca-app-pub-3940256099942544/2934735716';
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        throw UnsupportedError('Ads are not supported on this platform.');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBanner() {
    if (!_canShowAds) {
      return;
    }

    final bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
        },
      ),
    );

    bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    final bannerAd = _bannerAd;
    if (!_canShowAds || bannerAd == null) {
      return const SizedBox.shrink();
    }

    final adWidth = bannerAd.size.width.toDouble();
    final adHeight = bannerAd.size.height.toDouble();

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: adHeight,
          child: Center(
            child: SizedBox(
              width: adWidth,
              height: adHeight,
              child: AdWidget(ad: bannerAd),
            ),
          ),
        ),
      ),
    );
  }
}
