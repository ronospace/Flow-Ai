import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'explicit Connect always reaches authoritative health authorization',
    () {
      final service = File(
        'lib/core/services/advanced_biometric_service.dart',
      ).readAsStringSync();

      final provider = File(
        'lib/features/health/providers/health_provider.dart',
      ).readAsStringSync();

      expect(
        service,
        contains('Future<bool> requestHealthAuthorization() async'),
      );
      expect(service, contains('await _health!.getHealthConnectSdkStatus()'));
      expect(
        service,
        contains('final granted = await _requestHealthPermissions()'),
      );

      final connectStart = provider.indexOf(
        'Future<void> connectHealthKit(BuildContext context) async',
      );
      final authorization = provider.indexOf(
        '.requestHealthAuthorization()',
        connectStart,
      );
      final connected = provider.indexOf(
        '_hasHealthDataAccess = true;',
        authorization,
      );

      expect(connectStart, greaterThanOrEqualTo(0));
      expect(authorization, greaterThan(connectStart));
      expect(connected, greaterThan(authorization));
    },
  );

  test(
    'explicit authorization does not depend on initialization being false',
    () {
      final provider = File(
        'lib/features/health/providers/health_provider.dart',
      ).readAsStringSync();

      final connectStart = provider.indexOf(
        'Future<void> connectHealthKit(BuildContext context) async',
      );
      final disconnectStart = provider.indexOf(
        'Future<void> disconnectHealthKit',
        connectStart,
      );
      final connectBody = provider.substring(connectStart, disconnectStart);

      expect(
        connectBody,
        isNot(
          contains(
            'if (!biometricService.isInitialized) {\n'
            '            await biometricService.initialize();',
          ),
        ),
      );
      expect(connectBody, contains('requestHealthAuthorization()'));
    },
  );
}
