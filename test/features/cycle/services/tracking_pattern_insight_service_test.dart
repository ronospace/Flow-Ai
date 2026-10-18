import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flow_ai/features/cycle/services/tracking_pattern_insight_service.dart';

void main() {
  Map<String, dynamic> row({
    double? mood,
    double? energy,
    double? pain,
    bool moodObserved = false,
    bool energyObserved = false,
    bool painObserved = false,
  }) {
    return <String, dynamic>{
      'mood': mood,
      'energy': energy,
      'pain': pain,
      'mood_observed': moodObserved ? 1 : 0,
      'energy_observed': energyObserved ? 1 : 0,
      'pain_observed': painObserved ? 1 : 0,
    };
  }

  test('unobserved current metric fails closed', () {
    final insight = TrackingPatternInsightService.analyze(
      metric: TrackingInsightMetric.mood,
      currentValue: 3,
      currentObserved: false,
      history: const <Map<String, dynamic>>[],
    );

    expect(insight.historyBacked, isFalse);
    expect(insight.text, contains('Record your mood'));
    expect(insight.text, isNot(contains('hormone')));
  });

  test('insufficient history states what is actually available', () {
    final insight = TrackingPatternInsightService.analyze(
      metric: TrackingInsightMetric.energy,
      currentValue: 4,
      currentObserved: true,
      history: <Map<String, dynamic>>[
        row(energy: 2, energyObserved: true),
        row(energy: 3, energyObserved: true),
      ],
    );

    expect(insight.historyBacked, isFalse);
    expect(insight.historicalCount, 2);
    expect(insight.basis, '2 prior recorded energy days');
  });

  test('history-backed mood compares only observed records', () {
    final insight = TrackingPatternInsightService.analyze(
      metric: TrackingInsightMetric.mood,
      currentValue: 5,
      currentObserved: true,
      history: <Map<String, dynamic>>[
        row(mood: 1, moodObserved: false),
        row(mood: 2, moodObserved: true),
        row(mood: 3, moodObserved: true),
        row(mood: 3, moodObserved: true),
      ],
    );

    expect(insight.historyBacked, isTrue);
    expect(insight.historicalCount, 3);
    expect(insight.text, contains('higher than'));
    expect(insight.text, contains('2.7/5'));
  });

  test('pain insight uses recorded pain history without causal claims', () {
    final insight = TrackingPatternInsightService.analyze(
      metric: TrackingInsightMetric.pain,
      currentValue: 4,
      currentObserved: true,
      history: <Map<String, dynamic>>[
        row(pain: 1, painObserved: true),
        row(pain: 2, painObserved: true),
        row(pain: 2, painObserved: true),
      ],
    );

    expect(insight.text, contains("Today's pain is higher than"));
    expect(insight.text, isNot(contains('hormone')));
    expect(insight.text, isNot(contains('cycle phase')));
  });

  test('paired mood and energy may describe strong recorded relationship', () {
    final history = <Map<String, dynamic>>[
      row(mood: 1, energy: 1, moodObserved: true, energyObserved: true),
      row(mood: 2, energy: 2, moodObserved: true, energyObserved: true),
      row(mood: 3, energy: 3, moodObserved: true, energyObserved: true),
      row(mood: 4, energy: 4, moodObserved: true, energyObserved: true),
      row(mood: 5, energy: 5, moodObserved: true, energyObserved: true),
    ];

    final insight = TrackingPatternInsightService.analyze(
      metric: TrackingInsightMetric.mood,
      currentValue: 4,
      currentObserved: true,
      history: history,
    );

    expect(insight.text, contains('mood and energy tended to move together'));
    expect(insight.text, contains('5 days'));
  });

  test('production widget contains no unsupported psychology copy', () {
    final source = File(
      'lib/features/cycle/widgets/mood_energy_slider.dart',
    ).readAsStringSync();

    expect(source, contains('Personal Pattern Insight'));
    expect(source, contains('widget.insight.text'));
    expect(source, contains('widget.insight.basis'));

    for (final forbidden in <String>[
      'AI Psychology Insights',
      'Your hormones may be supporting emotional stability',
      'maintaining good hormonal balance',
      'optimal phase for productivity',
      'Moderate fatigue detected',
      '_getPsychologyInsight',
    ]) {
      expect(
        source,
        isNot(contains(forbidden)),
        reason:
            'Track insight UI must not contain unsupported claim: $forbidden',
      );
    }
  });
}
