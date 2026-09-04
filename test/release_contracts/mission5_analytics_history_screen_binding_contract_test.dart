import "dart:io";

import "package:flutter_test/flutter_test.dart";

void main() {
  test("analytics history binding is required and centralized", () {
    final card = File(
      "lib/features/analytics/widgets/health_analytics_card.dart",
    ).readAsStringSync();

    final enhanced = File(
      "lib/features/analytics/screens/enhanced_analytics_dashboard_screen.dart",
    ).readAsStringSync();

    final standard = File(
      "lib/features/analytics/screens/analytics_dashboard_screen.dart",
    ).readAsStringSync();

    final provider = File(
      "lib/features/analytics/providers/analytics_provider.dart",
    ).readAsStringSync();

    expect(card, contains("final AnalyticsHistory history;"));
    expect(card, contains("required this.history"));
    expect(card, isNot(contains("this.history ?? AnalyticsHistory.empty()")));

    for (final screen in [enhanced, standard]) {
      expect(screen, contains("history: provider.analyticsHistory"));
      expect(screen, contains("loadAllAnalytics()"));
      expect(
        screen,
        isNot(
          contains("HealthAnalyticsCard(analytics: provider.healthAnalytics!)"),
        ),
      );
    }

    expect(provider, contains("loadAnalyticsHistory()"));
    expect(provider, contains("_analyticsHistory = AnalyticsHistory.empty();"));
  });
}
