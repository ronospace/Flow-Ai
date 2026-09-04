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
}
