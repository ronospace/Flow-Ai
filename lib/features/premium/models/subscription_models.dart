import 'package:json_annotation/json_annotation.dart';

part 'subscription_models.g.dart';

/// Subscription tier levels
enum SubscriptionTier {
  free,
  premium,
  premiumPlus, // For future family/enterprise plans
}

/// Subscription status
enum SubscriptionStatus {
  active,
  expired,
  cancelled,
  grace_period, // Payment failed but still has access
  trial,
}

/// Subscription billing period
enum BillingPeriod {
  monthly,
  yearly,
  lifetime, // One-time purchase
}

/// Subscription product model
@JsonSerializable()
class SubscriptionProduct {
  final String id;
  final String name;
  final String description;
  final SubscriptionTier tier;
  final BillingPeriod billingPeriod;
  final double price;
  final String currency;
  final String priceString; // Formatted price like "$4.99"
  final List<String> features;
  final int? trialDays;
  final double? discount; // Percentage discount if applicable
  final bool isPopular; // For highlighting in UI

  const SubscriptionProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.tier,
    required this.billingPeriod,
    required this.price,
    required this.currency,
    required this.priceString,
    required this.features,
    this.trialDays,
    this.discount,
    this.isPopular = false,
  });

  factory SubscriptionProduct.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionProductFromJson(json);
  
  Map<String, dynamic> toJson() => _$SubscriptionProductToJson(this);

  /// Calculate savings compared to monthly
  double getSavingsPercentage(double monthlyPrice) {
    if (billingPeriod != BillingPeriod.yearly) return 0;
    final yearlyAsMonthly = price / 12;
    return ((monthlyPrice - yearlyAsMonthly) / monthlyPrice * 100);
  }

  /// Get price per month for display
  double getPricePerMonth() {
    switch (billingPeriod) {
      case BillingPeriod.monthly:
        return price;
      case BillingPeriod.yearly:
        return price / 12;
      case BillingPeriod.lifetime:
        return 0; // One-time
    }
  }
}

/// User's subscription information
@JsonSerializable()
class UserSubscription {
  final String userId;
  final SubscriptionTier tier;
  final SubscriptionStatus status;
  final String? productId;
  final BillingPeriod? billingPeriod;
  final DateTime? purchaseDate;
  final DateTime? expiryDate;
  final DateTime? cancelledDate;
  final bool autoRenew;
  final String? transactionId;
  final String? originalTransactionId;
  
  // Features access
  final int aiInsightsUsed;
  final int aiInsightsLimit;
  final bool hasUnlimitedInsights;
  final bool isAdFree;
  final bool canExportData;
  final bool hasAdvancedAnalytics;
  final bool hasPrioritySupport;

