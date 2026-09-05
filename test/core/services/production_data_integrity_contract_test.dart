import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production health paths contain no fabricated runtime data', () {
    final biometricService = File(
      'lib/core/services/advanced_biometric_service.dart',
    ).readAsStringSync();

    final healthScreen = File(
      'lib/features/health/screens/health_screen.dart',
    ).readAsStringSync();

    final homeScreen = File(
      'lib/features/cycle/screens/home_screen.dart',
    ).readAsStringSync();

    final insightsProvider = File(
      'lib/features/insights/providers/insights_provider.dart',
    ).readAsStringSync();

    final exportService = File(
      'lib/features/data_management/services/'
      'data_export_import_service.dart',
    ).readAsStringSync();

    expect(biometricService, isNot(contains('_initializeMockService')));
    expect(biometricService, isNot(contains('_generateMockInsights')));
    expect(biometricService, isNot(contains('Mock Temperature Pattern')));
    expect(biometricService, isNot(contains('mock data for development')));

    expect(healthScreen, isNot(contains('final healthScore = 0.82')));
    expect(homeScreen, isNot(contains('math.sin(')));
    expect(homeScreen, isNot(contains('_unlockPremiumInsights')));

    expect(insightsProvider, isNot(contains('Most common symptom: cramps')));
    expect(insightsProvider, isNot(contains('Premium Insight:')));
    expect(insightsProvider, isNot(contains('addPremiumInsights')));

    expect(exportService, isNot(contains("'date': '2024-01-15'")));
    expect(exportService, isNot(contains('heart_rate')));
    expect(exportService, isNot(contains('ImportedDataSet();')));
    expect(
      exportService,
      isNot(contains('success: true,\n      importedItems: 0')),
    );
  });

  test('Daily Feelings v2 fails closed for unrecorded wellbeing', () {
    final screen = File(
      'lib/features/tracking/screens/enhanced_daily_feelings_tracker.dart',
    ).readAsStringSync();

    final database = File(
      'lib/features/tracking/services/feelings_database_service.dart',
    ).readAsStringSync();

    final analytics = File(
      'lib/features/tracking/services/feelings_analytics_service.dart',
    ).readAsStringSync();

    expect(database, contains('static const int _databaseVersion = 2'));

    expect(database, contains('overall_wellbeing REAL,'));

    expect(
      database,
      contains('overall_wellbeing_recorded INTEGER NOT NULL DEFAULT 0'),
    );

    expect(database, contains("'overall_wellbeing_recorded':"));

    expect(screen, contains('double? _overallWellbeing;'));

    expect(screen, contains('final double? overallWellbeing;'));

    expect(screen, contains("'overallWellbeingRecorded':"));

    expect(screen, isNot(contains('_overallWellbeing = 5.0')));

    expect(analytics, contains('.whereType<double>()'));

    expect(analytics, contains('double? _calculateAverageWellbeing'));

    expect(analytics, contains('final double? averageWellbeing'));

    expect(analytics, isNot(contains('if (entry.overallWellbeing < 4)')));
  });
}
