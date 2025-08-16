import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  // Test Ad Unit IDs (use these for development)
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  // Production Ad Unit IDs (replace with your actual IDs when ready for production)
  static const String _prodBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _prodInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _prodRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  // Ad unit getters
  static String get bannerAdUnitId {
    if (kDebugMode) {
      return _testBannerAdUnitId;
    } else {
      return Platform.isAndroid ? _prodBannerAdUnitId : _prodBannerAdUnitId;
    }
  }

  static String get interstitialAdUnitId {
    if (kDebugMode) {
      return _testInterstitialAdUnitId;
    } else {
      return Platform.isAndroid ? _prodInterstitialAdUnitId : _prodInterstitialAdUnitId;
    }
  }

  static String get rewardedAdUnitId {
    if (kDebugMode) {
      return _testRewardedAdUnitId;
    } else {
      return Platform.isAndroid ? _prodRewardedAdUnitId : _prodRewardedAdUnitId;
    }
  }

  // Interstitial ad variables
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  // Rewarded ad variables
  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  // Initialize the Mobile Ads SDK
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    if (kDebugMode) {
      print('🎯 AdMob SDK initialized successfully');
    }
  }

  // Create banner ad
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            print('🎯 Banner ad loaded');
          }
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) {
            print('🎯 Banner ad failed to load: $error');
          }
          ad.dispose();
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
  void showInterstitialAd() {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      if (kDebugMode) {
        print('🎯 Interstitial ad not ready');
      }
      loadInterstitialAd(); // Try loading again
    }
  }

  // Load rewarded ad
  void loadRewardedAd() {
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
  void showRewardedAd({required Function(RewardItem) onRewarded}) {
    if (_isRewardedAdReady && _rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          if (kDebugMode) {
            print('🎯 User earned reward: ${reward.amount} ${reward.type}');
          }
          onRewarded(reward);
        },
      );
    } else {
      if (kDebugMode) {
        print('🎯 Rewarded ad not ready');
      }
      loadRewardedAd(); // Try loading again
    }
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
    return DateTime.now().difference(_lastInterstitialShown!) >= _minInterstitialInterval;
  }

  bool canShowRewardedAd() {
    if (_lastRewardedShown == null) return true;
    return DateTime.now().difference(_lastRewardedShown!) >= _minRewardedInterval;
  }

  void showInterstitialAdWithFrequency() {
    if (canShowInterstitialAd()) {
      showInterstitialAd();
      _lastInterstitialShown = DateTime.now();
    }
  }

  void showRewardedAdWithFrequency({required Function(RewardItem) onRewarded}) {
    if (canShowRewardedAd()) {
      showRewardedAd(onRewarded: onRewarded);
      _lastRewardedShown = DateTime.now();
    }
  }
}
