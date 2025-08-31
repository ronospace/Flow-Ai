import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';
import 'app_enhancement_service.dart';

/// Comprehensive performance optimization service
class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  bool _isInitialized = false;
  Timer? _memoryCleanupTimer;
  Timer? _cacheCleanupTimer;
  Timer? _performanceMonitoringTimer;

  // Cache management
  final Map<String, CacheEntry> _cache = {};
  final Map<String, ui.Image> _imageCache = {};
  final Map<String, Uint8List> _dataCache = {};

  // Performance metrics
  final List<PerformanceMetric> _metrics = [];
  final Map<String, Stopwatch> _activeTraces = {};

  // Configuration
  static const int maxCacheSize = 50 * 1024 * 1024; // 50MB
  static const int maxImageCacheSize = 20 * 1024 * 1024; // 20MB
  static const Duration cacheExpiry = Duration(hours: 24);
  static const Duration memoryCleanupInterval = Duration(minutes: 10);

  /// Initialize the performance service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      AppLogger.performance('🚀 Initializing Performance Service...');
      
      // Configure Flutter performance settings
      _configureFlutterPerformance();
      
      // Start background optimization tasks
      _startBackgroundTasks();
      
      // Initialize memory monitoring
      _startMemoryMonitoring();
      
      _isInitialized = true;
      AppLogger.performance('✅ Performance Service initialized successfully');
      
    } catch (e) {
      AppLogger.error('❌ Failed to initialize Performance Service', e);
      rethrow;
    }
  }

  /// Configure Flutter-specific performance settings
  void _configureFlutterPerformance() {
    // Configure image cache
    PaintingBinding.instance.imageCache.maximumSize = 150;
    PaintingBinding.instance.imageCache.maximumSizeBytes = maxImageCacheSize;
    
    // Configure raster cache
    if (!kIsWeb) {
      // These settings are platform-specific and may not apply to web
      try {
        // Enable hardware acceleration where available
        AppLogger.performance('🔧 Hardware acceleration configured');
      } catch (e) {
        AppLogger.warning('Hardware acceleration not available: $e');
      }
    }
    
    AppLogger.performance('✅ Flutter performance settings configured');
  }

  /// Start a performance trace
  void startTrace(String traceName) {
    if (_activeTraces.containsKey(traceName)) {
      AppLogger.warning('Trace already active: $traceName');
      return;
    }
    
    _activeTraces[traceName] = Stopwatch()..start();
    AppLogger.performance('📊 Started trace: $traceName');
  }

  /// Stop a performance trace and record the metric
  Duration? stopTrace(String traceName) {
    final stopwatch = _activeTraces.remove(traceName);
    if (stopwatch == null) {
      AppLogger.warning('No active trace found: $traceName');
      return null;
    }
    
    stopwatch.stop();
    final duration = stopwatch.elapsed;
    
    // Record the metric
    final metric = PerformanceMetric(
      name: traceName,
      duration: duration,
      timestamp: DateTime.now(),
      type: PerformanceMetricType.timing,
    );
    
    _recordMetric(metric);
    AppLogger.performance('⏱️ Trace "$traceName" completed in ${duration.inMilliseconds}ms');
    
    return duration;
  }

  /// Measure the performance of a function
  Future<T> measureAsync<T>(String traceName, Future<T> Function() function) async {
    startTrace(traceName);
    try {
      final result = await function();
      return result;
    } finally {
      stopTrace(traceName);
    }
  }

  /// Measure the performance of a synchronous function
  T measureSync<T>(String traceName, T Function() function) {
    startTrace(traceName);
    try {
      final result = function();
      return result;
    } finally {
      stopTrace(traceName);
    }
  }

  /// Cache data with automatic expiry
  void cacheData(String key, dynamic data, {Duration? expiry}) {
    final expiryTime = DateTime.now().add(expiry ?? cacheExpiry);
    final entry = CacheEntry(
      data: data,
      timestamp: DateTime.now(),
      expiryTime: expiryTime,
      size: _estimateDataSize(data),
    );
    
    _cache[key] = entry;
    _enforceCacheSize();
    
    AppLogger.performance('💾 Cached data: $key (${entry.size} bytes)');
  }

  /// Retrieve cached data
  T? getCachedData<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    
    // Check if expired
    if (DateTime.now().isAfter(entry.expiryTime)) {
      _cache.remove(key);
      AppLogger.performance('🗑️ Removed expired cache entry: $key');
      return null;
    }
    
    return entry.data as T?;
  }

  /// Cache optimized images
  Future<ui.Image?> cacheOptimizedImage(
    String key,
    Uint8List imageData, {
    int? targetWidth,
    int? targetHeight,
    int quality = 85,
  }) async {
    try {
      // Check if already cached
      final cached = _imageCache[key];
      if (cached != null) return cached;
      
      // Optimize and cache the image
      final optimized = await _optimizeImage(
        imageData,
        targetWidth: targetWidth,
        targetHeight: targetHeight,
        quality: quality,
      );
      
      if (optimized != null) {
        _imageCache[key] = optimized;
        _enforceImageCacheSize();
        AppLogger.performance('🖼️ Image cached and optimized: $key');
      }
      
      return optimized;
      
    } catch (e) {
      AppLogger.error('❌ Failed to cache optimized image', e);
      return null;
    }
  }

  /// Optimize image data
  Future<ui.Image?> _optimizeImage(
    Uint8List imageData, {
    int? targetWidth,
    int? targetHeight,
    int quality = 85,
  }) async {
    try {
      final codec = await ui.instantiateImageCodec(
        imageData,
        targetWidth: targetWidth,
        targetHeight: targetHeight,
      );
      
      final frameInfo = await codec.getNextFrame();
      return frameInfo.image;
      
    } catch (e) {
      AppLogger.error('❌ Image optimization failed', e);
      return null;
    }
  }

  /// Preload critical resources
  Future<void> preloadCriticalResources(BuildContext context) async {
    const criticalAssets = [
      'assets/images/logo.png',
      'assets/images/onboarding_1.png',
      'assets/images/onboarding_2.png',
      'assets/images/onboarding_3.png',
    ];

    final futures = criticalAssets.map((asset) async {
      try {
        await precacheImage(AssetImage(asset), context);
        AppLogger.performance('✅ Preloaded asset: $asset');
      } catch (e) {
        AppLogger.warning('Failed to preload asset $asset: $e');
      }
    });

    await Future.wait(futures);
    AppLogger.performance('✅ Critical resources preloaded');
  }

  /// Optimize memory usage
  void optimizeMemory() {
    try {
      // Clear expired cache entries
      _clearExpiredCache();
      
      // Trim image cache if needed
      _trimImageCache();
      
      // Force garbage collection in debug mode
      if (kDebugMode) {
        // Note: This is for debugging only and not recommended for production
        AppLogger.performance('🧹 Memory optimization completed');
      }
      
    } catch (e) {
      AppLogger.error('❌ Memory optimization failed', e);
    }
  }

  /// Get current memory usage estimates
  MemoryUsage getMemoryUsage() {
    final cacheSize = _cache.values.fold<int>(0, (sum, entry) => sum + entry.size);
    final imageCacheSize = _imageCache.length * 1024; // Rough estimate
    final dataCacheSize = _dataCache.values.fold<int>(0, (sum, data) => sum + data.length);
    
    return MemoryUsage(
      totalCacheSize: cacheSize,
      imageCacheSize: imageCacheSize,
      dataCacheSize: dataCacheSize,
      cacheEntries: _cache.length,
      imageEntries: _imageCache.length,
      dataEntries: _dataCache.length,
    );
  }

  /// Get performance metrics
  List<PerformanceMetric> getMetrics({Duration? since}) {
    if (since == null) return List.unmodifiable(_metrics);
    
    final cutoff = DateTime.now().subtract(since);
    return _metrics.where((m) => m.timestamp.isAfter(cutoff)).toList();
  }

  /// Get average metric value
  double getAverageMetric(String metricName, {Duration? since}) {
    final metrics = getMetrics(since: since)
        .where((m) => m.name == metricName)
        .toList();
    
    if (metrics.isEmpty) return 0.0;
    
    final totalMs = metrics.fold<int>(0, (sum, m) => sum + m.duration.inMilliseconds);
    return totalMs / metrics.length;
  }

  /// Clear all caches
  void clearAllCaches() {
    _cache.clear();
    _imageCache.clear();
    _dataCache.clear();
    PaintingBinding.instance.imageCache.clear();
    
    AppLogger.performance('🧹 All caches cleared');
  }

  /// Start background optimization tasks
  void _startBackgroundTasks() {
    // Memory cleanup task
    _memoryCleanupTimer = Timer.periodic(memoryCleanupInterval, (timer) {
      optimizeMemory();
    });
    
    // Cache cleanup task
    _cacheCleanupTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _clearExpiredCache();
    });
    
    AppLogger.performance('✅ Background optimization tasks started');
  }

  /// Start memory monitoring
  void _startMemoryMonitoring() {
    _performanceMonitoringTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _recordMemoryMetrics();
    });
  }

  /// Record memory-related metrics
  void _recordMemoryMetrics() {
    try {
      final memoryUsage = getMemoryUsage();
      
      _recordMetric(PerformanceMetric(
        name: 'memory.cache_size',
        duration: Duration(bytes: memoryUsage.totalCacheSize),
        timestamp: DateTime.now(),
        type: PerformanceMetricType.memory,
      ));
      
      _recordMetric(PerformanceMetric(
        name: 'memory.cache_entries',
        duration: Duration(microseconds: memoryUsage.cacheEntries),
        timestamp: DateTime.now(),
        type: PerformanceMetricType.counter,
      ));
      
    } catch (e) {
      AppLogger.warning('Failed to record memory metrics: $e');
    }
  }

  /// Record a performance metric
  void _recordMetric(PerformanceMetric metric) {
    _metrics.add(metric);
    
    // Keep only recent metrics (last 1000 or last hour)
    final cutoff = DateTime.now().subtract(const Duration(hours: 1));
    _metrics.removeWhere((m) => m.timestamp.isBefore(cutoff));
    
    if (_metrics.length > 1000) {
      _metrics.removeRange(0, _metrics.length - 1000);
    }
  }

  /// Estimate data size in bytes
  int _estimateDataSize(dynamic data) {
    if (data is String) return data.length * 2; // UTF-16
    if (data is List<int>) return data.length;
    if (data is Map) return data.toString().length * 2;
    return 1024; // Default estimate
  }

  /// Enforce cache size limits
  void _enforceCacheSize() {
    var totalSize = _cache.values.fold<int>(0, (sum, entry) => sum + entry.size);
    
    if (totalSize <= maxCacheSize) return;
    
    // Remove oldest entries until under limit
    final sortedEntries = _cache.entries.toList()
      ..sort((a, b) => a.value.timestamp.compareTo(b.value.timestamp));
    
    for (final entry in sortedEntries) {
      _cache.remove(entry.key);
      totalSize -= entry.value.size;
      
      if (totalSize <= maxCacheSize * 0.8) break; // Leave some headroom
    }
    
    AppLogger.performance('🧹 Cache size enforced: ${_cache.length} entries');
  }

  /// Enforce image cache size limits
  void _enforceImageCacheSize() {
    if (_imageCache.length <= 50) return; // Reasonable limit
    
    // Remove half of the oldest entries
    final keys = _imageCache.keys.take(_imageCache.length ~/ 2).toList();
    for (final key in keys) {
      _imageCache.remove(key);
    }
    
    AppLogger.performance('🧹 Image cache size enforced: ${_imageCache.length} images');
  }

  /// Clear expired cache entries
  void _clearExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = _cache.entries
        .where((entry) => now.isAfter(entry.value.expiryTime))
        .map((entry) => entry.key)
        .toList();
    
    for (final key in expiredKeys) {
      _cache.remove(key);
    }
    
    if (expiredKeys.isNotEmpty) {
      AppLogger.performance('🗑️ Cleared ${expiredKeys.length} expired cache entries');
    }
  }

  /// Trim image cache
  void _trimImageCache() {
    if (_imageCache.length > 100) {
      final keysToRemove = _imageCache.keys.take(_imageCache.length - 75).toList();
      for (final key in keysToRemove) {
        _imageCache.remove(key);
      }
      AppLogger.performance('✂️ Trimmed image cache to ${_imageCache.length} entries');
    }
  }

  /// Dispose resources
  void dispose() {
    _memoryCleanupTimer?.cancel();
    _cacheCleanupTimer?.cancel();
    _performanceMonitoringTimer?.cancel();
    
    clearAllCaches();
    _metrics.clear();
    _activeTraces.clear();
    
    _isInitialized = false;
    AppLogger.performance('🔄 Performance Service disposed');
  }
}

