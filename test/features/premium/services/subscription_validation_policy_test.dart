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
          contains('Secure purchase validation is temporarily unavailable.'),
        );
        expect(subscriptionService, contains('_validatePurchase'));
        expect(
          subscriptionService,
          contains('validationResult?.isValid == true'),
        );
        expect(subscriptionService, contains('validateAppleReceipt'));
        expect(subscriptionService, contains('validateGooglePlayReceipt'));
        expect(subscriptionService, contains('PackageInfo.fromPlatform'));
        expect(subscriptionService, contains('_currentSubscription?.userId'));
        expect(subscriptionService, contains('purchaseDetails.purchaseID'));
        expect(
          subscriptionService,
          contains('Missing App Store transaction identifier'),
        );
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

    test('uses the authenticated isolated receipt service only', () {
      expect(
        receiptValidationService,
        contains('FLOW_AI_RECEIPT_SERVICE_BASE_URL'),
      );
      expect(
        receiptValidationService,
        contains('package:firebase_auth/firebase_auth.dart'),
      );
      expect(receiptValidationService, contains('FirebaseAuth.instance'));
      expect(receiptValidationService, contains('getIdToken(forceRefresh)'));
      expect(
        receiptValidationService,
        contains("'Authorization': 'Bearer \$token'"),
      );
      expect(receiptValidationService, contains("'v1', 'receipts', 'apple'"));
      expect(receiptValidationService, contains("'v1', 'receipts', 'google'"));
      expect(receiptValidationService, contains("'v1', 'subscriptions'"));
      expect(
        subscriptionService,
        contains('_receiptValidationService.isAuthenticatedUser(userId)'),
      );

      for (final forbidden in <String>[
        'sandbox.itunes.apple.com/verifyReceipt',
        'buy.itunes.apple.com/verifyReceipt',
        '_validateWithAppleDirect',
        'FLOW_AI_APPLE_RECEIPT_VALIDATION_ENDPOINT',
        'FLOW_AI_GOOGLE_RECEIPT_VALIDATION_ENDPOINT',
        'FLOW_AI_SUBSCRIPTION_STATUS_ENDPOINT',
        "'userId':",
      ]) {
        expect(
          receiptValidationService,
          isNot(contains(forbidden)),
          reason: 'Legacy receipt token remained: $forbidden',
        );
      }

      expect(receiptValidationService, contains("'receipt': purchaseToken"));
      expect(receiptValidationService, contains("'platform': 'android'"));
      expect(
        receiptValidationService,
        isNot(contains("'purchaseToken': purchaseToken")),
      );

      expect(receiptValidationService, isNot(contains('debugPrint(')));
      expect(receiptValidationService, isNot(contains('print(')));
      expect(subscriptionService, contains('isProduction: kReleaseMode'));
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

    test('legacy PremiumService does not grant entitlement locally', () {
      final premiumService = File(
        'lib/features/premium/services/premium_service.dart',
      ).readAsStringSync();

      const forbidden = <String>[
        'await _loadCurrentSubscription();',
        "getString('current_subscription')",
        "setString('current_subscription'",
        'Mock payment processing',
        'return true; // Mock success',
        'status: SubscriptionStatus.active,',
        'await _unlockPremiumFeatures(tier);',
        r"feature_${feature.name}_unlocked",
        '_preferences.setBool(',
        '_restoreFromStore',
        'Mock restoration',
        'await _handleAutoRenewal(subscription);',
      ];

      for (final token in forbidden) {
        expect(
          premiumService.contains(token),
          isFalse,
          reason:
              'Legacy PremiumService local entitlement token remained: $token',
        );
      }

      expect(
        premiumService,
        contains('Legacy PremiumService purchase path disabled'),
      );
      expect(
        premiumService,
        contains('Legacy PremiumService restore path disabled'),
      );
      expect(premiumService, contains('backend-validated SubscriptionService'));
    });

    test('uses one secure build-time Cloud Run base URL', () {
      expect(receiptValidationService, contains('String.fromEnvironment'));
      expect(
        receiptValidationService,
        contains('FLOW_AI_RECEIPT_SERVICE_BASE_URL'),
      );
      expect(receiptValidationService, contains("uri.scheme == 'https'"));
      expect(receiptValidationService, contains('Uri.tryParse'));

      for (final forbidden in <String>[
        'FLOW_AI_APPLE_RECEIPT_VALIDATION_ENDPOINT',
        'FLOW_AI_GOOGLE_RECEIPT_VALIDATION_ENDPOINT',
        'FLOW_AI_SUBSCRIPTION_STATUS_ENDPOINT',
      ]) {
        expect(receiptValidationService, isNot(contains(forbidden)));
      }
    });

    test('premium restore uses authenticated user identity', () {
      final premiumPaywallScreen = File(
        'lib/features/premium/screens/premium_paywall_screen.dart',
      ).readAsStringSync();

      const forbidden = <String>[
        "const userId = 'current_user_id';",
        'TODO: Get from auth provider',
      ];

      for (final token in forbidden) {
        expect(
          premiumPaywallScreen.contains(token),
          isFalse,
          reason: 'Unsafe restore identity token remained: $token',
        );
      }

      expect(premiumPaywallScreen, contains("context.read<AppStateService>()"));
      expect(premiumPaywallScreen, contains('_resolveCurrentUserId'));
      expect(premiumPaywallScreen, contains('auth.getCurrentUser()'));
      expect(premiumPaywallScreen, contains('auth.initialize()'));
      expect(premiumPaywallScreen, contains("'uid'"));
      expect(premiumPaywallScreen, contains("'id'"));
      expect(
        premiumPaywallScreen,
        contains('Please sign in before restoring purchases.'),
      );
      expect(
        premiumPaywallScreen,
        contains('provider.restorePurchases(userId)'),
      );
    });

    test('persists subscription state as valid JSON only', () {
      const forbidden = <String>[
        'TODO: Implement proper JSON serialization',
        '_currentSubscription!.toJson().toString()',
      ];

      for (final token in forbidden) {
        expect(
          subscriptionService.contains(token),
          isFalse,
          reason: 'Unsafe subscription persistence token remained: $token',
        );
      }

      expect(subscriptionService, contains("import 'dart:convert';"));
      expect(subscriptionService, contains('jsonEncode('));
      expect(
        subscriptionService,
        contains("await prefs.setString(\n      'user_subscription',"),
      );
    });

    test(
      'loads persisted subscription only after backend status verification',
      () {
        const forbidden = <String>[
          "final subscriptionJson = prefs.getString('user_subscription');",
          'Subscription restored from storage',
        ];

        for (final token in forbidden) {
          expect(
            subscriptionService.contains(token),
            isFalse,
            reason: 'Unsafe entitlement refresh token remained: $token',
          );
        }

        expect(
          subscriptionService,
          contains('await _loadBackendVerifiedSubscription(userId);'),
        );
        expect(
          subscriptionService,
          contains('_loadBackendVerifiedSubscription(String userId)'),
        );
        expect(subscriptionService, contains('canValidateSubscriptionStatus'));
        expect(
          subscriptionService,
          contains("prefs.getString('user_subscription')"),
        );
        expect(subscriptionService, contains('jsonDecode(storedSubscription)'));
        expect(
          subscriptionService,
          contains('UserSubscription.fromJson(decoded)'),
        );
        expect(subscriptionService, contains('verifySubscriptionActive('));
        expect(subscriptionService, contains('isActive'));
        expect(subscriptionService, contains('? candidate'));
        expect(
          subscriptionService,
          contains(': UserSubscription.free(userId)'),
        );
      },
    );

    test('store builds inject one receipt service base URL', () {
      final scripts = <String>[
        File('build_appstore.sh').readAsStringSync(),
        File('scripts/deploy-android.sh').readAsStringSync(),
        File('scripts/deploy-all.sh').readAsStringSync(),
      ];

      for (final script in scripts) {
        expect(script, contains('REQUIRED_DART_DEFINES='));
        expect(script, contains('FLOW_AI_RECEIPT_SERVICE_BASE_URL'));
        expect(
          script,
          contains('--dart-define=FLOW_AI_RECEIPT_SERVICE_BASE_URL='),
        );

        for (final legacyDefine in <String>[
          'FLOW_AI_APPLE_RECEIPT_VALIDATION_ENDPOINT',
          'FLOW_AI_GOOGLE_RECEIPT_VALIDATION_ENDPOINT',
          'FLOW_AI_SUBSCRIPTION_STATUS_ENDPOINT',
        ]) {
          expect(script, isNot(contains(legacyDefine)));
        }
      }
    });

    test('isolated receipt service authenticates and persists entitlement', () {
      final backend = File(
        'services/receipt-service/src/index.ts',
      ).readAsStringSync();

      for (final token in <String>[
        'createRemoteJWKSet',
        'jwtVerify',
        'requireFirebaseUid',
        'generateAccessToken',
        'androidpublisher',
        'premiumEntitlements',
        'allowedProducts',
        'FLOW_AI_APPLE_ISSUER_ID_NEXT',
        'FLOW_AI_GOOGLE_PLAY_SERVICE_ACCOUNT',
        'valid: true',
        'active: true',
      ]) {
        expect(backend, contains(token));
      }

      for (final forbidden in <String>[
        'body.userId',
        'body.uid',
        'FLOW_AI_GOOGLE_SERVICE_ACCOUNT_JSON',
        'firebase-admin',
        'firebase-functions',
      ]) {
        expect(backend, isNot(contains(forbidden)));
      }
    });
  });
}
