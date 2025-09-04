import 'dart:math' as math;
import '../database/database_service.dart';
import '../models/cycle_data.dart';
import 'cycle_calculation_engine.dart';

/// Service that integrates database with cycle calculation engine
/// to provide real cycle predictions and data management
class RealCycleService {
  final DatabaseService _database;
  final CycleCalculationEngine _calculationEngine;
  
  RealCycleService(this._database) : _calculationEngine = CycleCalculationEngine(_database);
  
  /// Get comprehensive cycle data and predictions
  Future<RealCycleData> getRealCycleData() async {
    try {
      // Get current cycle predictions
      final predictions = await _calculationEngine.calculatePredictions(
        referenceDate: DateTime.now(),
        monthsOfHistory: 12,
      );
      
      // Get recent cycles for display
      final recentCycles = await _database.getCyclesInRange(
        DateTime.now().subtract(const Duration(days: 180)),
        DateTime.now(),
      );
      
      // Get current cycle if exists
      final currentCycle = await _database.getCurrentCycle();
      
      // Get recent tracking data for insights
      final recentTracking = await _database.getRecentTrackingData(days: 30);
      
      return RealCycleData(
        predictions: predictions,
        recentCycles: recentCycles,
        currentCycle: currentCycle,
        recentTrackingData: recentTracking,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      // Return default data if something goes wrong
      return RealCycleData(
        predictions: await _calculationEngine.calculatePredictions(
          referenceDate: DateTime.now(),
          monthsOfHistory: 0, // This will return default predictions
        ),
        recentCycles: [],
        currentCycle: null,
        recentTrackingData: [],
        lastUpdated: DateTime.now(),
      );
    }
  }
  
  /// Get cycle statistics and insights
  Future<CycleInsights> getCycleInsights() async {
    final stats = await _database.getCycleStatistics();
    final recentData = await _database.getRecentTrackingData(days: 90);
    
    return CycleInsights(
      averageCycleLength: stats['cycle_stats']['avg_length']?.toDouble() ?? 28.0,
      cycleVariability: _calculateVariability(stats),
      totalCycles: stats['cycle_stats']['total_cycles'] ?? 0,
      commonSymptoms: _extractCommonSymptoms(stats['common_symptoms']),
      moodTrends: _analyzeMoodTrends(recentData),
      periodPredictionAccuracy: await _calculatePredictionAccuracy(),
    );
  }
  
  /// Start a new cycle
  Future<void> startNewCycle({
    required DateTime startDate,
    FlowIntensity? initialFlow,
    List<String>? symptoms,
    String? notes,
  }) async {
    // End current cycle if exists
    final current = await _database.getCurrentCycle();
    if (current != null && current.endDate == null) {
      final updatedCycle = current.copyWith(
        endDate: startDate.subtract(const Duration(days: 1)),
      );
      await _database.updateCycle(updatedCycle);
    }
    
    // Create new cycle
    final newCycle = CycleData(
      id: 'cycle_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'unknown', // TODO: Get from auth service
      startDate: startDate,
      endDate: null,
      cycleLength: 28, // Will be updated when cycle ends
      dailyData: {},
      averageFlow: initialFlow ?? FlowIntensity.medium,
      flowIntensity: initialFlow,
      symptoms: symptoms ?? [],
      notes: notes != null ? {"text": notes} : null,
      createdAt: DateTime.now(),
      lastUpdated: DateTime.now(),
    );
    
    await _database.insertCycle(newCycle);
  }
  
  /// End current cycle
  Future<void> endCurrentCycle(DateTime endDate) async {
    final current = await _database.getCurrentCycle();
    if (current != null && current.endDate == null) {
      final length = endDate.difference(current.startDate).inDays;
      final updatedCycle = current.copyWith(
        endDate: endDate,
        cycleLength: length,
      );
      await _database.updateCycle(updatedCycle);
    }
  }
  
  /// Update cycle predictions (refresh calculations)
  Future<CyclePredictions> refreshPredictions() async {
    return await _calculationEngine.calculatePredictions(
      referenceDate: DateTime.now(),
      monthsOfHistory: 12,
    );
  }
  
  // Helper methods
  
  double _calculateVariability(Map<String, dynamic> stats) {
    final min = stats['cycle_stats']['min_length']?.toDouble() ?? 28.0;
    final max = stats['cycle_stats']['max_length']?.toDouble() ?? 28.0;
    final avg = stats['cycle_stats']['avg_length']?.toDouble() ?? 28.0;
    
    if (avg == 0) return 0.0;
    return ((max - min) / avg) * 100; // Variability as percentage
  }
  
  List<String> _extractCommonSymptoms(List<Map<String, dynamic>> symptomData) {
    return symptomData
        .take(5) // Top 5 symptoms
        .map((item) => item['symptoms']?.toString() ?? '')
        .where((symptom) => symptom.isNotEmpty)
        .toList();
  }
  
  Map<String, double> _analyzeMoodTrends(List<Map<String, dynamic>> trackingData) {
    if (trackingData.isEmpty) {
      return {
        'avgMood': 3.0,
        'avgEnergy': 3.0,
        'avgPain': 2.0,
      };
    }
    
    double totalMood = 0;
    double totalEnergy = 0; 
    double totalPain = 0;
    int moodCount = 0;
    int energyCount = 0;
    int painCount = 0;
    
    for (final data in trackingData) {
      if (data['mood'] != null) {
        totalMood += (data['mood'] as num).toDouble();
        moodCount++;
      }
      if (data['energy'] != null) {
        totalEnergy += (data['energy'] as num).toDouble();
        energyCount++;
      }
      if (data['pain'] != null) {
        totalPain += (data['pain'] as num).toDouble();
        painCount++;
      }
    }
    
    return {
      'avgMood': moodCount > 0 ? totalMood / moodCount : 3.0,
      'avgEnergy': energyCount > 0 ? totalEnergy / energyCount : 3.0,
      'avgPain': painCount > 0 ? totalPain / painCount : 2.0,
    };
  }
  
  Future<double> _calculatePredictionAccuracy() async {
    // Simple accuracy calculation based on recent predictions
    // In a real implementation, you'd track prediction vs actual data
    final recentCycles = await _database.getCyclesInRange(
      DateTime.now().subtract(const Duration(days: 180)),
      DateTime.now(),
    );
    
    if (recentCycles.length < 3) return 0.5; // Default 50% when not enough data
    
    // Calculate how regular cycles have been (more regular = higher accuracy)
    final cycleLengths = <int>[];
    for (int i = 0; i < recentCycles.length - 1; i++) {
      final length = recentCycles[i + 1].startDate.difference(recentCycles[i].startDate).inDays;
      cycleLengths.add(length);
    }
    
    if (cycleLengths.isEmpty) return 0.5;
    
    final avgLength = cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
    final variance = cycleLengths.map((l) => (l - avgLength) * (l - avgLength)).reduce((a, b) => a + b) / cycleLengths.length;
    final standardDeviation = math.sqrt(variance);
    
    // Convert standard deviation to accuracy (lower deviation = higher accuracy)
    final accuracy = math.max(0.1, math.min(0.95, 0.9 - (standardDeviation * 0.05)));
    return accuracy;
  }
}

/// Combined cycle data with predictions and insights
class RealCycleData {
  final CyclePredictions predictions;
  final List<CycleData> recentCycles;
  final CycleData? currentCycle;
  final List<Map<String, dynamic>> recentTrackingData;
  final DateTime lastUpdated;
  
