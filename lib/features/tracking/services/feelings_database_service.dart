import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../screens/enhanced_daily_feelings_tracker.dart';

/// Database service for feelings tracking with local SQLite storage
class FeelingsDatabaseService {
  static FeelingsDatabaseService? _instance;
  static FeelingsDatabaseService get instance {
    _instance ??= FeelingsDatabaseService._internal();
    return _instance!;
  }

  FeelingsDatabaseService._internal();

  Database? _database;
  bool _isInitialized = false;

  static const String _databaseName = 'feelings_tracker.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String _entriesTable = 'feelings_entries';
  static const String _trendsTable = 'feelings_trends';
  static const String _insightsTable = 'feelings_insights';

  /// Initialize the database
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final databasePath = await getDatabasesPath();
      final path = join(databasePath, _databaseName);

      _database = await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
      );

      _isInitialized = true;
      debugPrint('📊 Feelings database initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize feelings database: $e');
      throw DatabaseException('Failed to initialize feelings database: $e');
    }
  }

  /// Create database tables
  Future<void> _createDatabase(Database db, int version) async {
    // Feelings entries table
    await db.execute('''
      CREATE TABLE $_entriesTable (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        date TEXT NOT NULL,
        mood_scores TEXT NOT NULL,
        energy_levels TEXT NOT NULL,
        symptoms TEXT NOT NULL,
        custom_tags TEXT NOT NULL,
        notes TEXT NOT NULL,
        overall_wellbeing REAL NOT NULL,
        timestamp TEXT NOT NULL,
        sync_status INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create index for faster queries
    await db.execute('CREATE INDEX idx_entries_date ON $_entriesTable (date)');
    await db.execute('CREATE INDEX idx_entries_user_date ON $_entriesTable (user_id, date)');

    // Trends table
    await db.execute('''
      CREATE TABLE $_trendsTable (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        trend_type TEXT NOT NULL,
        description TEXT NOT NULL,
        direction TEXT NOT NULL,
        confidence REAL NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        data_points INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Insights table
    await db.execute('''
      CREATE TABLE $_insightsTable (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        insight_type TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        priority INTEGER NOT NULL,
        confidence REAL NOT NULL,
        actionable INTEGER NOT NULL,
        data_sources TEXT NOT NULL,
        generated_at TEXT NOT NULL,
        expires_at TEXT
      )
    ''');

    debugPrint('📊 Database tables created successfully');
  }

  /// Upgrade database schema
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    debugPrint('📊 Upgrading database from version $oldVersion to $newVersion');
  }

  /// Save a feelings entry
  Future<void> saveEntry(DailyFeelingsEntry entry) async {
    if (!_isInitialized || _database == null) {
      throw DatabaseException('Database not initialized');
    }

    try {
      final now = DateTime.now().toIso8601String();
      
      await _database!.insert(
        _entriesTable,
        {
          'id': entry.id,
          'user_id': 'current_user', // TODO: Get actual user ID
          'date': entry.date.toIso8601String().split('T')[0], // Date only
          'mood_scores': jsonEncode(entry.moodScores.map((k, v) => MapEntry(k.name, v))),
          'energy_levels': jsonEncode(entry.energyLevels.map((k, v) => MapEntry(k.name, v))),
          'symptoms': jsonEncode(entry.symptoms),
          'custom_tags': jsonEncode(entry.customTags),
          'notes': entry.notes,
          'overall_wellbeing': entry.overallWellbeing,
          'timestamp': entry.timestamp.toIso8601String(),
          'sync_status': 0,
          'created_at': now,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      debugPrint('💾 Saved feelings entry for ${entry.date}');
    } catch (e) {
      debugPrint('❌ Failed to save feelings entry: $e');
      throw DatabaseException('Failed to save entry: $e');
    }
  }

  /// Get entry for a specific date
  Future<DailyFeelingsEntry?> getEntryForDate(DateTime date) async {
    if (!_isInitialized || _database == null) {
      throw DatabaseException('Database not initialized');
    }

    try {
      final dateString = date.toIso8601String().split('T')[0];
      
      final results = await _database!.query(
        _entriesTable,
        where: 'user_id = ? AND date = ?',
        whereArgs: ['current_user', dateString],
        limit: 1,
      );

      if (results.isEmpty) return null;

      return _mapToFeelingsEntry(results.first);
    } catch (e) {
      debugPrint('❌ Failed to get entry for date $date: $e');
      return null;
    }
  }

  /// Get entries for a date range
  Future<List<DailyFeelingsEntry>> getEntriesInRange({
    required DateTime startDate,
    required DateTime endDate,
    String? userId,
  }) async {
    if (!_isInitialized || _database == null) {
      throw DatabaseException('Database not initialized');
    }

    try {
      final startDateString = startDate.toIso8601String().split('T')[0];
      final endDateString = endDate.toIso8601String().split('T')[0];
      final user = userId ?? 'current_user';

      final results = await _database!.query(
        _entriesTable,
        where: 'user_id = ? AND date >= ? AND date <= ?',
        whereArgs: [user, startDateString, endDateString],
        orderBy: 'date ASC',
      );

      return results.map(_mapToFeelingsEntry).toList();
    } catch (e) {
      debugPrint('❌ Failed to get entries in range: $e');
      return [];
    }
  }

  /// Get recent entries
  Future<List<DailyFeelingsEntry>> getRecentEntries({
    int limit = 30,
    String? userId,
  }) async {
    if (!_isInitialized || _database == null) {
      throw DatabaseException('Database not initialized');
    }

    try {
      final user = userId ?? 'current_user';

      final results = await _database!.query(
        _entriesTable,
        where: 'user_id = ?',
        whereArgs: [user],
        orderBy: 'date DESC',
        limit: limit,
      );

      return results.map(_mapToFeelingsEntry).toList();
    } catch (e) {
      debugPrint('❌ Failed to get recent entries: $e');
      return [];
    }
  }

  /// Delete an entry
  Future<bool> deleteEntry(String entryId) async {
    if (!_isInitialized || _database == null) {
      throw DatabaseException('Database not initialized');
    }

    try {
      final result = await _database!.delete(
        _entriesTable,
        where: 'id = ?',
        whereArgs: [entryId],
      );

      return result > 0;
    } catch (e) {
      debugPrint('❌ Failed to delete entry: $e');
      return false;
    }
  }

  /// Get entry count for user
  Future<int> getEntryCount({String? userId}) async {
    if (!_isInitialized || _database == null) {
      throw DatabaseException('Database not initialized');
    }

    try {
      final user = userId ?? 'current_user';
      
      final result = await _database!.rawQuery(
        'SELECT COUNT(*) as count FROM $_entriesTable WHERE user_id = ?',
        [user],
      );

      return result.first['count'] as int;
    } catch (e) {
      debugPrint('❌ Failed to get entry count: $e');
      return 0;
    }
  }

  /// Save trend analysis
  Future<void> saveTrend(TrendAnalysis trend) async {
    if (!_isInitialized || _database == null) {
      throw DatabaseException('Database not initialized');
    }

    try {
      await _database!.insert(
        _trendsTable,
        {
          'id': trend.id,
          'user_id': 'current_user',
          'trend_type': trend.type,
          'description': trend.description,
          'direction': trend.direction.name,
          'confidence': trend.confidence,
          'start_date': trend.startDate.toIso8601String(),
          'end_date': trend.endDate.toIso8601String(),
          'data_points': trend.dataPoints,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('❌ Failed to save trend: $e');
      throw DatabaseException('Failed to save trend: $e');
    }
  }

  /// Get recent trends
  Future<List<TrendAnalysis>> getRecentTrends({
    int limit = 10,
    String? userId,
  }) async {
    if (!_isInitialized || _database == null) {
      throw DatabaseException('Database not initialized');
    }

    try {
      final user = userId ?? 'current_user';

      final results = await _database!.query(
        _trendsTable,
        where: 'user_id = ?',
        whereArgs: [user],
        orderBy: 'created_at DESC',
        limit: limit,
      );

      return results.map(_mapToTrendAnalysis).toList();
    } catch (e) {
      debugPrint('❌ Failed to get recent trends: $e');
      return [];
    }
  }

  /// Save insight
  Future<void> saveInsight(FeelingsInsight insight) async {
    if (!_isInitialized || _database == null) {
      throw DatabaseException('Database not initialized');
    }

    try {
      await _database!.insert(
        _insightsTable,
        {
          'id': insight.id,
          'user_id': 'current_user',
          'insight_type': insight.type,
          'title': insight.title,
          'description': insight.description,
          'category': insight.category,
          'priority': insight.priority.index,
          'confidence': insight.confidence,
          'actionable': insight.actionable ? 1 : 0,
          'data_sources': jsonEncode(insight.dataSources),
          'generated_at': insight.generatedAt.toIso8601String(),
          'expires_at': insight.expiresAt?.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('❌ Failed to save insight: $e');
      throw DatabaseException('Failed to save insight: $e');
    }
  }

  /// Get active insights
  Future<List<FeelingsInsight>> getActiveInsights({
    int limit = 20,
    String? userId,
  }) async {
    if (!_isInitialized || _database == null) {
      throw DatabaseException('Database not initialized');
    }

    try {
      final user = userId ?? 'current_user';
      final now = DateTime.now().toIso8601String();

      final results = await _database!.query(
        _insightsTable,
        where: 'user_id = ? AND (expires_at IS NULL OR expires_at > ?)',
        whereArgs: [user, now],
        orderBy: 'priority DESC, generated_at DESC',
        limit: limit,
      );

      return results.map(_mapToFeelingsInsight).toList();
    } catch (e) {
      debugPrint('❌ Failed to get active insights: $e');
      return [];
    }
  }

  /// Clean up expired insights
  Future<void> cleanupExpiredInsights() async {
    if (!_isInitialized || _database == null) {
      throw DatabaseException('Database not initialized');
    }

    try {
      final now = DateTime.now().toIso8601String();
      
      await _database!.delete(
        _insightsTable,
        where: 'expires_at IS NOT NULL AND expires_at < ?',
        whereArgs: [now],
      );
    } catch (e) {
      debugPrint('❌ Failed to cleanup expired insights: $e');
    }
  }

  /// Get database statistics
  Future<Map<String, dynamic>> getDatabaseStats() async {
    if (!_isInitialized || _database == null) {
      throw DatabaseException('Database not initialized');
    }

    try {
      final entriesCount = await _database!.rawQuery(
        'SELECT COUNT(*) as count FROM $_entriesTable WHERE user_id = ?',
        ['current_user'],
      );

      final trendsCount = await _database!.rawQuery(
        'SELECT COUNT(*) as count FROM $_trendsTable WHERE user_id = ?',
        ['current_user'],
      );

      final insightsCount = await _database!.rawQuery(
        'SELECT COUNT(*) as count FROM $_insightsTable WHERE user_id = ?',
        ['current_user'],
      );

      final firstEntry = await _database!.rawQuery(
        'SELECT MIN(date) as first_date FROM $_entriesTable WHERE user_id = ?',
        ['current_user'],
      );

      final lastEntry = await _database!.rawQuery(
        'SELECT MAX(date) as last_date FROM $_entriesTable WHERE user_id = ?',
        ['current_user'],
      );

      return {
        'total_entries': entriesCount.first['count'],
        'total_trends': trendsCount.first['count'],
        'total_insights': insightsCount.first['count'],
        'first_entry_date': firstEntry.first['first_date'],
        'last_entry_date': lastEntry.first['last_date'],
        'tracking_duration_days': _calculateTrackingDuration(
          firstEntry.first['first_date'] as String?,
          lastEntry.first['last_date'] as String?,
        ),
      };
    } catch (e) {
      debugPrint('❌ Failed to get database stats: $e');
      return {};
    }
  }

  /// Calculate tracking duration in days
  int? _calculateTrackingDuration(String? firstDate, String? lastDate) {
    if (firstDate == null || lastDate == null) return null;
    
    try {
      final first = DateTime.parse(firstDate);
      final last = DateTime.parse(lastDate);
      return last.difference(first).inDays + 1;
    } catch (e) {
      return null;
    }
  }

  /// Map database row to DailyFeelingsEntry
  DailyFeelingsEntry _mapToFeelingsEntry(Map<String, dynamic> row) {
    final moodScoresJson = jsonDecode(row['mood_scores']) as Map<String, dynamic>;
    final energyLevelsJson = jsonDecode(row['energy_levels']) as Map<String, dynamic>;
    final symptomsJson = jsonDecode(row['symptoms']) as Map<String, dynamic>;
    final customTagsJson = jsonDecode(row['custom_tags']) as Map<String, dynamic>;

    return DailyFeelingsEntry(
      id: row['id'],
      date: DateTime.parse(row['date']),
      moodScores: moodScoresJson.map((k, v) => MapEntry(
        MoodCategory.values.firstWhere((e) => e.name == k),
        (v as num).toDouble(),
      )),
      energyLevels: energyLevelsJson.map((k, v) => MapEntry(
        EnergyType.values.firstWhere((e) => e.name == k),
        (v as num).toDouble(),
      )),
      symptoms: Map<String, int>.from(symptomsJson),
      customTags: Map<String, String>.from(customTagsJson),
      notes: row['notes'],
      overallWellbeing: (row['overall_wellbeing'] as num).toDouble(),
      timestamp: DateTime.parse(row['timestamp']),
    );
  }

  /// Map database row to TrendAnalysis
  TrendAnalysis _mapToTrendAnalysis(Map<String, dynamic> row) {
    return TrendAnalysis(
      id: row['id'],
      type: row['trend_type'],
      description: row['description'],
      direction: TrendDirection.values.firstWhere(
        (d) => d.name == row['direction'],
        orElse: () => TrendDirection.stable,
      ),
      confidence: (row['confidence'] as num).toDouble(),
      startDate: DateTime.parse(row['start_date']),
      endDate: DateTime.parse(row['end_date']),
      dataPoints: row['data_points'],
    );
  }

  /// Map database row to FeelingsInsight
  FeelingsInsight _mapToFeelingsInsight(Map<String, dynamic> row) {
    final dataSourcesJson = jsonDecode(row['data_sources']) as List<dynamic>;
    
    return FeelingsInsight(
      id: row['id'],
      type: row['insight_type'],
      title: row['title'],
      description: row['description'],
      category: row['category'],
      priority: InsightPriority.values[row['priority']],
      confidence: (row['confidence'] as num).toDouble(),
      actionable: row['actionable'] == 1,
      dataSources: List<String>.from(dataSourcesJson),
      generatedAt: DateTime.parse(row['generated_at']),
      expiresAt: row['expires_at'] != null 
          ? DateTime.parse(row['expires_at'])
          : null,
    );
  }

  /// Close database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _isInitialized = false;
    }
  }

  /// Export data as JSON
  Future<Map<String, dynamic>> exportData({String? userId}) async {
    if (!_isInitialized || _database == null) {
      throw DatabaseException('Database not initialized');
    }

    try {
      final user = userId ?? 'current_user';
      
      final entries = await _database!.query(
        _entriesTable,
        where: 'user_id = ?',
        whereArgs: [user],
        orderBy: 'date ASC',
      );

      final trends = await _database!.query(
        _trendsTable,
        where: 'user_id = ?',
        whereArgs: [user],
        orderBy: 'created_at ASC',
      );

      final insights = await _database!.query(
        _insightsTable,
        where: 'user_id = ?',
        whereArgs: [user],
        orderBy: 'generated_at ASC',
      );

      return {
        'export_date': DateTime.now().toIso8601String(),
        'user_id': user,
        'entries': entries,
        'trends': trends,
        'insights': insights,
        'version': _databaseVersion,
      };
    } catch (e) {
      debugPrint('❌ Failed to export data: $e');
      throw DatabaseException('Failed to export data: $e');
    }
  }
}

// === SUPPORTING DATA MODELS ===

class TrendAnalysis {
  final String id;
  final String type;
  final String description;
  final TrendDirection direction;
  final double confidence;
  final DateTime startDate;
  final DateTime endDate;
  final int dataPoints;

  TrendAnalysis({
    required this.id,
    required this.type,
    required this.description,
    required this.direction,
    required this.confidence,
    required this.startDate,
    required this.endDate,
    required this.dataPoints,
  });
}

class FeelingsInsight {
  final String id;
  final String type;
  final String title;
  final String description;
  final String category;
  final InsightPriority priority;
  final double confidence;
  final bool actionable;
  final List<String> dataSources;
  final DateTime generatedAt;
  final DateTime? expiresAt;

  FeelingsInsight({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.confidence,
    required this.actionable,
    required this.dataSources,
    required this.generatedAt,
    this.expiresAt,
  });
}

enum InsightPriority {
  low,
  medium,
  high,
}

class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}
