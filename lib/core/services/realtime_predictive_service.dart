import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../models/cycle_data.dart';
import '../database/database_service.dart';
import 'ml_pattern_recognition_service.dart'
    show MLPatternRecognitionService, AnomalyType, SymptomCorrelation;

/// Real-time Predictive Analytics Service
/// Provides live predictions, alerts, and proactive insights
/// Uses ML models to generate real-time forecasts and recommendations
class RealtimePredictiveService {
  static final RealtimePredictiveService _instance =
      RealtimePredictiveService._internal();
  factory RealtimePredictiveService() => _instance;
  RealtimePredictiveService._internal();

  final DatabaseService _databaseService = DatabaseService();
  final MLPatternRecognitionService _mlService = MLPatternRecognitionService();
  Timer? _predictionUpdateTimer;
  final Map<String, StreamController<PredictionUpdate>> _predictionStreams = {};

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _mlService.initialize();

    // Start periodic prediction updates (every 6 hours)
    _predictionUpdateTimer = Timer.periodic(
      const Duration(hours: 6),
      (_) => _updateAllPredictions(),
    );

    _isInitialized = true;
    debugPrint('⚡ Real-time Predictive Service initialized');
  }

  /// Get real-time prediction stream for a specific metric
  Stream<PredictionUpdate> getPredictionStream(String metric) {
    _predictionStreams[metric] ??=
        StreamController<PredictionUpdate>.broadcast();

    // Generate initial prediction
    _generatePredictionForMetric(metric).then((prediction) {
      _predictionStreams[metric]?.add(prediction);
    });

    return _predictionStreams[metric]!.stream;
  }

  /// Get next period prediction with real-time confidence updates
  Future<NextPeriodPrediction> predictNextPeriod() async {
    final cycles = await _databaseService.getCyclesInRange(
      DateTime.now().subtract(const Duration(days: 365)),
      DateTime.now(),
    );

    if (cycles.isEmpty) {
      return NextPeriodPrediction.empty();
    }

    final prediction = await _mlService.predictNextCyclePattern(
      historicalCycles: cycles,
    );

    if (prediction == null || cycles.isEmpty) {
      return NextPeriodPrediction.empty();
    }

    return NextPeriodPrediction(
      predictedDate: prediction.predictedStartDate,
      confidence: prediction.confidence,
      confidenceRange: _calculateConfidenceRange(
        prediction.confidence,
        prediction.predictedLength,
      ),
      factors: _analyzePredictionFactors(cycles),
      recommendations: _generatePeriodRecommendations(cycles.last),
      updatedAt: DateTime.now(),
    );
  }

  /// Get health risk assessment based on patterns
  Future<HealthRiskAssessment> assessHealthRisks() async {
    final cycles = await _databaseService.getCyclesInRange(
      DateTime.now().subtract(const Duration(days: 365)),
      DateTime.now(),
    );

    final trackingData = await _databaseService.getTrackingDataInRange(
      DateTime.now().subtract(const Duration(days: 90)),
      DateTime.now(),
    );

    final anomalies = await _mlService.detectCycleAnomalies(cycles: cycles);
    final symptomClusters = await _mlService.detectSymptomClusters(
      trackingData: trackingData,
    );

    final risks = <HealthRisk>[];

    // Assess cycle regularity risk
    if (anomalies
        .where((a) => a.type == AnomalyType.irregularCycleLength)
        .isNotEmpty) {
      risks.add(
        HealthRisk(
          type: RiskType.irregularCycles,
          severity: RiskSeverity.medium,
          description: 'Multiple irregular cycle lengths detected',
          recommendation:
              'Consider consulting a healthcare provider about cycle irregularities',
          detectedAt: DateTime.now(),
        ),
      );
    }

    // Assess symptom pattern risks
    if (symptomClusters.isNotEmpty) {
      for (final cluster in symptomClusters) {
        if (cluster.frequency > 10 && cluster.averageSeverity > 0.7) {
          risks.add(
            HealthRisk(
              type: RiskType.symptomPattern,
              severity: RiskSeverity.low,
              description:
                  'Frequent symptom cluster detected: ${cluster.symptoms.join(", ")}',
              recommendation: cluster.recommendation,
              detectedAt: DateTime.now(),
            ),
          );
        }
      }
    }

    return HealthRiskAssessment(
      risks: risks,
      overallRiskLevel: _calculateOverallRisk(risks),
      lastAssessed: DateTime.now(),
      recommendations: _generateRiskRecommendations(risks),
    );
  }

  /// Get proactive recommendations based on cycle phase and patterns
  Future<List<ProactiveRecommendation>> getProactiveRecommendations() async {
    final recommendations = <ProactiveRecommendation>[];

    final cycles = await _databaseService.getCyclesInRange(
      DateTime.now().subtract(const Duration(days: 90)),
      DateTime.now(),
    );

    if (cycles.isEmpty) return recommendations;

    final lastCycle = cycles.last;
    final daysSinceStart = DateTime.now()
        .difference(lastCycle.startDate)
        .inDays;
    final cycleLength = lastCycle.cycleLength ?? 28;
    final cyclePhase = _identifyCurrentPhase(daysSinceStart, cycleLength);

    // Phase-specific recommendations
    recommendations.addAll(
      _getPhaseRecommendations(cyclePhase, daysSinceStart),
    );

    // Pattern-based recommendations
    final trackingData = await _databaseService.getTrackingDataInRange(
      DateTime.now().subtract(const Duration(days: 30)),
      DateTime.now(),
    );

    final correlations = await _mlService.detectSymptomCorrelations(
      trackingData: trackingData,
      cycles: cycles,
    );

    recommendations.addAll(
      _getPatternBasedRecommendations(correlations, cyclePhase),
    );

    return recommendations;
  }

  /// Get predictive insights for upcoming days
  Future<List<PredictiveInsight>> getUpcomingInsights({
    int daysAhead = 7,
  }) async {
    final insights = <PredictiveInsight>[];

    final cycles = await _databaseService.getCyclesInRange(
      DateTime.now().subtract(const Duration(days: 365)),
      DateTime.now(),
    );

    if (cycles.isEmpty) return insights;

    final prediction = await predictNextPeriod();
    final today = DateTime.now();

    for (int i = 1; i <= daysAhead; i++) {
      final futureDate = today.add(Duration(days: i));

      // Check if period is predicted
      if (prediction.predictedDate.difference(futureDate).inDays.abs() <= 2) {
        insights.add(
          PredictiveInsight(
            date: futureDate,
            type: InsightType.periodPrediction,
            confidence: prediction.confidence,
            message: 'Period is likely to start around this date',
            actionable: true,
            action: 'Prepare accordingly and track your symptoms',
          ),
        );
      }

      // Predict symptoms based on phase
      final phase = _predictPhaseForDate(futureDate, cycles.last);
      if (phase != null) {
        insights.add(
          PredictiveInsight(
            date: futureDate,
            type: InsightType.phaseBased,
            confidence: 0.75,
            message: 'You\'ll likely be in your $phase phase',
            actionable: true,
            action: _getPhaseAction(phase),
          ),
        );
      }
    }

    return insights;
  }

  // Private helper methods

  Future<void> _updateAllPredictions() async {
    debugPrint('🔄 Updating all real-time predictions...');

    final metrics = ['next_period', 'symptoms', 'mood', 'energy'];
    for (final metric in metrics) {
      if (_predictionStreams.containsKey(metric)) {
        final prediction = await _generatePredictionForMetric(metric);
        _predictionStreams[metric]?.add(prediction);
      }
    }
  }

  Future<PredictionUpdate> _generatePredictionForMetric(String metric) async {
    switch (metric) {
      case 'next_period':
        final prediction = await predictNextPeriod();
        return PredictionUpdate(
          metric: metric,
          value: prediction.predictedDate.toIso8601String(),
          confidence: prediction.confidence,
          updatedAt: DateTime.now(),
        );
      default:
        return PredictionUpdate(
          metric: metric,
          value: '0',
          confidence: 0.0,
          updatedAt: DateTime.now(),
        );
    }
  }

  Duration _calculateConfidenceRange(double confidence, int predictedLength) {
    // Higher confidence = tighter range
    final baseRange = (predictedLength * 0.15).round(); // 15% of cycle length
    final adjustedRange = (baseRange * (1 - confidence)).round();
    return Duration(days: math.max(1, adjustedRange));
  }

  List<String> _analyzePredictionFactors(List<CycleData> cycles) {
    final factors = <String>[];

    if (cycles.length >= 3) {
      factors.add('${cycles.length} historical cycles analyzed');
    }

    // Check regularity
    final lengths = cycles.map((c) => c.length).toList();
    final mean = lengths.reduce((a, b) => a + b) / lengths.length;
    final variance =
        lengths.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) /
        lengths.length;

    if (variance < 5) {
      factors.add('Highly regular cycle pattern');
    } else {
      factors.add('Variable cycle pattern');
    }

    return factors;
  }

  List<String> _generatePeriodRecommendations(CycleData lastCycle) {
    final daysSinceStart = DateTime.now()
        .difference(lastCycle.startDate)
        .inDays;

    if (daysSinceStart >= 25) {
      return [
        'Period may start soon - consider carrying period products',
        'Track symptoms to improve prediction accuracy',
      ];
    } else {
      return ['Continue tracking your cycle for better predictions'];
    }
  }

  RiskLevel _calculateOverallRisk(List<HealthRisk> risks) {
    if (risks.any((r) => r.severity == RiskSeverity.high)) {
      return RiskLevel.high;
    } else if (risks.any((r) => r.severity == RiskSeverity.medium)) {
      return RiskLevel.medium;
    } else if (risks.isNotEmpty) {
      return RiskLevel.low;
    }
    return RiskLevel.none;
  }

  List<String> _generateRiskRecommendations(List<HealthRisk> risks) {
    if (risks.isEmpty) {
      return [
        'No significant health risks detected. Continue regular tracking.',
      ];
    }

    return risks.map((r) => r.recommendation).toList();
  }

  String _identifyCurrentPhase(int daysSinceStart, int cycleLength) {
    if (daysSinceStart < 5) return 'menstrual';
    if (daysSinceStart < 13) return 'follicular';
    if (daysSinceStart < 16) return 'ovulatory';
    return 'luteal';
  }

  List<ProactiveRecommendation> _getPhaseRecommendations(
    String phase,
    int daysSinceStart,
  ) {
    final recommendations = <ProactiveRecommendation>[];

    switch (phase) {
      case 'menstrual':
        recommendations.add(
          ProactiveRecommendation(
            title: 'Focus on Rest',
            description: 'Your body needs extra rest during menstruation',
            priority: RecommendationPriority.high,
            category: RecommendationCategory.lifestyle,
            actionableSteps: [
              'Get 8+ hours of sleep',
              'Consider gentle exercises',
              'Stay hydrated',
            ],
          ),
        );
        break;
      case 'ovulatory':
        recommendations.add(
          ProactiveRecommendation(
            title: 'Peak Energy Days',
            description: 'You typically have higher energy during ovulation',
            priority: RecommendationPriority.medium,
            category: RecommendationCategory.lifestyle,
            actionableSteps: [
              'Plan important activities',
              'Engage in moderate exercise',
              'Social activities',
            ],
          ),
        );
        break;
      case 'luteal':
        recommendations.add(
          ProactiveRecommendation(
            title: 'PMS Prevention',
            description: 'Focus on managing potential PMS symptoms',
            priority: RecommendationPriority.high,
            category: RecommendationCategory.health,
            actionableSteps: [
              'Monitor mood changes',
              'Maintain consistent sleep',
              'Consider magnesium supplements',
            ],
          ),
        );
        break;
    }

    return recommendations;
  }

  List<ProactiveRecommendation> _getPatternBasedRecommendations(
    Map<String, SymptomCorrelation> correlations,
    String currentPhase,
  ) {
    final recommendations = <ProactiveRecommendation>[];

    for (final correlation in correlations.values) {
      if (correlation.cyclePhase == currentPhase &&
          correlation.correlationStrength > 0.5) {
        recommendations.add(
          ProactiveRecommendation(
            title: 'Symptom Pattern Detected',
            description:
                '${correlation.symptom} commonly occurs during your $currentPhase phase',
            priority: RecommendationPriority.medium,
            category: RecommendationCategory.health,
            actionableSteps: [correlation.recommendation],
          ),
        );
      }
    }

    return recommendations;
  }

  String? _predictPhaseForDate(DateTime date, CycleData lastCycle) {
    final daysSinceStart = date.difference(lastCycle.startDate).inDays;
    final cycleLength = lastCycle.cycleLength ?? 28;
    if (daysSinceStart < 0 || daysSinceStart > cycleLength) {
      return null;
    }

    return _identifyCurrentPhase(daysSinceStart, cycleLength);
  }

  String _getPhaseAction(String phase) {
    switch (phase) {
      case 'menstrual':
        return 'Prepare for period-related needs';
      case 'ovulatory':
        return 'Take advantage of peak energy';
      case 'luteal':
        return 'Be mindful of potential PMS symptoms';
      default:
        return 'Continue regular tracking';
    }
  }

  void dispose() {
    _predictionUpdateTimer?.cancel();
    for (final stream in _predictionStreams.values) {
      stream.close();
    }
    _predictionStreams.clear();
    _isInitialized = false;
  }
}

