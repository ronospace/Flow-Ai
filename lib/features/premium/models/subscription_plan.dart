import 'subscription.dart';

/// Subscription Billing Cycle
enum SubscriptionBillingCycle { monthly, yearly }

/// Subscription plan metadata
class SubscriptionPlan {
  final String id;
  final String name;
  final SubscriptionTier tier;
  final SubscriptionBillingCycle billingCycle;
  final List<String> features;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.tier,
    required this.billingCycle,
    required this.features,
  });

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
      features: [
        'Everything in Basic',
        'Advanced AI predictions',
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
