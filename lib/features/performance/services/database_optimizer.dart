import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models/performance_models.dart';

class DatabaseOptimizer {
  static DatabaseOptimizer? _instance;
  static DatabaseOptimizer get instance {
    _instance ??= DatabaseOptimizer._internal();
    return _instance!;
  }
  DatabaseOptimizer._internal();

  DatabaseOptimizationConfig _config = const DatabaseOptimizationConfig();
  final Map<String, DatabasePerformanceMetrics> _databaseMetrics = {};
  final Map<String, Timer> _vacuumTimers = {};
  final Map<String, List<String>> _createdIndexes = {};

  // Query performance tracking
  final Map<String, List<double>> _queryTimes = {};
  final Map<String, int> _queryCount = {};

  // === INITIALIZATION ===

  Future<void> initialize({DatabaseOptimizationConfig? config}) async {
    _config = config ?? const DatabaseOptimizationConfig();
    debugPrint('✅ Database Optimizer initialized');
  }

  // === DATABASE OPTIMIZATION ===

  Future<Database> optimizeDatabase(Database database, [String? databaseName]) async {
    final dbName = databaseName ?? 'default';
    
    try {
      // Apply basic optimizations
      await _applyBasicOptimizations(database);
      
      // Apply specific optimizations based on config
      if (_config.optimizations.contains(DatabaseOptimization.wal)) {
        await _enableWAL(database);
      }
      
      if (_config.optimizations.contains(DatabaseOptimization.compression)) {
        await _enableCompression(database);
      }
      
      if (_config.optimizations.contains(DatabaseOptimization.indexing)) {
        await _optimizeIndexes(database);
      }
      
      if (_config.optimizations.contains(DatabaseOptimization.vacuuming)) {
        await _scheduleRegularVacuum(database, dbName);
      }
      
      // Set up performance monitoring
      if (_config.enableStatistics) {
        await _setupPerformanceMonitoring(database, dbName);
      }
      
      debugPrint('✅ Database $dbName optimized successfully');
      
      return database;
    } catch (e) {
      debugPrint('❌ Failed to optimize database $dbName: $e');
      rethrow;
    }
  }

  Future<void> _applyBasicOptimizations(Database database) async {
    // Set cache size
    await database.execute('PRAGMA cache_size = ${_config.cacheSize}');
    
    // Set page size
    await database.execute('PRAGMA page_size = ${_config.pageSize}');
    
    // Enable memory mapping if configured
    if (_config.enableMemoryMapping) {
      await database.execute('PRAGMA mmap_size = ${256 * 1024 * 1024}'); // 256MB
    }
    
    // Set busy timeout
    await database.execute('PRAGMA busy_timeout = ${_config.busyTimeout}');
    
    // Enable foreign keys
    await database.execute('PRAGMA foreign_keys = ON');
    
    // Optimize temp store
    await database.execute('PRAGMA temp_store = MEMORY');
  }

  Future<void> _enableWAL(Database database) async {
    try {
      await database.execute('PRAGMA journal_mode = WAL');
      await database.execute('PRAGMA synchronous = NORMAL'); // Faster than FULL with WAL
      await database.execute('PRAGMA wal_autocheckpoint = 1000');
      debugPrint('✅ WAL mode enabled');
    } catch (e) {
      debugPrint('⚠️ Failed to enable WAL: $e');
    }
  }

  Future<void> _enableCompression(Database database) async {
    try {
      // Enable page compression (if supported)
      await database.execute('PRAGMA page_size = 4096');
      await database.execute('PRAGMA auto_vacuum = INCREMENTAL');
      debugPrint('✅ Compression optimizations applied');
    } catch (e) {
      debugPrint('⚠️ Failed to apply compression: $e');
    }
  }

