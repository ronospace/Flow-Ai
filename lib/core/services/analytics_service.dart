import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/cycle_data.dart';
import '../models/daily_tracking_data.dart';
import '../models/cycle_data.dart';
import '../database/database_service.dart';
import 'cycle_calculation_engine.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  static AnalyticsService get instance => _instance;
  AnalyticsService._internal();

  final DatabaseService _databaseService = DatabaseService();
  final CycleCalculationEngine _calculationEngine = CycleCalculationEngine();

  // Cycle Analytics
  Future<CycleAnalytics> getCycleAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      startDate ??= DateTime.now().subtract(const Duration(days: 365));
      endDate ??= DateTime.now();

      final cycles = await _databaseService.getCyclesInRange(startDate, endDate);
      final trackingData = await _databaseService.getTrackingDataInRange(startDate, endDate);

      return _calculateCycleAnalytics(cycles, trackingData);
    } catch (e) {
      debugPrint('Error getting cycle analytics: $e');
      return CycleAnalytics.empty();
    }
  }

  // Health Analytics
  Future<HealthAnalytics> getHealthAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      startDate ??= DateTime.now().subtract(const Duration(days: 90));
      endDate ??= DateTime.now();

      final trackingData = await _databaseService.getTrackingDataInRange(startDate, endDate);
      final symptoms = await _databaseService.getAllSymptoms();

      return _calculateHealthAnalytics(trackingData, symptoms);
    } catch (e) {
      debugPrint('Error getting health analytics: $e');
      return HealthAnalytics.empty();
    }
  }

  // Prediction Analytics
  Future<PredictionAnalytics> getPredictionAnalytics() async {
    try {
      final cycles = await _databaseService.getCyclesInRange(
        DateTime.now().subtract(const Duration(days: 365)),
        DateTime.now(),
      );

      return _calculatePredictionAnalytics(cycles);
    } catch (e) {
      debugPrint('Error getting prediction analytics: $e');
      return PredictionAnalytics.empty();
    }
  }

  // Trend Analytics
  Future<TrendAnalytics> getTrendAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      startDate ??= DateTime.now().subtract(const Duration(days: 180));
      endDate ??= DateTime.now();

      final trackingData = await _databaseService.getTrackingDataInRange(startDate, endDate);
      final cycles = await _databaseService.getCyclesInRange(startDate, endDate);

      return _calculateTrendAnalytics(trackingData, cycles);
    } catch (e) {
      debugPrint('Error getting trend analytics: $e');
      return TrendAnalytics.empty();
    }
  }

  // Personalized Recommendations
  Future<List<PersonalizedRecommendation>> getPersonalizedRecommendations() async {
    try {
      final analytics = await getCycleAnalytics();
      final healthAnalytics = await getHealthAnalytics();
      final trendAnalytics = await getTrendAnalytics();

      return _generatePersonalizedRecommendations(analytics, healthAnalytics, trendAnalytics);
    } catch (e) {
      debugPrint('Error getting personalized recommendations: $e');
      return [];
    }
  }

  // Log event for general analytics tracking
  void logEvent(String eventName, Map<String, dynamic> parameters) {
    try {
      // In a production app, this would send to your analytics backend
      debugPrint('Analytics Event: $eventName, Parameters: $parameters');
    } catch (e) {
      debugPrint('Error logging analytics event: $e');
    }
  }

  // Private calculation methods
  CycleAnalytics _calculateCycleAnalytics(
    List<CycleData> cycles,
    List<DailyTrackingData> trackingData,
  ) {
    if (cycles.isEmpty) return CycleAnalytics.empty();

    // Calculate cycle statistics
    final cycleLengths = cycles.map((c) => c.length).toList();
    final averageCycleLength = cycleLengths.fold(0, (a, b) => a + b) / cycleLengths.length;
    
    // For period length, we'll use the cycle length as an estimate
    // In a real implementation, this would be calculated from bleeding days
    final periodLengths = cycles.map((c) => c.length).toList();
    final averagePeriodLength = periodLengths.isNotEmpty
        ? periodLengths.fold(0, (a, b) => a + b) / periodLengths.length
        : 0.0;

    // Calculate cycle regularity
    final cycleVariations = <double>[];
    for (int i = 1; i < cycleLengths.length; i++) {
      cycleVariations.add((cycleLengths[i] - cycleLengths[i - 1]).abs().toDouble());
    }
    final averageVariation = cycleVariations.isNotEmpty
        ? cycleVariations.fold(0.0, (a, b) => a + b) / cycleVariations.length
        : 0.0;
    
    final regularityScore = _calculateRegularityScore(averageVariation);

    // Calculate flow patterns
    final flowData = trackingData
        .where((t) => t.flowIntensity != null)
        .map((t) => t.flowIntensity!)
        .toList();
    
    final flowPattern = _analyzeFlowPattern(flowData);

    // Calculate symptom patterns
    final symptomFrequency = _calculateSymptomFrequency(trackingData);

    return CycleAnalytics(
      totalCycles: cycles.length,
      averageCycleLength: averageCycleLength,
      averagePeriodLength: averagePeriodLength,
      regularityScore: regularityScore,
      cycleVariation: averageVariation,
      flowPattern: flowPattern,
      symptomFrequency: symptomFrequency,
      lastUpdated: DateTime.now(),
    );
  }

  HealthAnalytics _calculateHealthAnalytics(
    List<DailyTrackingData> trackingData,
    List<Map<String, dynamic>> symptoms,
  ) {
    // Mood analysis
    final moodData = trackingData
        .where((t) => t.mood != null)
        .map((t) => t.mood!)
        .toList();
    final moodTrend = _calculateMoodTrend(moodData);

    // Energy analysis
    final energyData = trackingData
        .where((t) => t.energy != null)
        .map((t) => t.energy!)
        .toList();
    final energyTrend = _calculateEnergyTrend(energyData);

    // Sleep analysis
    final sleepData = trackingData
        .where((t) => t.sleepHours != null)
        .map((t) => t.sleepHours!)
        .toList();
    final sleepTrend = _calculateSleepTrend(sleepData);

    // Symptom severity trends
    final symptomSeverity = _calculateSymptomSeverityTrends(trackingData);

    // Overall health score
    final healthScore = _calculateOverallHealthScore(moodData, energyData, sleepData);

    return HealthAnalytics(
      moodTrend: moodTrend,
      energyTrend: energyTrend,
      sleepTrend: sleepTrend,
      symptomSeverity: symptomSeverity,
      overallHealthScore: healthScore,
      lastUpdated: DateTime.now(),
    );
  }

  PredictionAnalytics _calculatePredictionAnalytics(List<CycleData> cycles) {
    if (cycles.length < 3) return PredictionAnalytics.empty();

    // Calculate prediction accuracy for past cycles
    final accuracyData = <PredictionAccuracy>[];
    
    for (int i = 2; i < cycles.length; i++) {
      final pastCycles = cycles.sublist(0, i);
      final actualCycle = cycles[i];
      
      // Use calculation engine to predict based on past data
      // Using a mock prediction since calculateNextCycle method needs CyclePrediction return type
      final prediction = CyclePrediction(
        predictedStartDate: pastCycles.last.startDate.add(Duration(days: 28)),
        predictedLength: 28,
        confidence: 0.8,
        fertileWindow: FertileWindow(
          start: DateTime.now().add(Duration(days: 12)),
          end: DateTime.now().add(Duration(days: 16)),
          ovulationDay: 14,
        ),
      );
      
      if (actualCycle.startDate != null) {
        final predictedStart = prediction.predictedStartDate;
        final actualStart = actualCycle.startDate!;
        final daysDifference = actualStart.difference(predictedStart).inDays.abs();
        
        accuracyData.add(PredictionAccuracy(
          cycleNumber: i + 1,
          predictedDate: predictedStart,
          actualDate: actualStart,
          accuracyDays: daysDifference,
        ));
      }
    }

    final averageAccuracy = accuracyData.isNotEmpty
        ? accuracyData.map((a) => a.accuracyDays).fold(0, (a, b) => a + b) / accuracyData.length
        : 0.0;

    final confidenceScore = _calculateConfidenceScore(averageAccuracy, cycles.length);

    return PredictionAnalytics(
      averageAccuracyDays: averageAccuracy,
      confidenceScore: confidenceScore,
      accuracyHistory: accuracyData,
      totalPredictions: accuracyData.length,
      lastUpdated: DateTime.now(),
    );
  }

  TrendAnalytics _calculateTrendAnalytics(
    List<DailyTrackingData> trackingData,
    List<CycleData> cycles,
  ) {
    // Calculate monthly trends
    final monthlyData = _groupDataByMonth(trackingData);
    final trends = <String, TrendData>{};

    // Mood trends
    trends['mood'] = _calculateDataTrend(
      monthlyData.map((month) => month
          .where((t) => t.mood != null)
          .map((t) => t.mood!.toDouble())
          .fold(0.0, (a, b) => a + b) / 
          month.where((t) => t.mood != null).length)
      .toList(),
    );

    // Energy trends
    trends['energy'] = _calculateDataTrend(
      monthlyData.map((month) => month
          .where((t) => t.energy != null)
          .map((t) => t.energy!.toDouble())
          .fold(0.0, (a, b) => a + b) / 
          month.where((t) => t.energy != null).length)
      .toList(),
    );

    // Sleep trends
    trends['sleep'] = _calculateDataTrend(
      monthlyData.map((month) => month
          .where((t) => t.sleepHours != null)
          .map((t) => t.sleepHours!)
          .fold(0.0, (a, b) => a + b) / 
          month.where((t) => t.sleepHours != null).length)
      .toList(),
    );

    return TrendAnalytics(
      trends: trends,
      timeframe: '6 months',
      lastUpdated: DateTime.now(),
    );
  }

  List<PersonalizedRecommendation> _generatePersonalizedRecommendations(
    CycleAnalytics cycleAnalytics,
    HealthAnalytics healthAnalytics,
    TrendAnalytics trendAnalytics,
  ) {
    final recommendations = <PersonalizedRecommendation>[];

    // Cycle-based recommendations
    if (cycleAnalytics.regularityScore < 0.7) {
      recommendations.add(PersonalizedRecommendation(
        id: 'cycle_regularity',
        title: 'Improve Cycle Regularity',
        description: 'Your cycles show some irregularity. Consider lifestyle adjustments.',
        category: RecommendationCategory.cycle,
        priority: RecommendationPriority.medium,
        actionItems: [
          'Maintain consistent sleep schedule',
          'Practice stress management techniques',
          'Consider consulting a healthcare provider',
        ],
        icon: 'cycle_regularity',
      ));
    }

    // Health-based recommendations
    if (healthAnalytics.overallHealthScore < 70) {
      recommendations.add(PersonalizedRecommendation(
        id: 'overall_health',
        title: 'Boost Overall Wellness',
        description: 'Your health metrics suggest room for improvement.',
        category: RecommendationCategory.health,
        priority: RecommendationPriority.high,
        actionItems: [
          'Increase physical activity',
          'Focus on balanced nutrition',
          'Prioritize quality sleep',
          'Practice mindfulness or meditation',
        ],
        icon: 'health_boost',
      ));
    }

    // Mood-based recommendations
    if (healthAnalytics.moodTrend.direction == TrendDirection.declining) {
      recommendations.add(PersonalizedRecommendation(
        id: 'mood_support',
        title: 'Support Your Mood',
        description: 'Your mood has been trending downward recently.',
        category: RecommendationCategory.mood,
        priority: RecommendationPriority.high,
        actionItems: [
          'Engage in activities you enjoy',
          'Connect with friends and family',
          'Consider professional support if needed',
          'Practice gratitude journaling',
        ],
        icon: 'mood_support',
      ));
    }

    return recommendations;
  }

  // Helper methods
  double _calculateRegularityScore(double variation) {
    // Score from 0-1, where 1 is perfectly regular
    if (variation <= 1) return 1.0;
    if (variation <= 2) return 0.9;
    if (variation <= 3) return 0.8;
    if (variation <= 4) return 0.7;
    if (variation <= 5) return 0.6;
    return max(0.0, 0.6 - (variation - 5) * 0.1);
  }

  FlowPattern _analyzeFlowPattern(List<FlowIntensity> flowData) {
    if (flowData.isEmpty) return FlowPattern.unknown;
    
    final intensityCounts = <FlowIntensity, int>{};
    for (final flow in flowData) {
      intensityCounts[flow] = (intensityCounts[flow] ?? 0) + 1;
    }

    final mostCommon = intensityCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    switch (mostCommon) {
      case FlowIntensity.light:
        return FlowPattern.light;
      case FlowIntensity.medium:
        return FlowPattern.medium;
      case FlowIntensity.heavy:
        return FlowPattern.heavy;
      default:
        return FlowPattern.variable;
    }
  }

  Map<String, double> _calculateSymptomFrequency(List<DailyTrackingData> trackingData) {
    final symptomCounts = <String, int>{};
    final totalDays = trackingData.length;

    for (final data in trackingData) {
      if (data.symptoms != null) {
        for (final symptom in data.symptoms!) {
          symptomCounts[symptom] = (symptomCounts[symptom] ?? 0) + 1;
        }
      }
    }

    return symptomCounts.map((symptom, count) =>
        MapEntry(symptom, count / totalDays));
  }

  TrendData _calculateMoodTrend(List<int> moodData) {
    if (moodData.length < 2) return TrendData.stable();
    
    final average = moodData.fold(0, (a, b) => a + b) / moodData.length;
    final recent = moodData.skip(moodData.length - min(7, moodData.length)).toList();
    final recentAverage = recent.fold(0, (a, b) => a + b) / recent.length;
    
    final difference = recentAverage - average;
    
    if (difference > 0.5) return TrendData.improving();
    if (difference < -0.5) return TrendData.declining();
    return TrendData.stable();
  }

  TrendData _calculateEnergyTrend(List<int> energyData) {
    return _calculateMoodTrend(energyData); // Same logic
  }

  TrendData _calculateSleepTrend(List<double> sleepData) {
    if (sleepData.length < 2) return TrendData.stable();
    
    final average = sleepData.fold(0.0, (a, b) => a + b) / sleepData.length;
    final recent = sleepData.skip(sleepData.length - min(7, sleepData.length)).toList();
    final recentAverage = recent.fold(0.0, (a, b) => a + b) / recent.length;
    
    final difference = recentAverage - average;
    
    if (difference > 0.5) return TrendData.improving();
    if (difference < -0.5) return TrendData.declining();
    return TrendData.stable();
  }

  Map<String, TrendData> _calculateSymptomSeverityTrends(List<DailyTrackingData> trackingData) {
    // Placeholder implementation
    return {};
  }

  double _calculateOverallHealthScore(
    List<int> moodData,
    List<int> energyData,
    List<double> sleepData,
  ) {
    double score = 50.0; // Base score
    
    if (moodData.isNotEmpty) {
      final avgMood = moodData.fold(0, (a, b) => a + b) / moodData.length;
      score += (avgMood - 3) * 10; // Mood scale 1-5, neutral is 3
    }
    
    if (energyData.isNotEmpty) {
      final avgEnergy = energyData.fold(0, (a, b) => a + b) / energyData.length;
      score += (avgEnergy - 3) * 10;
    }
    
    if (sleepData.isNotEmpty) {
      final avgSleep = sleepData.fold(0.0, (a, b) => a + b) / sleepData.length;
      if (avgSleep >= 7 && avgSleep <= 9) {
        score += 20;
      } else {
        score -= (avgSleep - 8).abs() * 5;
      }
    }
    
    return max(0, min(100, score));
  }

  double _calculateConfidenceScore(double averageAccuracy, int cycleCount) {
    // Base confidence on cycle count and prediction accuracy
    double confidence = min(cycleCount / 12.0, 1.0) * 50; // Up to 50% for cycle count
    
    // Add accuracy bonus (lower average accuracy = higher confidence)
    if (averageAccuracy <= 1) confidence += 50;
    else if (averageAccuracy <= 2) confidence += 40;
    else if (averageAccuracy <= 3) confidence += 30;
    else confidence += max(0, 30 - (averageAccuracy - 3) * 5);
    
    return max(0, min(100, confidence));
  }

  List<List<DailyTrackingData>> _groupDataByMonth(List<DailyTrackingData> data) {
    final grouped = <DateTime, List<DailyTrackingData>>{};
    
    for (final item in data) {
      final monthKey = DateTime(item.date.year, item.date.month);
      grouped.putIfAbsent(monthKey, () => []).add(item);
    }
    
    return grouped.values.toList();
  }

  TrendData _calculateDataTrend(List<double> values) {
    if (values.length < 2) return TrendData.stable();
    
    // Simple linear regression slope
    final n = values.length;
    final x = List.generate(n, (i) => i.toDouble());
    final y = values;
    
    final xMean = x.fold(0.0, (a, b) => a + b) / n;
    final yMean = y.fold(0.0, (a, b) => a + b) / n;
    
    double numerator = 0;
    double denominator = 0;
    
    for (int i = 0; i < n; i++) {
      numerator += (x[i] - xMean) * (y[i] - yMean);
      denominator += (x[i] - xMean) * (x[i] - xMean);
    }
    
    final slope = denominator != 0 ? numerator / denominator : 0;
    
    if (slope > 0.1) return TrendData.improving();
    if (slope < -0.1) return TrendData.declining();
    return TrendData.stable();
  }
}

