import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Premium catalog initialization and resilience contract', () {
    late String paywall;
    late String provider;
    late String service;

    setUpAll(() {
      paywall = File(
        'lib/features/premium/screens/premium_paywall_screen.dart',
      ).readAsStringSync();

      provider = File(
        'lib/features/premium/providers/subscription_provider.dart',
      ).readAsStringSync();

      service = File(
        'lib/features/premium/services/subscription_service.dart',
      ).readAsStringSync();
    });

    test('paywall initializes the subscription provider on entry', () {
      expect(paywall, contains('WidgetsBinding.instance.addPostFrameCallback'));
      expect(paywall, contains('_initializeSubscriptionCatalog()'));
      expect(paywall, contains('await provider.initialize(userId)'));
    });

    test('empty catalogs show a truthful retry state', () {
      expect(paywall, contains('Plans temporarily unavailable'));
      expect(paywall, contains("label: const Text('Try Again')"));
      expect(paywall, contains("ValueKey('premium-catalog-retry')"));
      expect(paywall, contains('provider.availableProducts.isEmpty'));
    });

    test('feature cards do not promise invisible plans', () {
      expect(
        paywall,
        contains('Loading subscription plans for \${feature.title}.'),
      );
      expect(
        paywall,
        contains('_initializeSubscriptionCatalog(forceRefresh: true)'),
      );
    });

    test('provider and service support store product refresh', () {
      expect(provider, contains('Future<void> refreshProducts(String userId)'));
      expect(provider, contains('await _subscriptionService.reloadProducts()'));
      expect(service, contains('Future<void> reloadProducts()'));
      expect(service, contains('await _iap.isAvailable()'));
      expect(service, contains('await _loadProducts()'));
    });

    test('no local prices or fabricated products are introduced', () {
      expect(paywall, isNot(contains('SubscriptionProduct(')));
      expect(paywall, isNot(contains(r'$9.99')));
      expect(paywall, isNot(contains(r'$99.99')));
    });
  });
}