  Future<void> _optimizeIndexes(Database database) async {
    try {
      // Get list of tables
      final tables = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      );
      
      for (final table in tables) {
        final tableName = table['name'] as String;
        await _createOptimalIndexes(database, tableName);
      }
      
      // Analyze tables for query planner
      await database.execute('ANALYZE');
      
      debugPrint('✅ Indexes optimized');
    } catch (e) {
      debugPrint('⚠️ Failed to optimize indexes: $e');
    }
  }

  Future<void> _createOptimalIndexes(Database database, String tableName) async {
    try {
      // Get table info to understand column structure
      final columns = await database.rawQuery('PRAGMA table_info($tableName)');
      
      final indexesToCreate = <String>[];
      _createdIndexes[tableName] = [];
      
      for (final column in columns) {
        final columnName = column['name'] as String;
        final columnType = column['type'] as String;
        
        // Create indexes for commonly queried columns
        if (_shouldCreateIndex(columnName, columnType)) {
          final indexName = 'idx_${tableName}_$columnName';
          indexesToCreate.add('CREATE INDEX IF NOT EXISTS $indexName ON $tableName($columnName)');
          _createdIndexes[tableName]!.add(indexName);
        }
      }
      
      // Create composite indexes for common query patterns
      final compositeIndexes = _getCompositeIndexes(tableName, columns);
      indexesToCreate.addAll(compositeIndexes);
      
      // Execute index creation
      for (final indexSql in indexesToCreate) {
        await database.execute(indexSql);
      }
      
      if (indexesToCreate.isNotEmpty) {
        debugPrint('✅ Created ${indexesToCreate.length} indexes for $tableName');
      }
    } catch (e) {
      debugPrint('⚠️ Failed to create indexes for $tableName: $e');
    }
  }

  bool _shouldCreateIndex(String columnName, String columnType) {
    // Index commonly queried columns
    final commonQueryColumns = [
      'id', 'uuid', 'user_id', 'created_at', 'updated_at', 
      'date', 'timestamp', 'status', 'type', 'category'
    ];
    
    return commonQueryColumns.any((common) => 
      columnName.toLowerCase().contains(common.toLowerCase()));
  }

  List<String> _getCompositeIndexes(String tableName, List<Map<String, dynamic>> columns) {
    final indexes = <String>[];
    
    // Common composite index patterns for health tracking
    switch (tableName.toLowerCase()) {
      case 'cycle_records':
      case 'cycles':
        indexes.add('CREATE INDEX IF NOT EXISTS idx_${tableName}_user_date ON $tableName(user_id, date)');
        indexes.add('CREATE INDEX IF NOT EXISTS idx_${tableName}_date_type ON $tableName(date, cycle_type)');
        break;
      
      case 'symptom_logs':
      case 'symptoms':
        indexes.add('CREATE INDEX IF NOT EXISTS idx_${tableName}_user_date ON $tableName(user_id, date)');
        indexes.add('CREATE INDEX IF NOT EXISTS idx_${tableName}_type_severity ON $tableName(symptom_type, severity)');
        break;
      
      case 'mood_entries':
      case 'moods':
        indexes.add('CREATE INDEX IF NOT EXISTS idx_${tableName}_user_date ON $tableName(user_id, date)');
        indexes.add('CREATE INDEX IF NOT EXISTS idx_${tableName}_mood_score ON $tableName(mood_score, date)');
        break;
      
      case 'notifications':
        indexes.add('CREATE INDEX IF NOT EXISTS idx_${tableName}_user_status ON $tableName(user_id, status)');
        indexes.add('CREATE INDEX IF NOT EXISTS idx_${tableName}_scheduled_sent ON $tableName(scheduled_time, sent)');
        break;
    }
    
    return indexes;
  }

  Future<void> _scheduleRegularVacuum(Database database, String databaseName) async {
    // Cancel existing timer if any
    _vacuumTimers[databaseName]?.cancel();
    
    // Schedule vacuum every 24 hours
    _vacuumTimers[databaseName] = Timer.periodic(
      const Duration(hours: 24),
      (_) => _performVacuum(database, databaseName),
    );
    
    // Perform initial vacuum
    await _performVacuum(database, databaseName);
  }

  Future<void> _performVacuum(Database database, String databaseName) async {
    try {
      final stopwatch = Stopwatch()..start();
      
      // Check if vacuum is needed
      final sizeInfo = await _getDatabaseSizeInfo(database);
      final freePages = sizeInfo['freelist_count'] as int;
      
      if (freePages > 100) { // Only vacuum if there are significant free pages
        await database.execute('PRAGMA incremental_vacuum');
        
        stopwatch.stop();
        debugPrint('✅ Vacuum completed for $databaseName in ${stopwatch.elapsedMilliseconds}ms');
        
        // Update metrics
        await _updateDatabaseMetrics(database, databaseName);
      }
    } catch (e) {
      debugPrint('⚠️ Vacuum failed for $databaseName: $e');
    }
  }

  Future<void> _setupPerformanceMonitoring(Database database, String databaseName) async {
    // Initial metrics collection
    await _updateDatabaseMetrics(database, databaseName);
    
    // Schedule periodic metrics updates
    Timer.periodic(
      const Duration(minutes: 5),
      (_) => _updateDatabaseMetrics(database, databaseName),
    );
  }

  Future<void> _updateDatabaseMetrics(Database database, String databaseName) async {
    try {
      final sizeInfo = await _getDatabaseSizeInfo(database);
      final indexInfo = await _getIndexInfo(database);
      
      final metrics = DatabasePerformanceMetrics(
        totalQueries: _queryCount[databaseName] ?? 0,
        averageQueryTime: _calculateAverageQueryTime(databaseName),
        maxQueryTime: _calculateMaxQueryTime(databaseName),
        cacheHits: 0, // Would need SQLite stats extension
        cacheMisses: 0,
        totalRows: await _getTotalRowCount(database),
        databaseSizeBytes: sizeInfo['file_size'] as int,
        indexCount: indexInfo.length,
        tableRowCounts: await _getTableRowCounts(database),
        tableQueryTimes: _getTableQueryTimes(databaseName),
        timestamp: DateTime.now(),
      );
      
      _databaseMetrics[databaseName] = metrics;
    } catch (e) {
      debugPrint('⚠️ Failed to update database metrics for $databaseName: $e');
    }
  }

  Future<Map<String, dynamic>> _getDatabaseSizeInfo(Database database) async {
    final result = await database.rawQuery('PRAGMA page_count');
    final pageCount = result.first['page_count'] as int;
    
    final pageSizeResult = await database.rawQuery('PRAGMA page_size');
    final pageSize = pageSizeResult.first['page_size'] as int;
    
    final freelistResult = await database.rawQuery('PRAGMA freelist_count');
    final freelistCount = freelistResult.first['freelist_count'] as int;
    
    return {
      'file_size': pageCount * pageSize,
      'page_count': pageCount,
      'page_size': pageSize,
      'freelist_count': freelistCount,
    };
  }

  Future<List<Map<String, dynamic>>> _getIndexInfo(Database database) async {
    return await database.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='index' AND name NOT LIKE 'sqlite_%'",
    );
  }

  Future<int> _getTotalRowCount(Database database) async {
    try {
      final tables = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      );
      
      int totalRows = 0;
      for (final table in tables) {
        final tableName = table['name'] as String;
        final result = await database.rawQuery('SELECT COUNT(*) as count FROM $tableName');
        totalRows += result.first['count'] as int;
      }
      
      return totalRows;
    } catch (e) {
      debugPrint('⚠️ Failed to get total row count: $e');
      return 0;
    }
  }

  Future<Map<String, int>> _getTableRowCounts(Database database) async {
    final rowCounts = <String, int>{};
    
    try {
      final tables = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      );
      
      for (final table in tables) {
        final tableName = table['name'] as String;
        final result = await database.rawQuery('SELECT COUNT(*) as count FROM $tableName');
        rowCounts[tableName] = result.first['count'] as int;
      }
    } catch (e) {
      debugPrint('⚠️ Failed to get table row counts: $e');
    }
    
    return rowCounts;
  }

  double _calculateAverageQueryTime(String databaseName) {
    final times = _queryTimes[databaseName];
    if (times == null || times.isEmpty) return 0.0;
    
    return times.reduce((a, b) => a + b) / times.length;
  }

  double _calculateMaxQueryTime(String databaseName) {
    final times = _queryTimes[databaseName];
    if (times == null || times.isEmpty) return 0.0;
    
    return times.reduce((a, b) => a > b ? a : b);
  }

  Map<String, double> _getTableQueryTimes(String databaseName) {
    return {
      'average': _calculateAverageQueryTime(databaseName),
      'max': _calculateMaxQueryTime(databaseName),
    };
  }

  // === QUERY PERFORMANCE TRACKING ===

  Future<List<Map<String, dynamic>>> executeTrackedQuery(
    Database database,
    String sql, {
    List<Object?>? arguments,
    String? databaseName,
    String? tableName,
  }) async {
    final dbName = databaseName ?? 'default';
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await database.rawQuery(sql, arguments);
      
      stopwatch.stop();
      _recordQueryPerformance(dbName, stopwatch.elapsedMilliseconds.toDouble());
      
      return result;
    } catch (e) {
      stopwatch.stop();
      debugPrint('❌ Query failed (${stopwatch.elapsedMilliseconds}ms): $sql');
      rethrow;
    }
  }

  Future<int> executeTrackedUpdate(
    Database database,
    String sql, {
    List<Object?>? arguments,
    String? databaseName,
  }) async {
    final dbName = databaseName ?? 'default';
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await database.rawUpdate(sql, arguments);
      
      stopwatch.stop();
      _recordQueryPerformance(dbName, stopwatch.elapsedMilliseconds.toDouble());
      
      return result;
    } catch (e) {
      stopwatch.stop();
      debugPrint('❌ Update failed (${stopwatch.elapsedMilliseconds}ms): $sql');
      rethrow;
    }
  }

  Future<int> executeTrackedInsert(
    Database database,
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
    String? databaseName,
  }) async {
    final dbName = databaseName ?? 'default';
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await database.insert(
        table,
        values,
        nullColumnHack: nullColumnHack,
        conflictAlgorithm: conflictAlgorithm,
      );
      
      stopwatch.stop();
      _recordQueryPerformance(dbName, stopwatch.elapsedMilliseconds.toDouble());
      
      return result;
    } catch (e) {
      stopwatch.stop();
      debugPrint('❌ Insert failed (${stopwatch.elapsedMilliseconds}ms) into $table');
      rethrow;
    }
  }

  void _recordQueryPerformance(String databaseName, double executionTime) {
    _queryTimes.putIfAbsent(databaseName, () => []);
    _queryCount.putIfAbsent(databaseName, () => 0);
    
    _queryTimes[databaseName]!.add(executionTime);
    _queryCount[databaseName] = _queryCount[databaseName]! + 1;
    
    // Keep only last 1000 query times for memory efficiency
    if (_queryTimes[databaseName]!.length > 1000) {
      _queryTimes[databaseName]!.removeAt(0);
    }
    
    // Log slow queries
    if (executionTime > 1000) { // > 1 second
      debugPrint('🐌 Slow query detected: ${executionTime}ms');
    }
  }

  // === QUERY ANALYSIS ===

  Future<List<Map<String, dynamic>>> explainQuery(
    Database database,
    String sql,
    [List<Object?>? arguments]
  ) async {
    try {
      return await database.rawQuery('EXPLAIN QUERY PLAN $sql', arguments);
    } catch (e) {
      debugPrint('⚠️ Failed to explain query: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> analyzeSlowQueries(
    String databaseName,
    {double thresholdMs = 500}
  ) async {
    final slowQueries = <Map<String, dynamic>>[];
    final times = _queryTimes[databaseName] ?? [];
    
    for (int i = 0; i < times.length; i++) {
      if (times[i] > thresholdMs) {
        slowQueries.add({
          'execution_time': times[i],
          'timestamp': DateTime.now().subtract(Duration(minutes: times.length - i)),
          'database': databaseName,
        });
      }
    }
    
    return slowQueries;
  }

  // === MAINTENANCE OPERATIONS ===

  Future<void> rebuildIndexes(Database database, [String? databaseName]) async {
    try {
      final dbName = databaseName ?? 'default';
      
      // Get all indexes
      final indexes = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND name NOT LIKE 'sqlite_%'",
      );
      
      for (final index in indexes) {
        final indexName = index['name'] as String;
        await database.execute('REINDEX $indexName');
      }
      
      debugPrint('✅ Rebuilt ${indexes.length} indexes for $dbName');
    } catch (e) {
      debugPrint('⚠️ Failed to rebuild indexes: $e');
    }
  }

  Future<void> analyzeDatabase(Database database, [String? databaseName]) async {
    try {
      await database.execute('ANALYZE');
      debugPrint('✅ Database analysis completed');
    } catch (e) {
      debugPrint('⚠️ Database analysis failed: $e');
    }
  }

  Future<void> checkIntegrity(Database database, [String? databaseName]) async {
    try {
      final result = await database.rawQuery('PRAGMA integrity_check');
      final status = result.first.values.first as String;
      
      if (status == 'ok') {
        debugPrint('✅ Database integrity check passed');
      } else {
        debugPrint('⚠️ Database integrity issues found: $status');
      }
    } catch (e) {
      debugPrint('❌ Integrity check failed: $e');
    }
  }

  // === STATISTICS AND REPORTING ===

  DatabasePerformanceMetrics? getMetrics(String databaseName) {
    return _databaseMetrics[databaseName];
  }

  Map<String, dynamic> getPerformanceReport([String? databaseName]) {
    if (databaseName != null) {
      final metrics = _databaseMetrics[databaseName];
      return {
        'database': databaseName,
        'metrics': metrics?.toJson(),
        'query_count': _queryCount[databaseName] ?? 0,
        'average_query_time': _calculateAverageQueryTime(databaseName),
        'max_query_time': _calculateMaxQueryTime(databaseName),
        'created_indexes': _createdIndexes[databaseName] ?? [],
      };
    }
    
    // Return report for all databases
    final report = <String, dynamic>{
      'config': _config.toJson(),
      'databases': <String, dynamic>{},
    };
    
    for (final dbName in _databaseMetrics.keys) {
      report['databases'][dbName] = getPerformanceReport(dbName);
    }
    
    return report;
  }

  List<String> getOptimizationSuggestions(String databaseName) {
    final suggestions = <String>[];
    final metrics = _databaseMetrics[databaseName];
    
    if (metrics == null) {
      return ['Enable performance monitoring to get suggestions'];
    }
    
    // Check query performance
    if (metrics.averageQueryTime > 100) {
      suggestions.add('Average query time is high (${metrics.averageQueryTime}ms). Consider adding indexes.');
    }
    
    // Check database size
    final sizeMB = metrics.databaseSizeBytes / (1024 * 1024);
    if (sizeMB > 100) {
      suggestions.add('Database is large (${sizeMB.toStringAsFixed(1)}MB). Consider archiving old data.');
    }
    
    // Check index usage
    if (metrics.indexCount < 5) {
      suggestions.add('Few indexes detected. Review query patterns and add appropriate indexes.');
    }
    
    if (suggestions.isEmpty) {
      suggestions.add('Database performance looks good!');
    }
    
    return suggestions;
  }

  // === CLEANUP ===

  void dispose() {
    for (final timer in _vacuumTimers.values) {
      timer.cancel();
    }
    _vacuumTimers.clear();
    _databaseMetrics.clear();
    _queryTimes.clear();
    _queryCount.clear();
    _createdIndexes.clear();
  }
}
