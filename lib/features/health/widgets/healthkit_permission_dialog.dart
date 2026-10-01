import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'dart:io';

/// Mandatory HealthKit disclosure dialog
/// Shows BEFORE requesting health data permissions.
/// This ensures users are informed about health platform access before any data access.
class HealthKitPermissionDialog extends StatelessWidget {
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final bool informationOnly;

  const HealthKitPermissionDialog({
    super.key,
    this.onAccept,
    this.onDecline,
    this.informationOnly = false,
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

  static Future<bool?> showDetails(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) =>
          const HealthKitPermissionDialog(informationOnly: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final platformName = Platform.isIOS ? 'Apple HealthKit' : 'Health Connect';

    final viewportHeight = MediaQuery.sizeOf(context).height;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      actionsAlignment: MainAxisAlignment.center,
      shape: AppTheme.dialogShape,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.secondaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.health_and_safety,
              color: AppTheme.secondaryBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$platformName',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryBlue,
              ),
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 440,
          maxHeight: viewportHeight * 0.52,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Required disclosure text - Enhanced prominence
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.warningOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.warningOrange, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.gavel, size: 18, color: AppTheme.warningOrange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Health data access',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.warningOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Main disclosure
              Text(
                'Flow Ai can read health data you choose to share to support '
                'cycle tracking and wellness insights.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 10),

              // What we access
              Text(
                'Data you can share:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildDataItem(
                context,
                Icons.favorite,
                Platform.isIOS ? 'Heart rate and HRV' : 'Heart rate',
              ),
              _buildDataItem(context, Icons.thermostat, 'Body temperature'),
              _buildDataItem(context, Icons.bedtime, 'Sleep'),
              _buildDataItem(context, Icons.directions_walk, 'Sleep duration'),
              _buildDataItem(context, Icons.water_drop, 'Menstrual flow'),
              const SizedBox(height: 10),

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
                        'Used only for app features. Flow Ai does not sell or '
                        'share your health data.',
                        style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Optional note
              Text(
                Platform.isIOS
                    ? 'Optional - change access anytime in iOS Settings - Health - '
                          'Data Access & Devices.'
                    : 'Optional - change access anytime in Android Settings - Apps - '
                          'Health Connect - App permissions.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: informationOnly
          ? [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: AppTheme.dialogSecondaryActionStyle(theme),
                child: const Text('Close'),
              ),
            ]
          : [
              SizedBox(
                width: 124,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                    onDecline?.call();
                  },
                  style: AppTheme.dialogSecondaryActionStyle(theme),
                  child: const Text('Not Now'),
                ),
              ),
              SizedBox(
                width: 124,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    onAccept?.call();
                  },
                  style: AppTheme.dialogPrimaryActionStyle(theme),
                  child: const Text('Continue'),
                ),
              ),
            ],
    );
  }

  Widget _buildDataItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
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
