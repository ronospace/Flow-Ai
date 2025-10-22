// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'premium_feature.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PremiumFeature _$PremiumFeatureFromJson(Map<String, dynamic> json) =>
    PremiumFeature(
      type: $enumDecode(_$PremiumFeatureTypeEnumMap, json['type']),
      name: json['name'] as String,
      description: json['description'] as String,
      tier: $enumDecode(_$SubscriptionTierEnumMap, json['tier']),
      isEnabled: json['isEnabled'] as bool? ?? true,
      enabledAt: json['enabledAt'] == null
          ? null
          : DateTime.parse(json['enabledAt'] as String),
      usageCount: json['usageCount'] as int? ?? 0,
      lastUsed: json['lastUsed'] == null
          ? null
          : DateTime.parse(json['lastUsed'] as String),
      settings: json['settings'] as Map<String, dynamic>? ?? const {},
      usageLimitPerMonth: (json['usageLimitPerMonth'] as num?)?.toDouble(),
      helpUrl: json['helpUrl'] as String?,
    );

Map<String, dynamic> _$PremiumFeatureToJson(PremiumFeature instance) =>
    <String, dynamic>{
      'type': _$PremiumFeatureTypeEnumMap[instance.type]!,
      'name': instance.name,
      'description': instance.description,
      'tier': _$SubscriptionTierEnumMap[instance.tier]!,
      'isEnabled': instance.isEnabled,
      'enabledAt': instance.enabledAt?.toIso8601String(),
      'usageCount': instance.usageCount,
      'lastUsed': instance.lastUsed?.toIso8601String(),
      'settings': instance.settings,
      'usageLimitPerMonth': instance.usageLimitPerMonth,
      'helpUrl': instance.helpUrl,
    };

const _$PremiumFeatureTypeEnumMap = {
  PremiumFeatureType.basicTracking: 'basicTracking',
  PremiumFeatureType.basicPredictions: 'basicPredictions',
  PremiumFeatureType.limitedExports: 'limitedExports',
  PremiumFeatureType.unlimitedExports: 'unlimitedExports',
  PremiumFeatureType.customReports: 'customReports',
  PremiumFeatureType.advancedAI: 'advancedAI',
  PremiumFeatureType.healthcareIntegration: 'healthcareIntegration',
  PremiumFeatureType.prioritySupport: 'prioritySupport',
  PremiumFeatureType.biometricSync: 'biometricSync',
  PremiumFeatureType.multiUserProfiles: 'multiUserProfiles',
  PremiumFeatureType.advancedAnalytics: 'advancedAnalytics',
};

const _$SubscriptionTierEnumMap = {
  SubscriptionTier.basic: 'basic',
  SubscriptionTier.premium: 'premium',
  SubscriptionTier.ultimate: 'ultimate',
};

FeatureUsageAnalytics _$FeatureUsageAnalyticsFromJson(
        Map<String, dynamic> json) =>
    FeatureUsageAnalytics(
      featureType: $enumDecode(_$PremiumFeatureTypeEnumMap, json['featureType']),
      month: DateTime.parse(json['month'] as String),
      totalUsage: json['totalUsage'] as int,
      uniqueDaysUsed: json['uniqueDaysUsed'] as int,
      averageUsagePerDay: (json['averageUsagePerDay'] as num).toDouble(),
      usageDates: (json['usageDates'] as List<dynamic>)
          .map((e) => DateTime.parse(e as String))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$FeatureUsageAnalyticsToJson(
        FeatureUsageAnalytics instance) =>
    <String, dynamic>{
      'featureType': _$PremiumFeatureTypeEnumMap[instance.featureType]!,
      'month': instance.month.toIso8601String(),
      'totalUsage': instance.totalUsage,
      'uniqueDaysUsed': instance.uniqueDaysUsed,
      'averageUsagePerDay': instance.averageUsagePerDay,
      'usageDates': instance.usageDates.map((e) => e.toIso8601String()).toList(),
      'metadata': instance.metadata,
    };

K $enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}
