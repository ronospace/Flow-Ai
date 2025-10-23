import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../services/analytics_service.dart';
import '../utils/app_logger.dart';

/// 🛡️ Comprehensive Error Handling System
/// Production-grade error handling with logging, analytics, and recovery strategies
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  static ErrorHandler get instance => _instance;
  ErrorHandler._internal();

  late Logger _logger;
  bool _initialized = false;
  final Map<Type, ErrorRecoveryStrategy> _recoveryStrategies = {};
  final List<AppError> _errorHistory = [];
  final int _maxErrorHistory = 100;

  /// Initialize error handling system
  Future<void> initialize() async {
    if (_initialized) return;

    // Configure logger with production settings
    _logger = Logger(
      level: kDebugMode ? Level.debug : Level.info,
      printer: PrettyPrinter(
        methodCount: kDebugMode ? 3 : 1,
        errorMethodCount: 5,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      output: MultiOutput([
        ConsoleOutput(),
        if (!kDebugMode) FileOutput(file: await _getLogFile()),
      ]),
    );

    // Set up global error handling
    _setupGlobalErrorHandling();

    // Register default recovery strategies
    _registerDefaultStrategies();

    _initialized = true;
    AppLogger.success('Error Handler initialized with production-grade logging');
  }

  /// Set up global error handling for uncaught errors
  void _setupGlobalErrorHandling() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      final error = AppError(
        type: ErrorType.framework,
        message: details.summary.toString(),
        stackTrace: details.stack,
        timestamp: DateTime.now(),
        severity: ErrorSeverity.high,
        context: {
          'library': details.library,
          'context': details.context?.toString(),
          'silent': details.silent,
        },
      );

      handleError(error);
    };

    // Handle platform dispatcher errors (Dart isolate errors)
    PlatformDispatcher.instance.onError = (error, stack) {
      final appError = AppError(
        type: ErrorType.platform,
        message: error.toString(),
        stackTrace: stack,
        timestamp: DateTime.now(),
        severity: ErrorSeverity.critical,
        context: {'platform': 'isolate'},
      );

      handleError(appError);
      return true; // Handled
    };
  }

  /// Handle application errors with recovery strategies
  Future<void> handleError(AppError error) async {
    if (!_initialized) await initialize();

    // Log the error
    _logError(error);

    // Track error history
    _addToErrorHistory(error);

    // Report to analytics (anonymized)
    _reportToAnalytics(error);

    // Try to recover from error
    await _attemptRecovery(error);

    // Notify error listeners if any
    _notifyErrorListeners(error);
  }

  /// Create and handle different types of errors
  Future<void> handleAPIError(String endpoint, int? statusCode, String message) async {
    final error = AppError(
      type: ErrorType.api,
      message: 'API Error: $message',
      timestamp: DateTime.now(),
      severity: _getAPISeverity(statusCode),
      context: {
        'endpoint': endpoint,
        'status_code': statusCode,
        'network_available': await _isNetworkAvailable(),
      },
    );

    await handleError(error);
  }

  Future<void> handleDatabaseError(String operation, dynamic exception) async {
    final error = AppError(
      type: ErrorType.database,
      message: 'Database Error during $operation: $exception',
      timestamp: DateTime.now(),
      severity: ErrorSeverity.high,
      context: {
        'operation': operation,
        'exception_type': exception.runtimeType.toString(),
      },
    );

    await handleError(error);
  }

  Future<void> handleAuthError(String operation, dynamic exception) async {
    final error = AppError(
      type: ErrorType.authentication,
      message: 'Auth Error during $operation: $exception',
      timestamp: DateTime.now(),
      severity: ErrorSeverity.high,
      context: {
        'operation': operation,
        'exception_type': exception.runtimeType.toString(),
      },
    );

    await handleError(error);
  }

  Future<void> handleSecurityError(String context, String message) async {
    final error = AppError(
      type: ErrorType.security,
      message: 'Security Error: $message',
      timestamp: DateTime.now(),
      severity: ErrorSeverity.critical,
      context: {
        'security_context': context,
        'requires_immediate_attention': true,
      },
    );

    await handleError(error);
  }

  Future<void> handleHealthDataError(String operation, dynamic exception) async {
    final error = AppError(
      type: ErrorType.healthData,
      message: 'Health Data Error during $operation: $exception',
      timestamp: DateTime.now(),
      severity: ErrorSeverity.high,
      context: {
        'operation': operation,
        'data_integrity_concern': true,
      },
    );

    await handleError(error);
  }

  /// Log error with appropriate level and formatting
  void _logError(AppError error) {
    final logMessage = '''
═══════════════════════════════════════════════════════════════
🚨 ${error.severity.name.toUpperCase()} ERROR - ${error.type.name.toUpperCase()}
═══════════════════════════════════════════════════════════════
Message: ${error.message}
Timestamp: ${error.timestamp.toIso8601String()}
Context: ${error.context}
${error.stackTrace != null ? 'Stack Trace:\n${error.stackTrace}' : ''}
═══════════════════════════════════════════════════════════════
    ''';

    switch (error.severity) {
      case ErrorSeverity.low:
        _logger.i(logMessage);
        break;
      case ErrorSeverity.medium:
        _logger.w(logMessage);
        break;
      case ErrorSeverity.high:
        _logger.e(logMessage);
        break;
      case ErrorSeverity.critical:
        _logger.f(logMessage);
        break;
    }
  }

  /// Add error to history for analytics
  void _addToErrorHistory(AppError error) {
    _errorHistory.add(error);
    
    // Keep history size manageable
    if (_errorHistory.length > _maxErrorHistory) {
      _errorHistory.removeAt(0);
    }
  }

  /// Report anonymized error data to analytics
  void _reportToAnalytics(AppError error) {
    try {
      // Only report non-sensitive error data
      final analyticsData = {
        'error_type': error.type.name,
        'severity': error.severity.name,
        'timestamp': error.timestamp.toIso8601String(),
        'platform': Platform.operatingSystem,
        'has_stack_trace': error.stackTrace != null,
        // Don't include actual message or stack trace for privacy
      };

      // Report to analytics service (implement based on your analytics provider)
      AnalyticsService.instance.logEvent('app_error', analyticsData);
    } catch (e) {
      // Don't let analytics reporting cause more errors
      debugPrint('Failed to report error to analytics: $e');
    }
  }

  /// Attempt error recovery using registered strategies
  Future<void> _attemptRecovery(AppError error) async {
    final strategy = _recoveryStrategies[error.type.runtimeType];
    
    if (strategy != null) {
      try {
        final recovered = await strategy.attempt(error);
        if (recovered) {
          _logger.i('Successfully recovered from ${error.type.name} error');
          return;
        }
      } catch (recoveryError) {
        _logger.e('Recovery strategy failed: $recoveryError');
      }
    }

    // Fallback recovery strategies
    await _fallbackRecovery(error);
  }

  /// Fallback recovery strategies
  Future<void> _fallbackRecovery(AppError error) async {
    switch (error.type) {
      case ErrorType.api:
        // For API errors, we might retry or use cached data
        _logger.i('Applying API error fallback - using cached data if available');
        break;
      
      case ErrorType.database:
        // For database errors, we might try to reinitialize
        _logger.i('Applying database error fallback - attempting to reinitialize');
        break;
      
      case ErrorType.authentication:
        // For auth errors, we might redirect to login
        _logger.i('Applying auth error fallback - may need user re-authentication');
        break;
      
      default:
        _logger.i('No specific fallback strategy for ${error.type.name}');
    }
  }

  /// Register default recovery strategies
  void _registerDefaultStrategies() {
    registerRecoveryStrategy(ErrorType.api, APIErrorRecoveryStrategy());
    registerRecoveryStrategy(ErrorType.database, DatabaseErrorRecoveryStrategy());
    registerRecoveryStrategy(ErrorType.authentication, AuthErrorRecoveryStrategy());
  }

  /// Register custom recovery strategy
  void registerRecoveryStrategy(ErrorType type, ErrorRecoveryStrategy strategy) {
    _recoveryStrategies[type.runtimeType] = strategy;
  }

  /// Get API error severity based on status code
  ErrorSeverity _getAPISeverity(int? statusCode) {
    if (statusCode == null) return ErrorSeverity.high;
    
    if (statusCode >= 500) return ErrorSeverity.critical;
    if (statusCode >= 400) return ErrorSeverity.high;
    if (statusCode >= 300) return ErrorSeverity.medium;
    return ErrorSeverity.low;
  }

  /// Check network availability
  Future<bool> _isNetworkAvailable() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get log file for persistent logging
  Future<File> _getLogFile() async {
    // This would be implemented based on your file storage strategy
    // For now, return a placeholder
    return File('app_logs.txt');
  }

  /// Notify error listeners (for UI updates, etc.)
  void _notifyErrorListeners(AppError error) {
    // Implement error listener notification if needed
    // This could be used to show error messages to users or update UI state
  }

  /// Get error statistics for monitoring
  Map<String, dynamic> getErrorStats() {
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));
    
    final recentErrors = _errorHistory
        .where((error) => error.timestamp.isAfter(last24Hours))
        .toList();

    final errorsByType = <String, int>{};
    final errorsBySeverity = <String, int>{};

    for (final error in recentErrors) {
      errorsByType[error.type.name] = (errorsByType[error.type.name] ?? 0) + 1;
      errorsBySeverity[error.severity.name] = (errorsBySeverity[error.severity.name] ?? 0) + 1;
    }

    return {
      'total_errors': _errorHistory.length,
      'recent_errors_24h': recentErrors.length,
      'errors_by_type': errorsByType,
      'errors_by_severity': errorsBySeverity,
      'last_error': _errorHistory.isNotEmpty ? _errorHistory.last.timestamp.toIso8601String() : null,
    };
  }

  /// Clear error history (useful for testing)
  void clearErrorHistory() {
    _errorHistory.clear();
  }

  /// Get recent errors for debugging
  List<AppError> getRecentErrors({int limit = 20}) {
    return _errorHistory.reversed.take(limit).toList();
  }
}

