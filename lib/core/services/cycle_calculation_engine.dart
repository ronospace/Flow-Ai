import 'dart:math';
import '../database/database_service.dart';
import '../models/cycle_data.dart';

// Additional types for cycle calculations
class CyclePredictions {
  final DateTime nextPeriodDate;
  final DateTime? ovulationDate;
  final DateTime fertileWindowStart;
  final DateTime fertileWindowEnd;
  final CyclePhase currentPhase;
  final int cycleLength;
  final CycleRegularity cycleRegularity;
  final PredictionConfidence confidence;
  final DateTime lastUpdated;

  CyclePredictions({
    required this.nextPeriodDate,
    this.ovulationDate,
    required this.fertileWindowStart,
    required this.fertileWindowEnd,
    required this.currentPhase,
    required this.cycleLength,
    required this.cycleRegularity,
    required this.confidence,
    required this.lastUpdated,
  });
  
  /// Get days until next period
  int get daysUntilNextPeriod {
    return nextPeriodDate.difference(DateTime.now()).inDays;
  }
  
  /// Get days until ovulation
  int get daysUntilOvulation {
    if (ovulationDate == null) return 0;
    return ovulationDate!.difference(DateTime.now()).inDays;
  }
  
  /// Check if currently in fertile window
  bool get isInFertileWindow {
    final now = DateTime.now();
    return now.isAfter(fertileWindowStart.subtract(const Duration(days: 1))) &&
           now.isBefore(fertileWindowEnd.add(const Duration(days: 1)));
  }
}

class CycleStatistics {
  final int averageCycleLength;
  final double regularityScore;
  final CycleRegularity regularity;
  final double standardDeviation;
  final int sampleSize;

  CycleStatistics({
    required this.averageCycleLength,
    required this.regularityScore,
    required this.regularity,
    required this.standardDeviation,
    required this.sampleSize,
  });
}

/// Date range helper class
class DateRange {
  final DateTime start;
  final DateTime end;
  
  DateRange({required this.start, required this.end});
  
  bool contains(DateTime date) {
    return date.isAfter(start.subtract(const Duration(days: 1))) &&
           date.isBefore(end.add(const Duration(days: 1)));
  }
  
  int get lengthInDays {
    return end.difference(start).inDays + 1;
  }
}

enum CycleRegularity {
  veryRegular,
  regular,
  somewhatIrregular,
  irregular,
  unknown,
}

/// Prediction confidence levels
enum PredictionConfidence {
  high,
  medium,
  low,
  veryLow,
}

/// Extension for PredictionConfidence
extension PredictionConfidenceExtension on PredictionConfidence {
  String get displayName {
    switch (this) {
      case PredictionConfidence.high:
        return 'High Confidence';
      case PredictionConfidence.medium:
        return 'Medium Confidence';
      case PredictionConfidence.low:
        return 'Low Confidence';
      case PredictionConfidence.veryLow:
        return 'Very Low Confidence';
    }
  }
  
  double get score {
    switch (this) {
      case PredictionConfidence.high:
        return 0.9;
      case PredictionConfidence.medium:
        return 0.7;
      case PredictionConfidence.low:
        return 0.4;
      case PredictionConfidence.veryLow:
        return 0.1;
    }
  }
}

/// Comprehensive engine for calculating menstrual cycle predictions
/// Uses standard fertility tracking algorithms and historical data analysis
class CycleCalculationEngine {
  final DatabaseService _database;
  
  // Standard cycle parameters (in days)
  static const int averageCycleLength = 28;
  static const int averageLutealPhase = 14;
  static const int minCycleLength = 21;
  static const int maxCycleLength = 35;
  static const int fertileWindowDays = 6; // 5 days before + ovulation day
  
  CycleCalculationEngine(this._database);
  
  // Default constructor for cases where database is initialized later
  CycleCalculationEngine.withoutDatabase() : _database = DatabaseService();
  
