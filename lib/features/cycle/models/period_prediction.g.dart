// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'period_prediction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PeriodPrediction _$PeriodPredictionFromJson(Map<String, dynamic> json) =>
    PeriodPrediction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      predictedStartDate: DateTime.parse(json['predictedStartDate'] as String),
      predictedEndDate: DateTime.parse(json['predictedEndDate'] as String),
      confidence: (json['confidence'] as num).toDouble(),
      predictedLength: (json['predictedLength'] as num).toInt(),
      predictedIntensity:
          $enumDecodeNullable(
            _$FlowIntensityEnumMap,
            json['predictedIntensity'],
          ) ??
          FlowIntensity.medium,
      predictedSymptoms:
          (json['predictedSymptoms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      actualStartDate: json['actualStartDate'] == null
          ? null
          : DateTime.parse(json['actualStartDate'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$PeriodPredictionToJson(
  PeriodPrediction instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'predictedStartDate': instance.predictedStartDate.toIso8601String(),
  'predictedEndDate': instance.predictedEndDate.toIso8601String(),
  'confidence': instance.confidence,
  'predictedLength': instance.predictedLength,
  'predictedIntensity': _$FlowIntensityEnumMap[instance.predictedIntensity]!,
  'predictedSymptoms': instance.predictedSymptoms,
  'createdAt': instance.createdAt.toIso8601String(),
  'actualStartDate': instance.actualStartDate?.toIso8601String(),
  'metadata': instance.metadata,
};

const _$FlowIntensityEnumMap = {
  FlowIntensity.none: 'none',
  FlowIntensity.spotting: 'spotting',
  FlowIntensity.light: 'light',
  FlowIntensity.medium: 'medium',
  FlowIntensity.heavy: 'heavy',
  FlowIntensity.veryHeavy: 'veryHeavy',
};
