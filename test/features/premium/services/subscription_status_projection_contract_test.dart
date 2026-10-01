import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/features/premium/services/receipt_validation_service.dart',
  ).readAsStringSync();

  test('retains authoritative backend subscription projection', () {
    expect(source, contains('class SubscriptionStatusProjection'));

    expect(
      source,
      contains('Future<SubscriptionStatusProjection?> fetchSubscriptionStatus'),
    );

    for (final field in <String>[
      "decoded?['expirationDate']",
      "decoded?['productId']",
      "decoded?['transactionId']",
      "decoded?['originalTransactionId']",
    ]) {
      expect(source, contains(field));
    }
  });

  test('authoritative inactive is distinct from temporary unknown', () {
    expect(
      source,
      contains('const SubscriptionStatusProjection(active: false)'),
    );

    expect(
      source,
      contains('if (response == null || response.statusCode != 200)'),
    );

    expect(source, contains('active is! bool'));
    expect(source, contains('return null;'));
  });

  test('active backend response must contain complete live metadata', () {
    expect(source, contains('!expirationDate.isAfter(DateTime.now())'));
    expect(source, contains('productId.isEmpty'));
    expect(source, contains('transactionId.isEmpty'));
    expect(source, contains('originalTransactionId.isEmpty'));
  });

  test('boolean compatibility API delegates to full projection', () {
    final start = source.indexOf('Future<bool?> verifySubscriptionActive');

    expect(start, greaterThanOrEqualTo(0));

    final body = source.substring(start);

    expect(body, contains('fetchSubscriptionStatus('));
    expect(body, contains('return projection?.active;'));
  });
}
