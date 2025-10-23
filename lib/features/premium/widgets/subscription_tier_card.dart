import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../models/subscription.dart';
import '../models/subscription_plan.dart';

/// Subscription Tier Card Widget
/// Displays a subscription tier with pricing and features
class SubscriptionTierCard extends StatelessWidget {
  final SubscriptionTier tier;
  final SubscriptionBillingCycle billingCycle;
  final bool isPopular;
  final bool isCurrentTier;
  final VoidCallback onSubscribe;

  const SubscriptionTierCard({
    super.key,
    required this.tier,
    required this.billingCycle,
    this.isPopular = false,
    this.isCurrentTier = false,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    final plan = SubscriptionPlan.getPlanForTier(tier, billingCycle);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        children: [
          // Main card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isPopular
                    ? AppTheme.primaryPurple
                    : AppTheme.borderColor,
                width: isPopular ? 2 : 1,
              ),
              boxShadow: isPopular
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryPurple.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tier name and icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _getTierGradient(),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getTierIcon(),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tier.displayName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            _getTierSubtitle(),
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCurrentTier)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'CURRENT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.successGreen,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Pricing
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      plan.currencySymbol,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      plan.price.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '/${billingCycle == SubscriptionBillingCycle.monthly ? 'month' : 'year'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                
                if (billingCycle == SubscriptionBillingCycle.yearly)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${plan.currencySymbol}${(plan.price / 12).toStringAsFixed(2)}/month',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.accentMint,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                
                const SizedBox(height: 24),
                
                // Features list
                ...plan.features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 20,
                        color: AppTheme.primaryPurple,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                
                const SizedBox(height: 24),
                
                // Subscribe button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrentTier ? null : onSubscribe,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPopular
                          ? AppTheme.primaryPurple
                          : AppTheme.secondaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: isPopular ? 4 : 2,
                    ),
                    child: Text(
                      isCurrentTier
                          ? 'Current Plan'
                          : tier == SubscriptionTier.basic
                              ? 'Continue Free'
                              : 'Subscribe Now',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Popular badge
          if (isPopular)
            Positioned(
              top: 0,
              right: 40,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryPurple, AppTheme.secondaryBlue],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'MOST POPULAR',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ).animate().scale(delay: 300.ms),
            ),
        ],
      ),
    );
  }

  List<Color> _getTierGradient() {
    switch (tier) {
      case SubscriptionTier.basic:
        return [AppTheme.mediumGrey, AppTheme.lightGrey];
      case SubscriptionTier.premium:
        return [AppTheme.primaryPurple, AppTheme.secondaryBlue];
      case SubscriptionTier.ultimate:
        return [AppTheme.accentMint, AppTheme.primaryPurple];
    }
  }

  IconData _getTierIcon() {
    switch (tier) {
      case SubscriptionTier.basic:
        return Icons.favorite_border;
      case SubscriptionTier.premium:
        return Icons.auto_awesome;
      case SubscriptionTier.ultimate:
        return Icons.workspace_premium;
    }
  }

  String _getTierSubtitle() {
    switch (tier) {
      case SubscriptionTier.basic:
        return 'Essential features';
      case SubscriptionTier.premium:
        return 'Enhanced AI & analytics';
      case SubscriptionTier.ultimate:
        return 'Complete experience';
    }
  }
}
