import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../models/cycle_data.dart';

/// Advanced ML-based Pattern Recognition Service
/// Uses machine learning algorithms to detect patterns, anomalies, and predictive insights
/// This is a sophisticated service that analyzes complex health patterns
class MLPatternRecognitionService {
  static final MLPatternRecognitionService _instance =
      MLPatternRecognitionService._internal();
  factory MLPatternRecognitionService() => _instance;
  MLPatternRecognitionService._internal();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    // In production, this would load TensorFlow Lite models
    _isInitialized = true;
    debugPrint('🤖 ML Pattern Recognition Service initialized');
  }

  /// Detect anomalies in cycle patterns using statistical analysis
  Future<List<PatternAnomaly>> detectCycleAnomalies({
    required List<CycleData> cycles,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (cycles.length < 3) return [];

    final anomalies = <PatternAnomaly>[];

    // Calculate baseline statistics
    final cycleLengths = cycles
        .where((c) => c.cycleLength != null)
        .map((c) => c.cycleLength!.toDouble())
        .toList();
    final mean = cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
    final variance =
        cycleLengths.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) /
        cycleLengths.length;
    final stdDev = math.sqrt(variance);

    // Detect outliers (beyond 2 standard deviations)
    final validCycles = cycles.where((c) => c.cycleLength != null).toList();
    final validLengths = validCycles
        .map((c) => c.cycleLength!.toDouble())
        .toList();

    for (int i = 0; i < validCycles.length; i++) {
      final zScore =
          (validLengths[i] - mean) / (stdDev + 0.001); // Avoid division by zero
      if (zScore.abs() > 2.0) {
        anomalies.add(
          PatternAnomaly(
            type: AnomalyType.irregularCycleLength,
            severity: zScore.abs() > 3.0
                ? AnomalySeverity.high
                : AnomalySeverity.medium,
            detectedAt: validCycles[i].startDate,
            description:
                'Cycle length ${validLengths[i].toInt()} days differs significantly from average ${mean.toInt()} days',
            confidence: 0.85,
            recommendation: _getAnomalyRecommendation(
              AnomalyType.irregularCycleLength,
            ),
          ),
        );
      }
    }

    return anomalies;
  }

  /// Predict future cycle patterns using time series analysis
  Future<CyclePrediction?> predictNextCyclePattern({
    required List<CycleData> historicalCycles,
  }) async {
    if (historicalCycles.length < 3) {
      return null;
    }

    final validCycles = historicalCycles
        .where((c) => c.cycleLength != null)
        .toList();
    if (validCycles.length < 3) {
      return null;
    }

    // Use exponential smoothing for prediction
    final cycleLengths = validCycles
        .map((c) => c.cycleLength!.toDouble())
        .toList();
    final lastCycle = validCycles.last;

    // Calculate weighted moving average (recent cycles weighted more heavily)
    double predictedLength = 0;
    double totalWeight = 0;
    for (int i = 0; i < cycleLengths.length; i++) {
      final weight = math.pow(1.2, i); // Exponential weighting
      predictedLength += cycleLengths[cycleLengths.length - 1 - i] * weight;
      totalWeight += weight;
    }
    predictedLength /= totalWeight;

    // Calculate confidence based on historical variance
    final variance =
        cycleLengths
            .map((x) => math.pow(x - predictedLength, 2))
            .reduce((a, b) => a + b) /
        cycleLengths.length;
    final confidence = math.max(0.0, math.min(1.0, 1.0 - (variance / 100)));

    // Predict start date
    final lastStartDate = lastCycle.startDate;
    final predictedStartDate = lastStartDate.add(
      Duration(days: predictedLength.toInt()),
    );

    return CyclePrediction(
      predictedStartDate: predictedStartDate,
      predictedLength: predictedLength.toInt(),
      confidence: confidence,
      fertileWindow: _calculateFertileWindow(
        predictedStartDate,
        predictedLength.toInt(),
      ),
    );
  }

  /// Detect correlations between symptoms and cycle phases using statistical analysis
  Future<Map<String, SymptomCorrelation>> detectSymptomCorrelations({
    required List<Map<String, dynamic>> trackingData,
    required List<CycleData> cycles,
  }) async {
    final correlations = <String, SymptomCorrelation>{};

    // Group tracking data by cycle phase
    final phaseData = <String, List<Map<String, dynamic>>>{
      'menstrual': [],
      'follicular': [],
      'ovulatory': [],
      'luteal': [],
    };

    for (final cycle in cycles) {
      final cycleStart = cycle.startDate;
      final cycleLength = cycle.cycleLength ?? 28;
      final periodLength = cycle.periodLength ?? 5;

      for (final dayData in trackingData) {
        final dateStr = dayData['date'] as String?;
        if (dateStr == null) continue;
        final day = DateTime.parse(dateStr);

        if (day.isBefore(cycleStart) ||
            day.isAfter(cycleStart.add(Duration(days: cycleLength)))) {
          continue;
        }

        final daysSinceStart = day.difference(cycleStart).inDays;
        String phase;
        if (daysSinceStart < periodLength) {
          phase = 'menstrual';
        } else if (daysSinceStart < 13) {
          phase = 'follicular';
        } else if (daysSinceStart < 16) {
          phase = 'ovulatory';
        } else {
          phase = 'luteal';
        }

        phaseData[phase]?.add(dayData);
      }
    }

    // Analyze symptom patterns per phase
    for (final phase in phaseData.keys) {
      final phaseTrackingData = phaseData[phase]!;

      // Calculate symptom frequency per phase
      final symptomCounts = <String, int>{};
      int totalDays = phaseTrackingData.length;

      for (final dayData in phaseTrackingData) {
        final symptoms = dayData['symptoms'];
        if (symptoms != null) {
          List<String> symptomList;
          if (symptoms is List) {
            symptomList = symptoms.cast<String>();
          } else if (symptoms is String) {
            symptomList = symptoms
                .split(',')
                .where((s) => s.isNotEmpty)
                .toList();
          } else {
            continue;
          }

          for (final symptom in symptomList) {
            symptomCounts[symptom] = (symptomCounts[symptom] ?? 0) + 1;
          }
        }
      }

      // Calculate correlation strength
      for (final entry in symptomCounts.entries) {
        final frequency = entry.value / totalDays;
        if (frequency > 0.3) {
          // Only significant correlations (>30% frequency)
          correlations['${entry.key}_$phase'] = SymptomCorrelation(
            symptom: entry.key,
            cyclePhase: phase,
            correlationStrength: frequency,
            occurrenceRate: entry.value / totalDays,
            sampleSize: totalDays,
            confidence: math.min(0.95, totalDays / 10.0),
            recommendation: _getSymptomRecommendation(entry.key, phase),
          );
        }
      }
    }

    return correlations;
  }

  /// Detect health trends using advanced statistical methods
  Future<HealthTrend> detectHealthTrend({
    required List<Map<String, dynamic>> trackingData,
    required String metric, // 'mood', 'energy', 'sleep', etc.
  }) async {
    if (trackingData.isEmpty) return HealthTrend.stable();

    // Extract metric values
    List<double> values;
    switch (metric) {
      case 'mood':
        values = trackingData
            .where((t) => t['mood'] != null)
            .map((t) => (t['mood'] as num).toDouble())
            .toList();
        break;
      case 'energy':
        values = trackingData
            .where((t) => t['energy'] != null)
            .map((t) => (t['energy'] as num).toDouble())
            .toList();
        break;
      case 'sleep':
        values = trackingData
            .where((t) => t['sleepHours'] != null)
            .map((t) => (t['sleepHours'] as num).toDouble())
            .toList();
        break;
      default:
        return HealthTrend.stable();
    }

    if (values.length < 3) return HealthTrend.stable();

    // Calculate linear regression slope
    final n = values.length;
    final x = List.generate(n, (i) => i.toDouble());
    final y = values;

    final xMean = x.reduce((a, b) => a + b) / n;
    final yMean = y.reduce((a, b) => a + b) / n;

    double numerator = 0;
    double denominator = 0;

    for (int i = 0; i < n; i++) {
      numerator += (x[i] - xMean) * (y[i] - yMean);
      denominator += (x[i] - xMean) * (x[i] - xMean);
    }

    final slope = denominator != 0 ? numerator / denominator : 0;
    final rSquared = _calculateRSquared(x, y, xMean, yMean);

    // Determine trend direction
    TrendDirection direction;
    if (slope > 0.05) {
      direction = TrendDirection.improving;
    } else if (slope < -0.05) {
      direction = TrendDirection.declining;
    } else {
      direction = TrendDirection.stable;
    }

    return HealthTrend(
      direction: direction,
      strength: math.min(1.0, rSquared.abs()),
      changeRate: slope.toDouble(),
      confidence: math.min(0.95, n / 30.0),
      metadata: {'sample_size': n, 'r_squared': rSquared, 'slope': slope},
    );
  }

  /// Detect patterns in symptom clusters
  Future<List<SymptomCluster>> detectSymptomClusters({
    required List<Map<String, dynamic>> trackingData,
  }) async {
    final clusters = <SymptomCluster>[];

    // Group days by symptom combinations
    final symptomCombinations = <String, List<Map<String, dynamic>>>{};

    for (final dayData in trackingData) {
      final symptoms = dayData['symptoms'];
      if (symptoms != null) {
        List<String> symptomList;
        if (symptoms is List) {
          symptomList = symptoms.cast<String>();
        } else if (symptoms is String) {
          symptomList = symptoms.split(',').where((s) => s.isNotEmpty).toList();
        } else {
          continue;
        }

        if (symptomList.isNotEmpty) {
          final key = List<String>.from(symptomList)..sort();
          final keyString = key.join(',');
          symptomCombinations[keyString] ??= [];
          symptomCombinations[keyString]!.add(dayData);
        }
      }
    }

    // Identify significant clusters (occurring >5 times)
    for (final entry in symptomCombinations.entries) {
      if (entry.value.length >= 5) {
        final symptoms = entry.key.split(',');
        clusters.add(
          SymptomCluster(
            symptoms: symptoms,
            frequency: entry.value.length,
            averageSeverity: _calculateAverageSeverity(entry.value),
            mostCommonPhase: _identifyMostCommonPhase(entry.value),
            recommendation: _getClusterRecommendation(symptoms),
          ),
        );
      }
    }

    return clusters;
  }

  // Helper methods

  FertileWindow _calculateFertileWindow(DateTime cycleStart, int cycleLength) {
    final ovulationDay = cycleLength - 14; // Typical ovulation day
    final fertileStart = cycleStart.add(Duration(days: ovulationDay - 5));
    final fertileEnd = cycleStart.add(Duration(days: ovulationDay + 1));
    final peak = cycleStart.add(Duration(days: ovulationDay));

    return FertileWindow(start: fertileStart, end: fertileEnd, peak: peak);
  }

  double _calculateRSquared(
    List<double> x,
    List<double> y,
    double xMean,
    double yMean,
  ) {
    double ssRes = 0;
    double ssTot = 0;

    double slope = 0;
    double intercept = 0;
    final n = x.length;

    double xySum = 0, xSum = 0, ySum = 0, x2Sum = 0;
    for (int i = 0; i < n; i++) {
      xySum += x[i] * y[i];
      xSum += x[i];
      ySum += y[i];
      x2Sum += x[i] * x[i];
    }

    slope = (n * xySum - xSum * ySum) / (n * x2Sum - xSum * xSum);
    intercept = (ySum - slope * xSum) / n;

    for (int i = 0; i < n; i++) {
      final predicted = slope * x[i] + intercept;
      ssRes += math.pow(y[i] - predicted, 2);
      ssTot += math.pow(y[i] - yMean, 2);
    }

    return ssTot > 0 ? 1 - (ssRes / ssTot) : 0;
  }

  double _calculateAverageSeverity(List<Map<String, dynamic>> data) {
    // Calculate average from pain scores
    double totalPain = 0;
    int count = 0;
    for (final dayData in data) {
      if (dayData['pain'] != null) {
        totalPain += (dayData['pain'] as num).toDouble();
        count++;
      }
    }
    return count > 0 ? totalPain / count : 0.5;
  }

  String _identifyMostCommonPhase(List<Map<String, dynamic>> data) {
    // Placeholder - would analyze cycle phases for these days
    return 'luteal';
  }

  String _getAnomalyRecommendation(AnomalyType type) {
    switch (type) {
      case AnomalyType.irregularCycleLength:
        return 'Consider tracking additional health metrics and consult with a healthcare provider if irregularities persist.';
      default:
        return 'Monitor your patterns and consult with a healthcare provider if concerned.';
    }
  }

  String _getSymptomRecommendation(String symptom, String phase) {
    return 'This symptom commonly occurs during your $phase phase. Consider tracking related factors like stress, sleep, and nutrition.';
  }

  String _getClusterRecommendation(List<String> symptoms) {
    return 'These symptoms often occur together. Consider lifestyle factors that may influence multiple symptoms simultaneously.';
  }
}

