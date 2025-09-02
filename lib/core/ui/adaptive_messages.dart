import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/platform_service.dart';
import 'adaptive_components.dart';
import '../theme/app_theme.dart';

/// Adaptive message display utility that automatically adjusts to platform conventions
class AdaptiveMessages {
  static final PlatformService _platformService = PlatformService();

  /// Show a success message
  static Future<void> showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) async {
    await _showMessage(
      context,
      title: 'Success',
      message: message,
      type: _MessageType.success,
      duration: duration,
    );
  }

  /// Show an error message
  static Future<void> showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) async {
    await _showMessage(
      context,
      title: 'Error',
      message: message,
      type: _MessageType.error,
      duration: duration,
    );
  }

  /// Show an info message
  static Future<void> showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) async {
    await _showMessage(
      context,
      title: 'Information',
      message: message,
      type: _MessageType.info,
      duration: duration,
    );
  }

  /// Show a warning message
  static Future<void> showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) async {
    await _showMessage(
      context,
      title: 'Warning',
      message: message,
      type: _MessageType.warning,
      duration: duration,
    );
  }

  static Future<void> _showMessage(
    BuildContext context, {
    required String title,
    required String message,
    required _MessageType type,
    Duration duration = const Duration(seconds: 3),
  }) async {
    if (!context.mounted) return;

    final platformInfo = _platformService.platformInfo;
    
    if (platformInfo.platform == TargetPlatform.iOS && platformInfo.isMobile) {
      // Use iOS-style alert for messages
      await _showIOSMessage(context, title: title, message: message, type: type, duration: duration);
    } else {
      // Use Material SnackBar for Android/other platforms
      await _showMaterialMessage(context, title: title, message: message, type: type, duration: duration);
    }
  }

  static Future<void> _showIOSMessage(
    BuildContext context, {
    required String title,
    required String message,
    required _MessageType type,
    Duration duration = const Duration(seconds: 3),
  }) async {
    final (icon, color) = _getTypeIconAndColor(type);

    // For iOS, we'll show a brief alert dialog that auto-dismisses
    final completer = Completer<void>();
    
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        // Auto-dismiss the dialog after the duration
        Timer(duration, () {
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
            completer.complete();
          }
        });

        return CupertinoAlertDialog(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                completer.complete();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    return completer.future;
  }

  static Future<void> _showMaterialMessage(
    BuildContext context, {
    required String title,
    required String message,
    required _MessageType type,
    Duration duration = const Duration(seconds: 3),
  }) async {
    final (icon, color) = _getTypeIconAndColor(type);

    // Safely check for ScaffoldMessenger availability
    ScaffoldMessengerState? scaffoldMessenger;
    try {
      scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    } catch (e) {
      // If ScaffoldMessenger is not available, fall back to iOS-style dialog
      return _showIOSMessage(context, title: title, message: message, type: type, duration: duration);
    }

    if (scaffoldMessenger != null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: duration,
        ),
      );
    } else {
      // Fallback to iOS-style dialog if no ScaffoldMessenger available
      return _showIOSMessage(context, title: title, message: message, type: type, duration: duration);
    }
  }

  static (IconData, Color) _getTypeIconAndColor(_MessageType type) {
    switch (type) {
      case _MessageType.success:
        return (Icons.check_circle, AppTheme.successGreen);
      case _MessageType.error:
        return (Icons.error, AppTheme.primaryRose);
      case _MessageType.warning:
        return (Icons.warning, Colors.orange);
      case _MessageType.info:
        return (Icons.info, AppTheme.secondaryBlue);
    }
  }

  /// Show a confirmation dialog with adaptive styling
  static Future<bool> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    return await AdaptiveComponents.showAdaptiveDialog<bool>(
      context: context,
      title: title,
      content: message,
      actions: [
        AdaptiveDialogAction(
          text: cancelText,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AdaptiveDialogAction(
          text: confirmText,
          onPressed: () => Navigator.of(context).pop(true),
          isDefault: true,
          isDestructive: isDestructive,
        ),
      ],
    ) ?? false;
  }
}

enum _MessageType {
  success,
  error,
  warning,
  info,
}
