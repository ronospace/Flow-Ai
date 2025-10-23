import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/performance_models.dart';

class PerformanceOptimizationService {
  static PerformanceOptimizationService? _instance;
  static PerformanceOptimizationService get instance {
    _instance ??= PerformanceOptimizationService._internal();
    return _instance!;
  }
  PerformanceOptimizationService._internal();

  // Configuration
  PerformanceOptimizationConfig _config = const PerformanceOptimizationConfig();
  
  // Cache Management
  final Map<String, AdvancedCache> _caches = {};
  
  // Memory Management
  MemoryMonitor? _memoryMonitor;
  final Map<String, MemoryPool> _memoryPools = {};
  
  // Performance Monitoring
  PerformanceMetrics? _lastMetrics;
  final List<PerformanceMetrics> _metricsHistory = [];
  Timer? _metricsTimer;
  
  // Background Tasks
  final Map<String, BackgroundTask> _backgroundTasks = {};
  Timer? _backgroundTaskTimer;
  
  // Optimization States
  bool _isOptimizationRunning = false;
  DateTime? _lastOptimizationRun;
  
  // Event Streams
  final StreamController<PerformanceMetrics> _metricsController = StreamController.broadcast();
  final StreamController<MemoryUsageInfo> _memoryController = StreamController.broadcast();

  Stream<PerformanceMetrics> get metricsStream => _metricsController.stream;
  Stream<MemoryUsageInfo> get memoryStream => _memoryController.stream;

  // === INITIALIZATION ===

  Future<void> initialize({PerformanceOptimizationConfig? config}) async {
    try {
      _config = config ?? const PerformanceOptimizationConfig();
      
      await _initializeCaches();
      await _initializeMemoryMonitoring();
      await _initializeBackgroundTasks();
      _startPerformanceMonitoring();
      
      debugPrint('✅ Performance Optimization Service initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize Performance Optimization Service: $e');
      rethrow;
    }
  }

  Future<void> _initializeCaches() async {
    // Initialize default caches
    await createCache(
      'default',
      _config.cacheConfig,
    );
    
    await createCache(
      'images',
      _config.cacheConfig.copyWith(
        maxMemoryUsageBytes: 20 * 1024 * 1024, // 20MB for images
        compressionType: CompressionType.lz4,
      ),
    );
    
    await createCache(
      'api_responses',
      _config.cacheConfig.copyWith(
        maxMemoryUsageBytes: 10 * 1024 * 1024, // 10MB for API responses
        defaultTtl: const Duration(minutes: 30),
      ),
    );
  }

  Future<void> _initializeMemoryMonitoring() async {
    _memoryMonitor = MemoryMonitor(_config.cacheConfig.memoryThreshold);
    _memoryMonitor!.onMemoryPressure.listen(_handleMemoryPressure);
  }

  Future<void> _initializeBackgroundTasks() async {
    // Cache cleanup task
    registerBackgroundTask(BackgroundTask(
      id: 'cache_cleanup',
      name: 'Cache Cleanup',
      task: _performCacheCleanup,
      interval: const Duration(minutes: 15),
      priority: 2,
    ));
    
    // Memory compaction task
    if (_config.enableMemoryCompaction) {
      registerBackgroundTask(BackgroundTask(
        id: 'memory_compaction',
        name: 'Memory Compaction',
        task: _performMemoryCompaction,
        interval: const Duration(hours: 1),
        priority: 1,
      ));
    }
    
    // Performance metrics collection
    registerBackgroundTask(BackgroundTask(
      id: 'metrics_collection',
      name: 'Metrics Collection',
      task: _collectPerformanceMetrics,
      interval: const Duration(seconds: 30),
      priority: 3,
    ));

    if (_config.enableBackgroundProcessing) {
      _startBackgroundTaskScheduler();
    }
  }

  // === CACHE MANAGEMENT ===

  Future<AdvancedCache> createCache(
    String name, [
    CacheConfiguration? config,
  ]) async {
    final cacheConfig = config ?? _config.cacheConfig;
    final cache = AdvancedCache(name, cacheConfig);
    await cache.initialize();
    _caches[name] = cache;
    return cache;
  }

  AdvancedCache? getCache(String name) => _caches[name];

