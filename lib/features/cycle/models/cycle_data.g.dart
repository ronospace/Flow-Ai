// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cycle_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CycleData _$CycleDataFromJson(Map<String, dynamic> json) => CycleData(
  id: json['id'] as String,
  userId: json['userId'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  length: (json['length'] as num).toInt(),
  dailyData: (json['dailyData'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      DateTime.parse(k),
      DailyData.fromJson(e as Map<String, dynamic>),
    ),
  ),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$CycleDataToJson(CycleData instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'length': instance.length,
  'dailyData': instance.dailyData.map(
    (k, e) => MapEntry(k.toIso8601String(), e),
  ),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

DailyData _$DailyDataFromJson(Map<String, dynamic> json) => DailyData(
  date: DateTime.parse(json['date'] as String),
  flowIntensity: $enumDecodeNullable(
    _$FlowIntensityEnumMap,
    json['flowIntensity'],
  ),
  symptoms:
      (json['symptoms'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  moodScore: (json['moodScore'] as num?)?.toInt(),
  energyLevel: (json['energyLevel'] as num?)?.toInt(),
  bodyTemperature: (json['bodyTemperature'] as num?)?.toDouble(),
  notes: json['notes'] as String?,
  additionalData: json['additionalData'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$DailyDataToJson(DailyData instance) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'flowIntensity': _$FlowIntensityEnumMap[instance.flowIntensity],
  'symptoms': instance.symptoms,
  'moodScore': instance.moodScore,
  'energyLevel': instance.energyLevel,
  'bodyTemperature': instance.bodyTemperature,
  'notes': instance.notes,
  'additionalData': instance.additionalData,
};

const _$FlowIntensityEnumMap = {
  FlowIntensity.none: 'none',
  FlowIntensity.spotting: 'spotting',
  FlowIntensity.light: 'light',
  FlowIntensity.medium: 'medium',
  FlowIntensity.heavy: 'heavy',
  FlowIntensity.veryHeavy: 'veryHeavy',
};

CycleSettings _$CycleSettingsFromJson(Map<String, dynamic> json) =>
    CycleSettings(
      averageCycleLength: (json['averageCycleLength'] as num?)?.toInt() ?? 28,
      averagePeriodLength: (json['averagePeriodLength'] as num?)?.toInt() ?? 5,
      enablePredictions: json['enablePredictions'] as bool? ?? true,
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      customSettings:
          json['customSettings'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$CycleSettingsToJson(CycleSettings instance) =>
    <String, dynamic>{
      'averageCycleLength': instance.averageCycleLength,
      'averagePeriodLength': instance.averagePeriodLength,
      'enablePredictions': instance.enablePredictions,
      'enableNotifications': instance.enableNotifications,
      'customSettings': instance.customSettings,
    };

CycleStatistics _$CycleStatisticsFromJson(Map<String, dynamic> json) =>
    CycleStatistics(
      averageCycleLength: (json['averageCycleLength'] as num).toDouble(),
      averagePeriodLength: (json['averagePeriodLength'] as num).toDouble(),
      cycleVariability: (json['cycleVariability'] as num).toDouble(),
      totalCycles: (json['totalCycles'] as num).toInt(),
      lastPeriodStart: json['lastPeriodStart'] == null
          ? null
          : DateTime.parse(json['lastPeriodStart'] as String),
      nextPredictedPeriod: json['nextPredictedPeriod'] == null
          ? null
          : DateTime.parse(json['nextPredictedPeriod'] as String),
      additionalStats:
          json['additionalStats'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$CycleStatisticsToJson(CycleStatistics instance) =>
    <String, dynamic>{
      'averageCycleLength': instance.averageCycleLength,
      'averagePeriodLength': instance.averagePeriodLength,
      'cycleVariability': instance.cycleVariability,
      'totalCycles': instance.totalCycles,
      'lastPeriodStart': instance.lastPeriodStart?.toIso8601String(),
      'nextPredictedPeriod': instance.nextPredictedPeriod?.toIso8601String(),
      'additionalStats': instance.additionalStats,
    };
