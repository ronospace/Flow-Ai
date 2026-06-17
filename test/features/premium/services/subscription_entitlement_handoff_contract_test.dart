import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('validated entitlement is published to SubscriptionProvider', () {
    final service = File(
      'lib/features/premium/services/subscription_service.dart',
    ).readAsStringSync();

    final provider = File(
      'lib/features/premium/providers/subscription_provider.dart',
    ).readAsStringSync();

    final validationIndex = service.indexOf(
      'final validationResult = await _validatePurchase',
    );
    final grantIndex = service.indexOf('await _grantPremiumAccess');

    expect(validationIndex, greaterThanOrEqualTo(0));
    expect(grantIndex, greaterThan(validationIndex));

    expect(service, contains('StreamController<UserSubscription>.broadcast()'));
    expect(
      service,
      contains('Stream<UserSubscription> get entitlementChanges'),
    );
    expect(
      service,
      contains('_entitlementController.add(validatedSubscription)'),
    );
    expect(service, contains('_entitlementController.close()'));

    expect(
      provider,
      contains(
        'StreamSubscription<UserSubscription>? '
        '_entitlementSubscription',
      ),
    );
    expect(
      provider,
      contains('_subscriptionService.entitlementChanges.listen'),
    );
    expect(provider, contains('_subscription = subscription'));
    expect(provider, contains('notifyListeners()'));
    expect(provider, contains('_entitlementSubscription?.cancel()'));
  });
}
