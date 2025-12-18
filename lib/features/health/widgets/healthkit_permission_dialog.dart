import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Mandatory HealthKit disclosure dialog
/// Shows BEFORE requesting HealthKit permissions (App Store Guideline 2.5.1)
/// This ensures users are informed about HealthKit usage before any data access
class HealthKitPermissionDialog extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback? onDecline;

  const HealthKitPermissionDialog({
    super.key,
    required this.onAccept,
    this.onDecline,
  });

  static Future<bool?> show(
    BuildContext context, {
    required VoidCallback onAccept,
    VoidCallback? onDecline,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // Cannot dismiss without action
      builder: (context) =>
          HealthKitPermissionDialog(onAccept: onAccept, onDecline: onDecline),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.secondaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.health_and_safety,
              color: AppTheme.secondaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Apple HealthKit Integration',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryBlue,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Required disclosure text - Enhanced prominence
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.warningOrange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.warningOrange,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.gavel,
                    size: 20,
                    color: AppTheme.warningOrange,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Required Disclosure',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.warningOrange,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'App Store Guideline 2.5.1 - HealthKit Transparency',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.warningOrange.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Main disclosure
            Text(
              'Flow Ai uses Apple HealthKit to access your health data for enhanced cycle predictions and personalized insights.',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // What we access
            Text(
              'We may access the following health data:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDataItem(
              context,
              Icons.favorite,
              'Heart rate & HRV for cycle correlation',
            ),
            _buildDataItem(
              context,
              Icons.thermostat,
              'Body temperature for ovulation tracking',
            ),
            _buildDataItem(
              context,
              Icons.bedtime,
              'Sleep data for pattern analysis',
            ),
            _buildDataItem(
              context,
              Icons.directions_walk,
              'Activity & steps for wellness insights',
            ),
            _buildDataItem(
              context,
              Icons.water_drop,
              'Menstrual flow data (if tracked in HealthKit)',
            ),
            const SizedBox(height: 16),

            // Purpose
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.secondaryBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: AppTheme.secondaryBlue,
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

            // Optional note
            Text(
              'HealthKit integration is optional. You can enable or disable at any time in Settings → Health → Data Access & Devices.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            onDecline?.call();
          },
          child: Text('Not Now'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onAccept();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.secondaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text('Continue'),
        ),
      ],
    );
  }

  Widget _buildDataItem(BuildContext context, IconData icon, String text) {
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
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
