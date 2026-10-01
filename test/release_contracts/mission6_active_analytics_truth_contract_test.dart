import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('home advanced analytics route is the audited production path', () {
    final home = File(
      'lib/features/cycle/screens/home_screen.dart',
    ).readAsStringSync();

    final enhanced = File(
      'lib/features/analytics/screens/'
      'enhanced_analytics_dashboard_screen.dart',
    ).readAsStringSync();

    expect(home, contains('EnhancedAnalyticsDashboardScreen()'));
    expect(
      enhanced,
      contains('AdvancedAnalyticsDashboard(provider: provider)'),
    );
    expect(enhanced, contains('loadAllAnalytics()'));
  });

  test('active advanced analytics contains no synthetic user scores', () {
    final source = File(
      'lib/features/analytics/widgets/'
      'advanced_analytics_dashboard.dart',
    ).readAsStringSync();

    for (final forbidden in <String>[
      '?? 70.0',
      '?? 0.8',
      '?? 85.0',
      '_generateHealthData',
      '_generateQualityData',
      '_getHealthPatterns',
      'optimal hormonal balance',
      'healthy reproductive patterns',
      '23% improved cycle regularity',
      '15% increase in cycle variability',
      '18% better mood scores',
      '31%',
    ]) {
      expect(
        source,
        isNot(contains(forbidden)),
        reason: 'Active analytics must not fabricate $forbidden',
      );
    }

    expect(source, contains('Prediction validation unavailable'));
    expect(source, contains('Missing data remains missing'));
  });

  test('analytics service does not manufacture health or prediction truth', () {
    final source = File(
      'lib/core/services/analytics_service.dart',
    ).readAsStringSync();

    for (final forbidden in <String>[
      'Using a mock prediction',
      'predictedStartDate: pastCycles.last.startDate.add',
      'predictedLength: 28',
      '_calculateOverallHealthScore(',
      '_calculateConfidenceScore(',
      'overallHealthScore: 50',
    ]) {
      expect(
        source,
        isNot(contains(forbidden)),
        reason: 'Production analytics must not fabricate $forbidden',
      );
    }

    expect(
      source,
      contains('does not currently persist historical production'),
    );
  });

  test(
    'health detail screen presents availability rather than a health rating',
    () {
      final provider = File(
        'lib/features/health/providers/health_provider.dart',
      ).readAsStringSync();

      final screen = File(
        'lib/features/health/screens/health_screen.dart',
      ).readAsStringSync();

      expect(provider, contains('hasObservedHealthData'));
      expect(provider, contains('metricProvenance.isNotEmpty'));

      expect(screen, contains('Data Coverage'));
      expect(screen, contains('availability coverage'));
      expect(screen, contains('observed metric'));
      expect(screen, contains('snapshot?.metricProvenance.length ?? 0'));
      expect(screen, isNot(contains('synced metric')));
      expect(screen, isNot(contains('availability only')));
      expect(screen, isNot(contains('healthProvider.healthScore')));
      expect(screen, isNot(contains('HealthScorePainter')));
      expect(screen, isNot(contains('hasVerifiedHealthData')));
    },
  );

  test('reusable analytics cards fail closed', () {
    final healthCard = File(
      'lib/features/analytics/widgets/health_analytics_card.dart',
    ).readAsStringSync();

    final predictionCard = File(
      'lib/features/analytics/widgets/prediction_analytics_card.dart',
    ).readAsStringSync();

    expect(healthCard, isNot(contains('analytics.overallHealthScore')));
    expect(healthCard, isNot(contains('Overall Health Score')));
    expect(healthCard, isNot(contains('Wellness Tips')));

    expect(healthCard, contains('values: history.mood'));
    expect(healthCard, contains('values: history.energy'));
    expect(healthCard, contains('values: history.sleepHours'));
    expect(healthCard, contains(r'No $label history available'));

    expect(predictionCard, contains('analytics.totalPredictions == 0'));
    expect(predictionCard, contains('Prediction validation unavailable'));
  });
}
