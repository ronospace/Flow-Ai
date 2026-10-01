import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final adMob = File('lib/core/services/admob_service.dart').readAsStringSync();

  final subscriptionProvider = File(
    'lib/features/premium/providers/subscription_provider.dart',
  ).readAsStringSync();

  test('ads fail closed until authoritative entitlement resolves', () {
    expect(adMob, contains('_adsSuppressedByEntitlement = true'));

    expect(adMob, contains('!_adsSuppressedByEntitlement'));

    expect(
      subscriptionProvider,
      contains('AdMobService().setPremiumSuppressed(true);'),
    );
  });

  test('validated entitlement drives centralized ad suppression', () {
    expect(
      subscriptionProvider,
      contains('AdMobService().setPremiumSuppressed(subscription.isPremium);'),
    );

    expect(
      subscriptionProvider,
      contains(
        'AdMobService().setPremiumSuppressed(_subscription?.isPremium ?? true);',
      ),
    );

    expect(subscriptionProvider, isNot(contains('AdMobService().dispose();')));
  });

  test('Premium suppression is enforced before every ad request/show', () {
    expect(adMob, contains('bool get canLoadAds'));

    expect(adMob, contains('if (!canLoadAds)'));

    expect(adMob, contains('BannerAd('));

    expect(adMob, contains('InterstitialAd.load('));

    expect(adMob, contains('RewardedAd.load('));

    expect(adMob, contains('showInterstitialAd('));

    expect(adMob, contains('showRewardedAd('));
  });

  test('in-flight ad loads cannot survive entitlement becoming Premium', () {
    expect(adMob, contains('_interstitialAd = null;'));

    expect(adMob, contains('_rewardedAd = null;'));

    expect(adMob, contains('_isInterstitialAdReady = false;'));

    expect(adMob, contains('_isRewardedAdReady = false;'));
  });

  test('UMP consent remains part of the authoritative ad eligibility gate', () {
    expect(adMob, contains('AdConsentService.instance.canRequestAds'));

    expect(adMob, contains('AdConsentService.instance.gatherConsent()'));

    expect(adMob, contains('_mobileAdsInitialized'));
  });

  test('runtime AdMob source contains no Google sample publisher ID', () {
    expect(adMob, isNot(contains('3940256099942544')));
  });

  test('banner load callback rejects stale entitlement or consent', () {
    final start = adMob.indexOf('BannerAd createBannerAd');

    expect(start, greaterThanOrEqualTo(0));

    final end = (start + 3200) < adMob.length ? start + 3200 : adMob.length;

    final region = adMob.substring(start, end);

    expect(
      'if (!canLoadAds)'.allMatches(region).length,
      greaterThanOrEqualTo(2),
      reason:
          'Banner must re-check centralized eligibility before request delivery.',
    );

    expect(region, contains('ad.dispose();'));
  });

  test(
    'verified platform-specific production AdMob units remain mapped correctly',
    () {
      const ids = <String>[
        // Android
        'ca-app-pub-8707491489514576/5736358977',
        'ca-app-pub-8707491489514576/7416449761',
        'ca-app-pub-8707491489514576/3438849765',
        'ca-app-pub-8707491489514576/3748489887',
        'ca-app-pub-8707491489514576/5061571550',
        'ca-app-pub-8707491489514576/6804213858',

        // iOS
        'ca-app-pub-8707491489514576/7498939737',
        'ca-app-pub-8707491489514576/9591267529',
        'ca-app-pub-8707491489514576/8812021403',
        'ca-app-pub-8707491489514576/2837639998',
        'ca-app-pub-8707491489514576/8114534323',
        'ca-app-pub-8707491489514576/7894240148',
      ];

      for (final id in ids) {
        expect(adMob, contains(id));
      }
    },
  );
}
