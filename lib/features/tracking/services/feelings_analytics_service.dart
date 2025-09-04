import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';

import '../screens/enhanced_daily_feelings_tracker.dart';
import 'feelings_database_service.dart';

/// Analytics service for feelings data analysis and insights generation
class FeelingsAnalyticsService {
  static FeelingsAnalyticsService? _instance;
  static FeelingsAnalyticsService get instance {
    _instance ??= FeelingsAnalyticsService._internal();
    return _instance!;
  }

  FeelingsAnalyticsService._internal();

  final FeelingsDatabaseService _databaseService = FeelingsDatabaseService.instance;
  bool _isInitialized = false;

  /// Initialize the analytics service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _databaseService.initialize();
      _isInitialized = true;
      debugPrint('📈 Feelings analytics service initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize feelings analytics: $e');
      throw AnalyticsException('Failed to initialize analytics service: $e');
    }
  }

  /// Process a new entry and generate insights
  Future<void> processNewEntry(DailyFeelingsEntry entry) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Trigger background analytics processing
      _processEntryInBackground(entry);
    } catch (e) {
      debugPrint('❌ Failed to process new entry: $e');
    }
  }

  /// Background processing of entry analytics
  void _processEntryInBackground(DailyFeelingsEntry entry) async {
    try {
      // Analyze trends
      await _analyzeTrends(entry);

      // Generate insights
      await _generateInsights(entry);

      // Clean up expired data
      await _databaseService.cleanupExpiredInsights();

      debugPrint('✅ Processed analytics for entry ${entry.id}');
    } catch (e) {
      debugPrint('❌ Error in background processing: $e');
    }
  }

  /// Get recent trends for user
  Future<List<TrendInsight>> getRecentTrends({
    required String userId,
    int limit = 10,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Get recent entries for analysis
      final entries = await _databaseService.getRecentEntries(
        limit: 30,
        userId: userId,
      );

      if (entries.length < 7) {
        return []; // Need at least a week of data for trends
      }

      final trends = <TrendInsight>[];

      // Analyze mood trends
      final moodTrends = _analyzeMoodTrends(entries);
      trends.addAll(moodTrends);

      // Analyze energy trends
      final energyTrends = _analyzeEnergyTrends(entries);
      trends.addAll(energyTrends);

      // Analyze wellbeing trends
      final wellbeingTrends = _analyzeWellbeingTrends(entries);
      trends.addAll(wellbeingTrends);

      // Sort by confidence and limit
      trends.sort((a, b) => b.confidence.compareTo(a.confidence));
      return trends.take(limit).toList();
    } catch (e) {
      debugPrint('❌ Failed to get recent trends: $e');
      return [];
    }
  }

  /// Analyze mood trends
  List<TrendInsight> _analyzeMoodTrends(List<DailyFeelingsEntry> entries) {
    final trends = <TrendInsight>[];

    // Analyze each mood category
    for (final category in MoodCategory.values) {
      final values = entries
          .where((e) => e.moodScores.containsKey(category))
          .map((e) => e.moodScores[category]!)
          .toList();

      if (values.length < 7) continue;

      final trend = _calculateTrend(values);
      if (trend.direction != TrendDirection.stable) {
        trends.add(TrendInsight(
          description: _generateMoodTrendDescription(category, trend),
          direction: trend.direction,
          confidence: trend.confidence,
          category: 'mood',
        ));
      }
    }

    return trends;
  }

  /// Analyze energy trends
  List<TrendInsight> _analyzeEnergyTrends(List<DailyFeelingsEntry> entries) {
    final trends = <TrendInsight>[];

    // Analyze each energy type
    for (final type in EnergyType.values) {
      final values = entries
          .where((e) => e.energyLevels.containsKey(type))
          .map((e) => e.energyLevels[type]!)
          .toList();

      if (values.length < 7) continue;

      final trend = _calculateTrend(values);
      if (trend.direction != TrendDirection.stable) {
        trends.add(TrendInsight(
          description: _generateEnergyTrendDescription(type, trend),
          direction: trend.direction,
          confidence: trend.confidence,
          category: 'energy',
        ));
      }
    }

    return trends;
  }

  /// Analyze overall wellbeing trends
  List<TrendInsight> _analyzeWellbeingTrends(List<DailyFeelingsEntry> entries) {
    final trends = <TrendInsight>[];

    final values = entries.map((e) => e.overallWellbeing).toList();
    if (values.length < 7) return trends;

    final trend = _calculateTrend(values);
    if (trend.direction != TrendDirection.stable) {
      trends.add(TrendInsight(
        description: _generateWellbeingTrendDescription(trend),
        direction: trend.direction,
        confidence: trend.confidence,
        category: 'wellbeing',
      ));
    }

    return trends;
  }

  /// Calculate trend direction and confidence
  TrendData _calculateTrend(List<double> values) {
    if (values.length < 3) {
      return TrendData(TrendDirection.stable, 0.0);
    }

    // Simple linear regression slope
    final n = values.length;
    final sumX = (n * (n - 1)) / 2; // Sum of indices 0, 1, 2, ..., n-1
    final sumY = values.reduce((a, b) => a + b);
    final sumXY = values.asMap().entries.fold<double>(
      0.0,
      (sum, entry) => sum + (entry.key * entry.value),
    );
    final sumXX = (n * (n - 1) * (2 * n - 1)) / 6; // Sum of squares of indices

    final slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);

    // Calculate confidence based on slope magnitude and consistency
    final normalizedSlope = slope / 10; // Normalize for 1-10 scale
    final confidence = math.min(normalizedSlope.abs() * 2, 1.0);

    TrendDirection direction;
    if (slope > 0.1) {
      direction = TrendDirection.up;
    } else if (slope < -0.1) {
      direction = TrendDirection.down;
    } else {
      direction = TrendDirection.stable;
    }

    return TrendData(direction, confidence);
  }

  /// Generate mood trend description
  String _generateMoodTrendDescription(MoodCategory category, TrendData trend) {
    final categoryName = category.displayName.toLowerCase();
    final direction = trend.direction == TrendDirection.up ? 'increasing' : 'decreasing';
    
    return 'Your $categoryName levels have been $direction over the past week';
  }

  /// Generate energy trend description
  String _generateEnergyTrendDescription(EnergyType type, TrendData trend) {
    final typeName = type.displayName.toLowerCase();
    final direction = trend.direction == TrendDirection.up ? 'improving' : 'declining';
    
    return 'Your $typeName has been $direction recently';
  }

  /// Generate wellbeing trend description
  String _generateWellbeingTrendDescription(TrendData trend) {
    final direction = trend.direction == TrendDirection.up ? 'improving' : 'declining';
    return 'Your overall wellbeing has been $direction';
  }

  /// Analyze trends for database storage
  Future<void> _analyzeTrends(DailyFeelingsEntry entry) async {
    try {
      final endDate = entry.date;
      final startDate = endDate.subtract(const Duration(days: 14));

      final entries = await _databaseService.getEntriesInRange(
        startDate: startDate,
        endDate: endDate,
      );

      if (entries.length < 7) return;

      // Analyze and save trends
      final trends = <TrendAnalysis>[];

      // Mood trends
      for (final category in MoodCategory.values) {
        final values = entries
            .where((e) => e.moodScores.containsKey(category))
            .map((e) => e.moodScores[category]!)
            .toList();

        if (values.length >= 7) {
          final trendData = _calculateTrend(values);
          if (trendData.direction != TrendDirection.stable && trendData.confidence > 0.5) {
            trends.add(TrendAnalysis(
              id: 'trend_mood_${category.name}_${DateTime.now().millisecondsSinceEpoch}',
              type: 'mood_${category.name}',
              description: _generateMoodTrendDescription(category, trendData),
              direction: trendData.direction,
              confidence: trendData.confidence,
              startDate: startDate,
              endDate: endDate,
              dataPoints: values.length,
            ));
          }
        }
      }

      // Save trends to database
      for (final trend in trends) {
        await _databaseService.saveTrend(trend);
      }
    } catch (e) {
      debugPrint('❌ Failed to analyze trends: $e');
    }
  }

  /// Generate insights from entry data
  Future<void> _generateInsights(DailyFeelingsEntry entry) async {
    try {
      final insights = <FeelingsInsight>[];

      // Get recent entries for context
      final recentEntries = await _databaseService.getRecentEntries(limit: 14);

      // Low wellbeing insight
      if (entry.overallWellbeing < 4) {
        insights.add(FeelingsInsight(
          id: 'insight_low_wellbeing_${DateTime.now().millisecondsSinceEpoch}',
          type: 'wellbeing_alert',
          title: 'Low Wellbeing Detected',
          description: 'Your overall wellbeing score is lower than usual. Consider self-care activities or reaching out for support.',
          category: 'wellbeing',
          priority: InsightPriority.high,
          confidence: 0.9,
          actionable: true,
          dataSources: ['daily_entry'],
          generatedAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 3)),
        ));
      }

      // High anxiety insight
      if (entry.moodScores[MoodCategory.anxiety] != null &&
          entry.moodScores[MoodCategory.anxiety]! > 7) {
        insights.add(FeelingsInsight(
          id: 'insight_high_anxiety_${DateTime.now().millisecondsSinceEpoch}',
          type: 'anxiety_alert',
          title: 'High Anxiety Level',
          description: 'Your anxiety levels are elevated today. Consider breathing exercises or mindfulness practices.',
          category: 'mood',
          priority: InsightPriority.high,
          confidence: 0.85,
          actionable: true,
          dataSources: ['daily_entry'],
          generatedAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 1)),
        ));
      }

      // Positive mood streak insight
      final happinessValues = recentEntries
          .where((e) => e.moodScores.containsKey(MoodCategory.happiness))
          .map((e) => e.moodScores[MoodCategory.happiness]!)
          .take(7)
          .toList();

      if (happinessValues.length >= 7 && happinessValues.every((v) => v >= 7)) {
        insights.add(FeelingsInsight(
          id: 'insight_happiness_streak_${DateTime.now().millisecondsSinceEpoch}',
          type: 'positive_trend',
          title: 'Great Happiness Streak!',
          description: 'You\'ve maintained high happiness levels for a week. Whatever you\'re doing, keep it up!',
          category: 'mood',
          priority: InsightPriority.medium,
          confidence: 0.8,
          actionable: false,
          dataSources: ['recent_entries'],
          generatedAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 7)),
        ));
      }

      // Low energy pattern insight
      final energyValues = recentEntries
          .take(5)
          .map((e) => e.energyLevels.values.isEmpty 
              ? 5.0 
              : e.energyLevels.values.reduce((a, b) => a + b) / e.energyLevels.length)
          .toList();

      if (energyValues.length >= 5 && energyValues.every((v) => v <= 4)) {
        insights.add(FeelingsInsight(
          id: 'insight_low_energy_${DateTime.now().millisecondsSinceEpoch}',
          type: 'energy_alert',
          title: 'Consistent Low Energy',
          description: 'Your energy levels have been low for several days. Consider improving sleep, exercise, or nutrition.',
          category: 'energy',
          priority: InsightPriority.medium,
          confidence: 0.75,
          actionable: true,
          dataSources: ['recent_entries'],
          generatedAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 5)),
        ));
      }

      // Save insights to database
      for (final insight in insights) {
        await _databaseService.saveInsight(insight);
      }
    } catch (e) {
      debugPrint('❌ Failed to generate insights: $e');
    }
  }

  /// Get comprehensive analytics summary
  Future<AnalyticsSummary> getAnalyticsSummary({
    required String userId,
    int dayRange = 30,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: dayRange));

      final entries = await _databaseService.getEntriesInRange(
        startDate: startDate,
        endDate: endDate,
        userId: userId,
      );

      if (entries.isEmpty) {
        return AnalyticsSummary.empty();
      }

      return AnalyticsSummary(
        totalEntries: entries.length,
        averageWellbeing: _calculateAverageWellbeing(entries),
        moodDistribution: _calculateMoodDistribution(entries),
        energyDistribution: _calculateEnergyDistribution(entries),
        commonSymptoms: _getCommonSymptoms(entries),
        commonTags: _getCommonTags(entries),
        streaks: _calculateStreaks(entries),
        periodAnalyzed: dayRange,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('❌ Failed to get analytics summary: $e');
      return AnalyticsSummary.empty();
    }
  }

  /// Calculate average wellbeing
  double _calculateAverageWellbeing(List<DailyFeelingsEntry> entries) {
    if (entries.isEmpty) return 0.0;
    
    final sum = entries.map((e) => e.overallWellbeing).reduce((a, b) => a + b);
    return sum / entries.length;
  }

  /// Calculate mood distribution
  Map<String, double> _calculateMoodDistribution(List<DailyFeelingsEntry> entries) {
    final distribution = <String, double>{};
    
    for (final category in MoodCategory.values) {
      final values = entries
          .where((e) => e.moodScores.containsKey(category))
          .map((e) => e.moodScores[category]!)
          .toList();
      
      if (values.isNotEmpty) {
        distribution[category.displayName] = values.reduce((a, b) => a + b) / values.length;
      }
    }
    
    return distribution;
  }

  /// Calculate energy distribution
  Map<String, double> _calculateEnergyDistribution(List<DailyFeelingsEntry> entries) {
    final distribution = <String, double>{};
    
    for (final type in EnergyType.values) {
      final values = entries
          .where((e) => e.energyLevels.containsKey(type))
          .map((e) => e.energyLevels[type]!)
          .toList();
      
      if (values.isNotEmpty) {
        distribution[type.displayName] = values.reduce((a, b) => a + b) / values.length;
      }
    }
    
    return distribution;
  }

  /// Get common symptoms
  Map<String, int> _getCommonSymptoms(List<DailyFeelingsEntry> entries) {
    final symptomCounts = <String, int>{};
    
    for (final entry in entries) {
      for (final symptom in entry.symptoms.keys) {
        symptomCounts[symptom] = (symptomCounts[symptom] ?? 0) + 1;
      }
    }
    
    // Sort by frequency and return top 10
    final sorted = symptomCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sorted.take(10));
  }

  /// Get common tags
  Map<String, int> _getCommonTags(List<DailyFeelingsEntry> entries) {
    final tagCounts = <String, int>{};
    
    for (final entry in entries) {
      for (final tag in entry.customTags.keys) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }
    
    // Sort by frequency and return top 10
    final sorted = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sorted.take(10));
  }

  /// Calculate streaks
  Map<String, int> _calculateStreaks(List<DailyFeelingsEntry> entries) {
    final streaks = <String, int>{};
    
    // Sort entries by date (newest first)
    entries.sort((a, b) => b.date.compareTo(a.date));
    
    // Calculate current wellbeing streak
    int currentWellbeingStreak = 0;
    for (final entry in entries) {
      if (entry.overallWellbeing >= 7) {
        currentWellbeingStreak++;
      } else {
        break;
      }
    }
    streaks['High Wellbeing'] = currentWellbeingStreak;
    
    // Calculate happiness streak
    int currentHappinessStreak = 0;
    for (final entry in entries) {
      final happiness = entry.moodScores[MoodCategory.happiness];
      if (happiness != null && happiness >= 7) {
        currentHappinessStreak++;
      } else {
        break;
      }
    }
    streaks['High Happiness'] = currentHappinessStreak;
    
    return streaks;
  }

  /// Get insights for a specific date range
  Future<List<FeelingsInsight>> getInsightsForRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      return await _databaseService.getActiveInsights(userId: userId);
    } catch (e) {
      debugPrint('❌ Failed to get insights for range: $e');
      return [];
    }
  }

  /// Dispose resources
  void dispose() {
    _isInitialized = false;
  }
}

