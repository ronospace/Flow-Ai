import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('startup reconstructs owned entitlement through validated restore', () {
    final source = File(
      'lib/features/premium/services/subscription_service.dart',
    ).readAsStringSync();

    final initializeStart =
        source.indexOf('Future<void> initialize(String userId)');
    expect(initializeStart, greaterThanOrEqualTo(0));

    expect(
      source,
      contains('_restoreOwnedPurchasesOnStartup('),
    );

    expect(
      source,
      contains('await _iap.restorePurchases()'),
    );

    // Store ownership alone must never grant Premium.
    expect(
      source,
      contains('validationResult.grantsActiveEntitlement'),
    );

    expect(
      source,
      contains('PurchaseStatus.restored'),
    );

    expect(
      source,
      isNot(contains(
        'UserSubscription.premium(userId)',
      )),
    );
  });
}
