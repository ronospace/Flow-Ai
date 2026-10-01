import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Health detail does not consume HealthProvider healthScore', () {
    final screen = File(
      'lib/features/health/screens/health_screen.dart',
    ).readAsStringSync();

    expect(screen, contains('Data Coverage'));
    expect(screen, isNot(contains('healthProvider.healthScore')));
    expect(screen, isNot(contains('Health Score')));
  });

  test('Home uses the enhanced analytics release path', () {
    final home = File(
      'lib/features/cycle/screens/home_screen.dart',
    ).readAsStringSync();

    expect(home, contains('EnhancedAnalyticsDashboardScreen('));

    expect(
      home,
      isNot(
        contains(
          "import '../../analytics/screens/analytics_dashboard_screen.dart'",
        ),
      ),
    );
  });
}