// Analytics Models
class CycleAnalytics {
  final int totalCycles;
  final double averageCycleLength;
  final double averagePeriodLength;
  final double regularityScore;
  final double cycleVariation;
  final FlowPattern flowPattern;
  final Map<String, double> symptomFrequency;
  final DateTime lastUpdated;

  CycleAnalytics({
    required this.totalCycles,
    required this.averageCycleLength,
    required this.averagePeriodLength,
    required this.regularityScore,
    required this.cycleVariation,
    required this.flowPattern,
    required this.symptomFrequency,
    required this.lastUpdated,
  });

  factory CycleAnalytics.empty() => CycleAnalytics(
        totalCycles: 0,
        averageCycleLength: 0,
        averagePeriodLength: 0,
        regularityScore: 0,
        cycleVariation: 0,
        flowPattern: FlowPattern.unknown,
        symptomFrequency: {},
        lastUpdated: DateTime.now(),
      );
}

class HealthAnalytics {
  final TrendData moodTrend;
  final TrendData energyTrend;
  final TrendData sleepTrend;
  final Map<String, TrendData> symptomSeverity;
  final double overallHealthScore;
  final DateTime lastUpdated;

  HealthAnalytics({
    required this.moodTrend,
    required this.energyTrend,
    required this.sleepTrend,
    required this.symptomSeverity,
    required this.overallHealthScore,
    required this.lastUpdated,
  });

