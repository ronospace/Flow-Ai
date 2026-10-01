import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = File(
    'lib/features/premium/services/subscription_service.dart',
  ).readAsStringSync();

  final models = File(
    'lib/features/premium/models/subscription_models.dart',
  ).readAsStringSync();

  String activeBranch() {
    final start = service.indexOf('if (backendStatus?.active == true)');

    final end = service.indexOf('if (backendStatus?.active == false)', start);

    expect(start, greaterThanOrEqualTo(0));
    expect(end, greaterThan(start));

    return service.substring(start, end);
  }

  test('backend ACTIVE owns entitlement metadata', () {
    final branch = activeBranch();

    expect(branch, contains('backendStatus!.productId'));
    expect(branch, contains('backendStatus.expirationDate'));
    expect(branch, contains('backendStatus.transactionId'));
    expect(branch, contains('backendStatus.originalTransactionId'));

    expect(branch, contains('productId: productId'));
    expect(branch, contains('expiryDate: expiryDate'));
    expect(branch, contains('transactionId: transactionId'));
    expect(branch, contains('originalTransactionId: originalTransactionId'));
  });

  test('backend ACTIVE cannot promote stale candidate wholesale', () {
    final branch = activeBranch();

    expect(branch, isNot(contains('_currentSubscription = candidate')));

    expect(
      branch,
      contains('_currentSubscription = UserSubscription.premium('),
    );
  });

  test('backend entitlement requires recognized live metadata', () {
    final branch = activeBranch();

    expect(
      branch,
      contains('productId != monthlyProductId && productId != yearlyProductId'),
    );

    expect(branch, contains('!expiryDate.isAfter(DateTime.now())'));
    expect(branch, contains('transactionId.isEmpty'));
    expect(branch, contains('originalTransactionId.isEmpty'));
  });

  test('purchase date remains historical and is never fabricated here', () {
    final branch = activeBranch();

    expect(models, contains('DateTime? purchaseDate,'));

    expect(branch, contains('purchaseDate: candidate.purchaseDate'));

    expect(branch, isNot(contains('purchaseDate: DateTime.now()')));

    expect(
      branch,
      isNot(contains('purchaseDate: DateTime.fromMillisecondsSinceEpoch')),
    );
  });

  test('backend UNKNOWN preserves only existing locally valid candidate', () {
    final start = service.indexOf('// Backend status is temporarily unknown.');

    expect(start, greaterThanOrEqualTo(0));

    final branch = service.substring(start);

    expect(branch, contains('if (candidate.isPremium)'));
    expect(branch, contains('_currentSubscription = candidate'));
  });
}
