import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Deployment store pricing policy', () {
    late String deploymentService;
    late String storeProductIds;
    late String subscriptionService;

    setUpAll(() {
      deploymentService = File(
        'lib/features/deployment/services/deployment_service.dart',
      ).readAsStringSync();
      storeProductIds = File(
        'lib/features/premium/constants/store_product_ids.dart',
      ).readAsStringSync();
      subscriptionService = File(
        'lib/features/premium/services/subscription_service.dart',
      ).readAsStringSync();
    });

    test('centralizes paid product identifiers', () {
      expect(storeProductIds, contains('flow_ai_premium_monthly'));
      expect(storeProductIds, contains('flow_ai_premium_yearly'));

      expect(subscriptionService, contains('StoreProductIds.premiumMonthly'));
      expect(subscriptionService, contains('StoreProductIds.premiumYearly'));
      expect(subscriptionService, contains('StoreProductIds.subscriptions'));

      expect(deploymentService, contains('StoreProductIds.premiumMonthly'));
      expect(deploymentService, contains('StoreProductIds.premiumYearly'));

      expect(deploymentService, isNot(contains("'premium_monthly'")));
      expect(deploymentService, isNot(contains("'premium_yearly'")));
      expect(deploymentService, isNot(contains("'premium_features'")));
    });

    test('does not hardcode regional paid prices in deployment metadata', () {
      expect(deploymentService, contains('store-managed regional pricing'));
      expect(deploymentService, contains('inAppPurchases: const []'));
      expect(deploymentService, contains('prices: const {}'));

      for (final token in [
        "'US':",
        "'GB':",
        "'EU':",
        "'CA':",
        "'AU':",
        "'JP':",
        '4.99',
        '19.99',
        '29.99',
        'significant savings',
      ]) {
        expect(
          deploymentService.contains(token),
          isFalse,
          reason:
              'DeploymentService still has stale regional pricing token: $token',
        );
      }
    });
  });
}
