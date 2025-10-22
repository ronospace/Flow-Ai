// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subscription _$SubscriptionFromJson(Map<String, dynamic> json) => Subscription(
      id: json['id'] as String,
      userId: json['userId'] as String,
      tier: $enumDecode(_$SubscriptionTierEnumMap, json['tier']),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      paymentMethod: $enumDecode(_$PaymentMethodEnumMap, json['paymentMethod']),
      status: $enumDecode(_$SubscriptionStatusEnumMap, json['status']),
      autoRenew: json['autoRenew'] as bool,
      cancelledAt: json['cancelledAt'] == null
          ? null
          : DateTime.parse(json['cancelledAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$SubscriptionToJson(Subscription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'tier': _$SubscriptionTierEnumMap[instance.tier]!,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod]!,
      'status': _$SubscriptionStatusEnumMap[instance.status]!,
      'autoRenew': instance.autoRenew,
      'cancelledAt': instance.cancelledAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$SubscriptionTierEnumMap = {
  SubscriptionTier.basic: 'basic',
  SubscriptionTier.premium: 'premium',
  SubscriptionTier.ultimate: 'ultimate',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.appStore: 'appStore',
  PaymentMethod.googlePlay: 'googlePlay',
  PaymentMethod.stripe: 'stripe',
  PaymentMethod.paypal: 'paypal',
};

const _$SubscriptionStatusEnumMap = {
  SubscriptionStatus.active: 'active',
  SubscriptionStatus.expired: 'expired',
  SubscriptionStatus.cancelled: 'cancelled',
  SubscriptionStatus.suspended: 'suspended',
  SubscriptionStatus.pending: 'pending',
};

SubscriptionAnalytics _$SubscriptionAnalyticsFromJson(
        Map<String, dynamic> json) =>
    SubscriptionAnalytics(
      subscriptionId: json['subscriptionId'] as String,
      totalDaysActive: json['totalDaysActive'] as int,
      featuresUsed: json['featuresUsed'] as int,
      reportsGenerated: json['reportsGenerated'] as int,
      exportsCompleted: json['exportsCompleted'] as int,
      providersConnected: json['providersConnected'] as int,
      lastActivity: DateTime.parse(json['lastActivity'] as String),
      featureUsageCount: Map<String, int>.from(json['featureUsageCount']),
      satisfactionRating: (json['satisfactionRating'] as num).toDouble(),
      feedback: json['feedback'] as String?,
    );

Map<String, dynamic> _$SubscriptionAnalyticsToJson(
        SubscriptionAnalytics instance) =>
    <String, dynamic>{
      'subscriptionId': instance.subscriptionId,
      'totalDaysActive': instance.totalDaysActive,
      'featuresUsed': instance.featuresUsed,
      'reportsGenerated': instance.reportsGenerated,
      'exportsCompleted': instance.exportsCompleted,
      'providersConnected': instance.providersConnected,
      'lastActivity': instance.lastActivity.toIso8601String(),
      'featureUsageCount': instance.featureUsageCount,
      'satisfactionRating': instance.satisfactionRating,
      'feedback': instance.feedback,
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
