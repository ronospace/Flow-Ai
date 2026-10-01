import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/core/ui/app_upcoming_feature_status.dart',
  ).readAsStringSync();

  test('compact roadmap status is rounded rectangle not pill geometry', () {
    expect(source, contains('compact ? 6 : AppGeometry.radiusSm'));
    expect(source, contains('final badgeHorizontal = compact ? 6.0 : 8.0;'));
    expect(source, contains('final badgeVertical = compact ? 2.0 : 4.0;'));
    expect(source, contains('fontSize: 8'));
  });
}