/// Error types for categorization
enum ErrorType {
  framework,
  platform,
  api,
  database,
  authentication,
  security,
  healthData,
  ui,
  performance,
  unknown,
}

/// Error severity levels
enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}

/// Application error model
class AppError {
  final ErrorType type;
  final String message;
  final StackTrace? stackTrace;
  final DateTime timestamp;
  final ErrorSeverity severity;
  final Map<String, dynamic> context;

  AppError({
    required this.type,
    required this.message,
    this.stackTrace,
    required this.timestamp,
    required this.severity,
    this.context = const {},
  });

  /// Convert to JSON for logging/analytics
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'severity': severity.name,
      'context': context,
      'has_stack_trace': stackTrace != null,
    };
  }
}

/// Abstract recovery strategy
abstract class ErrorRecoveryStrategy {
  Future<bool> attempt(AppError error);
}

/// API error recovery strategy
class APIErrorRecoveryStrategy extends ErrorRecoveryStrategy {
  @override
  Future<bool> attempt(AppError error) async {
    // Implement API-specific recovery (retry, fallback to cache, etc.)
    await Future.delayed(const Duration(milliseconds: 100));
    return false; // Simplified - would implement actual recovery logic
  }
}

/// Database error recovery strategy
class DatabaseErrorRecoveryStrategy extends ErrorRecoveryStrategy {
  @override
  Future<bool> attempt(AppError error) async {
    // Implement database-specific recovery (reinitialize, repair, etc.)
    await Future.delayed(const Duration(milliseconds: 100));
    return false; // Simplified - would implement actual recovery logic
  }
}