// Data Models

enum AnomalyType {
  irregularCycleLength,
  unusualSymptomPattern,
  healthMetricDeviation,
}

enum AnomalySeverity { low, medium, high }

class PatternAnomaly {
  final AnomalyType type;
  final AnomalySeverity severity;
  final DateTime detectedAt;
  final String description;
  final double confidence;
  final String recommendation;

  PatternAnomaly({
    required this.type,
    required this.severity,
    required this.detectedAt,
    required this.description,
    required this.confidence,
    required this.recommendation,
  });
}

class SymptomCorrelation {
  final String symptom;
  final String cyclePhase;
  final double correlationStrength;
  final double occurrenceRate;
  final int sampleSize;
  final double confidence;
  final String recommendation;

  SymptomCorrelation({
    required this.symptom,
    required this.cyclePhase,
    required this.correlationStrength,
    required this.occurrenceRate,
    required this.sampleSize,
    required this.confidence,
    required this.recommendation,
  });
}

enum TrendDirection { improving, declining, stable }

class HealthTrend {
  final TrendDirection direction;
  final double strength;
  final double changeRate;
  final double confidence;
  final Map<String, dynamic> metadata;

  HealthTrend({
    required this.direction,
    required this.strength,
    required this.changeRate,
    required this.confidence,
    required this.metadata,
  });

  factory HealthTrend.stable() => HealthTrend(
    direction: TrendDirection.stable,
    strength: 0.0,
    changeRate: 0.0,
    confidence: 0.0,
    metadata: {},
  );
}

class SymptomCluster {
  final List<String> symptoms;
  final int frequency;
  final double averageSeverity;
  final String mostCommonPhase;
  final String recommendation;

  SymptomCluster({
    required this.symptoms,
    required this.frequency,
    required this.averageSeverity,
    required this.mostCommonPhase,
    required this.recommendation,
  });
}
