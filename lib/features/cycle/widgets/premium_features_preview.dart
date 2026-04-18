import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import 'premium_feature_preview_card.dart';

class PremiumFeaturesPreview extends StatelessWidget {
  final VoidCallback onAICoach;
  final VoidCallback onPartnerSharing;
  final VoidCallback onHealthcarePortal;
  final VoidCallback onAdvancedAnalytics;

  const PremiumFeaturesPreview({
    super.key,
    required this.onAICoach,
    required this.onPartnerSharing,
    required this.onHealthcarePortal,
    required this.onAdvancedAnalytics,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.cardColor,
            AppTheme.primaryPurple.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryPurple.withValues(alpha: 0.1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryPurple, AppTheme.primaryRose],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.stars_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium Advanced Features',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGrey,
                      ),
                    ),
                    Text(
                      'Health Intelligence Features',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryPurple, AppTheme.primaryRose],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'PREVIEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.85,
            children: [
              PremiumFeaturePreviewCard(
                title: 'AI Health Coach',
                description: 'Personal health guidance powered by advanced AI',
                icon: Icons.psychology_rounded,
                color: AppTheme.primaryPurple,
                estimatedDate: 'Q2 2026',
                onTap: onAICoach,
              ),
              PremiumFeaturePreviewCard(
                title: 'Partner Sharing',
                description: 'Securely share cycle data with trusted partners',
                icon: Icons.favorite_rounded,
                color: AppTheme.primaryRose,
                estimatedDate: 'NEW',
                onTap: onPartnerSharing,
              ),
              PremiumFeaturePreviewCard(
                title: 'Healthcare Portal',
                description: 'Export data for medical appointments',
                icon: Icons.medical_services_rounded,
                color: AppTheme.secondaryBlue,
                estimatedDate: 'NEW',
                onTap: onHealthcarePortal,
              ),
              PremiumFeaturePreviewCard(
                title: 'Advanced Analytics',
                description: 'Deep insights with predictive modeling',
                icon: Icons.analytics_rounded,
                color: AppTheme.accentMint,
                estimatedDate: 'NEW',
                onTap: onAdvancedAnalytics,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.3, end: 0);
  }
}
