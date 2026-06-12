import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Premium paywall pricing contract', () {
    test('does not call forbidden provider savings calculation', () {
      final paywall = File(
        'lib/features/premium/screens/premium_paywall_screen.dart',
      ).readAsStringSync();

      expect(paywall, isNot(contains('calculateYearlySavings')));
      expect(paywall, contains('getMonthlyProduct()'));
      expect(paywall, contains('getYearlyProduct()'));
      expect(paywall, contains('hasYearlyBillingOption'));
      expect(paywall, contains('Yearly billing'));
    });

    test('does not expose hardcoded savings or trusted client pricing', () {
      final paywall = File(
        'lib/features/premium/screens/premium_paywall_screen.dart',
      ).readAsStringSync();
      final provider = File(
        'lib/features/premium/providers/subscription_provider.dart',
      ).readAsStringSync();

      expect(provider, isNot(contains('calculateYearlySavings')));
      expect(paywall, isNot(contains('Save 20%')));
      expect(paywall, isNot(contains('Save 30%')));
      expect(paywall, isNot(contains('Save 33%')));
      expect(paywall, isNot(contains('9.99')));
      expect(paywall, isNot(contains('79.99')));
      expect(paywall, isNot(contains('119.99')));
    });
  });
}
