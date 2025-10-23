import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../models/subscription.dart';
import '../models/premium_feature.dart';

/// Upgrade Prompt Dialog
/// Shows when users try to access premium features
class UpgradePromptDialog extends StatelessWidget {
  final PremiumFeatureType blockedFeature;
  final SubscriptionTier requiredTier;

  const UpgradePromptDialog({
    super.key,
    required this.blockedFeature,
    required this.requiredTier,
  });

  /// Show the upgrade dialog
  static Future<bool?> show(
    BuildContext context, {
    required PremiumFeatureType blockedFeature,
    required SubscriptionTier requiredTier,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => UpgradePromptDialog(
        blockedFeature: blockedFeature,
        requiredTier: requiredTier,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: AppTheme.cardColor,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.cardColor,
              AppTheme.primaryPurple.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Premium icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryPurple,
                    AppTheme.secondaryBlue,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 40,
                color: Colors.white,
              ),
            ).animate().scale(duration: 400.ms),
            
            const SizedBox(height: 20),
            
            // Title
            Text(
              'Premium Feature',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ).animate().fadeIn(delay: 200.ms),
            
            const SizedBox(height: 8),
            
            // Feature name
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                blockedFeature.displayName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryPurple,
                ),
              ),
            ).animate().fadeIn(delay: 300.ms),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              blockedFeature.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ).animate().fadeIn(delay: 400.ms),
            
            const SizedBox(height: 24),
            
            // Required tier badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getTierGradient(),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getTierIcon(),
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Requires ${requiredTier.displayName}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms),
            
            const SizedBox(height: 24),
            
            // Benefits list
            _buildBenefitsList(),
            
            const SizedBox(height: 24),
            
            // Upgrade button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  context.push('/premium/paywall');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Upgrade Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
            
            const SizedBox(height: 12),
            
            // Cancel button
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Maybe Later',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ).animate().fadeIn(delay: 700.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsList() {
    final benefits = _getFeatureBenefits();
    
    return Column(
      children: benefits.map((benefit) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 20,
                color: AppTheme.successGreen,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  benefit,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<String> _getFeatureBenefits() {
    switch (blockedFeature) {
      case PremiumFeatureType.advancedAI:
        return [
          '95%+ prediction accuracy',
          'Personalized insights',
          'Advanced pattern detection',
        ];
      case PremiumFeatureType.unlimitedExports:
        return [
          'Export anytime you want',
          'Multiple file formats',
          'Share with healthcare providers',
        ];
      case PremiumFeatureType.customReports:
        return [
          'Detailed health reports',
          'Customizable data views',
          'Track trends over time',
        ];
      case PremiumFeatureType.healthcareIntegration:
        return [
          'Connect with doctors',
          'Share reports securely',
          'Get professional insights',
        ];
      case PremiumFeatureType.biometricSync:
        return [
          'Sync with Apple Health',
          'Connect wearable devices',
          'Automatic data updates',
        ];
      case PremiumFeatureType.advancedAnalytics:
        return [
          'Deep data analysis',
          'Predictive modeling',
          'Comprehensive health metrics',
        ];
      case PremiumFeatureType.multiUserProfiles:
        return [
          'Manage up to 5 profiles',
          'Family health tracking',
          'Individual privacy controls',
        ];
      default:
        return [
          'Access premium features',
          'Enhanced functionality',
          'Priority support',
        ];
    }
  }

  List<Color> _getTierGradient() {
    switch (requiredTier) {
      case SubscriptionTier.basic:
        return [AppTheme.mediumGrey, AppTheme.lightGrey];
      case SubscriptionTier.premium:
        return [AppTheme.primaryPurple, AppTheme.secondaryBlue];
      case SubscriptionTier.ultimate:
        return [AppTheme.accentMint, AppTheme.primaryPurple];
    }
  }

  IconData _getTierIcon() {
    switch (requiredTier) {
      case SubscriptionTier.basic:
        return Icons.favorite;
      case SubscriptionTier.premium:
        return Icons.auto_awesome;
      case SubscriptionTier.ultimate:
        return Icons.workspace_premium;
    }
  }
}

/// Helper extension for showing upgrade prompts
extension PremiumFeatureGating on BuildContext {
  /// Show upgrade prompt for a blocked feature
  Future<bool> requiresPremium({
    required PremiumFeatureType feature,
    required SubscriptionTier tier,
  }) async {
    final result = await UpgradePromptDialog.show(
      this,
      blockedFeature: feature,
      requiredTier: tier,
    );
    return result ?? false;
  }
}
