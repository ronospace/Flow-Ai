import "dart:io";

import "package:flutter_test/flutter_test.dart";

void main() {
  test("real-time health trends use only real domain-correct data", () {
    final dashboard = File(
      "lib/features/health/screens/real_time_health_dashboard.dart",
    ).readAsStringSync();

    final chart = File(
      "lib/features/health/widgets/health_trend_chart.dart",
    ).readAsStringSync();

    expect(
      dashboard,
      contains("context.watch<AnalyticsProvider>().analyticsHistory"),
    );
    expect(
      dashboard,
      contains("context.read<AnalyticsProvider>().loadAnalyticsHistory()"),
    );

    expect(dashboard, contains("reading.type == _selectedMetric"));
    expect(dashboard, contains("reading.value.isFinite"));
    expect(dashboard, contains("history.sleepHours.entries"));
    expect(dashboard, contains("Duration(hours: _selectedTimeRange)"));

    expect(dashboard, isNot(contains("List<FlSpot> _generateTrendData()")));
    expect(
      dashboard,
      isNot(contains("return const <FlSpot>[];\n  }\n\n  Color")),
    );
    expect(dashboard, isNot(contains("Keep only last 100 readings")));

    expect(chart, contains("double _getMaxX()"));
    expect(chart, contains("maxX: _getMaxX()"));
    expect(chart, contains("return 'Sleep Hours'"));
    expect(chart, contains("return 'h'"));

    expect(chart, isNot(contains("return 'Sleep Score'")));
    expect(chart, isNot(contains("targetValue = 85.0")));
    expect(chart, contains("Available synced readings from the last 24 hours"));
  });
}
