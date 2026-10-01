import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = File(
    'lib/features/premium/services/subscription_service.dart',
  ).readAsStringSync();

  final provider = File(
    'lib/features/premium/providers/subscription_provider.dart',
  ).readAsStringSync();

  test('subscription service owns one active account generation', () {
    expect(service, contains('String? _activeUserId;'));
    expect(service, contains('int _identityGeneration = 0;'));
    expect(
      service,
      contains('bool _isActiveIdentity(String userId, int generation)'),
    );
  });

  test(
    'purchase validation never derives ownership from mutable entitlement',
    () {
      expect(
        service,
        isNot(contains('final userId = _currentSubscription?.userId;')),
      );
      expect(
        service,
        isNot(contains("_currentSubscription?.userId ?? 'unknown'")),
      );
    },
  );

  test('persistence remains bound to active account ownership', () {
    expect(service, contains('candidate.userId != userId'));
    expect(service, contains('Future<void> _saveSubscription('));
    expect(service, contains('_isActiveIdentity(userId, generation)'));
  });

  test('provider initialization is account and generation scoped', () {
    expect(provider, contains('String? _initializedUserId;'));
    expect(provider, contains('int _initializationGeneration = 0;'));
    expect(provider, isNot(contains('if (_isInitialized) return;')));
    expect(provider, contains('generation != _initializationGeneration'));
  });

  test('provider fails closed while switching accounts', () {
    expect(
      provider,
      contains('_subscription = UserSubscription.free(normalizedUserId);'),
    );
    expect(provider, contains('_availableProducts = const [];'));
    expect(provider, contains('await _entitlementSubscription?.cancel();'));
  });
}
