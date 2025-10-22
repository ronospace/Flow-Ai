import 'package:json_annotation/json_annotation.dart';
import 'biometric_data.dart';

part 'biometric_insights.g.dart';

/// Biometric Insights Model
/// AI-generated health analysis and recommendations based on biometric data
@JsonSerializable()
class BiometricInsights {
  final String insightsId;
  final String userId;
  final DateTime generatedDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalDataPoints;
  final Map<BiometricType, double> keyMetrics;
  final Map<BiometricType, TrendDirection> trends;
  final List<BiometricAnomaly> anomalies;
  final Map<String, double> correlations;
  final double healthScore;
  final List<HealthRecommendation> recommendations;
  final List<RiskFactor> riskFactors;
  final InsightsSummary summary;

  BiometricInsights({
    required this.insightsId,
    required this.userId,
    required this.generatedDate,
    required this.periodStart,
    required this.periodEnd,
    required this.totalDataPoints,
    required this.keyMetrics,
    required this.trends,
    required this.anomalies,
    required this.correlations,
    required this.healthScore,
    required this.recommendations,
    required this.riskFactors,
    required this.summary,
  });

  // Computed properties
  Duration get analysisWindow => periodEnd.difference(periodStart);
  bool get hasHighPriorityRecommendations => 
      recommendations.any((r) => r.priority == RecommendationPriority.high);
  bool get hasCriticalAnomalies => 
      anomalies.any((a) => a.severity == AnomalySeverity.high);
  
  /// Get insights freshness (how recent the analysis is)
  InsightsFreshness get freshness {
    final age = DateTime.now().difference(generatedDate);
    if (age.inHours < 24) return InsightsFreshness.fresh;
    if (age.inDays < 7) return InsightsFreshness.recent;
    if (age.inDays < 30) return InsightsFreshness.stale;
    return InsightsFreshness.outdated;
  }

  /// Get overall insight confidence score (0-100)
  int get confidenceScore {
    var score = 0;
    
    // Data quantity factor
    if (totalDataPoints > 1000) score += 30;
    else if (totalDataPoints > 500) score += 20;
    else if (totalDataPoints > 100) score += 10;
    
    // Time window factor
    if (analysisWindow.inDays >= 30) score += 25;
    else if (analysisWindow.inDays >= 14) score += 15;
    else if (analysisWindow.inDays >= 7) score += 10;
    
    // Metric diversity factor
    score += (keyMetrics.length * 3).clamp(0, 20);
    
    // Correlation strength factor
    final strongCorrelations = correlations.values.where((c) => c.abs() > 0.6).length;
    score += (strongCorrelations * 5).clamp(0, 15);
    
    // Freshness factor
    switch (freshness) {
      case InsightsFreshness.fresh:
        score += 10;
        break;
      case InsightsFreshness.recent:
        score += 7;
        break;
      case InsightsFreshness.stale:
        score += 3;
        break;
      case InsightsFreshness.outdated:
        break;
    }
    
    return score.clamp(0, 100);
  }

  /// Get priority recommendations (high and critical only)
  List<HealthRecommendation> get priorityRecommendations {
    return recommendations
        .where((r) => r.priority == RecommendationPriority.high || 
                     r.priority == RecommendationPriority.critical)
        .toList();
  }

  /// Get anomalies by severity
  Map<AnomalySeverity, List<BiometricAnomaly>> get anomaliesBySeverity {
    final grouped = <AnomalySeverity, List<BiometricAnomaly>>{};
    
    for (final severity in AnomalySeverity.values) {
      grouped[severity] = anomalies.where((a) => a.severity == severity).toList();
    }
    
    return grouped;
  }

  /// Get trends by category
  Map<BiometricCategory, Map<BiometricType, TrendDirection>> get trendsByCategory {
    final grouped = <BiometricCategory, Map<BiometricType, TrendDirection>>{};
    
    for (final entry in trends.entries) {
      final category = entry.key.category;
      if (!grouped.containsKey(category)) {
        grouped[category] = {};
      }
      grouped[category]![entry.key] = entry.value;
    }
    
    return grouped;
  }

