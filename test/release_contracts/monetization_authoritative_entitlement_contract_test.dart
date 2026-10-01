import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final gate = File('lib/services/feature_gate.dart').readAsStringSync();

  final premiumService = File(
    'lib/features/premium/services/premium_service.dart',
  ).readAsStringSync();

  test('FeatureGate reads validated SubscriptionProvider entitlement', () {
    expect(gate, contains('context.read<SubscriptionProvider>()'));
    expect(gate, contains('subscriptionProvider.isPremium'));
    expect(gate, isNot(contains('PremiumService')));
  });

  test('ad gate follows the same authoritative entitlement', () {
    expect(
      gate,
      contains(
        'static bool adsEnabled(BuildContext context) => !isPremium(context);',
      ),
    );
  });

  test('legacy PremiumService cannot independently grant purchases', () {
    expect(
      premiumService,
      contains('Legacy PremiumService purchase path disabled'),
    );
    expect(
      premiumService,
      contains('Legacy PremiumService restore path disabled'),
    );
    expect(premiumService, contains('_currentSubscription = null'));
  });
}
