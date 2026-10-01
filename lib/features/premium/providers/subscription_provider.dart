import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/subscription_models.dart';
import '../services/subscription_service.dart';

import 'package:flow_ai/core/services/admob_service.dart';
import '../../../core/services/production_analytics_service.dart';

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionService _subscriptionService = SubscriptionService();
  StreamSubscription<UserSubscription>? _entitlementSubscription;
  Timer? _expiryTimer;

  UserSubscription? _subscription;
  List<SubscriptionProduct> _availableProducts = [];
  bool _isLoading = false;
  bool _isRestoring = false;
  String? _errorMessage;
  bool _isInitialized = false;
  String? _initializedUserId;
  int _initializationGeneration = 0;

  // Getters
  UserSubscription? get subscription => _subscription;
  List<SubscriptionProduct> get availableProducts => _availableProducts;
  bool get isLoading => _isLoading;
  bool get isRestoring => _isRestoring;
  String? get errorMessage => _errorMessage;

  bool get hasReceiptOwnershipConflict =>
      _subscriptionService.lastReceiptValidationError ==
      'receipt_owner_conflict';

  String? get ownershipConflictMessage {
    if (!hasReceiptOwnershipConflict) return null;

    return 'This subscription is linked to a different Flow Ai account. '
        'Sign in with the Flow Ai account that owns the subscription.';
  }

  String? get restoreOwnershipErrorMessage => ownershipConflictMessage;

  bool get isInitialized => _isInitialized;
  String? get initializedUserId => _initializedUserId;

  // Premium status
  bool get isPremium =>
      _subscriptionService.isPremium &&
      _subscription?.userId == _initializedUserId &&
      (_subscription?.isPremium ?? false);

  bool get hasDurableMonetizationIdentity =>
      _subscriptionService.hasDurableMonetizationIdentity;

  bool canOwnMonetizationFor(String userId) =>
      _subscriptionService.canOwnMonetizationFor(userId);
  bool get isFree => !isPremium;
  SubscriptionTier get tier => _subscription?.tier ?? SubscriptionTier.free;

  // Feature access
  bool get hasUnlimitedInsights =>
      canAccessFeature(PremiumFeature.unlimitedInsights);
  bool get isAdFree => canAccessFeature(PremiumFeature.adFree);
  bool get canExportData => canAccessFeature(PremiumFeature.dataExport);
  bool get hasAdvancedAnalytics =>
      canAccessFeature(PremiumFeature.advancedAnalytics);
  bool get hasPrioritySupport =>
      canAccessFeature(PremiumFeature.prioritySupport);

  // Free tier limits
  int get remainingFreeInsights =>
      _subscriptionService.getRemainingFreeInsights();
  bool get hasUsedFreeInsights => _subscription?.hasUsedFreeInsights ?? false;
  int get aiInsightsUsed => _subscription?.aiInsightsUsed ?? 0;
  int get aiInsightsLimit => _subscription?.aiInsightsLimit ?? 5;

  // Subscription info
  DateTime? get expiryDate => _subscription?.expiryDate;
  int? get daysUntilExpiry => _subscription?.daysUntilExpiry;
  bool get isExpiringSoon => _subscription?.isExpiringSoon ?? false;
  String? get billingPeriodText {
    if (_subscription?.billingPeriod == null) return null;
    switch (_subscription!.billingPeriod!) {
      case BillingPeriod.monthly:
        return 'Monthly';
      case BillingPeriod.yearly:
        return 'Yearly';
      case BillingPeriod.lifetime:
        return 'Lifetime';
    }
  }

  void _scheduleExpiryRefresh() {
    _expiryTimer?.cancel();
    _expiryTimer = null;

    final subscription = _subscription;
    final expiry = subscription?.expiryDate;

    if (subscription == null || !subscription.isPremium || expiry == null) {
      return;
    }

    final delay = expiry.difference(DateTime.now());

    if (delay <= Duration.zero) {
      AdMobService().setPremiumSuppressed(false);
      notifyListeners();
      return;
    }

    _expiryTimer = Timer(delay + const Duration(seconds: 1), () {
      _expiryTimer = null;

      // UserSubscription.isPremium evaluates expiry against DateTime.now().
      // Rebuild exactly after entitlement expiry so premium UI/features fail
      // closed without requiring navigation, restart, or a purchase event.
      final premiumNow = _subscription?.isPremium ?? false;
      AdMobService().setPremiumSuppressed(premiumNow);
      notifyListeners();
    });
  }

  /// Initialize subscription service
  Future<void> initialize(String userId) async {
    final normalizedUserId = userId.trim();

    if (normalizedUserId.isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'User ID cannot be empty');
    }

    final generation = ++_initializationGeneration;

    // Entitlement is unknown during account transition. Ads fail closed until
    // the new account's backend-validated subscription state resolves.
    AdMobService().setPremiumSuppressed(true);

    // Stop observing the previous account before exposing any new state.
    await _entitlementSubscription?.cancel();
    _entitlementSubscription = null;
    _expiryTimer?.cancel();
    _expiryTimer = null;

    // Fail closed immediately during an account transition.
    _subscription = UserSubscription.free(normalizedUserId);
    _availableProducts = const [];
    _errorMessage = null;
    _isInitialized = false;
    _initializedUserId = null;
    notifyListeners();

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _subscriptionService.initialize(normalizedUserId);
      await _entitlementSubscription?.cancel();
      _entitlementSubscription = _subscriptionService.entitlementChanges.listen(
        (subscription) {
          _subscription = subscription;
          AdMobService().setPremiumSuppressed(subscription.isPremium);
          _scheduleExpiryRefresh();
          notifyListeners();
        },
      );
      _subscription = _subscriptionService.currentSubscription;
      AdMobService().setPremiumSuppressed(_subscription?.isPremium ?? true);
      _scheduleExpiryRefresh();
      _availableProducts = _subscriptionService.getAvailableProducts();
      if (generation != _initializationGeneration) {
        return;
      }

      _initializedUserId = normalizedUserId;
      _isInitialized = true;

      if (_availableProducts.isEmpty) {
        _errorMessage = 'Subscription plans are temporarily unavailable.';
      }
    } catch (e) {
      // Unknown entitlement must never degrade into ad-supported behavior.
      AdMobService().setPremiumSuppressed(true);
      _errorMessage =
          'Subscriptions are temporarily unavailable. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load the real app-store product catalog without changing entitlement ownership.
  Future<void> loadStoreCatalog() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _subscriptionService.reloadProducts();
      _availableProducts = _subscriptionService.getAvailableProducts();

      if (_availableProducts.isEmpty) {
        _errorMessage = 'Subscription plans are temporarily unavailable.';
      }
    } catch (_) {
      _errorMessage =
          'Subscription plans could not be loaded. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh products after an unavailable or empty catalog response.
  Future<void> refreshProducts(String userId) async {
    if (!_isInitialized) {
      await initialize(userId);
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _subscriptionService.reloadProducts();
      _availableProducts = _subscriptionService.getAvailableProducts();

      if (_availableProducts.isEmpty) {
        _errorMessage = 'Subscription plans are temporarily unavailable.';
      }
    } catch (e) {
      _errorMessage =
          'Subscription plans could not be refreshed. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check if user can access a premium feature
  bool canAccessFeature(PremiumFeature feature) {
    return isPremium &&
        _subscriptionService.canAccessFeature(feature) &&
        (_subscription?.canAccessFeature(feature) ?? false);
  }

  /// Purchase a subscription
  Future<PurchaseResult> purchaseSubscription(String productId) async {
    if (_isLoading) {
      return PurchaseResult.failure(
        'Another subscription action is already in progress. Please wait.',
        PurchaseError.unknown,
      );
    }

    await ProductionAnalyticsService().trackMonetizationAction(
      'premium_purchase_requested',
    );

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _subscriptionService.purchaseSubscription(productId);

      if (!result.success) {
        if (result.error == PurchaseError.alreadyPurchased) {
          _subscription = _subscriptionService.currentSubscription;
          _errorMessage = null;
          _scheduleExpiryRefresh();
        } else {
          _errorMessage =
              result.errorMessage ??
              'We could not start the purchase. Please try again.';
        }
      } else if (result.subscription != null) {
        _subscription = result.subscription;
        _scheduleExpiryRefresh();
      }

      return result;
    } catch (error) {
      _errorMessage = 'We could not start the purchase. Please try again.';

      return PurchaseResult.failure(
        _errorMessage!,
        PurchaseError.paymentFailed,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Restore previous purchases
  Future<bool> restorePurchases(String userId) async {
    if (_isLoading) {
      return false;
    }

    await ProductionAnalyticsService().trackMonetizationAction(
      'premium_restore_requested',
    );

    _isLoading = true;
    _isRestoring = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final restored = await _subscriptionService.restorePurchases(userId);
      _subscription = _subscriptionService.currentSubscription;
      _scheduleExpiryRefresh();

      if (!restored) {
        _errorMessage = restoreOwnershipErrorMessage;
      }

      return restored;
    } catch (error) {
      _errorMessage = 'We could not restore purchases. Please try again.';
      return false;
    } finally {
      _isRestoring = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Increment AI insights usage (for free users)
  Future<void> incrementInsightsUsage() async {
    if (_subscription == null || hasUnlimitedInsights) {
      return; // Premium users have unlimited
    }

    await _subscriptionService.incrementInsightsUsage();
    _subscription = _subscriptionService.currentSubscription;
    notifyListeners();
  }

  /// Check if user should see upgrade prompt
  bool shouldShowUpgradePrompt() {
    if (isPremium) return false;

    // Show prompt when user has used 80% of free insights
    final used = _subscription?.aiInsightsUsed ?? 0;
    final limit = _subscription?.aiInsightsLimit ?? 5;

    return used >= (limit * 0.8).floor();
  }

  /// Get recommended product (yearly for better value)
  SubscriptionProduct? getRecommendedProduct() {
    if (_availableProducts.isEmpty) return null;

    // Return yearly product if available (better value)
    return _availableProducts.firstWhere(
      (p) => p.billingPeriod == BillingPeriod.yearly,
      orElse: () => _availableProducts.first,
    );
  }

  /// Get monthly product
  SubscriptionProduct? getMonthlyProduct() {
    for (final product in _availableProducts) {
      if (product.billingPeriod == BillingPeriod.monthly) {
        return product;
      }
    }

    return null;
  }

  /// Get yearly product
  SubscriptionProduct? getYearlyProduct() {
    for (final product in _availableProducts) {
      if (product.billingPeriod == BillingPeriod.yearly) {
        return product;
      }
    }

    return null;
  }

  /// Get upgrade message based on current usage
  String getUpgradeMessage() {
    if (isPremium) return 'You have premium access';

    final remaining = remainingFreeInsights;

    if (remaining <= 0) {
      return 'You\'ve used all your free AI insights for this month. Upgrade to premium for unlimited insights!';
    } else if (remaining <= 1) {
      return 'Only 1 free AI insight remaining. Upgrade now for unlimited insights!';
    } else if (remaining <= 2) {
      return 'Only $remaining free AI insights remaining. Upgrade to premium for unlimited access!';
    } else {
      return 'Get unlimited AI insights, advanced analytics, and data export with premium!';
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    _entitlementSubscription?.cancel();
    _subscriptionService.dispose();
    super.dispose();
  }
}
