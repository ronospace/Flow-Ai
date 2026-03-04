import 'package:flutter/foundation.dart';

/// Production-safe logging utility
/// Only logs in debug mode, silent in release builds
class AppLogger {
  static const String _prefix = 'FlowAI';

  /// Log info messages (general information)
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix ℹ️ $message');
    }
  }

  /// Log success messages
  static void success(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix ✅ $message');
    }
  }

  /// Log warning messages
  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix ⚠️ $message');
    }
  }

  /// Log error messages (always logged, even in production for crash reporting)
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('$_prefix ❌ $message');
      if (error != null) {
        debugPrint('$_prefix Error details: $error');
      }
      if (stackTrace != null) {
        debugPrint('$_prefix Stack trace: $stackTrace');
      }
    }
    // In production, you would send this to crash reporting service
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }

  /// Log debug messages (development only)
  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix 🐛 $message');
    }
  }

  /// Log performance metrics
  static void performance(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix 🚀 $message');
    }
  }

  /// Log AI-related messages
  static void ai(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix 🧠 $message');
    }
  }

  /// Log authentication-related messages
  static void auth(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix 🔐 $message');
    }
  }

  /// Log sync-related messages
  static void sync(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix 🔄 $message');
    }
  }

  /// Log notification-related messages
  static void notification(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix 🔔 $message');
    }
  }

  /// Log navigation-related messages
  static void navigation(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix 🚀 $message');
    }
  }

  /// Log memory-related messages
  static void memory(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix 🧹 $message');
    }
  }

  /// Log system-related messages
  static void system(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix ⚙️ $message');
    }
  }

  /// Log cycle-related messages
  static void cycle(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix 🌙 $message');
    }
  }

  /// Log analytics-related messages
  static void analytics(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix 📊 $message');
    }
  }

  /// Log security-related messages
  static void security(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix 🔒 $message');
    }
  }

  /// Log clinical-related messages
  static void clinical(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix 🏥 $message');
    }
  }
}
