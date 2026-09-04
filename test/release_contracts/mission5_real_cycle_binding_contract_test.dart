import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('health dashboard uses real persisted cycle history', () {
    final source = File(
      'lib/features/health/screens/real_time_health_dashboard.dart',
    ).readAsStringSync();

    expect(source.contains('_generateMockCycleHistory'), isFalse);
    expect(source.contains("DatabaseService.instance.getAllCycles()"), isFalse);
    expect(source.contains("AnalyticsService.instance"), isTrue);
    expect(source.contains(".getPersistedCycleHistory()"), isTrue);
  });

  test('smart notifications use real persisted cycle history', () {
    final source = File(
      'lib/core/services/smart_notification_service.dart',
    ).readAsStringSync();

    expect(source.contains('_generateMockCycleData'), isFalse);
    expect(
      'DatabaseService.instance.getAllCycles()'.allMatches(source).length,
      greaterThanOrEqualTo(2),
    );
  });
}
