import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/onboarding_step.dart';
import '../../../generated/app_localizations.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingStep step;
  final VoidCallback? onPermissionRequest;

  const OnboardingPage({
    super.key,
    required this.step,
    this.onPermissionRequest,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          _buildIllustration(theme),
          const SizedBox(height: 40),
          
          // Title
          Text(
            step.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Description
          Text(
            step.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Highlights
          _buildHighlights(theme),
          
          // Permission-specific content
          if (step.type == OnboardingStepType.permissions)
            _buildPermissionContent(theme, localizations),
        ],
      ),
    );
  }

  Widget _buildIllustration(ThemeData theme) {
    return Container(
      height: 200,
      width: 200,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Icon(
          _getStepIcon(),
          size: 80,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  IconData _getStepIcon() {
    switch (step.type) {
      case OnboardingStepType.welcome:
        return Icons.favorite;
      case OnboardingStepType.features:
        return Icons.auto_awesome;
      case OnboardingStepType.privacy:
        return Icons.security;
      case OnboardingStepType.permissions:
        return Icons.notifications_active;
      case OnboardingStepType.setup:
        return Icons.settings;
      case OnboardingStepType.complete:
        return Icons.check_circle;
    }
  }

  Widget _buildHighlights(ThemeData theme) {
    return Column(
      children: step.highlights.map((highlight) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  highlight,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPermissionContent(ThemeData theme, AppLocalizations localizations) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tap "Allow" on the next screen to enable notifications',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            HapticFeedback.lightImpact();
            onPermissionRequest?.call();
          },
          icon: const Icon(Icons.notifications_active),
          label: const Text('Enable Notifications'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
