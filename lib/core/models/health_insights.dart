/// Health insights models for preventive health analysis
class HealthInsight {
  final String insightId;
  final String userId;
  final DateTime generatedAt;
  final HealthInsightType type;
  final String title;
  final String description;
  final double confidenceLevel;
  final HealthInsightSeverity severity;
  final List<String> recommendations;
  final Map<String, dynamic> additionalData;

  HealthInsight({
    required this.insightId,
    required this.userId,
    required this.generatedAt,
    required this.type,
    required this.title,
    required this.description,
    required this.confidenceLevel,
    required this.severity,
    required this.recommendations,
    required this.additionalData,
  });
}

enum HealthInsightType {
  pcosRisk,
  thyroidDysfunction,
  endometriosisRisk,
  fertilityOptimization,
  hormonalImbalance,
  cycleIrregularity,
  symptomPattern,
  lifestyleRecommendation,
  preventiveCare
}

enum HealthInsightSeverity {
  info,
  low,
  moderate,
  high,
  critical
}

class MedicalRiskAssessment {
  final String conditionName;
  final double riskScore; // 0-1 scale
  final RiskLevel riskLevel;
  final Map<String, double> contributingFactors;
  final List<String> detectedSymptoms;
  final List<String> recommendations;
  final bool requiresMedicalAttention;
  final DateTime nextAssessmentDate;
  final double confidenceLevel;

  MedicalRiskAssessment({
    required this.conditionName,
    required this.riskScore,
    required this.riskLevel,
    required this.contributingFactors,
    required this.detectedSymptoms,
    required this.recommendations,
    required this.requiresMedicalAttention,
    required this.nextAssessmentDate,
    required this.confidenceLevel,
  });
}

enum RiskLevel {
  minimal,
  low,
  moderate,
  high,
  critical
}

class FertilityInsight {
  final double fertilityScore; // 0-1 scale
  final FertilityStatus status;
  final List<String> optimizationRecommendations;
  final Map<String, dynamic> fertilityFactors;
  final DateTime nextOptimalWindow;
  final double confidenceLevel;

  FertilityInsight({
    required this.fertilityScore,
    required this.status,
    required this.optimizationRecommendations,
    required this.fertilityFactors,
    required this.nextOptimalWindow,
    required this.confidenceLevel,
  });
}

enum FertilityStatus {
  optimal,
  good,
  concernsDetected,
  requiresAttention
}

class HormonalAnalysis {
  final Map<String, HormoneLevel> hormoneLevels;
  final List<String> imbalanceIndicators;
  final HormonalPhase currentPhase;
  final double hormonalHealthScore; // 0-1 scale
  final List<String> balancingRecommendations;

  HormonalAnalysis({
    required this.hormoneLevels,
    required this.imbalanceIndicators,
    required this.currentPhase,
    required this.hormonalHealthScore,
    required this.balancingRecommendations,
  });
}

class HormoneLevel {
  final String hormoneName;
  final double estimatedLevel; // Relative scale
  final HormoneLevelStatus status;
  final double confidence;

  HormoneLevel({
    required this.hormoneName,
    required this.estimatedLevel,
    required this.status,
    required this.confidence,
  });
}

enum HormoneLevelStatus {
  low,
  normal,
  elevated,
  fluctuating
}

enum HormonalPhase {
  menstrual,
  follicular,
  ovulatory,
  luteal
}

class SymptomPatternInsight {
  final String patternType;
  final Map<String, double> symptomFrequency;
  final List<String> correlatedSymptoms;
  final Map<String, dynamic> patterns;
  final List<String> managementSuggestions;
  final double patternStrength;

  SymptomPatternInsight({
    required this.patternType,
    required this.symptomFrequency,
    required this.correlatedSymptoms,
    required this.patterns,
    required this.managementSuggestions,
    required this.patternStrength,
  });
}

class CycleQualityAssessment {
  final double regularityScore; // 0-1 scale
  final double symptomScore; // 0-1 scale  
  final double overallHealthScore; // 0-1 scale
  final CycleQualityStatus status;
  final List<String> strengthAreas;
  final List<String> improvementAreas;
  final List<String> actionRecommendations;

  CycleQualityAssessment({
    required this.regularityScore,
    required this.symptomScore,
    required this.overallHealthScore,
    required this.status,
    required this.strengthAreas,
    required this.improvementAreas,
    required this.actionRecommendations,
  });
}

enum CycleQualityStatus {
  excellent,
  good,
  fair,
  needsAttention
}

class LifestyleImpactAnalysis {
  final Map<String, double> lifestyleFactors;
  final List<String> positiveInfluences;
  final List<String> negativeInfluences;
  final List<String> optimizationOpportunities;
  final double overallLifestyleScore;

  LifestyleImpactAnalysis({
    required this.lifestyleFactors,
    required this.positiveInfluences,
    required this.negativeInfluences,
    required this.optimizationOpportunities,
    required this.overallLifestyleScore,
  });
}
