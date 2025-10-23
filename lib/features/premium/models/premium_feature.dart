import 'package:json_annotation/json_annotation.dart';
import 'subscription.dart';

part 'premium_feature.g.dart';

/// Types of premium features available in the app
enum PremiumFeatureType {
  // Free tier features
  basicTracking,
  basicPredictions,
  limitedExports,

  // Basic tier features
  unlimitedExports,
  customReports,

  // Premium tier features
  advancedAI,
  healthcareIntegration,
  prioritySupport,
  biometricSync,

  // Ultimate tier features
  multiUserProfiles,
  advancedAnalytics;

  /// Get display name for the feature
  String get displayName {
    switch (this) {
      case PremiumFeatureType.basicTracking:
        return 'Basic Cycle Tracking';
      case PremiumFeatureType.basicPredictions:
        return 'Basic Period Predictions';
      case PremiumFeatureType.limitedExports:
        return 'Limited Data Exports';
      case PremiumFeatureType.unlimitedExports:
        return 'Unlimited Data Exports';
      case PremiumFeatureType.customReports:
        return 'Custom Health Reports';
      case PremiumFeatureType.advancedAI:
        return 'Advanced AI Predictions';
      case PremiumFeatureType.healthcareIntegration:
        return 'Healthcare Integration';
      case PremiumFeatureType.prioritySupport:
        return 'Priority Support';
      case PremiumFeatureType.biometricSync:
        return 'Biometric Data Sync';
      case PremiumFeatureType.multiUserProfiles:
        return 'Multi-User Profiles';
      case PremiumFeatureType.advancedAnalytics:
        return 'Advanced Analytics';
    }
  }

  /// Get description for the feature
  String get description {
    switch (this) {
      case PremiumFeatureType.basicTracking:
        return 'Track your menstrual cycle with basic functionality';
      case PremiumFeatureType.basicPredictions:
        return 'Get basic period and fertility predictions';
      case PremiumFeatureType.limitedExports:
        return 'Export your data up to 3 times per month';
      case PremiumFeatureType.unlimitedExports:
        return 'Export your data anytime in multiple formats';
      case PremiumFeatureType.customReports:
        return 'Generate detailed, customizable health reports';
      case PremiumFeatureType.advancedAI:
        return 'Enhanced AI with 95%+ accuracy and detailed insights';
      case PremiumFeatureType.healthcareIntegration:
        return 'Connect with healthcare providers and share reports';
      case PremiumFeatureType.prioritySupport:
        return '24/7 priority customer support';
      case PremiumFeatureType.biometricSync:
        return 'Sync with Apple Health, Google Fit, and wearables';
      case PremiumFeatureType.multiUserProfiles:
        return 'Manage multiple family member profiles';
      case PremiumFeatureType.advancedAnalytics:
        return 'Comprehensive health analytics and trend analysis';
    }
  }

  /// Get the minimum subscription tier required for this feature
  SubscriptionTier get minimumTier {
    switch (this) {
      case PremiumFeatureType.basicTracking:
      case PremiumFeatureType.basicPredictions:
      case PremiumFeatureType.limitedExports:
        return SubscriptionTier.basic; // These are free but we need a tier
      case PremiumFeatureType.unlimitedExports:
      case PremiumFeatureType.customReports:
        return SubscriptionTier.basic;
      case PremiumFeatureType.advancedAI:
      case PremiumFeatureType.healthcareIntegration:
      case PremiumFeatureType.prioritySupport:
      case PremiumFeatureType.biometricSync:
        return SubscriptionTier.premium;
      case PremiumFeatureType.multiUserProfiles:
      case PremiumFeatureType.advancedAnalytics:
        return SubscriptionTier.ultimate;
    }
  }

  /// Check if this is a free feature
  bool get isFreeFeature {
    return [
      PremiumFeatureType.basicTracking,
      PremiumFeatureType.basicPredictions,
      PremiumFeatureType.limitedExports,
    ].contains(this);
  }

