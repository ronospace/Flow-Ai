import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('validated Premium immediately disposes active ads', () {
    final provider = File(
      'lib/features/premium/providers/subscription_provider.dart',
    ).readAsStringSync();

    final assignment = provider.indexOf('_subscription = subscription;');
    final premiumGate = provider.indexOf(
      'if (subscription.isPremium)',
      assignment,
    );
    final disposal = provider.indexOf('AdMobService().dispose();', premiumGate);
    final notification = provider.indexOf('notifyListeners();', disposal);

    expect(assignment, greaterThanOrEqualTo(0));
    expect(premiumGate, greaterThan(assignment));
    expect(disposal, greaterThan(premiumGate));
    expect(notification, greaterThan(disposal));
  });

  test('AdMob disposal clears only active interstitial and rewarded ads', () {
    final ads = File('lib/core/services/admob_service.dart').readAsStringSync();

    expect(ads, contains('_interstitialAd?.dispose();'));
    expect(ads, contains('_rewardedAd?.dispose();'));
  });
}
