import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Receipt validation client release policy', () {
    test('does not emit receipt validation debug logs', () {
      final receiptValidationService = File(
        'lib/features/premium/services/receipt_validation_service.dart',
      ).readAsStringSync();

      expect(receiptValidationService, isNot(contains('debugPrint(')));
      expect(receiptValidationService, isNot(contains('print(')));
      expect(
        receiptValidationService,
        isNot(contains('Validating Apple receipt')),
      );
      expect(
        receiptValidationService,
        isNot(contains('Validating Google Play receipt')),
      );
      expect(
        receiptValidationService,
        isNot(contains('Backend validation error')),
      );
    });

    test('requires explicit Apple production/sandbox environment', () {
      final receiptValidationService = File(
        'lib/features/premium/services/receipt_validation_service.dart',
      ).readAsStringSync();
      final subscriptionService = File(
        'lib/features/premium/services/subscription_service.dart',
      ).readAsStringSync();

      expect(receiptValidationService, contains('required bool isProduction'));
      expect(
        receiptValidationService,
        isNot(contains('bool isProduction = false')),
      );
      expect(subscriptionService, contains('isProduction: kReleaseMode'));
    });
  });
}
