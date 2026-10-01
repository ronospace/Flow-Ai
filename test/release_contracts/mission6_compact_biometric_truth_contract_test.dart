import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Stress compact biometric tile keeps truthful centralized roadmap status',
    () {
      final health = File(
        'lib/features/health/screens/health_screen.dart',
      ).readAsStringSync();

      final pos = health.indexOf("'Stress Level'");
      expect(pos, greaterThanOrEqualTo(0));

      final start = health.lastIndexOf('_buildBiometricCard(', pos);
      final next = health.indexOf('_buildBiometricCard(', pos + 1);

      final segment = health.substring(start, next >= 0 ? next : health.length);

      expect(segment, contains("'No data'"));
      expect(segment, contains("'Q4 2026'"));
      expect(segment, contains('releaseLabel:'));
      expect(segment, contains('AppFeatureAvailability.comingSoon'));
    },
  );

  test('live biometric metrics retain No data semantics', () {
    final health = File(
      'lib/features/health/screens/health_screen.dart',
    ).readAsStringSync();

    expect(health, contains("'Heart Rate'"));
    expect(health, contains("'Temperature'"));
    expect(health, contains("'No data'"));
  });
}
