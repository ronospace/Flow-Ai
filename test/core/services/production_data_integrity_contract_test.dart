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
}
