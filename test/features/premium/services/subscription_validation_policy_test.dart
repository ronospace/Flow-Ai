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
  });
}
