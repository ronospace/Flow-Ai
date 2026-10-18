import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'server validated receipt is not invalidated by client transit-time race',
    () {
      final source = File(
        'lib/features/premium/services/receipt_validation_service.dart',
      ).readAsStringSync();

      expect(source, contains("data['valid'] == true"));
      expect(source, contains('lifecycleStatus?.grantsEntitlement == true'));
      expect(source, contains('expirationDate != null'));
      expect(source, contains('transactionId.isNotEmpty'));
      expect(source, contains('originalTransactionId.isNotEmpty'));

      final grantStart = source.indexOf('final responseGrantsEntitlement');
      final grantEnd = source.indexOf(';', grantStart);

      expect(grantStart, greaterThanOrEqualTo(0));
      expect(grantEnd, greaterThan(grantStart));

      final grantBlock = source.substring(grantStart, grantEnd + 1);

      expect(
        grantBlock,
        isNot(contains('expirationDate.isAfter(DateTime.now())')),
      );
    },
  );
}
