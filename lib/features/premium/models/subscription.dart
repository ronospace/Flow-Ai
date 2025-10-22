import 'package:json_annotation/json_annotation.dart';

part 'subscription.g.dart';

/// Subscription tiers available in the app
enum SubscriptionTier {
  basic('Basic', 4.99),
  premium('Premium', 9.99),
  ultimate('Ultimate', 19.99);

  const SubscriptionTier(this.displayName, this.price);

  final String displayName;
  final double price;

  /// Get monthly price string
  String get priceString => '\$${price.toStringAsFixed(2)}/month';

  /// Get features available for this tier
  String get featuresDescription {
    switch (this) {
      case SubscriptionTier.basic:
        return 'Unlimited exports, custom reports, enhanced tracking';
      case SubscriptionTier.premium:
        return 'Advanced AI, healthcare integration, biometric sync, priority support';
      case SubscriptionTier.ultimate:
        return 'All premium features plus advanced analytics, multi-user profiles';
    }
  }
}

/// Subscription status
enum SubscriptionStatus {
  active,
  expired,
  cancelled,
  suspended,
  pending;

  /// Check if subscription allows premium features
  bool get allowsPremiumFeatures => this == SubscriptionStatus.active;
}

/// Payment methods available
enum PaymentMethod {
  appStore('App Store'),
  googlePlay('Google Play'),
  stripe('Credit Card'),
  paypal('PayPal');

  const PaymentMethod(this.displayName);

  final String displayName;
}

/// User subscription information
@JsonSerializable()
class Subscription {
  final String id;
  final String userId;
  final SubscriptionTier tier;
  final DateTime startDate;
  final DateTime endDate;
  final PaymentMethod paymentMethod;
  final SubscriptionStatus status;
  final bool autoRenew;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const Subscription({
    required this.id,
    required this.userId,
    required this.tier,
    required this.startDate,
    required this.endDate,
    required this.paymentMethod,
    required this.status,
    required this.autoRenew,
    this.cancelledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.metadata = const {},
  }) : createdAt = createdAt ?? startDate,
       updatedAt = updatedAt ?? startDate;

  /// Check if subscription is currently active
  bool get isActive => status == SubscriptionStatus.active && !isExpired;

  /// Check if subscription has expired
  bool get isExpired => DateTime.now().isAfter(endDate);

  /// Check if subscription should auto-renew
  bool get shouldAutoRenew => autoRenew && status == SubscriptionStatus.active;

  /// Get remaining days in subscription
  int get remainingDays {
    if (isExpired) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }

  /// Get subscription duration in days
  int get durationDays => endDate.difference(startDate).inDays;

  /// Check if subscription is cancelled but still active
  bool get isCancelledButActive => 
      status == SubscriptionStatus.cancelled && DateTime.now().isBefore(endDate);

  /// Get renewal date (same as end date for active subscriptions)
  DateTime get renewalDate => endDate;

  /// Create copy with updated fields
  Subscription copyWith({
    String? id,
    String? userId,
    SubscriptionTier? tier,
    DateTime? startDate,
    DateTime? endDate,
    PaymentMethod? paymentMethod,
    SubscriptionStatus? status,
    bool? autoRenew,
    DateTime? cancelledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tier: tier ?? this.tier,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      autoRenew: autoRenew ?? this.autoRenew,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$SubscriptionToJson(this);

  /// Create from JSON
  factory Subscription.fromJson(Map<String, dynamic> json) => 
      _$SubscriptionFromJson(json);

  /// Create a sample subscription for testing
  factory Subscription.sample({
    String? id,
    String? userId,
    SubscriptionTier? tier,
    SubscriptionStatus? status,
    bool? isExpired,
  }) {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 15));
    final endDate = isExpired == true 
        ? now.subtract(const Duration(days: 1))
        : now.add(const Duration(days: 15));

    return Subscription(
      id: id ?? 'sub_sample_${now.millisecondsSinceEpoch}',
      userId: userId ?? 'user_sample',
      tier: tier ?? SubscriptionTier.premium,
      startDate: startDate,
      endDate: endDate,
      paymentMethod: PaymentMethod.appStore,
      status: status ?? SubscriptionStatus.active,
      autoRenew: true,
      createdAt: startDate,
      updatedAt: now,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subscription &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Subscription{id: $id, tier: $tier, status: $status, '
           'remainingDays: $remainingDays, autoRenew: $autoRenew}';
  }
}

/// Subscription analytics data
@JsonSerializable()
class SubscriptionAnalytics {
  final String subscriptionId;
  final int totalDaysActive;
  final int featuresUsed;
  final int reportsGenerated;
  final int exportsCompleted;
  final int providersConnected;
  final DateTime lastActivity;
  final Map<String, int> featureUsageCount;
  final double satisfactionRating;
  final String? feedback;

  const SubscriptionAnalytics({
    required this.subscriptionId,
    required this.totalDaysActive,
    required this.featuresUsed,
    required this.reportsGenerated,
    required this.exportsCompleted,
    required this.providersConnected,
    required this.lastActivity,
    required this.featureUsageCount,
    required this.satisfactionRating,
    this.feedback,
  });

  /// Calculate engagement score (0-100)
  double get engagementScore {
    double score = 0;
    
    // Feature usage contributes 40%
    score += (featuresUsed / 10.0).clamp(0, 1) * 40;
    
    // Report generation contributes 30%
    score += (reportsGenerated / 5.0).clamp(0, 1) * 30;
    
    // Data exports contributes 20%
    score += (exportsCompleted / 3.0).clamp(0, 1) * 20;
    
    // Provider connections contributes 10%
    score += (providersConnected / 2.0).clamp(0, 1) * 10;
    
    return score.clamp(0, 100);
  }

  /// Check if user is highly engaged
  bool get isHighlyEngaged => engagementScore >= 70;

  /// Get most used feature
  String? get mostUsedFeature {
    if (featureUsageCount.isEmpty) return null;
    
    return featureUsageCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$SubscriptionAnalyticsToJson(this);

  /// Create from JSON
  factory SubscriptionAnalytics.fromJson(Map<String, dynamic> json) => 
      _$SubscriptionAnalyticsFromJson(json);

  /// Create empty analytics
  factory SubscriptionAnalytics.empty(String subscriptionId) {
    return SubscriptionAnalytics(
      subscriptionId: subscriptionId,
      totalDaysActive: 0,
      featuresUsed: 0,
      reportsGenerated: 0,
      exportsCompleted: 0,
      providersConnected: 0,
      lastActivity: DateTime.now(),
      featureUsageCount: {},
      satisfactionRating: 0.0,
    );
  }

  @override
  String toString() {
    return 'SubscriptionAnalytics{subscriptionId: $subscriptionId, '
           'engagementScore: ${engagementScore.toStringAsFixed(1)}, '
           'mostUsedFeature: $mostUsedFeature}';
  }
}
