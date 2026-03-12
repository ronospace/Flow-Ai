import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../generated/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import 'dart:io';

/// HealthKit/Health Data Transparency Disclosure Banner
/// Required by App Store Guideline 2.5.1 for transparency in health data usage
class HealthKitDisclosureBanner extends StatelessWidget {
  final VoidCallback? onDismiss;
  final bool showDismissButton;

  /// Whether this is the first-time disclosure (non-dismissible for compliance)
  final bool isFirstTimeDisclosure;

  const HealthKitDisclosureBanner({
    super.key,
    this.onDismiss,
    this.showDismissButton = false,
    this.isFirstTimeDisclosure =
        false, // First-time disclosures cannot be dismissed (App Store 2.5.1)
  });

  @override
  Widget build(BuildContext context) {
    final platformName = Platform.isIOS ? 'Apple HealthKit' : 'Health Connect';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.secondaryBlue.withValues(alpha: 0.1),
            AppTheme.primaryPurple.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.secondaryBlue.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with icon - Enhanced for App Store compliance (2.5.1)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.health_and_safety_outlined,
                  color: AppTheme.secondaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${platformName} Integration',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryBlue,
                      ),
                    ),
                    Text(
                      'Required disclosure per App Store guidelines',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              // Only show dismiss button if not first-time disclosure (App Store compliance)
              if (showDismissButton && !isFirstTimeDisclosure)
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 20,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Disclosure text - Enhanced for clarity (App Store 2.5.1)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.secondaryBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.secondaryBlue.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: AppTheme.secondaryBlue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'HealthKit Usage Disclosure',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  Platform.isIOS ? 'Flow Ai uses Apple HealthKit to access your health data for enhanced cycle predictions and personalized insights.' : 'Flow Ai uses Health Connect to access your health data for enhanced cycle predictions and personalized insights.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // What we collect section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'We may access:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
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
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Purpose statement
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 18, color: AppTheme.primaryPurple),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'This data is used exclusively to provide personalized cycle predictions, health insights, and pattern detection. We never sell or share your health data.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _launchPrivacyPolicy(),
                  icon: Icon(Icons.privacy_tip_outlined, size: 18),
                  label: Text('Privacy Policy'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.secondaryBlue,
                    side: BorderSide(
                      color: AppTheme.secondaryBlue.withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showPermissionsHelp(context),
                  icon: Icon(Icons.settings_outlined, size: 18),
                  label: Text('Manage'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Optional toggle note
          Text(
            Platform.isIOS ? 'HealthKit integration is optional. You can enable or disable it any time in iOS Settings → Health → Data Access & Devices.' : 'Health Connect integration is optional. You can manage it any time in Android Settings → Apps → Health Connect → App permissions.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 11,
              height: 1.3,
            ),
          ),
        ],
      ),
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
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _launchPrivacyPolicy() async {
    final url = Uri.parse('https://flowiq.app/privacy');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showPermissionsHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.settings, color: AppTheme.secondaryBlue),
            const SizedBox(width: 12),
            Text('Manage Health Permissions'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To manage health data permissions:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildStepItem(context, '1', 'Open device Settings'),
            _buildStepItem(context, '2', 'Tap Health → Data Access & Devices'),
            _buildStepItem(context, '3', 'Select "Flow Ai"'),
            _buildStepItem(context, '4', 'Toggle permissions on/off'),
            const SizedBox(height: 12),
            Text(
              'The app works without HealthKit access, but insights will be limited to manually tracked data.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(BuildContext context, String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.secondaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryBlue,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(text),
            ),
          ),
        ],
      ),
    );
  }
}
