import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobAppOpenAd with WidgetsBindingObserver {
  static const Duration _startupShowWindow = Duration(seconds: 12);
  static const String _releaseAdUnitId =
      'ca-app-pub-8980159252766093/8691977453';
  static const String _androidTestAdUnitId =
      'ca-app-pub-3940256099942544/9257395921';
  static const String _iosTestAdUnitId =
      'ca-app-pub-3940256099942544/5575463023';
  static bool _didRequestStartupAdInProcess = false;

  AppOpenAd? _appOpenAd;
  DateTime? _startupRequestedAt;
  bool _isLoading = false;
  bool _isShowingAd = false;
  bool _didLeaveStartupForeground = false;
  bool _isObservingLifecycle = false;

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
        return kReleaseMode ? _releaseAdUnitId : _androidTestAdUnitId;
      case TargetPlatform.iOS:
        return kReleaseMode ? _releaseAdUnitId : _iosTestAdUnitId;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        throw UnsupportedError('Ads are not supported on this platform.');
    }
  }

  void loadAndShowOnStartup() {
    if (!_canShowAds || _didRequestStartupAdInProcess || _isLoading) {
      return;
    }

    _didRequestStartupAdInProcess = true;
    _didLeaveStartupForeground = false;
    _isLoading = true;
    _startupRequestedAt = DateTime.now();
    _startObservingLifecycle();

    AppOpenAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoading = false;
          _appOpenAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback<AppOpenAd>(
            onAdShowedFullScreenContent: (_) {
              _isShowingAd = true;
            },
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _appOpenAd = null;
              _isShowingAd = false;
            },
            onAdFailedToShowFullScreenContent: (ad, _) {
              ad.dispose();
              _appOpenAd = null;
              _isShowingAd = false;
            },
          );
          _showIfStillStartup();
        },
        onAdFailedToLoad: (_) {
          _isLoading = false;
          _appOpenAd = null;
          _stopObservingLifecycle();
        },
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed || _isShowingAd) {
      return;
    }

    _didLeaveStartupForeground = true;
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _stopObservingLifecycle();
  }

  void _showIfStillStartup() {
    final ad = _appOpenAd;
    final requestedAt = _startupRequestedAt;
    if (ad == null || requestedAt == null || _isShowingAd) {
      return;
    }

    final elapsed = DateTime.now().difference(requestedAt);
    if (_didLeaveStartupForeground || elapsed > _startupShowWindow) {
      ad.dispose();
      _appOpenAd = null;
      _stopObservingLifecycle();
      return;
    }

    _stopObservingLifecycle();
    ad.show();
    _appOpenAd = null;
  }

  void _startObservingLifecycle() {
    if (_isObservingLifecycle) {
      return;
    }

    WidgetsBinding.instance.addObserver(this);
    _isObservingLifecycle = true;
  }

  void _stopObservingLifecycle() {
    if (!_isObservingLifecycle) {
      return;
    }

    WidgetsBinding.instance.removeObserver(this);
    _isObservingLifecycle = false;
  }

  void dispose() {
    _stopObservingLifecycle();
    _appOpenAd?.dispose();
    _appOpenAd = null;
  }
}
