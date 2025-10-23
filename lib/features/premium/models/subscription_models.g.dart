// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionProduct _$SubscriptionProductFromJson(Map<String, dynamic> json) =>
    SubscriptionProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      tier: $enumDecode(_$SubscriptionTierEnumMap, json['tier']),
      billingPeriod: $enumDecode(_$BillingPeriodEnumMap, json['billingPeriod']),
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      priceString: json['priceString'] as String,
      features: (json['features'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      trialDays: (json['trialDays'] as num?)?.toInt(),
      discount: (json['discount'] as num?)?.toDouble(),
      isPopular: json['isPopular'] as bool? ?? false,
    );

Map<String, dynamic> _$SubscriptionProductToJson(
  SubscriptionProduct instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'tier': _$SubscriptionTierEnumMap[instance.tier]!,
  'billingPeriod': _$BillingPeriodEnumMap[instance.billingPeriod]!,
  'price': instance.price,
  'currency': instance.currency,
  'priceString': instance.priceString,
  'features': instance.features,
  'trialDays': instance.trialDays,
  'discount': instance.discount,
  'isPopular': instance.isPopular,
};

const _$SubscriptionTierEnumMap = {
  SubscriptionTier.free: 'free',
  SubscriptionTier.premium: 'premium',
  SubscriptionTier.premiumPlus: 'premiumPlus',
};

const _$BillingPeriodEnumMap = {
  BillingPeriod.monthly: 'monthly',
  BillingPeriod.yearly: 'yearly',
  BillingPeriod.lifetime: 'lifetime',
};

UserSubscription _$UserSubscriptionFromJson(Map<String, dynamic> json) =>
    UserSubscription(
      userId: json['userId'] as String,
      tier: $enumDecode(_$SubscriptionTierEnumMap, json['tier']),
      status: $enumDecode(_$SubscriptionStatusEnumMap, json['status']),
      productId: json['productId'] as String?,
      billingPeriod: $enumDecodeNullable(
        _$BillingPeriodEnumMap,
        json['billingPeriod'],
      ),
      purchaseDate: json['purchaseDate'] == null
          ? null
          : DateTime.parse(json['purchaseDate'] as String),
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate'] as String),
      cancelledDate: json['cancelledDate'] == null
          ? null
          : DateTime.parse(json['cancelledDate'] as String),
      autoRenew: json['autoRenew'] as bool? ?? false,
      transactionId: json['transactionId'] as String?,
      originalTransactionId: json['originalTransactionId'] as String?,
      aiInsightsUsed: (json['aiInsightsUsed'] as num?)?.toInt() ?? 0,
      aiInsightsLimit: (json['aiInsightsLimit'] as num?)?.toInt() ?? 5,
      hasUnlimitedInsights: json['hasUnlimitedInsights'] as bool? ?? false,
      isAdFree: json['isAdFree'] as bool? ?? false,
      canExportData: json['canExportData'] as bool? ?? false,
      hasAdvancedAnalytics: json['hasAdvancedAnalytics'] as bool? ?? false,
      hasPrioritySupport: json['hasPrioritySupport'] as bool? ?? false,
    );

Map<String, dynamic> _$UserSubscriptionToJson(UserSubscription instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'tier': _$SubscriptionTierEnumMap[instance.tier]!,
      'status': _$SubscriptionStatusEnumMap[instance.status]!,
      'productId': instance.productId,
      'billingPeriod': _$BillingPeriodEnumMap[instance.billingPeriod],
      'purchaseDate': instance.purchaseDate?.toIso8601String(),
      'expiryDate': instance.expiryDate?.toIso8601String(),
      'cancelledDate': instance.cancelledDate?.toIso8601String(),
      'autoRenew': instance.autoRenew,
      'transactionId': instance.transactionId,
      'originalTransactionId': instance.originalTransactionId,
      'aiInsightsUsed': instance.aiInsightsUsed,
      'aiInsightsLimit': instance.aiInsightsLimit,
      'hasUnlimitedInsights': instance.hasUnlimitedInsights,
      'isAdFree': instance.isAdFree,
      'canExportData': instance.canExportData,
      'hasAdvancedAnalytics': instance.hasAdvancedAnalytics,
      'hasPrioritySupport': instance.hasPrioritySupport,
    };

const _$SubscriptionStatusEnumMap = {
  SubscriptionStatus.active: 'active',
  SubscriptionStatus.expired: 'expired',
  SubscriptionStatus.cancelled: 'cancelled',
  SubscriptionStatus.grace_period: 'grace_period',
  SubscriptionStatus.trial: 'trial',
};
