import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/services/app_enhancement_service.dart';
import '../models/cycle_data.dart';
import '../models/period_prediction.dart';
import '../models/symptom_tracking.dart';

/// Enhanced cycle tracking service with AI predictions and comprehensive analysis
class EnhancedCycleService {
  static final EnhancedCycleService _instance = EnhancedCycleService._internal();
  factory EnhancedCycleService() => _instance;
  EnhancedCycleService._internal();

  static const String _cycleDataKey = 'cycle_data';
  static const String _predictionsKey = 'cycle_predictions';
  static const String _symptomsKey = 'symptom_tracking';
  static const String _settingsKey = 'cycle_settings';

  SharedPreferences? _prefs;
  bool _isInitialized = false;
  
  List<CycleData> _cycles = [];
  List<PeriodPrediction> _predictions = [];
  Map<String, SymptomTracking> _symptoms = {};
  CycleSettings _settings = CycleSettings.defaults();

  final StreamController<List<CycleData>> _cycleStreamController = 
      StreamController<List<CycleData>>.broadcast();
  
  final StreamController<List<PeriodPrediction>> _predictionStreamController = 
      StreamController<List<PeriodPrediction>>.broadcast();

  // Getters for external access
  List<CycleData> get cycles => List.unmodifiable(_cycles);
  List<PeriodPrediction> get predictions => List.unmodifiable(_predictions);
  Map<String, SymptomTracking> get symptoms => Map.unmodifiable(_symptoms);
  CycleSettings get settings => _settings;
  
  Stream<List<CycleData>> get cycleStream => _cycleStreamController.stream;
  Stream<List<PeriodPrediction>> get predictionStream => _predictionStreamController.stream;

  /// Initialize the enhanced cycle service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      AppLogger.cycle('🔄 Initializing Enhanced Cycle Service...');
      
      _prefs = await SharedPreferences.getInstance();
      
      // Load existing data
      await _loadCycleData();
      await _loadPredictions();
      await _loadSymptoms();
      await _loadSettings();
      
      // Generate initial predictions if needed
      if (_predictions.isEmpty && _cycles.length >= 2) {
        await _generatePredictions();
      }
      
      _isInitialized = true;
      AppLogger.cycle('✅ Enhanced Cycle Service initialized successfully');
      
