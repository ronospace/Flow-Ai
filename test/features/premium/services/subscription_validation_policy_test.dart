import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Premium purchase validation policy', () {
    late String subscriptionService;
    late String receiptValidationService;

    setUpAll(() {
      subscriptionService = File(
        'lib/features/premium/services/subscription_service.dart',
      ).readAsStringSync();

      receiptValidationService = File(
        'lib/features/premium/services/receipt_validation_service.dart',
      ).readAsStringSync();
    });

    test(
      'does not grant Premium from local receipt, token, or storage alone',
      () {
        const forbidden = <String>[
          'For now, we\'ll trust the store',
          'return receipt.isNotEmpty',
          'return purchaseToken.isNotEmpty',
          'TODO: Send to backend for verification',
          'Future<bool> _verifyPurchase',
          'await _grantPremiumAccess(purchaseDetails);',
          "final subscriptionJson = prefs.getString('user_subscription');",
          'Subscription restored from storage',
          '\n          _handlePurchased(purchaseDetails);\n',
          '\n        _iap.completePurchase(purchaseDetails);\n',
        ];

        for (final token in forbidden) {
          expect(
            subscriptionService.contains(token),
            isFalse,
            reason: 'Unsafe subscription token remained: $token',
          );
        }

        expect(subscriptionService, contains('ReceiptValidationService'));
        expect(
          subscriptionService,
          contains('_isPurchaseValidationConfigured'),
        );
        expect(
          subscriptionService,
          contains('Secure purchase validation is not configured'),
        );
        expect(subscriptionService, contains('_validatePurchase'));
        expect(
          subscriptionService,
          contains('validationResult?.isValid == true'),
        );
        expect(subscriptionService, contains('validateAppleReceipt'));
        expect(subscriptionService, contains('validateGooglePlayReceipt'));
        expect(subscriptionService, contains('PackageInfo.fromPlatform'));
        expect(
          subscriptionService,
          contains('backend validation before Premium is granted'),
        );
        expect(subscriptionService, contains('unawaited(_onPurchaseUpdate'));
        expect(
          subscriptionService,
          contains('await _handlePurchased(purchaseDetails)'),
        );
        expect(
          subscriptionService,
          contains('await _iap.completePurchase(purchaseDetails)'),
        );
      },
    );

    test('does not validate App Store receipts directly from the client', () {
      const forbidden = <String>[
        'sandbox.itunes.apple.com/verifyReceipt',
        'buy.itunes.apple.com/verifyReceipt',
        'Direct validation with Apple',
        'fallback, less secure',
        'App-Specific Shared Secret',
        '\'password\': \'\'',
        '_validateWithAppleDirect',
        '_appleSandboxUrl',
        '_appleProductionUrl',
        '_parseAppleDate',
        '_getAppleErrorMessage',
      ];

      for (final token in forbidden) {
        expect(
          receiptValidationService.contains(token),
          isFalse,
          reason: 'Unsafe receipt token remained: $token',
        );
      }

      expect(
        receiptValidationService,
        contains('Validate App Store receipt through Flow AI backend only'),
      );
      expect(
        receiptValidationService,
        contains('Backend validation unavailable'),
      );
      expect(receiptValidationService, contains('_validateThroughBackend'));
      expect(receiptValidationService, contains('canValidateAppleReceipts'));
      expect(
        receiptValidationService,
        contains('canValidateGooglePlayReceipts'),
      );
      expect(receiptValidationService, contains('validateAppleReceipt'));
      expect(receiptValidationService, contains('validateGooglePlayReceipt'));
    });

    test('does not expose trusted hardcoded client pricing', () {
      final sourceByFile = <String, String>{
        'subscription.dart': File(
          'lib/features/premium/models/subscription.dart',
        ).readAsStringSync(),
        'subscription_plan.dart': File(
          'lib/features/premium/models/subscription_plan.dart',
        ).readAsStringSync(),
        'premium_paywall_screen.dart': File(
          'lib/features/premium/screens/premium_paywall_screen.dart',
        ).readAsStringSync(),
        'premium_subscription_screen.dart': File(
          'lib/features/premium/screens/premium_subscription_screen.dart',
        ).readAsStringSync(),
        'premium_service.dart': File(
          'lib/features/premium/services/premium_service.dart',
        ).readAsStringSync(),
        'subscription_analytics_service.dart': File(
          'lib/features/premium/services/subscription_analytics_service.dart',
        ).readAsStringSync(),
        'subscription_service.dart': File(
          'lib/features/premium/services/subscription_service.dart',
        ).readAsStringSync(),
        'subscription_provider.dart': File(
          'lib/features/premium/providers/subscription_provider.dart',
        ).readAsStringSync(),
        'subscription_status_widget.dart': File(
          'lib/features/premium/widgets/subscription_status_widget.dart',
        ).readAsStringSync(),
        'subscription_tier_card.dart': File(
          'lib/features/premium/widgets/subscription_tier_card.dart',
        ).readAsStringSync(),
      };

      const forbiddenByFile = <String, List<String>>{
        'subscription.dart': [
          r"basic('Basic', 4.99)",
          r"premium('Premium', 9.99)",
          r"ultimate('Ultimate', 19.99)",
          'final double price;',
          'priceString =>',
        ],
        'subscription_plan.dart': [
          'price: isYearly ? 79.99 : 9.99',
          'price: isYearly ? 119.99 : 14.99',
          'discount: isYearly ? 0.20 : null',
          'currencySymbol',
          'currencyCode',
          'pricePerMonth',
          'getSavingsComparedToMonthly',
          'getSavingsPercentage',
        ],
        'premium_paywall_screen.dart': [
          r'Save ${yearlySavings.toStringAsFixed(0)}%',
          'BEST VALUE',
          'getPricePerMonth().toStringAsFixed(2)',
        ],
        'premium_subscription_screen.dart': [
          'tier.priceString',
          '_selectedTier.priceString',
          'subscription.tier.priceString',
        ],
        'premium_service.dart': ['tier.price'],
        'subscription_analytics_service.dart': [
          'plan.price',
          'plan.currencyCode',
          r"'revenue': plan.price",
        ],
        'subscription_service.dart': ['2 months free!'],
        'subscription_provider.dart': ['calculateYearlySavings'],
        'subscription_status_widget.dart': ['subscription.tier.priceString'],
        'subscription_tier_card.dart': [
          'plan.price',
          'plan.currencySymbol',
          '(plan.price / 12)',
        ],
      };

      for (final entry in forbiddenByFile.entries) {
        final source = sourceByFile[entry.key]!;
        for (final token in entry.value) {
          expect(
            source.contains(token),
            isFalse,
            reason: '${entry.key} still exposes trusted pricing token: $token',
          );
        }
      }

      expect(
        sourceByFile['subscription_service.dart'],
        contains('priceString: product.price'),
      );
      expect(
        sourceByFile['premium_paywall_screen.dart'],
        contains('product.priceString'),
      );
    });

    test(
      'does not duplicate stale product identifiers outside store service',
      () {
        final subscriptionPlan = File(
          'lib/features/premium/models/subscription_plan.dart',
        ).readAsStringSync();
        final subscriptionAnalyticsService = File(
          'lib/features/premium/services/subscription_analytics_service.dart',
        ).readAsStringSync();
        final subscriptionService = File(
          'lib/features/premium/services/subscription_service.dart',
        ).readAsStringSync();

        for (final source in [subscriptionPlan, subscriptionAnalyticsService]) {
          expect(source.contains('com.zyraflow'), isFalse);
          expect(source.contains('plan.productId'), isFalse);
        }

        expect(subscriptionService, contains('monthlyProductId'));
        expect(subscriptionService, contains('yearlyProductId'));
        expect(
          subscriptionService,
          contains('queryProductDetails(_productIds)'),
        );
      },
    );
  });
}
