import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const canonicalPath =
      'lib/features/premium/services/subscription_service.dart';
  const providerPath =
      'lib/features/premium/providers/subscription_provider.dart';
  const paywallPath =
      'lib/features/premium/screens/premium_paywall_screen.dart';
  const receiptPath =
      'lib/features/premium/services/receipt_validation_service.dart';

  final canonical = File(canonicalPath).readAsStringSync();
  final provider = File(providerPath).readAsStringSync();
  final paywall = File(paywallPath).readAsStringSync();
  final receipt = File(receiptPath).readAsStringSync();

  final productionFiles =
      Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .toList()
        ..sort((left, right) => left.path.compareTo(right.path));

  String relativePath(File file) {
    final normalized = file.path.replaceAll('\\', '/');
    final libIndex = normalized.lastIndexOf('/lib/');

    if (libIndex >= 0) {
      return normalized.substring(libIndex + 1);
    }

    return normalized.startsWith('lib/')
        ? normalized
        : normalized.replaceFirst(RegExp(r'^.*?lib/'), 'lib/');
  }

  Map<String, List<String>> ownersOf(String marker) {
    final owners = <String, List<String>>{};

    for (final file in productionFiles) {
      final source = file.readAsStringSync();

      if (!source.contains(marker)) {
        continue;
      }

      owners.putIfAbsent(marker, () => <String>[]).add(relativePath(file));
    }

    return owners;
  }

  test('only SubscriptionService imports the store SDK', () {
    const sdkImport = 'package:in_app_purchase/in_app_purchase.dart';
    final owners = ownersOf(sdkImport)[sdkImport] ?? <String>[];

    expect(
      owners,
      equals(<String>[canonicalPath]),
      reason:
          'The low-level in_app_purchase SDK must have one production owner.',
    );
  });

  test('only SubscriptionService owns low-level store operations', () {
    const requiredMarkers = <String>[
      'InAppPurchase.instance',
      '.purchaseStream',
      '.queryProductDetails(',
      '.buyNonConsumable(',
      '.completePurchase(',
    ];

    for (final marker in requiredMarkers) {
      final owners = ownersOf(marker)[marker] ?? <String>[];

      expect(
        owners,
        equals(<String>[canonicalPath]),
        reason: '$marker must remain exclusively owned by SubscriptionService.',
      );
    }
  });

  test('provider and paywall delegate without owning the store SDK', () {
    const forbiddenMarkers = <String>[
      'package:in_app_purchase/in_app_purchase.dart',
      'InAppPurchase.instance',
      '.purchaseStream',
      '.queryProductDetails(',
      '.buyNonConsumable(',
      '.buyConsumable(',
      '.completePurchase(',
    ];

    for (final marker in forbiddenMarkers) {
      expect(
        provider,
        isNot(contains(marker)),
        reason: 'SubscriptionProvider must delegate $marker.',
      );

      expect(
        paywall,
        isNot(contains(marker)),
        reason: 'PremiumPaywallScreen must delegate $marker.',
      );
    }

    expect(provider, contains('SubscriptionService'));
    expect(provider, contains('restorePurchases'));
  });

  test('canonical service delegates trust to receipt validation', () {
    expect(canonical, contains('receipt_validation_service.dart'));
    expect(canonical, contains('ReceiptValidationService'));

    expect(
      receipt,
      anyOf(
        contains('validatePurchase'),
        contains('validateSubscription'),
        contains('verifySubscription'),
        contains('verifyPurchase'),
      ),
    );
  });

  test('UI restore is delegation, not independent store ownership', () {
    expect(paywall, contains('restorePurchases'));
    expect(
      paywall,
      anyOf(
        contains('SubscriptionProvider'),
        contains('PremiumProvider'),
        contains('SubscriptionService'),
      ),
    );

    expect(paywall, isNot(contains('InAppPurchase')));
  });
}
