import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'validated Premium immediately activates authoritative ad suppression',
    () {
      final provider = File(
        'lib/features/premium/providers/subscription_provider.dart',
      ).readAsStringSync();

      final assignment = provider.indexOf('_subscription = subscription;');
      final suppression = provider.indexOf(
        'AdMobService().setPremiumSuppressed(subscription.isPremium);',
        assignment,
      );
      final notification = provider.indexOf('notifyListeners();', suppression);

      expect(assignment, greaterThanOrEqualTo(0));
      expect(suppression, greaterThan(assignment));
      expect(notification, greaterThan(suppression));

      expect(provider, isNot(contains('AdMobService().dispose();')));
    },
  );

  test('Premium suppression centrally clears loaded full-screen ads', () {
    final ads = File('lib/core/services/admob_service.dart').readAsStringSync();

    expect(ads, contains('void setPremiumSuppressed(bool suppressed)'));
    expect(ads, contains('_disposeLoadedAds();'));

    expect(ads, contains('_interstitialAd?.dispose();'));
    expect(ads, contains('_rewardedAd?.dispose();'));

    expect(ads, contains('_interstitialAd = null;'));
    expect(ads, contains('_rewardedAd = null;'));

    expect(ads, contains('_isInterstitialAdReady = false;'));
    expect(ads, contains('_isRewardedAdReady = false;'));
  });
}
