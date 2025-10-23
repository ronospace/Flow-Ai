// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biometric_insights.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BiometricInsights _$BiometricInsightsFromJson(
  Map<String, dynamic> json,
) => BiometricInsights(
  insightsId: json['insightsId'] as String,
  userId: json['userId'] as String,
  generatedDate: DateTime.parse(json['generatedDate'] as String),
  periodStart: DateTime.parse(json['periodStart'] as String),
  periodEnd: DateTime.parse(json['periodEnd'] as String),
  totalDataPoints: (json['totalDataPoints'] as num).toInt(),
  keyMetrics: (json['keyMetrics'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry($enumDecode(_$BiometricTypeEnumMap, k), (e as num).toDouble()),
  ),
  trends: (json['trends'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      $enumDecode(_$BiometricTypeEnumMap, k),
      $enumDecode(_$TrendDirectionEnumMap, e),
    ),
  ),
  anomalies: (json['anomalies'] as List<dynamic>)
      .map((e) => BiometricAnomaly.fromJson(e as Map<String, dynamic>))
      .toList(),
  correlations: (json['correlations'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  healthScore: (json['healthScore'] as num).toDouble(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => HealthRecommendation.fromJson(e as Map<String, dynamic>))
      .toList(),
  riskFactors: (json['riskFactors'] as List<dynamic>)
      .map((e) => RiskFactor.fromJson(e as Map<String, dynamic>))
      .toList(),
  summary: InsightsSummary.fromJson(json['summary'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BiometricInsightsToJson(BiometricInsights instance) =>
    <String, dynamic>{
      'insightsId': instance.insightsId,
      'userId': instance.userId,
      'generatedDate': instance.generatedDate.toIso8601String(),
      'periodStart': instance.periodStart.toIso8601String(),
      'periodEnd': instance.periodEnd.toIso8601String(),
      'totalDataPoints': instance.totalDataPoints,
      'keyMetrics': instance.keyMetrics.map(
        (k, e) => MapEntry(_$BiometricTypeEnumMap[k]!, e),
      ),
      'trends': instance.trends.map(
        (k, e) =>
            MapEntry(_$BiometricTypeEnumMap[k]!, _$TrendDirectionEnumMap[e]!),
      ),
      'anomalies': instance.anomalies,
      'correlations': instance.correlations,
      'healthScore': instance.healthScore,
      'recommendations': instance.recommendations,
      'riskFactors': instance.riskFactors,
      'summary': instance.summary,
    };

const _$BiometricTypeEnumMap = {
  BiometricType.heartRate: 'heartRate',
  BiometricType.restingHeartRate: 'restingHeartRate',
  BiometricType.heartRateVariability: 'heartRateVariability',
  BiometricType.bloodPressureSystolic: 'bloodPressureSystolic',
  BiometricType.bloodPressureDiastolic: 'bloodPressureDiastolic',
  BiometricType.bloodOxygen: 'bloodOxygen',
  BiometricType.steps: 'steps',
  BiometricType.distance: 'distance',
  BiometricType.activeCalories: 'activeCalories',
  BiometricType.totalCalories: 'totalCalories',
  BiometricType.activeMinutes: 'activeMinutes',
  BiometricType.exerciseMinutes: 'exerciseMinutes',
  BiometricType.weight: 'weight',
  BiometricType.bodyFat: 'bodyFat',
  BiometricType.muscleMass: 'muscleMass',
  BiometricType.boneDensity: 'boneDensity',
  BiometricType.waterPercentage: 'waterPercentage',
  BiometricType.bodyTemperature: 'bodyTemperature',
  BiometricType.skinTemperature: 'skinTemperature',
  BiometricType.basalBodyTemperature: 'basalBodyTemperature',
  BiometricType.sleep: 'sleep',
  BiometricType.sleepQuality: 'sleepQuality',
  BiometricType.deepSleep: 'deepSleep',
  BiometricType.remSleep: 'remSleep',
  BiometricType.sleepEfficiency: 'sleepEfficiency',
  BiometricType.stressLevel: 'stressLevel',
  BiometricType.mentalWellbeing: 'mentalWellbeing',
  BiometricType.mindfulnessMinutes: 'mindfulnessMinutes',
  BiometricType.respiratoryRate: 'respiratoryRate',
  BiometricType.vo2Max: 'vo2Max',
  BiometricType.menstrualFlow: 'menstrualFlow',
  BiometricType.ovulationTest: 'ovulationTest',
  BiometricType.cervicalMucus: 'cervicalMucus',
  BiometricType.activity: 'activity',
  BiometricType.readiness: 'readiness',
  BiometricType.recovery: 'recovery',
  BiometricType.energy: 'energy',
};

const _$TrendDirectionEnumMap = {
  TrendDirection.decreasing: 'decreasing',
  TrendDirection.stable: 'stable',
  TrendDirection.increasing: 'increasing',
};

BiometricAnomaly _$BiometricAnomalyFromJson(Map<String, dynamic> json) =>
    BiometricAnomaly(
      anomalyId: json['anomalyId'] as String,
      type: $enumDecode(_$BiometricTypeEnumMap, json['type']),
      value: (json['value'] as num).toDouble(),
      expectedRange: Range.fromJson(
        json['expectedRange'] as Map<String, dynamic>,
      ),
      severity: $enumDecode(_$AnomalySeverityEnumMap, json['severity']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      description: json['description'] as String,
      possibleCauses:
          (json['possibleCauses'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      recommendations:
          (json['recommendations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$BiometricAnomalyToJson(BiometricAnomaly instance) =>
    <String, dynamic>{
      'anomalyId': instance.anomalyId,
      'type': _$BiometricTypeEnumMap[instance.type]!,
      'value': instance.value,
      'expectedRange': instance.expectedRange,
      'severity': _$AnomalySeverityEnumMap[instance.severity]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'description': instance.description,
      'possibleCauses': instance.possibleCauses,
      'recommendations': instance.recommendations,
    };

const _$AnomalySeverityEnumMap = {
  AnomalySeverity.low: 'low',
  AnomalySeverity.medium: 'medium',
  AnomalySeverity.high: 'high',
};

Range _$RangeFromJson(Map<String, dynamic> json) =>
    Range((json['min'] as num).toDouble(), (json['max'] as num).toDouble());

Map<String, dynamic> _$RangeToJson(Range instance) => <String, dynamic>{
  'min': instance.min,
  'max': instance.max,
};

HealthRecommendation _$HealthRecommendationFromJson(
  Map<String, dynamic> json,
) => HealthRecommendation(
  recommendationId: json['recommendationId'] as String,
  type: $enumDecode(_$RecommendationTypeEnumMap, json['type']),
  title: json['title'] as String,
  description: json['description'] as String,
  priority: $enumDecode(_$RecommendationPriorityEnumMap, json['priority']),
  actionItems:
      (json['actionItems'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  targetMetric: json['targetMetric'] as String?,
  targetValue: (json['targetValue'] as num?)?.toDouble(),
  timeFrame: json['timeFrame'] == null
      ? null
      : Duration(microseconds: (json['timeFrame'] as num).toInt()),
  resources:
      (json['resources'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$HealthRecommendationToJson(
  HealthRecommendation instance,
) => <String, dynamic>{
  'recommendationId': instance.recommendationId,
  'type': _$RecommendationTypeEnumMap[instance.type]!,
  'title': instance.title,
  'description': instance.description,
  'priority': _$RecommendationPriorityEnumMap[instance.priority]!,
  'actionItems': instance.actionItems,
  'targetMetric': instance.targetMetric,
  'targetValue': instance.targetValue,
  'timeFrame': instance.timeFrame?.inMicroseconds,
  'resources': instance.resources,
};

const _$RecommendationTypeEnumMap = {
  RecommendationType.lifestyle: 'lifestyle',
  RecommendationType.activity: 'activity',
  RecommendationType.nutrition: 'nutrition',
  RecommendationType.sleep: 'sleep',
  RecommendationType.stress: 'stress',
  RecommendationType.medical: 'medical',
  RecommendationType.monitoring: 'monitoring',
};

const _$RecommendationPriorityEnumMap = {
  RecommendationPriority.low: 'low',
  RecommendationPriority.medium: 'medium',
  RecommendationPriority.high: 'high',
  RecommendationPriority.critical: 'critical',
};

RiskFactor _$RiskFactorFromJson(Map<String, dynamic> json) => RiskFactor(
  factorId: json['factorId'] as String,
  name: json['name'] as String,
  riskLevel: $enumDecode(_$RiskLevelEnumMap, json['riskLevel']),
  description: json['description'] as String,
  relatedMetrics: (json['relatedMetrics'] as List<dynamic>)
      .map((e) => $enumDecode(_$BiometricTypeEnumMap, e))
      .toList(),
  riskScore: (json['riskScore'] as num).toDouble(),
  mitigationStrategies:
      (json['mitigationStrategies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  identifiedDate: DateTime.parse(json['identifiedDate'] as String),
);

Map<String, dynamic> _$RiskFactorToJson(RiskFactor instance) =>
    <String, dynamic>{
      'factorId': instance.factorId,
      'name': instance.name,
      'riskLevel': _$RiskLevelEnumMap[instance.riskLevel]!,
      'description': instance.description,
      'relatedMetrics': instance.relatedMetrics
          .map((e) => _$BiometricTypeEnumMap[e]!)
          .toList(),
      'riskScore': instance.riskScore,
      'mitigationStrategies': instance.mitigationStrategies,
      'identifiedDate': instance.identifiedDate.toIso8601String(),
    };

const _$RiskLevelEnumMap = {
  RiskLevel.low: 'low',
  RiskLevel.medium: 'medium',
  RiskLevel.high: 'high',
  RiskLevel.critical: 'critical',
};

InsightsSummary _$InsightsSummaryFromJson(Map<String, dynamic> json) =>
    InsightsSummary(
      overallAssessment: json['overallAssessment'] as String,
      keyFindings: (json['keyFindings'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      improvements:
          (json['improvements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      concerns:
          (json['concerns'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      nextSteps: json['nextSteps'] as String,
      category: $enumDecode(_$InsightsCategoryEnumMap, json['category']),
    );

Map<String, dynamic> _$InsightsSummaryToJson(InsightsSummary instance) =>
    <String, dynamic>{
      'overallAssessment': instance.overallAssessment,
      'keyFindings': instance.keyFindings,
      'improvements': instance.improvements,
      'concerns': instance.concerns,
      'nextSteps': instance.nextSteps,
      'category': _$InsightsCategoryEnumMap[instance.category]!,
    };

const _$InsightsCategoryEnumMap = {
  InsightsCategory.excellent: 'excellent',
  InsightsCategory.good: 'good',
  InsightsCategory.fair: 'fair',
  InsightsCategory.poor: 'poor',
  InsightsCategory.insufficient: 'insufficient',
};

BiometricPattern _$BiometricPatternFromJson(Map<String, dynamic> json) =>
    BiometricPattern(
      patternId: json['patternId'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$PatternTypeEnumMap, json['type']),
      involvedMetrics: (json['involvedMetrics'] as List<dynamic>)
          .map((e) => $enumDecode(_$BiometricTypeEnumMap, e))
          .toList(),
      description: json['description'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      firstObserved: DateTime.parse(json['firstObserved'] as String),
      lastObserved: DateTime.parse(json['lastObserved'] as String),
      significance: $enumDecode(
        _$PatternSignificanceEnumMap,
        json['significance'],
      ),
    );

Map<String, dynamic> _$BiometricPatternToJson(BiometricPattern instance) =>
    <String, dynamic>{
      'patternId': instance.patternId,
      'name': instance.name,
      'type': _$PatternTypeEnumMap[instance.type]!,
      'involvedMetrics': instance.involvedMetrics
          .map((e) => _$BiometricTypeEnumMap[e]!)
          .toList(),
      'description': instance.description,
      'confidence': instance.confidence,
      'firstObserved': instance.firstObserved.toIso8601String(),
      'lastObserved': instance.lastObserved.toIso8601String(),
      'significance': _$PatternSignificanceEnumMap[instance.significance]!,
    };

const _$PatternTypeEnumMap = {
  PatternType.cyclical: 'cyclical',
  PatternType.seasonal: 'seasonal',
  PatternType.lifestyle: 'lifestyle',
  PatternType.health: 'health',
  PatternType.trend: 'trend',
};

const _$PatternSignificanceEnumMap = {
  PatternSignificance.low: 'low',
  PatternSignificance.medium: 'medium',
  PatternSignificance.high: 'high',
  PatternSignificance.critical: 'critical',
};
