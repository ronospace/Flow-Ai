import '../../../core/services/user_preferences_service.dart';
import '../models/subscription.dart';
import '../models/premium_feature.dart';

/// Premium Features and Subscription Service
class PremiumService {
  static final PremiumService _instance = PremiumService._internal();
  factory PremiumService() => _instance;
  PremiumService._internal();

  final UserPreferencesService _preferences = UserPreferencesService();

  Subscription? _currentSubscription;
  List<PremiumFeature> _availableFeatures = [];
  bool _isInitialized = false;

  /// Initialize premium service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Legacy local subscription hydration is disabled; Premium access must
      // come from the validated store/backend subscription flow.
      _currentSubscription = null;
      await _loadAvailableFeatures();

      _isInitialized = true;
    } catch (e) {
      rethrow;
    }
  }

  /// Check if user has active premium subscription
  bool get hasPremium => _currentSubscription?.isActive == true;

  /// Get current subscription
  Subscription? get currentSubscription => _currentSubscription;

  /// Get available premium features
  List<PremiumFeature> get availableFeatures =>
      List.unmodifiable(_availableFeatures);

  /// Check if a specific feature is available
  bool hasFeature(PremiumFeatureType featureType) {
    if (!hasPremium) {
      return _getFreeTierFeatures().contains(featureType);
    }

    final subscription = _currentSubscription!;
    return _getFeaturesForTier(subscription.tier).contains(featureType);
  }

  /// Get subscription tiers
  List<SubscriptionTier> get availableTiers => [
    SubscriptionTier.basic,
    SubscriptionTier.premium,
    SubscriptionTier.ultimate,
  ];

  /// Legacy PremiumService purchase path disabled.
  /// Authoritative purchases are owned by SubscriptionProvider -> SubscriptionService.
  /// Purchase subscription
  Future<bool> purchaseSubscription(
    SubscriptionTier tier,
    PaymentMethod paymentMethod,
  ) async {
    return false;
  }

  /// Cancel subscription
  Future<bool> cancelSubscription() async {
    if (_currentSubscription == null) return false;

    try {
      final updatedSubscription = _currentSubscription!.copyWith(
        status: SubscriptionStatus.cancelled,
        cancelledAt: DateTime.now(),
        autoRenew: false,
      );

      _currentSubscription = updatedSubscription;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Legacy PremiumService restore path disabled.
  /// Authoritative restore is owned by SubscriptionProvider -> SubscriptionService.
  /// Restore subscription (for App Store/Play Store purchases)
  Future<bool> restoreSubscription() async {
    return false;
  }

  /// Get premium feature usage analytics
  Future<Map<String, dynamic>> getPremiumAnalytics() async {
    if (!hasPremium) return {};

    final subscription = _currentSubscription!;
    final daysSinceStart = DateTime.now()
        .difference(subscription.startDate)
        .inDays;

    return {
      'subscription_tier': subscription.tier.name,
      'days_active': daysSinceStart,
      'features_used': await _getUsedFeaturesCount(),
      'reports_generated': _preferences.getInt('reports_generated'),
      'providers_connected': _preferences.getInt('providers_connected'),
      'data_exports': _preferences.getInt('data_exports'),
    };
  }

  /// Check subscription status and update if needed
  Future<void> checkSubscriptionStatus() async {
    if (_currentSubscription == null) return;

    final subscription = _currentSubscription!;

    // Check if subscription expired
    if (subscription.isExpired &&
        subscription.status == SubscriptionStatus.active) {
      final updatedSubscription = subscription.copyWith(
        status: SubscriptionStatus.expired,
      );

      _currentSubscription = updatedSubscription;
    }

    // Handle auto-renewal
  }

  /// Get feature limits for current subscription
  FeatureLimits get featureLimits {
    if (!hasPremium) {
      return FeatureLimits.free();
    }

    return FeatureLimits.forTier(_currentSubscription!.tier);
  }

  // Private helper methods

  Future<void> _loadAvailableFeatures() async {
    _availableFeatures = [
      PremiumFeature(
        type: PremiumFeatureType.advancedAI,
        name: 'Cycle & Wellness AI Insights',
        description:
            'Deeper AI insights using your tracked cycle and wellness context',
        tier: SubscriptionTier.premium,
        benefits: [
          'Deeper cycle and wellness insights',
          'Detailed cycle phase insights',
          'Personalized wellness insights',
          'Advanced pattern detection',
        ],
      ),
      PremiumFeature(
        type: PremiumFeatureType.unlimitedExports,
        name: 'Unlimited Data Exports',
        description: 'Export your data in multiple formats anytime',
        tier: SubscriptionTier.basic,
        benefits: [
          'Export in PDF or CSV',
          'No monthly limits',
          'Custom date ranges',
          'Include all health metrics',
        ],
        usage: FeatureUsage.unlimited(),
      ),
      PremiumFeature(
        type: PremiumFeatureType.customReports,
        name: 'Custom Health Reports',
        description: 'Generate detailed, customizable health reports',
        tier: SubscriptionTier.basic,
      ),
      PremiumFeature(
        type: PremiumFeatureType.advancedAnalytics,
        name: 'Advanced Analytics Dashboard',
        description: 'Comprehensive health analytics and trends',
        tier: SubscriptionTier.ultimate,
      ),
    ];
  }

  List<PremiumFeatureType> _getFreeTierFeatures() {
    return [
      PremiumFeatureType.basicTracking,
      PremiumFeatureType.basicPredictions,
      PremiumFeatureType.limitedExports,
    ];
  }

  List<PremiumFeatureType> _getFeaturesForTier(SubscriptionTier tier) {
    final allFeatures = _getFreeTierFeatures();

    switch (tier) {
      case SubscriptionTier.basic:
        allFeatures.addAll([
          PremiumFeatureType.unlimitedExports,
          PremiumFeatureType.customReports,
        ]);
        break;
      case SubscriptionTier.premium:
        allFeatures.addAll([
          PremiumFeatureType.unlimitedExports,
          PremiumFeatureType.customReports,
          PremiumFeatureType.advancedAI,
        ]);
        break;
      case SubscriptionTier.ultimate:
        allFeatures.addAll([
          PremiumFeatureType.unlimitedExports,
          PremiumFeatureType.customReports,
          PremiumFeatureType.advancedAI,
          PremiumFeatureType.advancedAnalytics,
        ]);
        break;
    }

    return allFeatures;
  }

  Future<int> _getUsedFeaturesCount() async {
    int count = 0;
    for (final feature in _availableFeatures) {
      final used = _preferences.getBool('feature_${feature.type.name}_used');
      if (used) count++;
    }
    return count;
  }
}

/// Feature limits based on subscription tier
class FeatureLimits {
  final int maxExportsPerMonth;
  final int maxReportsPerMonth;
  final int maxProvidersConnected;
  final bool unlimitedPredictions;
  final bool advancedAnalytics;

  const FeatureLimits({
    required this.maxExportsPerMonth,
    required this.maxReportsPerMonth,
    required this.maxProvidersConnected,
    required this.unlimitedPredictions,
    required this.advancedAnalytics,
  });

  factory FeatureLimits.free() {
    return const FeatureLimits(
      maxExportsPerMonth: 3,
      maxReportsPerMonth: 1,
      maxProvidersConnected: 0,
      unlimitedPredictions: false,
      advancedAnalytics: false,
    );
  }

  factory FeatureLimits.forTier(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.basic:
        return const FeatureLimits(
          maxExportsPerMonth: 20,
          maxReportsPerMonth: 10,
          maxProvidersConnected: 1,
          unlimitedPredictions: true,
          advancedAnalytics: false,
        );
      case SubscriptionTier.premium:
        return const FeatureLimits(
          maxExportsPerMonth: -1, // Unlimited
          maxReportsPerMonth: -1, // Unlimited
          maxProvidersConnected: 5,
          unlimitedPredictions: true,
          advancedAnalytics: true,
        );
      case SubscriptionTier.ultimate:
        return const FeatureLimits(
          maxExportsPerMonth: -1, // Unlimited
          maxReportsPerMonth: -1, // Unlimited
          maxProvidersConnected: -1, // Unlimited
          unlimitedPredictions: true,
          advancedAnalytics: true,
        );
    }
  }

  bool get hasUnlimitedExports => maxExportsPerMonth == -1;
  bool get hasUnlimitedReports => maxReportsPerMonth == -1;
  bool get hasUnlimitedProviders => maxProvidersConnected == -1;
}