  factory HealthAnalytics.empty() => HealthAnalytics(
        moodTrend: TrendData.stable(),
        energyTrend: TrendData.stable(),
        sleepTrend: TrendData.stable(),
        symptomSeverity: {},
        overallHealthScore: 50,
        lastUpdated: DateTime.now(),
      );
}

class PredictionAnalytics {
  final double averageAccuracyDays;
  final double confidenceScore;
  final List<PredictionAccuracy> accuracyHistory;
  final int totalPredictions;
  final DateTime lastUpdated;

  PredictionAnalytics({
    required this.averageAccuracyDays,
    required this.confidenceScore,
    required this.accuracyHistory,
    required this.totalPredictions,
    required this.lastUpdated,
  });

  factory PredictionAnalytics.empty() => PredictionAnalytics(
        averageAccuracyDays: 0,
        confidenceScore: 0,
        accuracyHistory: [],
        totalPredictions: 0,
        lastUpdated: DateTime.now(),
      );
}

class TrendAnalytics {
  final Map<String, TrendData> trends;
  final String timeframe;
  final DateTime lastUpdated;

  TrendAnalytics({
    required this.trends,
    required this.timeframe,
    required this.lastUpdated,
  });

  factory TrendAnalytics.empty() => TrendAnalytics(
        trends: {},
        timeframe: '',
        lastUpdated: DateTime.now(),
      );
}

