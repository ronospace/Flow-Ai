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

    test('declares Apple and Google provider secrets', () {
      expect(backend, contains('defineSecret'));
      for (final secretName in [
        'FLOW_AI_APPLE_BUNDLE_ID',
        'FLOW_AI_APPLE_ISSUER_ID',
        'FLOW_AI_APPLE_KEY_ID',
        'FLOW_AI_APPLE_PRIVATE_KEY_P8',
        'FLOW_AI_GOOGLE_PACKAGE_NAME',
        'FLOW_AI_GOOGLE_SERVICE_ACCOUNT_JSON',
      ]) {
        expect(backend, contains(secretName));
      }

      expect(backend, contains('secrets: appleProviderSecrets'));
      expect(backend, contains('secrets: googleProviderSecrets'));
      expect(backend, contains('missingAppleProviderSecrets'));
      expect(backend, contains('missingGoogleProviderSecrets'));
    });

    test(
      'fails closed when provider secrets or provider implementation are absent',
      () {
        expect(backend, contains('provider_secrets_not_configured'));
        expect(backend, contains('provider_validation_not_configured'));
        expect(backend, contains('valid: false'));
        expect(backend, contains('active: false'));

        expect(backend, isNot(contains('valid: true')));
        expect(backend, isNot(contains('active: true')));
        expect(backend, isNot(contains('return true')));
      },
    );

    test('requires Apple environment and Android package contract', () {
      expect(backend, contains('allowedAppleEnvironments'));
      expect(backend, contains('production'));
      expect(backend, contains('sandbox'));
      expect(backend, contains('packageName !== configuredPackageName'));

      expect(
        client,
        contains("'environment': isProduction ? 'production' : 'sandbox'"),
      );
      expect(client, contains("'packageName': packageName"));
    });
  });
}
