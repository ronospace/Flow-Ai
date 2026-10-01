import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final provider = File(
    'lib/features/premium/providers/subscription_provider.dart',
  ).readAsStringSync();

  String initializeBody() {
    const marker = 'Future<void> initialize(String userId) async {';

    final start = provider.indexOf(marker);
    expect(start, greaterThanOrEqualTo(0));

    final nextMethod = provider.indexOf(
      'Future<void> loadStoreCatalog() async {',
      start,
    );

    expect(nextMethod, greaterThan(start));

    return provider.substring(start, nextMethod);
  }

  test('same initialized user is not allowed to bypass reconciliation', () {
    final body = initializeBody();

    expect(
      body,
      isNot(
        contains('_isInitialized && _initializedUserId == normalizedUserId'),
      ),
    );

    expect(
      body,
      contains('await _subscriptionService.initialize(normalizedUserId);'),
    );
  });

  test('reconciliation retains provider generation protection', () {
    final body = initializeBody();

    expect(body, contains('final generation = ++_initializationGeneration;'));

    expect(body, contains('if (generation != _initializationGeneration)'));
  });

  test('provider replaces rather than duplicates entitlement listener', () {
    final body = initializeBody();

    final firstCancel = body.indexOf(
      'await _entitlementSubscription?.cancel();',
    );

    final clear = body.indexOf('_entitlementSubscription = null;');

    final listen = body.indexOf(
      '_subscriptionService.entitlementChanges.listen(',
    );

    expect(firstCancel, greaterThanOrEqualTo(0));
    expect(clear, greaterThan(firstCancel));
    expect(listen, greaterThan(clear));
  });

  test('account transition remains fail closed before service resolution', () {
    final body = initializeBody();

    final suppression = body.indexOf(
      'AdMobService().setPremiumSuppressed(true);',
    );

    final freeState = body.indexOf(
      '_subscription = UserSubscription.free(normalizedUserId);',
    );

    final serviceInitialize = body.indexOf(
      'await _subscriptionService.initialize(normalizedUserId);',
    );

    expect(suppression, greaterThanOrEqualTo(0));
    expect(freeState, greaterThan(suppression));
    expect(serviceInitialize, greaterThan(freeState));
  });

  test('reconciled service truth is copied back into provider state', () {
    final body = initializeBody();

    expect(
      body,
      contains('_subscription = _subscriptionService.currentSubscription;'),
    );

    expect(
      body,
      contains(
        '_availableProducts = _subscriptionService.getAvailableProducts();',
      ),
    );

    expect(body, contains('_initializedUserId = normalizedUserId;'));

    expect(body, contains('_isInitialized = true;'));
  });
}
