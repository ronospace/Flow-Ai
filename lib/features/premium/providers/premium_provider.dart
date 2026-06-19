import 'package:flutter/foundation.dart';
import '../models/subscription.dart';
import '../models/premium_feature.dart';
import '../services/premium_service.dart';
import 'subscription_provider.dart';

/// Provider for managing premium features and subscription state
class PremiumProvider extends ChangeNotifier {
  final PremiumService _premiumService = PremiumService();
  SubscriptionProvider? _subscriptionProvider;

  Subscription? _currentSubscription;
  List<PremiumFeature> _availableFeatures = [];
  FeatureLimits? _featureLimits;
  bool _isLoading = false;
  String? _error;
  Map<PremiumFeatureType, int> _monthlyUsage = {};

  /// Get current subscription
  Subscription? get currentSubscription => _currentSubscription;

  /// Get available premium features
  List<PremiumFeature> get availableFeatures =>
      List.unmodifiable(_availableFeatures);

  /// Get feature limits based on current subscription
  FeatureLimits? get featureLimits => _featureLimits;

  /// Check if user has premium subscription
  bool get hasPremium => _subscriptionProvider?.isPremium ?? false;

  /// Check if provider is loading
  bool get isLoading => _isLoading;

  /// Get current error message
  String? get error => _error;

  /// Get monthly usage for features
  Map<PremiumFeatureType, int> get monthlyUsage =>
      Map.unmodifiable(_monthlyUsage);

  /// Initialize premium provider
  void updateSubscriptionProvider(SubscriptionProvider provider) {
    if (identical(_subscriptionProvider, provider)) return;
    _subscriptionProvider?.removeListener(_handleSubscriptionChanged);
    _subscriptionProvider = provider;
    _subscriptionProvider!.addListener(_handleSubscriptionChanged);
    notifyListeners();
  }

  void _handleSubscriptionChanged() {
    notifyListeners();
  }