  /// Get key insights as text summaries
  List<String> get keyInsights {
    final insights = <String>[];
    
    // Health score insight
    if (healthScore >= 80) {
      insights.add('Your overall health score is excellent at ${healthScore.toStringAsFixed(0)}/100');
    } else if (healthScore >= 60) {
      insights.add('Your health score is good at ${healthScore.toStringAsFixed(0)}/100 with room for improvement');
    } else {
      insights.add('Your health score is ${healthScore.toStringAsFixed(0)}/100 - focus on key recommendations');
    }
    
    // Trend insights
    final improvingTrends = trends.entries
        .where((e) => e.value == TrendDirection.increasing && _isPositiveTrend(e.key))
        .length;
    final decliningTrends = trends.entries
        .where((e) => e.value == TrendDirection.decreasing && _isPositiveTrend(e.key))
        .length;
        
    if (improvingTrends > decliningTrends) {
      insights.add('Most of your health metrics are improving - keep up the great work!');
    } else if (decliningTrends > improvingTrends) {
      insights.add('Some health metrics need attention - check your recommendations');
    }
    
    // Anomaly insights
    if (hasCriticalAnomalies) {
      insights.add('Critical health anomalies detected - consider consulting a healthcare provider');
    } else if (anomalies.isNotEmpty) {
      insights.add('${anomalies.length} health patterns detected for monitoring');
    }
    
    // Correlation insights
    final strongestCorrelation = correlations.entries
        .reduce((a, b) => a.value.abs() > b.value.abs() ? a : b);
    if (strongestCorrelation.value.abs() > 0.7) {
      insights.add('Strong correlation found: ${strongestCorrelation.key}');
    }
    
    return insights;
  }

  bool _isPositiveTrend(BiometricType type) {
    // Define which metrics should trend upward vs downward for positive health
    switch (type) {
      case BiometricType.steps:
      case BiometricType.activeCalories:
      case BiometricType.sleep:
      case BiometricType.heartRateVariability:
      case BiometricType.vo2Max:
        return true; // Higher is better
      case BiometricType.restingHeartRate:
      case BiometricType.stressLevel:
      case BiometricType.bodyFat:
        return false; // Lower is better
      default:
        return true; // Assume higher is better unless specified
    }
  }

  factory BiometricInsights.fromJson(Map<String, dynamic> json) => 
      _$BiometricInsightsFromJson(json);
  Map<String, dynamic> toJson() => _$BiometricInsightsToJson(this);
}

/// Insights Freshness
enum InsightsFreshness {
  fresh('Fresh', 'Generated within 24 hours', 0xFF4CAF50),
  recent('Recent', 'Generated within a week', 0xFF8BC34A),
  stale('Stale', 'Generated within a month', 0xFFFF9800),
  outdated('Outdated', 'Generated over a month ago', 0xFFF44336);

  const InsightsFreshness(this.displayName, this.description, this.color);

  final String displayName;
  final String description;
  final int color;
}

/// Trend Direction
enum TrendDirection {
  decreasing('Decreasing', '📉'),
  stable('Stable', '➡️'),
  increasing('Increasing', '📈');

  const TrendDirection(this.displayName, this.icon);

  final String displayName;
  final String icon;
}

/// Biometric Anomaly
@JsonSerializable()
class BiometricAnomaly {
  final String anomalyId;
  final BiometricType type;
  final double value;
  final Range expectedRange;
  final AnomalySeverity severity;
  final DateTime timestamp;
  final String description;
  final List<String> possibleCauses;
  final List<String> recommendations;

  BiometricAnomaly({
    required this.anomalyId,
    required this.type,
    required this.value,
    required this.expectedRange,
    required this.severity,
    required this.timestamp,
    required this.description,
    this.possibleCauses = const [],
    this.recommendations = const [],
  });

  /// Get deviation from expected range
  double get deviation {
    if (value < expectedRange.min) {
      return expectedRange.min - value;
    } else if (value > expectedRange.max) {
      return value - expectedRange.max;
    }
    return 0.0; // Within range
  }

  /// Get deviation percentage
  double get deviationPercentage {
    final rangeSize = expectedRange.max - expectedRange.min;
    if (rangeSize == 0) return 0.0;
    return (deviation / rangeSize) * 100;
  }

  /// Check if anomaly requires immediate attention
  bool get requiresAttention => severity == AnomalySeverity.high;

  factory BiometricAnomaly.fromJson(Map<String, dynamic> json) => 
      _$BiometricAnomalyFromJson(json);
  Map<String, dynamic> toJson() => _$BiometricAnomalyToJson(this);
}

