import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final header = File(
    'lib/features/health/widgets/health_section_header.dart',
  ).readAsStringSync();

  final health = File(
    'lib/features/health/screens/health_screen.dart',
  ).readAsStringSync();

  test('Health Overview remains the page-level title', () {
    final pos = health.indexOf("'Health Overview'");
    expect(pos, greaterThanOrEqualTo(0));

    final segment = health.substring(pos, (pos + 450).clamp(0, health.length));

    expect(segment, contains('headlineSmall'));
  });

  test('central section header owns the shared heading API', () {
    expect(header, contains('final IconData icon'));
    expect(header, contains('final String title'));
    expect(header, contains('final Widget? trailing'));
  });

  test('core sibling Health sections use central header', () {
    for (final title in [
      'Data Coverage',
      'Biometric Monitoring',
      'Health Insights',
      'Health Goals',
    ]) {
      expect(health, contains("title: '$title'"));
    }
  });

  test('Health section heading hierarchy is centralized and responsive', () {
    final source = File(
      'lib/features/health/widgets/health_section_header.dart',
    ).readAsStringSync();

    expect(source, contains('return Wrap('));
    expect(source, contains('WrapCrossAlignment.center'));
    expect(source, contains('Icon(icon, size: 24'));
    expect(source, contains('theme.textTheme.titleLarge'));
    expect(source, isNot(contains('TextOverflow.ellipsis')));
    expect(source, isNot(contains('maxLines: 1')));
  });

  test('Symptom Tracker keeps the shared responsive header', () {
    final source = File(
      'lib/features/health/screens/health_screen.dart',
    ).readAsStringSync();

    expect(source, contains("title: 'Symptom Tracker'"));
    expect(source, contains('AppSectionActionButton('));
    expect(source, contains("label: 'Add Symptom'"));
    expect(source, contains('onPressed: _openSymptomTracker'));
    expect(source, contains('HealthSectionHeader('));
  });
}
