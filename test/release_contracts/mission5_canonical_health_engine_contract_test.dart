import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('M5.6 engine uses canonical real Health observations only', () {
    final source = File(
      'lib/core/biometrics/advanced_biometric_engine.dart',
    ).readAsStringSync();

    for (final required in <String>[
      'AdvancedBiometricService',
      'getCurrentBiometricSnapshot',
      '_refreshCanonicalHealthData',
      "addRealValue('sleep', canonicalSnapshot.sleepHours)",
      "addRealValue('steps', canonicalSnapshot.steps)",
      "addRealValue('activity', canonicalSnapshot.activeEnergy)",
    ]) {
      expect(
        source.contains(required),
        isTrue,
        reason: 'Canonical binding missing: $required',
      );
    }

    for (final forbidden in <String>[
      'HealthKitIntegration',
      'FitbitIntegration',
      'OuraIntegration',
      'ContinuousGlucoseMonitor',
      'SmartThermometer',
      '_healthKit',
      '_fitbit',
      '_oura',
      '_cgm',
      '_thermometer',
      'BiometricSnapshot.mock',
      '_calculateHRVTrend',
      '_calculateTemperatureTrend',
      '_analyzeGlucose',
      'math.Random(',
      'Random(',
      '.nextDouble(',
      '.nextInt(',
      '?? 40.0',
      '?? 36.5',
      '?? 95.0',
      "'daily_steps': 8500",
      "'active_minutes': 45",
      "'sleep_score': 82",
      "'glucose': 95.0",
    ]) {
      expect(
        source.contains(forbidden),
        isFalse,
        reason: 'Synthetic health behavior survived: $forbidden',
      );
    }

    expect(
      source.contains("'glucose': canonicalSnapshot"),
      isFalse,
      reason: 'Glucose remains unavailable until a verified provider exists.',
    );
  });
}
