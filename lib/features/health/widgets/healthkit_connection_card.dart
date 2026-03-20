import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/ui/adaptive_messages.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/health_provider.dart';

/// HealthKit Connection Card
/// Allows users to connect/disconnect HealthKit integration
class HealthKitConnectionCard extends StatelessWidget {
  const HealthKitConnectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<HealthProvider>(
      builder: (context, healthProvider, child) {
        final isConnected = healthProvider.isHealthKitConnected;
        final isIOS = Platform.isIOS;
        final platformName = isIOS ? 'Apple HealthKit' : 'Health Connect';
        final platformShort = isIOS ? 'HealthKit' : 'Health Connect';
        final disclosureLabel = isIOS ? '' : 'Uses Android Health';
        final syncSource = isIOS ? 'Apple Health' : 'Android Health';

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isConnected
                  ? [
                      AppTheme.successGreen.withValues(alpha: 0.1),
                      AppTheme.successGreen.withValues(alpha: 0.05),
                    ]
                  : [
                      AppTheme.secondaryBlue.withValues(alpha: 0.1),
                      AppTheme.secondaryBlue.withValues(alpha: 0.05),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isConnected
                  ? AppTheme.successGreen.withValues(alpha: 0.3)
                  : AppTheme.secondaryBlue.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color:
                          (isConnected
                                  ? AppTheme.successGreen
                                  : AppTheme.secondaryBlue)
                              .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      isConnected
                          ? Icons.check_circle
                          : Icons.health_and_safety,
                      color: isConnected
                          ? AppTheme.successGreen
                          : AppTheme.secondaryBlue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                isConnected
                                    ? '${platformName} Connected'
                                    : 'Connect ${platformName}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (isConnected)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.successGreen.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Connected',
                                  style: TextStyle(
                                    color: AppTheme.successGreen,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Disclosure badge row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryBlue.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                disclosureLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.secondaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isConnected
                              ? 'Health data syncing from ${syncSource}'
                              : 'Sync health data from ${syncSource} & wearables',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => _showHealthKitDisclosure(context),
                          child: Text(
                            'View full disclosure in Settings',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.secondaryBlue,
                              fontSize: 10,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isConnected) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await healthProvider.disconnectHealthKit();
                          if (context.mounted) {
                            AdaptiveMessages.showSuccess(
                              context,
                              '${platformShort} disconnected',
                            );
                          }
                        },
                        icon: const Icon(Icons.link_off, size: 18),
                        label: const Text('Disconnect'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorRed,
                          side: BorderSide(
                            color: AppTheme.errorRed.withValues(alpha: 0.5),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await healthProvider.connectHealthKit(context);
                    },
                    icon: const Icon(Icons.link, size: 20),
                    label: Text('Connect ${platformShort}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
      },
    );
  }

  void _showHealthKitDisclosure(BuildContext context) {
    final theme = Theme.of(context);
    final platformName = Platform.isIOS ? 'Apple HealthKit' : 'Health Connect';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.health_and_safety, color: AppTheme.secondaryBlue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${platformName} Integration',
                style: TextStyle(color: AppTheme.secondaryBlue),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warningOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.warningOrange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: AppTheme.warningOrange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Required Disclosure',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.warningOrange,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            Platform.isIOS ? 'App Store Guideline 2.5.1 - HealthKit Transparency' : 'Health Connect data disclosure',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.warningOrange.withValues(
                                alpha: 0.9,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Flow Ai uses ${platformName} to access your health data for enhanced cycle predictions and personalized insights.',
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Health data we may access:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildDisclosureItem(
                theme,
                Icons.favorite,
                'Heart rate & HRV for cycle correlation',
              ),
              _buildDisclosureItem(
                theme,
                Icons.thermostat,
                'Body temperature for ovulation tracking',
              ),
              _buildDisclosureItem(
                theme,
                Icons.bedtime,
                'Sleep data for pattern analysis',
              ),
              _buildDisclosureItem(
                theme,
                Icons.directions_walk,
                'Activity & steps for wellness insights',
              ),
              _buildDisclosureItem(
                theme,
                Icons.water_drop,
                'Menstrual flow data (if tracked in HealthKit)',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.successGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 18,
                      color: AppTheme.successGreen,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This data is used exclusively to provide personalized cycle predictions, health insights, and pattern detection. We never sell or share your health data.',
                        style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                Platform.isIOS ? 'You can manage HealthKit access at any time in iOS Settings → Health → Data Access & Devices.' : 'You can manage Health Connect access at any time in Android Settings → Apps → Health Connect → App permissions.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclosureItem(ThemeData theme, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.secondaryBlue.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
