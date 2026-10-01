import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Android Health Connect manifest uses current-feature minimum scope',
    () {
      final manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();

      for (final permission in <String>[
        'READ_HEART_RATE',
        'READ_BODY_TEMPERATURE',
        'READ_SLEEP',
        'READ_MENSTRUATION',
      ]) {
        expect(manifest, contains(permission));
      }

      for (final permission in <String>[
        'READ_RESTING_HEART_RATE',
        'READ_HEART_RATE_VARIABILITY',
        'READ_STEPS',
        'READ_ACTIVE_CALORIES_BURNED',
        'READ_OXYGEN_SATURATION',
        'READ_RESPIRATORY_RATE',
        'READ_HYDRATION',
      ]) {
        expect(
          manifest,
          isNot(contains(permission)),
          reason: 'Android release must satisfy Health Connect minimum scope',
        );
      }
    },
  );

  test('Android runtime health request matches manifest minimum scope', () {
    final source = File(
      'lib/core/services/advanced_biometric_service.dart',
    ).readAsStringSync();

    final start = source.indexOf(
      'static const List<HealthDataType> _androidDataTypes',
    );
    final end = source.indexOf('];', start);

    expect(start, greaterThanOrEqualTo(0));
    expect(end, greaterThan(start));

    final block = source.substring(start, end);

    for (final type in <String>[
      'HealthDataType.HEART_RATE',
      'HealthDataType.BODY_TEMPERATURE',
      'HealthDataType.SLEEP_ASLEEP',
      'HealthDataType.MENSTRUATION_FLOW',
    ]) {
      expect(block, contains(type));
    }

    for (final type in <String>[
      'HealthDataType.RESTING_HEART_RATE',
      'HealthDataType.HEART_RATE_VARIABILITY_RMSSD',
      'HealthDataType.STEPS',
      'HealthDataType.ACTIVE_ENERGY_BURNED',
      'HealthDataType.BLOOD_OXYGEN',
      'HealthDataType.RESPIRATORY_RATE',
      'HealthDataType.WATER',
      'HealthDataType.SLEEP_AWAKE',
      'HealthDataType.SLEEP_DEEP',
      'HealthDataType.SLEEP_REM',
    ]) {
      expect(block, isNot(contains(type)));
    }
  });

  test(
    'current Health UI proves retained metrics have user-facing purpose',
    () {
      final health = File(
        'lib/features/health/screens/health_screen.dart',
      ).readAsStringSync();

      expect(health, contains("'Heart Rate'"));
      expect(health, contains('snapshot?.heartRate'));

      expect(health, contains("'Temperature'"));
      expect(health, contains('snapshot?.bodyTemperature'));

      expect(health, contains("'Sleep Duration'"));
      expect(health, contains('snapshot?.sleepHours'));
    },
  );

  test('Android Health Connect disclosure matches minimum scope', () {
    final dialog = File(
      'lib/features/health/widgets/healthkit_permission_dialog.dart',
    ).readAsStringSync();

    final banner = File(
      'lib/features/health/widgets/healthkit_disclosure_banner.dart',
    ).readAsStringSync();

    expect(dialog, contains('Platform.isIOS'));
    expect(dialog, contains("'Heart rate and HRV'"));
    expect(dialog, contains("'Heart rate'"));

    expect(banner, contains('Platform.isIOS'));
    expect(banner, contains("'Heart rate & HRV for cycle correlation'"));
    expect(banner, contains("'Heart rate for cycle correlation'"));

    expect(dialog, isNot(contains('Activity and steps')));
    expect(banner, isNot(contains('Activity & steps for wellness insights')));
  });

  test('Android historical Steps read is fail-closed', () {
    final source = File(
      'lib/core/services/advanced_biometric_service.dart',
    ).readAsStringSync();

    final stepsRead = source.indexOf('getTotalStepsInInterval');
    expect(stepsRead, greaterThanOrEqualTo(0));

    final methodStart = source.lastIndexOf(
      'Future<List<BiometricHistoryPoint>>',
      stepsRead,
    );
    expect(methodStart, greaterThanOrEqualTo(0));

    final region = source.substring(methodStart, stepsRead);

    expect(region, contains('if (Platform.isAndroid)'));
    expect(region, contains('return const <BiometricHistoryPoint>[];'));
  });
}
