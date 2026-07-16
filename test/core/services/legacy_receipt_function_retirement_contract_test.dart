import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legacy Firebase receipt endpoints are not deployable', () {
    final index = File('functions/src/index.ts').readAsStringSync();

    expect(index, isNot(contains('validateAppleReceipt')));
    expect(index, isNot(contains('validateGooglePlayReceipt')));
    expect(index, isNot(contains('subscriptionStatus')));
    expect(
      File('functions/src/receipt_validation_http.ts').existsSync(),
      isFalse,
    );
  });

  test('receipt client uses authenticated Cloud Run service', () {
    final source = File(
      'lib/features/premium/services/receipt_validation_service.dart',
    ).readAsStringSync();

    expect(source, contains('getIdToken'));
    expect(source, contains("'Authorization': 'Bearer \$token'"));
    expect(source, contains('.a.run.app'));
    expect(source, isNot(contains('cloudfunctions.net')));
    expect(source, isNot(contains("'userId':")));
  });
}
