import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final paywall = File(
    'lib/features/premium/screens/premium_paywall_screen.dart',
  ).readAsStringSync();

  final service = File(
    'lib/features/premium/services/subscription_service.dart',
  ).readAsStringSync();

  test('checkout launch feedback is store-neutral and truthful', () {
    expect(paywall, isNot(contains('App-store checkout opened')));
    expect(
      paywall,
      contains(
        'Purchase request sent to your store. '
        'Premium activates after secure verification.',
      ),
    );
  });

  test('checkout launch has temporary diagnostic telemetry', () {
    expect(service, contains('[PREMIUM-CHECKOUT] launch-request'));
    expect(service, contains('[PREMIUM-CHECKOUT] launch-return'));
    expect(service, contains('[PREMIUM-CHECKOUT] stream-update'));
    expect(service, contains('[PREMIUM-CHECKOUT] pending'));
    expect(service, contains('[PREMIUM-CHECKOUT] error'));
    expect(service, contains('[PREMIUM-CHECKOUT] canceled'));
  });

  test('diagnostics do not log account or transaction identity', () {
    final diagnosticLines = service
        .split('\n')
        .where((line) => line.contains('[PREMIUM-CHECKOUT]'))
        .join('\n');

    expect(diagnosticLines, isNot(contains('userId')));
    expect(diagnosticLines, isNot(contains('purchaseID')));
    expect(diagnosticLines, isNot(contains('transactionId')));
    expect(diagnosticLines, isNot(contains('verificationData')));
  });
}
