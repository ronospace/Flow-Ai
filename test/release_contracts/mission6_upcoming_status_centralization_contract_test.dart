import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Home quarter and availability are independent', () {
    final card = File(
      'lib/features/cycle/widgets/premium_feature_preview_card.dart',
    ).readAsStringSync();

    final grid = File(
      'lib/features/cycle/widgets/premium_features_preview.dart',
    ).readAsStringSync();

    expect(card, contains('availability == AppFeatureAvailability.comingSoon'));

    expect(card, isNot(contains("estimatedDate == 'Q2 2026'")));

    expect(grid, contains("estimatedDate: 'Q4 2026'"));
    expect(grid, contains('availability: AppFeatureAvailability.comingSoon'));
  });

  test('Stress keeps Q3 Coming Soon placeholder', () {
    final health = File(
      'lib/features/health/screens/health_screen.dart',
    ).readAsStringSync();

    expect(health, contains("'Stress Level'"));
    expect(health, contains("releaseLabel: 'Q4 2026'"));
    expect(health, contains('AppFeatureAvailability.comingSoon'));
    expect(health, contains('AppUpcomingFeatureStatus('));
  });

  test('Shared Health status has no empty rendering requirement', () {
    final health = File(
      'lib/features/health/screens/health_screen.dart',
    ).readAsStringSync();

    expect(health, contains('status != null && status.isNotEmpty'));
  });
}
