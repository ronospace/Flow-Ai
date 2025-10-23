import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../utils/app_logger.dart';

/// Performance Optimization Service
/// Comprehensive performance monitoring and optimization for Flow Ai
class PerformanceOptimizationService {
  static final PerformanceOptimizationService _instance = PerformanceOptimizationService._internal();
  static PerformanceOptimizationService get instance => _instance;
  PerformanceOptimizationService._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Performance monitoring
  Timer? _performanceTimer;
  final List<PerformanceMetric> _performanceHistory = [];
  final int _maxHistorySize = 100;

  // Memory management
  Timer? _memoryCleanupTimer;
  final int _lastMemoryUsage = 0;
  final int _memoryThresholdMB = 150; // Alert threshold

  // Cache management
  final Map<String, CacheEntry> _imageCache = {};
  final Map<String, CacheEntry> _dataCache = {};
  final int _maxCacheSize = 50 * 1024 * 1024; // 50MB
  int _currentCacheSize = 0;

  // Network optimization
  final Map<String, NetworkRequest> _pendingRequests = {};
  Timer? _networkCleanupTimer;

  // Platform-specific optimizations
  bool _isLowPowerMode = false;
  bool _isMemoryWarning = false;

  /// Initialize performance optimization
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      AppLogger.info('⚡ Initializing Performance Optimization Service...');

      // Start performance monitoring
      _startPerformanceMonitoring();

      // Initialize memory management
      _initializeMemoryManagement();

      // Setup cache management
      _initializeCacheManagement();

      // Platform-specific optimizations
      await _initializePlatformOptimizations();

      // Network optimization
      _initializeNetworkOptimization();