  Future<void> clearCache(String name) async {
    final cache = _caches[name];
    if (cache != null) {
      await cache.clear();
    }
  }

  Future<void> clearAllCaches() async {
    await Future.wait(_caches.values.map((cache) => cache.clear()));
  }

  // === MEMORY MANAGEMENT ===

  MemoryPool<T> createMemoryPool<T>({
    required String name,
    required int maxSize,
    required T Function() factory,
    void Function(T)? resetFunction,
  }) {
    final pool = MemoryPool<T>(
      name: name,
      maxSize: maxSize,
      factory: factory,
      resetFunction: resetFunction,
    );
    _memoryPools[name] = pool;
    return pool;
  }

  MemoryPool<T>? getMemoryPool<T>(String name) {
    return _memoryPools[name] as MemoryPool<T>?;
  }

  Future<void> _handleMemoryPressure(MemoryUsageInfo memoryInfo) async {
    debugPrint('🔥 Memory pressure detected: ${memoryInfo.pressureLevel.name}');
    
    switch (memoryInfo.pressureLevel) {
      case MemoryPressureLevel.moderate:
        await _performLightCleanup();
        break;
      case MemoryPressureLevel.high:
        await _performMediumCleanup();
        break;
      case MemoryPressureLevel.critical:
        await _performAggressiveCleanup();
        break;
      case MemoryPressureLevel.normal:
        break;
    }
  }

  Future<void> _performLightCleanup() async {
    // Clear expired cache entries
    for (final cache in _caches.values) {
      cache.removeExpired();
    }
    
    // Trigger GC hint
    if (_config.enableGarbageCollectionHints) {
      _triggerGarbageCollection();
    }
  }

  Future<void> _performMediumCleanup() async {
    await _performLightCleanup();
    
    // Clear LRU cache entries (keep 70%)
    for (final cache in _caches.values) {
      await cache.trim(0.7);
    }
    
    // Clear memory pools partially
    for (final pool in _memoryPools.values) {
      // Clear half of available items
      final stats = pool.getStats();
      final availableCount = stats['available'] as int;
      for (int i = 0; i < availableCount ~/ 2; i++) {
        try {
          final item = pool.acquire();
          // Don't release back to reduce pool size
        } catch (e) {
          break;
        }
      }
    }
  }

  Future<void> _performAggressiveCleanup() async {
    await _performMediumCleanup();
    
    // Clear most cache entries (keep 30%)
    for (final cache in _caches.values) {
      await cache.trim(0.3);
    }
    
    // Clear all memory pools
    for (final pool in _memoryPools.values) {
      pool.clear();
    }
    
    // Force garbage collection
    _triggerGarbageCollection();
    
    debugPrint('🧹 Aggressive cleanup completed');
  }

  void _triggerGarbageCollection() {
    if (kDebugMode) {
      // In debug mode, we can't force GC, but we can hint
      SystemChannels.system.invokeMethod('SystemNavigator.routeUpdated');
    }
  }

  // === PERFORMANCE MONITORING ===

