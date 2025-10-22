import 'dart:convert';
import 'package:flutter/foundation.dart';
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

    debugPrint('💎 Initializing Premium Service...');

    try {
      await _loadCurrentSubscription();
      await _loadAvailableFeatures();
      
      _isInitialized = true;
      debugPrint('✅ Premium Service initialized');
    } catch (e) {
      debugPrint('❌ Premium Service initialization failed: $e');
      rethrow;
    }
  }

  /// Check if user has active premium subscription
  bool get hasPremium => _currentSubscription?.isActive ?? false;

  /// Get current subscription
  Subscription? get currentSubscription => _currentSubscription;

  /// Get available premium features
  List<PremiumFeature> get availableFeatures => List.unmodifiable(_availableFeatures);

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

  /// Purchase subscription
  Future<bool> purchaseSubscription(SubscriptionTier tier, PaymentMethod paymentMethod) async {
    try {
      debugPrint('💳 Purchasing ${tier.displayName} subscription...');

      // Mock payment processing
      final success = await _processPayment(tier, paymentMethod);
      if (!success) {
        throw Exception('Payment processing failed');
      }

      // Create new subscription
      final subscription = Subscription(
        id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
        userId: _preferences.getString('user_id') ?? 'unknown',
        tier: tier,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(_getSubscriptionDuration(tier)),
        paymentMethod: paymentMethod,
        status: SubscriptionStatus.active,
        autoRenew: true,
      );

      // Store subscription
      await _saveSubscription(subscription);
      _currentSubscription = subscription;

      // Unlock premium features
      await _unlockPremiumFeatures(tier);

      debugPrint('✅ Subscription purchased successfully: ${tier.displayName}');
      return true;
    } catch (e) {
      debugPrint('❌ Subscription purchase failed: $e');
      return false;
    }
  }

  /// Cancel subscription
  Future<bool> cancelSubscription() async {
    if (_currentSubscription == null) return false;

    try {
      debugPrint('🚫 Canceling subscription...');

      final updatedSubscription = _currentSubscription!.copyWith(
        status: SubscriptionStatus.cancelled,
        cancelledAt: DateTime.now(),
        autoRenew: false,
      );

      await _saveSubscription(updatedSubscription);
      _currentSubscription = updatedSubscription;

      debugPrint('✅ Subscription cancelled successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Subscription cancellation failed: $e');
      return false;
    }
  }

  /// Restore subscription (for App Store/Play Store purchases)
  Future<bool> restoreSubscription() async {
    try {
      debugPrint('🔄 Restoring subscription...');

      // Mock subscription restoration from App Store/Play Store
      final restoredSubscription = await _restoreFromStore();
      
      if (restoredSubscription != null) {
        await _saveSubscription(restoredSubscription);
        _currentSubscription = restoredSubscription;

        debugPrint('✅ Subscription restored successfully');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Subscription restoration failed: $e');
      return false;
    }
  }

  /// Get premium feature usage analytics
  Future<Map<String, dynamic>> getPremiumAnalytics() async {
    if (!hasPremium) return {};

    final subscription = _currentSubscription!;
    final daysSinceStart = DateTime.now().difference(subscription.startDate).inDays;

    return {
      'subscription_tier': subscription.tier.name,
      'days_active': daysSinceStart,
      'features_used': await _getUsedFeaturesCount(),
      'reports_generated': _preferences.getInt('reports_generated') ?? 0,
      'providers_connected': _preferences.getInt('providers_connected') ?? 0,
      'data_exports': _preferences.getInt('data_exports') ?? 0,
    };
  }

  /// Check subscription status and update if needed
  Future<void> checkSubscriptionStatus() async {
    if (_currentSubscription == null) return;

    final subscription = _currentSubscription!;
    
    // Check if subscription expired
    if (subscription.isExpired && subscription.status == SubscriptionStatus.active) {
      final updatedSubscription = subscription.copyWith(
        status: SubscriptionStatus.expired,
      );
      
      await _saveSubscription(updatedSubscription);
      _currentSubscription = updatedSubscription;
    }

    // Handle auto-renewal
    if (subscription.shouldAutoRenew) {
      await _handleAutoRenewal(subscription);
    }
  }

  /// Get feature limits for current subscription
  FeatureLimits get featureLimits {
    if (!hasPremium) {
      return FeatureLimits.free();
    }
    
    return FeatureLimits.forTier(_currentSubscription!.tier);
  }

  // Private helper methods

  Future<void> _loadCurrentSubscription() async {
    try {
      final subscriptionData = _preferences.getString('current_subscription');
      if (subscriptionData != null) {
        final json = jsonDecode(subscriptionData);
        _currentSubscription = Subscription.fromJson(json);
      }
    } catch (e) {
      debugPrint('⚠️ Error loading subscription: $e');
    }
  }

  Future<void> _loadAvailableFeatures() async {
    _availableFeatures = [
      PremiumFeature(
        type: PremiumFeatureType.advancedAI,
        name: 'Advanced AI Predictions',
        description: 'Enhanced AI with 95%+ accuracy and detailed insights',
        tier: SubscriptionTier.premium,
        benefits: [
          '95%+ prediction accuracy',
          'Detailed cycle phase insights',
          'Personalized recommendations',
          'Advanced pattern detection',
        ],
      ),
      PremiumFeature(
        type: PremiumFeatureType.healthcareIntegration,
        name: 'Healthcare Provider Integration',
        description: 'Connect with doctors and share health reports',
        tier: SubscriptionTier.premium,
        benefits: [
          'Share reports with doctors',
          'Secure medical data sync',
          'Appointment scheduling',
          'Health record integration',
        ],
      ),
      PremiumFeature(
        type: PremiumFeatureType.unlimitedExports,
        name: 'Unlimited Data Exports',
        description: 'Export your data in multiple formats anytime',
        tier: SubscriptionTier.basic,
        benefits: [
          'Export in PDF, CSV, Excel',
          'No monthly limits',
          'Custom date ranges',
          'Include all health metrics',
        ],
        usage: FeatureUsage.unlimited(),
      ),
      PremiumFeature(
        type: PremiumFeatureType.prioritySupport,
        name: 'Priority Support',
        description: '24/7 priority customer support',
        tier: SubscriptionTier.premium,
      ),
      PremiumFeature(
        type: PremiumFeatureType.customReports,
        name: 'Custom Health Reports',
        description: 'Generate detailed, customizable health reports',
        tier: SubscriptionTier.basic,
      ),
      PremiumFeature(
        type: PremiumFeatureType.biometricSync,
        name: 'Biometric Data Sync',
        description: 'Sync with wearables and health apps',
        tier: SubscriptionTier.premium,
      ),
      PremiumFeature(
        type: PremiumFeatureType.multiUserProfiles,
        name: 'Multi-User Profiles',
        description: 'Manage multiple family member profiles',
        tier: SubscriptionTier.ultimate,
      ),
      PremiumFeature(
        type: PremiumFeatureType.advancedAnalytics,
        name: 'Advanced Analytics Dashboard',
        description: 'Comprehensive health analytics and trends',
        tier: SubscriptionTier.ultimate,
      ),
    ];
  }

  Future<void> _saveSubscription(Subscription subscription) async {
    final json = jsonEncode(subscription.toJson());
    await _preferences.setString('current_subscription', json);
  }

  Future<bool> _processPayment(SubscriptionTier tier, PaymentMethod paymentMethod) async {
    // Mock payment processing - in real implementation, integrate with payment provider
    debugPrint('💳 Processing payment: ${tier.price} via ${paymentMethod.displayName}');
    await Future.delayed(const Duration(seconds: 2));
    return true; // Mock success
  }

  Duration _getSubscriptionDuration(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.basic:
      case SubscriptionTier.premium:
      case SubscriptionTier.ultimate:
        return const Duration(days: 30); // Monthly subscription
    }
  }

  Future<void> _unlockPremiumFeatures(SubscriptionTier tier) async {
      final features = _getFeaturesForTier(tier);
      for (final feature in features) {
        _preferences.setBool('feature_${feature.name}_unlocked', true);
      }
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
          PremiumFeatureType.healthcareIntegration,
          PremiumFeatureType.prioritySupport,
          PremiumFeatureType.biometricSync,
        ]);
        break;
      case SubscriptionTier.ultimate:
        allFeatures.addAll([
          PremiumFeatureType.unlimitedExports,
          PremiumFeatureType.customReports,
          PremiumFeatureType.advancedAI,
          PremiumFeatureType.healthcareIntegration,
          PremiumFeatureType.prioritySupport,
          PremiumFeatureType.biometricSync,
          PremiumFeatureType.multiUserProfiles,
          PremiumFeatureType.advancedAnalytics,
        ]);
        break;
    }
    
    return allFeatures;
  }

  Future<Subscription?> _restoreFromStore() async {
    // Mock restoration - in real implementation, check with App Store/Play Store
    await Future.delayed(const Duration(seconds: 1));
    return null; // Mock no subscription found
  }

  Future<int> _getUsedFeaturesCount() async {
    int count = 0;
    for (final feature in _availableFeatures) {
      final used = _preferences.getBool('feature_${feature.type.name}_used') ?? false;
      if (used) count++;
    }
    return count;
  }

  Future<void> _handleAutoRenewal(Subscription subscription) async {
    if (!subscription.autoRenew) return;

    try {
      // Mock auto-renewal process
      final renewed = await _processPayment(subscription.tier, subscription.paymentMethod);
      if (renewed) {
        final renewedSubscription = subscription.copyWith(
          endDate: DateTime.now().add(_getSubscriptionDuration(subscription.tier)),
        );
        
        await _saveSubscription(renewedSubscription);
        _currentSubscription = renewedSubscription;
      }
    } catch (e) {
      debugPrint('❌ Auto-renewal failed: $e');
    }
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
