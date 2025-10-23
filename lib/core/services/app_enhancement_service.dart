import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/app_logger.dart';

/// Centralized app enhancement service for dependency injection,
/// error handling, performance monitoring, and feature management
class AppEnhancementService {
  static final AppEnhancementService _instance = AppEnhancementService._internal();
  factory AppEnhancementService() => _instance;
  AppEnhancementService._internal();

  final Map<Type, dynamic> _services = {};
  final Map<String, bool> _featureFlags = {};
  final List<AppError> _errors = [];
  final Map<String, PerformanceMetric> _performanceMetrics = {};
  bool _isInitialized = false;

  /// Initialize the enhancement service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      AppLogger.system('🚀 Initializing App Enhancement Service...');
      
      // Initialize feature flags
      _initializeFeatureFlags();
      
      // Setup error monitoring
      _setupErrorMonitoring();
      
      // Initialize performance monitoring
      _setupPerformanceMonitoring();
      
      _isInitialized = true;
      AppLogger.system('✅ App Enhancement Service initialized successfully');
      
      // Start background tasks
      _startBackgroundTasks();
      
    } catch (e) {
      AppLogger.error('❌ Failed to initialize App Enhancement Service', e);
      rethrow;
    }
  }

  /// Register a service for dependency injection
  void registerService<T>(T service) {
    _services[T] = service;
    AppLogger.system('📦 Registered service: ${T.toString()}');
  }

  /// Get a registered service
  T getService<T>() {
    final service = _services[T];
    if (service == null) {
      throw ServiceNotFoundException('Service ${T.toString()} not found');
    }
    return service as T;
  }

  /// Check if a service is registered
  bool hasService<T>() => _services.containsKey(T);

  /// Remove a service
  void unregisterService<T>() {
    _services.remove(T);
    AppLogger.system('🗑️ Unregistered service: ${T.toString()}');
  }

  /// Initialize feature flags
  void _initializeFeatureFlags() {
    _featureFlags.addAll({
      'enhanced_auth': true,
      'ai_insights': true,
      'biometric_login': true,
      'offline_mode': true,
      'analytics': !kDebugMode,
      'performance_monitoring': true,
      'error_reporting': !kDebugMode,
      'push_notifications': true,
      'voice_notes': false, // Beta feature
      'calendar_integration': false, // Coming soon
      'health_kit_integration': false, // iOS only, coming soon
      'wear_os_support': false, // Android Wear, coming soon
    });
    
    AppLogger.system('🏁 Feature flags initialized: ${_featureFlags.length} features');
  }

  /// Check if a feature is enabled
  bool isFeatureEnabled(String feature) => _featureFlags[feature] ?? false;

  /// Enable/disable a feature
  void setFeature(String feature, bool enabled) {
    _featureFlags[feature] = enabled;
    AppLogger.system('🔧 Feature "$feature" ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Setup comprehensive error monitoring
  void _setupErrorMonitoring() {
    FlutterError.onError = (FlutterErrorDetails details) {
      final error = AppError(
        message: details.exception.toString(),
        stackTrace: details.stack.toString(),
        timestamp: DateTime.now(),
        type: AppErrorType.flutter,
        context: details.context?.toString(),
      );
      
      _recordError(error);
      
      // Log to console in debug mode
      if (kDebugMode) {
        FlutterError.presentError(details);
      }
    };

    // Catch Dart errors
    PlatformDispatcher.instance.onError = (error, stack) {
      final appError = AppError(
        message: error.toString(),
        stackTrace: stack.toString(),
        timestamp: DateTime.now(),
        type: AppErrorType.dart,
      );
      
      _recordError(appError);
      return true;
    };
    
    AppLogger.system('🛡️ Error monitoring setup complete');
  }

  /// Record an error
  void _recordError(AppError error) {
    _errors.add(error);
    
    // Keep only the last 100 errors to prevent memory leaks
    if (_errors.length > 100) {
      _errors.removeAt(0);
    }
    
    AppLogger.error('📊 Error recorded: ${error.message}');
    
    // In production, you would send this to a crash reporting service
    if (isFeatureEnabled('error_reporting') && kReleaseMode) {
      _sendErrorToService(error);
    }
  }

  /// Send error to external service (placeholder)
  Future<void> _sendErrorToService(AppError error) async {
    // TODO: Integrate with Firebase Crashlytics, Sentry, or similar service
    AppLogger.system('📡 Sending error to external service: ${error.message}');
  }

  /// Setup performance monitoring
  void _setupPerformanceMonitoring() {
    if (!isFeatureEnabled('performance_monitoring')) return;
    
    // Monitor build times, navigation, and memory usage
    AppLogger.system('📈 Performance monitoring enabled');
  }

  /// Start a performance measurement
  void startPerformanceTrace(String traceName) {
    if (!isFeatureEnabled('performance_monitoring')) return;
    
    _performanceMetrics[traceName] = PerformanceMetric(
      name: traceName,
      startTime: DateTime.now(),
    );
  }

  /// Stop a performance measurement
  void stopPerformanceTrace(String traceName) {
    if (!isFeatureEnabled('performance_monitoring')) return;
    
    final metric = _performanceMetrics[traceName];
    if (metric != null) {
      metric.endTime = DateTime.now();
      metric.duration = metric.endTime!.difference(metric.startTime);
      
      AppLogger.performance('⏱️ Trace "$traceName" took ${metric.duration!.inMilliseconds}ms');
      
      // In production, send to analytics service
      if (kReleaseMode) {
        _sendMetricToService(metric);
      }
    }
  }

  /// Send metric to external service (placeholder)
  Future<void> _sendMetricToService(PerformanceMetric metric) async {
    // TODO: Integrate with Firebase Performance, Google Analytics, etc.
    AppLogger.system('📊 Sending metric to service: ${metric.name}');
  }

  /// Start background tasks
  void _startBackgroundTasks() {
    // Cleanup old errors and metrics periodically
    Timer.periodic(const Duration(minutes: 30), (timer) {
      _cleanupOldData();
    });
    
    // Performance health check
    Timer.periodic(const Duration(minutes: 5), (timer) {
      _performHealthCheck();
    });
  }

  /// Cleanup old data to prevent memory leaks
  void _cleanupOldData() {
    final now = DateTime.now();
    
    // Remove errors older than 1 hour
    _errors.removeWhere((error) => 
        now.difference(error.timestamp).inHours > 1);
    
    // Remove old performance metrics
    _performanceMetrics.removeWhere((key, metric) => 
        metric.endTime != null && 
        now.difference(metric.endTime!).inMinutes > 30);
    
    AppLogger.system('🧹 Cleanup completed');
  }

  /// Perform system health check
  void _performHealthCheck() {
    if (!kDebugMode) return;
    
    try {
      // Check error rate
      final recentErrors = _errors.where((error) => 
          DateTime.now().difference(error.timestamp).inMinutes < 5).length;
      
      if (recentErrors > 5) {
        AppLogger.warning('⚠️ High error rate detected: $recentErrors errors in last 5 minutes');
      }
      
      AppLogger.system('💚 Health check completed - System healthy');
      
    } catch (e) {
      AppLogger.warning('❌ Health check failed: $e');
    }
  }

  /// Get system health report
  Map<String, dynamic> getHealthReport() {
    return {
      'isInitialized': _isInitialized,
      'servicesCount': _services.length,
      'featuresEnabled': _featureFlags.values.where((v) => v).length,
      'totalFeatures': _featureFlags.length,
      'errorCount': _errors.length,
      'recentErrors': _errors.where((error) => 
          DateTime.now().difference(error.timestamp).inMinutes < 10).length,
      'performanceMetrics': _performanceMetrics.length,
      'memoryHealth': 'Good', // Placeholder - would use actual memory stats
    };
  }

  /// Get error summary
  List<Map<String, dynamic>> getErrorSummary() {
    return _errors.map((error) => {
      'message': error.message,
      'type': error.type.toString(),
      'timestamp': error.timestamp.toIso8601String(),
      'hasStackTrace': error.stackTrace.isNotEmpty,
    }).toList();
  }

  /// Clear all errors (for testing/debugging)
  void clearErrors() {
    _errors.clear();
    AppLogger.system('🧹 All errors cleared');
  }

  /// Dispose resources
  void dispose() {
    _services.clear();
    _errors.clear();
    _performanceMetrics.clear();
    _isInitialized = false;
    AppLogger.system('🔄 App Enhancement Service disposed');
  }
}

/// Custom exception for service not found
class ServiceNotFoundException implements Exception {
  final String message;
  ServiceNotFoundException(this.message);
  
  @override
  String toString() => 'ServiceNotFoundException: $message';
}

/// Error model for comprehensive error tracking
class AppError {
  final String message;
  final String stackTrace;
  final DateTime timestamp;
  final AppErrorType type;
  final String? context;
  final Map<String, dynamic> metadata;

  AppError({
    required this.message,
    required this.stackTrace,
    required this.timestamp,
    required this.type,
    this.context,
    this.metadata = const {},
  });
}

/// Error types for categorization
enum AppErrorType {
  flutter,
  dart,
  network,
  authentication,
  storage,
  permission,
  platform,
  user,
}

/// Performance metric model
class PerformanceMetric {
  final String name;
  final DateTime startTime;
  DateTime? endTime;
  Duration? duration;
  final Map<String, dynamic> attributes;

  PerformanceMetric({
    required this.name,
    required this.startTime,
    this.endTime,
    this.duration,
    this.attributes = const {},
  });
}

/// Extension for easy service access
extension ServiceLocator on BuildContext {
  T getService<T>() => AppEnhancementService().getService<T>();
  
  bool hasService<T>() => AppEnhancementService().hasService<T>();
}