  void _startPerformanceMonitoring() {
    _metricsTimer?.cancel();
    _metricsTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _collectPerformanceMetrics(),
    );
  }

  void _collectPerformanceMetrics() {
    final metrics = _generatePerformanceMetrics();
    _lastMetrics = metrics;
    
    _metricsHistory.add(metrics);
    if (_metricsHistory.length > 1000) {
      _metricsHistory.removeAt(0);
    }
    
    _metricsController.add(metrics);
    
    // Auto-optimize if needed
    if (_shouldAutoOptimize(metrics)) {
      _performAutoOptimization();
    }
  }

  PerformanceMetrics _generatePerformanceMetrics() {
    int totalCacheHits = 0;
    int totalCacheMisses = 0;
    int totalMemoryUsage = 0;
    
    for (final cache in _caches.values) {
      final stats = cache.getStats();
      totalCacheHits += stats.hits;
      totalCacheMisses += stats.misses;
      totalMemoryUsage += stats.memoryUsageBytes;
    }
    
    return PerformanceMetrics(
      cpuUsagePercentage: _getCpuUsage(),
      memoryUsageBytes: totalMemoryUsage,
      networkBytesReceived: 0, // Would need platform-specific implementation
      networkBytesSent: 0,
      databaseQueryCount: 0, // Would be tracked by database service
      averageQueryTime: 0.0,
      cacheHits: totalCacheHits,
      cacheMisses: totalCacheMisses,
      frameRenderTime: 16.6, // Placeholder - would need frame rendering metrics
      gcCount: 0, // Platform-specific
      upTime: DateTime.now().difference(DateTime.now()), // App start time tracking needed
      customMetrics: {
        'active_caches': _caches.length.toDouble(),
        'memory_pools': _memoryPools.length.toDouble(),
        'background_tasks': _backgroundTasks.length.toDouble(),
      },
      timestamp: DateTime.now(),
    );
  }

  double _getCpuUsage() {
    // Placeholder implementation - would need platform-specific code
    // or method channel to get actual CPU usage
    return Random().nextDouble() * 20; // Simulated 0-20% usage
  }

  bool _shouldAutoOptimize(PerformanceMetrics metrics) {
    return metrics.cacheHitRatio < 0.5 ||
           metrics.memoryUsageBytes > _config.cacheConfig.maxMemoryUsageBytes * 0.9;
  }

  void _performAutoOptimization() {
    if (_isOptimizationRunning) return;
    
    _isOptimizationRunning = true;
    Timer(const Duration(seconds: 1), () {
      _performOptimizationCycle();
      _isOptimizationRunning = false;
      _lastOptimizationRun = DateTime.now();
    });
  }

  void _performOptimizationCycle() {
    // Optimize caches
    for (final cache in _caches.values) {
      cache.optimize();
    }
    
    // Clean up expired data
    _performCacheCleanup();
  }

  // === BACKGROUND TASK MANAGEMENT ===

  void registerBackgroundTask(BackgroundTask task) {
    _backgroundTasks[task.id] = task;
  }

  void unregisterBackgroundTask(String taskId) {
    _backgroundTasks.remove(taskId);
  }

  void _startBackgroundTaskScheduler() {
    _backgroundTaskTimer?.cancel();
    _backgroundTaskTimer = Timer.periodic(
      _config.backgroundTaskInterval,
      (_) => _runBackgroundTasks(),
    );
  }

  void _runBackgroundTasks() {
    final sortedTasks = _backgroundTasks.values.toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));
    
    for (final task in sortedTasks) {
      if (task.shouldRun()) {
        _executeBackgroundTask(task);
      }
    }
  }

  void _executeBackgroundTask(BackgroundTask task) {
    try {
      task.task();
    } catch (e) {
      debugPrint('❌ Background task ${task.name} failed: $e');
    }
  }

  void _performCacheCleanup() {
    for (final cache in _caches.values) {
      cache.removeExpired();
    }
  }

  void _performMemoryCompaction() {
    _performLightCleanup();
    _triggerGarbageCollection();
  }

  // === PUBLIC API ===

  Future<void> optimizePerformance({OptimizationLevel? level}) async {
    final targetLevel = level ?? _config.level;
    
    switch (targetLevel) {
      case OptimizationLevel.minimal:
        await _performLightCleanup();
        break;
      case OptimizationLevel.balanced:
        await _performMediumCleanup();
        break;
      case OptimizationLevel.aggressive:
      case OptimizationLevel.maximum:
        await _performAggressiveCleanup();
        break;
    }
  }

  Map<String, dynamic> getPerformanceReport() {
    final cacheStats = <String, dynamic>{};
    for (final entry in _caches.entries) {
      cacheStats[entry.key] = entry.value.getStats().toJson();
    }
    
    final poolStats = <String, dynamic>{};
    for (final entry in _memoryPools.entries) {
      poolStats[entry.key] = entry.value.getStats();
    }
    
    return {
      'config': _config.toJson(),
      'last_metrics': _lastMetrics?.toJson(),
      'cache_stats': cacheStats,
      'memory_pool_stats': poolStats,
      'background_tasks': _backgroundTasks.values.map((t) => t.toJson()).toList(),
      'last_optimization': _lastOptimizationRun?.toIso8601String(),
      'is_optimization_running': _isOptimizationRunning,
      'metrics_history_count': _metricsHistory.length,
    };
  }

  Future<void> dispose() async {
    _metricsTimer?.cancel();
    _backgroundTaskTimer?.cancel();
    
    await _metricsController.close();
    await _memoryController.close();
    
    await clearAllCaches();
    
    for (final pool in _memoryPools.values) {
      pool.clear();
    }
    
    _memoryMonitor?.dispose();
  }
}

