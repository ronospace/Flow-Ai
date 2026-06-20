import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Subscription product billing-period integrity', () {
    late String provider;

    setUpAll(() {
      provider = File(
        'lib/features/premium/providers/subscription_provider.dart',
      ).readAsStringSync();
    });

    test('monthly lookup returns null when monthly is unavailable', () {
      expect(
        provider,
        contains('if (product.billingPeriod == BillingPeriod.monthly)'),
      );
      expect(provider, contains('SubscriptionProduct? getMonthlyProduct()'));
    });

    test('yearly lookup returns null when yearly is unavailable', () {
      expect(
        provider,
        contains('if (product.billingPeriod == BillingPeriod.yearly)'),
      );
      expect(provider, contains('SubscriptionProduct? getYearlyProduct()'));
    });

    test('period lookups never substitute a different product', () {
      const oldMonthlyFallback = '''
SubscriptionProduct? getMonthlyProduct() {
    if (_availableProducts.isEmpty) return null;

    return _availableProducts.firstWhere(
      (p) => p.billingPeriod == BillingPeriod.monthly,
      orElse: () => _availableProducts.first,
    );
''';

      const oldYearlyFallback = '''
SubscriptionProduct? getYearlyProduct() {
    if (_availableProducts.isEmpty) return null;

    return _availableProducts.firstWhere(
      (p) => p.billingPeriod == BillingPeriod.yearly,
      orElse: () => _availableProducts.first,
    );
''';

      expect(provider, isNot(contains(oldMonthlyFallback)));
      expect(provider, isNot(contains(oldYearlyFallback)));
    });
  });
}
