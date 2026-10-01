import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Active Insights truth contract', () {
    late String screen;

    setUpAll(() {
      screen = File(
        'lib/features/insights/screens/analytics_dashboard_screen.dart',
      ).readAsStringSync();
    });

    test('active Insights delegates to authoritative analytics provider', () {
      expect(screen, contains('context.read<AnalyticsProvider>()'));
      expect(screen, contains('Consumer<AnalyticsProvider>'));
      expect(screen, contains('analytics.cycleAnalytics'));
      expect(screen, contains('analytics.healthAnalytics'));
      expect(screen, contains('analytics.predictionAnalytics'));
      expect(screen, contains('analytics.analyticsHistory'));
      expect(screen, contains('analytics.recommendations'));
    });

    test(
      'synthetic chart generation and fixed confidence claims are absent',
      () {
        for (final prohibited in <String>[
          'return 28',
          'return 92',
          '94% accurate',
          'confidence: 0.92',
          'confidence: 0.85',
          'confidence: 0.78',
          'confidence: 0.94',
          'List.generate(6',
          'List.generate(28',
          'math.sin',
          'math.cos',
          'consistent hormonal balance',
          'within the healthy range',
        ]) {
          expect(
            screen,
            isNot(contains(prohibited)),
            reason:
                'Active Insights must not contain synthetic claim: $prohibited',
          );
        }
      },
    );

    test('truthful widgets replace fabricated analytics', () {
      expect(screen, contains('HealthAnalyticsCard('));
      expect(screen, contains('PredictionAnalyticsCard('));
      expect(screen, contains('RecommendationsList('));
    });

    test('insufficient history fails closed in the UI', () {
      expect(screen, contains('No recorded cycle history yet'));
      expect(screen, contains('Insufficient recorded health history'));
      expect(screen, contains('Prediction validation unavailable'));
    });

    test('decorative export claim is absent', () {
      expect(screen, isNot(contains('Exporting analytics data')));
      expect(screen, isNot(contains('_exportData(')));
    });

    test('unsupported rewarded premium-insights runtime surface is absent', () {
      expect(screen, isNot(contains('PremiumInsightsUnlockCard')));
      expect(screen, isNot(contains('showRewardedAd')));

      expect(
        File(
          'lib/features/cycle/widgets/premium_insights_unlock_card.dart',
        ).existsSync(),
        isFalse,
      );
    });
  });
}
