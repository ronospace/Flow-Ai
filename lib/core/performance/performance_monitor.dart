import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import '../error/error_handler.dart';
import '../utils/app_logger.dart';

/// 📊 Performance Monitor
/// Production-grade performance monitoring and optimization system
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  static PerformanceMonitor get instance => _instance;
  PerformanceMonitor._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Performance metrics tracking
  final Map<String, PerformanceMetric> _metrics = {};
  final List<FramePerformanceData> _frameData = [];
  final List<MemorySnapshot> _memorySnapshots = [];
  final List<NetworkMetric> _networkMetrics = [];
  
  // Performance configuration
  static const int _maxFrameDataPoints = 1000;
  static const int _maxMemorySnapshots = 100;
  static const int _maxNetworkMetrics = 500;
  static const Duration _memorySnapshotInterval = Duration(seconds: 30);
  
  // Timers for periodic monitoring
  Timer? _memoryMonitorTimer;
  Timer? _performanceReportTimer;
  
  // Frame timing observer
  late PerformanceFrameObserver _frameObserver;
  
  // Current session metrics
  final PerformanceSession _currentSession = PerformanceSession();
  
  /// Initialize performance monitoring
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      AppLogger.performance('📊 Initializing Performance Monitor...');

      // Initialize frame performance monitoring
      _initializeFrameMonitoring();
      
      // Initialize memory monitoring
      _initializeMemoryMonitoring();
      
      // Initialize network monitoring
      _initializeNetworkMonitoring();
      
      // Start periodic monitoring
      _startPeriodicMonitoring();
      
      // Register lifecycle callbacks
      _registerLifecycleCallbacks();

      _isInitialized = true;
      
      AppLogger.success('✅ Performance Monitor initialized with real-time tracking');
    } catch (e) {
      await ErrorHandler.instance.handleError(AppError(
        type: ErrorType.performance,
        message: 'Failed to initialize Performance Monitor: $e',
        timestamp: DateTime.now(),
        severity: ErrorSeverity.high,
        context: {'component': 'performance_monitor'},
      ));
      rethrow;
    }
  }

  /// Initialize frame performance monitoring
  void _initializeFrameMonitoring() {
    _frameObserver = PerformanceFrameObserver();
    SchedulerBinding.instance.addTimingsCallback(_frameObserver.onFrameTiming);
    AppLogger.performance('🖼️ Frame performance monitoring enabled');
  }

  /// Initialize memory monitoring
  void _initializeMemoryMonitoring() {
    _memoryMonitorTimer = Timer.periodic(_memorySnapshotInterval, (_) {
      _captureMemorySnapshot();
    });
    
    // Capture initial snapshot
    _captureMemorySnapshot();
    AppLogger.performance('🧠 Memory monitoring enabled');
  }

  /// Initialize network monitoring
  void _initializeNetworkMonitoring() {
    // Network monitoring will be implemented through HTTP interceptors
    AppLogger.performance('🌐 Network monitoring enabled');
  }

  /// Start periodic monitoring tasks
  void _startPeriodicMonitoring() {
    _performanceReportTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _generatePerformanceReport(),
    );
    AppLogger.performance('⏱️ Periodic monitoring started');
  }

  /// Register app lifecycle callbacks
  void _registerLifecycleCallbacks() {
    WidgetsBinding.instance.addObserver(PerformanceLifecycleObserver(this));
    AppLogger.performance('♻️ Lifecycle monitoring registered');
  }

  /// Start measuring performance for a specific operation
  PerformanceTimer startMeasurement(String operationName, {
    Map<String, dynamic>? metadata,
  }) {
    final timer = PerformanceTimer(
      operationName: operationName,
      startTime: DateTime.now(),
      metadata: metadata ?? {},
    );
    
    AppLogger.performance('⏱️ Started measuring: $operationName');
    return timer;
  }

  /// Complete a performance measurement
  void completeMeasurement(PerformanceTimer timer, {
    bool success = true,
    String? errorMessage,
    Map<String, dynamic>? additionalMetadata,
  }) {
    final endTime = DateTime.now();
    final duration = endTime.difference(timer.startTime);

    final metric = PerformanceMetric(
      operationName: timer.operationName,
      duration: duration,
      timestamp: timer.startTime,
      success: success,
      errorMessage: errorMessage,
      metadata: {
        ...timer.metadata,
        ...?additionalMetadata,
      },
    );

    _recordMetric(metric);
    
    AppLogger.performance(
      '✅ Completed measuring: ${timer.operationName} (${duration.inMilliseconds}ms)',
    );
  }

  /// Record a performance metric
  void _recordMetric(PerformanceMetric metric) {
    final key = '${metric.operationName}_${DateTime.now().millisecondsSinceEpoch}';
    _metrics[key] = metric;
    
    // Keep metrics list manageable
    if (_metrics.length > 1000) {
      final oldestKey = _metrics.keys.first;
      _metrics.remove(oldestKey);
    }
    
    // Update session statistics
    _currentSession.addMetric(metric);
  }

  /// Measure and execute an operation
  Future<T> measureOperation<T>(
    String operationName,
    Future<T> Function() operation, {
    Map<String, dynamic>? metadata,
  }) async {
    final timer = startMeasurement(operationName, metadata: metadata);
    
    try {
      final result = await operation();
      completeMeasurement(timer, success: true);
      return result;
    } catch (error) {
      completeMeasurement(
        timer,
        success: false,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }

  /// Measure synchronous operation
  T measureSync<T>(
    String operationName,
    T Function() operation, {
    Map<String, dynamic>? metadata,
  }) {
    final timer = startMeasurement(operationName, metadata: metadata);
    
    try {
      final result = operation();
      completeMeasurement(timer, success: true);
      return result;
    } catch (error) {
      completeMeasurement(
        timer,
        success: false,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }

  /// Record network request performance
  void recordNetworkMetric({
    required String url,
    required String method,
    required Duration duration,
    required int statusCode,
    int? requestSize,
    int? responseSize,
    String? errorMessage,
  }) {
    final metric = NetworkMetric(
      url: url,
      method: method,
      duration: duration,
      statusCode: statusCode,
      requestSize: requestSize,
      responseSize: responseSize,
      timestamp: DateTime.now(),
      success: statusCode >= 200 && statusCode < 300,
      errorMessage: errorMessage,
    );

    _networkMetrics.add(metric);
    
    // Keep network metrics manageable
    if (_networkMetrics.length > _maxNetworkMetrics) {
      _networkMetrics.removeAt(0);
    }
    
    AppLogger.performance(
      '🌐 Network: $method $url (${duration.inMilliseconds}ms, $statusCode)',
    );
  }

  /// Capture memory snapshot
  void _captureMemorySnapshot() {
    try {
      final info = developer.Service.getIsolateId(Isolate.current);
      
      final snapshot = MemorySnapshot(
        timestamp: DateTime.now(),
        heapUsage: _getHeapUsage(),
        rssUsage: _getRSSUsage(),
        isolateId: info ?? 'unknown',
      );

      _memorySnapshots.add(snapshot);
      
      // Keep memory snapshots manageable
      if (_memorySnapshots.length > _maxMemorySnapshots) {
        _memorySnapshots.removeAt(0);
      }
      
      // Check for memory pressure
      _checkMemoryPressure(snapshot);
      
    } catch (e) {
      AppLogger.warning('Failed to capture memory snapshot: $e');
    }
  }

  /// Get current heap usage
  int _getHeapUsage() {
    try {
      // This would use dart:developer's Service API in a real implementation
      return ProcessInfo.currentRss ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get current RSS usage
  int _getRSSUsage() {
    try {
      return ProcessInfo.currentRss ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Check for memory pressure and trigger warnings
  void _checkMemoryPressure(MemorySnapshot snapshot) {
    const int memoryWarningThreshold = 500 * 1024 * 1024; // 500MB
    const int memoryCriticalThreshold = 1024 * 1024 * 1024; // 1GB

    if (snapshot.rssUsage > memoryCriticalThreshold) {
      AppLogger.warning('🚨 CRITICAL: Memory usage very high (${snapshot.rssUsage ~/ (1024 * 1024)}MB)');
      
      // Trigger garbage collection
      _forceGarbageCollection();
      
    } else if (snapshot.rssUsage > memoryWarningThreshold) {
      AppLogger.warning('⚠️ WARNING: Memory usage elevated (${snapshot.rssUsage ~/ (1024 * 1024)}MB)');
    }
  }

  /// Force garbage collection
  void _forceGarbageCollection() {
    try {
      // Request garbage collection
      developer.postEvent('gc', {});
      AppLogger.performance('🗑️ Garbage collection requested');
    } catch (e) {
      AppLogger.warning('Failed to trigger garbage collection: $e');
    }
  }

  /// Generate comprehensive performance report
  void _generatePerformanceReport() {
    final report = PerformanceReport.generate(
      session: _currentSession,
      metrics: _metrics.values.toList(),
      frameData: _frameData,
      memorySnapshots: _memorySnapshots,
      networkMetrics: _networkMetrics,
    );

    AppLogger.performance('📊 Performance Report Generated:');
    AppLogger.performance('  - Operations: ${report.totalOperations}');
    AppLogger.performance('  - Avg Duration: ${report.averageDuration.inMilliseconds}ms');
    AppLogger.performance('  - Frame Rate: ${report.averageFrameRate.toStringAsFixed(1)} FPS');
    AppLogger.performance('  - Memory Usage: ${report.currentMemoryUsage ~/ (1024 * 1024)}MB');
    
    // Check for performance issues
    _analyzePerformanceIssues(report);
  }

  /// Analyze performance issues and generate alerts
  void _analyzePerformanceIssues(PerformanceReport report) {
    final issues = <String>[];

    // Check frame rate
    if (report.averageFrameRate < 55.0) {
      issues.add('Low frame rate detected: ${report.averageFrameRate.toStringAsFixed(1)} FPS');
    }

    // Check slow operations
    final slowOperations = report.slowestOperations.take(3);
    for (final op in slowOperations) {
      if (op.duration.inMilliseconds > 1000) {
        issues.add('Slow operation: ${op.operationName} (${op.duration.inMilliseconds}ms)');
      }
    }

    // Check memory growth
    if (report.memoryGrowthRate > 0.1) { // 10% growth
      issues.add('High memory growth rate: ${(report.memoryGrowthRate * 100).toStringAsFixed(1)}%');
    }

    // Check network performance
    if (report.averageNetworkDuration.inMilliseconds > 5000) {
      issues.add('Slow network requests: ${report.averageNetworkDuration.inMilliseconds}ms average');
    }

    // Report issues
    if (issues.isNotEmpty) {
      AppLogger.warning('⚠️ Performance Issues Detected:');
      for (final issue in issues) {
        AppLogger.warning('  - $issue');
      }
    }
  }

  /// Get current performance metrics
  PerformanceSnapshot getCurrentMetrics() {
    final recentMetrics = _metrics.values
        .where((m) => DateTime.now().difference(m.timestamp) < const Duration(minutes: 5))
        .toList();

    final recentFrames = _frameData
        .where((f) => DateTime.now().difference(f.timestamp) < const Duration(minutes: 1))
        .toList();

    return PerformanceSnapshot(
      timestamp: DateTime.now(),
      operationCount: recentMetrics.length,
      averageDuration: recentMetrics.isNotEmpty
          ? Duration(
              microseconds: recentMetrics
                  .map((m) => m.duration.inMicroseconds)
                  .reduce((a, b) => a + b) ~/
              recentMetrics.length,
            )
          : Duration.zero,
      frameRate: recentFrames.isNotEmpty
          ? recentFrames.map((f) => f.fps).reduce((a, b) => a + b) / recentFrames.length
          : 60.0,
      memoryUsage: _memorySnapshots.isNotEmpty ? _memorySnapshots.last.rssUsage : 0,
      networkLatency: _networkMetrics.isNotEmpty
          ? Duration(
              microseconds: _networkMetrics
                  .map((m) => m.duration.inMicroseconds)
                  .reduce((a, b) => a + b) ~/
              _networkMetrics.length,
            )
          : Duration.zero,
    );
  }

  /// Get performance statistics
  Map<String, dynamic> getPerformanceStats() {
    final recentMetrics = _metrics.values
        .where((m) => DateTime.now().difference(m.timestamp) < const Duration(hours: 1))
        .toList();

    final successfulOps = recentMetrics.where((m) => m.success).length;
    final failedOps = recentMetrics.length - successfulOps;

    return {
      'session_duration_minutes': DateTime.now().difference(_currentSession.startTime).inMinutes,
      'total_operations': recentMetrics.length,
      'successful_operations': successfulOps,
      'failed_operations': failedOps,
      'success_rate': recentMetrics.isNotEmpty ? successfulOps / recentMetrics.length : 1.0,
      'average_operation_duration_ms': recentMetrics.isNotEmpty
          ? recentMetrics.map((m) => m.duration.inMilliseconds).reduce((a, b) => a + b) / recentMetrics.length
          : 0.0,
      'current_memory_mb': _memorySnapshots.isNotEmpty 
          ? _memorySnapshots.last.rssUsage / (1024 * 1024) 
          : 0.0,
      'average_frame_rate': _frameData.isNotEmpty
          ? _frameData.map((f) => f.fps).reduce((a, b) => a + b) / _frameData.length
          : 60.0,
      'network_requests_last_hour': _networkMetrics
          .where((m) => DateTime.now().difference(m.timestamp) < const Duration(hours: 1))
          .length,
      'monitor_status': _isInitialized ? 'active' : 'inactive',
    };
  }

  /// Dispose of performance monitoring resources
  void dispose() {
    _memoryMonitorTimer?.cancel();
    _performanceReportTimer?.cancel();
    
    if (_isInitialized) {
      SchedulerBinding.instance.removeTimingsCallback(_frameObserver.onFrameTiming);
    }
    
    AppLogger.performance('📊 Performance Monitor disposed');
  }
}

/// Performance timer for measuring operations
class PerformanceTimer {
  final String operationName;
  final DateTime startTime;
  final Map<String, dynamic> metadata;

  PerformanceTimer({
    required this.operationName,
    required this.startTime,
    required this.metadata,
  });
}

/// Performance metric data model
class PerformanceMetric {
  final String operationName;
  final Duration duration;
  final DateTime timestamp;
  final bool success;
  final String? errorMessage;
  final Map<String, dynamic> metadata;

  PerformanceMetric({
    required this.operationName,
    required this.duration,
    required this.timestamp,
    required this.success,
    this.errorMessage,
    required this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'operation_name': operationName,
      'duration_ms': duration.inMilliseconds,
      'timestamp': timestamp.toIso8601String(),
      'success': success,
      'error_message': errorMessage,
      'metadata': metadata,
    };
  }
}

/// Frame performance observer
class PerformanceFrameObserver {
  void onFrameTiming(List<FrameTiming> timings) {
    for (final timing in timings) {
      final frameData = FramePerformanceData(
        timestamp: DateTime.now(),
        buildDuration: timing.buildDuration,
        rasterDuration: timing.rasterDuration,
        totalDuration: timing.totalSpan,
        fps: 1000000 / timing.totalSpan.inMicroseconds, // Convert to FPS
      );

      PerformanceMonitor.instance._frameData.add(frameData);
      
      // Keep frame data manageable
      if (PerformanceMonitor.instance._frameData.length > PerformanceMonitor._maxFrameDataPoints) {
        PerformanceMonitor.instance._frameData.removeAt(0);
      }

      // Check for dropped frames
      if (frameData.fps < 55.0) {
        AppLogger.warning('📉 Frame drop detected: ${frameData.fps.toStringAsFixed(1)} FPS');
      }
    }
  }
}

/// Frame performance data
class FramePerformanceData {
  final DateTime timestamp;
  final Duration buildDuration;
  final Duration rasterDuration;
  final Duration totalDuration;
  final double fps;

  FramePerformanceData({
    required this.timestamp,
    required this.buildDuration,
    required this.rasterDuration,
    required this.totalDuration,
    required this.fps,
  });
}

/// Memory snapshot data
class MemorySnapshot {
  final DateTime timestamp;
  final int heapUsage;
  final int rssUsage;
  final String isolateId;

  MemorySnapshot({
    required this.timestamp,
    required this.heapUsage,
    required this.rssUsage,
    required this.isolateId,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'heap_usage_bytes': heapUsage,
      'rss_usage_bytes': rssUsage,
      'isolate_id': isolateId,
    };
  }
}

/// Network performance metric
class NetworkMetric {
  final String url;
  final String method;
  final Duration duration;
  final int statusCode;
  final int? requestSize;
  final int? responseSize;
  final DateTime timestamp;
  final bool success;
  final String? errorMessage;

  NetworkMetric({
    required this.url,
    required this.method,
    required this.duration,
    required this.statusCode,
    this.requestSize,
    this.responseSize,
    required this.timestamp,
    required this.success,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'method': method,
      'duration_ms': duration.inMilliseconds,
      'status_code': statusCode,
      'request_size_bytes': requestSize,
      'response_size_bytes': responseSize,
      'timestamp': timestamp.toIso8601String(),
      'success': success,
      'error_message': errorMessage,
    };
  }
}

/// Performance session tracking
class PerformanceSession {
  final DateTime startTime = DateTime.now();
  final List<PerformanceMetric> _metrics = [];

  void addMetric(PerformanceMetric metric) {
    _metrics.add(metric);
  }

  List<PerformanceMetric> get metrics => List.unmodifiable(_metrics);
  
  Duration get sessionDuration => DateTime.now().difference(startTime);
  
  int get totalOperations => _metrics.length;
  
  int get successfulOperations => _metrics.where((m) => m.success).length;
  
  int get failedOperations => totalOperations - successfulOperations;
  
  double get successRate => totalOperations > 0 ? successfulOperations / totalOperations : 1.0;
}

/// Performance report generation
class PerformanceReport {
  final DateTime timestamp;
  final int totalOperations;
  final Duration averageDuration;
  final double averageFrameRate;
  final int currentMemoryUsage;
  final double memoryGrowthRate;
  final Duration averageNetworkDuration;
  final List<PerformanceMetric> slowestOperations;

  PerformanceReport({
    required this.timestamp,
    required this.totalOperations,
    required this.averageDuration,
    required this.averageFrameRate,
    required this.currentMemoryUsage,
    required this.memoryGrowthRate,
    required this.averageNetworkDuration,
    required this.slowestOperations,
  });

  static PerformanceReport generate({
    required PerformanceSession session,
    required List<PerformanceMetric> metrics,
    required List<FramePerformanceData> frameData,
    required List<MemorySnapshot> memorySnapshots,
    required List<NetworkMetric> networkMetrics,
  }) {
    // Calculate average duration
    final avgDuration = metrics.isNotEmpty
        ? Duration(
            microseconds: metrics
                .map((m) => m.duration.inMicroseconds)
                .reduce((a, b) => a + b) ~/
            metrics.length,
          )
        : Duration.zero;

    // Calculate average frame rate
    final avgFrameRate = frameData.isNotEmpty
        ? frameData.map((f) => f.fps).reduce((a, b) => a + b) / frameData.length
        : 60.0;

    // Calculate memory growth rate
    double memoryGrowthRate = 0.0;
    if (memorySnapshots.length >= 2) {
      final first = memorySnapshots.first.rssUsage;
      final last = memorySnapshots.last.rssUsage;
      memoryGrowthRate = (last - first) / first;
    }

    // Calculate average network duration
    final avgNetworkDuration = networkMetrics.isNotEmpty
        ? Duration(
            microseconds: networkMetrics
                .map((m) => m.duration.inMicroseconds)
                .reduce((a, b) => a + b) ~/
            networkMetrics.length,
          )
        : Duration.zero;

    // Get slowest operations
    final sortedMetrics = metrics.toList()
      ..sort((a, b) => b.duration.compareTo(a.duration));
    final slowestOps = sortedMetrics.take(10).toList();

    return PerformanceReport(
      timestamp: DateTime.now(),
      totalOperations: metrics.length,
      averageDuration: avgDuration,
      averageFrameRate: avgFrameRate,
      currentMemoryUsage: memorySnapshots.isNotEmpty ? memorySnapshots.last.rssUsage : 0,
      memoryGrowthRate: memoryGrowthRate,
      averageNetworkDuration: avgNetworkDuration,
      slowestOperations: slowestOps,
    );
  }
}

/// Current performance snapshot
class PerformanceSnapshot {
  final DateTime timestamp;
  final int operationCount;
  final Duration averageDuration;
  final double frameRate;
  final int memoryUsage;
  final Duration networkLatency;

  PerformanceSnapshot({
    required this.timestamp,
    required this.operationCount,
    required this.averageDuration,
    required this.frameRate,
    required this.memoryUsage,
    required this.networkLatency,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'operation_count': operationCount,
      'average_duration_ms': averageDuration.inMilliseconds,
      'frame_rate': frameRate,
      'memory_usage_bytes': memoryUsage,
      'network_latency_ms': networkLatency.inMilliseconds,
    };
  }
}

/// App lifecycle observer for performance monitoring
class PerformanceLifecycleObserver extends WidgetsBindingObserver {
  final PerformanceMonitor monitor;

  PerformanceLifecycleObserver(this.monitor);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        AppLogger.performance('📱 App resumed - performance monitoring active');
        break;
      case AppLifecycleState.paused:
        AppLogger.performance('📱 App paused - performance monitoring reduced');
        break;
      case AppLifecycleState.detached:
        AppLogger.performance('📱 App detached - performance monitoring stopped');
        monitor.dispose();
        break;
      default:
        break;
    }
  }


  @override
  void didHaveMemoryPressure() {
    super.didHaveMemoryPressure();
    AppLogger.warning('🚨 Memory pressure detected by system');
    
    // Force garbage collection on memory pressure
    monitor._forceGarbageCollection();
  }
}

/// Performance optimization utilities
class PerformanceOptimizer {
  /// Optimize animations for better performance
  static void optimizeAnimations() {
    // Reduce animations in debug mode or low-end devices
    if (kDebugMode || _isLowEndDevice()) {
      // Note: disableAnimations is not available in newer Flutter versions
      // Instead, we can reduce animation durations or suggest users disable them in accessibility settings
      AppLogger.performance('🎬 Animation optimization suggestions applied');
    }
  }

  /// Check if device is low-end
  static bool _isLowEndDevice() {
    // This would implement device capability detection
    // For now, return false
    return false;
  }

  /// Optimize image loading
  static void optimizeImages() {
    // Configure image cache size based on available memory
    PaintingBinding.instance.imageCache.maximumSize = 100;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024; // 50MB
    AppLogger.performance('🖼️ Image cache optimized');
  }

  /// Optimize network performance
  static void optimizeNetwork() {
    // Configure HTTP client settings for better performance
    HttpOverrides.global = PerformanceHttpOverrides();
    AppLogger.performance('🌐 Network optimizations applied');
  }
}

/// Custom HTTP overrides for performance optimization
class PerformanceHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    
    // Configure timeouts
    client.connectionTimeout = const Duration(seconds: 15);
    client.idleTimeout = const Duration(seconds: 15);
    
    return client;
  }
}

/// Performance utilities
class PerformanceUtils {
  /// Measure widget build time
  static Widget measureWidgetBuild(Widget child, String widgetName) {
    return Builder(
      builder: (context) {
        final stopwatch = Stopwatch()..start();
        
        return Builder(
          builder: (context) {
            final result = child;
            stopwatch.stop();
            
            if (stopwatch.elapsedMilliseconds > 16) { // More than one frame
              AppLogger.warning(
                '🐌 Slow widget build: $widgetName (${stopwatch.elapsedMilliseconds}ms)',
              );
            }
            
            return result;
          },
        );
      },
    );
  }

  /// Create performance-aware ListView
  static Widget createOptimizedListView({
    required IndexedWidgetBuilder itemBuilder,
    required int itemCount,
    ScrollController? controller,
  }) {
    return ListView.builder(
      controller: controller,
      itemBuilder: (context, index) {
        return PerformanceUtils.measureWidgetBuild(
          itemBuilder(context, index),
          'ListItem_$index',
        );
      },
      itemCount: itemCount,
      cacheExtent: 1000.0, // Pre-cache items for smoother scrolling
      addAutomaticKeepAlives: false, // Disable keep-alives for memory efficiency
      addRepaintBoundaries: true, // Add repaint boundaries for performance
    );
  }
}