/// Authentication error recovery strategy
class AuthErrorRecoveryStrategy extends ErrorRecoveryStrategy {
  @override
  Future<bool> attempt(AppError error) async {
    // Implement auth-specific recovery (token refresh, re-authenticate, etc.)
    await Future.delayed(const Duration(milliseconds: 100));
    return false; // Simplified - would implement actual recovery logic
  }
}

/// File output for production logging
class FileOutput extends LogOutput {
  final File file;

  FileOutput({required this.file});

  @override
  void output(OutputEvent event) {
    try {
      final lines = event.lines.join('\n');
      file.writeAsStringSync('$lines\n', mode: FileMode.append);
    } catch (e) {
      // Don't let file logging errors break the app
      debugPrint('Failed to write to log file: $e');
    }
  }
}

/// Multiple output handler
class MultiOutput extends LogOutput {
  final List<LogOutput> outputs;

  MultiOutput(this.outputs);

  @override
  void output(OutputEvent event) {
    for (final output in outputs) {
      try {
        output.output(event);
      } catch (e) {
        // Continue with other outputs even if one fails
        debugPrint('Log output failed: $e');
      }
    }
  }
}

/// Error handling utilities
class ErrorUtils {
  /// Safely execute a function with error handling
  static Future<T?> safeExecute<T>(
    Future<T> Function() function, {
    String? context,
    ErrorType errorType = ErrorType.unknown,
    T? fallback,
  }) async {
    try {
      return await function();
    } catch (error, stackTrace) {
      final appError = AppError(
        type: errorType,
        message: '${context ?? 'Operation'} failed: $error',
        stackTrace: stackTrace,
        timestamp: DateTime.now(),
        severity: ErrorSeverity.medium,
        context: {'operation_context': context},
      );

      await ErrorHandler.instance.handleError(appError);
      return fallback;
    }
  }

  /// Safely execute a synchronous function with error handling
  static T? safeExecuteSync<T>(
    T Function() function, {
    String? context,
    ErrorType errorType = ErrorType.unknown,
    T? fallback,
  }) {
    try {
      return function();
    } catch (error, stackTrace) {
      final appError = AppError(
        type: errorType,
        message: '${context ?? 'Operation'} failed: $error',
        stackTrace: stackTrace,
        timestamp: DateTime.now(),
        severity: ErrorSeverity.medium,
        context: {'operation_context': context},
      );

      // Handle error asynchronously
      ErrorHandler.instance.handleError(appError);
      return fallback;
    }
  }
}
