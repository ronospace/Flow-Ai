import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Mission 5 health acquisition fails closed without synthetic data', () {
    final source = File(
      'lib/core/services/biometric_integration_service.dart',
    ).readAsStringSync();

    for (final forbidden in <String>[
      '_generateSimulatedHeartRateData',
      '_generateSimulatedSleepData',
      '_generateSimulatedTemperatureData',
      '_generateSimulatedHRVData',
      '_generateSimulatedStressData',
      '_generateSimulatedActivityData',
    ]) {
      expect(
        source.contains(forbidden),
        isFalse,
        reason: 'Production health source must not contain $forbidden',
      );
    }

    expect(
      RegExp(r'_healthChannel\.invokeMethod').allMatches(source).length,
      greaterThanOrEqualTo(6),
      reason: 'Real native health acquisition must remain intact.',
    );

    expect(
      RegExp(r'return <BiometricReading>\[\];').allMatches(source).length,
      greaterThanOrEqualTo(6),
      reason: 'Unavailable health data must fail closed as no-data.',
    );
  });

  test('Mission 5 wellness UI contains no fabricated personal readings', () {
    final wellness = File(
      'lib/features/health/screens/health_screen.dart',
    ).readAsStringSync();

    for (final forbidden in <String>[
      '72 BPM',
      '98.6°F',
      '8.2/10',
      'improved by 15%',
      '8 glasses of water daily',
      "['Fatigue', 'Mood Swings'].contains(symptom)",
      "'current': 8420",
    ]) {
      expect(
        wellness.contains(forbidden),
        isFalse,
        reason: 'Production Wellness must not fabricate $forbidden',
      );
    }

    expect(wellness, contains("final isActive = false;"));
    expect(wellness, contains("EnhancedDailyFeelingsTracker("));
    expect(wellness, contains("hasVerifiedHealthData"));

    final home = File(
      'lib/features/cycle/screens/home_screen.dart',
    ).readAsStringSync();

    final start = home.indexOf(
      'Widget _buildHealthDashboardMatrix(CycleProvider provider)',
    );
    final end = home.indexOf('Widget _buildHealthMetricCard(', start);

    expect(start, greaterThanOrEqualTo(0));
    expect(end, greaterThan(start));

    final matrix = home.substring(start, end);
    expect(matrix, isNot(contains(": '28 ")));
    expect(matrix, isNot(contains(": '50%'")));
  });
}
