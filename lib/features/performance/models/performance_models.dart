import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

// === ENUMS ===

enum CacheStrategy {
  lru, // Least Recently Used
  lfu, // Least Frequently Used
  fifo, // First In First Out
  ttl, // Time To Live
  adaptive, // Smart adaptive based on usage patterns
}

enum DataLoadStrategy {
  eager, // Load all data upfront
  lazy, // Load data on demand
  predictive, // Pre-load based on usage patterns
  hybrid, // Combination approach
}

enum MemoryPressureLevel {
  normal,
  moderate,
  high,
  critical,
}

enum OptimizationLevel {
  minimal,
  balanced,
  aggressive,
  maximum,
}

enum CompressionType {
  none,
  gzip,
  lz4,
  snappy,
  brotli,
}

enum DatabaseOptimization {
  indexing,
  partitioning,
  compression,
  vacuuming,
  wal, // Write-Ahead Logging
}

// === CACHE MODELS ===

class CacheEntry<T> {
  final String key;
  final T data;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int accessCount;
  final DateTime lastAccessedAt;
  final int sizeBytes;
  final Map<String, dynamic> metadata;

  CacheEntry({
    required this.key,
    required this.data,
    required this.createdAt,
    this.expiresAt,
    this.accessCount = 1,
    required this.lastAccessedAt,
    required this.sizeBytes,
    this.metadata = const {},
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  CacheEntry<T> copyWithAccess() {
    return CacheEntry<T>(
      key: key,
      data: data,
      createdAt: createdAt,
      expiresAt: expiresAt,
      accessCount: accessCount + 1,
      lastAccessedAt: DateTime.now(),
      sizeBytes: sizeBytes,
      metadata: metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'access_count': accessCount,
      'last_accessed_at': lastAccessedAt.toIso8601String(),
      'size_bytes': sizeBytes,
      'metadata': metadata,
    };
  }

  factory CacheEntry.fromJson(Map<String, dynamic> json, T data) {
    return CacheEntry<T>(
      key: json['key'],
      data: data,
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
      accessCount: json['access_count'] ?? 1,
      lastAccessedAt: DateTime.parse(json['last_accessed_at']),
      sizeBytes: json['size_bytes'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class CacheConfiguration {
  final int maxMemoryUsageBytes;
  final int maxItemCount;
  final Duration defaultTtl;
  final CacheStrategy strategy;
  final bool enableCompression;
  final CompressionType compressionType;
  final bool enablePersistence;
  final bool enableMetrics;
  final double memoryThreshold; // 0.0 to 1.0

  const CacheConfiguration({
    this.maxMemoryUsageBytes = 50 * 1024 * 1024, // 50MB
    this.maxItemCount = 10000,
    this.defaultTtl = const Duration(hours: 6),
    this.strategy = CacheStrategy.lru,
    this.enableCompression = true,
    this.compressionType = CompressionType.gzip,
    this.enablePersistence = true,
    this.enableMetrics = true,
    this.memoryThreshold = 0.8,
  });

  Map<String, dynamic> toJson() {
    return {
      'max_memory_usage_bytes': maxMemoryUsageBytes,
      'max_item_count': maxItemCount,
      'default_ttl_ms': defaultTtl.inMilliseconds,
      'strategy': strategy.name,
      'enable_compression': enableCompression,
      'compression_type': compressionType.name,
      'enable_persistence': enablePersistence,
      'enable_metrics': enableMetrics,
      'memory_threshold': memoryThreshold,
    };
  }

  factory CacheConfiguration.fromJson(Map<String, dynamic> json) {
    return CacheConfiguration(
      maxMemoryUsageBytes: json['max_memory_usage_bytes'] ?? 50 * 1024 * 1024,
      maxItemCount: json['max_item_count'] ?? 10000,
      defaultTtl: Duration(milliseconds: json['default_ttl_ms'] ?? 6 * 60 * 60 * 1000),
      strategy: CacheStrategy.values.firstWhere(
        (e) => e.name == json['strategy'],
        orElse: () => CacheStrategy.lru,
      ),
      enableCompression: json['enable_compression'] ?? true,
      compressionType: CompressionType.values.firstWhere(
        (e) => e.name == json['compression_type'],
        orElse: () => CompressionType.gzip,
      ),
      enablePersistence: json['enable_persistence'] ?? true,
      enableMetrics: json['enable_metrics'] ?? true,
      memoryThreshold: json['memory_threshold'] ?? 0.8,
    );
  }
}

// === MEMORY MONITORING ===

class MemoryUsageInfo {
  final int totalMemoryBytes;
  final int usedMemoryBytes;
  final int availableMemoryBytes;
  final double usagePercentage;
  final MemoryPressureLevel pressureLevel;
  final Map<String, int> categoryUsage; // Usage by category
  final DateTime timestamp;

  MemoryUsageInfo({
    required this.totalMemoryBytes,
    required this.usedMemoryBytes,
    required this.availableMemoryBytes,
    required this.usagePercentage,
    required this.pressureLevel,
    required this.categoryUsage,
    required this.timestamp,
  });

  static MemoryPressureLevel calculatePressureLevel(double usagePercentage) {
    if (usagePercentage >= 0.9) return MemoryPressureLevel.critical;
    if (usagePercentage >= 0.75) return MemoryPressureLevel.high;
    if (usagePercentage >= 0.6) return MemoryPressureLevel.moderate;
    return MemoryPressureLevel.normal;
  }

  Map<String, dynamic> toJson() {
    return {
      'total_memory_bytes': totalMemoryBytes,
      'used_memory_bytes': usedMemoryBytes,
      'available_memory_bytes': availableMemoryBytes,
      'usage_percentage': usagePercentage,
      'pressure_level': pressureLevel.name,
      'category_usage': categoryUsage,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory MemoryUsageInfo.fromJson(Map<String, dynamic> json) {
    return MemoryUsageInfo(
      totalMemoryBytes: json['total_memory_bytes'],
      usedMemoryBytes: json['used_memory_bytes'],
      availableMemoryBytes: json['available_memory_bytes'],
      usagePercentage: json['usage_percentage'],
      pressureLevel: MemoryPressureLevel.values.firstWhere(
        (e) => e.name == json['pressure_level'],
      ),
      categoryUsage: Map<String, int>.from(json['category_usage']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

// === PERFORMANCE METRICS ===

class PerformanceMetrics {
  final double cpuUsagePercentage;
  final int memoryUsageBytes;
  final int networkBytesReceived;
  final int networkBytesSent;
  final int databaseQueryCount;
  final double averageQueryTime;
  final int cacheHits;
  final int cacheMisses;
  final double frameRenderTime;
  final int gcCount; // Garbage Collection count
  final Duration upTime;
  final Map<String, double> customMetrics;
  final DateTime timestamp;

  PerformanceMetrics({
    required this.cpuUsagePercentage,
    required this.memoryUsageBytes,
    required this.networkBytesReceived,
    required this.networkBytesSent,
    required this.databaseQueryCount,
    required this.averageQueryTime,
    required this.cacheHits,
    required this.cacheMisses,
    required this.frameRenderTime,
    required this.gcCount,
    required this.upTime,
    required this.customMetrics,
    required this.timestamp,
  });

  double get cacheHitRatio {
    final total = cacheHits + cacheMisses;
    if (total == 0) return 0.0;
    return cacheHits / total;
  }

  Map<String, dynamic> toJson() {
    return {
      'cpu_usage_percentage': cpuUsagePercentage,
      'memory_usage_bytes': memoryUsageBytes,
      'network_bytes_received': networkBytesReceived,
      'network_bytes_sent': networkBytesSent,
      'database_query_count': databaseQueryCount,
      'average_query_time': averageQueryTime,
      'cache_hits': cacheHits,
      'cache_misses': cacheMisses,
      'frame_render_time': frameRenderTime,
      'gc_count': gcCount,
      'up_time_ms': upTime.inMilliseconds,
      'custom_metrics': customMetrics,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return PerformanceMetrics(
      cpuUsagePercentage: json['cpu_usage_percentage'],
      memoryUsageBytes: json['memory_usage_bytes'],
      networkBytesReceived: json['network_bytes_received'],
      networkBytesSent: json['network_bytes_sent'],
      databaseQueryCount: json['database_query_count'],
      averageQueryTime: json['average_query_time'],
      cacheHits: json['cache_hits'],
      cacheMisses: json['cache_misses'],
      frameRenderTime: json['frame_render_time'],
      gcCount: json['gc_count'],
      upTime: Duration(milliseconds: json['up_time_ms']),
      customMetrics: Map<String, double>.from(json['custom_metrics']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

// === DATABASE OPTIMIZATION ===

class DatabaseOptimizationConfig {
  final bool enableWal; // Write-Ahead Logging
  final int cacheSize; // SQLite cache size in KB
  final int pageSize; // Database page size
  final bool enableMemoryMapping;
  final bool enableJournalMode;
  final int busyTimeout;
  final Set<DatabaseOptimization> optimizations;
  final bool enableQueryPlanning;
  final bool enableStatistics;

  const DatabaseOptimizationConfig({
    this.enableWal = true,
    this.cacheSize = 2048, // 2MB
    this.pageSize = 4096, // 4KB
    this.enableMemoryMapping = true,
    this.enableJournalMode = true,
    this.busyTimeout = 30000, // 30 seconds
    this.optimizations = const {
      DatabaseOptimization.indexing,
      DatabaseOptimization.compression,
      DatabaseOptimization.wal,
    },
    this.enableQueryPlanning = true,
    this.enableStatistics = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'enable_wal': enableWal,
      'cache_size': cacheSize,
      'page_size': pageSize,
      'enable_memory_mapping': enableMemoryMapping,
      'enable_journal_mode': enableJournalMode,
      'busy_timeout': busyTimeout,
      'optimizations': optimizations.map((o) => o.name).toList(),
      'enable_query_planning': enableQueryPlanning,
      'enable_statistics': enableStatistics,
    };
  }
}

class DatabasePerformanceMetrics {
  final int totalQueries;
  final double averageQueryTime;
  final double maxQueryTime;
  final int cacheHits;
  final int cacheMisses;
  final int totalRows;
  final int databaseSizeBytes;
  final int indexCount;
  final Map<String, int> tableRowCounts;
  final Map<String, double> tableQueryTimes;
  final DateTime timestamp;

  DatabasePerformanceMetrics({
    required this.totalQueries,
    required this.averageQueryTime,
    required this.maxQueryTime,
    required this.cacheHits,
    required this.cacheMisses,
    required this.totalRows,
    required this.databaseSizeBytes,
    required this.indexCount,
    required this.tableRowCounts,
    required this.tableQueryTimes,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'total_queries': totalQueries,
      'average_query_time': averageQueryTime,
      'max_query_time': maxQueryTime,
      'cache_hits': cacheHits,
      'cache_misses': cacheMisses,
      'total_rows': totalRows,
      'database_size_bytes': databaseSizeBytes,
      'index_count': indexCount,
      'table_row_counts': tableRowCounts,
      'table_query_times': tableQueryTimes,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

// === OPTIMIZATION CONFIGURATION ===

class PerformanceOptimizationConfig {
  final OptimizationLevel level;
  final CacheConfiguration cacheConfig;
  final DatabaseOptimizationConfig databaseConfig;
  final DataLoadStrategy dataLoadStrategy;
  final bool enableLazyLoading;
  final bool enableImageOptimization;
  final bool enableBackgroundProcessing;
  final int maxConcurrentOperations;
  final Duration backgroundTaskInterval;
  final bool enableMemoryCompaction;
  final bool enableGarbageCollectionHints;
  final Map<String, dynamic> customSettings;

  const PerformanceOptimizationConfig({
    this.level = OptimizationLevel.balanced,
    this.cacheConfig = const CacheConfiguration(),
    this.databaseConfig = const DatabaseOptimizationConfig(),
    this.dataLoadStrategy = DataLoadStrategy.hybrid,
    this.enableLazyLoading = true,
    this.enableImageOptimization = true,
    this.enableBackgroundProcessing = true,
    this.maxConcurrentOperations = 4,
    this.backgroundTaskInterval = const Duration(minutes: 5),
    this.enableMemoryCompaction = true,
    this.enableGarbageCollectionHints = true,
    this.customSettings = const {},
  });

  factory PerformanceOptimizationConfig.minimal() {
    return const PerformanceOptimizationConfig(
      level: OptimizationLevel.minimal,
      cacheConfig: CacheConfiguration(
        maxMemoryUsageBytes: 10 * 1024 * 1024, // 10MB
        maxItemCount: 1000,
      ),
      enableLazyLoading: false,
      enableImageOptimization: false,
      enableBackgroundProcessing: false,
      maxConcurrentOperations: 2,
      enableMemoryCompaction: false,
      enableGarbageCollectionHints: false,
    );
  }

  factory PerformanceOptimizationConfig.aggressive() {
    return const PerformanceOptimizationConfig(
      level: OptimizationLevel.aggressive,
      cacheConfig: CacheConfiguration(
        maxMemoryUsageBytes: 100 * 1024 * 1024, // 100MB
        maxItemCount: 50000,
        strategy: CacheStrategy.adaptive,
        enableCompression: true,
        compressionType: CompressionType.lz4,
      ),
      databaseConfig: DatabaseOptimizationConfig(
        cacheSize: 4096, // 4MB
        optimizations: {
          DatabaseOptimization.indexing,
          DatabaseOptimization.compression,
          DatabaseOptimization.partitioning,
          DatabaseOptimization.wal,
          DatabaseOptimization.vacuuming,
        },
      ),
      dataLoadStrategy: DataLoadStrategy.predictive,
      maxConcurrentOperations: 8,
      backgroundTaskInterval: Duration(minutes: 1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level.name,
      'cache_config': cacheConfig.toJson(),
      'database_config': databaseConfig.toJson(),
      'data_load_strategy': dataLoadStrategy.name,
      'enable_lazy_loading': enableLazyLoading,
      'enable_image_optimization': enableImageOptimization,
      'enable_background_processing': enableBackgroundProcessing,
      'max_concurrent_operations': maxConcurrentOperations,
      'background_task_interval_ms': backgroundTaskInterval.inMilliseconds,
      'enable_memory_compaction': enableMemoryCompaction,
      'enable_garbage_collection_hints': enableGarbageCollectionHints,
      'custom_settings': customSettings,
    };
  }
}

// === IMAGE OPTIMIZATION ===

class ImageOptimizationConfig {
  final int maxWidth;
  final int maxHeight;
  final int quality; // 0-100
  final bool enableCaching;
  final bool enableCompression;
  final CompressionType compressionType;
  final bool enableThumbnails;
  final List<int> thumbnailSizes;
  final bool enableProgressiveLoading;

  const ImageOptimizationConfig({
    this.maxWidth = 1920,
    this.maxHeight = 1080,
    this.quality = 85,
    this.enableCaching = true,
    this.enableCompression = true,
    this.compressionType = CompressionType.gzip,
    this.enableThumbnails = true,
    this.thumbnailSizes = const [150, 300, 600],
    this.enableProgressiveLoading = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'max_width': maxWidth,
      'max_height': maxHeight,
      'quality': quality,
      'enable_caching': enableCaching,
      'enable_compression': enableCompression,
      'compression_type': compressionType.name,
      'enable_thumbnails': enableThumbnails,
      'thumbnail_sizes': thumbnailSizes,
      'enable_progressive_loading': enableProgressiveLoading,
    };
  }
}

// === BACKGROUND TASK ===

class BackgroundTask {
  final String id;
  final String name;
  final VoidCallback task;
  final Duration interval;
  final int priority; // Higher number = higher priority
  final bool runOnLowMemory;
  final bool runOnLowBattery;
  final DateTime? lastRun;
  final bool isRunning;

  BackgroundTask({
    required this.id,
    required this.name,
    required this.task,
    required this.interval,
    this.priority = 1,
    this.runOnLowMemory = false,
    this.runOnLowBattery = true,
    this.lastRun,
    this.isRunning = false,
  });

  bool shouldRun() {
    if (isRunning) return false;
    if (lastRun == null) return true;
    return DateTime.now().difference(lastRun!).compareTo(interval) >= 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'interval_ms': interval.inMilliseconds,
      'priority': priority,
      'run_on_low_memory': runOnLowMemory,
      'run_on_low_battery': runOnLowBattery,
      'last_run': lastRun?.toIso8601String(),
      'is_running': isRunning,
    };
  }
}

// === LAZY LOADING CONFIGURATION ===

class LazyLoadingConfig {
  final int preloadItemCount;
  final int cacheItemCount;
  final Duration debounceDelay;
  final bool enablePredictiveLoading;
  final double loadTriggerThreshold; // 0.0 to 1.0
  final int batchSize;

  const LazyLoadingConfig({
    this.preloadItemCount = 20,
    this.cacheItemCount = 100,
    this.debounceDelay = const Duration(milliseconds: 300),
    this.enablePredictiveLoading = true,
    this.loadTriggerThreshold = 0.8,
    this.batchSize = 10,
  });

  Map<String, dynamic> toJson() {
    return {
      'preload_item_count': preloadItemCount,
      'cache_item_count': cacheItemCount,
      'debounce_delay_ms': debounceDelay.inMilliseconds,
      'enable_predictive_loading': enablePredictiveLoading,
      'load_trigger_threshold': loadTriggerThreshold,
      'batch_size': batchSize,
    };
  }
}

// === MEMORY POOL ===

class MemoryPool<T> {
  final String name;
  final int maxSize;
  final Queue<T> _available = Queue<T>();
  final Set<T> _inUse = <T>{};
  final T Function() _factory;
  final void Function(T)? _resetFunction;
  int _totalCreated = 0;

  MemoryPool({
    required this.name,
    required this.maxSize,
    required T Function() factory,
    void Function(T)? resetFunction,
  }) : _factory = factory, _resetFunction = resetFunction;

  T acquire() {
    if (_available.isNotEmpty) {
      final item = _available.removeFirst();
      _inUse.add(item);
      return item;
    }

    if (_totalCreated < maxSize) {
      final item = _factory();
      _totalCreated++;
      _inUse.add(item);
      return item;
    }

    throw StateError('Memory pool $name exhausted');
  }

  void release(T item) {
    if (_inUse.remove(item)) {
      _resetFunction?.call(item);
      _available.addLast(item);
    }
  }

  void clear() {
    _available.clear();
    _inUse.clear();
    _totalCreated = 0;
  }

  Map<String, dynamic> getStats() {
    return {
      'name': name,
      'max_size': maxSize,
      'total_created': _totalCreated,
      'available': _available.length,
      'in_use': _inUse.length,
      'utilization': _inUse.length / maxSize,
    };
  }
}
