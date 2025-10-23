import 'package:flutter/foundation.dart';
import '../models/subscription_models.dart';
import '../services/subscription_service.dart';

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionService _subscriptionService = SubscriptionService();
  
  UserSubscription? _subscription;
  List<SubscriptionProduct> _availableProducts = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  // Getters
  UserSubscription? get subscription => _subscription;
  List<SubscriptionProduct> get availableProducts => _availableProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  
  // Premium status
  bool get isPremium => _subscription?.isPremium ?? false;
  bool get isFree => !isPremium;
  SubscriptionTier get tier => _subscription?.tier ?? SubscriptionTier.free;
  
  // Feature access
  bool get hasUnlimitedInsights => 
      _subscription?.hasUnlimitedInsights ?? false;
  bool get isAdFree => _subscription?.isAdFree ?? false;
  bool get canExportData => _subscription?.canExportData ?? false;
  bool get hasAdvancedAnalytics => 
      _subscription?.hasAdvancedAnalytics ?? false;
  bool get hasPrioritySupport => 
      _subscription?.hasPrioritySupport ?? false;
  
  // Free tier limits
  int get remainingFreeInsights => 
      _subscriptionService.getRemainingFreeInsights();
  bool get hasUsedFreeInsights => 
      _subscription?.hasUsedFreeInsights ?? false;
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

  /// Initialize subscription service
  Future<void> initialize(String userId) async {
    if (_isInitialized) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _subscriptionService.initialize(userId);
      _subscription = _subscriptionService.currentSubscription;
      _availableProducts = _subscriptionService.getAvailableProducts();
      _isInitialized = true;
      
      if (kDebugMode) {
        print('✅ SubscriptionProvider initialized');
        print('   Tier: ${_subscription?.tier}');
        print('   Premium: $isPremium');
      }
    } catch (e) {
      _errorMessage = 'Failed to initialize subscriptions: ${e.toString()}';
      if (kDebugMode) {
        print('❌ SubscriptionProvider error: $_errorMessage');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check if user can access a premium feature
  bool canAccessFeature(PremiumFeature feature) {
    return _subscription?.canAccessFeature(feature) ?? false;
  }

  /// Purchase a subscription
  Future<PurchaseResult> purchaseSubscription(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _subscriptionService.purchaseSubscription(productId);
      
      if (result.success && result.subscription != null) {
        _subscription = result.subscription;
        
        if (kDebugMode) {
          print('🎉 Purchase successful! User is now premium');
        }
      } else {
        _errorMessage = result.errorMessage ?? 'Purchase failed';
        if (kDebugMode) {
          print('❌ Purchase failed: $_errorMessage');
        }
      }
      
      return result;
    } catch (e) {
      _errorMessage = 'Purchase error: ${e.toString()}';
      if (kDebugMode) {
        print('❌ Purchase exception: $_errorMessage');
      }
      return PurchaseResult.failure(_errorMessage!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Restore previous purchases
  Future<bool> restorePurchases(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final restored = await _subscriptionService.restorePurchases(userId);
      _subscription = _subscriptionService.currentSubscription;
      
      if (restored) {
        if (kDebugMode) {
          print('✅ Purchases restored');
        }
      } else {
        if (kDebugMode) {
          print('ℹ️ No purchases to restore');
        }
      }
      
      return restored;
    } catch (e) {
      _errorMessage = 'Failed to restore purchases: ${e.toString()}';
      if (kDebugMode) {
        print('❌ Restore error: $_errorMessage');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Increment AI insights usage (for free users)
  Future<void> incrementInsightsUsage() async {
    if (_subscription == null || _subscription!.hasUnlimitedInsights) {
      return; // Premium users have unlimited
    }

    await _subscriptionService.incrementInsightsUsage();
    _subscription = _subscriptionService.currentSubscription;
    notifyListeners();

    if (kDebugMode) {
      print('📊 AI insights used: ${_subscription?.aiInsightsUsed}/${_subscription?.aiInsightsLimit}');
    }
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
    if (_availableProducts.isEmpty) return null;
    
    return _availableProducts.firstWhere(
      (p) => p.billingPeriod == BillingPeriod.monthly,
      orElse: () => _availableProducts.first,
    );
  }

  /// Get yearly product
  SubscriptionProduct? getYearlyProduct() {
    if (_availableProducts.isEmpty) return null;
    
    return _availableProducts.firstWhere(
      (p) => p.billingPeriod == BillingPeriod.yearly,
      orElse: () => _availableProducts.first,
    );
  }

  /// Calculate savings for yearly subscription
  double? calculateYearlySavings() {
    final monthly = getMonthlyProduct();
    final yearly = getYearlyProduct();
    
    if (monthly == null || yearly == null) return null;
    
    return yearly.getSavingsPercentage(monthly.price);
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
      return 'Get unlimited AI insights, ad-free experience, and more with premium!';
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscriptionService.dispose();
    super.dispose();
  }
}
