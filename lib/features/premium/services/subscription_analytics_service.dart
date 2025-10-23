import 'package:flutter/foundation.dart';
import '../models/subscription.dart';
import '../models/subscription_plan.dart';
import '../models/premium_feature.dart';

/// Subscription Analytics Service
/// Tracks subscription events, conversions, and feature usage
class SubscriptionAnalyticsService {
  // TODO: Replace with your actual analytics service (Firebase, Mixpanel, Amplitude, etc.)
  
  /// Track when user views the paywall
  static Future<void> trackPaywallViewed({
    String? source, // e.g., 'settings', 'feature_gate', 'onboarding'
    PremiumFeatureType? blockedFeature,
  }) async {
    await _logEvent('paywall_viewed', parameters: {
      'source': source ?? 'unknown',
      if (blockedFeature != null) 'blocked_feature': blockedFeature.name,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track when user changes billing cycle selection
  static Future<void> trackBillingCycleChanged({
    required SubscriptionBillingCycle from,
    required SubscriptionBillingCycle to,
  }) async {
    await _logEvent('billing_cycle_changed', parameters: {
      'from_cycle': from.name,
      'to_cycle': to.name,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track when user taps on a subscription tier
  static Future<void> trackTierSelected({
    required SubscriptionTier tier,
    required SubscriptionBillingCycle billingCycle,
    required double price,
  }) async {
    await _logEvent('tier_selected', parameters: {
      'tier': tier.name,
      'billing_cycle': billingCycle.name,
      'price': price,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track purchase initiated
  static Future<void> trackPurchaseInitiated({
    required SubscriptionPlan plan,
  }) async {
    await _logEvent('purchase_initiated', parameters: {
      'product_id': plan.productId,
      'tier': plan.tier.name,
      'billing_cycle': plan.billingCycle.name,
      'price': plan.price,
      'currency': plan.currencyCode,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track successful purchase (CRITICAL - for revenue tracking)
  static Future<void> trackPurchaseCompleted({
    required SubscriptionPlan plan,
    required String transactionId,
    String? originalTransactionId,
  }) async {
    await _logEvent('purchase_completed', parameters: {
      'product_id': plan.productId,
      'tier': plan.tier.name,
      'billing_cycle': plan.billingCycle.name,
      'price': plan.price,
      'currency': plan.currencyCode,
      'transaction_id': transactionId,
      if (originalTransactionId != null)
        'original_transaction_id': originalTransactionId,
      'timestamp': DateTime.now().toIso8601String(),
      'revenue': plan.price, // For revenue tracking
    });
    
    // Also track conversion event
    await trackConversion(
      tier: plan.tier,
      billingCycle: plan.billingCycle,
      revenue: plan.price,
    );
  }

  /// Track purchase failed
  static Future<void> trackPurchaseFailed({
    required SubscriptionPlan plan,
    required String errorMessage,
    String? errorCode,
  }) async {
    await _logEvent('purchase_failed', parameters: {
      'product_id': plan.productId,
      'tier': plan.tier.name,
      'billing_cycle': plan.billingCycle.name,
      'error_message': errorMessage,
      if (errorCode != null) 'error_code': errorCode,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track purchase cancelled by user
  static Future<void> trackPurchaseCancelled({
    required SubscriptionPlan plan,
  }) async {
    await _logEvent('purchase_cancelled', parameters: {
      'product_id': plan.productId,
      'tier': plan.tier.name,
      'billing_cycle': plan.billingCycle.name,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track successful restore purchases
  static Future<void> trackPurchasesRestored({
    required int restoreCount,
  }) async {
    await _logEvent('purchases_restored', parameters: {
      'restored_count': restoreCount,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track conversion (subscription activated)
  static Future<void> trackConversion({
    required SubscriptionTier tier,
    required SubscriptionBillingCycle billingCycle,
    required double revenue,
  }) async {
    await _logEvent('subscription_conversion', parameters: {
      'tier': tier.name,
      'billing_cycle': billingCycle.name,
      'revenue': revenue,
      'conversion_value': revenue,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track subscription renewal
  static Future<void> trackSubscriptionRenewed({
    required Subscription subscription,
    required double revenue,
  }) async {
    await _logEvent('subscription_renewed', parameters: {
      'subscription_id': subscription.id,
      'tier': subscription.tier.name,
      'revenue': revenue,
      'renewal_count': subscription.renewalCount,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track subscription cancellation
  static Future<void> trackSubscriptionCancelled({
    required Subscription subscription,
    String? reason,
  }) async {
    await _logEvent('subscription_cancelled', parameters: {
      'subscription_id': subscription.id,
      'tier': subscription.tier.name,
      'days_active': subscription.daysActive,
      if (reason != null) 'cancellation_reason': reason,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track subscription expired
  static Future<void> trackSubscriptionExpired({
    required Subscription subscription,
  }) async {
    await _logEvent('subscription_expired', parameters: {
      'subscription_id': subscription.id,
      'tier': subscription.tier.name,
      'days_active': subscription.daysActive,
      'renewal_count': subscription.renewalCount,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track subscription upgraded
  static Future<void> trackSubscriptionUpgraded({
    required SubscriptionTier fromTier,
    required SubscriptionTier toTier,
    required double additionalRevenue,
  }) async {
    await _logEvent('subscription_upgraded', parameters: {
      'from_tier': fromTier.name,
      'to_tier': toTier.name,
      'revenue': additionalRevenue,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track subscription downgraded
  static Future<void> trackSubscriptionDowngraded({
    required SubscriptionTier fromTier,
    required SubscriptionTier toTier,
  }) async {
    await _logEvent('subscription_downgraded', parameters: {
      'from_tier': fromTier.name,
      'to_tier': toTier.name,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track premium feature accessed
  static Future<void> trackFeatureAccessed({
    required PremiumFeatureType feature,
    required SubscriptionTier userTier,
    bool wasBlocked = false,
  }) async {
    await _logEvent('feature_accessed', parameters: {
      'feature': feature.name,
      'user_tier': userTier.name,
      'was_blocked': wasBlocked,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track premium feature used
  static Future<void> trackFeatureUsed({
    required PremiumFeatureType feature,
    required SubscriptionTier userTier,
    Map<String, dynamic>? additionalData,
  }) async {
    await _logEvent('feature_used', parameters: {
      'feature': feature.name,
      'user_tier': userTier.name,
      'timestamp': DateTime.now().toIso8601String(),
      ...?additionalData,
    });
  }

  /// Track upgrade prompt shown
  static Future<void> trackUpgradePromptShown({
    required PremiumFeatureType feature,
    required SubscriptionTier requiredTier,
  }) async {
    await _logEvent('upgrade_prompt_shown', parameters: {
      'feature': feature.name,
      'required_tier': requiredTier.name,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track upgrade prompt dismissed
  static Future<void> trackUpgradePromptDismissed({
    required PremiumFeatureType feature,
  }) async {
    await _logEvent('upgrade_prompt_dismissed', parameters: {
      'feature': feature.name,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track upgrade prompt converted
  static Future<void> trackUpgradePromptConverted({
    required PremiumFeatureType feature,
    required SubscriptionTier selectedTier,
  }) async {
    await _logEvent('upgrade_prompt_converted', parameters: {
      'feature': feature.name,
      'selected_tier': selectedTier.name,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track feature comparison viewed
  static Future<void> trackFeatureComparisonViewed() async {
    await _logEvent('feature_comparison_viewed', parameters: {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track FAQ viewed
  static Future<void> trackFAQViewed({
    String? question,
  }) async {
    await _logEvent('faq_viewed', parameters: {
      if (question != null) 'question': question,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track user lifetime value
  static Future<void> updateUserLTV({
    required String userId,
    required double totalRevenue,
    required int subscriptionMonths,
  }) async {
    await _logEvent('user_ltv_updated', parameters: {
      'user_id': userId,
      'total_revenue': totalRevenue,
      'subscription_months': subscriptionMonths,
      'average_revenue_per_month': subscriptionMonths > 0 
          ? totalRevenue / subscriptionMonths 
          : 0,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Set user properties for segmentation
  static Future<void> setUserProperties({
    required String userId,
    required SubscriptionTier tier,
    required SubscriptionStatus status,
    DateTime? subscriptionStartDate,
  }) async {
    await _setUserProperty('subscription_tier', tier.name);
    await _setUserProperty('subscription_status', status.name);
    await _setUserProperty('is_premium', tier != SubscriptionTier.basic);
    
    if (subscriptionStartDate != null) {
      final daysSinceStart = DateTime.now().difference(subscriptionStartDate).inDays;
      await _setUserProperty('subscription_days', daysSinceStart);
    }
  }

  /// Track funnel step (for conversion optimization)
  static Future<void> trackFunnelStep({
    required String step,
    Map<String, dynamic>? additionalData,
  }) async {
    await _logEvent('subscription_funnel', parameters: {
      'step': step,
      'timestamp': DateTime.now().toIso8601String(),
      ...?additionalData,
    });
  }

  // ============ PRIVATE HELPER METHODS ============

  /// Log event to analytics platform
  static Future<void> _logEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) async {
    try {
      debugPrint('📊 Analytics Event: $eventName');
      if (parameters != null) {
        debugPrint('   Parameters: $parameters');
      }

      // TODO: Implement your analytics service
      // Examples:
      
      // Firebase Analytics:
      // await FirebaseAnalytics.instance.logEvent(
      //   name: eventName,
      //   parameters: parameters,
      // );
      
      // Mixpanel:
      // await Mixpanel.track(eventName, properties: parameters);
      
      // Amplitude:
      // Amplitude.getInstance().logEvent(eventName, eventProperties: parameters);
      
      // Custom Analytics:
      // await YourAnalyticsService.trackEvent(eventName, parameters);
      
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Set user property for segmentation
  static Future<void> _setUserProperty(String key, dynamic value) async {
    try {
      debugPrint('👤 User Property: $key = $value');
      
      // TODO: Implement your analytics service
      // Firebase Analytics:
      // await FirebaseAnalytics.instance.setUserProperty(
      //   name: key,
      //   value: value.toString(),
      // );
      
      // Mixpanel:
      // await Mixpanel.getPeople().set(key, value);
      
    } catch (e) {
      debugPrint('❌ User property error: $e');
    }
  }
}
