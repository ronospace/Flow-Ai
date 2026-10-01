import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final health = File(
    'lib/features/health/screens/health_screen.dart',
  ).readAsStringSync();

  test('Symptom Tracker title remains independent from its action', () {
    final title = health.indexOf("'Symptom Tracker'");
    expect(title, greaterThanOrEqualTo(0));

    final start = health.lastIndexOf('const HealthSectionHeader(', title);
    expect(start, greaterThanOrEqualTo(0));

    final segment = health.substring(
      start,
      (title + 1100).clamp(0, health.length),
    );

    expect(segment, contains('const HealthSectionHeader('));
    expect(segment, isNot(contains('trailing:')));
    expect(segment, contains('AppSectionActionButton('));
    expect(segment, contains('AppSectionContentCarrier('));
    expect(segment, contains("'Add Symptom'"));
    expect(segment, contains('Icons.add'));
    expect(segment, contains('onPressed: _openSymptomTracker'));
  });

  test('Add Symptom has one centralized navigation owner', () {
    expect(health, contains('void _openSymptomTracker()'));
    expect(health, contains('HapticFeedback.lightImpact()'));
    expect(health, contains('Navigator.of(context).push('));
    expect(health, contains('EnhancedDailyFeelingsTracker('));
    expect(health, contains('selectedDate: DateTime.now()'));

    expect(
      RegExp(r'void _openSymptomTracker\(\)').allMatches(health).length,
      1,
    );
    expect(
      RegExp(r'onPressed: _openSymptomTracker').allMatches(health).length,
      1,
    );
  });

  test('symptom chips use centralized numeric radius correctly', () {
    expect(
      RegExp(
        r'BorderRadius\.circular\(\s*AppGeometry\.radiusSm\s*,?\s*\)',
      ).hasMatch(health),
      isTrue,
    );
    expect(health, isNot(contains('borderRadius: AppGeometry.radiusSm,')));
  });
}
