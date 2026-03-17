import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobInterstitial {
  InterstitialAd? _interstitialAd;
  int _saveCount = 0;

  bool get _canShowAds {
    if (kIsWeb || bool.fromEnvironment('FLUTTER_TEST')) {
      return false;
    }

    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  String get _adUnitId {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'ca-app-pub-3940256099942544/1033173712';
      case TargetPlatform.iOS:
        return kReleaseMode
            ? 'ca-app-pub-8980159252766093/3697653803'
            : 'ca-app-pub-3940256099942544/4411468910';
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        throw UnsupportedError('Ads are not supported on this platform.');
    }
  }

  void loadAd() {
    if (!_canShowAds) {
      return;
    }

    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              loadAd();
            },
            onAdFailedToShowFullScreenContent: (ad, _) {
              ad.dispose();
              _interstitialAd = null;
              loadAd();
            },
          );
        },
        onAdFailedToLoad: (_) {
          _interstitialAd = null;
        },
      ),
    );
  }

  void onImageSaved() {
    _saveCount++;
    if (_saveCount % 3 == 0) {
      _showAdIfReady();
    }
  }

  void _showAdIfReady() {
    final ad = _interstitialAd;
    if (ad != null) {
      ad.show();
      _interstitialAd = null;
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