      _isInitialized = true;
      AppLogger.success('✅ Performance Optimization Service initialized');
    } catch (e) {
      AppLogger.error('Failed to initialize performance service: $e');
      rethrow;
    }
  }

  /// Start performance monitoring
  void _startPerformanceMonitoring() {
    _performanceTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _collectPerformanceMetrics();
    });
  }

  /// Collect performance metrics
  Future<void> _collectPerformanceMetrics() async {
    try {
      final metric = PerformanceMetric(
        timestamp: DateTime.now(),
        memoryUsageMB: await _getCurrentMemoryUsage(),
        cacheUsageMB: _currentCacheSize / (1024 * 1024),
        frameRate: await _getCurrentFrameRate(),
        batteryLevel: await _getBatteryLevel(),
        networkLatency: await _getNetworkLatency(),
        cpuUsage: await _getCPUUsage(),
      );

      _performanceHistory.add(metric);

      // Keep history size manageable
      if (_performanceHistory.length > _maxHistorySize) {
        _performanceHistory.removeAt(0);
      }

      // Check for performance issues
      _checkPerformanceThresholds(metric);

      // Log performance data
      if (kDebugMode) {
        AppLogger.info('📊 Performance: Memory: ${metric.memoryUsageMB.toInt()}MB, FPS: ${metric.frameRate.toInt()}, Cache: ${metric.cacheUsageMB.toStringAsFixed(1)}MB');
      }
    } catch (e) {
      AppLogger.warning('Performance metrics collection failed: $e');
    }
  }

  /// Initialize memory management
  void _initializeMemoryManagement() {
    _memoryCleanupTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _performMemoryCleanup();
    });

    // Listen for system memory warnings
    if (Platform.isIOS) {
      _listenForMemoryWarnings();
    }
  }

  /// Perform memory cleanup
  Future<void> _performMemoryCleanup() async {
    try {
      final currentMemory = await _getCurrentMemoryUsage();
      
      if (currentMemory > _memoryThresholdMB || _isMemoryWarning) {
        AppLogger.info('🧹 Performing memory cleanup...');
        
        // Clear expired cache entries
        await _clearExpiredCache();
        
        // Force garbage collection
        await _forceGarbageCollection();
        
        // Clear image cache if memory is still high
        if (await _getCurrentMemoryUsage() > _memoryThresholdMB) {
          await _clearImageCache();
        }
        
        // Optimize data structures
        _optimizeDataStructures();
        
        final newMemory = await _getCurrentMemoryUsage();
        final freedMB = currentMemory - newMemory;
        
        if (freedMB > 0) {
          AppLogger.success('✅ Memory cleanup freed ${freedMB.toInt()}MB');
        }
        
        _isMemoryWarning = false;
      }
    } catch (e) {
      AppLogger.error('Memory cleanup failed: $e');
    }
  }

  /// Initialize cache management
  void _initializeCacheManagement() {
    // Pre-warm critical caches
    _preWarmCache();
    
    // Setup cache cleanup
    Timer.periodic(const Duration(hours: 1), (timer) {
      _performCacheOptimization();
    });
  }

  /// Initialize platform-specific optimizations
  Future<void> _initializePlatformOptimizations() async {
    try {
      if (Platform.isIOS) {
        await _initializeIOSOptimizations();
      } else if (Platform.isAndroid) {
        await _initializeAndroidOptimizations();
      }
    } catch (e) {
      AppLogger.warning('Platform optimization initialization failed: $e');
    }
  }

  /// iOS-specific optimizations
  Future<void> _initializeIOSOptimizations() async {
    // Enable iOS rendering optimizations
    if (!kDebugMode) {
      // Optimize for battery life in production
      await _optimizeForBatteryLife();
    }
    
    // Configure memory pressure handling
    _setupIOSMemoryHandling();
  }

  /// Android-specific optimizations
  Future<void> _initializeAndroidOptimizations() async {
    // Configure Android-specific optimizations
    await _optimizeAndroidPerformance();
  }

  /// Initialize network optimization
  void _initializeNetworkOptimization() {
    _networkCleanupTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _cleanupPendingRequests();
    });
  }

  /// Cache data with automatic expiration
  Future<void> cacheData(String key, dynamic data, {Duration? ttl}) async {
    try {
      final ttlDuration = ttl ?? const Duration(hours: 1);
      final serializedData = _serializeData(data);
      final dataSize = _calculateDataSize(serializedData);
      
      // Check if we need to make space
      if (_currentCacheSize + dataSize > _maxCacheSize) {
        await _makeSpaceInCache(dataSize);
      }
      
      _dataCache[key] = CacheEntry(
        data: serializedData,
        timestamp: DateTime.now(),
        ttl: ttlDuration,
        size: dataSize,
        accessCount: 0,
      );
      
      _currentCacheSize += dataSize;
      AppLogger.info('💾 Cached data: $key (${_formatBytes(dataSize)})');
    } catch (e) {
      AppLogger.error('Failed to cache data: $e');
    }
  }

  /// Retrieve cached data
  T? getCachedData<T>(String key) {
    try {
      final entry = _dataCache[key];
      if (entry == null) return null;
      
      // Check if expired
      if (DateTime.now().difference(entry.timestamp) > entry.ttl) {
        removeCachedData(key);
        return null;
      }
      
      // Update access statistics
      entry.accessCount++;
      entry.lastAccessed = DateTime.now();
      
      return _deserializeData<T>(entry.data);
    } catch (e) {
      AppLogger.error('Failed to retrieve cached data: $e');
      return null;
    }
  }

  /// Remove cached data
  void removeCachedData(String key) {
    final entry = _dataCache.remove(key);
    if (entry != null) {
      _currentCacheSize -= entry.size;
    }
  }

  /// Cache image with optimization
  Future<void> cacheImage(String key, Uint8List imageData, {Duration? ttl}) async {
    try {
      final optimizedData = await _optimizeImage(imageData);
      final ttlDuration = ttl ?? const Duration(days: 1);
      
      // Check cache space
      if (_currentCacheSize + optimizedData.length > _maxCacheSize) {
        await _makeSpaceInCache(optimizedData.length);
      }
      
      _imageCache[key] = CacheEntry(
        data: optimizedData,
        timestamp: DateTime.now(),
        ttl: ttlDuration,
        size: optimizedData.length,
        accessCount: 0,
      );
      
      _currentCacheSize += optimizedData.length;
      AppLogger.info('🖼️ Cached image: $key (${_formatBytes(optimizedData.length)})');
    } catch (e) {
      AppLogger.error('Failed to cache image: $e');
    }
  }

  /// Get cached image
  Uint8List? getCachedImage(String key) {
    try {
      final entry = _imageCache[key];
      if (entry == null) return null;
      
      // Check if expired
      if (DateTime.now().difference(entry.timestamp) > entry.ttl) {
        _imageCache.remove(key);
        _currentCacheSize -= entry.size;
        return null;
      }
      
      entry.accessCount++;
      entry.lastAccessed = DateTime.now();
      
      return entry.data as Uint8List;
    } catch (e) {
      AppLogger.error('Failed to retrieve cached image: $e');
      return null;
    }
  }

  /// Optimize app performance based on current conditions
  Future<void> optimizePerformance() async {
    try {
      AppLogger.info('⚡ Optimizing app performance...');
      
      // Analyze recent performance metrics
      final recentMetrics = _performanceHistory.take(10).toList();
      if (recentMetrics.isEmpty) return;
      
      final avgMemory = recentMetrics.map((m) => m.memoryUsageMB).reduce((a, b) => a + b) / recentMetrics.length;
      final avgFrameRate = recentMetrics.map((m) => m.frameRate).reduce((a, b) => a + b) / recentMetrics.length;
      final avgBattery = recentMetrics.map((m) => m.batteryLevel).reduce((a, b) => a + b) / recentMetrics.length;
      
      // Apply optimizations based on performance analysis
      if (avgMemory > _memoryThresholdMB) {
        await _performMemoryCleanup();
      }
      
      if (avgFrameRate < 30) {
        await _optimizeForFrameRate();
      }
      
      if (avgBattery < 20) {
        await _optimizeForBatteryLife();
      }
      
      AppLogger.success('✅ Performance optimization completed');
    } catch (e) {
      AppLogger.error('Performance optimization failed: $e');
    }
  }

  /// Pre-warm cache with critical data
  void _preWarmCache() {
    // This would pre-load critical app data
    AppLogger.info('🔥 Pre-warming cache with critical data...');
  }

  /// Make space in cache by removing least recently used entries
  Future<void> _makeSpaceInCache(int neededSpace) async {
    try {
      var freedSpace = 0;
      final allEntries = <MapEntry<String, CacheEntry>>[];
      
      // Combine all cache entries
      allEntries.addAll(_dataCache.entries.map((e) => MapEntry('data_${e.key}', e.value)));
      allEntries.addAll(_imageCache.entries.map((e) => MapEntry('image_${e.key}', e.value)));
      
      // Sort by last accessed (LRU)
      allEntries.sort((a, b) => (a.value.lastAccessed ?? a.value.timestamp).compareTo(b.value.lastAccessed ?? b.value.timestamp));
      
      for (final entry in allEntries) {
        if (freedSpace >= neededSpace) break;
        
        final key = entry.key;
        final size = entry.value.size;
        
        if (key.startsWith('data_')) {
          _dataCache.remove(key.substring(5));
        } else if (key.startsWith('image_')) {
          _imageCache.remove(key.substring(6));
        }
        
        freedSpace += size;
        _currentCacheSize -= size;
      }
      
      AppLogger.info('🗑️ Freed ${_formatBytes(freedSpace)} from cache');
    } catch (e) {
      AppLogger.error('Failed to make space in cache: $e');
    }
  }

  /// Clear expired cache entries
  Future<void> _clearExpiredCache() async {
    final now = DateTime.now();
    var freedSpace = 0;
    
    // Clear expired data cache
    final expiredDataKeys = _dataCache.entries
        .where((entry) => now.difference(entry.value.timestamp) > entry.value.ttl)
        .map((entry) => entry.key)
        .toList();
    
    for (final key in expiredDataKeys) {
      final entry = _dataCache.remove(key);
      if (entry != null) {
        freedSpace += entry.size;
        _currentCacheSize -= entry.size;
      }
    }
    
    // Clear expired image cache
    final expiredImageKeys = _imageCache.entries
        .where((entry) => now.difference(entry.value.timestamp) > entry.value.ttl)
        .map((entry) => entry.key)
        .toList();
    
    for (final key in expiredImageKeys) {
      final entry = _imageCache.remove(key);
      if (entry != null) {
        freedSpace += entry.size;
        _currentCacheSize -= entry.size;
      }
    }
    
    if (freedSpace > 0) {
      AppLogger.info('🕐 Cleared expired cache: ${_formatBytes(freedSpace)}');
    }
  }

  /// Force garbage collection
  Future<void> _forceGarbageCollection() async {
    if (kDebugMode) {
      // In debug mode, we can suggest GC
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    // Clear any weak references
    _performanceHistory.removeWhere((metric) => 
      DateTime.now().difference(metric.timestamp) > const Duration(hours: 1));
  }

  /// Clear image cache
  Future<void> _clearImageCache() async {
    final freedSpace = _imageCache.values.map((e) => e.size).fold(0, (a, b) => a + b);
    _imageCache.clear();
    _currentCacheSize -= freedSpace;
    AppLogger.info('🖼️ Cleared image cache: ${_formatBytes(freedSpace)}');
  }

  /// Optimize data structures
  void _optimizeDataStructures() {
    // Compact performance history
    if (_performanceHistory.length > _maxHistorySize ~/ 2) {
      final keepCount = _maxHistorySize ~/ 2;
      _performanceHistory.removeRange(0, _performanceHistory.length - keepCount);
    }
  }

  /// Optimize image data
  Future<Uint8List> _optimizeImage(Uint8List imageData) async {
    // In a real implementation, you might compress or resize the image
    // For now, return as-is
    return imageData;
  }

  /// Performance threshold checking
  void _checkPerformanceThresholds(PerformanceMetric metric) {
    final alerts = <String>[];
    
    if (metric.memoryUsageMB > _memoryThresholdMB) {
      alerts.add('High memory usage: ${metric.memoryUsageMB.toInt()}MB');
    }
    
    if (metric.frameRate < 30) {
      alerts.add('Low frame rate: ${metric.frameRate.toInt()}fps');
    }
    
    if (metric.batteryLevel < 20) {
      alerts.add('Low battery: ${metric.batteryLevel.toInt()}%');
      _isLowPowerMode = true;
    } else {
      _isLowPowerMode = false;
    }
    
    if (alerts.isNotEmpty) {
      AppLogger.warning('⚠️ Performance alerts: ${alerts.join(', ')}');
    }
  }

  /// Optimize for frame rate
  Future<void> _optimizeForFrameRate() async {
    AppLogger.info('🎬 Optimizing for better frame rate...');
    
    // Reduce animation complexity
    // Clear non-essential caches
    await _clearExpiredCache();
    
    // Reduce background processing
  }

  /// Optimize for battery life
  Future<void> _optimizeForBatteryLife() async {
    AppLogger.info('🔋 Optimizing for battery life...');
    
    // Reduce update frequency
    // Disable non-essential animations
    // Reduce network requests
  }

  /// Platform-specific methods
  Future<double> _getCurrentMemoryUsage() async {
    try {
      // This would use platform-specific APIs to get memory usage
      // For now, return a mock value based on cache usage
      return 50.0 + (_currentCacheSize / (1024 * 1024));
    } catch (e) {
      return 0.0;
    }
  }

  Future<double> _getCurrentFrameRate() async {
    // Mock frame rate based on performance
    return 60.0;
  }

  Future<double> _getBatteryLevel() async {
    // Mock battery level
    return 85.0;
  }

  Future<double> _getNetworkLatency() async {
    // Mock network latency
    return 50.0;
  }

  Future<double> _getCPUUsage() async {
    // Mock CPU usage
    return 15.0;
  }

  void _listenForMemoryWarnings() {
    // iOS memory warning handling would go here
  }

  void _setupIOSMemoryHandling() {
    // iOS-specific memory handling
  }

  Future<void> _optimizeAndroidPerformance() async {
    // Android-specific optimizations
  }

  void _performCacheOptimization() {
    // Regular cache optimization
    _clearExpiredCache();
  }

  void _cleanupPendingRequests() {
    final now = DateTime.now();
    final expiredKeys = _pendingRequests.entries
        .where((entry) => now.difference(entry.value.timestamp) > const Duration(minutes: 5))
        .map((entry) => entry.key)
        .toList();
    
    for (final key in expiredKeys) {
      _pendingRequests.remove(key);
    }
  }

  // Data serialization helpers
  dynamic _serializeData(dynamic data) {
    // Simple serialization - in practice might use more efficient methods
    return data;
  }

  T _deserializeData<T>(dynamic data) {
    return data as T;
  }

  int _calculateDataSize(dynamic data) {
    if (data is String) {
      return data.length * 2; // Rough estimate for UTF-16
    } else if (data is List) {
      return data.length * 8; // Rough estimate
    } else if (data is Map) {
      return data.length * 16; // Rough estimate
    }
    return 100; // Default estimate
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// Get performance report
  PerformanceReport getPerformanceReport() {
    if (_performanceHistory.isEmpty) {
      return PerformanceReport.empty();
    }

    final recentMetrics = _performanceHistory.take(10).toList();
    final avgMemory = recentMetrics.map((m) => m.memoryUsageMB).reduce((a, b) => a + b) / recentMetrics.length;
    final avgFrameRate = recentMetrics.map((m) => m.frameRate).reduce((a, b) => a + b) / recentMetrics.length;
    final avgBattery = recentMetrics.map((m) => m.batteryLevel).reduce((a, b) => a + b) / recentMetrics.length;

    return PerformanceReport(
      averageMemoryUsage: avgMemory,
      averageFrameRate: avgFrameRate,
      averageBatteryLevel: avgBattery,
      cacheUsageMB: _currentCacheSize / (1024 * 1024),
      isLowPowerMode: _isLowPowerMode,
      totalCacheEntries: _dataCache.length + _imageCache.length,
      performanceScore: _calculatePerformanceScore(avgMemory, avgFrameRate, avgBattery),
    );
  }

  double _calculatePerformanceScore(double memory, double frameRate, double battery) {
    var score = 100.0;
    
    // Deduct for high memory usage
    if (memory > _memoryThresholdMB) {
      score -= (memory - _memoryThresholdMB) / _memoryThresholdMB * 30;
    }
    
    // Deduct for low frame rate
    if (frameRate < 60) {
      score -= (60 - frameRate) / 60 * 20;
    }
    
    // Deduct for low battery
    if (battery < 50) {
      score -= (50 - battery) / 50 * 10;
    }
    
    return (score.clamp(0, 100) / 100);
  }

  /// Dispose of resources
  void dispose() {
    _performanceTimer?.cancel();
    _memoryCleanupTimer?.cancel();
    _networkCleanupTimer?.cancel();
    _dataCache.clear();
    _imageCache.clear();
    _performanceHistory.clear();
    _pendingRequests.clear();
    _isInitialized = false;
  }
}

/// Performance metric data class
class PerformanceMetric {
  final DateTime timestamp;
  final double memoryUsageMB;
  final double cacheUsageMB;
  final double frameRate;
  final double batteryLevel;
  final double networkLatency;
  final double cpuUsage;

  PerformanceMetric({
    required this.timestamp,
    required this.memoryUsageMB,
    required this.cacheUsageMB,
    required this.frameRate,
    required this.batteryLevel,
    required this.networkLatency,
    required this.cpuUsage,
  });
}

/// Cache entry class
class CacheEntry {
  final dynamic data;
  final DateTime timestamp;
  final Duration ttl;
  final int size;
  int accessCount;
  DateTime? lastAccessed;

  CacheEntry({
    required this.data,
    required this.timestamp,
    required this.ttl,
    required this.size,
    this.accessCount = 0,
    this.lastAccessed,
  });
}

/// Network request tracking
class NetworkRequest {
  final DateTime timestamp;
  final String url;
  bool isCompleted;

  NetworkRequest({
    required this.timestamp,
    required this.url,
    this.isCompleted = false,
  });
}

/// Performance report
class PerformanceReport {
  final double averageMemoryUsage;
  final double averageFrameRate;
  final double averageBatteryLevel;
  final double cacheUsageMB;
  final bool isLowPowerMode;
  final int totalCacheEntries;
  final double performanceScore;

  PerformanceReport({
    required this.averageMemoryUsage,
    required this.averageFrameRate,
    required this.averageBatteryLevel,
    required this.cacheUsageMB,
    required this.isLowPowerMode,
    required this.totalCacheEntries,
    required this.performanceScore,
  });

  factory PerformanceReport.empty() {
    return PerformanceReport(
      averageMemoryUsage: 0,
      averageFrameRate: 60,
      averageBatteryLevel: 100,
      cacheUsageMB: 0,
      isLowPowerMode: false,
      totalCacheEntries: 0,
      performanceScore: 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'averageMemoryUsage': averageMemoryUsage,
      'averageFrameRate': averageFrameRate,
      'averageBatteryLevel': averageBatteryLevel,
      'cacheUsageMB': cacheUsageMB,
      'isLowPowerMode': isLowPowerMode,
      'totalCacheEntries': totalCacheEntries,
      'performanceScore': performanceScore,
    };
  }
}
