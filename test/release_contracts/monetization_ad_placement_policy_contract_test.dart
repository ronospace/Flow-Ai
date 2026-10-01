import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Flow Ai advertising placement policy', () {
    late String ads;
    late String router;
    late String main;

    setUpAll(() {
      ads = File('lib/core/services/admob_service.dart').readAsStringSync();

      router = File('lib/core/routing/app_router.dart').readAsStringSync();

      main = File('lib/main.dart').readAsStringSync();
    });

    test('banner is limited to Home and Insights', () {
      expect(ads, contains('_bannerAllowedRoutes'));
      expect(ads, contains("'/home'"));
      expect(ads, contains("'/insights'"));
      expect(ads, contains('canShowBannerOnRoute'));
      expect(router, contains('AdMobService.canShowBannerOnRoute'));
    });

    test('health and sensitive flows explicitly reject ads', () {
      for (final route in <String>[
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
      ]) {
        expect(ads, contains("'$route'"));
      }
    });

    test('interstitial has one audited navigation transition', () {
      expect(ads, contains("fromRoute == '/insights' && toRoute == '/home'"));
      expect(
        router,
        contains("fromRoute == '/insights' && toRoute == '/home'"),
      );
      expect(router, contains('showInterstitialAdWithFrequency('));
    });

    test('interstitial is conservatively frequency limited', () {
      expect(
        ads,
        contains(
          'static const Duration _minimumInterstitialSessionAge = '
          'Duration(minutes: 2)',
        ),
      );
      expect(
        ads,
        contains(
          'static const Duration _minInterstitialInterval = '
          'Duration(minutes: 10)',
        ),
      );
    });

    test('rewarded remains dormant without a truthful value exchange', () {
      expect(main, isNot(contains('adMobService.loadRewardedAd();')));

      expect(
        File(
          'lib/features/cycle/widgets/premium_insights_unlock_card.dart',
        ).existsSync(),
        isFalse,
      );

      expect(
        ads,
        contains('void loadRewardedAd()'),
        reason:
            'Existing format owner remains available for a future '
            'audited value exchange.',
      );
    });

    test('unsupported formats remain unimplemented', () {
      expect(ads, isNot(contains('AppOpenAd.load(')));
      expect(ads, isNot(contains('NativeAd(')));
      expect(ads, isNot(contains('RewardedInterstitialAd.load(')));
    });
  });
}
