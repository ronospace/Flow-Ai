import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = File(
    'lib/features/premium/services/subscription_service.dart',
  ).readAsStringSync();

  final provider = File(
    'lib/features/premium/providers/subscription_provider.dart',
  ).readAsStringSync();

  final paywall = File(
    'lib/features/premium/screens/premium_paywall_screen.dart',
  ).readAsStringSync();

  String purchaseBody() {
    const startMarker =
        'Future<PurchaseResult> purchaseSubscription(String productId) async {';
    const endMarker = '/// Handle purchase updates';

    final start = service.indexOf(startMarker);
    final end = service.indexOf(endMarker, start);

    expect(start, greaterThanOrEqualTo(0));
    expect(end, greaterThan(start));

    return service.substring(start, end);
  }

  test('authoritative reconciliation runs before store checkout', () {
    final body = purchaseBody();

    final reconcile = body.indexOf('_loadBackendVerifiedSubscription(');

    final checkout = body.indexOf('_iap.buyNonConsumable(');

    expect(reconcile, greaterThanOrEqualTo(0));
    expect(checkout, greaterThan(reconcile));
  });

  test('checkout reconciliation is identity-generation protected', () {
    final body = purchaseBody();

    expect(body, contains('final generation = _identityGeneration;'));

    expect(
      RegExp(
        r'_isActiveIdentity\(userId,\s*generation\)',
      ).allMatches(body).length,
      greaterThanOrEqualTo(2),
    );
  });

  test('validated active Premium returns alreadyPurchased', () {
    final body = purchaseBody();

    expect(
      body,
      contains('backendResolution == _BackendSubscriptionResolution.active &&'),
    );

    expect(body, contains('_currentSubscription?.userId == userId'));

    expect(body, contains('(_currentSubscription?.isPremium ?? false)'));

    expect(body, contains('PurchaseError.alreadyPurchased'));

    final alreadyPurchased = body.indexOf('PurchaseError.alreadyPurchased');

    final checkout = body.indexOf('_iap.buyNonConsumable(');

    expect(alreadyPurchased, greaterThanOrEqualTo(0));
    expect(checkout, greaterThan(alreadyPurchased));
  });

  test(
    'unknown preserved Premium does not masquerade as authoritative active',
    () {
      final body = purchaseBody();

      expect(
        service,
        contains('return _BackendSubscriptionResolution.unknownPreserved;'),
      );
      expect(
        body,
        contains(
          'backendResolution == _BackendSubscriptionResolution.active &&',
        ),
      );
      expect(
        body,
        isNot(
          contains(
            'backendResolution == '
            '_BackendSubscriptionResolution.unknownPreserved',
          ),
        ),
      );
    },
  );

  test('provider adopts authoritative subscription on alreadyPurchased', () {
    expect(
      provider,
      contains('if (result.error == PurchaseError.alreadyPurchased)'),
    );

    expect(
      provider,
      contains('_subscription = _subscriptionService.currentSubscription;'),
    );

    expect(provider, contains('_errorMessage = null;'));
  });

  test('paywall does not present already-active ownership as failure', () {
    expect(
      paywall,
      contains('if (result.error == PurchaseError.alreadyPurchased)'),
    );

    final already = paywall.indexOf(
      'if (result.error == PurchaseError.alreadyPurchased)',
    );

    final genericError = paywall.indexOf(
      'if (result.error != PurchaseError.cancelled)',
      already,
    );

    expect(already, greaterThanOrEqualTo(0));
    expect(genericError, greaterThan(already));
  });

  test('store checkout remains singular', () {
    expect(RegExp(r'_iap\.buyNonConsumable\(').allMatches(service).length, 1);
  });

  test('checkout launch is single-flight and excludes restore operations', () {
    expect(service, contains('bool _purchaseLaunchInFlight = false;'));

    final body = purchaseBody();

    final busy = body.indexOf('if (_purchaseLaunchInFlight ||');
    final acquire = body.indexOf('_purchaseLaunchInFlight = true;');
    final reconcile = body.indexOf('_loadBackendVerifiedSubscription(');
    final checkout = body.indexOf('_iap.buyNonConsumable(');
    final release = body.indexOf('_purchaseLaunchInFlight = false;');

    expect(busy, greaterThanOrEqualTo(0));
    expect(acquire, greaterThan(busy));
    expect(reconcile, greaterThan(acquire));
    expect(checkout, greaterThan(reconcile));
    expect(release, greaterThan(checkout));

    expect(
      body,
      contains('(activeRestore != null && !activeRestore.isCompleted)'),
    );

    final startupRestoreStart = service.indexOf(
      'Future<void> _restoreOwnedPurchasesOnStartup(',
    );
    final manualRestoreStart = service.indexOf(
      'Future<bool> restorePurchases(String userId)',
      startupRestoreStart,
    );

    expect(startupRestoreStart, greaterThanOrEqualTo(0));
    expect(manualRestoreStart, greaterThan(startupRestoreStart));

    final startupRestore = service.substring(
      startupRestoreStart,
      manualRestoreStart,
    );

    expect(startupRestore, contains('if (_purchaseLaunchInFlight)'));

    final manualRestoreEnd = service.indexOf(
      '/// Save subscription to storage',
      manualRestoreStart,
    );

    expect(manualRestoreEnd, greaterThan(manualRestoreStart));

    final manualRestore = service.substring(
      manualRestoreStart,
      manualRestoreEnd,
    );

    expect(manualRestore, contains('if (_purchaseLaunchInFlight)'));

    expect(RegExp(r'_iap\.restorePurchases\(\)').allMatches(service).length, 2);
  });

  test('provider rejects purchase re-entry before loading mutation', () {
    const marker =
        'Future<PurchaseResult> purchaseSubscription(String productId) async {';

    final start = provider.indexOf(marker);
    final end = provider.indexOf('/// Restore previous purchases', start);

    expect(start, greaterThanOrEqualTo(0));
    expect(end, greaterThan(start));

    final body = provider.substring(start, end);

    final busy = body.indexOf('if (_isLoading)');
    final loading = body.indexOf('_isLoading = true;');
    final serviceCall = body.indexOf(
      '_subscriptionService.purchaseSubscription(productId)',
    );

    expect(busy, greaterThanOrEqualTo(0));
    expect(loading, greaterThan(busy));
    expect(serviceCall, greaterThan(loading));
  });

  test(
    'startup restore never owns the manual restore completer or checkout lock',
    () {
      final service = File(
        'lib/features/premium/services/subscription_service.dart',
      ).readAsStringSync();

      final startupRestoreStart = service.indexOf(
        'Future<void> _restoreOwnedPurchasesOnStartup(',
      );
      final manualRestoreStart = service.indexOf(
        'Future<bool> restorePurchases(String userId)',
      );

      expect(startupRestoreStart, greaterThanOrEqualTo(0));
      expect(manualRestoreStart, greaterThan(startupRestoreStart));

      final startupRestore = service.substring(
        startupRestoreStart,
        manualRestoreStart,
      );

      expect(startupRestore, contains('await _iap.restorePurchases();'));
      expect(startupRestore, isNot(contains('_restoreCompleter =')));
      expect(startupRestore, isNot(contains('Completer<bool>()')));
      expect(startupRestore, isNot(contains('completer.future.timeout')));
    },
  );
}
