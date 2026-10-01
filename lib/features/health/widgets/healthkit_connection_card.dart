import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/health_provider.dart';
import 'healthkit_permission_dialog.dart';
import '../../../core/ui/app_geometry.dart';

/// HealthKit Connection Card
/// Allows users to connect/disconnect HealthKit integration
class HealthKitConnectionCard extends StatelessWidget {
  const HealthKitConnectionCard({super.key});

  Widget _buildConnectionAction({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    Color? foregroundColor,
    bool showProgress = false,
  }) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.70,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: showProgress
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon, size: 20),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: foregroundColor ?? Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppGeometry.radiusSm),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isIOS && !Platform.isAndroid) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Consumer<HealthProvider>(
      builder: (context, healthProvider, child) {
        final hasAccess = healthProvider.hasHealthDataAccess;
        final isIOS = Platform.isIOS;
        final isAndroidConnecting =
            Platform.isAndroid && healthProvider.isConnectingHealthData;
        final platformName = isIOS ? 'Apple HealthKit' : 'Health Connect';
        const String? disclosureLabel = null;
        final syncSource = isIOS ? 'Apple Health' : 'Android Health';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: hasAccess
                  ? [
                      AppTheme.successGreen.withValues(alpha: 0.1),
                      AppTheme.successGreen.withValues(alpha: 0.05),
                    ]
                  : [
                      AppTheme.secondaryBlue.withValues(alpha: 0.1),
                      AppTheme.secondaryBlue.withValues(alpha: 0.05),
                    ],
            ),
            borderRadius: BorderRadius.circular(AppGeometry.radiusSm),
            border: Border.all(
              color: hasAccess
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
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color:
                          (hasAccess
                                  ? AppTheme.successGreen
                                  : AppTheme.secondaryBlue)
                              .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      hasAccess ? Icons.check_circle : Icons.health_and_safety,
                      color: hasAccess
                          ? AppTheme.successGreen
                          : AppTheme.secondaryBlue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),

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
                                platformName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            if (hasAccess)
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
                                  borderRadius: BorderRadius.circular(
                                    AppGeometry.radiusSm,
                                  ),
                                ),
                                child: Text(
                                  'Access Granted',
                                  style: TextStyle(
                                    color: AppTheme.successGreen,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (disclosureLabel != null) ...[
                          const SizedBox(height: 6),
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
                        ],
                        const SizedBox(height: 4),
                        Text(
                          'Flow Ai can read the health data you choose to share through $syncSource.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              AppGeometry.radiusSm,
                            ),
                            onTap: () =>
                                HealthKitPermissionDialog.showDetails(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryBlue.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppGeometry.radiusSm,
                                ),
                                border: Border.all(
                                  color: AppTheme.secondaryBlue.withValues(
                                    alpha: 0.22,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Privacy details',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.secondaryBlue,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (hasAccess) ...[
                const SizedBox(height: 12),
                _buildConnectionAction(
                  label: 'Disconnect',
                  icon: Icons.link_off,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.disconnectCautionDark
                      : AppTheme.disconnectCaution,
                  foregroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.onDisconnectCautionDark
                      : AppTheme.onDisconnectCaution,
                  onPressed: () async {
                    await healthProvider.disconnectHealthKit();
                  },
                ),
              ] else ...[
                const SizedBox(height: 12),
                if (Platform.isAndroid &&
                    healthProvider.requiresHealthConnectInstallOrUpdate) ...[
                  Text(
                    'Health Connect is required on this Android device before '
                    'Flow Ai can read health data.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await healthProvider.installHealthConnect();
                      },
                      icon: const Icon(Icons.download, size: 20),
                      label: const Text('Install Health Connect'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppGeometry.radiusSm,
                          ),
                        ),
                      ),
                    ),
                  ),
                ] else if (Platform.isAndroid &&
                    healthProvider.isHealthConnectUnsupported) ...[
                  Text(
                    'Health Connect is unavailable on this Android device.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ] else ...[
                  _buildConnectionAction(
                    label: isAndroidConnecting ? 'Connecting…' : 'Connect',
                    icon: Icons.link,
                    color: AppTheme.secondaryBlue,
                    showProgress: isAndroidConnecting,
                    onPressed: isAndroidConnecting
                        ? null
                        : () async {
                            await healthProvider.connectHealthKit(context);
                          },
                  ),
                ],
              ],
            ],
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
      },
    );
  }
}
