import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final feelings = File(
    'lib/features/tracking/screens/enhanced_daily_feelings_tracker.dart',
  ).readAsStringSync();

  final health = File(
    'lib/features/health/screens/health_screen.dart',
  ).readAsStringSync();

  test('unrecorded feelings use truthful first-input copy', () {
    expect(RegExp('Tap a number to record').allMatches(feelings).length, 3);
    expect(feelings, isNot(contains('Tap or drag to record')));
  });

  test('coverage separates observations from availability', () {
    expect(health, contains('snapshot?.metricProvenance.length ?? 0'));
    expect(health, contains('observed metric'));
    expect(health, contains('availability coverage'));
    expect(health, isNot(contains('synced metric')));
    expect(health, isNot(contains('availability only')));
  });
}
