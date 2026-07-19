import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Isolated receipt-service contract', () {
    late String backend;
    late String client;

    setUpAll(() {
      backend = File(
        'services/receipt-service/src/index.ts',
      ).readAsStringSync();

      client = File(
        'lib/features/premium/services/'
        'receipt_validation_service.dart',
      ).readAsStringSync();
    });

    test('authenticates Firebase identity without UID trust', () {
      expect(backend, contains('createRemoteJWKSet'));
      expect(backend, contains('jwtVerify'));
      expect(backend, contains('requireFirebaseUid'));
      expect(backend, contains('extractBearerToken'));
      expect(backend, contains('RS256'));

      expect(backend, isNot(contains('body.userId')));
      expect(backend, isNot(contains('body.uid')));
      expect(client, isNot(contains("'userId':")));
    });

    test('matches Apple and Google request contracts', () {
      expect(backend, contains('transactionId'));
      expect(backend, contains('environment'));
      expect(backend, contains('purchaseToken'));
      expect(backend, contains('packageName'));
      expect(backend, contains('productId'));

      expect(client, contains("'transactionId': transactionId"));
      expect(
        client,
        contains(
          "'environment': "
          "isProduction ? 'production' : 'sandbox'",
        ),
      );
      expect(client, contains("'receipt': purchaseToken"));
      expect(client, contains("'platform': 'android'"));
      expect(client, isNot(contains("'purchaseToken': purchaseToken")));
      expect(client, contains("'packageName': packageName"));
      expect(client, contains("'productId': productId"));
    });

    test('uses keyless provider access', () {
      expect(backend, contains('generateAccessToken'));
      expect(backend, contains('androidpublisher'));
      expect(backend, contains('premiumEntitlements'));
      expect(backend, contains('allowedProducts'));
      expect(backend, contains('FLOW_AI_APPLE_ISSUER_ID_NEXT'));
      expect(backend, contains('FLOW_AI_GOOGLE_PLAY_SERVICE_ACCOUNT'));

      expect(backend, isNot(contains('FLOW_AI_GOOGLE_SERVICE_ACCOUNT_JSON')));
      expect(backend, isNot(contains('firebase-admin')));
      expect(backend, isNot(contains('firebase-functions')));
    });

    test('client uses the protected v1 routes', () {
      expect(client, contains('FLOW_AI_RECEIPT_SERVICE_BASE_URL'));
      expect(client, contains("'v1', 'receipts', 'apple'"));
      expect(client, contains("'v1', 'receipts', 'google'"));
      expect(client, contains("'v1', 'subscriptions', normalizedId"));
      expect(client, contains("'Authorization': 'Bearer \$token'"));
    });
  });
}
