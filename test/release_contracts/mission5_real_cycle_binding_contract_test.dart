import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('live health dashboard uses persisted real cycle history', () {
    final dashboard = File(
      'lib/features/health/screens/real_time_health_dashboard.dart',
    ).readAsStringSync();

    final analytics = File(
      'lib/core/services/analytics_service.dart',
    ).readAsStringSync();

    expect(dashboard, contains('AnalyticsService.instance'));

    expect(dashboard, contains('getPersistedCycleHistory'));

    expect(dashboard, isNot(contains('_generateMockCycleHistory')));

    expect(analytics, contains('getPersistedCycleHistory() async'));

    expect(analytics, contains('_databaseService.getAllCycles()'));
  });

  test('retired SmartNotificationService does not return', () {
    expect(
      File('lib/core/services/smart_notification_service.dart').existsSync(),
      isFalse,
    );
  });

  test('active AI notification scheduler retains startup ownership', () {
    final main = File('lib/main.dart').readAsStringSync();

    expect(main, contains('AINotificationScheduler.instance.initialize()'));
  });
}
