import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_upcoming_feature_status.dart';

class PremiumFeaturePreviewCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String estimatedDate;
  final AppFeatureAvailability availability;
  final bool isPremiumLocked;
  final VoidCallback onTap;

  const PremiumFeaturePreviewCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.estimatedDate,
    this.availability = AppFeatureAvailability.active,
    this.isPremiumLocked = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [theme.cardColor, color.withValues(alpha: 0.06)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                HapticFeedback.lightImpact();
                onTap();
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, color: color, size: 18),
                        ),
                        const Spacer(),
                        AppUpcomingFeatureStatus(
                          releaseLabel: isPremiumLocked ? 'PRO' : estimatedDate,
                          availability: availability,
                          compact: true,
                          color: isPremiumLocked
                              ? AppTheme.primaryPurple
                              : AppTheme.warningOrange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      maxLines: 2,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        fontSize: 13,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Expanded(
                      flex: 2,
                      child: Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.28,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          isPremiumLocked
                              ? Icons.lock_rounded
                              : Icons.schedule_rounded,
                          color: isPremiumLocked
                              ? AppTheme.primaryPurple
                              : color,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            isPremiumLocked
                                ? 'Premium'
                                : availability ==
                                      AppFeatureAvailability.comingSoon
                                ? 'Coming Soon'
                                : 'Active',
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isPremiumLocked
                                  ? AppTheme.primaryPurple
                                  : color,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 10,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .shimmer(duration: 4000.ms, color: color.withValues(alpha: 0.03))
        .then(delay: 3000.ms);
  }
}
