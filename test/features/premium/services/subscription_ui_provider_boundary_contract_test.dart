import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const paywallPath =
      'lib/features/premium/screens/premium_paywall_screen.dart';

  final paywall = File(paywallPath).readAsStringSync();

  final uiFiles =
      Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .where((file) {
            final path = file.path.replaceAll('\\', '/');

            return path.contains('/screens/') ||
                path.contains('/widgets/') ||
                path.contains('/pages/') ||
                path.contains('/views/');
          })
          .toList()
        ..sort((left, right) => left.path.compareTo(right.path));

  String relativePath(File file) {
    final path = file.path.replaceAll('\\', '/');
    final index = path.lastIndexOf('/lib/');

    return index >= 0
        ? path.substring(index + 1)
        : path.replaceFirst(RegExp(r'^.*?lib/'), 'lib/');
  }

  test('Premium paywall delegates through SubscriptionProvider', () {
    expect(paywall, contains('SubscriptionProvider'));

    expect(
      paywall,
      isNot(contains('package:in_app_purchase/in_app_purchase.dart')),
    );

    expect(paywall, isNot(contains('InAppPurchase.instance')));
    expect(paywall, isNot(contains('SubscriptionService(')));
    expect(paywall, isNot(contains('ReceiptValidationService(')));
  });

  test('UI never owns store or validation primitives', () {
    const forbidden = <String>[
      'package:in_app_purchase/in_app_purchase.dart',
      'InAppPurchase.instance',
      '.purchaseStream',
      '.queryProductDetails(',
      '.buyNonConsumable(',
      '.buyConsumable(',
      '.completePurchase(',
      'SubscriptionService(',
      'ReceiptValidationService(',
    ];

    final violations = <String>[];

    for (final file in uiFiles) {
      final source = file.readAsStringSync();

      for (final marker in forbidden) {
        if (source.contains(marker)) {
          violations.add('${relativePath(file)} owns $marker');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Premium UI must delegate store and validation work.',
    );
  });

  test('UI subscription actions require a provider dependency', () {
    final actionPattern = RegExp(
      r'\b(?:restorePurchases|purchaseProduct|'
      r'purchaseSubscription)\s*\(',
    );

    final violations = <String>[];

    for (final file in uiFiles) {
      final source = file.readAsStringSync();

      if (!actionPattern.hasMatch(source)) {
        continue;
      }

      final hasProvider =
          source.contains('SubscriptionProvider') ||
          source.contains('PremiumProvider');

      if (!hasProvider) {
        violations.add(relativePath(file));
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Purchase and restore actions require a provider.',
    );
  });

  test('Premium paywall restore remains provider delegation', () {
    expect(paywall, contains('restorePurchases'));
    expect(paywall, contains('SubscriptionProvider'));
    expect(paywall, isNot(contains('InAppPurchase')));
  });
}