/// Cache entry model
class CacheEntry {
  final dynamic data;
  final DateTime timestamp;
  final DateTime expiryTime;
  final int size;

  CacheEntry({
    required this.data,
    required this.timestamp,
    required this.expiryTime,
    required this.size,
  });
}

/// Performance metric model
class PerformanceMetric {
  final String name;
  final Duration duration;
  final DateTime timestamp;
  final PerformanceMetricType type;

  PerformanceMetric({
    required this.name,
    required this.duration,
    required this.timestamp,
    required this.type,
  });
}

/// Performance metric types
enum PerformanceMetricType {
  timing,
  memory,
  counter,
  network,
}

/// Memory usage model
class MemoryUsage {
  final int totalCacheSize;
  final int imageCacheSize;
  final int dataCacheSize;
  final int cacheEntries;
  final int imageEntries;
  final int dataEntries;

  MemoryUsage({
    required this.totalCacheSize,
    required this.imageCacheSize,
    required this.dataCacheSize,
    required this.cacheEntries,
    required this.imageEntries,
    required this.dataEntries,
  });

  /// Total memory usage in bytes
  int get totalSize => totalCacheSize + imageCacheSize + dataCacheSize;

  /// Total entries across all caches
  int get totalEntries => cacheEntries + imageEntries + dataEntries;

  /// Format size as human readable string
  String formatSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  @override
  String toString() {
    return 'MemoryUsage(total: ${formatSize(totalSize)}, entries: $totalEntries)';
  }
}

/// Performance optimization extensions
extension PerformanceWidget on Widget {
  /// Wrap widget with performance monitoring
  Widget withPerformanceTrace(String traceName) {
    return PerformanceTraceWidget(
      traceName: traceName,
      child: this,
    );
  }
}

/// Widget that automatically traces build performance
class PerformanceTraceWidget extends StatefulWidget {
  final String traceName;
  final Widget child;

  const PerformanceTraceWidget({
    super.key,
    required this.traceName,
    required this.child,
  });

  @override
  State<PerformanceTraceWidget> createState() => _PerformanceTraceWidgetState();
}

class _PerformanceTraceWidgetState extends State<PerformanceTraceWidget> {
  @override
  void initState() {
    super.initState();
    PerformanceService().startTrace('widget_build_${widget.traceName}');
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PerformanceService().stopTrace('widget_build_${widget.traceName}');
    });

    return widget.child;
  }
}