  const UserSubscription({
    required this.userId,
    required this.tier,
    required this.status,
    this.productId,
    this.billingPeriod,
    this.purchaseDate,
    this.expiryDate,
    this.cancelledDate,
    this.autoRenew = false,
    this.transactionId,
    this.originalTransactionId,
    this.aiInsightsUsed = 0,
    this.aiInsightsLimit = 5,
    this.hasUnlimitedInsights = false,
    this.isAdFree = false,
    this.canExportData = false,
    this.hasAdvancedAnalytics = false,
    this.hasPrioritySupport = false,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) =>
      _$UserSubscriptionFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserSubscriptionToJson(this);

  /// Create free tier subscription
  factory UserSubscription.free(String userId) {
    return UserSubscription(
      userId: userId,
      tier: SubscriptionTier.free,
      status: SubscriptionStatus.active,
      aiInsightsLimit: 5,
      hasUnlimitedInsights: false,
      isAdFree: false,
      canExportData: false,
      hasAdvancedAnalytics: false,
      hasPrioritySupport: false,
    );
  }

  /// Create premium subscription
  factory UserSubscription.premium({
    required String userId,
    required String productId,
    required BillingPeriod billingPeriod,
    required DateTime purchaseDate,
    required DateTime expiryDate,
    String? transactionId,
    String? originalTransactionId,
  }) {
    return UserSubscription(
      userId: userId,
      tier: SubscriptionTier.premium,
      status: SubscriptionStatus.active,
      productId: productId,
      billingPeriod: billingPeriod,
      purchaseDate: purchaseDate,
      expiryDate: expiryDate,
      autoRenew: true,
      transactionId: transactionId,
      originalTransactionId: originalTransactionId,
      hasUnlimitedInsights: true,
      isAdFree: true,
      canExportData: true,
      hasAdvancedAnalytics: true,
      hasPrioritySupport: true,
    );
  }

  /// Check if subscription is valid
  bool get isValid {
    if (tier == SubscriptionTier.free) return true;
    if (status != SubscriptionStatus.active && 
        status != SubscriptionStatus.trial &&
        status != SubscriptionStatus.grace_period) {
      return false;
    }
    if (expiryDate != null && DateTime.now().isAfter(expiryDate!)) {
      return false;
    }
    return true;
  }

  /// Check if user has premium access
  bool get isPremium => tier != SubscriptionTier.free && isValid;

  /// Days until expiry
  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  /// Check if subscription is about to expire (less than 7 days)
  bool get isExpiringSoon {
    final days = daysUntilExpiry;
    return days != null && days <= 7 && days > 0;
  }

  /// Check if user can access a feature
  bool canAccessFeature(PremiumFeature feature) {
    switch (feature) {
      case PremiumFeature.unlimitedInsights:
        return hasUnlimitedInsights;
      case PremiumFeature.adFree:
        return isAdFree;
      case PremiumFeature.dataExport:
        return canExportData;
      case PremiumFeature.advancedAnalytics:
        return hasAdvancedAnalytics;
      case PremiumFeature.prioritySupport:
        return hasPrioritySupport;
    }
  }

  /// Check if user has used up free insights
  bool get hasUsedFreeInsights => 
      tier == SubscriptionTier.free && aiInsightsUsed >= aiInsightsLimit;

  /// Copy with updated fields
  UserSubscription copyWith({
    SubscriptionTier? tier,
    SubscriptionStatus? status,
    String? productId,
    BillingPeriod? billingPeriod,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    DateTime? cancelledDate,
    bool? autoRenew,
    String? transactionId,
    String? originalTransactionId,
    int? aiInsightsUsed,
    int? aiInsightsLimit,
    bool? hasUnlimitedInsights,
    bool? isAdFree,
    bool? canExportData,
    bool? hasAdvancedAnalytics,
    bool? hasPrioritySupport,
  }) {
    return UserSubscription(
      userId: userId,
      tier: tier ?? this.tier,
      status: status ?? this.status,
      productId: productId ?? this.productId,
      billingPeriod: billingPeriod ?? this.billingPeriod,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
      cancelledDate: cancelledDate ?? this.cancelledDate,
      autoRenew: autoRenew ?? this.autoRenew,
      transactionId: transactionId ?? this.transactionId,
      originalTransactionId: originalTransactionId ?? this.originalTransactionId,
      aiInsightsUsed: aiInsightsUsed ?? this.aiInsightsUsed,
      aiInsightsLimit: aiInsightsLimit ?? this.aiInsightsLimit,
      hasUnlimitedInsights: hasUnlimitedInsights ?? this.hasUnlimitedInsights,
      isAdFree: isAdFree ?? this.isAdFree,
      canExportData: canExportData ?? this.canExportData,
      hasAdvancedAnalytics: hasAdvancedAnalytics ?? this.hasAdvancedAnalytics,
      hasPrioritySupport: hasPrioritySupport ?? this.hasPrioritySupport,
    );
  }
}

/// Premium features that can be gated
enum PremiumFeature {
  unlimitedInsights,
  adFree,
  dataExport,
  advancedAnalytics,
  prioritySupport,
}

/// Purchase result
class PurchaseResult {
  final bool success;
  final UserSubscription? subscription;
  final String? errorMessage;
  final PurchaseError? error;

  const PurchaseResult({
    required this.success,
    this.subscription,
    this.errorMessage,
    this.error,
  });

  factory PurchaseResult.success(UserSubscription subscription) {
    return PurchaseResult(
      success: true,
      subscription: subscription,
    );
  }

  factory PurchaseResult.failure(String message, [PurchaseError? error]) {
    return PurchaseResult(
      success: false,
      errorMessage: message,
      error: error,
    );
  }
}

/// Purchase error types
enum PurchaseError {
  cancelled,
  networkError,
  paymentFailed,
  productNotAvailable,
  alreadyPurchased,
  unknown,
}