// === SUPPORTING DATA MODELS ===

class TrendData {
  final TrendDirection direction;
  final double confidence;

  TrendData(this.direction, this.confidence);
}

class AnalyticsSummary {
  final int totalEntries;
  final double averageWellbeing;
  final Map<String, double> moodDistribution;
  final Map<String, double> energyDistribution;
  final Map<String, int> commonSymptoms;
  final Map<String, int> commonTags;
  final Map<String, int> streaks;
  final int periodAnalyzed;
  final DateTime generatedAt;

  AnalyticsSummary({
    required this.totalEntries,
    required this.averageWellbeing,
    required this.moodDistribution,
    required this.energyDistribution,
    required this.commonSymptoms,
    required this.commonTags,
    required this.streaks,
    required this.periodAnalyzed,
    required this.generatedAt,
  });

  factory AnalyticsSummary.empty() {
    return AnalyticsSummary(
      totalEntries: 0,
      averageWellbeing: 0.0,
      moodDistribution: {},
      energyDistribution: {},
      commonSymptoms: {},
      commonTags: {},
      streaks: {},
      periodAnalyzed: 0,
      generatedAt: DateTime.now(),
    );
  }
}

class AnalyticsException implements Exception {
  final String message;
  AnalyticsException(this.message);

  @override
  String toString() => 'AnalyticsException: $message';
}