/// Anomaly Severity
enum AnomalySeverity {
  low('Low', 'Minor deviation from normal', 0xFF8BC34A),
  medium('Medium', 'Moderate concern, monitor closely', 0xFFFF9800),
  high('High', 'Significant deviation, seek medical advice', 0xFFF44336);

  const AnomalySeverity(this.displayName, this.description, this.color);

  final String displayName;
  final String description;
  final int color;
}

/// Range for expected values
@JsonSerializable()
class Range {
  final double min;
  final double max;

  Range(this.min, this.max);

  /// Check if value is within range
  bool contains(double value) => value >= min && value <= max;

  /// Get range size
  double get size => max - min;

  /// Get midpoint
  double get midpoint => (min + max) / 2;

  factory Range.fromJson(Map<String, dynamic> json) => _$RangeFromJson(json);
  Map<String, dynamic> toJson() => _$RangeToJson(this);
}

/// Health Recommendation
@JsonSerializable()
class HealthRecommendation {
  final String recommendationId;
  final RecommendationType type;
  final String title;
  final String description;
  final RecommendationPriority priority;
  final List<String> actionItems;
  final String? targetMetric;
  final double? targetValue;
  final Duration? timeFrame;
  final List<String> resources;

  HealthRecommendation({
    required this.recommendationId,
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
    this.actionItems = const [],
    this.targetMetric,
    this.targetValue,
    this.timeFrame,
    this.resources = const [],
  });

  /// Check if recommendation is time-sensitive
  bool get isTimeSensitive => priority == RecommendationPriority.critical ||
                              priority == RecommendationPriority.high;

  /// Get estimated effort level
  EffortLevel get effortLevel {
    if (actionItems.length <= 2) return EffortLevel.low;
    if (actionItems.length <= 4) return EffortLevel.medium;
    return EffortLevel.high;
  }

  factory HealthRecommendation.fromJson(Map<String, dynamic> json) => 
      _$HealthRecommendationFromJson(json);
  Map<String, dynamic> toJson() => _$HealthRecommendationToJson(this);
}

/// Recommendation Type
enum RecommendationType {
  lifestyle('Lifestyle', 'General lifestyle improvements', '🌟'),
  activity('Activity', 'Physical activity and exercise', '🏃‍♀️'),
  nutrition('Nutrition', 'Diet and nutrition guidance', '🥗'),
  sleep('Sleep', 'Sleep quality and duration', '😴'),
  stress('Stress Management', 'Stress reduction techniques', '🧘‍♀️'),
  medical('Medical', 'Medical consultation recommended', '🩺'),
  monitoring('Monitoring', 'Continue monitoring specific metrics', '📊');

  const RecommendationType(this.displayName, this.description, this.icon);

  final String displayName;
  final String description;
  final String icon;
}

/// Recommendation Priority
enum RecommendationPriority {
  low('Low', 'Nice to have improvement', 0xFF8BC34A),
  medium('Medium', 'Moderate importance', 0xFFFF9800),
  high('High', 'Important for health', 0xFFFF5722),
  critical('Critical', 'Urgent attention required', 0xFFF44336);

  const RecommendationPriority(this.displayName, this.description, this.color);

  final String displayName;
  final String description;
  final int color;
}

/// Effort Level
enum EffortLevel {
  low('Low', 'Easy to implement'),
  medium('Medium', 'Moderate effort required'),
  high('High', 'Significant lifestyle changes needed');

  const EffortLevel(this.displayName, this.description);

  final String displayName;
  final String description;
}

/// Risk Factor
@JsonSerializable()
class RiskFactor {
  final String factorId;
  final String name;
  final RiskLevel riskLevel;
  final String description;
  final List<BiometricType> relatedMetrics;
  final double riskScore; // 0-100
  final List<String> mitigationStrategies;
  final DateTime identifiedDate;

  RiskFactor({
    required this.factorId,
    required this.name,
    required this.riskLevel,
    required this.description,
    required this.relatedMetrics,
    required this.riskScore,
    this.mitigationStrategies = const [],
    required this.identifiedDate,
  });

  /// Check if risk factor is severe
  bool get isSevere => riskLevel == RiskLevel.high || riskLevel == RiskLevel.critical;

  /// Get risk factor age
  Duration get age => DateTime.now().difference(identifiedDate);