// === ADVANCED CACHE IMPLEMENTATION ===

class AdvancedCache<T> {
  final String name;
  final CacheConfiguration config;
  
  final Map<String, CacheEntry<T>> _cache = {};
  final LinkedHashMap<String, int> _accessOrder = LinkedHashMap();
  
  int _hits = 0;
  int _misses = 0;
  int _memoryUsage = 0;
  
  Database? _persistentStore;
  
  AdvancedCache(this.name, this.config);

  Future<void> initialize() async {
    if (config.enablePersistence) {
      await _initializePersistentStore();
    }
  }

  Future<void> _initializePersistentStore() async {
    try {
      final directory = await getApplicationSupportDirectory();
      final path = '${directory.path}/cache_$name.db';
      
      _persistentStore = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE cache_entries (
              key TEXT PRIMARY KEY,
              data BLOB,
              metadata TEXT,
              created_at INTEGER,
              expires_at INTEGER,
              access_count INTEGER,
              last_accessed_at INTEGER,
              size_bytes INTEGER
            )
          ''');
          
          await db.execute('CREATE INDEX idx_expires_at ON cache_entries(expires_at)');
          await db.execute('CREATE INDEX idx_last_accessed ON cache_entries(last_accessed_at)');
        },
      );
    } catch (e) {
      debugPrint('⚠️ Failed to initialize persistent cache for $name: $e');
    }
  }

  Future<T?> get(String key) async {
    final entry = _cache[key];
    
    if (entry == null) {
      _misses++;
      
      // Try loading from persistent store
      if (config.enablePersistence && _persistentStore != null) {
        final persistedEntry = await _loadFromPersistentStore(key);
        if (persistedEntry != null) {
          _cache[key] = persistedEntry;
          _updateAccessOrder(key);
          _hits++;
          return persistedEntry.data;
        }
      }
      
      return null;
    }
    
    if (entry.isExpired) {
      await remove(key);
      _misses++;
      return null;
    }
    
    // Update access tracking
    final updatedEntry = entry.copyWithAccess();
    _cache[key] = updatedEntry;
    _updateAccessOrder(key);
    _hits++;
    
    return entry.data;
  }

  Future<void> put(String key, T data, {Duration? ttl}) async {
    final expiresAt = ttl != null 
        ? DateTime.now().add(ttl)
        : DateTime.now().add(config.defaultTtl);
    
    final sizeBytes = _calculateSize(data);
    final entry = CacheEntry<T>(
      key: key,
      data: data,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
      lastAccessedAt: DateTime.now(),
      sizeBytes: sizeBytes,
    );
    
    // Check memory constraints
    await _ensureMemoryConstraints(sizeBytes);
    
    _cache[key] = entry;
    _updateAccessOrder(key);
    _memoryUsage += sizeBytes;
    
    // Persist if enabled
    if (config.enablePersistence && _persistentStore != null) {
      await _saveToPersistentStore(entry);
    }
  }

  Future<void> remove(String key) async {
    final entry = _cache.remove(key);
    if (entry != null) {
      _memoryUsage -= entry.sizeBytes;
      _accessOrder.remove(key);
    }
    
    if (config.enablePersistence && _persistentStore != null) {
      await _persistentStore!.delete('cache_entries', where: 'key = ?', whereArgs: [key]);
    }
  }

  Future<void> clear() async {
    _cache.clear();
    _accessOrder.clear();
    _memoryUsage = 0;
    _hits = 0;
    _misses = 0;
    
    if (config.enablePersistence && _persistentStore != null) {
      await _persistentStore!.delete('cache_entries');
    }
  }

  void optimize() {
    // Remove expired entries
    removeExpired();
    
    // Apply optimization strategy
    switch (config.strategy) {
      case CacheStrategy.lru:
        _optimizeLRU();
        break;
      case CacheStrategy.lfu:
        _optimizeLFU();
        break;
      case CacheStrategy.adaptive:
        _optimizeAdaptive();
        break;
      default:
        break;
    }
  }

  void removeExpired() {
    final now = DateTime.now();
    final keysToRemove = <String>[];
    
    for (final entry in _cache.entries) {
      if (entry.value.isExpired) {
        keysToRemove.add(entry.key);
      }
    }
    
    for (final key in keysToRemove) {
      remove(key);
    }
  }

  Future<void> trim(double keepRatio) async {
    final targetCount = (_cache.length * keepRatio).floor();
    final currentCount = _cache.length;
    
    if (targetCount >= currentCount) return;
    
    final sortedEntries = _cache.entries.toList()
      ..sort((a, b) => a.value.lastAccessedAt.compareTo(b.value.lastAccessedAt));
    
    final toRemove = currentCount - targetCount;
    for (int i = 0; i < toRemove && i < sortedEntries.length; i++) {
      await remove(sortedEntries[i].key);
    }
  }

  CacheStats getStats() {
    return CacheStats(
      name: name,
      size: _cache.length,
      hits: _hits,
      misses: _misses,
      memoryUsageBytes: _memoryUsage,
      maxMemoryBytes: config.maxMemoryUsageBytes,
      hitRatio: _hits + _misses > 0 ? _hits / (_hits + _misses) : 0.0,
    );
  }

  // === PRIVATE METHODS ===

  void _updateAccessOrder(String key) {
    _accessOrder.remove(key);
    _accessOrder[key] = DateTime.now().millisecondsSinceEpoch;
  }

  Future<void> _ensureMemoryConstraints(int newEntrySize) async {
    while (_memoryUsage + newEntrySize > config.maxMemoryUsageBytes && _cache.isNotEmpty) {
      await _evictOldestEntry();
    }
    
    while (_cache.length >= config.maxItemCount) {
      await _evictOldestEntry();
    }
  }

  Future<void> _evictOldestEntry() async {
    if (_accessOrder.isEmpty) return;
    
    final oldestKey = _accessOrder.keys.first;
    await remove(oldestKey);
  }

  int _calculateSize(T data) {
    // Simplified size calculation - in production, this would be more sophisticated
    if (data is String) {
      return data.length * 2; // UTF-16 encoding
    } else if (data is List<int>) {
      return (data as List<int>).length;
    } else if (data is Map) {
      return json.encode(data).length * 2;
    }
    return 100; // Default estimate
  }

  void _optimizeLRU() {
    // LRU optimization is already handled by access order tracking
  }

  void _optimizeLFU() {
    if (_cache.length <= config.maxItemCount * 0.8) return;
    
    final sortedEntries = _cache.entries.toList()
      ..sort((a, b) => a.value.accessCount.compareTo(b.value.accessCount));
    
    final toRemoveCount = (_cache.length * 0.1).floor();
    for (int i = 0; i < toRemoveCount && i < sortedEntries.length; i++) {
      remove(sortedEntries[i].key);
    }
  }

  void _optimizeAdaptive() {
    final now = DateTime.now();
    final oneHourAgo = now.subtract(const Duration(hours: 1));
    
    // Remove entries not accessed in the last hour and with low access count
    final keysToRemove = <String>[];
    
    for (final entry in _cache.entries) {
      if (entry.value.lastAccessedAt.isBefore(oneHourAgo) && 
          entry.value.accessCount < 3) {
        keysToRemove.add(entry.key);
      }
    }
    
    for (final key in keysToRemove) {
      remove(key);
    }
  }

  Future<CacheEntry<T>?> _loadFromPersistentStore(String key) async {
    try {
      final result = await _persistentStore!.query(
        'cache_entries',
        where: 'key = ?',
        whereArgs: [key],
        limit: 1,
      );
      
      if (result.isNotEmpty) {
        final row = result.first;
        final data = _deserializeData(row['data'] as Uint8List);
        
        return CacheEntry<T>(
          key: key,
          data: data,
          createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
          expiresAt: row['expires_at'] != null 
              ? DateTime.fromMillisecondsSinceEpoch(row['expires_at'] as int)
              : null,
          accessCount: row['access_count'] as int,
          lastAccessedAt: DateTime.fromMillisecondsSinceEpoch(row['last_accessed_at'] as int),
          sizeBytes: row['size_bytes'] as int,
          metadata: json.decode(row['metadata'] as String),
        );
      }
    } catch (e) {
      debugPrint('⚠️ Failed to load from persistent store: $e');
    }
    
    return null;
  }

  Future<void> _saveToPersistentStore(CacheEntry<T> entry) async {
    try {
      await _persistentStore!.insert(
        'cache_entries',
        {
          'key': entry.key,
          'data': _serializeData(entry.data),
          'metadata': json.encode(entry.metadata),
          'created_at': entry.createdAt.millisecondsSinceEpoch,
          'expires_at': entry.expiresAt?.millisecondsSinceEpoch,
          'access_count': entry.accessCount,
          'last_accessed_at': entry.lastAccessedAt.millisecondsSinceEpoch,
          'size_bytes': entry.sizeBytes,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('⚠️ Failed to save to persistent store: $e');
    }
  }

  Uint8List _serializeData(T data) {
    // Simplified serialization - in production would use more robust serialization
    final jsonString = json.encode(data);
    return Uint8List.fromList(utf8.encode(jsonString));
  }

  T _deserializeData(Uint8List bytes) {
    // Simplified deserialization
    final jsonString = utf8.decode(bytes);
    return json.decode(jsonString) as T;
  }
}

// === MEMORY MONITOR ===

class MemoryMonitor {
  final double warningThreshold;
  final StreamController<MemoryUsageInfo> _controller = StreamController.broadcast();
  Timer? _monitoringTimer;
  
  Stream<MemoryUsageInfo> get onMemoryPressure => _controller.stream;
  
  MemoryMonitor(this.warningThreshold) {
    _startMonitoring();
  }
  
  void _startMonitoring() {
    _monitoringTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _checkMemoryUsage(),
    );
  }
  
  void _checkMemoryUsage() {
    // Placeholder implementation - would need platform-specific code
    final memoryInfo = MemoryUsageInfo(
      totalMemoryBytes: 1024 * 1024 * 1024, // 1GB placeholder
      usedMemoryBytes: 512 * 1024 * 1024, // 512MB placeholder
      availableMemoryBytes: 512 * 1024 * 1024,
      usagePercentage: 0.5,
      pressureLevel: MemoryUsageInfo.calculatePressureLevel(0.5),
      categoryUsage: {
        'cache': 100 * 1024 * 1024,
        'images': 200 * 1024 * 1024,
        'other': 212 * 1024 * 1024,
      },
      timestamp: DateTime.now(),
    );
    
    if (memoryInfo.usagePercentage > warningThreshold) {
      _controller.add(memoryInfo);
    }
  }
  
  void dispose() {
    _monitoringTimer?.cancel();
    _controller.close();
  }
}

// === CACHE STATS ===

class CacheStats {
  final String name;
  final int size;
  final int hits;
  final int misses;
  final int memoryUsageBytes;
  final int maxMemoryBytes;
  final double hitRatio;

  CacheStats({
    required this.name,
    required this.size,
    required this.hits,
    required this.misses,
    required this.memoryUsageBytes,
    required this.maxMemoryBytes,
    required this.hitRatio,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'size': size,
      'hits': hits,
      'misses': misses,
      'memory_usage_bytes': memoryUsageBytes,
      'max_memory_bytes': maxMemoryBytes,
      'hit_ratio': hitRatio,
      'memory_utilization': memoryUsageBytes / maxMemoryBytes,
    };
  }
}

// === EXTENSIONS ===

extension CacheConfigurationExtensions on CacheConfiguration {
  CacheConfiguration copyWith({
    int? maxMemoryUsageBytes,
    int? maxItemCount,
    Duration? defaultTtl,
    CacheStrategy? strategy,
    bool? enableCompression,
    CompressionType? compressionType,
    bool? enablePersistence,
    bool? enableMetrics,
    double? memoryThreshold,
  }) {
    return CacheConfiguration(
      maxMemoryUsageBytes: maxMemoryUsageBytes ?? this.maxMemoryUsageBytes,
      maxItemCount: maxItemCount ?? this.maxItemCount,
      defaultTtl: defaultTtl ?? this.defaultTtl,
      strategy: strategy ?? this.strategy,
      enableCompression: enableCompression ?? this.enableCompression,
      compressionType: compressionType ?? this.compressionType,
      enablePersistence: enablePersistence ?? this.enablePersistence,
      enableMetrics: enableMetrics ?? this.enableMetrics,
      memoryThreshold: memoryThreshold ?? this.memoryThreshold,
    );
  }
}
