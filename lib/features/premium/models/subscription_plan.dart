import 'subscription.dart';

/// Subscription Billing Cycle
enum SubscriptionBillingCycle {
  monthly,
  yearly,
}

/// Subscription Plan with pricing details
class SubscriptionPlan {
  final String id;
  final String name;
  final SubscriptionTier tier;
  final SubscriptionBillingCycle billingCycle;
  final double price;
  final String currencySymbol;
  final String currencyCode;
  final List<String> features;
  final String productId; // For in-app purchase
  final double? discount; // Percentage discount (e.g., 0.20 for 20%)

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.tier,
    required this.billingCycle,
    required this.price,
    this.currencySymbol = '\$',
    this.currencyCode = 'USD',
    required this.features,
    required this.productId,
    this.discount,
  });

  /// Get price per month (for annual plans)
  double get pricePerMonth {
    return billingCycle == SubscriptionBillingCycle.yearly ? price / 12 : price;
  }

  /// Get total savings compared to monthly (for annual plans)
  double getSavingsComparedToMonthly(double monthlyPrice) {
    if (billingCycle != SubscriptionBillingCycle.yearly) return 0;
    return (monthlyPrice * 12) - price;
  }

  /// Get savings percentage
  double getSavingsPercentage(double monthlyPrice) {
    if (billingCycle != SubscriptionBillingCycle.yearly) return 0;
    final savings = getSavingsComparedToMonthly(monthlyPrice);
    return (savings / (monthlyPrice * 12)) * 100;
  }

  /// Create a plan for a specific tier and billing cycle
  static SubscriptionPlan getPlanForTier(
    SubscriptionTier tier,
    SubscriptionBillingCycle billingCycle,
  ) {
    switch (tier) {
      case SubscriptionTier.basic:
        return _createBasicPlan(billingCycle);
      case SubscriptionTier.premium:
        return _createPremiumPlan(billingCycle);
      case SubscriptionTier.ultimate:
        return _createUltimatePlan(billingCycle);
    }
  }

  static SubscriptionPlan _createBasicPlan(SubscriptionBillingCycle cycle) {
    return SubscriptionPlan(
      id: 'basic_${cycle.name}',
      name: 'Basic',
      tier: SubscriptionTier.basic,
      billingCycle: cycle,
      price: 0.0,
      productId: 'com.zyraflow.basic',
      features: [
        'Period tracking',
        'Basic predictions',
        'Limited exports (3/month)',
        'Community access',
      ],
    );
  }

  static SubscriptionPlan _createPremiumPlan(SubscriptionBillingCycle cycle) {
    final isYearly = cycle == SubscriptionBillingCycle.yearly;
    return SubscriptionPlan(
      id: 'premium_${cycle.name}',
      name: 'Premium',
      tier: SubscriptionTier.premium,
      billingCycle: cycle,
      price: isYearly ? 79.99 : 9.99,
      productId: isYearly 
          ? 'com.zyraflow.premium.yearly'
          : 'com.zyraflow.premium.monthly',
      discount: isYearly ? 0.20 : null, // 20% discount on annual
      features: [
        'Everything in Basic',
        'Advanced AI predictions (95% accuracy)',
        'Unlimited exports',
        'Custom health reports',
        'Healthcare integration',
        'Priority support',
        'Biometric data sync',
        'Ad-free experience',
      ],
    );
  }

  static SubscriptionPlan _createUltimatePlan(SubscriptionBillingCycle cycle) {
    final isYearly = cycle == SubscriptionBillingCycle.yearly;
    return SubscriptionPlan(
      id: 'ultimate_${cycle.name}',
      name: 'Ultimate',
      tier: SubscriptionTier.ultimate,
      billingCycle: cycle,
      price: isYearly ? 119.99 : 14.99,
      productId: isYearly
          ? 'com.zyraflow.ultimate.yearly'
          : 'com.zyraflow.ultimate.monthly',
      discount: isYearly ? 0.20 : null, // 20% discount on annual
      features: [
        'Everything in Premium',
        'Multi-user profiles (up to 5)',
        'Advanced analytics dashboard',
        'Predictive health modeling',
        'Export to healthcare providers',
        'White-glove support',
        'Early access to new features',
        'Lifetime data storage',
      ],
    );
  }

  /// Get all available plans
  static List<SubscriptionPlan> get allPlans => [
        _createBasicPlan(SubscriptionBillingCycle.monthly),
        _createBasicPlan(SubscriptionBillingCycle.yearly),
        _createPremiumPlan(SubscriptionBillingCycle.monthly),
        _createPremiumPlan(SubscriptionBillingCycle.yearly),
        _createUltimatePlan(SubscriptionBillingCycle.monthly),
        _createUltimatePlan(SubscriptionBillingCycle.yearly),
      ];

  /// Get plans for a specific billing cycle
  static List<SubscriptionPlan> getPlansForCycle(
    SubscriptionBillingCycle cycle,
  ) {
    return [
      _createBasicPlan(cycle),
      _createPremiumPlan(cycle),
      _createUltimatePlan(cycle),
    ];
  }
}
