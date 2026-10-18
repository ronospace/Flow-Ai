import 'dart:math' as math;

import '../../../core/database/database_service.dart';

enum TrackingInsightMetric { mood, energy, pain }

final class TrackingPatternInsight {
  const TrackingPatternInsight({
    required this.text,
    required this.basis,
    required this.historicalCount,
    required this.historyBacked,
  });

  final String text;
  final String basis;
  final int historicalCount;
  final bool historyBacked;
}

final class TrackingPatternInsightService {
  TrackingPatternInsightService({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService();

  final DatabaseService _databaseService;

  Future<List<Map<String, dynamic>>> loadPriorHistory(
    DateTime selectedDate, {
    int lookbackDays = 30,
  }) async {
    final day = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final end = day.subtract(const Duration(days: 1));
    final start = day.subtract(Duration(days: lookbackDays));

    try {
      return await _databaseService.getDailyTrackingRange(start, end);
    } catch (_) {
      return const <Map<String, dynamic>>[];
    }
  }

  static TrackingPatternInsight analyze({
    required TrackingInsightMetric metric,
    required double currentValue,
    required bool currentObserved,
    required List<Map<String, dynamic>> history,
  }) {
    final label = _label(metric);

    if (!currentObserved) {
      return TrackingPatternInsight(
        text: 'Record your $label to start building a personal pattern.',
        basis: 'No recorded $label for this day',
        historicalCount: 0,
        historyBacked: false,
      );
    }

    final values = <double>[];

    for (final row in history) {
      if (!_isObserved(row, metric)) continue;

      final value = _asDouble(row[_valueKey(metric)]);
      if (value == null || value < 1 || value > 5) continue;

      values.add(value);
    }

    if (values.length < 3) {
      final count = values.length;
      final dayWord = count == 1 ? 'day' : 'days';

      return TrackingPatternInsight(
        text:
            'You recorded $label at ${currentValue.toStringAsFixed(0)}/5 today. '
            'Keep tracking to compare it with your own history.',
        basis: '$count prior recorded $label $dayWord',
        historicalCount: count,
        historyBacked: false,
      );
    }

    final average = values.reduce((a, b) => a + b) / values.length;
    final difference = currentValue - average;

    final comparison = switch (metric) {
      TrackingInsightMetric.pain => _painComparison(difference),
      TrackingInsightMetric.mood ||
      TrackingInsightMetric.energy => _positiveComparison(difference),
    };

    final buffer = StringBuffer(
      'Today\'s $label is $comparison your recent recorded average '
      '(${average.toStringAsFixed(1)}/5).',
    );

    if (values.length >= 6) {
      final recent = values.sublist(values.length - 3);
      final previous = values.sublist(values.length - 6, values.length - 3);

      final recentAverage = recent.reduce((a, b) => a + b) / recent.length;
      final previousAverage =
          previous.reduce((a, b) => a + b) / previous.length;
      final trendDifference = recentAverage - previousAverage;

      if (trendDifference.abs() >= 0.5) {
        final direction = trendDifference > 0 ? 'higher' : 'lower';
        buffer.write(
          ' Your last three recorded $label values were $direction '
          'than the preceding three.',
        );
      }
    }

    if (metric == TrackingInsightMetric.mood ||
        metric == TrackingInsightMetric.energy) {
      final paired = _pairedMoodEnergy(history);

      if (paired.length >= 5) {
        final correlation = _correlation(
          paired.map((pair) => pair.$1).toList(growable: false),
          paired.map((pair) => pair.$2).toList(growable: false),
        );

        if (correlation != null && correlation.abs() >= 0.6) {
          final relationship = correlation > 0
              ? 'tended to move together'
              : 'tended to move in opposite directions';

          buffer.write(
            ' Across ${paired.length} days where both were recorded, '
            'mood and energy $relationship.',
          );
        }
      }
    }

    return TrackingPatternInsight(
      text: buffer.toString(),
      basis: 'Based on ${values.length} prior recorded $label days',
      historicalCount: values.length,
      historyBacked: true,
    );
  }

  static String _label(TrackingInsightMetric metric) => switch (metric) {
    TrackingInsightMetric.mood => 'mood',
    TrackingInsightMetric.energy => 'energy',
    TrackingInsightMetric.pain => 'pain',
  };

  static String _valueKey(TrackingInsightMetric metric) => switch (metric) {
    TrackingInsightMetric.mood => 'mood',
    TrackingInsightMetric.energy => 'energy',
    TrackingInsightMetric.pain => 'pain',
  };

  static String _observedKey(TrackingInsightMetric metric) => switch (metric) {
    TrackingInsightMetric.mood => 'mood_observed',
    TrackingInsightMetric.energy => 'energy_observed',
    TrackingInsightMetric.pain => 'pain_observed',
  };

  static bool _isObserved(
    Map<String, dynamic> row,
    TrackingInsightMetric metric,
  ) {
    final raw = row[_observedKey(metric)];
    return raw == 1 || raw == true;
  }

  static double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  static String _positiveComparison(double difference) {
    if (difference >= 0.5) return 'higher than';
    if (difference <= -0.5) return 'lower than';
    return 'close to';
  }

  static String _painComparison(double difference) {
    if (difference >= 0.5) return 'higher than';
    if (difference <= -0.5) return 'lower than';
    return 'close to';
  }

  static List<(double, double)> _pairedMoodEnergy(
    List<Map<String, dynamic>> history,
  ) {
    final paired = <(double, double)>[];

    for (final row in history) {
      final moodObserved =
          row['mood_observed'] == 1 || row['mood_observed'] == true;
      final energyObserved =
          row['energy_observed'] == 1 || row['energy_observed'] == true;

      if (!moodObserved || !energyObserved) continue;

      final mood = _asDouble(row['mood']);
      final energy = _asDouble(row['energy']);

      if (mood == null ||
          energy == null ||
          mood < 1 ||
          mood > 5 ||
          energy < 1 ||
          energy > 5) {
        continue;
      }

      paired.add((mood, energy));
    }

    return paired;
  }

  static double? _correlation(List<double> x, List<double> y) {
    if (x.length != y.length || x.length < 2) return null;

    final meanX = x.reduce((a, b) => a + b) / x.length;
    final meanY = y.reduce((a, b) => a + b) / y.length;

    var numerator = 0.0;
    var sumSquareX = 0.0;
    var sumSquareY = 0.0;

    for (var i = 0; i < x.length; i++) {
      final dx = x[i] - meanX;
      final dy = y[i] - meanY;
      numerator += dx * dy;
      sumSquareX += dx * dx;
      sumSquareY += dy * dy;
    }

    final denominator = math.sqrt(sumSquareX * sumSquareY);
    if (denominator == 0) return null;

    return numerator / denominator;
  }
}
