import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/cycle_data.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, 'flowsense.db');
      
      return await openDatabase(
        path,
        version: 1,
        onCreate: _createTables,
        onUpgrade: _upgradeDatabase,
      );
    } catch (e) {
      throw Exception('Failed to initialize database: $e');
    }
  }

  Future<void> _createTables(Database db, int version) async {
    await _createCycleTable(db);
    await _createDailyTrackingTable(db);
    await _createSymptomsTable(db);
    await _createUserSettingsTable(db);
    await _createPredictionsTable(db);
    await _createFeelingsTable(db);
  }

  Future<void> _createCycleTable(Database db) async {
    await db.execute('''
      CREATE TABLE cycles (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL DEFAULT 'unknown',
        start_date TEXT NOT NULL,
        end_date TEXT,
        length INTEGER,
        period_length INTEGER,
        average_flow TEXT NOT NULL DEFAULT 'medium',
        flow_intensity TEXT,
        symptoms TEXT, -- JSON array of symptoms
        moods TEXT, -- JSON array of moods
        current_phase TEXT NOT NULL DEFAULT 'menstrual',
        ovulation_date TEXT,
        expected_next_period TEXT,
        fertility_score REAL,
        is_complete BOOLEAN DEFAULT 0,
        quality TEXT NOT NULL DEFAULT 'regular',
        mood REAL,
        energy REAL,
        pain REAL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_cycles_start_date ON cycles(start_date)');
    await db.execute('CREATE INDEX idx_cycles_created_at ON cycles(created_at)');
  }

  Future<void> _createDailyTrackingTable(Database db) async {
    await db.execute('''
      CREATE TABLE daily_tracking (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        flow_intensity TEXT,
        symptoms TEXT, -- JSON array of symptoms
        symptom_severity TEXT, -- JSON map of symptom -> severity
        mood REAL,
        energy REAL,
        pain REAL,
        pain_areas TEXT, -- JSON map of area -> intensity
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(date)
      )
    ''');

    await db.execute('CREATE INDEX idx_daily_tracking_date ON daily_tracking(date)');
  }

  Future<void> _createSymptomsTable(Database db) async {
    await db.execute('''
      CREATE TABLE symptoms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        category TEXT NOT NULL,
        icon TEXT,
        color TEXT,
        is_active BOOLEAN DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    // Insert default symptoms
    await _insertDefaultSymptoms(db);
  }

  Future<void> _createUserSettingsTable(Database db) async {
    await db.execute('''
      CREATE TABLE user_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createPredictionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE predictions (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL, -- 'cycle', 'symptoms', 'mood_energy'
        predicted_date TEXT,
        predicted_length INTEGER,
        confidence REAL NOT NULL,
        data TEXT, -- JSON with prediction details
        created_at TEXT NOT NULL,
        expires_at TEXT
      )
    ''');

    await db.execute('CREATE INDEX idx_predictions_type ON predictions(type)');
    await db.execute('CREATE INDEX idx_predictions_expires_at ON predictions(expires_at)');
  }

  Future<void> _createFeelingsTable(Database db) async {
    await db.execute('''
      CREATE TABLE feelings (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        feeling_score INTEGER NOT NULL CHECK(feeling_score >= 1 AND feeling_score <= 10),
        time_of_day TEXT NOT NULL CHECK(time_of_day IN ('morning', 'evening')),
        timestamp TEXT NOT NULL,
        notes TEXT,
        encrypted_notes TEXT,
        context_data TEXT, -- JSON object
        app_type TEXT NOT NULL CHECK(app_type IN ('consumer', 'clinical')),
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_feelings_user_id ON feelings(user_id)');
    await db.execute('CREATE INDEX idx_feelings_timestamp ON feelings(timestamp)');
    await db.execute('CREATE INDEX idx_feelings_app_type ON feelings(app_type)');
    await db.execute('CREATE INDEX idx_feelings_user_timestamp ON feelings(user_id, timestamp)');
  }

  Future<void> _insertDefaultSymptoms(Database db) async {
    final defaultSymptoms = [
      // Physical symptoms
      {'name': 'Cramps', 'category': 'Physical', 'icon': '🤕', 'color': '#FF6B6B'},
      {'name': 'Bloating', 'category': 'Physical', 'icon': '🎈', 'color': '#4ECDC4'},
      {'name': 'Headache', 'category': 'Physical', 'icon': '🤕', 'color': '#FFD93D'},
      {'name': 'Back Pain', 'category': 'Physical', 'icon': '🦴', 'color': '#6BCF7F'},
      {'name': 'Breast Tenderness', 'category': 'Physical', 'icon': '💐', 'color': '#FF8A80'},
      {'name': 'Fatigue', 'category': 'Physical', 'icon': '😴', 'color': '#B39DDB'},
      {'name': 'Nausea', 'category': 'Physical', 'icon': '🤢', 'color': '#81C784'},
      {'name': 'Hot Flashes', 'category': 'Physical', 'icon': '🔥', 'color': '#FF7043'},
      
      // Emotional symptoms  
      {'name': 'Mood Swings', 'category': 'Emotional', 'icon': '🎭', 'color': '#E1BEE7'},
      {'name': 'Irritability', 'category': 'Emotional', 'icon': '😤', 'color': '#FFCDD2'},
      {'name': 'Anxiety', 'category': 'Emotional', 'icon': '😰', 'color': '#F8BBD9'},
      {'name': 'Depression', 'category': 'Emotional', 'icon': '😢', 'color': '#C5E1A5'},
      {'name': 'Stress', 'category': 'Emotional', 'icon': '😵', 'color': '#FFAB91'},
      
      // Skin & Hair symptoms
      {'name': 'Acne', 'category': 'Skin & Hair', 'icon': '🔴', 'color': '#EF9A9A'},
      {'name': 'Oily Skin', 'category': 'Skin & Hair', 'icon': '✨', 'color': '#FFF59D'},
      {'name': 'Dry Skin', 'category': 'Skin & Hair', 'icon': '🏜️', 'color': '#BCAAA4'},
      
      // Digestive symptoms
      {'name': 'Food Cravings', 'category': 'Digestive', 'icon': '🍫', 'color': '#A1887F'},
      {'name': 'Loss of Appetite', 'category': 'Digestive', 'icon': '🚫', 'color': '#90A4AE'},
      {'name': 'Constipation', 'category': 'Digestive', 'icon': '🚽', 'color': '#8D6E63'},
      {'name': 'Diarrhea', 'category': 'Digestive', 'icon': '💧', 'color': '#4DD0E1'},
    ];

    for (final symptom in defaultSymptoms) {
      await db.insert('symptoms', {
        'name': symptom['name'],
        'category': symptom['category'],
        'icon': symptom['icon'],
        'color': symptom['color'],
        'is_active': 1,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here when schema changes
    // For now, we'll just recreate tables (in production, use proper migrations)
    if (oldVersion < newVersion) {
      // Add migration logic here
    }
  }

  // ===== CYCLE DATA METHODS =====

  Future<String> insertCycle(CycleData cycle) async {
    final db = await database;
    
    // Map CycleData to database columns
    final data = <String, dynamic>{
      'id': cycle.id,
      'user_id': cycle.userId,
      'start_date': cycle.startDate.toIso8601String(),
      'end_date': cycle.endDate?.toIso8601String(),
      'length': cycle.cycleLength,
      'period_length': cycle.periodLength,
      'average_flow': cycle.averageFlow.name,
      'flow_intensity': cycle.flowIntensity?.name,
      'symptoms': cycle.symptoms.join(','),
      'moods': cycle.moods.join(','),
      'current_phase': cycle.currentPhase.name,
      'ovulation_date': cycle.ovulationDate?.toIso8601String(),
      'expected_next_period': cycle.expectedNextPeriod?.toIso8601String(),
      'fertility_score': cycle.fertilityScore,
      'is_complete': cycle.isComplete ? 1 : 0,
      'quality': cycle.quality.name,
      'mood': cycle.mood,
      'energy': cycle.energy,
      'pain': cycle.pain,
      'notes': cycle.notes != null ? (cycle.notes!['text'] ?? '') : null,
      'created_at': cycle.createdAt.toIso8601String(),
      'updated_at': cycle.lastUpdated?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
    
    await db.insert('cycles', data, conflictAlgorithm: ConflictAlgorithm.replace);
    return cycle.id;
  }

  Future<List<CycleData>> getAllCycles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cycles',
      orderBy: 'start_date DESC',
    );

    return maps.map((map) => _cycleFromMap(map)).toList();
  }

  Future<CycleData?> getCycleById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cycles',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return _cycleFromMap(maps.first);
    }
    return null;
  }

  Future<List<CycleData>> getCyclesByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cycles',
      where: 'start_date >= ? AND start_date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'start_date DESC',
    );

    return maps.map((map) => _cycleFromMap(map)).toList();
  }

  // Alias for getCyclesByDateRange to match cycle calculation engine expectations
  Future<List<CycleData>> getCyclesInRange(DateTime start, DateTime end) async {
    return getCyclesByDateRange(start, end);
  }

  Future<CycleData?> getCurrentCycle() async {
    final db = await database;
    final now = DateTime.now();
    
    // Get cycles that might be current (started recently and not ended)
    final List<Map<String, dynamic>> maps = await db.query(
      'cycles',
      where: 'end_date IS NULL OR end_date >= ?',
      whereArgs: [now.subtract(const Duration(days: 7)).toIso8601String()],
      orderBy: 'start_date DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return _cycleFromMap(maps.first);
    }
    return null;
  }

  Future<void> updateCycle(CycleData cycle) async {
    final db = await database;
    final updatedCycle = cycle.copyWith(lastUpdated: DateTime.now());
    
    // Map CycleData to database columns
    final data = <String, dynamic>{
      'id': updatedCycle.id,
      'user_id': updatedCycle.userId,
      'start_date': updatedCycle.startDate.toIso8601String(),
      'end_date': updatedCycle.endDate?.toIso8601String(),
      'length': updatedCycle.cycleLength,
      'period_length': updatedCycle.periodLength,
      'average_flow': updatedCycle.averageFlow.name,
      'flow_intensity': updatedCycle.flowIntensity?.name,
      'symptoms': updatedCycle.symptoms.join(','),
      'moods': updatedCycle.moods.join(','),
      'current_phase': updatedCycle.currentPhase.name,
      'ovulation_date': updatedCycle.ovulationDate?.toIso8601String(),
      'expected_next_period': updatedCycle.expectedNextPeriod?.toIso8601String(),
      'fertility_score': updatedCycle.fertilityScore,
      'is_complete': updatedCycle.isComplete ? 1 : 0,
      'quality': updatedCycle.quality.name,
      'mood': updatedCycle.mood,
      'energy': updatedCycle.energy,
      'pain': updatedCycle.pain,
      'notes': updatedCycle.notes != null ? (updatedCycle.notes!['text'] ?? '') : null,
      'created_at': updatedCycle.createdAt.toIso8601String(),
      'updated_at': updatedCycle.lastUpdated?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
    
    await db.update(
      'cycles',
      data,
      where: 'id = ?',
      whereArgs: [cycle.id],
    );
  }

  Future<void> deleteCycle(String id) async {
    final db = await database;
    await db.delete('cycles', where: 'id = ?', whereArgs: [id]);
  }

  // ===== DAILY TRACKING METHODS =====

  Future<void> saveDailyTracking({
    required DateTime date,
    FlowIntensity? flowIntensity,
    List<String>? symptoms,
    Map<String, double>? symptomSeverity,
    double? mood,
    double? energy,  
    double? pain,
    Map<String, double>? painAreas,
    String? notes,
  }) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0]; // YYYY-MM-DD format
    
    final data = <String, dynamic>{
      'id': '${dateStr}_tracking',
      'date': dateStr,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (flowIntensity != null) data['flow_intensity'] = flowIntensity.name;
    if (symptoms != null) data['symptoms'] = symptoms.join(',');
    if (symptomSeverity != null) data['symptom_severity'] = _mapToJson(symptomSeverity);
    if (mood != null) data['mood'] = mood;
    if (energy != null) data['energy'] = energy;
    if (pain != null) data['pain'] = pain;
    if (painAreas != null) data['pain_areas'] = _mapToJson(painAreas);
    if (notes != null) data['notes'] = notes;

    await db.insert('daily_tracking', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getDailyTracking(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    
    final List<Map<String, dynamic>> maps = await db.query(
      'daily_tracking',
      where: 'date = ?',
      whereArgs: [dateStr],
    );

    if (maps.isNotEmpty) {
      final data = Map<String, dynamic>.from(maps.first);
      
      // Parse JSON fields
      if (data['symptoms'] != null) {
        data['symptoms'] = (data['symptoms'] as String).split(',').where((s) => s.isNotEmpty).toList();
      }
      if (data['symptom_severity'] != null) {
        data['symptom_severity'] = _jsonToMap(data['symptom_severity']);
      }
      if (data['pain_areas'] != null) {
        data['pain_areas'] = _jsonToMap(data['pain_areas']);
      }
      if (data['flow_intensity'] != null) {
        data['flow_intensity'] = FlowIntensity.values.firstWhere(
          (e) => e.name == data['flow_intensity'],
          orElse: () => FlowIntensity.none,
        );
      }
      
      return data;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getDailyTrackingRange(DateTime start, DateTime end) async {
    final db = await database;
    final startStr = start.toIso8601String().split('T')[0];
    final endStr = end.toIso8601String().split('T')[0];
    
    final List<Map<String, dynamic>> maps = await db.query(
      'daily_tracking',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startStr, endStr],
      orderBy: 'date ASC',
    );

    return maps.map((data) {
      final parsedData = Map<String, dynamic>.from(data);
      
      // Parse JSON fields
      if (parsedData['symptoms'] != null) {
        parsedData['symptoms'] = (parsedData['symptoms'] as String).split(',').where((s) => s.isNotEmpty).toList();
      }
      if (parsedData['symptom_severity'] != null) {
        parsedData['symptom_severity'] = _jsonToMap(parsedData['symptom_severity']);
      }
      if (parsedData['pain_areas'] != null) {
        parsedData['pain_areas'] = _jsonToMap(parsedData['pain_areas']);
      }
      if (parsedData['flow_intensity'] != null) {
        parsedData['flow_intensity'] = FlowIntensity.values.firstWhere(
          (e) => e.name == parsedData['flow_intensity'],
          orElse: () => FlowIntensity.none,
        );
      }
      
      return parsedData;
    }).toList();
  }

  // ===== SYMPTOMS METHODS =====

  Future<List<Map<String, dynamic>>> getAllSymptoms() async {
    final db = await database;
    return await db.query('symptoms', where: 'is_active = 1', orderBy: 'category, name');
  }

  Future<List<Map<String, dynamic>>> getSymptomsByCategory(String category) async {
    final db = await database;
    return await db.query(
      'symptoms', 
      where: 'category = ? AND is_active = 1', 
      whereArgs: [category],
      orderBy: 'name'
    );
  }

  // ===== USER SETTINGS METHODS =====

  Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'user_settings',
      {
        'key': key,
        'value': value,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (maps.isNotEmpty) {
      return maps.first['value'] as String;
    }
    return null;
  }

  Future<Map<String, String>> getAllSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('user_settings');
    
    final settings = <String, String>{};
    for (final map in maps) {
      settings[map['key'] as String] = map['value'] as String;
    }
    return settings;
  }

  // ===== PREDICTIONS METHODS =====

  Future<void> savePrediction({
    required String id,
    required String type,
    DateTime? predictedDate,
    int? predictedLength,
    required double confidence,
    required Map<String, dynamic> data,
    DateTime? expiresAt,
  }) async {
    final db = await database;
    await db.insert(
      'predictions',
      {
        'id': id,
        'type': type,
        'predicted_date': predictedDate?.toIso8601String(),
        'predicted_length': predictedLength,
        'confidence': confidence,
        'data': _mapToJson(data),
        'created_at': DateTime.now().toIso8601String(),
        'expires_at': expiresAt?.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getPrediction(String type) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    final List<Map<String, dynamic>> maps = await db.query(
      'predictions',
      where: 'type = ? AND (expires_at IS NULL OR expires_at > ?)',
      whereArgs: [type, now],
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final data = Map<String, dynamic>.from(maps.first);
      if (data['data'] != null) {
        data['data'] = _jsonToMap(data['data']);
      }
      return data;
    }
    return null;
  }

  Future<void> clearExpiredPredictions() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    await db.delete(
      'predictions',
      where: 'expires_at IS NOT NULL AND expires_at <= ?',
      whereArgs: [now],
    );
  }

  // ===== UTILITY METHODS =====

  CycleData _cycleFromMap(Map<String, dynamic> map) {
    return CycleData(
      id: map['id'],
      userId: map['user_id'] ?? 'unknown',
      startDate: _parseDateTime(map['start_date']),
      endDate: map['end_date'] != null ? _parseDateTime(map['end_date']) : null,
      cycleLength: map['length'],
      periodLength: map['period_length'],
      averageFlow: FlowIntensity.values.firstWhere(
        (e) => e.name == map['flow_intensity'],
        orElse: () => FlowIntensity.medium,
      ),
      dailyData: {},
      symptoms: map['symptoms'] != null 
          ? (map['symptoms'] as String).split(',').where((s) => s.isNotEmpty).toList()
          : [],
      moods: [], // Empty for now, can be populated from daily tracking data
      currentPhase: CyclePhase.values.firstWhere(
        (e) => e.name == map['current_phase'],
        orElse: () => CyclePhase.menstrual,
      ),
      ovulationDate: map['ovulation_date'] != null ? _parseDateTime(map['ovulation_date']) : null,
      expectedNextPeriod: map['expected_next_period'] != null ? _parseDateTime(map['expected_next_period']) : null,
      notes: map['notes'] != null ? {"text": map['notes']} : null,
      fertilityScore: map['fertility_score']?.toDouble(),
      events: [], // Empty for now, can be populated from events table if needed
      createdAt: _parseDateTime(map['created_at']),
      lastUpdated: map['updated_at'] != null ? _parseDateTime(map['updated_at']) : null,
      isComplete: map['is_complete'] == 1 || map['is_complete'] == true,
      quality: CycleQuality.values.firstWhere(
        (e) => e.name == map['quality'],
        orElse: () => CycleQuality.regular,
      ),
      mood: map['mood']?.toDouble(),
      energy: map['energy']?.toDouble(),
      pain: map['pain']?.toDouble(),
      flowIntensity: FlowIntensity.values.firstWhere(
        (e) => e.name == map['flow_intensity'],
        orElse: () => FlowIntensity.medium,
      ),
    );
  }

  String _mapToJson(Map<String, dynamic> map) {
    // Simple JSON encoding for maps
    final entries = map.entries.map((e) => '"${e.key}":${e.value}').join(',');
    return '{$entries}';
  }

  Map<String, double> _jsonToMap(String json) {
    // Simple JSON decoding for maps (in production, use dart:convert)
    final map = <String, double>{};
    if (json.startsWith('{') && json.endsWith('}')) {
      final content = json.substring(1, json.length - 1);
      for (final entry in content.split(',')) {
        final parts = entry.split(':');
        if (parts.length == 2) {
          final key = parts[0].replaceAll('"', '').trim();
          final value = double.tryParse(parts[1].trim()) ?? 0.0;
          map[key] = value;
        }
      }
    }
    return map;
  }

  /// Helper method to parse DateTime from various formats (String, Timestamp, DateTime)
  DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) {
      return DateTime.now();
    }
    
    if (dateValue is DateTime) {
      return dateValue;
    }
    
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        debugPrint('Error parsing date string: $dateValue, error: $e');
        return DateTime.now();
      }
    }
    
    // Handle Firestore Timestamp
    if (dateValue.runtimeType.toString() == 'Timestamp') {
      try {
        // Access toDate() method via reflection-like approach
        final timestamp = dateValue as dynamic;
        return timestamp.toDate() as DateTime;
      } catch (e) {
        debugPrint('Error parsing Timestamp: $dateValue, error: $e');
        return DateTime.now();
      }
    }
    
    // Handle milliseconds since epoch
    if (dateValue is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(dateValue);
      } catch (e) {
        debugPrint('Error parsing timestamp: $dateValue, error: $e');
        return DateTime.now();
      }
    }
    
    // Fallback
    debugPrint('Unknown date format: ${dateValue.runtimeType}, value: $dateValue');
    return DateTime.now();
  }
  
  // ===== DATABASE MANAGEMENT =====

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  Future<void> deleteDatabase() async {
    await close();
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'flowsense.db');
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  // ===== ANALYTICS & STATISTICS =====

  Future<Map<String, dynamic>> getCycleStatistics() async {
    final db = await database;
    
    // Get average cycle length
    final avgLengthResult = await db.rawQuery('''
      SELECT AVG(length) as avg_length, 
             MIN(length) as min_length, 
             MAX(length) as max_length,
             COUNT(*) as total_cycles
      FROM cycles 
      WHERE end_date IS NOT NULL
    ''');

    // Get most common symptoms
    final symptomsResult = await db.rawQuery('''
      SELECT symptoms, COUNT(*) as frequency
      FROM cycles 
      WHERE symptoms IS NOT NULL AND symptoms != ''
      GROUP BY symptoms
      ORDER BY frequency DESC
      LIMIT 10
    ''');

    // Get mood/energy trends
    final moodResult = await db.rawQuery('''
      SELECT AVG(mood) as avg_mood, AVG(energy) as avg_energy, AVG(pain) as avg_pain
      FROM cycles 
      WHERE mood IS NOT NULL OR energy IS NOT NULL OR pain IS NOT NULL
    ''');

    return {
      'cycle_stats': avgLengthResult.first,
      'common_symptoms': symptomsResult,
      'mood_stats': moodResult.first,
    };
  }

  Future<List<Map<String, dynamic>>> getRecentTrackingData({int days = 30}) async {
    final db = await database;
    final startDate = DateTime.now().subtract(Duration(days: days));
    
    return await db.query(
      'daily_tracking',
      where: 'date >= ?',
      whereArgs: [startDate.toIso8601String().split('T')[0]],
      orderBy: 'date DESC',
    );
  }

  // ===== FEELINGS TRACKING METHODS =====

  /// Store a feelings entry to the database
  Future<void> storeFeelingsEntry(dynamic feelingsEntry) async {
    final db = await database;
    
    // Convert the feelings entry to a map for database storage
    final data = <String, dynamic>{
      'id': feelingsEntry.id,
      'user_id': feelingsEntry.userId,
      'feeling_score': feelingsEntry.feelingScore,
      'time_of_day': feelingsEntry.timeOfDay.name,
      'timestamp': feelingsEntry.timestamp.toIso8601String(),
      'notes': feelingsEntry.notes,
      'encrypted_notes': feelingsEntry.encryptedNotes,
      'context_data': feelingsEntry.contextData.isNotEmpty ? _mapToJsonString(feelingsEntry.contextData) : null,
      'app_type': feelingsEntry.appType.name,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    await db.insert('feelings', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Get feelings history from database
  Future<List<dynamic>> getFeelingsHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'feelings',
      orderBy: 'timestamp DESC',
    );

    // Convert database records back to FeelingsEntry objects
    return maps.map((map) => _feelingsEntryFromMap(map)).toList();
  }

  /// Get feelings entries for a specific user
  Future<List<Map<String, dynamic>>> getFeelingsForUser({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    String? appType,
  }) async {
    final db = await database;
    
    String whereClause = 'user_id = ?';
    List<dynamic> whereArgs = [userId];
    
    if (startDate != null) {
      whereClause += ' AND timestamp >= ?';
      whereArgs.add(startDate.toIso8601String());
    }
    
    if (endDate != null) {
      whereClause += ' AND timestamp <= ?';
      whereArgs.add(endDate.toIso8601String());
    }
    
    if (appType != null) {
      whereClause += ' AND app_type = ?';
      whereArgs.add(appType);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'feelings',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => _processFeelingsMap(map)).toList();
  }

  /// Get feelings entries within a date range
  Future<List<Map<String, dynamic>>> getFeelingsInDateRange({
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
    String? appType,
  }) async {
    final db = await database;
    
    String whereClause = '1=1'; // Always true condition
    List<dynamic> whereArgs = [];
    
    if (userId != null) {
      whereClause += ' AND user_id = ?';
      whereArgs.add(userId);
    }
    
    if (startDate != null) {
      whereClause += ' AND timestamp >= ?';
      whereArgs.add(startDate.toIso8601String());
    }
    
    if (endDate != null) {
      whereClause += ' AND timestamp <= ?';
      whereArgs.add(endDate.toIso8601String());
    }
    
    if (appType != null) {
      whereClause += ' AND app_type = ?';
      whereArgs.add(appType);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'feelings',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'timestamp ASC',
    );

    return maps.map((map) => _processFeelingsMap(map)).toList();
  }

  /// Delete old feelings entries (keep only recent data)
  Future<void> cleanupOldFeelings({int daysToKeep = 365}) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    
    await db.delete(
      'feelings',
      where: 'timestamp < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
  }

  /// Get feelings statistics for a user
  Future<Map<String, dynamic>> getFeelingsStatistics(String userId, {String? appType}) async {
    final db = await database;
    
    String whereClause = 'user_id = ?';
    List<dynamic> whereArgs = [userId];
    
    if (appType != null) {
      whereClause += ' AND app_type = ?';
      whereArgs.add(appType);
    }

    // Get basic statistics
    final statsResult = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_entries,
        AVG(feeling_score) as avg_score,
        MIN(feeling_score) as min_score,
        MAX(feeling_score) as max_score,
        MIN(timestamp) as first_entry,
        MAX(timestamp) as last_entry
      FROM feelings 
      WHERE $whereClause
    ''', whereArgs);

    // Get entries by time of day
    final timeOfDayResult = await db.rawQuery('''
      SELECT 
        time_of_day,
        COUNT(*) as count,
        AVG(feeling_score) as avg_score
      FROM feelings 
      WHERE $whereClause
      GROUP BY time_of_day
    ''', whereArgs);

    // Get recent trend (last 30 days)
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final trendResult = await db.rawQuery('''
      SELECT 
        AVG(feeling_score) as recent_avg
      FROM feelings 
      WHERE $whereClause AND timestamp >= ?
    ''', [...whereArgs, thirtyDaysAgo.toIso8601String()]);

    return {
      'overall': statsResult.isNotEmpty ? statsResult.first : {},
      'by_time_of_day': timeOfDayResult,
      'recent_trend': trendResult.isNotEmpty ? trendResult.first : {},
    };
  }

  // Helper methods for feelings data
  
  /// Convert a database map to a feelings entry
  dynamic _feelingsEntryFromMap(Map<String, dynamic> map) {
    // This is a placeholder - in the actual implementation, this would create
    // a proper FeelingsEntry object. For now, return the processed map.
    return _processFeelingsMap(map);
  }

  /// Process feelings map from database
  Map<String, dynamic> _processFeelingsMap(Map<String, dynamic> map) {
    final processedMap = Map<String, dynamic>.from(map);
    
    // Parse timestamp
    if (processedMap['timestamp'] != null) {
      processedMap['timestamp'] = DateTime.parse(processedMap['timestamp']);
    }
    
    // Parse context_data JSON
    if (processedMap['context_data'] != null && processedMap['context_data'] is String) {
      try {
        processedMap['context_data'] = _jsonStringToMap(processedMap['context_data']);
      } catch (e) {
        processedMap['context_data'] = <String, dynamic>{};
      }
    } else {
      processedMap['context_data'] = <String, dynamic>{};
    }
    
    return processedMap;
  }

  /// Convert map to JSON string
  String _mapToJsonString(Map<String, dynamic> map) {
    if (map.isEmpty) return '{}';
    
    final entries = map.entries.map((e) {
      final value = e.value is String ? '"${e.value}"' : e.value.toString();
      return '"${e.key}":$value';
    }).join(',');
    
    return '{$entries}';
  }

  /// Convert JSON string to map
  Map<String, dynamic> _jsonStringToMap(String json) {
    final map = <String, dynamic>{};
    if (json.startsWith('{') && json.endsWith('}')) {
      final content = json.substring(1, json.length - 1);
      if (content.isNotEmpty) {
        for (final entry in content.split(',')) {
          final colonIndex = entry.indexOf(':');
          if (colonIndex != -1) {
            final key = entry.substring(0, colonIndex).replaceAll('"', '').trim();
            final valueStr = entry.substring(colonIndex + 1).trim();
            
            // Try to parse different value types
            dynamic value;
            if (valueStr.startsWith('"') && valueStr.endsWith('"')) {
              value = valueStr.substring(1, valueStr.length - 1);
            } else if (valueStr == 'true') {
              value = true;
            } else if (valueStr == 'false') {
              value = false;
            } else {
              value = double.tryParse(valueStr) ?? valueStr;
            }
            
            map[key] = value;
          }
        }
      }
    }
    return map;
  }

  // Add a static instance getter for singleton access
  static DatabaseService get instance => _instance;
}
