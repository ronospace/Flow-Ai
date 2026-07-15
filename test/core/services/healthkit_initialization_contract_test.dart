import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('HealthKit initializes before the first synchronization', () {
    final source = File(
      'lib/core/services/advanced_biometric_service.dart',
    ).readAsStringSync();

    final initializeStart = source.indexOf('Future<void> initialize() async');
    final authorization = source.indexOf(
      'final granted = await _requestHealthPermissions()',
    );
    final initialized = source.indexOf('_isInitialized = true;', authorization);
    final initialSync = source.indexOf('await _syncHealthData();', initialized);

    expect(initializeStart, greaterThanOrEqualTo(0));
    expect(authorization, greaterThan(initializeStart));
    expect(initialized, greaterThan(authorization));
    expect(initialSync, greaterThan(initialized));

    expect(source, isNot(contains('_initializeMockService')));
    expect(source, isNot(contains('_generateMockInsights')));
  });

  test('provider never records connection before initialization succeeds', () {
    final source = File(
      'lib/features/health/providers/health_provider.dart',
    ).readAsStringSync();

    final connectStart = source.indexOf('Future<void> connectHealthKit');
    final initializeCall = source.indexOf(
      'await biometricService.initialize()',
      connectStart,
    );
    final verification = source.indexOf(
      'if (!biometricService.isInitialized)',
      initializeCall + 1,
    );
    final connected = source.indexOf(
      '_isHealthKitConnected = true;',
      verification,
    );

    expect(connectStart, greaterThanOrEqualTo(0));
    expect(initializeCall, greaterThan(connectStart));
    expect(verification, greaterThan(initializeCall));
    expect(connected, greaterThan(verification));
    expect(source, contains("prefs.setBool('healthkit_connected', false)"));
  });
}
