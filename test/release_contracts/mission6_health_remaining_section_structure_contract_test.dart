import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final health = File(
    'lib/features/health/screens/health_screen.dart',
  ).readAsStringSync();

  test('Symptom Tracker preserves centralized header and action', () {
    final start = health.indexOf('Widget _buildSymptomTracker(');
    final end = health.indexOf('Widget _buildHealthGoals(', start);

    expect(start, greaterThanOrEqualTo(0));
    expect(end, greaterThan(start));

    final segment = health.substring(start, end);

    expect(segment, contains('HealthSectionHeader('));
    expect(segment, contains('Icons.healing_outlined'));
    expect(segment, contains("'Symptom Tracker'"));
    expect(segment, contains('AppSectionActionButton('));
    expect(segment, contains('AppSectionContentCarrier('));
    expect(segment, contains('onPressed: _openSymptomTracker'));
    expect(segment, contains('Icons.add'));
    expect(segment, contains("'Add Symptom'"));
    expect(segment, contains('AppGeometry.radiusSm'));
    expect(segment, isNot(contains('BorderRadius.circular(20)')));
  });

  test('Health Insights owns an independent carrier', () {
    final start = health.indexOf('Widget _buildHealthInsightsSection(');
    final end = health.indexOf('Widget _buildSymptomTracker(', start);

    final segment = health.substring(start, end);

    expect(segment, contains('return Container('));
    expect(segment, contains('AppGeometry.carrierRadius'));
    expect(segment, contains("'Health Insights'"));
  });

  test('Health Goals owns an independent carrier', () {
    final start = health.indexOf('Widget _buildHealthGoals(');
    expect(start, greaterThanOrEqualTo(0));

    final segment = health.substring(start);

    expect(segment, contains('return Container('));
    expect(segment, contains('AppGeometry.carrierRadius'));
    expect(segment, contains("'Health Goals'"));
  });
}
