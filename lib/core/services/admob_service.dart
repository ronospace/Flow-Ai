import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();

  factory AdMobService() => _instance;

  AdMobService._internal();

  static const String _testInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewarded = 'ca-app-pub-3940256099942544/5224354917';

  static const String _androidInterstitial =
      'ca-app-pub-8707491489514576/8812021403';
  static const String _androidRewarded =
      'ca-app-pub-8707491489514576/7894240148';

  static const String _iosInterstitial =
      'ca-app-pub-8707491489514576/4558432692';
  static const String _iosRewarded = 'ca-app-pub-8707491489514576/2833485150';

  static const bool _configured = bool.fromEnvironment(
    'ENABLE_ADS',
    defaultValue: true,
  );

  static bool _canRequestAds = false;
  static bool _sdkInitialized = false;
  static Future<void>? _initialization;

  static bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static bool get adsEnabled =>
      _configured && _supported && _canRequestAds && _sdkInitialized;

  static bool get _useTestAds =>
      kDebugMode &&
      const bool.fromEnvironment('USE_TEST_ADS', defaultValue: true);

  static String get interstitialAdUnitId {
    if (_useTestAds) return _testInterstitial;

    if (defaultTargetPlatform == TargetPlatform.android) {
      return _androidInterstitial;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _iosInterstitial;
    }

    throw UnsupportedError('AdMob platform unsupported');
  }

  static String get rewardedAdUnitId {
    if (_useTestAds) return _testRewarded;

    if (defaultTargetPlatform == TargetPlatform.android) {
      return _androidRewarded;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _iosRewarded;
    }

    throw UnsupportedError('AdMob platform unsupported');
  }

  static const AdRequest _request = AdRequest();

  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;

  bool _interstitialLoading = false;
  bool _interstitialReady = false;
  bool _rewardedLoading = false;
  bool _rewardedReady = false;

  DateTime? _lastInterstitial;
  DateTime? _lastRewarded;

  static Future<void> initialize() async {
    if (!_configured || !_supported) return;

    final existing = _initialization;

    if (existing != null) {
      await existing;
      return;
    }

    final operation = _initializeWithConsent();
    _initialization = operation;

    try {
      await operation;
    } finally {
      _initialization = null;
    }
  }

  static Future<void> _initializeWithConsent() async {
    await _refreshConsentInformation();

    _canRequestAds = await ConsentInformation.instance.canRequestAds();

    if (!_canRequestAds) {
      _instance.dispose();
      return;
    }

    if (!_sdkInitialized) {
      await MobileAds.instance.initialize();
      _sdkInitialized = true;
    }
  }

  static Future<void> _refreshConsentInformation() {
    final completer = Completer<void>();

    void complete() {
      if (!completer.isCompleted) completer.complete();
    }

    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () {
        ConsentForm.loadAndShowConsentFormIfRequired((error) => complete());
      },
      (error) => complete(),
    );

    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: complete,
    );
  }

  static Future<bool> isPrivacyOptionsRequired() async {
    if (!_supported) return false;

    return await ConsentInformation.instance
            .getPrivacyOptionsRequirementStatus() ==
        PrivacyOptionsRequirementStatus.required;
  }

  static Future<FormError?> showPrivacyOptionsForm() {
    final completer = Completer<FormError?>();

    if (!_supported) {
      completer.complete(null);
      return completer.future;
    }

    ConsentForm.showPrivacyOptionsForm((error) async {
      _canRequestAds = await ConsentInformation.instance.canRequestAds();

      if (_canRequestAds && !_sdkInitialized) {
        await MobileAds.instance.initialize();
        _sdkInitialized = true;
      }

      if (!_canRequestAds) {
        _instance.dispose();
      }

      completer.complete(error);
    });

    return completer.future;
  }

  void loadInterstitialAd() {
    if (!adsEnabled || _interstitialLoading || _interstitialReady) {
      return;
    }

    _interstitialLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: _request,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialLoading = false;
          _interstitialReady = true;
          _interstitial = ad;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitial = null;
              _interstitialReady = false;
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitial = null;
              _interstitialReady = false;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _interstitialLoading = false;
          _interstitialReady = false;
        },
      ),
    );
  }

  bool showInterstitialAdWithFrequency() {
    final previous = _lastInterstitial;

    if (previous != null &&
        DateTime.now().difference(previous) < const Duration(minutes: 3)) {
      return false;
    }

    if (!adsEnabled || !_interstitialReady || _interstitial == null) {
      loadInterstitialAd();
      return false;
    }

    final ad = _interstitial;

    _interstitial = null;
    _interstitialReady = false;
    _lastInterstitial = DateTime.now();
    ad!.show();

    return true;
  }

  void loadRewardedAd() {
    if (!adsEnabled || _rewardedLoading || _rewardedReady) {
      return;
    }

    _rewardedLoading = true;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: _request,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedLoading = false;
          _rewardedReady = true;
          _rewarded = ad;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewarded = null;
              _rewardedReady = false;
              loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _rewarded = null;
              _rewardedReady = false;
              loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _rewardedLoading = false;
          _rewardedReady = false;
        },
      ),
    );
  }

  bool showRewardedAdWithFrequency({
    required ValueChanged<RewardItem> onRewarded,
  }) {
    final previous = _lastRewarded;

    if (previous != null &&
        DateTime.now().difference(previous) < const Duration(minutes: 1)) {
      return false;
    }

    if (!adsEnabled || !_rewardedReady || _rewarded == null) {
      loadRewardedAd();
      return false;
    }

    final ad = _rewarded;

    _rewarded = null;
    _rewardedReady = false;
    _lastRewarded = DateTime.now();

    ad!.show(
      onUserEarnedReward: (ad, reward) {
        onRewarded(reward);
      },
    );

    return true;
  }

  void dispose() {
    _interstitial?.dispose();
    _rewarded?.dispose();

    _interstitial = null;
    _rewarded = null;
    _interstitialLoading = false;
    _interstitialReady = false;
    _rewardedLoading = false;
    _rewardedReady = false;
  }
}
