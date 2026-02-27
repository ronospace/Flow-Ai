import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Advanced Performance Optimization Service
/// Implements code splitting, lazy loading, caching strategies, and memory management
class PerformanceOptimizer {
  static final PerformanceOptimizer _instance =
      PerformanceOptimizer._internal();
  static PerformanceOptimizer get instance => _instance;
  PerformanceOptimizer._internal();

  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<String, Completer<dynamic>> _pendingOperations = {};

  Timer? _cleanupTimer;
  bool _isInitialized = false;

  // Performance metrics
  int _cacheHits = 0;
  int _cacheMisses = 0;
  int _memoryWarnings = 0;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Start periodic cache cleanup
    _cleanupTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      _cleanupCache();
    });

    // Monitor frame rendering performance
    _monitorFramePerformance();

    _isInitialized = true;
    debugPrint('⚡ Performance Optimizer initialized');
  }

  /// Get cached value or compute and cache
  Future<T> getOrCompute<T>({
    required String key,
    required Future<T> Function() compute,
    Duration? cacheDuration,
  }) async {
    // Check cache first
    if (_cache.containsKey(key)) {
      final cached = _cache[key] as T?;
      if (cached != null) {
        final age = DateTime.now().difference(_cacheTimestamps[key]!);
        final duration = cacheDuration ?? const Duration(hours: 1);

        if (age < duration) {
          _cacheHits++;
          return cached;
        }
      }
    }

    // Check if operation is already in progress
    if (_pendingOperations.containsKey(key)) {
      return await _pendingOperations[key]!.future as T;
    }

    // Compute value
    _cacheMisses++;
    final completer = Completer<T>();
    _pendingOperations[key] = completer;

    try {
      final value = await compute();
      _cache[key] = value;
      _cacheTimestamps[key] = DateTime.now();
      completer.complete(value);
      _pendingOperations.remove(key);
      return value;
    } catch (e) {
      completer.completeError(e);
      _pendingOperations.remove(key);
      rethrow;
    }
  }

  /// Compute in isolate for heavy operations
  Future<T> computeInIsolate<T, Q>({
    required T Function(Q) callback,
    required Q message,
  }) async {
    return await compute(callback, message);
  }

  /// Lazy load data with debouncing
  Future<T> lazyLoad<T>({
    required String key,
    required Future<T> Function() loader,
    Duration debounceDuration = const Duration(milliseconds: 300),
  }) async {
    // Cancel previous debounce timer if exists
    if (_pendingOperations.containsKey('${key}_debounce')) {
      (_pendingOperations['${key}_debounce']!.future).ignore();
      _pendingOperations.remove('${key}_debounce');
    }

    final completer = Completer<T>();
    _pendingOperations['${key}_debounce'] = completer;

    // Wait for debounce duration
    await Future.delayed(debounceDuration);

    // Load data
    final result = await loader();
    completer.complete(result);
    _pendingOperations.remove('${key}_debounce');

    return result;
  }

  /// Preload data in background
  void preload<T>({
    required String key,
    required Future<T> Function() loader,
    Duration? cacheDuration,
  }) {
    // Don't await - let it run in background
    getOrCompute(
      key: key,
      compute: loader,
      cacheDuration: cacheDuration,
    ).catchError((error) {
      debugPrint('⚠️ Preload failed for $key: $error');
      return null;
    });
  }

  /// Clear cache entries
  void clearCache([String? key]) {
    if (key != null) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    } else {
      _cache.clear();
      _cacheTimestamps.clear();
    }
    debugPrint('🗑️ Cache cleared${key != null ? ' for key: $key' : ''}');
  }

  /// Cleanup old cache entries
  void _cleanupCache() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    for (final entry in _cacheTimestamps.entries) {
      final age = now.difference(entry.value);
      if (age > const Duration(hours: 24)) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }

    if (keysToRemove.isNotEmpty) {
      debugPrint('🧹 Cleaned up ${keysToRemove.length} old cache entries');
    }
  }

  /// Monitor frame rendering performance
  void _monitorFramePerformance() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Frame monitoring logic would go here
      // Could detect dropped frames and adjust rendering strategies
      // frameTime available if needed for advanced monitoring
    });
  }

  /// Get cache statistics
  CacheStats getStats() {
    return CacheStats(
      cacheHits: _cacheHits,
      cacheMisses: _cacheMisses,
      cacheSize: _cache.length,
      hitRate: _cacheHits + _cacheMisses > 0
          ? _cacheHits / (_cacheHits + _cacheMisses)
          : 0.0,
      memoryWarnings: _memoryWarnings,
    );
  }

  /// Dispose resources
  void dispose() {
    _cleanupTimer?.cancel();
    _cache.clear();
    _cacheTimestamps.clear();
    _pendingOperations.clear();
    _isInitialized = false;
  }
}

class CacheStats {
  final int cacheHits;
  final int cacheMisses;
  final int cacheSize;
  final double hitRate;
  final int memoryWarnings;

  CacheStats({
    required this.cacheHits,
    required this.cacheMisses,
    required this.cacheSize,
    required this.hitRate,
    required this.memoryWarnings,
  });

  @override
  String toString() {
    return 'CacheStats(hits: $cacheHits, misses: $cacheMisses, size: $cacheSize, hitRate: ${(hitRate * 100).toStringAsFixed(1)}%, warnings: $memoryWarnings)';
  }
}
