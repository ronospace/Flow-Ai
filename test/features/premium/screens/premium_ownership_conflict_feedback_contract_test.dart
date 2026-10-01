import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final provider = File(
    'lib/features/premium/providers/subscription_provider.dart',
  ).readAsStringSync();

  final paywall = File(
    'lib/features/premium/screens/premium_paywall_screen.dart',
  ).readAsStringSync();

  final service = File(
    'lib/features/premium/services/subscription_service.dart',
  ).readAsStringSync();

  test('ownership conflict has one platform-neutral user message', () {
    expect(
      provider,
      contains('This subscription is linked to a different Flow Ai account. '),
    );
    expect(
      provider,
      contains('Sign in with the Flow Ai account that owns the subscription.'),
    );
    expect(provider, isNot(contains('This App Store subscription is linked')));
  });

  test('Start Premium visibly handles existing ownership conflict', () {
    expect(
      paywall,
      contains('final ownershipConflict = provider.ownershipConflictMessage;'),
    );
    expect(
      paywall,
      contains('_showRestoreStatus(ownershipConflict, autoClear: false);'),
    );
    expect(
      paywall,
      contains('AdaptiveMessages.showError(context, ownershipConflict);'),
    );
  });

  test('async checkout failure also exposes ownership conflict', () {
    expect(
      paywall,
      contains('final ownershipConflict = provider.ownershipConflictMessage;'),
    );
    expect(paywall, contains('messenger?.context ?? navigator.context'));
  });

  test('receipt ownership security still blocks before store launch', () {
    final purchaseStart = service.indexOf(
      'Future<PurchaseResult> purchaseSubscription(String productId) async {',
    );
    final purchaseEnd = service.indexOf(
      '/// Handle purchase updates',
      purchaseStart,
    );

    expect(purchaseStart, greaterThanOrEqualTo(0));
    expect(purchaseEnd, greaterThan(purchaseStart));

    final purchaseBody = service.substring(purchaseStart, purchaseEnd);

    final conflictGate = purchaseBody.indexOf(
      "_lastReceiptValidationError == 'receipt_owner_conflict'",
    );
    final storeLaunch = purchaseBody.indexOf('_iap.buyNonConsumable(');

    expect(conflictGate, greaterThanOrEqualTo(0));
    expect(storeLaunch, greaterThan(conflictGate));
  });

  test('client never transfers or bypasses receipt ownership', () {
    expect(service, isNot(contains("receipt_owner_conflict' => true")));
    expect(service, isNot(contains('grantsActiveEntitlement = true')));
  });
}
