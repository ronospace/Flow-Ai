import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Health Sleep card consumes real snapshot sleep duration', () {
    final health = File(
      'lib/features/health/screens/health_screen.dart',
    ).readAsStringSync();

    expect(health, contains("'Sleep Duration'"));
    expect(health, contains('snapshot?.sleepHours'));
    expect(health, contains('toStringAsFixed(1)'));
    expect(health, isNot(contains("'Sleep Quality'")));
  });

  test('Sleep remains truthful when no observation exists', () {
    final health = File(
      'lib/features/health/screens/health_screen.dart',
    ).readAsStringSync();

    final pos = health.indexOf("'Sleep Duration'");
    expect(pos, greaterThanOrEqualTo(0));

    final start = health.lastIndexOf('_buildBiometricCard(', pos);
    final next = health.indexOf('_buildBiometricCard(', pos + 1);

    final segment = health.substring(start, next >= 0 ? next : health.length);

    expect(segment, contains("'No data'"));
    expect(segment, isNot(contains('comingSoon')));
    expect(segment, isNot(contains('releaseLabel:')));
  });
}
