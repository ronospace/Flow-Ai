import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import 'modern_button.dart';

enum ComingSoonType {
  feature,
  enhancement,
  premium,
  beta,
}

class ComingSoonCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final ComingSoonType type;
  final String? releaseEstimate;
  final VoidCallback? onNotifyMeTapped;
  final Color? accentColor;
  final List<String>? features;

  const ComingSoonCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.type = ComingSoonType.feature,
    this.releaseEstimate,
    this.onNotifyMeTapped,
    this.accentColor,
    this.features,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveAccentColor = accentColor ?? _getTypeColor();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.cardColor,
            theme.cardColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: effectiveAccentColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: effectiveAccentColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  effectiveAccentColor.withValues(alpha: 0.1),
                  effectiveAccentColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(23),
                topRight: Radius.circular(23),
              ),
            ),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        effectiveAccentColor,
                        effectiveAccentColor.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: effectiveAccentColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Title and Type Badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: effectiveAccentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: effectiveAccentColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _getTypeLabel(),
                          style: TextStyle(
                            color: effectiveAccentColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Sparkle Animation
                const Icon(
                  Icons.auto_awesome,
                  color: AppTheme.accentMint,
                  size: 24,
                ).animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                ).scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.2, 1.2),
                  duration: 2.seconds,
                ).then(delay: 1.seconds),
              ],
            ),
          ),
          
          // Content Section
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.mediumGrey,
                    height: 1.6,
                  ),
                ),
                
                if (features != null && features!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'What\'s Coming:',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...features!.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(top: 8, right: 12),
                          decoration: BoxDecoration(
                            color: effectiveAccentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            feature,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.mediumGrey,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
                
                if (releaseEstimate != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.secondaryBlue.withValues(alpha: 0.1),
                          AppTheme.accentMint.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.secondaryBlue.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          color: AppTheme.secondaryBlue,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Expected: $releaseEstimate',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.secondaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Action Button
                if (onNotifyMeTapped != null)
                  ModernButton(
                    text: '🔔 Notify Me When Ready',
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onNotifyMeTapped!();
                    },
                    type: ModernButtonType.outline,
                    size: ModernButtonSize.medium,
                    gradientColors: [effectiveAccentColor, effectiveAccentColor.withValues(alpha: 0.8)],
                    isExpanded: true,
                  )
                else
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            effectiveAccentColor.withValues(alpha: 0.1),
                            effectiveAccentColor.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: effectiveAccentColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.construction_rounded,
                            color: effectiveAccentColor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'In Development',
                            style: TextStyle(
                              color: effectiveAccentColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0);
  }

  Color _getTypeColor() {
    switch (type) {
      case ComingSoonType.feature:
        return AppTheme.primaryRose;
      case ComingSoonType.enhancement:
        return AppTheme.secondaryBlue;
      case ComingSoonType.premium:
        return AppTheme.primaryPurple;
      case ComingSoonType.beta:
        return AppTheme.accentMint;
    }
  }

  String _getTypeLabel() {
    switch (type) {
      case ComingSoonType.feature:
        return 'NEW FEATURE';
      case ComingSoonType.enhancement:
        return 'ENHANCEMENT';
      case ComingSoonType.premium:
        return 'PREMIUM';
      case ComingSoonType.beta:
        return 'BETA';
    }
  }
}

// Convenience constructors for different types
class ComingSoonCards {
  static Widget feature({
    required String title,
    required String description,
    required IconData icon,
    String? releaseEstimate,
    VoidCallback? onNotifyMeTapped,
    List<String>? features,
  }) {
    return ComingSoonCard(
      title: title,
      description: description,
      icon: icon,
      type: ComingSoonType.feature,
      releaseEstimate: releaseEstimate,
      onNotifyMeTapped: onNotifyMeTapped,
      features: features,
    );
  }

  static Widget premium({
    required String title,
    required String description,
    required IconData icon,
    String? releaseEstimate,
    VoidCallback? onNotifyMeTapped,
    List<String>? features,
  }) {
    return ComingSoonCard(
      title: title,
      description: description,
      icon: icon,
      type: ComingSoonType.premium,
      releaseEstimate: releaseEstimate,
      onNotifyMeTapped: onNotifyMeTapped,
      features: features,
    );
  }

  static Widget enhancement({
    required String title,
    required String description,
    required IconData icon,
    String? releaseEstimate,
    VoidCallback? onNotifyMeTapped,
    List<String>? features,
  }) {
    return ComingSoonCard(
      title: title,
      description: description,
      icon: icon,
      type: ComingSoonType.enhancement,
      releaseEstimate: releaseEstimate,
      onNotifyMeTapped: onNotifyMeTapped,
      features: features,
    );
  }

  static Widget beta({
    required String title,
    required String description,
    required IconData icon,
    String? releaseEstimate,
    VoidCallback? onNotifyMeTapped,
    List<String>? features,
  }) {
    return ComingSoonCard(
      title: title,
      description: description,
      icon: icon,
      type: ComingSoonType.beta,
      releaseEstimate: releaseEstimate,
      onNotifyMeTapped: onNotifyMeTapped,
      features: features,
    );
  }
}
