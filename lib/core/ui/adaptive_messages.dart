import 'dart:async';
import 'package:flutter/material.dart';

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
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
