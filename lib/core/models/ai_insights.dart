import 'medical_citation.dart';

enum InsightType {
  cycleRegularity,
  symptomPattern,
  healthTrend,
  fertilityWindow,
  moodPattern,
  energyPattern,
  cyclePattern,
  predictionAccuracy,
  phaseAnalysis,
  correlationInsight,
  healthRecommendation,
  nutritionGuidance,
  sleepOptimization,
}

enum PatternType {
  regularity,
  irregularity,
  lengthVariation,
  symptomCluster,
}

enum ImpactLevel {
  low,
  medium,
  high,
  critical,
}

class AIInsight {
  final InsightType type;
  final String title;
  final String description;
  final double confidence; // 0-1
  final bool actionable;
  final List<String> recommendations;
  final String? recommendation; // Single recommendation for backward compatibility
  final DateTime generatedAt;
  final List<MedicalCitation> citations; // Medical sources for health information
  final String? citationCategory; // Category for automatic citation lookup

  AIInsight({
    required this.type,
    required this.title,
    required this.description,
    required this.confidence,
    this.actionable = false,
    this.recommendations = const [],
    this.recommendation,
    DateTime? generatedAt,
    this.citations = const [],
    this.citationCategory,
  }) : generatedAt = generatedAt ?? DateTime.now();
  
  /// Get all applicable citations including auto-loaded from category
  List<MedicalCitation> get allCitations {
    final List<MedicalCitation> allCites = List.from(citations);
    if (citationCategory != null) {
      allCites.addAll(
        MedicalCitationsDatabase.getCitationsForInsightType(citationCategory!)
      );
    }
    return allCites;
  }
}

class PatternDetection {
  final PatternType type;
  final String description;
  final double confidence;
  final ImpactLevel impact;
  final DateTime detectedAt;

  PatternDetection({
    required this.type,
    required this.description,
    required this.confidence,
    required this.impact,
    DateTime? detectedAt,
  }) : detectedAt = detectedAt ?? DateTime.now();
}

// Extension for easier access
extension InsightTypeExtensions on InsightType {
  String get displayName {
    switch (this) {
      case InsightType.cycleRegularity:
        return 'Cycle Regularity';
      case InsightType.symptomPattern:
        return 'Symptom Pattern';
      case InsightType.healthTrend:
        return 'Health Trend';
      case InsightType.fertilityWindow:
        return 'Fertility Window';
      case InsightType.moodPattern:
        return 'Mood Pattern';
      case InsightType.energyPattern:
        return 'Energy Pattern';
      case InsightType.cyclePattern:
        return 'Cycle Pattern';
      case InsightType.predictionAccuracy:
        return 'Prediction Accuracy';
      case InsightType.phaseAnalysis:
        return 'Phase Analysis';
      case InsightType.correlationInsight:
        return 'Correlation Insight';
      case InsightType.healthRecommendation:
        return 'Health Recommendation';
      case InsightType.nutritionGuidance:
        return 'Nutrition Guidance';
      case InsightType.sleepOptimization:
        return 'Sleep Optimization';
    }
  }

  String get emoji {
    switch (this) {
      case InsightType.cycleRegularity:
        return '📊';
      case InsightType.symptomPattern:
        return '🔍';
      case InsightType.healthTrend:
        return '📈';
      case InsightType.fertilityWindow:
        return '🌸';
      case InsightType.moodPattern:
        return '😊';
      case InsightType.energyPattern:
        return '⚡';
      case InsightType.cyclePattern:
        return '🔄';
      case InsightType.predictionAccuracy:
        return '🎯';
      case InsightType.phaseAnalysis:
        return '🌙';
      case InsightType.correlationInsight:
        return '🔗';
      case InsightType.healthRecommendation:
        return '💪';
      case InsightType.nutritionGuidance:
        return '🥗';
      case InsightType.sleepOptimization:
        return '😴';
    }
  }
}
