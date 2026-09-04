import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Mission 5 symptom correlation is persisted-data only', () {
    final source = File(
      'lib/features/visualization/services/'
      'advanced_visualization_service.dart',
    ).readAsStringSync();

    for (final forbidden in <String>[
      '_generateMockCorrelationMatrix',
      'Mock symptom correlation data',
      'Generate mock correlation matrix',
      "'Headache', 'Fatigue', 'Cramps', 'Mood Swings', 'Bloating'",
    ]) {
      expect(
        source.contains(forbidden),
        isFalse,
        reason: 'Production correlation must not contain $forbidden',
      );
    }

    expect(
      source.contains('FeelingsDatabaseService.instance.getEntriesInRange'),
      isTrue,
    );

    expect(source.contains('_calculateSymptomCorrelationMatrix'), isTrue);

    expect(source.contains('Statistics.pearsonCorrelation'), isTrue);

    expect(source.contains('minimumSamples: 3'), isTrue);

    expect(
      source.contains('xValue == null || yValue == null'),
      isTrue,
      reason: 'Missing symptoms must remain missing rather than becoming zero.',
    );

    expect(
      source.contains(
        'Not enough real symptom history to calculate correlations',
      ),
      isTrue,
    );
  });
}
