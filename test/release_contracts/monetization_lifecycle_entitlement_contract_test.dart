import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final backend = File(
    'services/receipt-service/src/index.ts',
  ).readAsStringSync();

  final receipt = File(
    'lib/features/premium/services/receipt_validation_service.dart',
  ).readAsStringSync();

  final service = File(
    'lib/features/premium/services/subscription_service.dart',
  ).readAsStringSync();

  test('backend exposes and persists verified lifecycle truth', () {
    expect(backend, contains('lifecycleStatus: result.lifecycleStatus'));

    expect(backend, contains('stringValue: result.lifecycleStatus'));
  });

  test('mobile models lifecycle as a closed typed set', () {
    expect(receipt, contains('enum ReceiptLifecycleStatus'));

    expect(receipt, contains('ReceiptLifecycleStatus.active'));

    expect(receipt, contains('ReceiptLifecycleStatus.gracePeriod'));

    expect(receipt, contains('ReceiptLifecycleStatus.paidThroughCancellation'));
  });

  test('unknown or missing lifecycle fails closed', () {
    expect(receipt, contains('ReceiptLifecycleStatus.fromBackendValue'));

    expect(receipt, contains('lifecycleStatus?.grantsEntitlement == true'));
  });

  test('receipt entitlement still requires future expiry and ids', () {
    expect(receipt, contains('expiry.isAfter(DateTime.now())'));

    expect(receipt, contains('normalizedTransactionId.isNotEmpty'));

    expect(receipt, contains('normalizedOriginalTransactionId.isNotEmpty'));
  });

  test('premium grant performs defense-in-depth lifecycle check', () {
    expect(service, contains('if (!validationResult.grantsActiveEntitlement)'));

    expect(
      service,
      contains('Receipt lifecycle does not grant Premium entitlement'),
    );
  });
}
