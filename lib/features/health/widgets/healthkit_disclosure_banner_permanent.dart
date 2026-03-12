import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'dart:io';

/// Permanent HealthKit disclosure banner
/// Required by App Store Guideline 2.5.1 - HealthKit Transparency
/// Must clearly identify HealthKit functionality in UI
class HealthKitDisclosureBannerPermanent extends StatelessWidget {
  const HealthKitDisclosureBannerPermanent({super.key});

  @override
  Widget build(BuildContext context) {
    final platformName = Platform.isIOS ? 'Apple HealthKit' : 'Health Connect';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.secondaryBlue.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - clearly identifies HealthKit usage (Apple requirement)
          Row(
            children: [
              Icon(
                Icons.health_and_safety,
                color: AppTheme.secondaryBlue,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${platformName} Integration',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Purpose statement (Apple requirement: explain why data is used)
          Text(
            Platform.isIOS ? 'Flow Ai uses Apple HealthKit to access your health data for enhanced cycle predictions and personalized insights.' : 'Flow Ai uses Health Connect to access your health data for enhanced cycle predictions and personalized insights.',
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 12),

          // Data types accessed - inline summary (Apple requirement: list data types)
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildChip(Icons.favorite, 'Heart rate'),
              _buildChip(Icons.thermostat, 'Temperature'),
              _buildChip(Icons.bedtime, 'Sleep'),
              _buildChip(Icons.directions_walk, 'Activity'),
            ],
          ),
          const SizedBox(height: 12),

          // Privacy statement (Apple requirement: explain data usage)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lock_outline, size: 16, color: AppTheme.successGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Used exclusively for cycle predictions and health insights. We never sell or share your health data.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.4,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // User control instructions (Apple requirement: explain how to manage)
          Text(
            Platform.isIOS ? 'Manage in Settings → Health → Data Access & Devices' : 'Manage in Settings → Apps → Health Connect → App permissions',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBlue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppTheme.secondaryBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.secondaryBlue),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.secondaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
