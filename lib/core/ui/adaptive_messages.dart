import 'dart:async';
import 'package:flutter/material.dart';

/// Adaptive message display utility that automatically adjusts to platform conventions
class AdaptiveMessages {
  static String? _lastError;
  static DateTime? _lastErrorTime;

  static Future<void> showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 700),
  }) async {
    final normalized = message.toLowerCase();

    final allowSuccess =
        normalized.contains('saved') ||
        normalized.contains('updated') ||
        normalized.contains('submitted');

    if (!allowSuccess) return;

    _showSnack(
      context,
      message,
      Colors.green,
      duration,
      icon: Icons.check_circle_outline,
    );
  }

  static Future<void> showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 700),
  }) async {
    return;
  }

  static Future<void> showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 900),
  }) async {
    _showSnack(
      context,
      message,
      Colors.orange,
      duration,
      icon: Icons.warning_amber_rounded,
    );
  }

  static Future<void> showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 700),
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
      Colors.red,
      duration,
      icon: Icons.warning_amber_rounded,
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
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          duration: duration,
        ),
      );
  }

  static Future<bool> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}


