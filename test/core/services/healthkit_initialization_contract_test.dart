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

  test(
    'provider never records health access before initialization succeeds',
    () {
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
        '_hasHealthDataAccess = true;',
        verification,
      );

      expect(connectStart, greaterThanOrEqualTo(0));
      expect(initializeCall, greaterThan(connectStart));
      expect(verification, greaterThan(initializeCall));
      expect(connected, greaterThan(verification));
      expect(
        source,
        contains("prefs.setBool('health_data_access_granted', false)"),
      );
    },
  );

  test('Health Connect availability is checked before authorization', () {
    final source = File(
      'lib/core/services/advanced_biometric_service.dart',
    ).readAsStringSync();

    final configure = source.indexOf('await _health!.configure();');
    final availability = source.indexOf('isHealthConnectAvailable');
    final authorization = source.indexOf(
      'final granted = await _requestHealthPermissions()',
    );

    expect(configure, greaterThanOrEqualTo(0));
    expect(availability, greaterThan(configure));
    expect(authorization, greaterThan(availability));

    expect(
      source,
      contains('No Android health data will be requested or displayed.'),
    );
  });

  test('snapshot preserves provenance and aggregates sleep in hours', () {
    final service = File(
      'lib/core/services/advanced_biometric_service.dart',
    ).readAsStringSync();

    final card = File(
      'lib/features/health/widgets/healthkit_connection_card.dart',
    ).readAsStringSync();

    expect(service, contains('class HealthMetricProvenance'));
    expect(service, contains('metricProvenance'));
    expect(service, contains('sourcePlatforms'));
    expect(service, contains('sourceDeviceIds'));
    expect(service, contains('recordingMethods'));
    expect(service, contains('_aggregateLatestSleepHours'));
    expect(service, contains('totalMinutes / 60.0'));

    expect(
      service,
      isNot(
        contains(
          'sleepHours: _getLatestValue('
          'recentData[HealthDataType.SLEEP_ASLEEP]',
        ),
      ),
    );

    expect(card, contains('Access Granted'));
    expect(card, contains('Access granted'));

    expect(card, isNot(contains('Health data syncing from')));

    expect(card, isNot(contains('& wearables')));
  });
}