  /// Get icon name for the feature
  String get iconName {
    switch (this) {
      case PremiumFeatureType.basicTracking:
        return 'calendar_month';
      case PremiumFeatureType.basicPredictions:
        return 'insights';
      case PremiumFeatureType.limitedExports:
        return 'download';
      case PremiumFeatureType.unlimitedExports:
        return 'cloud_download';
      case PremiumFeatureType.customReports:
        return 'assessment';
      case PremiumFeatureType.advancedAI:
        return 'smart_toy';
      case PremiumFeatureType.healthcareIntegration:
        return 'local_hospital';
      case PremiumFeatureType.prioritySupport:
        return 'support_agent';
      case PremiumFeatureType.biometricSync:
        return 'fitness_center';
      case PremiumFeatureType.multiUserProfiles:
        return 'group';
      case PremiumFeatureType.advancedAnalytics:
        return 'analytics';
    }
  }
}

/// Premium feature configuration and metadata
@JsonSerializable()
class PremiumFeature {
  final PremiumFeatureType type;
  final String name;
  final String description;
  final SubscriptionTier tier;
  final bool isEnabled;
  final DateTime? enabledAt;
  final int usageCount;
  final DateTime? lastUsed;
  final Map<String, dynamic> settings;
  final double? usageLimitPerMonth;
  final String? helpUrl;
  final List<String> benefits;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final FeatureUsage? usage;

  const PremiumFeature({
    required this.type,
    required this.name,
    required this.description,
    required this.tier,
    this.isEnabled = true,
    this.enabledAt,
    this.usageCount = 0,
    this.lastUsed,
    this.settings = const {},
    this.usageLimitPerMonth,
    this.helpUrl,
    this.benefits = const [],
    this.usage,
  });

  /// Check if feature has usage limit
  bool get hasUsageLimit => usageLimitPerMonth != null;

  /// Check if feature usage is within limit
  bool get isWithinUsageLimit {
    if (!hasUsageLimit) return true;
    return usageCount <= (usageLimitPerMonth ?? 0);
  }

  /// Get remaining usage for this month
  double get remainingUsage {
    if (!hasUsageLimit) return double.infinity;
    return (usageLimitPerMonth! - usageCount).clamp(0, usageLimitPerMonth!);
  }

  /// Get usage percentage (0-100)
  double get usagePercentage {
    if (!hasUsageLimit) return 0;
    return ((usageCount / usageLimitPerMonth!) * 100).clamp(0, 100);
  }

  /// Check if feature was recently used (within last 7 days)
  bool get wasRecentlyUsed {
    if (lastUsed == null) return false;
    return DateTime.now().difference(lastUsed!).inDays <= 7;
  }

  /// Get days since last use
  int get daysSinceLastUse {
    if (lastUsed == null) return -1;
    return DateTime.now().difference(lastUsed!).inDays;
  }

  /// Create copy with updated fields
  PremiumFeature copyWith({
    PremiumFeatureType? type,
    String? name,
    String? description,
    SubscriptionTier? tier,
    bool? isEnabled,
    DateTime? enabledAt,
    int? usageCount,
    DateTime? lastUsed,
    Map<String, dynamic>? settings,
    double? usageLimitPerMonth,
    String? helpUrl,
    List<String>? benefits,
    FeatureUsage? usage,
  }) {
    return PremiumFeature(
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      tier: tier ?? this.tier,
      isEnabled: isEnabled ?? this.isEnabled,
      enabledAt: enabledAt ?? this.enabledAt,
      usageCount: usageCount ?? this.usageCount,
      lastUsed: lastUsed ?? this.lastUsed,
      settings: settings ?? this.settings,
      usageLimitPerMonth: usageLimitPerMonth ?? this.usageLimitPerMonth,
      helpUrl: helpUrl ?? this.helpUrl,
      benefits: benefits ?? this.benefits,
      usage: usage ?? this.usage,
    );
  }

  /// Increment usage count
  PremiumFeature incrementUsage() {
    return copyWith(
      usageCount: usageCount + 1,
      lastUsed: DateTime.now(),
    );
  }

