// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biometric_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BiometricData _$BiometricDataFromJson(Map<String, dynamic> json) =>
    BiometricData(
      dataId: json['dataId'] as String,
      type: $enumDecode(_$BiometricTypeEnumMap, json['type']),
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      source: json['source'] as String,
      deviceId: json['deviceId'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      quality:
          $enumDecodeNullable(_$DataQualityEnumMap, json['quality']) ??
          DataQuality.good,
      isProcessed: json['isProcessed'] as bool? ?? false,
    );

Map<String, dynamic> _$BiometricDataToJson(BiometricData instance) =>
    <String, dynamic>{
      'dataId': instance.dataId,
      'type': _$BiometricTypeEnumMap[instance.type]!,
      'value': instance.value,
      'unit': instance.unit,
      'timestamp': instance.timestamp.toIso8601String(),
      'source': instance.source,
      'deviceId': instance.deviceId,
      'confidence': instance.confidence,
      'metadata': instance.metadata,
      'quality': _$DataQualityEnumMap[instance.quality]!,
      'isProcessed': instance.isProcessed,
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

const _$DataQualityEnumMap = {
  DataQuality.excellent: 'excellent',
  DataQuality.good: 'good',
  DataQuality.fair: 'fair',
  DataQuality.poor: 'poor',
};

BiometricDataCollection _$BiometricDataCollectionFromJson(
  Map<String, dynamic> json,
) => BiometricDataCollection(
  collectionId: json['collectionId'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  dataPoints: (json['dataPoints'] as List<dynamic>)
      .map((e) => BiometricData.fromJson(e as Map<String, dynamic>))
      .toList(),
  source: json['source'] as String,
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$BiometricDataCollectionToJson(
  BiometricDataCollection instance,
) => <String, dynamic>{
  'collectionId': instance.collectionId,
  'timestamp': instance.timestamp.toIso8601String(),
  'dataPoints': instance.dataPoints,
  'source': instance.source,
  'metadata': instance.metadata,
};

BiometricDataSummary _$BiometricDataSummaryFromJson(
  Map<String, dynamic> json,
) => BiometricDataSummary(
  date: DateTime.parse(json['date'] as String),
  averageValues: (json['averageValues'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry($enumDecode(_$BiometricTypeEnumMap, k), (e as num).toDouble()),
  ),
  minValues: (json['minValues'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry($enumDecode(_$BiometricTypeEnumMap, k), (e as num).toDouble()),
  ),
  maxValues: (json['maxValues'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry($enumDecode(_$BiometricTypeEnumMap, k), (e as num).toDouble()),
  ),
  dataPointCounts: (json['dataPointCounts'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry($enumDecode(_$BiometricTypeEnumMap, k), (e as num).toInt()),
  ),
  overallHealthScore: (json['overallHealthScore'] as num).toDouble(),
);

Map<String, dynamic> _$BiometricDataSummaryToJson(
  BiometricDataSummary instance,
) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'averageValues': instance.averageValues.map(
    (k, e) => MapEntry(_$BiometricTypeEnumMap[k]!, e),
  ),
  'minValues': instance.minValues.map(
    (k, e) => MapEntry(_$BiometricTypeEnumMap[k]!, e),
  ),
  'maxValues': instance.maxValues.map(
    (k, e) => MapEntry(_$BiometricTypeEnumMap[k]!, e),
  ),
  'dataPointCounts': instance.dataPointCounts.map(
    (k, e) => MapEntry(_$BiometricTypeEnumMap[k]!, e),
  ),
  'overallHealthScore': instance.overallHealthScore,
};
