import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Receipt validation client release policy', () {
    late String receiptClient;
    late String subscriptionService;

    setUpAll(() {
      receiptClient = File(
        'lib/features/premium/services/'
        'receipt_validation_service.dart',
      ).readAsStringSync();

      subscriptionService = File(
        'lib/features/premium/services/'
        'subscription_service.dart',
      ).readAsStringSync();
    });

    String invocationArguments(String methodName) {
      final match = RegExp(
        '$methodName\\((.*?)\\);',
        dotAll: true,
      ).firstMatch(subscriptionService);

      expect(match, isNotNull, reason: 'Missing invocation of $methodName');

      return match!.group(1)!;
    }

    test('uses Firebase Bearer authentication', () {
      expect(
        receiptClient,
        contains('package:firebase_auth/firebase_auth.dart'),
      );
      expect(receiptClient, contains('FirebaseAuth.instance'));
      expect(receiptClient, contains('currentUser'));
      expect(receiptClient, contains('getIdToken(forceRefresh)'));
      expect(receiptClient, contains("'Authorization': 'Bearer \$token'"));
      expect(receiptClient, contains('isAuthenticatedUser'));

      expect(receiptClient, isNot(contains('debugPrint(')));
      expect(receiptClient, isNot(contains('print(')));
    });

    test('uses one HTTPS Cloud Run base URL', () {
      expect(receiptClient, contains('FLOW_AI_RECEIPT_SERVICE_BASE_URL'));
      expect(receiptClient, contains("'v1', 'receipts', 'apple'"));
      expect(receiptClient, contains("'v1', 'receipts', 'google'"));
      expect(receiptClient, contains("'v1', 'subscriptions'"));
      expect(receiptClient, contains("uri.scheme == 'https'"));

      for (final legacyDefine in <String>[
        'FLOW_AI_APPLE_RECEIPT_VALIDATION_ENDPOINT',
        'FLOW_AI_GOOGLE_RECEIPT_VALIDATION_ENDPOINT',
        'FLOW_AI_SUBSCRIPTION_STATUS_ENDPOINT',
      ]) {
        expect(receiptClient, isNot(contains(legacyDefine)));
      }
    });

    test('never sends client-owned UID to validation routes', () {
      expect(receiptClient, isNot(contains("'userId':")));
      expect(receiptClient, isNot(contains('required String userId')));
      expect(receiptClient, isNot(contains("'receipt':")));
      expect(receiptClient, isNot(contains("'platform':")));

      for (final methodName in <String>[
        'validateAppleReceipt',
        'validateGooglePlayReceipt',
        'verifySubscriptionActive',
      ]) {
        expect(
          invocationArguments(methodName),
          isNot(contains('userId:')),
          reason: '$methodName still receives a client UID',
        );
      }

      expect(
        invocationArguments('validateAppleReceipt'),
        contains('transactionId: transactionId'),
      );

      expect(
        invocationArguments('validateGooglePlayReceipt'),
        contains('purchaseToken: verificationData'),
      );
    });
  });
}
