import 'dart:async';
import 'package:flutter/material.dart';
import '../services/app_runtime_metadata_service.dart';

class AdaptiveMessages {
  static String? _lastError;
  static DateTime? _lastErrorTime;

  static Future<void> showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 1600),
  }) async {
    _showSnack(
      context,
      message,
      const Color(0xFF1E8E3E),
      duration,
      icon: Icons.check_circle_rounded,
    );
  }

  static Future<void> showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 1700),
  }) async {
    _showSnack(
      context,
      message,
      const Color(0xFF2563EB),
      duration,
      icon: Icons.info_rounded,
    );
  }

  static Future<void> showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 1900),
  }) async {
    _showSnack(
      context,
      message,
      const Color(0xFFF59E0B),
      duration,
      icon: Icons.warning_amber_rounded,
    );
  }

  static Future<void> showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 2200),
  }) async {
    final now = DateTime.now();

    if (_lastError == message &&
        _lastErrorTime != null &&
        now.difference(_lastErrorTime!).inSeconds < 4) {
      return;
    }

    _lastError = message;
    _lastErrorTime = now;

    _showSnack(
      context,
      message,
      const Color(0xFFDC2626),
      duration,
      icon: Icons.error_outline_rounded,
    );
  }

  static void _showSnack(
    BuildContext context,
    String message,
    Color color,
    Duration duration, {
    required IconData icon,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          duration: duration,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          content: Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: color.withValues(alpha: 0.45),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  /// Central Flow Ai About surface.
  ///
  /// Uses one visual rhythm and equal-width actions instead of Flutter's
  /// stock AboutDialog/AlertDialog action layout.
  static Future<void> showFlowAiAbout(BuildContext context) async {
    final metadata = await AppRuntimeMetadataService.instance.packageInfo;

    if (!context.mounted) return;

    const legalese = '© 2026 Flow Ai. All rights reserved.';
    const description =
        'AI-powered menstrual cycle tracking for better reproductive health.';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Flow Ai',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    metadata.version,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Divider(height: 1, color: theme.colorScheme.outlineVariant),
                  const SizedBox(height: 20),
                  Text(
                    legalese,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.4,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            onPressed: () {
                              showLicensePage(
                                context: dialogContext,
                                applicationName: 'Flow Ai',
                                applicationVersion: metadata.version,
                                applicationLegalese: legalese,
                              );
                            },
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'View licenses',
                                maxLines: 1,
                                softWrap: false,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Close',
                                maxLines: 1,
                                softWrap: false,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<bool> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String? supportingText,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    IconData icon = Icons.help_outline_rounded,
    Color? accentColor,
    bool destructive = false,
  }) async {
    final theme = Theme.of(context);
    final accent = destructive
        ? theme.colorScheme.error
        : (accentColor ?? theme.colorScheme.primary);

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        icon: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: accent, size: 26),
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                height: 1.4,
              ),
            ),
            if (supportingText != null && supportingText.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                supportingText,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  height: 1.4,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(minimumSize: const Size(112, 48)),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              minimumSize: const Size(112, 48),
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
