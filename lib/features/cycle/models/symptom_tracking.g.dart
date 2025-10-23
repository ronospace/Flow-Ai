// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'symptom_tracking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SymptomEntry _$SymptomEntryFromJson(Map<String, dynamic> json) => SymptomEntry(
  symptomName: json['symptomName'] as String,
  type: $enumDecode(_$SymptomTypeEnumMap, json['type']),
  intensity: $enumDecode(_$SymptomIntensityEnumMap, json['intensity']),
  notes: json['notes'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$SymptomEntryToJson(SymptomEntry instance) =>
    <String, dynamic>{
      'symptomName': instance.symptomName,
      'type': _$SymptomTypeEnumMap[instance.type]!,
      'intensity': _$SymptomIntensityEnumMap[instance.intensity]!,
      'notes': instance.notes,
      'timestamp': instance.timestamp.toIso8601String(),
    };

const _$SymptomTypeEnumMap = {
  SymptomType.physical: 'physical',
  SymptomType.emotional: 'emotional',
  SymptomType.mental: 'mental',
  SymptomType.energy: 'energy',
  SymptomType.sleep: 'sleep',
  SymptomType.appetite: 'appetite',
  SymptomType.pain: 'pain',
  SymptomType.skin: 'skin',
  SymptomType.digestive: 'digestive',
  SymptomType.other: 'other',
};

const _$SymptomIntensityEnumMap = {
  SymptomIntensity.none: 'none',
  SymptomIntensity.mild: 'mild',
  SymptomIntensity.moderate: 'moderate',
  SymptomIntensity.severe: 'severe',
  SymptomIntensity.extreme: 'extreme',
};

SymptomTracking _$SymptomTrackingFromJson(
  Map<String, dynamic> json,
) => SymptomTracking(
  id: json['id'] as String,
  userId: json['userId'] as String,
  date: DateTime.parse(json['date'] as String),
  symptoms: (json['symptoms'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, SymptomEntry.fromJson(e as Map<String, dynamic>)),
  ),
  moodScores: (json['moodScores'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry($enumDecode(_$MoodCategoryEnumMap, k), (e as num).toDouble()),
  ),
  energyLevels: (json['energyLevels'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry($enumDecode(_$EnergyTypeEnumMap, k), (e as num).toDouble()),
  ),
  overallWellbeing: (json['overallWellbeing'] as num?)?.toDouble(),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$SymptomTrackingToJson(SymptomTracking instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'date': instance.date.toIso8601String(),
      'symptoms': instance.symptoms,
      'moodScores': instance.moodScores.map(
        (k, e) => MapEntry(_$MoodCategoryEnumMap[k]!, e),
      ),
      'energyLevels': instance.energyLevels.map(
        (k, e) => MapEntry(_$EnergyTypeEnumMap[k]!, e),
      ),
      'overallWellbeing': instance.overallWellbeing,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$MoodCategoryEnumMap = {
  MoodCategory.happy: 'happy',
  MoodCategory.sad: 'sad',
  MoodCategory.anxious: 'anxious',
  MoodCategory.irritable: 'irritable',
  MoodCategory.calm: 'calm',
  MoodCategory.energetic: 'energetic',
  MoodCategory.tired: 'tired',
  MoodCategory.confident: 'confident',
  MoodCategory.emotional: 'emotional',
  MoodCategory.neutral: 'neutral',
};

const _$EnergyTypeEnumMap = {
  EnergyType.physical: 'physical',
  EnergyType.mental: 'mental',
  EnergyType.emotional: 'emotional',
  EnergyType.overall: 'overall',
};
