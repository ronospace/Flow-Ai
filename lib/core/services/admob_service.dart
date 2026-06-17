import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_consent_service.dart';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  // Android production ad units (App ID: ca-app-pub-8707491489514576~2318954189)
  static const String _androidBannerAdUnitId =
      'ca-app-pub-8707491489514576/9591267529';
  static const String _androidInterstitialAdUnitId =
      'ca-app-pub-8707491489514576/8812021403';
  static const String _androidRewardedAdUnitId =
      'ca-app-pub-8707491489514576/7894240148';
  // ignore: unused_field
  static const String _androidAppOpenAdUnitId =
      'ca-app-pub-8707491489514576/7498939737';
  // ignore: unused_field
  static const String _androidNativeAdUnitId =
      'ca-app-pub-8707491489514576/2837639998';
  // ignore: unused_field
  static const String _androidRewardedInterstitialAdUnitId =
      'ca-app-pub-8707491489514576/8114534323';

  // iOS production ad units (App ID: ca-app-pub-8707491489514576~3053779336)
  static const String _iosBannerAdUnitId =
      'ca-app-pub-8707491489514576/4146566820';
  static const String _iosInterstitialAdUnitId =
      'ca-app-pub-8707491489514576/4558432692';
  static const String _iosRewardedAdUnitId =
      'ca-app-pub-8707491489514576/2833485150';
  // ignore: unused_field
  static const String _iosAppOpenAdUnitId =
      'ca-app-pub-8707491489514576/1932269355';
  // ignore: unused_field
  static const String _iosNativeAdUnitId =
      'ca-app-pub-8707491489514576/3245351026';
  // ignore: unused_field
  static const String _iosRewardedInterstitialAdUnitId =
      'ca-app-pub-8707491489514576/2881586612';

  // Production ads are enabled only in release builds.
  static bool get adsEnabled => const bool.fromEnvironment(
    'FLOW_AI_ENABLE_ADS',
    defaultValue: kReleaseMode,
  );

  static Future<void>? _initialization;
  static bool _mobileAdsInitialized = false;
  static bool _consentAllowsAds = false;

  static bool get canLoadAds =>
      adsEnabled && _consentAllowsAds && _mobileAdsInitialized;

  static String get bannerAdUnitId =>
      Platform.isAndroid ? _androidBannerAdUnitId : _iosBannerAdUnitId;

  static String get interstitialAdUnitId => Platform.isAndroid
      ? _androidInterstitialAdUnitId
      : _iosInterstitialAdUnitId;

  static String get rewardedAdUnitId =>
      Platform.isAndroid ? _androidRewardedAdUnitId : _iosRewardedAdUnitId;

  // Interstitial ad variables
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  // Rewarded ad variables
  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  // Initialize consent first, then Mobile Ads exactly once.
  static Future<void> initialize() {
    if (!adsEnabled || _mobileAdsInitialized) {
      return Future<void>.value();
    }

    return _initialization ??= _initializeOnce().whenComplete(() {
      _initialization = null;
    });
  }

  static Future<void> _initializeOnce() async {
    _consentAllowsAds = await AdConsentService.instance.gatherConsent();
    if (!_consentAllowsAds || _mobileAdsInitialized) return;

    await MobileAds.instance.initialize();
    _mobileAdsInitialized = true;

    if (kDebugMode) {
      print('🎯 AdMob initialized after consent verification');
    }
  }

  // Create banner ad
  BannerAd createBannerAd({
    required void Function(BannerAd ad) onLoaded,
    required void Function(LoadAdError error) onFailedToLoad,
  }) {
    if (!canLoadAds) {
      throw StateError('Ads are unavailable until consent permits requests');
    }

    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            print('🎯 Banner ad loaded');
          }
          onLoaded(ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) {
            print('🎯 Banner ad failed to load: $error');
          }
          ad.dispose();
          onFailedToLoad(error);
        },
        onAdOpened: (ad) {
          if (kDebugMode) {
            print('🎯 Banner ad opened');
          }
        },
        onAdClosed: (ad) {
          if (kDebugMode) {
            print('🎯 Banner ad closed');
          }
        },
      ),
    );
  }

  // Load interstitial ad
  void loadInterstitialAd() {
    if (!canLoadAds) return;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              if (kDebugMode) {
                print('🎯 Interstitial ad showed full screen content');
              }
            },
            onAdDismissedFullScreenContent: (ad) {
              if (kDebugMode) {
                print('🎯 Interstitial ad dismissed');
              }
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd(); // Load next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              if (kDebugMode) {
                print('🎯 Interstitial ad failed to show: $error');
              }
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd(); // Load next ad
            },
          );

          if (kDebugMode) {
            print('🎯 Interstitial ad loaded');
          }
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('🎯 Interstitial ad failed to load: $error');
          }
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  // Show interstitial ad
  bool showInterstitialAd() {
    if (!canLoadAds) return false;

    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
      return true;
    }

    if (kDebugMode) {
      print('🎯 Interstitial ad not ready');
    }
    loadInterstitialAd();
    return false;
  }

  // Load rewarded ad
  void loadRewardedAd() {
    if (!canLoadAds) return;
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              if (kDebugMode) {
                print('🎯 Rewarded ad showed full screen content');
              }
            },
            onAdDismissedFullScreenContent: (ad) {
              if (kDebugMode) {
                print('🎯 Rewarded ad dismissed');
              }
              ad.dispose();
              _isRewardedAdReady = false;
              loadRewardedAd(); // Load next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              if (kDebugMode) {
                print('🎯 Rewarded ad failed to show: $error');
              }
              ad.dispose();
              _isRewardedAdReady = false;
              loadRewardedAd(); // Load next ad
            },
          );

          if (kDebugMode) {
            print('🎯 Rewarded ad loaded');
          }
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('🎯 Rewarded ad failed to load: $error');
          }
          _isRewardedAdReady = false;
        },
      ),
    );
  }

  // Show rewarded ad
  bool showRewardedAd({required Function(RewardItem) onRewarded}) {
    if (!canLoadAds) return false;

    if (_isRewardedAdReady && _rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          if (kDebugMode) {
            print('🎯 User earned reward: ${reward.amount} ${reward.type}');
          }
          onRewarded(reward);
        },
      );
      return true;
    }

    if (kDebugMode) {
      print('🎯 Rewarded ad not ready');
    }
    loadRewardedAd();
    return false;
  }

  // Check if interstitial ad is ready
  bool get isInterstitialAdReady => _isInterstitialAdReady;

  // Check if rewarded ad is ready
  bool get isRewardedAdReady => _isRewardedAdReady;

  // Dispose ads
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }

  // Ad frequency management
  static DateTime? _lastInterstitialShown;
  static DateTime? _lastRewardedShown;

  static const Duration _minInterstitialInterval = Duration(minutes: 3);
  static const Duration _minRewardedInterval = Duration(minutes: 1);

  bool canShowInterstitialAd() {
    if (_lastInterstitialShown == null) return true;
    return DateTime.now().difference(_lastInterstitialShown!) >=
        _minInterstitialInterval;
  }

  bool canShowRewardedAd() {
    if (_lastRewardedShown == null) return true;
    return DateTime.now().difference(_lastRewardedShown!) >=
        _minRewardedInterval;
  }

  void showInterstitialAdWithFrequency() {
    if (canShowInterstitialAd() && showInterstitialAd()) {
      _lastInterstitialShown = DateTime.now();
    }
  }

  void showRewardedAdWithFrequency({required Function(RewardItem) onRewarded}) {
    if (canShowRewardedAd() && showRewardedAd(onRewarded: onRewarded)) {
      _lastRewardedShown = DateTime.now();
    }
  }
}
