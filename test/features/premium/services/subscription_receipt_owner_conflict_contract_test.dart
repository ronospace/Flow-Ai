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

  test('backend receipt ownership conflict remains fail closed', () {
    expect(receipt, contains("data?['error'] is String"));
    expect(service, contains('validationResult?.errorMessage?.trim()'));
    expect(service, contains('_lastReceiptValidationError'));
  });

  test('restore exposes explicit account ownership conflict', () {
    expect(provider, contains("'receipt_owner_conflict'"));
    expect(
      provider,
      contains('This subscription is linked to a different Flow Ai account. '),
    );
    expect(
      provider,
      contains('Sign in with the Flow Ai account that owns the subscription.'),
    );
    expect(paywall, contains('provider.restoreOwnershipErrorMessage'));
  });

  test('temporary receipt diagnostics are removed', () {
    expect(receipt, isNot(contains('FLOW_AI_RECEIPT_DIAGNOSTICS')));
    expect(receipt, isNot(contains('FLOW_RECEIPT_DIAGNOSTIC')));
    expect(service, isNot(contains('diagnosticAuthenticatedUserId')));
    expect(paywall, isNot(contains('UID: \$userId')));
  });

  test('receipt ownership conflict blocks checkout before store launch', () {
    final purchaseStart = service.indexOf(
      'Future<PurchaseResult> purchaseSubscription(String productId) async {',
    );
    final purchaseEnd = service.indexOf(
      '/// Handle purchase updates',
      purchaseStart,
    );

    expect(purchaseStart, greaterThanOrEqualTo(0));
    expect(purchaseEnd, greaterThan(purchaseStart));

    final body = service.substring(purchaseStart, purchaseEnd);
    final conflict = body.indexOf(
      "_lastReceiptValidationError == 'receipt_owner_conflict'",
    );
    final checkout = body.indexOf('_iap.buyNonConsumable(');

    expect(conflict, greaterThanOrEqualTo(0));
    expect(checkout, greaterThan(conflict));
    expect(
      body,
      contains(
        'This App Store subscription is linked to a different Flow Ai account.',
      ),
    );
  });

  test('receipt ownership protection is never bypassed client side', () {
    expect(service, isNot(contains("receipt_owner_conflict' => true")));
    expect(service, isNot(contains('grantsActiveEntitlement = true')));
  });
}
