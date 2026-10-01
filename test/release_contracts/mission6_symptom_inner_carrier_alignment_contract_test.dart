import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final health = File(
    'lib/features/health/screens/health_screen.dart',
  ).readAsStringSync();

  String functionRegion(String startMarker, String endMarker) {
    final start = health.indexOf(startMarker);
    final end = health.indexOf(endMarker, start + startMarker.length);

    expect(start, greaterThanOrEqualTo(0));
    expect(end, greaterThan(start));

    return health.substring(start, end);
  }

  test('Symptom and Health Insights share the same outer section inset', () {
    const insightsMarker =
        'Widget _buildHealthInsightsSection(AppLocalizations localizations)';
    const symptomMarker =
        'Widget _buildSymptomTracker(AppLocalizations localizations)';
    const goalsMarker =
        'Widget _buildHealthGoals(AppLocalizations localizations)';

    final insights = functionRegion(insightsMarker, symptomMarker);
    final symptom = functionRegion(symptomMarker, goalsMarker);

    final outerPadding = RegExp(
      r'return Container\(\s*'
      r'(?:width:\s*double\.infinity,\s*)?'
      r'padding:\s*const\s+EdgeInsets\.all\(([\d.]+)\)',
    );

    final insightsPadding = outerPadding.firstMatch(insights)?.group(1);
    final symptomPadding = outerPadding.firstMatch(symptom)?.group(1);

    expect(insightsPadding, '18');
    expect(symptomPadding, insightsPadding);
  });

  test('Symptom preserves centralized inner carrier geometry', () {
    const symptomMarker =
        'Widget _buildSymptomTracker(AppLocalizations localizations)';
    const goalsMarker =
        'Widget _buildHealthGoals(AppLocalizations localizations)';

    final symptom = functionRegion(symptomMarker, goalsMarker);

    expect(symptom, contains('AppSectionContentCarrier('));
    expect(
      RegExp(
        r'padding:\s*const\s+EdgeInsets\.symmetric\(\s*'
        r'horizontal:\s*8,\s*vertical:\s*14\s*\)',
      ).hasMatch(symptom),
      isTrue,
    );
    expect(symptom, contains('AppSectionActionButton('));
    expect(symptom, contains("label: 'Add Symptom'"));
  });

  test('Add Symptom button edges match the carrier top spacing', () {
    const symptomMarker =
        'Widget _buildSymptomTracker(AppLocalizations localizations)';
    const goalsMarker =
        'Widget _buildHealthGoals(AppLocalizations localizations)';

    final symptom = functionRegion(symptomMarker, goalsMarker);

    expect(
      RegExp(
        r'AppSectionContentCarrier\(.*?'
        r'horizontal:\s*8,\s*vertical:\s*14',
        dotAll: true,
      ).hasMatch(symptom),
      isTrue,
    );

    expect(
      RegExp(
        r'Padding\(\s*'
        r'padding:\s*const\s+EdgeInsets\.symmetric\('
        r'horizontal:\s*6\).*?'
        r'AppSectionActionButton\(.*?'
        r"label:\s*'Add Symptom'",
        dotAll: true,
      ).hasMatch(symptom),
      isTrue,
    );
  });
}