  RealCycleData({
    required this.predictions,
    required this.recentCycles,
    required this.currentCycle,
    required this.recentTrackingData,
    required this.lastUpdated,
  });
  
  /// Get current cycle day (days since period started)
  int get currentCycleDay {
    if (currentCycle == null) return 0;
    return DateTime.now().difference(currentCycle!.startDate).inDays + 1;
  }
  
  /// Check if currently menstruating (first 5 days of cycle)
  bool get isMenstruating {
    return currentCycleDay <= 5;
  }
  
  /// Get cycle phase description for UI
  String get phaseDescription {
    return predictions.currentPhase.description;
  }
  
  /// Get next significant event (period, ovulation, etc.)
  NextEvent get nextEvent {
    final now = DateTime.now();
    final daysUntilPeriod = predictions.daysUntilNextPeriod;
    final daysUntilOvulation = predictions.daysUntilOvulation;
    
    if (predictions.isInFertileWindow) {
      return NextEvent(
        type: EventType.fertility,
        date: predictions.fertileWindowEnd,
        daysAway: predictions.fertileWindowEnd.difference(now).inDays,
        description: 'Fertile window ends',
      );
    }
    
    if (daysUntilOvulation > 0 && daysUntilOvulation < daysUntilPeriod && predictions.ovulationDate != null) {
      return NextEvent(
        type: EventType.ovulation,
        date: predictions.ovulationDate!,
        daysAway: daysUntilOvulation,
        description: 'Ovulation expected',
      );
    }
    
    return NextEvent(
      type: EventType.period,
      date: predictions.nextPeriodDate,
      daysAway: daysUntilPeriod,
      description: 'Next period expected',
    );
  }
}

/// Cycle insights for analytics
class CycleInsights {
  final double averageCycleLength;
  final double cycleVariability;
  final int totalCycles;
  final List<String> commonSymptoms;
  final Map<String, double> moodTrends;
  final double periodPredictionAccuracy;
  
  CycleInsights({
    required this.averageCycleLength,
    required this.cycleVariability,
    required this.totalCycles,
    required this.commonSymptoms,
    required this.moodTrends,
    required this.periodPredictionAccuracy,
  });
}

/// Next significant event
class NextEvent {
  final EventType type;
  final DateTime date;
  final int daysAway;
  final String description;
  
  NextEvent({
    required this.type,
    required this.date,
    required this.daysAway,
    required this.description,
  });
}

enum EventType { period, ovulation, fertility }
