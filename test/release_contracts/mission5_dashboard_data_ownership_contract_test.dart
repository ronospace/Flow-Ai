import "dart:io";

import "package:flutter_test/flutter_test.dart";

void main() {
  test("dashboard cycle history has one centralized owner", () {
    final dashboard = File(
      "lib/features/health/screens/real_time_health_dashboard.dart",
    ).readAsStringSync();
    final service = File(
      "lib/core/services/analytics_service.dart",
    ).readAsStringSync();

    expect(dashboard, isNot(contains("DatabaseService")));
    expect(dashboard, contains("AnalyticsService.instance"));
    expect(dashboard, contains(".getPersistedCycleHistory()"));
    expect(dashboard, contains("cycleHistory: cycleHistory"));

    expect(service, contains("getPersistedCycleHistory() async"));
    expect(service, contains("_databaseService.getAllCycles()"));
  });
}
