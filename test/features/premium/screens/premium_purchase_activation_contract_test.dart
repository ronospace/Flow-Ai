import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('store launch does not grant or announce Premium', () {
    final paywall = File(
      'lib/features/premium/screens/premium_paywall_screen.dart',
    ).readAsStringSync();

    final service = File(
      'lib/features/premium/services/subscription_service.dart',
    ).readAsStringSync();

    expect(paywall, isNot(contains('Welcome to Premium')));
    expect(
      paywall,
      contains(
        'App-store checkout opened. Premium activates after secure verification.',
      ),
    );

    expect(service, contains('await _validatePurchase(purchaseDetails)'));
    expect(service, contains('if (validationResult?.isValid == true)'));
    expect(service, contains('await _grantPremiumAccess('));
  });
}
