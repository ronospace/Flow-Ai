import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final receipt = File(
    'lib/features/premium/services/receipt_validation_service.dart',
  ).readAsStringSync();

  final service = File(
    'lib/features/premium/services/subscription_service.dart',
  ).readAsStringSync();

  final provider = File(
    'lib/features/premium/providers/subscription_provider.dart',
  ).readAsStringSync();

  final paywall = File(
    'lib/features/premium/screens/premium_paywall_screen.dart',
  ).readAsStringSync();

  final models = File(
    'lib/features/premium/models/subscription_models.dart',
  ).readAsStringSync();

  test('release receipt endpoint has a secure compiled default', () {
    expect(receipt, contains("'FLOW_AI_RECEIPT_SERVICE_BASE_URL'"));
    expect(
      receipt,
      contains("'https://flow-ai-receipt-service-v2-ylrxu2v7qq-uc.a.run.app'"),
    );
    expect(receipt, contains('defaultValue:'));
    expect(receipt, contains("uri.scheme == 'https'"));
  });

  test('billing launch result is captured and rejected when false', () {
    expect(RegExp(r'_iap\.buyNonConsumable\(').allMatches(service).length, 1);
    expect(service, contains('final launched = await _iap.buyNonConsumable('));
    expect(service, contains('if (!launched)'));
    expect(service, contains('PurchaseResult.launched()'));
    expect(service, isNot(contains('PurchaseResult(success: true)')));
    expect(models, contains('factory PurchaseResult.launched()'));
  });

  test('purchase launch is not confused with entitlement completion', () {
    expect(
      models,
      contains(
        'Entitlement is still granted only after purchase-stream processing',
      ),
    );
    expect(provider, contains('if (!result.success)'));
    expect(provider, contains('else if (result.subscription != null)'));
    expect(paywall, contains('Premium activates after secure verification.'));
  });

  test('restore waits for validated purchase-stream processing', () {
    expect(service, contains('Completer<bool>? _restoreCompleter;'));
    expect(service, contains('_restoreTimeout'));
    expect(service, contains('await completer.future.timeout('));
    expect(service, contains('restoredValidationSucceeded'));
    expect(service, contains('Future<bool> _handlePurchased('));
    expect(service, isNot(contains('await restorePurchases(userId);')));
  });

  test('premium UI and provider expose professional safe feedback', () {
    expect(provider, isNot(contains("'Purchase error: \${e.toString()}'")));
    expect(
      provider,
      isNot(contains("'Failed to restore purchases: \${e.toString()}'")),
    );
    expect(
      provider,
      contains('We could not start the purchase. Please try again.'),
    );
    expect(
      provider,
      contains('We could not restore purchases. Please try again.'),
    );
    expect(paywall, contains('result.errorMessage'));
    expect(paywall, contains('No purchases found to restore'));
  });
}