// Data Models

class PredictionUpdate {
  final String metric;
  final String value;
  final double confidence;
  final DateTime updatedAt;

  PredictionUpdate({
    required this.metric,
    required this.value,
    required this.confidence,
    required this.updatedAt,
  });
}

class NextPeriodPrediction {
  final DateTime predictedDate;
  final double confidence;
  final Duration confidenceRange;
  final List<String> factors;
  final List<String> recommendations;
  final DateTime updatedAt;

  NextPeriodPrediction({
    required this.predictedDate,
    required this.confidence,
    required this.confidenceRange,
    required this.factors,
    required this.recommendations,
    required this.updatedAt,
  });

  factory NextPeriodPrediction.empty() => NextPeriodPrediction(
    predictedDate: DateTime.now().add(const Duration(days: 28)),
    confidence: 0.0,
    confidenceRange: const Duration(days: 7),
    factors: [],
    recommendations: [],
    updatedAt: DateTime.now(),
  );
}

enum RiskType { irregularCycles, symptomPattern, healthMetricDeviation }

enum RiskSeverity { low, medium, high }

class HealthRisk {
  final RiskType type;
  final RiskSeverity severity;
  final String description;
  final String recommendation;
  final DateTime detectedAt;

  HealthRisk({
    required this.type,
    required this.severity,
    required this.description,
    required this.recommendation,
    required this.detectedAt,
  });
}

enum RiskLevel { none, low, medium, high }

class HealthRiskAssessment {
  final List<HealthRisk> risks;
  final RiskLevel overallRiskLevel;
  final DateTime lastAssessed;
  final List<String> recommendations;

  HealthRiskAssessment({
    required this.risks,
    required this.overallRiskLevel,
    required this.lastAssessed,
    required this.recommendations,
  });
}

enum RecommendationCategory { health, lifestyle, nutrition, exercise }

enum RecommendationPriority { low, medium, high }

class ProactiveRecommendation {
  final String title;
  final String description;
  final RecommendationPriority priority;
  final RecommendationCategory category;
  final List<String> actionableSteps;

  ProactiveRecommendation({
    required this.title,
    required this.description,
    required this.priority,
    required this.category,
    required this.actionableSteps,
  });
}

enum InsightType {
  periodPrediction,
  phaseBased,
  symptomPrediction,
  healthAlert,
}

class PredictiveInsight {
  final DateTime date;
  final InsightType type;
  final double confidence;
  final String message;
  final bool actionable;
  final String? action;

  PredictiveInsight({
    required this.date,
    required this.type,
    required this.confidence,
    required this.message,
    required this.actionable,
    this.action,
  });
}