      // Start background tasks
      _startBackgroundTasks();
      
    } catch (e) {
      AppLogger.error('❌ Failed to initialize Enhanced Cycle Service', e);
      rethrow;
    }
  }

  /// Add a new cycle period
  Future<void> addCycle({
    required DateTime startDate,
    DateTime? endDate,
    required FlowIntensity flow,
    List<String>? symptoms,
    String? notes,
  }) async {
    final enhancementService = AppEnhancementService();
    enhancementService.startPerformanceTrace('add_cycle');

    try {
      final cycle = CycleData(
        id: _generateCycleId(),
        startDate: startDate,
        endDate: endDate,
        flow: flow,
        symptoms: symptoms ?? [],
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _cycles.add(cycle);
      _cycles.sort((a, b) => b.startDate.compareTo(a.startDate));

      await _saveCycleData();
      _cycleStreamController.add(_cycles);

      // Trigger prediction update
      await _generatePredictions();

      // Log cycle length if we have a previous cycle
      if (_cycles.length > 1) {
        final previousCycle = _cycles[1];
        if (previousCycle.startDate.isBefore(startDate)) {
          final cycleLength = startDate.difference(previousCycle.startDate).inDays;
          AppLogger.cycle('📊 Cycle length recorded: $cycleLength days');
          
          // Track cycle irregularities
          if (cycleLength < 21 || cycleLength > 35) {
            AppLogger.cycle('⚠️ Irregular cycle detected: $cycleLength days');
          }
        }
      }

      enhancementService.stopPerformanceTrace('add_cycle');
      AppLogger.cycle('✅ Cycle added successfully: ${cycle.id}');

    } catch (e) {
      enhancementService.stopPerformanceTrace('add_cycle');
      AppLogger.error('❌ Failed to add cycle', e);
      rethrow;
    }
  }

  /// Update an existing cycle
  Future<void> updateCycle(String cycleId, {
    DateTime? startDate,
    DateTime? endDate,
    FlowIntensity? flow,
    List<String>? symptoms,
    String? notes,
  }) async {
    try {
      final index = _cycles.indexWhere((c) => c.id == cycleId);
      if (index == -1) {
        throw ArgumentError('Cycle not found: $cycleId');
      }

      final existingCycle = _cycles[index];
      final updatedCycle = existingCycle.copyWith(
        startDate: startDate,
        endDate: endDate,
        flow: flow,
        symptoms: symptoms,
        notes: notes,
        updatedAt: DateTime.now(),
      );

      _cycles[index] = updatedCycle;
      await _saveCycleData();
      _cycleStreamController.add(_cycles);

      // Regenerate predictions after update
      await _generatePredictions();

      AppLogger.cycle('✅ Cycle updated successfully: $cycleId');

    } catch (e) {
      AppLogger.error('❌ Failed to update cycle', e);
      rethrow;
    }
  }

  /// Delete a cycle
  Future<void> deleteCycle(String cycleId) async {
    try {
      final index = _cycles.indexWhere((c) => c.id == cycleId);
      if (index == -1) {
        throw ArgumentError('Cycle not found: $cycleId');
      }

      _cycles.removeAt(index);
      await _saveCycleData();
      _cycleStreamController.add(_cycles);

      // Regenerate predictions after deletion
      await _generatePredictions();

      AppLogger.cycle('✅ Cycle deleted successfully: $cycleId');

    } catch (e) {
      AppLogger.error('❌ Failed to delete cycle', e);
      rethrow;
    }
  }

  /// Track daily symptoms
  Future<void> trackSymptoms({
    required DateTime date,
    required Map<SymptomType, SymptomIntensity> symptoms,
    String? notes,
  }) async {
    try {
      final dateKey = _formatDateKey(date);
      
      _symptoms[dateKey] = SymptomTracking(
        date: date,
        symptoms: symptoms,
        notes: notes,
        createdAt: DateTime.now(),
      );

      await _saveSymptoms();
      AppLogger.cycle('✅ Symptoms tracked for ${dateKey}');

    } catch (e) {
      AppLogger.error('❌ Failed to track symptoms', e);
      rethrow;
    }
  }

  /// Get cycle statistics
  CycleStatistics getCycleStatistics() {
    if (_cycles.isEmpty) {
      return CycleStatistics.empty();
    }

    final cycleLengths = <int>[];
    final periodLengths = <int>[];

    for (int i = 0; i < _cycles.length - 1; i++) {
      final current = _cycles[i];
      final next = _cycles[i + 1];
      
      // Calculate cycle length (from start of one period to start of next)
      final cycleLength = current.startDate.difference(next.startDate).inDays;
      if (cycleLength > 0 && cycleLength < 60) { // Reasonable range
        cycleLengths.add(cycleLength);
      }

      // Calculate period length if end date is available
      if (current.endDate != null) {
        final periodLength = current.endDate!.difference(current.startDate).inDays + 1;
        if (periodLength > 0 && periodLength < 15) { // Reasonable range
          periodLengths.add(periodLength);
        }
      }
    }

    return CycleStatistics(
      totalCycles: _cycles.length,
      averageCycleLength: cycleLengths.isNotEmpty 
        ? (cycleLengths.reduce((a, b) => a + b) / cycleLengths.length).round()
        : 0,
      averagePeriodLength: periodLengths.isNotEmpty
        ? (periodLengths.reduce((a, b) => a + b) / periodLengths.length).round()
        : 0,
      cycleLengths: cycleLengths,
      periodLengths: periodLengths,
      shortestCycle: cycleLengths.isNotEmpty ? cycleLengths.reduce((a, b) => a < b ? a : b) : 0,
      longestCycle: cycleLengths.isNotEmpty ? cycleLengths.reduce((a, b) => a > b ? a : b) : 0,
      regularityScore: _calculateRegularityScore(cycleLengths),
    );
  }

  /// Get next period prediction
  PeriodPrediction? getNextPeriodPrediction() {
    if (_predictions.isEmpty) return null;
    
    final now = DateTime.now();
    return _predictions
        .where((p) => p.predictedStartDate.isAfter(now))
        .isNotEmpty 
        ? _predictions.first 
        : null;
  }

  /// Get symptoms for a specific date range
  List<SymptomTracking> getSymptomsForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final symptoms = <SymptomTracking>[];
    
    for (final entry in _symptoms.entries) {
      final symptom = entry.value;
      if (symptom.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          symptom.date.isBefore(endDate.add(const Duration(days: 1)))) {
        symptoms.add(symptom);
      }
    }
    
    symptoms.sort((a, b) => a.date.compareTo(b.date));
    return symptoms;
  }

  /// Generate AI-powered cycle predictions
  Future<void> _generatePredictions() async {
    try {
      if (_cycles.length < 2) {
        _predictions.clear();
        _predictionStreamController.add(_predictions);
        return;
      }

      final statistics = getCycleStatistics();
      final predictions = <PeriodPrediction>[];
      
      // Get the most recent cycle
      final lastCycle = _cycles.first;
      var nextPredictedStart = lastCycle.startDate.add(Duration(days: statistics.averageCycleLength));
      
      // Generate predictions for the next 6 cycles
      for (int i = 0; i < 6; i++) {
        final confidence = _calculatePredictionConfidence(statistics, i);
        
        predictions.add(PeriodPrediction(
          id: 'prediction_${i + 1}',
          predictedStartDate: nextPredictedStart,
          predictedEndDate: nextPredictedStart.add(Duration(days: statistics.averagePeriodLength - 1)),
          confidence: confidence,
          cycleNumber: i + 1,
          basedOnCycles: statistics.totalCycles,
          createdAt: DateTime.now(),
        ));
        
        nextPredictedStart = nextPredictedStart.add(Duration(days: statistics.averageCycleLength));
      }

      _predictions = predictions;
      await _savePredictions();
      _predictionStreamController.add(_predictions);

      AppLogger.cycle('✅ Generated ${predictions.length} cycle predictions');

    } catch (e) {
      AppLogger.error('❌ Failed to generate predictions', e);
    }
  }

  /// Calculate prediction confidence based on cycle regularity
  double _calculatePredictionConfidence(CycleStatistics stats, int predictionIndex) {
    if (stats.cycleLengths.isEmpty) return 0.0;
    
    // Base confidence decreases with prediction distance
    double baseConfidence = 1.0 - (predictionIndex * 0.1);
    
    // Adjust based on regularity score
    double regularityMultiplier = stats.regularityScore / 100.0;
    
    // Adjust based on sample size
    double sampleSizeMultiplier = (stats.totalCycles / 10.0).clamp(0.1, 1.0);
    
    return (baseConfidence * regularityMultiplier * sampleSizeMultiplier).clamp(0.0, 1.0);
  }

  /// Calculate cycle regularity score (0-100)
  double _calculateRegularityScore(List<int> cycleLengths) {
    if (cycleLengths.length < 2) return 0.0;
    
    final average = cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
    final variance = cycleLengths
        .map((length) => (length - average) * (length - average))
        .reduce((a, b) => a + b) / cycleLengths.length;
    
    final standardDeviation = sqrt(variance);
    
    // Convert standard deviation to regularity score (lower deviation = higher score)
    final maxExpectedDeviation = 7.0; // 7 days is quite irregular
    final regularityScore = ((maxExpectedDeviation - standardDeviation) / maxExpectedDeviation * 100).clamp(0.0, 100.0);
    
    return regularityScore;
  }

  /// Load cycle data from storage
  Future<void> _loadCycleData() async {
    try {
      final cycleDataJson = _prefs?.getString(_cycleDataKey);
      if (cycleDataJson != null) {
        final List<dynamic> cycleList = json.decode(cycleDataJson);
        _cycles = cycleList.map((data) => CycleData.fromJson(data)).toList();
        _cycles.sort((a, b) => b.startDate.compareTo(a.startDate));
      }
    } catch (e) {
      AppLogger.error('❌ Failed to load cycle data', e);
    }
  }

  /// Save cycle data to storage
  Future<void> _saveCycleData() async {
    try {
      final cycleDataJson = json.encode(_cycles.map((c) => c.toJson()).toList());
      await _prefs?.setString(_cycleDataKey, cycleDataJson);
    } catch (e) {
      AppLogger.error('❌ Failed to save cycle data', e);
    }
  }

  /// Load predictions from storage
  Future<void> _loadPredictions() async {
    try {
      final predictionsJson = _prefs?.getString(_predictionsKey);
      if (predictionsJson != null) {
        final List<dynamic> predictionList = json.decode(predictionsJson);
        _predictions = predictionList.map((data) => PeriodPrediction.fromJson(data)).toList();
      }
    } catch (e) {
      AppLogger.error('❌ Failed to load predictions', e);
    }
  }

  /// Save predictions to storage
  Future<void> _savePredictions() async {
    try {
      final predictionsJson = json.encode(_predictions.map((p) => p.toJson()).toList());
      await _prefs?.setString(_predictionsKey, predictionsJson);
    } catch (e) {
      AppLogger.error('❌ Failed to save predictions', e);
    }
  }

  /// Load symptoms from storage
  Future<void> _loadSymptoms() async {
    try {
      final symptomsJson = _prefs?.getString(_symptomsKey);
      if (symptomsJson != null) {
        final Map<String, dynamic> symptomMap = json.decode(symptomsJson);
        _symptoms = symptomMap.map(
          (key, value) => MapEntry(key, SymptomTracking.fromJson(value)),
        );
      }
    } catch (e) {
      AppLogger.error('❌ Failed to load symptoms', e);
    }
  }

  /// Save symptoms to storage
  Future<void> _saveSymptoms() async {
    try {
      final symptomMap = _symptoms.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
      final symptomsJson = json.encode(symptomMap);
      await _prefs?.setString(_symptomsKey, symptomsJson);
    } catch (e) {
      AppLogger.error('❌ Failed to save symptoms', e);
    }
  }

  /// Load settings from storage
  Future<void> _loadSettings() async {
    try {
      final settingsJson = _prefs?.getString(_settingsKey);
      if (settingsJson != null) {
        _settings = CycleSettings.fromJson(json.decode(settingsJson));
      }
    } catch (e) {
      AppLogger.error('❌ Failed to load cycle settings', e);
    }
  }

  /// Save settings to storage
  Future<void> _saveSettings() async {
    try {
      final settingsJson = json.encode(_settings.toJson());
      await _prefs?.setString(_settingsKey, settingsJson);
    } catch (e) {
      AppLogger.error('❌ Failed to save cycle settings', e);
    }
  }

  /// Update cycle settings
  Future<void> updateSettings(CycleSettings newSettings) async {
    _settings = newSettings;
    await _saveSettings();
    AppLogger.cycle('✅ Cycle settings updated');
  }

  /// Generate unique cycle ID
  String _generateCycleId() {
    return 'cycle_${DateTime.now().millisecondsSinceEpoch}_${_cycles.length}';
  }

  /// Format date as key for storage
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Start background tasks
  void _startBackgroundTasks() {
    // Update predictions daily
    Timer.periodic(const Duration(hours: 24), (timer) {
      if (_cycles.length >= 2) {
        _generatePredictions();
      }
    });

    // Clean up old data periodically
    Timer.periodic(const Duration(days: 7), (timer) {
      _cleanupOldData();
    });
  }

  /// Clean up old data to prevent storage bloat
  Future<void> _cleanupOldData() async {
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 730)); // 2 years
      
      // Remove old cycles (keep at least 12 for accuracy)
      if (_cycles.length > 12) {
        _cycles.removeWhere((cycle) => cycle.startDate.isBefore(cutoffDate));
        await _saveCycleData();
      }
      
      // Remove old symptoms
      _symptoms.removeWhere((key, symptom) => symptom.date.isBefore(cutoffDate));
      await _saveSymptoms();
      
      AppLogger.cycle('🧹 Old cycle data cleaned up');
      
    } catch (e) {
      AppLogger.error('❌ Failed to cleanup old data', e);
    }
  }

  /// Export cycle data for backup/sharing
  Map<String, dynamic> exportData() {
    return {
      'cycles': _cycles.map((c) => c.toJson()).toList(),
      'predictions': _predictions.map((p) => p.toJson()).toList(),
      'symptoms': _symptoms.map((k, v) => MapEntry(k, v.toJson())),
      'settings': _settings.toJson(),
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0',
    };
  }

  /// Import cycle data from backup
  Future<void> importData(Map<String, dynamic> data) async {
    try {
      // Backup current data
      final backup = exportData();
      
      if (data['cycles'] != null) {
        final List<dynamic> cycleList = data['cycles'];
        _cycles = cycleList.map((c) => CycleData.fromJson(c)).toList();
        _cycles.sort((a, b) => b.startDate.compareTo(a.startDate));
      }
      
      if (data['symptoms'] != null) {
        final Map<String, dynamic> symptomMap = data['symptoms'];
        _symptoms = symptomMap.map(
          (k, v) => MapEntry(k, SymptomTracking.fromJson(v)),
        );
      }
      
      if (data['settings'] != null) {
        _settings = CycleSettings.fromJson(data['settings']);
      }
      
      // Save imported data
      await _saveCycleData();
      await _saveSymptoms();
      await _saveSettings();
      
      // Regenerate predictions
      await _generatePredictions();
      
      // Notify listeners
      _cycleStreamController.add(_cycles);
      
      AppLogger.cycle('✅ Cycle data imported successfully');
      
    } catch (e) {
      AppLogger.error('❌ Failed to import cycle data', e);
      rethrow;
    }
  }

  /// Dispose resources
  void dispose() {
    _cycleStreamController.close();
    _predictionStreamController.close();
    AppLogger.cycle('🔄 Enhanced Cycle Service disposed');
  }
}

/// Square root function for regularity calculation
double sqrt(double value) {
  if (value < 0) return double.nan;
  if (value == 0) return 0;
  
  double x = value;
  double prev;
  
  // Newton's method for square root
  do {
    prev = x;
    x = (x + value / x) / 2;
  } while ((x - prev).abs() > 0.0001);
  
  return x;
}
