import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/features/tracking/screens/enhanced_daily_feelings_tracker.dart',
  ).readAsStringSync();

  test('Daily Feelings selector keeps canonical tab order', () {
    expect(
      source,
      contains("labels: const ['Mood', 'Energy', 'Symptoms', '+Tag(s)']"),
    );
  });

  test('+Tag(s) receives selector emphasis', () {
    expect(source, contains('emphasizedIndices: const {3}'));
  });
}
