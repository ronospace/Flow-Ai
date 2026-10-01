import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final health = File(
    'lib/features/health/screens/health_screen.dart',
  ).readAsStringSync();

  final homeCard = File(
    'lib/features/cycle/widgets/premium_feature_preview_card.dart',
  ).readAsStringSync();

  final shared = File(
    'lib/core/ui/app_upcoming_feature_status.dart',
  ).readAsStringSync();

  test('Home and Health use one roadmap capsule owner', () {
    expect(health, contains('AppUpcomingFeatureStatus('));
    expect(homeCard, contains('AppUpcomingFeatureStatus('));

    expect(
      homeCard,
      isNot(
        contains(
          'color: AppTheme.warningOrange.withValues(\n'
          '                              alpha: 0.1',
        ),
      ),
    );
  });

  test('shared compact capsule owns Home-equivalent geometry', () {
    expect(shared, contains('final badgeHorizontal = compact ? 6.0 : 8.0;'));
    expect(shared, contains('final badgeVertical = compact ? 2.0 : 4.0;'));
    expect(shared, contains('fontSize: 8'));
    expect(shared, contains('compact ? 6 : AppGeometry.radiusSm'));
  });

  test('shared status owner allows semantic accent without duplicating UI', () {
    expect(shared, contains('final Color? color;'));
    expect(shared, contains('final statusColor = color ?? scheme.primary;'));

    expect(homeCard, contains('color: AppTheme.warningOrange'));

    expect(health, contains("releaseLabel: 'Q4 2026'"));
  });
}