  /// Reset monthly usage
  PremiumFeature resetMonthlyUsage() {
    return copyWith(usageCount: 0);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$PremiumFeatureToJson(this);

  /// Create from JSON
  factory PremiumFeature.fromJson(Map<String, dynamic> json) =>
      _$PremiumFeatureFromJson(json);

  /// Create a feature with default settings
  factory PremiumFeature.withDefaults(
    PremiumFeatureType type,
    SubscriptionTier tier,
  ) {
    return PremiumFeature(
      type: type,
      name: type.displayName,
      description: type.description,
      tier: tier,
      isEnabled: true,
      enabledAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PremiumFeature &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() {
    return 'PremiumFeature{type: $type, name: $name, tier: $tier, '
           'enabled: $isEnabled, usageCount: $usageCount}';
  }
}

/// Feature usage analytics
@JsonSerializable()
class FeatureUsageAnalytics {
  final PremiumFeatureType featureType;
  final DateTime month;
  final int totalUsage;
  final int uniqueDaysUsed;
  final double averageUsagePerDay;
  final List<DateTime> usageDates;
  final Map<String, dynamic> metadata;

  const FeatureUsageAnalytics({
    required this.featureType,
    required this.month,
    required this.totalUsage,
    required this.uniqueDaysUsed,
    required this.averageUsagePerDay,
    required this.usageDates,
    this.metadata = const {},
  });

  /// Check if feature was heavily used this month
  bool get isHeavilyUsed => totalUsage >= 20 || uniqueDaysUsed >= 15;

  /// Get usage consistency score (0-100)
  double get consistencyScore {
    if (uniqueDaysUsed == 0) return 0;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    return (uniqueDaysUsed / daysInMonth * 100).clamp(0, 100);
  }

  /// Get usage trend (positive = increasing, negative = decreasing)
  double get usageTrend {
    if (usageDates.length < 2) return 0;
    
    // Simple linear trend calculation
    final sortedDates = List<DateTime>.from(usageDates)..sort();
    final firstHalf = sortedDates.take(sortedDates.length ~/ 2).length;
    final secondHalf = sortedDates.skip(sortedDates.length ~/ 2).length;
    
    return (secondHalf - firstHalf) / sortedDates.length;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$FeatureUsageAnalyticsToJson(this);

  /// Create from JSON
  factory FeatureUsageAnalytics.fromJson(Map<String, dynamic> json) =>
      _$FeatureUsageAnalyticsFromJson(json);

  /// Create empty analytics for a month
  factory FeatureUsageAnalytics.empty(PremiumFeatureType featureType, DateTime month) {
    return FeatureUsageAnalytics(
      featureType: featureType,
      month: DateTime(month.year, month.month),
      totalUsage: 0,
      uniqueDaysUsed: 0,
      averageUsagePerDay: 0.0,
      usageDates: [],
    );
  }

  @override
  String toString() {
    return 'FeatureUsageAnalytics{feature: $featureType, month: ${month.month}/${month.year}, '
           'usage: $totalUsage, consistency: ${consistencyScore.toStringAsFixed(1)}%}';
  }
}

/// Feature usage information and limits
class FeatureUsage {
  final int? limit;
  final int current;
  final DateTime? resetDate;
  final String? limitType;

  const FeatureUsage({
    this.limit,
    this.current = 0,
    this.resetDate,
    this.limitType,
  });

  /// Check if usage is within limit
  bool get isWithinLimit {
    if (limit == null) return true;
    return current < limit!;
  }

  /// Get remaining usage
  int get remaining {
    if (limit == null) return -1; // Unlimited
    return (limit! - current).clamp(0, limit!);
  }

  /// Get usage percentage (0-100)
  double get percentage {
    if (limit == null) return 0;
    return (current / limit! * 100).clamp(0, 100);
  }

  /// Check if limit is reached
  bool get isLimitReached {
    if (limit == null) return false;
    return current >= limit!;
  }

  /// Create copy with updated usage
  FeatureUsage copyWith({
    int? limit,
    int? current,
    DateTime? resetDate,
    String? limitType,
  }) {
    return FeatureUsage(
      limit: limit ?? this.limit,
      current: current ?? this.current,
      resetDate: resetDate ?? this.resetDate,
      limitType: limitType ?? this.limitType,
    );
  }

  /// Create usage with unlimited access
  factory FeatureUsage.unlimited() {
    return const FeatureUsage(
      limit: null,
      current: 0,
      limitType: 'unlimited',
    );
  }

  /// Create usage with monthly limit
  factory FeatureUsage.monthly(int limit, [int current = 0]) {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    
    return FeatureUsage(
      limit: limit,
      current: current,
      resetDate: nextMonth,
      limitType: 'monthly',
    );
  }

  @override
  String toString() {
    return 'FeatureUsage{limit: $limit, current: $current, type: $limitType}';
  }
}
