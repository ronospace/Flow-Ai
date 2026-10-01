import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Stress Q3 badge keeps natural width after Spacer', () {
    final health = File(
      'lib/features/health/screens/health_screen.dart',
    ).readAsStringSync();

    final pos = health.indexOf('AppUpcomingFeatureStatus(');
    expect(pos, greaterThanOrEqualTo(0));

    final rowStart = health.lastIndexOf('Row(', pos);
    final beforeBadge = health.substring(rowStart, pos);

    expect(beforeBadge, contains('Spacer()'));

    final tail = beforeBadge.length > 250
        ? beforeBadge.substring(beforeBadge.length - 250)
        : beforeBadge;

    expect(tail, isNot(contains('Flexible(')));
    expect(tail, isNot(contains('Expanded(')));
  });

  test('Stress remains Q4 2026 and No data', () {
    final health = File(
      'lib/features/health/screens/health_screen.dart',
    ).readAsStringSync();

    expect(health, contains("'Stress Level'"));
    expect(health, contains("releaseLabel: 'Q4 2026'"));
    expect(health, contains("'No data'"));
  });
}