  factory RiskFactor.fromJson(Map<String, dynamic> json) => _$RiskFactorFromJson(json);
  Map<String, dynamic> toJson() => _$RiskFactorToJson(this);
}

/// Risk Level
enum RiskLevel {
  low('Low', 'Minimal risk', 0xFF4CAF50),
  medium('Medium', 'Moderate risk to monitor', 0xFFFF9800),
  high('High', 'Significant risk factor', 0xFFFF5722),
  critical('Critical', 'High-priority risk requiring attention', 0xFFF44336);

  const RiskLevel(this.displayName, this.description, this.color);

  final String displayName;
  final String description;
  final int color;
}

/// Insights Summary
@JsonSerializable()
class InsightsSummary {
  final String overallAssessment;
  final List<String> keyFindings;
  final List<String> improvements;
  final List<String> concerns;
  final String nextSteps;
  final InsightsCategory category;

  InsightsSummary({
    required this.overallAssessment,
    required this.keyFindings,
    this.improvements = const [],
    this.concerns = const [],
    required this.nextSteps,
    required this.category,
  });

  /// Get summary tone based on content
  SummaryTone get tone {
    if (concerns.isNotEmpty && improvements.isEmpty) return SummaryTone.concerning;
    if (improvements.isNotEmpty && concerns.isEmpty) return SummaryTone.positive;
    if (improvements.isNotEmpty && concerns.isNotEmpty) return SummaryTone.mixed;
    return SummaryTone.neutral;
  }

  factory InsightsSummary.fromJson(Map<String, dynamic> json) => 
      _$InsightsSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$InsightsSummaryToJson(this);
}

/// Insights Category
enum InsightsCategory {
  excellent('Excellent', 'Outstanding health metrics', '🌟'),
  good('Good', 'Generally healthy patterns', '✅'),
  fair('Fair', 'Room for improvement', '⚠️'),
  poor('Poor', 'Multiple areas need attention', '🚨'),
  insufficient('Insufficient Data', 'Not enough data for analysis', '❓');

  const InsightsCategory(this.displayName, this.description, this.icon);

  final String displayName;
  final String description;
  final String icon;
}

/// Summary Tone
enum SummaryTone {
  positive('Positive', 'Encouraging and optimistic'),
  neutral('Neutral', 'Balanced assessment'),
  mixed('Mixed', 'Both positive and concerning elements'),
  concerning('Concerning', 'Areas requiring attention');

  const SummaryTone(this.displayName, this.description);

  final String displayName;
  final String description;
}

/// Biometric Pattern
@JsonSerializable()
class BiometricPattern {
  final String patternId;
  final String name;
  final PatternType type;
  final List<BiometricType> involvedMetrics;
  final String description;
  final double confidence;
  final DateTime firstObserved;
  final DateTime lastObserved;
  final PatternSignificance significance;

  BiometricPattern({
    required this.patternId,
    required this.name,
    required this.type,
    required this.involvedMetrics,
    required this.description,
    required this.confidence,
    required this.firstObserved,
    required this.lastObserved,
    required this.significance,
  });

  /// Get pattern duration
  Duration get duration => lastObserved.difference(firstObserved);

  /// Check if pattern is recent
  bool get isRecent => DateTime.now().difference(lastObserved).inDays < 7;

  /// Check if pattern is consistent
  bool get isConsistent => confidence >= 0.7;

  factory BiometricPattern.fromJson(Map<String, dynamic> json) => 
      _$BiometricPatternFromJson(json);
  Map<String, dynamic> toJson() => _$BiometricPatternToJson(this);
}

/// Pattern Type
enum PatternType {
  cyclical('Cyclical', 'Repeating patterns over time'),
  seasonal('Seasonal', 'Patterns related to seasons'),
  lifestyle('Lifestyle', 'Patterns related to daily activities'),
  health('Health Event', 'Patterns around health events'),
  trend('Trend', 'Long-term trending patterns');

  const PatternType(this.displayName, this.description);

  final String displayName;
  final String description;
}

/// Pattern Significance
enum PatternSignificance {
  low('Low', 'Minor pattern of limited significance'),
  medium('Medium', 'Noteworthy pattern worth monitoring'),
  high('High', 'Significant pattern with health implications'),
  critical('Critical', 'Critical pattern requiring immediate attention');

  const PatternSignificance(this.displayName, this.description);

  final String displayName;
  final String description;
}
