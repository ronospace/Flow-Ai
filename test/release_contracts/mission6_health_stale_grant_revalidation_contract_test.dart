import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cached Android health access is revalidated before being trusted', () {
    final provider = File(
      'lib/features/health/providers/health_provider.dart',
    ).readAsStringSync();

    final service = File(
      'lib/core/services/advanced_biometric_service.dart',
    ).readAsStringSync();

    expect(
      service,
      contains('Future<bool> hasCurrentAndroidHealthPermissions() async'),
    );
    expect(service, contains('await _health!.getHealthConnectSdkStatus()'));
    expect(service, contains('await _health!.hasPermissions('));
    expect(service, contains('return granted == true;'));

    final loadStart = provider.indexOf(
      'Future<void> loadConnectionState() async',
    );
    final androidCheck = provider.indexOf(
      'hasCurrentAndroidHealthPermissions()',
      loadStart,
    );
    final connected = provider.indexOf(
      '_hasHealthDataAccess = true;',
      loadStart,
    );

    expect(loadStart, greaterThanOrEqualTo(0));
    expect(androidCheck, greaterThan(loadStart));
    expect(connected, greaterThan(androidCheck));

    expect(
      provider,
      contains("await prefs.setBool('health_data_access_granted', false)"),
    );
  });
}
