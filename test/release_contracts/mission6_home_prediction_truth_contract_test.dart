import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Home prediction uses CycleProvider truth only', () {
    final source = File(
      'lib/features/cycle/screens/home_screen.dart',
    ).readAsStringSync();

    expect(source, contains('final prediction = provider.predictions;'));
    expect(source, contains('if (prediction == null)'));
    expect(source, contains('prediction.confidence.score'));
    expect(source, contains('prediction.daysUntilNextPeriod'));

    expect(
      source,
      isNot(contains('PeriodPredictionEngine().predictNextPeriod(')),
    );
    expect(source, isNot(contains('PeriodPrediction? _currentPrediction;')));
  });
  test('Home contains no synthetic metric accuracy fallback', () {
    final source = File(
      'lib/features/cycle/screens/home_screen.dart',
    ).readAsStringSync();

    expect(source, isNot(contains("'97'")));
    expect(source, isNot(contains('"97"')));
    expect(source, contains('String accuracy,'));
  });
}