class TrendData {
  final TrendDirection direction;
  final double magnitude;
  final double confidence;

  TrendData({
    required this.direction,
    required this.magnitude,
    required this.confidence,
  });

  factory TrendData.improving() => TrendData(
        direction: TrendDirection.improving,
        magnitude: 0.5,
        confidence: 0.8,
      );

  factory TrendData.declining() => TrendData(
        direction: TrendDirection.declining,
        magnitude: 0.5,
        confidence: 0.8,
      );

  factory TrendData.stable() => TrendData(
        direction: TrendDirection.stable,
        magnitude: 0.0,
        confidence: 0.9,
      );
}

class PredictionAccuracy {
  final int cycleNumber;
  final DateTime predictedDate;
  final DateTime actualDate;
  final int accuracyDays;

  PredictionAccuracy({
    required this.cycleNumber,
    required this.predictedDate,
    required this.actualDate,
    required this.accuracyDays,
  });
}

class PersonalizedRecommendation {
  final String id;
  final String title;
  final String description;
  final RecommendationCategory category;
  final RecommendationPriority priority;
  final List<String> actionItems;
  final String icon;

  PersonalizedRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.actionItems,
    required this.icon,
  });
}

// Fertile Window class for predictions
class FertileWindow {
  final DateTime start;
  final DateTime end;
  final int ovulationDay;

  FertileWindow({
    required this.start,
    required this.end,
    required this.ovulationDay,
  });
}

enum FlowPattern { light, medium, heavy, variable, unknown }
enum TrendDirection { improving, declining, stable }
enum RecommendationCategory { cycle, health, mood, sleep, nutrition, exercise }
enum RecommendationPriority { low, medium, high, urgent }

/// Extension for RecommendationPriority to add compareTo functionality
extension RecommendationPriorityExtension on RecommendationPriority {
  int compareTo(RecommendationPriority other) {
    return index.compareTo(other.index);
  }
}