  /// Calculate next cycle prediction (simpler version for compatibility)
  CyclePrediction? calculateNextCycle(List<CycleData> cycles) {
    if (cycles.isEmpty) return null;
    
    // Sort cycles by start date
    cycles.sort((a, b) => a.startDate.compareTo(b.startDate));
    
    // Calculate average cycle length
    final cycleLengths = <int>[];
    for (int i = 0; i < cycles.length - 1; i++) {
      final length = cycles[i + 1].startDate.difference(cycles[i].startDate).inDays;
      if (length >= minCycleLength && length <= maxCycleLength) {
        cycleLengths.add(length);
      }
    }
    
    final avgLength = cycleLengths.isNotEmpty 
        ? cycleLengths.reduce((a, b) => a + b) / cycleLengths.length 
        : averageCycleLength.toDouble();
    
    // Predict next cycle start date
    final lastCycle = cycles.last;
    final predictedStartDate = lastCycle.startDate.add(Duration(days: avgLength.round()));
    
    // Calculate ovulation day (typically 14 days before next period)
    final ovulationDay = avgLength.round() - averageLutealPhase;
    
    // Calculate confidence based on data consistency
    double confidence = 0.8;
    if (cycleLengths.length >= 3) {
      final variance = cycleLengths.map((l) => (l - avgLength) * (l - avgLength)).reduce((a, b) => a + b) / cycleLengths.length;
      confidence = max(0.3, 1.0 - (sqrt(variance) / 10.0));
    }
    
    return CyclePrediction(
      predictedStartDate: predictedStartDate,
      predictedLength: avgLength.round(),
      confidence: confidence,
      fertileWindow: FertileWindow(
        start: predictedStartDate.subtract(Duration(days: avgLength.round() - ovulationDay + 5)),
        end: predictedStartDate.subtract(Duration(days: avgLength.round() - ovulationDay - 1)),
        peak: predictedStartDate.subtract(Duration(days: avgLength.round() - ovulationDay)),
      ),
    );
  }
  
