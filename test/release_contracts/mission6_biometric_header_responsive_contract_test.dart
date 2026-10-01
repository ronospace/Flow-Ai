import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('biometric roadmap status participates in available header width', () {
    final health = File(
      'lib/features/health/screens/health_screen.dart',
    ).readAsStringSync();

    expect(health, contains('const Spacer()'));
    expect(health, contains('AppUpcomingFeatureStatus('));
    expect(health, contains('compact: true'));
  });

  test('compact roadmap status remains quarter-only', () {
    final status = File(
      'lib/core/ui/app_upcoming_feature_status.dart',
    ).readAsStringSync();

    expect(status, contains('!compact'));
    expect(status, contains('final badgeHorizontal = compact ? 6.0 : 8.0;'));
    expect(status, contains('AppGeometry.radiusSm'));
  });

  test('Stress remains centralized Q3 placeholder', () {
    final health = File(
      'lib/features/health/screens/health_screen.dart',
    ).readAsStringSync();

    expect(health, contains("'Stress Level'"));
    expect(health, contains("releaseLabel: 'Q4 2026'"));
    expect(health, contains('AppFeatureAvailability.comingSoon'));
  });
}
