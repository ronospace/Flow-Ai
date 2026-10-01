import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('compact upcoming presentation suppresses Coming Soon row', () {
    final shared = File(
      'lib/core/ui/app_upcoming_feature_status.dart',
    ).readAsStringSync();

    expect(shared, contains('!compact'));
    expect(
      shared,
      contains('availability == AppFeatureAvailability.comingSoon'),
    );
    expect(shared, contains("'Coming Soon'"));
  });

  test('Stress uses compact Q3 roadmap presentation', () {
    final health = File(
      'lib/features/health/screens/health_screen.dart',
    ).readAsStringSync();

    expect(health, contains("'Stress Level'"));
    expect(health, contains("releaseLabel: 'Q4 2026'"));
    expect(health, contains('compact: true'));
  });

  test('Home AI Health Coach remains Q4 Coming Soon', () {
    final home = File(
      'lib/features/cycle/widgets/premium_features_preview.dart',
    ).readAsStringSync();

    expect(home, contains("'AI Health Coach'"));
    expect(home, contains("'Q4 2026'"));
    expect(home, contains('AppFeatureAvailability.comingSoon'));
  });
}