  /// Calculate comprehensive cycle predictions for a user
  Future<CyclePredictions> calculatePredictions({
    required DateTime referenceDate,
    int monthsOfHistory = 12,
  }) async {
    try {
      // Get historical cycle data
      final historicalCycles = await _getHistoricalCycles(monthsOfHistory);
      
      // Find current or most recent cycle
      final currentCycle = await _getCurrentCycle(referenceDate);
      
      // Calculate cycle statistics
      final stats = _calculateCycleStatistics(historicalCycles);
      
      // Generate predictions
      final nextPeriod = _predictNextPeriod(currentCycle, stats, referenceDate);
      final fertileWindow = _calculateFertileWindow(nextPeriod, stats);
      final ovulationDate = _calculateOvulationDate(nextPeriod, stats);
      final currentPhase = _calculateCurrentPhase(currentCycle, referenceDate, stats);
      
      // Calculate confidence scores
      final confidence = _calculateConfidence(historicalCycles, stats);
      
      return CyclePredictions(
        nextPeriodDate: nextPeriod,
        ovulationDate: ovulationDate,
        fertileWindowStart: fertileWindow.start,
        fertileWindowEnd: fertileWindow.end,
        currentPhase: currentPhase,
        cycleLength: stats.averageCycleLength,
        cycleRegularity: stats.regularity,
        confidence: confidence,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      // Return default predictions if calculation fails
      return _getDefaultPredictions(referenceDate);
    }
  }
  
  /// Get historical cycles for analysis
  Future<List<CycleData>> _getHistoricalCycles(int months) async {
    final endDate = DateTime.now();
    final startDate = DateTime(endDate.year, endDate.month - months, endDate.day);
    
    return await _database.getCyclesInRange(startDate, endDate);
  }
  
  /// Find current active cycle or most recent cycle
  Future<CycleData?> _getCurrentCycle(DateTime referenceDate) async {
    // Get recent cycles to find current one
    final recentCycles = await _getHistoricalCycles(3);
    
    if (recentCycles.isEmpty) return null;
    
    // Sort by start date (most recent first)
    recentCycles.sort((a, b) => b.startDate.compareTo(a.startDate));
    
    // Check if reference date falls within any recent cycle
    for (final cycle in recentCycles) {
      final cycleEnd = cycle.endDate ?? _estimateCycleEnd(cycle);
      if (referenceDate.isAfter(cycle.startDate.subtract(const Duration(days: 1))) &&
          referenceDate.isBefore(cycleEnd.add(const Duration(days: 1)))) {
        return cycle;
      }
    }
    
    // Return most recent cycle if no current cycle found
    return recentCycles.first;
  }
  
  /// Calculate cycle statistics from historical data
  CycleStatistics _calculateCycleStatistics(List<CycleData> cycles) {
    if (cycles.length < 2) {
      return CycleStatistics(
        averageCycleLength: averageCycleLength,
        regularityScore: 0.0,
        regularity: CycleRegularity.unknown,
        standardDeviation: 0.0,
        sampleSize: cycles.length,
      );
    }
    
    // Calculate cycle lengths
    final cycleLengths = <int>[];
    for (int i = 0; i < cycles.length - 1; i++) {
      final currentCycle = cycles[i];
      final nextCycle = cycles[i + 1];
      final length = nextCycle.startDate.difference(currentCycle.startDate).inDays;
      if (length >= minCycleLength && length <= maxCycleLength) {
        cycleLengths.add(length);
      }
    }
    
    if (cycleLengths.isEmpty) {
      return CycleStatistics(
        averageCycleLength: averageCycleLength,
        regularityScore: 0.0,
        regularity: CycleRegularity.unknown,
        standardDeviation: 0.0,
        sampleSize: 0,
      );
    }
    
    // Calculate average cycle length
    final avgLength = cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
    
    // Calculate standard deviation
    final variance = cycleLengths
        .map((length) => pow(length - avgLength, 2))
        .reduce((a, b) => a + b) / cycleLengths.length;
    final stdDev = sqrt(variance);
    
    // Determine regularity
    final regularity = _determineRegularity(stdDev, cycleLengths.length);
    final regularityScore = _calculateRegularityScore(stdDev);
    
    return CycleStatistics(
      averageCycleLength: avgLength.round(),
      regularityScore: regularityScore,
      regularity: regularity,
      standardDeviation: stdDev,
      sampleSize: cycleLengths.length,
    );
  }
  
  /// Predict next period date
  DateTime _predictNextPeriod(CycleData? currentCycle, CycleStatistics stats, DateTime referenceDate) {
    if (currentCycle == null) {
      // No cycle data, predict based on reference date
      return referenceDate.add(Duration(days: stats.averageCycleLength));
    }
    
    // If cycle is still active, predict from cycle start
    final estimatedEnd = currentCycle.endDate ?? _estimateCycleEnd(currentCycle);
    if (referenceDate.isBefore(estimatedEnd)) {
      // We're still in current cycle
      return currentCycle.startDate.add(Duration(days: stats.averageCycleLength));
    }
    
    // Current cycle has ended, predict next cycle
    return estimatedEnd.add(Duration(days: stats.averageCycleLength));
  }
  
  /// Calculate fertile window
  DateRange _calculateFertileWindow(DateTime nextPeriodDate, CycleStatistics stats) {
    // Ovulation typically occurs 14 days before next period
    final ovulationDate = nextPeriodDate.subtract(Duration(days: averageLutealPhase));
    
    // Fertile window is 5 days before ovulation + ovulation day
    final fertileStart = ovulationDate.subtract(const Duration(days: 5));
    final fertileEnd = ovulationDate;
    
    return DateRange(start: fertileStart, end: fertileEnd);
  }
  
  /// Calculate ovulation date
  DateTime _calculateOvulationDate(DateTime nextPeriodDate, CycleStatistics stats) {
    // Standard algorithm: 14 days before next period
    return nextPeriodDate.subtract(Duration(days: averageLutealPhase));
  }
  
  /// Calculate current cycle phase
  CyclePhase _calculateCurrentPhase(CycleData? currentCycle, DateTime referenceDate, CycleStatistics stats) {
    if (currentCycle == null) {
      return CyclePhase.unknown;
    }
    
    final daysSinceStart = referenceDate.difference(currentCycle.startDate).inDays;
    final cycleLength = stats.averageCycleLength;
    
    // Menstrual phase (days 1-5)
    if (daysSinceStart <= 5) {
      return CyclePhase.menstrual;
    }
    
    // Follicular phase (days 6 - ovulation)
    final ovulationDay = cycleLength - averageLutealPhase;
    if (daysSinceStart < ovulationDay) {
      return CyclePhase.follicular;
    }
    
    // Ovulatory phase (around ovulation day ± 1)
    if (daysSinceStart >= ovulationDay - 1 && daysSinceStart <= ovulationDay + 1) {
      return CyclePhase.ovulatory;
    }
    
    // Luteal phase (after ovulation until next period)
    if (daysSinceStart < cycleLength) {
      return CyclePhase.luteal;
    }
    
    // Beyond expected cycle length
    return CyclePhase.unknown;
  }
  
  /// Calculate prediction confidence based on data quality
  PredictionConfidence _calculateConfidence(List<CycleData> cycles, CycleStatistics stats) {
    double confidenceScore = 0.0;
    
    // Factor 1: Amount of historical data (0-40 points)
    final dataPoints = min(cycles.length, 12);
    confidenceScore += (dataPoints / 12.0) * 40;
    
    // Factor 2: Cycle regularity (0-40 points)
    confidenceScore += stats.regularityScore * 40;
    
    // Factor 3: Recent data availability (0-20 points)
    if (cycles.isNotEmpty) {
      final daysSinceLastCycle = DateTime.now().difference(cycles.first.startDate).inDays;
      if (daysSinceLastCycle <= 60) {
        confidenceScore += 20;
      } else if (daysSinceLastCycle <= 120) {
        confidenceScore += 10;
      }
    }
    
    // Convert to confidence level
    if (confidenceScore >= 80) return PredictionConfidence.high;
    if (confidenceScore >= 50) return PredictionConfidence.medium;
    if (confidenceScore >= 20) return PredictionConfidence.low;
    return PredictionConfidence.veryLow;
  }
  
  /// Determine cycle regularity from standard deviation
  CycleRegularity _determineRegularity(double stdDev, int sampleSize) {
    if (sampleSize < 3) return CycleRegularity.unknown;
    
    if (stdDev <= 2.0) return CycleRegularity.veryRegular;
    if (stdDev <= 4.0) return CycleRegularity.regular;
    if (stdDev <= 7.0) return CycleRegularity.somewhatIrregular;
    return CycleRegularity.irregular;
  }
  
  /// Calculate regularity score (0.0 - 1.0)
  double _calculateRegularityScore(double stdDev) {
    // Higher score for lower standard deviation
    return max(0.0, 1.0 - (stdDev / 10.0));
  }
  
  /// Estimate cycle end date when not provided
  DateTime _estimateCycleEnd(CycleData cycle) {
    return cycle.startDate.add(Duration(days: averageCycleLength));
  }
  
  /// Get default predictions when no data is available
  CyclePredictions _getDefaultPredictions(DateTime referenceDate) {
    final nextPeriod = referenceDate.add(const Duration(days: averageCycleLength));
    final ovulation = nextPeriod.subtract(const Duration(days: averageLutealPhase));
    final fertileStart = ovulation.subtract(const Duration(days: 5));
    
    return CyclePredictions(
      nextPeriodDate: nextPeriod,
      ovulationDate: ovulation,
      fertileWindowStart: fertileStart,
      fertileWindowEnd: ovulation,
      currentPhase: CyclePhase.unknown,
      cycleLength: averageCycleLength,
      cycleRegularity: CycleRegularity.unknown,
      confidence: PredictionConfidence.veryLow,
      lastUpdated: DateTime.now(),
    );
  }
}

