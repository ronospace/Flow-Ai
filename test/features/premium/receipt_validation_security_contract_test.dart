import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../lib/features/premium/services/receipt_validation_service.dart';

void main() {
  group('receipt validation security contract', () {
    test('active verified result grants entitlement', () {
      final result = ReceiptValidationResult(
        isValid: true,
        expirationDate: DateTime.now().add(const Duration(hours: 1)),
        transactionId: 'transaction-id',
        originalTransactionId: 'original-transaction-id',
      );

      expect(result.grantsActiveEntitlement, isTrue);
      expect(result.isExpired, isFalse);
    });

    test('missing expiry fails closed', () {
      const result = ReceiptValidationResult(
        isValid: true,
        transactionId: 'transaction-id',
        originalTransactionId: 'original-transaction-id',
      );

      expect(result.grantsActiveEntitlement, isFalse);
      expect(result.isExpired, isTrue);
    });

    test('expired result fails closed', () {
      final result = ReceiptValidationResult(
        isValid: true,
        expirationDate: DateTime.now().subtract(const Duration(minutes: 1)),
        transactionId: 'transaction-id',
        originalTransactionId: 'original-transaction-id',
      );

      expect(result.grantsActiveEntitlement, isFalse);
      expect(result.isExpired, isTrue);
    });

    test('missing authoritative identifiers fails closed', () {
      final result = ReceiptValidationResult(
        isValid: true,
        expirationDate: DateTime.now().add(const Duration(hours: 1)),
      );

      expect(result.grantsActiveEntitlement, isFalse);
    });

    test('Google payload matches deployed backend contract', () {
      final source = File(
        'lib/features/premium/services/receipt_validation_service.dart',
      ).readAsStringSync();

      expect(source, contains("'purchaseToken': purchaseToken"));
      expect(source, isNot(contains("'receipt': purchaseToken")));
      expect(source, isNot(contains("'platform': 'android'")));
    });

    test('local entitlement-expiry fabrication remains prohibited', () {
      final source = File(
        'lib/features/premium/services/subscription_service.dart',
      ).readAsStringSync();

      expect(
        source,
        contains('validationResult?.grantsActiveEntitlement == true'),
      );
      expect(
        source,
        contains('final expiryDate = validationResult.expirationDate!;'),
      );
      expect(source, isNot(contains('fallbackExpiryDate')));
      expect(source, isNot(contains('validationResult.expirationDate ??')));
    });
  });
}
