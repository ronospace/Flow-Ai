import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('empty health history is unavailable rather than stable', () {
    final analytics = File(
      'lib/core/services/analytics_service.dart',
    ).readAsStringSync();

    final card = File(
      'lib/features/analytics/widgets/health_analytics_card.dart',
    ).readAsStringSync();

    expect(analytics, contains('final bool isAvailable;'));
    expect(analytics, contains('factory TrendData.unavailable()'));
    expect(analytics, contains('isAvailable: false'));

    final emptyStart = analytics.indexOf('factory HealthAnalytics.empty()');
    expect(emptyStart, greaterThanOrEqualTo(0));

    final emptySlice = analytics.substring(
      emptyStart,
      (emptyStart + 1000).clamp(0, analytics.length),
    );

    expect(emptySlice, isNot(contains('TrendData.stable()')));
    expect(
      RegExp(r'TrendData\.unavailable\(\)').allMatches(emptySlice).length,
      greaterThanOrEqualTo(3),
    );

    expect(card, contains('trend.isAvailable'));
    expect(card, contains("'No data'"));

    expect(analytics, contains('healthAnalytics.moodTrend.isAvailable'));
  });
}
