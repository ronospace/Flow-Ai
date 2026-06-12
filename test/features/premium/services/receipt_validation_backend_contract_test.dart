import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Receipt validation backend provider contract', () {
    late String backend;
    late String client;

    setUpAll(() {
      backend = File(
        'functions/src/receipt_validation_http.ts',
      ).readAsStringSync();
      client = File(
        'lib/features/premium/services/receipt_validation_service.dart',
      ).readAsStringSync();
    });

    test('declares official provider SDKs and provider secrets', () {
      for (final token in [
        '@apple/app-store-server-library',
        'AppStoreServerAPIClient',
        'SignedDataVerifier',
        'GoogleAuth',
        'FLOW_AI_APPLE_BUNDLE_ID',
        'FLOW_AI_APPLE_ISSUER_ID',
        'FLOW_AI_APPLE_KEY_ID',
        'FLOW_AI_APPLE_PRIVATE_KEY_P8',
        'FLOW_AI_APPLE_ROOT_CERTIFICATES_PEM',
        'FLOW_AI_GOOGLE_PACKAGE_NAME',
        'FLOW_AI_GOOGLE_SERVICE_ACCOUNT_JSON',
      ]) {
        expect(backend, contains(token));
      }

      expect(backend, contains('secrets: appleProviderSecrets'));
      expect(backend, contains('secrets: googleProviderSecrets'));
      expect(backend, contains('missingAppleProviderSecrets'));
      expect(backend, contains('missingGoogleProviderSecrets'));
    });

    test('verifies providers before returning a valid receipt response', () {
      expect(backend, contains('getTransactionInfo'));
      expect(backend, contains('verifyAndDecodeTransaction'));
      expect(backend, contains('subscriptionsv2'));
      expect(backend, contains('androidpublisher'));
      expect(backend, contains('verifyAppleTransaction'));
      expect(backend, contains('verifyGoogleSubscription'));
      expect(backend, contains('receipt_not_active'));
      expect(backend, contains('provider_validation_failed'));

      expect(backend, isNot(contains('provider_validation_not_configured')));
      expect(backend, isNot(contains('sandbox.itunes.apple.com')));
      expect(backend, isNot(contains('buy.itunes.apple.com')));
      expect(backend, isNot(contains('return true')));
    });

    test(
      'persists entitlement before granting and reads status from Firestore',
      () {
        final validIndex = backend.indexOf('valid: true');
        final persistIndex = backend.indexOf(
          'await persistValidatedEntitlement',
        );
        final activeIndex = backend.indexOf('active: true');
        final statusSnapshotIndex = backend.indexOf(
          'const snapshot = await db',
        );

        expect(validIndex, greaterThan(-1));
        expect(persistIndex, greaterThan(-1));
        expect(persistIndex, lessThan(validIndex));

        expect(activeIndex, greaterThan(-1));
        expect(statusSnapshotIndex, greaterThan(-1));
        expect(statusSnapshotIndex, lessThan(activeIndex));

        expect(backend, contains('premiumEntitlements'));
        expect(backend, contains('subscriptions'));
        expect(backend, contains('expiresAtMillis'));
        expect(backend, contains('Timestamp.fromMillis'));
        expect(backend, contains('FieldValue.serverTimestamp'));
      },
    );

    test('requires Apple environment and Android package contract', () {
      expect(backend, contains('allowedAppleEnvironments'));
      expect(backend, contains('production'));
      expect(backend, contains('sandbox'));
      expect(backend, contains('packageName !== configuredPackageName'));
      expect(backend, contains('body.userId'));
      expect(backend, contains('body.transactionId'));
      expect(backend, contains('appleTransactionId'));
      expect(backend, contains('appleRootCertificatesPem'));

      expect(
        client,
        contains("'environment': isProduction ? 'production' : 'sandbox'"),
      );
      expect(client, contains("'transactionId': transactionId"));
      expect(client, contains("'userId': userId"));
      expect(client, contains("'packageName': packageName"));
    });
  });
}
