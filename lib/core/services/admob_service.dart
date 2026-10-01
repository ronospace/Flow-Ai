import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_consent_service.dart';
import 'production_analytics_service.dart';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  // Android production ad units (App ID: ca-app-pub-8707491489514576~2318954189)
  static const String _androidBannerAdUnitId =
      'ca-app-pub-8707491489514576/7416449761';
  static const String _androidInterstitialAdUnitId =
      'ca-app-pub-8707491489514576/3438849765';
  static const String _androidRewardedAdUnitId =
      'ca-app-pub-8707491489514576/6804213858';
  // ignore: unused_field
  static const String _androidAppOpenAdUnitId =
      'ca-app-pub-8707491489514576/5736358977';
  // ignore: unused_field
  static const String _androidNativeAdUnitId =
      'ca-app-pub-8707491489514576/3748489887';
  // ignore: unused_field
  static const String _androidRewardedInterstitialAdUnitId =
      'ca-app-pub-8707491489514576/5061571550';

  // iOS production ad units (App ID: ca-app-pub-8707491489514576~3053779336)
  static const String _iosBannerAdUnitId =
      'ca-app-pub-8707491489514576/9591267529';
  static const String _iosInterstitialAdUnitId =
      'ca-app-pub-8707491489514576/8812021403';
  static const String _iosRewardedAdUnitId =
      'ca-app-pub-8707491489514576/7894240148';
  // ignore: unused_field
  static const String _iosAppOpenAdUnitId =
      'ca-app-pub-8707491489514576/7498939737';
  // ignore: unused_field
  static const String _iosNativeAdUnitId =
      'ca-app-pub-8707491489514576/2837639998';
  // ignore: unused_field
  static const String _iosRewardedInterstitialAdUnitId =
      'ca-app-pub-8707491489514576/8114534323';

  // Production ads are enabled only in release builds.
  static bool get adsEnabled => const bool.fromEnvironment(
    'FLOW_AI_ENABLE_ADS',
    defaultValue: kReleaseMode,
  );

  static Future<void>? _initialization;
  static bool _mobileAdsInitialized = false;
  static bool _consentListenerAttached = false;
  static final ValueNotifier<int> readinessRevision = ValueNotifier<int>(0);

  static void _notifyReadinessChanged() {
    readinessRevision.value++;
  }

  // Ads fail closed until authoritative subscription entitlement resolves.
  // SubscriptionProvider is the entitlement owner; AdMobService only enforces
  // the resulting ad-suppression policy.
  static bool _adsSuppressedByEntitlement = true;

  static bool get canLoadAds =>
      adsEnabled &&
      !_adsSuppressedByEntitlement &&
      AdConsentService.instance.canRequestAds &&
      _mobileAdsInitialized;

  static const Set<String> _bannerAllowedRoutes = {'/home', '/insights'};

  static const Set<String> _noAdRoutePrefixes = {
    '/auth',
    '/onboarding',
    '/calendar',
    '/cycle',
    '/tracking',
    '/health',
    '/premium',
    '/settings',
    '/account',
    '/partner',
  };

  static bool _isSensitiveRoute(String route) {
    return _noAdRoutePrefixes.any(
      (prefix) => route == prefix || route.startsWith('$prefix/'),
    );
  }

  static bool canShowBannerOnRoute(String route) {
    return canLoadAds &&
        !_isSensitiveRoute(route) &&
        _bannerAllowedRoutes.contains(route);
  }

  static bool canShowInterstitialTransition({
    required String fromRoute,
    required String toRoute,
  }) {
    if (!canLoadAds) return false;
    if (_isSensitiveRoute(fromRoute) || _isSensitiveRoute(toRoute)) {
      return false;
    }

    return fromRoute == '/insights' && toRoute == '/home';
  }

  void setPremiumSuppressed(bool suppressed) {
    if (_adsSuppressedByEntitlement == suppressed) {
      if (suppressed) {
        _disposeLoadedAds();
      }
      return;
    }

    _adsSuppressedByEntitlement = suppressed;
    _notifyReadinessChanged();

    if (suppressed) {
      _disposeLoadedAds();
      return;
    }

    // Free entitlement may resolve after Mobile Ads/consent initialization.
    // Preload only when both platform consent and entitlement now permit ads.
    if (canLoadAds) {
      loadInterstitialAd();
    }
  }

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
  bool _interstitialLoadInFlight = false;
  int _interstitialLoadGeneration = 0;

  // Rewarded ad variables
  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;
  bool _rewardedLoadInFlight = false;
  int _rewardedLoadGeneration = 0;

  static void _ensureConsentListener() {
    if (_consentListenerAttached) return;

    AdConsentService.instance.addListener(_onConsentEligibilityChanged);
    _consentListenerAttached = true;
  }

  static void _onConsentEligibilityChanged() {
    _notifyReadinessChanged();

    if (!AdConsentService.instance.canRequestAds) {
      // Consent withdrawal must immediately invalidate every loaded or
      // in-flight fullscreen ad. Banner ownership independently re-evaluates
      // canLoadAds from MainShell.
      AdMobService()._disposeLoadedAds();
      return;
    }

    // Consent may become available after startup. Resume Mobile Ads
    // initialization without requiring an app restart or another caller.
    if (!_mobileAdsInitialized) {
      unawaited(initialize());
      return;
    }

    // Free entitlement may already be resolved when consent is granted.
    if (canLoadAds) {
      AdMobService().loadInterstitialAd();
    }
  }

  // Initialize consent first, then Mobile Ads exactly once.
  static Future<void> initialize() {
    if (!adsEnabled) {
      return Future<void>.value();
    }

    _ensureConsentListener();

    if (_mobileAdsInitialized) {
      return Future<void>.value();
    }

    return _initialization ??= _initializeOnce().whenComplete(() {
      _initialization = null;
    });
  }

  static Future<void> _initializeOnce() async {
    final consentAllowsAds = await AdConsentService.instance.gatherConsent();

    if (!consentAllowsAds || _mobileAdsInitialized) return;

    await MobileAds.instance.initialize();
    _mobileAdsInitialized = true;

    _notifyReadinessChanged();
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
          ProductionAnalyticsService().trackAdLifecycle(
            'loaded',
            format: 'banner',
          );
          // Entitlement or consent can change while this request is in flight.
          if (!canLoadAds) {
            ad.dispose();
            return;
          }

          onLoaded(ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          ProductionAnalyticsService().trackAdLifecycle(
            'load_failed',
            format: 'banner',
          );
          ad.dispose();
          onFailedToLoad(error);
        },
        onAdOpened: (ad) {},
        onAdClosed: (ad) {},
      ),
    );
  }

  // Load interstitial ad
  void loadInterstitialAd() {
    if (!canLoadAds ||
        _interstitialLoadInFlight ||
        _isInterstitialAdReady ||
        _interstitialAd != null) {
      return;
    }

    _interstitialLoadInFlight = true;
    final generation = ++_interstitialLoadGeneration;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ProductionAnalyticsService().trackAdLifecycle(
            'loaded',
            format: 'interstitial',
          );
          if (generation != _interstitialLoadGeneration) {
            ad.dispose();
            return;
          }

          _interstitialLoadInFlight = false;

          if (!canLoadAds) {
            ad.dispose();
            return;
          }

          // Never overwrite an already-owned ready ad.
          if (_interstitialAd != null || _isInterstitialAdReady) {
            ad.dispose();
            return;
          }

          _interstitialAd = ad;
          _isInterstitialAdReady = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              _isInterstitialAdReady = false;
            },
            onAdDismissedFullScreenContent: (ad) {
              ProductionAnalyticsService().trackAdLifecycle(
                'dismissed',
                format: 'interstitial',
              );
              ad.dispose();
              if (identical(_interstitialAd, ad)) {
                _interstitialAd = null;
              }
              _isInterstitialAdReady = false;
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ProductionAnalyticsService().trackAdLifecycle(
                'show_failed',
                format: 'interstitial',
              );
              ad.dispose();
              if (identical(_interstitialAd, ad)) {
                _interstitialAd = null;
              }
              _isInterstitialAdReady = false;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          ProductionAnalyticsService().trackAdLifecycle(
            'load_failed',
            format: 'interstitial',
          );
          if (generation == _interstitialLoadGeneration) {
            _interstitialLoadInFlight = false;
            _isInterstitialAdReady = false;
          }
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

    loadInterstitialAd();
    return false;
  }

  // Load rewarded ad
  void loadRewardedAd() {
    if (!canLoadAds ||
        _rewardedLoadInFlight ||
        _isRewardedAdReady ||
        _rewardedAd != null) {
      return;
    }

    _rewardedLoadInFlight = true;
    final generation = ++_rewardedLoadGeneration;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ProductionAnalyticsService().trackAdLifecycle(
            'loaded',
            format: 'rewarded',
          );
          if (generation != _rewardedLoadGeneration) {
            ad.dispose();
            return;
          }

          _rewardedLoadInFlight = false;

          if (!canLoadAds) {
            ad.dispose();
            return;
          }

          if (_rewardedAd != null || _isRewardedAdReady) {
            ad.dispose();
            return;
          }

          _rewardedAd = ad;
          _isRewardedAdReady = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              _isRewardedAdReady = false;
            },
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              if (identical(_rewardedAd, ad)) {
                _rewardedAd = null;
              }
              _isRewardedAdReady = false;
              loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              if (identical(_rewardedAd, ad)) {
                _rewardedAd = null;
              }
              _isRewardedAdReady = false;
              loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          ProductionAnalyticsService().trackAdLifecycle(
            'load_failed',
            format: 'rewarded',
          );
          if (generation == _rewardedLoadGeneration) {
            _rewardedLoadInFlight = false;
            _isRewardedAdReady = false;
          }
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
          onRewarded(reward);
        },
      );
      return true;
    }

    loadRewardedAd();
    return false;
  }

  // Check if interstitial ad is ready
  bool get isInterstitialAdReady => _isInterstitialAdReady;

  // Check if rewarded ad is ready
  bool get isRewardedAdReady => _isRewardedAdReady;

  void _disposeLoadedAds() {
    _interstitialLoadGeneration++;
    _rewardedLoadGeneration++;
    _interstitialLoadInFlight = false;
    _rewardedLoadInFlight = false;
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();

    _interstitialAd = null;
    _rewardedAd = null;
    _isInterstitialAdReady = false;
    _isRewardedAdReady = false;
  }

  // Dispose ads without changing the authoritative entitlement policy.
  void dispose() {
    _disposeLoadedAds();
  }

  // Ad frequency management
  static final DateTime _adSessionStartedAt = DateTime.now();
  static DateTime? _lastInterstitialShown;
  static DateTime? _lastRewardedShown;

  static const Duration _minimumInterstitialSessionAge = Duration(minutes: 2);
  static const Duration _minInterstitialInterval = Duration(minutes: 10);
  static const Duration _minRewardedInterval = Duration(minutes: 1);

  bool canShowInterstitialAd() {
    if (DateTime.now().difference(_adSessionStartedAt) <
        _minimumInterstitialSessionAge) {
      return false;
    }

    if (_lastInterstitialShown == null) return true;

    return DateTime.now().difference(_lastInterstitialShown!) >=
        _minInterstitialInterval;
  }

  bool canShowRewardedAd() {
    if (_lastRewardedShown == null) return true;
    return DateTime.now().difference(_lastRewardedShown!) >=
        _minRewardedInterval;
  }

  bool showInterstitialAdWithFrequency({
    required String fromRoute,
    required String toRoute,
  }) {
    if (!canShowInterstitialTransition(
      fromRoute: fromRoute,
      toRoute: toRoute,
    )) {
      return false;
    }

    if (!canShowInterstitialAd()) return false;

    if (showInterstitialAd()) {
      _lastInterstitialShown = DateTime.now();
      return true;
    }

    return false;
  }

  void showRewardedAdWithFrequency({required Function(RewardItem) onRewarded}) {
    if (canShowRewardedAd() && showRewardedAd(onRewarded: onRewarded)) {
      _lastRewardedShown = DateTime.now();
    }
  }
}
