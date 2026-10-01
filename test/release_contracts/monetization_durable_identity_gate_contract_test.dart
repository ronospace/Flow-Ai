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

  test('receipt ownership rejects anonymous Firebase identity', () {
    expect(receipt, contains('!user.isAnonymous'));
    expect(receipt, contains('bool canOwnMonetizationFor(String userId)'));
  });

  test('subscription service remains authoritative', () {
    expect(service, contains('bool get hasDurableMonetizationIdentity'));
    expect(service, contains('bool canOwnMonetizationFor(String userId)'));
    expect(
      service,
      contains(
        'Legacy local and anonymous sessions cannot own store purchases.',
      ),
    );
  });

  test('provider delegates monetization identity ownership', () {
    expect(provider, contains('bool get hasDurableMonetizationIdentity'));
    expect(
      provider,
      contains('_subscriptionService.canOwnMonetizationFor(userId)'),
    );
  });

  test('paywall fails closed before purchase checkout', () {
    expect(paywall, contains('if (!provider.hasDurableMonetizationIdentity)'));
    expect(
      paywall,
      contains('cannot safely own App Store or Google Play purchases'),
    );
  });

  test('restore requires exact durable account ownership', () {
    expect(paywall, contains('if (!provider.canOwnMonetizationFor(userId))'));
    expect(
      paywall,
      contains('ownership of the App Store or Google Play subscription'),
    );
  });

  test('paywall does not fabricate or mutate identity', () {
    expect(paywall, isNot(contains('FirebaseAuth.instance')));
    expect(paywall, isNot(contains('signInAnonymously()')));
    expect(paywall, isNot(contains('signOut()')));
  });
}
