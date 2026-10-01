import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final card = File(
    'lib/features/health/widgets/healthkit_connection_card.dart',
  ).readAsStringSync();

  test(
    'connection title keeps strong hierarchy without titleLarge wrapping',
    () {
      final pos = card.indexOf('platformName,');
      expect(pos, greaterThanOrEqualTo(0));

      final segment = card.substring(pos, (pos + 420).clamp(0, card.length));

      expect(segment, contains('theme.textTheme.titleMedium'));
      expect(segment, contains('FontWeight.bold'));
      expect(segment, isNot(contains('fontSize:')));
    },
  );

  test('platform titles remain native', () {
    expect(card, contains("'Apple HealthKit'"));
    expect(card, contains("'Health Connect'"));
  });
}