  Future<void> initialize() async {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      await _premiumService.initialize();
      await _loadSubscriptionData();
      await _loadFeatures();
      await _loadUsageData();

      debugPrint('✅ PremiumProvider initialized');
    } catch (e) {
      _setError('Failed to initialize premium features: $e');
      debugPrint('❌ PremiumProvider initialization failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Check if a specific feature is available
  bool hasFeature(PremiumFeatureType featureType) {
    final provider = _subscriptionProvider;
    switch (featureType.name) {
      case 'basicTracking':
      case 'basicPredictions':
      case 'limitedExports':
        return true;
      case 'unlimitedExports':
      case 'customReports':
        return provider?.canExportData ?? false;
      case 'advancedAI':
        return provider?.hasUnlimitedInsights ?? false;
      case 'prioritySupport':
        return provider?.hasPrioritySupport ?? false;
      case 'advancedAnalytics':
        return provider?.hasAdvancedAnalytics ?? false;
      default:
        return provider?.isPremium ?? false;
    }
  }

  /// Get feature by type
  PremiumFeature? getFeature(PremiumFeatureType featureType) {
    try {
      return _availableFeatures.firstWhere((f) => f.type == featureType);
    } catch (e) {
      return null;
    }
  }

  /// Check if feature usage is within limits
  bool canUseFeature(PremiumFeatureType featureType) {
    final feature = getFeature(featureType);
    if (feature == null) return false;

    // Check if feature is enabled
    if (!feature.isEnabled) return false;

    // Check subscription access
    if (!hasFeature(featureType)) return false;

    // Check usage limits
    if (_featureLimits != null) {
      return _isWithinUsageLimits(featureType);
    }

    return true;
  }

  /// Purchase a subscription
  Future<bool> purchaseSubscription(
    SubscriptionTier tier,
    PaymentMethod paymentMethod,
  ) async {
    _setError('Purchases must use the backend-validated Premium paywall.');
    return false;
  }

  /// Cancel current subscription
  Future<bool> cancelSubscription() async {
    _setError(
      'Subscription management must use the authenticated store workflow.',
    );
    return false;
  }

  /// Restore subscription from App Store/Play Store
  Future<bool> restoreSubscription() async {
    _setError('Restore must use the backend-validated Premium paywall.');
    return false;
  }

  /// Record feature usage
  Future<void> recordFeatureUsage(PremiumFeatureType featureType) async {
    try {
      // Update local usage tracking
      _monthlyUsage[featureType] = (_monthlyUsage[featureType] ?? 0) + 1;

      // Update feature usage count
      final featureIndex = _availableFeatures.indexWhere(
        (f) => f.type == featureType,
      );
      if (featureIndex != -1) {
        _availableFeatures[featureIndex] = _availableFeatures[featureIndex]
            .incrementUsage();
      }

      _notifyListeners();

      // TODO: Persist usage data to local storage or analytics service
    } catch (e) {
      debugPrint('⚠️ Failed to record feature usage: $e');
    }
  }

  /// Get remaining usage for a feature
  int getRemainingUsage(PremiumFeatureType featureType) {
    if (_featureLimits == null) return -1; // Unlimited

    final currentUsage = _monthlyUsage[featureType] ?? 0;

    switch (featureType) {
      case PremiumFeatureType.unlimitedExports:
      case PremiumFeatureType.limitedExports:
        if (_featureLimits!.hasUnlimitedExports) return -1;
        return (_featureLimits!.maxExportsPerMonth - currentUsage).clamp(
          0,
          _featureLimits!.maxExportsPerMonth,
        );

      case PremiumFeatureType.customReports:
        if (_featureLimits!.hasUnlimitedReports) return -1;
        return (_featureLimits!.maxReportsPerMonth - currentUsage).clamp(
          0,
          _featureLimits!.maxReportsPerMonth,
        );

      default:
        return -1; // Most features are unlimited once unlocked
    }
  }

  /// Get feature usage count for a specific feature type
  int getFeatureUsage(PremiumFeatureType featureType) {
    return _monthlyUsage[featureType] ?? 0;
  }

  /// Check subscription status and update if needed
  Future<void> checkSubscriptionStatus() async {
    try {
      await _premiumService.checkSubscriptionStatus();
      await _loadSubscriptionData();
      _notifyListeners();
    } catch (e) {
      debugPrint('⚠️ Failed to check subscription status: $e');
    }
  }

  /// Get premium analytics
  Future<Map<String, dynamic>> getPremiumAnalytics() async {
    try {
      return await _premiumService.getPremiumAnalytics();
    } catch (e) {
      debugPrint('⚠️ Failed to get premium analytics: $e');
      return {};
    }
  }

  /// Get available subscription tiers
  List<SubscriptionTier> get availableTiers => _premiumService.availableTiers;

  // Private helper methods

  Future<void> _loadSubscriptionData() async {
    _currentSubscription = _premiumService.currentSubscription;
    _featureLimits = _premiumService.featureLimits;
  }

  Future<void> _loadFeatures() async {
    _availableFeatures = _premiumService.availableFeatures;
  }

  Future<void> _loadUsageData() async {
    // TODO: Load monthly usage data from local storage
    // For now, initialize with empty usage
    _monthlyUsage = {};
  }

  bool _isWithinUsageLimits(PremiumFeatureType featureType) {
    if (_featureLimits == null) return true;

    final currentUsage = _monthlyUsage[featureType] ?? 0;

    switch (featureType) {
      case PremiumFeatureType.limitedExports:
      case PremiumFeatureType.unlimitedExports:
        if (_featureLimits!.hasUnlimitedExports) return true;
        return currentUsage < _featureLimits!.maxExportsPerMonth;

      case PremiumFeatureType.customReports:
        if (_featureLimits!.hasUnlimitedReports) return true;
        return currentUsage < _featureLimits!.maxReportsPerMonth;

      default:
        return true; // Most features are unlimited once unlocked
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      _notifyListeners();
    }
  }

  void _setError(String? error) {
    if (_error != error) {
      _error = error;
      _notifyListeners();
    }
  }

  void _clearError() {
    _setError(null);
  }

  void _notifyListeners() {
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('🗑️ PremiumProvider disposed');
    _subscriptionProvider?.removeListener(_handleSubscriptionChanged);
    super.dispose();
  }
}
