import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('M5.7B uses genuine historical Health observations', () {
    final provider = File(
      'lib/core/services/advanced_biometric_service.dart',
    ).readAsStringSync();

    final visualization = File(
      'lib/features/visualization/services/'
      'advanced_visualization_service.dart',
    ).readAsStringSync();

    for (final required in <String>[
      'getHistoricalSleepHours',
      'HealthDataType.SLEEP_ASLEEP',
      'getHealthDataFromTypes',
      'point.dateFrom',
      'point.dateTo',
      'getHistoricalDailySteps',
      'getTotalStepsInInterval',
      'BiometricHistoryPoint',
    ]) {
      expect(
        provider.contains(required),
        isTrue,
        reason: 'Real history binding missing: $required',
      );
    }

    for (final required in <String>[
      'getHistoricalSleepHours',
      'getHistoricalDailySteps',
      "'type': 'sleep_hours'",
      "'type': 'steps'",
      "'source': 'health'",
      'No synced sleep history is available',
      'No synced activity history is available',
    ]) {
      expect(
        visualization.contains(required),
        isTrue,
        reason: 'Visualization binding missing: $required',
      );
    }

    for (final forbidden in <String>[
      '5 + random',
      '5-9 hours',
      'activity_percentage',
      'Activity %',
      '0-100% activity',
      'math.Random()',
      '.nextDouble()',
    ]) {
      expect(
        visualization.contains(forbidden),
        isFalse,
        reason: 'Synthetic visualization survived: $forbidden',
      );
    }
  });
}
