import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cycle statistics use completed recorded cycle lengths', () {
    final source = File(
      'lib/features/insights/screens/insights_screen.dart',
    ).readAsStringSync();

    expect(source, contains('cycle.isComplete'));
    expect(source, contains('cycle.cycleLength!'));
    expect(source, isNot(contains('Mock cycle lengths')));
    expect(source, isNot(contains('return 28.0')));
    expect(source, isNot(contains('return 2.5')));
  });

  test('mood and energy charts use recorded values only', () {
    final source = File(
      'lib/features/insights/widgets/mood_energy_chart.dart',
    ).readAsStringSync();

    expect(source, contains('entry.value.mood!'));
    expect(source, contains('entry.value.energy!'));
    expect(source, isNot(contains('_getMockMoodScore')));
    expect(source, isNot(contains('_getMockEnergyScore')));
    expect(source, isNot(contains('Simulate mood')));
    expect(source, isNot(contains('Simulate energy')));
  });

  test('symptom heatmap uses recorded daily symptoms only', () {
    final source = File(
      'lib/features/insights/widgets/symptom_heatmap.dart',
    ).readAsStringSync();

    expect(source, contains('entry.value.symptoms'));
    expect(source, contains('observationsByCycleDay'));
    expect(source, isNot(contains('_generateSymptomPattern')));
    expect(source, isNot(contains('Mock symptom data')));
    expect(source, isNot(contains("case 'Cramps'")));
  });
}
