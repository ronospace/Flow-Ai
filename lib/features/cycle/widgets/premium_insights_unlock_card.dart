import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/app_localizations.dart';

class PremiumInsightsUnlockCard extends StatelessWidget {
  final ThemeData theme;
  final AppLocalizations localizations;
  final VoidCallback onWatchAd;

  const PremiumInsightsUnlockCard({
    super.key,
    required this.theme,
    required this.localizations,
    required this.onWatchAd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.warningOrange.withValues(alpha: 0.1),
            AppTheme.primaryRose.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.warningOrange.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.warningOrange, AppTheme.primaryRose],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.star,
                  color: theme.colorScheme.onPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.unlockPremiumAiInsights,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    Text(
                      localizations.watchAdToUnlockInsights,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.warningOrange, AppTheme.primaryRose],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  localizations.free,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onWatchAd,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.warningOrange, AppTheme.primaryRose],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.warningOrange.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_circle_fill,
                      color: theme.colorScheme.onPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      localizations.watchAdUnlockInsights,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.sweetPeach, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  localizations.getAdditionalPremiumInsights,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.sweetPeach, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  localizations.unlockAdvancedHealthRecommendations,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.95, 0.95));
  }
}
