import "dart:io";

import "package:flutter_test/flutter_test.dart";

void main() {
  test("analytics card uses real domain-correct history", () {
    final source = File(
      "lib/features/analytics/widgets/health_analytics_card.dart",
    ).readAsStringSync();

    expect(source, contains("final AnalyticsHistory history;"));
    expect(source, contains("required this.history"));
    expect(source, isNot(contains("this.history ?? AnalyticsHistory.empty()")));

    expect(source, contains("values: history.mood"));
    expect(source, contains("values: history.energy"));
    expect(source, contains("values: history.sleepHours"));

    expect(source, contains("fixedMaxY: 10"));
    expect(source, contains("unit: \"/10\""));
    expect(source, contains("unit: \"hours\""));

    expect(source, contains("day.difference(previousDay).inDays > 1"));

    expect(source, contains("No \$label history available"));

    expect(source, isNot(contains("List.generate(31")));
    expect(source, isNot(contains("_generateMoodSpots")));
    expect(source, isNot(contains("_generateEnergySpots")));
    expect(source, isNot(contains("_generateSleepSpots")));
    expect(source, isNot(contains("baseValue =")));
    expect(source, isNot(contains("variation =")));
  });
}
