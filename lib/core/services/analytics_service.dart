import 'dart:math';
import '../models/cycle_data.dart' as cycle_data;
import '../models/daily_tracking_data.dart';
import '../database/database_service.dart';
import 'cycle_calculation_engine.dart';
import 'performance_optimizer.dart';

import 'advanced_biometric_service.dart';

import '../identity/active_account_scope.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  static AnalyticsService get instance => _instance;
  AnalyticsService._internal();

  final DatabaseService _databaseService = DatabaseService();
  // ignore: unused_field
  late final CycleCalculationEngine _calculationEngine = CycleCalculationEngine(
    _databaseService,
  );

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  // Cycle Analytics with performance optimization
  Future<CycleAnalytics> getCycleAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final activeUserId = await ActiveAccountScope.instance.requireUserId();
    // Use performance optimizer for caching
    return await PerformanceOptimizer.instance.getOrCompute<CycleAnalytics>(
      key:
          'cycle_analytics_${activeUserId}_${startDate?.toIso8601String() ?? 'all'}_${endDate?.toIso8601String() ?? 'now'}',
      compute: () async {
        try {
          startDate ??= DateTime.now().subtract(const Duration(days: 365));
          endDate ??= DateTime.now();

          final cycles = await _databaseService.getCyclesInRange(
            startDate!,
            endDate!,
          );
          final trackingDataMaps = await _databaseService
              .getTrackingDataInRange(startDate!, endDate!);
          final trackingData = trackingDataMaps.map((map) {
            // Convert map to DailyTrackingData
            // The database returns date as ISO string, need to parse it
            final dateStr = map['date'] is String
                ? map['date']
                : map['date'].toString().split('T')[0];
            final date = DateTime.tryParse(dateStr) ?? DateTime.now();

            return DailyTrackingData(
              date: date,
              flowIntensity: map['flow_intensity'] is cycle_data.FlowIntensity
                  ? _flowIntensityToInt(
                      map['flow_intensity'] as cycle_data.FlowIntensity,
                    )
                  : map['flow_intensity'] is int
                  ? _asInt(map['flow_intensity'])
                  : null,
              mood: _asInt(map['mood']),
              energy: _asInt(map['energy']),
              sleepHours: _asDouble(map['sleep_hours']),
              symptoms:
                  (map['symptoms'] as List<dynamic>?)?.cast<String>() ?? [],
              medications:
                  (map['medications'] as List<dynamic>?)?.cast<String>() ?? [],
              notes: map['notes'] as String?,
              isPeriodDay: map['is_period_day'] as bool? ?? false,
              isOvulationDay: map['is_ovulation_day'] as bool? ?? false,
              customFields: map['custom_fields'] as Map<String, dynamic>?,
              createdAt: map['created_at'] is String
                  ? DateTime.tryParse(map['created_at']) ?? DateTime.now()
                  : DateTime.fromMillisecondsSinceEpoch(
                      _asInt(map['created_at']) ??
                          DateTime.now().millisecondsSinceEpoch,
                    ),
              updatedAt: map['updated_at'] is String
                  ? DateTime.tryParse(map['updated_at']) ?? DateTime.now()
                  : DateTime.fromMillisecondsSinceEpoch(
                      _asInt(map['updated_at']) ??
                          DateTime.now().millisecondsSinceEpoch,
                    ),
            );
          }).toList();

          return _calculateCycleAnalytics(cycles, trackingData);
        } catch (e) {
          return CycleAnalytics.empty();
        }
      },
      cacheDuration: const Duration(minutes: 15), // Cache for 15 minutes
    );
  }

  // Health Analytics with performance optimization
  Future<HealthAnalytics> getHealthAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final activeUserId = await ActiveAccountScope.instance.requireUserId();
    // Use performance optimizer for caching
    return await PerformanceOptimizer.instance.getOrCompute<HealthAnalytics>(
      key:
          'health_analytics_${activeUserId}_${startDate?.toIso8601String() ?? 'all'}_${endDate?.toIso8601String() ?? 'now'}',
      compute: () async {
        try {
          startDate ??= DateTime.now().subtract(const Duration(days: 90));
          endDate ??= DateTime.now();

          final trackingDataMaps = await _databaseService
              .getTrackingDataInRange(startDate!, endDate!);
          final trackingData = trackingDataMaps.map((map) {
            final dateStr = map['date'] is String
                ? map['date']
                : map['date'].toString().split('T')[0];
            final date = DateTime.tryParse(dateStr) ?? DateTime.now();

            return DailyTrackingData(
              date: date,
              flowIntensity: map['flow_intensity'] is cycle_data.FlowIntensity
                  ? _flowIntensityToInt(
                      map['flow_intensity'] as cycle_data.FlowIntensity,
                    )
                  : map['flow_intensity'] is int
                  ? _asInt(map['flow_intensity'])
                  : null,
              mood: _asInt(map['mood']),
              energy: _asInt(map['energy']),
              sleepHours: _asDouble(map['sleep_hours']),
              symptoms:
                  (map['symptoms'] as List<dynamic>?)?.cast<String>() ?? [],
              medications:
                  (map['medications'] as List<dynamic>?)?.cast<String>() ?? [],
              notes: map['notes'] as String?,
              isPeriodDay: map['is_period_day'] as bool? ?? false,
              isOvulationDay: map['is_ovulation_day'] as bool? ?? false,
              customFields: map['custom_fields'] as Map<String, dynamic>?,
              createdAt: map['created_at'] is String
                  ? DateTime.tryParse(map['created_at']) ?? DateTime.now()
                  : DateTime.fromMillisecondsSinceEpoch(
                      _asInt(map['created_at']) ??
                          DateTime.now().millisecondsSinceEpoch,
                    ),
              updatedAt: map['updated_at'] is String
                  ? DateTime.tryParse(map['updated_at']) ?? DateTime.now()
                  : DateTime.fromMillisecondsSinceEpoch(
                      _asInt(map['updated_at']) ??
                          DateTime.now().millisecondsSinceEpoch,
                    ),
            );
          }).toList();
          final symptoms = await _databaseService.getAllSymptoms();

          return _calculateHealthAnalytics(trackingData, symptoms);
        } catch (e) {
          return HealthAnalytics.empty();
        }
      },
      cacheDuration: const Duration(minutes: 15), // Cache for 15 minutes
    );
  }

  // Prediction Analytics
  Future<PredictionAnalytics> getPredictionAnalytics() async {
    try {
      final cycles = await _databaseService.getCyclesInRange(
        DateTime.now().subtract(const Duration(days: 365)),
        DateTime.now(),
      );

      return _calculatePredictionAnalytics(cycles);
    } catch (e) {
      return PredictionAnalytics.empty();
    }
  }

  // Trend Analytics
  Future<TrendAnalytics> getTrendAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      startDate ??= DateTime.now().subtract(const Duration(days: 180));
      endDate ??= DateTime.now();

      final trackingDataMaps = await _databaseService.getTrackingDataInRange(
        startDate,
        endDate,
      );
      final trackingData = trackingDataMaps.map((map) {
        final dateStr = map['date'] is String
            ? map['date']
            : map['date'].toString().split('T')[0];
        final date = DateTime.tryParse(dateStr) ?? DateTime.now();

        return DailyTrackingData(
          date: date,
          flowIntensity: map['flow_intensity'] is cycle_data.FlowIntensity
              ? _flowIntensityToInt(
                  map['flow_intensity'] as cycle_data.FlowIntensity,
                )
              : map['flow_intensity'] is int
              ? _asInt(map['flow_intensity'])
              : _asInt(map['flow_intensity']),
          mood: _asInt(map['mood']),
          energy: _asInt(map['energy']),
          sleepHours: _asDouble(map['sleep_hours']),
          symptoms: (map['symptoms'] as List<dynamic>?)?.cast<String>() ?? [],
          medications:
              (map['medications'] as List<dynamic>?)?.cast<String>() ?? [],
          notes: map['notes'] as String?,
          isPeriodDay: map['is_period_day'] as bool? ?? false,
          isOvulationDay: map['is_ovulation_day'] as bool? ?? false,
          customFields: map['custom_fields'] as Map<String, dynamic>?,
          createdAt: map['created_at'] is String
              ? DateTime.tryParse(map['created_at']) ?? DateTime.now()
              : DateTime.fromMillisecondsSinceEpoch(
                  ((map['created_at'] as num?)?.toInt()) ??
                      DateTime.now().millisecondsSinceEpoch,
                ),
          updatedAt: map['updated_at'] is String
              ? DateTime.tryParse(map['updated_at']) ?? DateTime.now()
              : DateTime.fromMillisecondsSinceEpoch(
                  ((map['updated_at'] as num?)?.toInt()) ??
                      DateTime.now().millisecondsSinceEpoch,
                ),
        );
      }).toList();
      final cycles = await _databaseService.getCyclesInRange(
        startDate,
        endDate,
      );

      return _calculateTrendAnalytics(trackingData, cycles);
    } catch (e) {
      return TrendAnalytics.empty();
    }
  }

  /// Canonical persisted/Health-backed history for analytics charts.
  ///
  /// Missing dates remain missing. Current snapshots are never synthesized
  /// into historical points.
  Future<List<cycle_data.CycleData>> getPersistedCycleHistory() async {
    return _databaseService.getAllCycles();
  }

  Future<AnalyticsHistory> getAnalyticsHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final resolvedEnd = endDate ?? DateTime.now();
    final resolvedStart =
        startDate ?? resolvedEnd.subtract(const Duration(days: 30));

    if (!resolvedStart.isBefore(resolvedEnd)) {
      return AnalyticsHistory.empty();
    }

    try {
      final trackingRows = await _databaseService.getTrackingDataInRange(
        resolvedStart,
        resolvedEnd,
      );

      final mood = <DateTime, double>{};
      final energy = <DateTime, double>{};

      for (final row in trackingRows) {
        final rawDate = row['date'];

        final parsedDate = rawDate is DateTime
            ? rawDate
            : DateTime.tryParse(rawDate?.toString() ?? '');

        if (parsedDate == null) continue;

        final day = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);

        final moodValue = _asDouble(row['mood']);
        if (moodValue != null) {
          mood[day] = moodValue;
        }

        final energyValue = _asDouble(row['energy']);
        if (energyValue != null) {
          energy[day] = energyValue;
        }
      }

      final sleepPoints = await AdvancedBiometricService.instance
          .getHistoricalSleepHours(start: resolvedStart, end: resolvedEnd);

      final sleepHours = <DateTime, double>{};

      for (final point in sleepPoints) {
        final day = DateTime(
          point.timestamp.year,
          point.timestamp.month,
          point.timestamp.day,
        );

        sleepHours[day] = point.value;
      }

      final cycles = await _databaseService.getCyclesInRange(
        resolvedStart,
        resolvedEnd,
      );

      final completedCycleLengths = <double>[];
      for (final cycle in cycles) {
        final end = cycle.endDate;
        if (end == null) continue;

        final days = end.difference(cycle.startDate).inDays;
        if (days > 0) {
          completedCycleLengths.add(days.toDouble());
        }
      }

      return AnalyticsHistory(
        mood: mood,
        energy: energy,
        sleepHours: sleepHours,
        cycleRegularity: completedCycleLengths,
      );
    } catch (_) {
      return AnalyticsHistory.empty();
    }
  }

  // Personalized Recommendations
  Future<List<PersonalizedRecommendation>>
  getPersonalizedRecommendations() async {
    try {
      final analytics = await getCycleAnalytics();
      final healthAnalytics = await getHealthAnalytics();
      final trendAnalytics = await getTrendAnalytics();

      return _generatePersonalizedRecommendations(
        analytics,
        healthAnalytics,
        trendAnalytics,
      );
    } catch (e) {
      return [];
    }
  }

  // Log event for general analytics tracking
  void logEvent(String eventName, Map<String, dynamic> parameters) {
    try {
      // In a production app, this would send to your analytics backend
    } catch (e) {
    }
  }

  // Private calculation methods
  CycleAnalytics _calculateCycleAnalytics(
    List<cycle_data.CycleData> cycles,
    List<DailyTrackingData> trackingData,
  ) {
    if (cycles.isEmpty) return CycleAnalytics.empty();

    // Calculate cycle statistics
    final cycleLengths = cycles.map((c) => c.length).toList();
    final averageCycleLength =
        cycleLengths.fold(0.0, (a, b) => a + b) / cycleLengths.length;

    // For period length, we'll use the period length or cycle length as an estimate
    // In a real implementation, this would be calculated from bleeding days
    final periodLengths = cycles
        .map((c) => c.periodLength ?? c.length)
        .toList();
    final averagePeriodLength = periodLengths.isNotEmpty
        ? periodLengths.fold(0.0, (a, b) => a + b) / periodLengths.length
        : 0.0;

    // Calculate cycle regularity
    final cycleVariations = <double>[];
    for (int i = 1; i < cycleLengths.length; i++) {
      cycleVariations.add(
        (cycleLengths[i] - cycleLengths[i - 1]).abs().toDouble(),
      );
    }
    final averageVariation = cycleVariations.isNotEmpty
        ? cycleVariations.fold(0.0, (a, b) => a + b) / cycleVariations.length
        : 0.0;

    final regularityScore = _calculateRegularityScore(averageVariation);

    // Calculate flow patterns - convert int? to FlowIntensity
    final flowData = trackingData
        .where((t) => t.flowIntensity != null)
        .map((t) => _intToFlowIntensity(t.flowIntensity!))
        .toList();

    final flowPattern = _analyzeFlowPattern(flowData);

    // Calculate symptom patterns
    final symptomFrequency = _calculateSymptomFrequency(trackingData);

    return CycleAnalytics(
      totalCycles: cycles.length,
      averageCycleLength: averageCycleLength,
      averagePeriodLength: averagePeriodLength,
      regularityScore: regularityScore,
      cycleVariation: averageVariation,
      flowPattern: flowPattern,
      symptomFrequency: symptomFrequency,
      lastUpdated: DateTime.now(),
    );
  }

  HealthAnalytics _calculateHealthAnalytics(
    List<DailyTrackingData> trackingData,
    List<Map<String, dynamic>> symptoms,
  ) {
    // Mood analysis
    final moodData = trackingData
        .where((t) => t.mood != null)
        .map((t) => t.mood!)
        .toList();
    final moodTrend = _calculateMoodTrend(moodData);

    // Energy analysis
    final energyData = trackingData
        .where((t) => t.energy != null)
        .map((t) => t.energy!)
        .toList();
    final energyTrend = _calculateEnergyTrend(energyData);

    // Sleep analysis
    final sleepData = trackingData
        .where((t) => t.sleepHours != null)
        .map((t) => t.sleepHours!)
        .toList();
    final sleepTrend = _calculateSleepTrend(sleepData);

    // Symptom severity trends
    final symptomSeverity = _calculateSymptomSeverityTrends(trackingData);

    // A numeric overall health rating is intentionally not
    // generated from mood, energy, and sleep tracking data.
    return HealthAnalytics(
      moodTrend: moodTrend,
      energyTrend: energyTrend,
      sleepTrend: sleepTrend,
      symptomSeverity: symptomSeverity,
      // Legacy compatibility field. Flow AI no longer presents
      // this as a health rating.
      overallHealthScore: 0.0,
      lastUpdated: DateTime.now(),
    );
  }

  PredictionAnalytics _calculatePredictionAnalytics(
    List<cycle_data.CycleData> cycles,
  ) {
    if (cycles.length < 3) {
      return PredictionAnalytics.empty();
    }

    // Flow AI does not currently persist historical production
    // prediction snapshots alongside their later actual outcomes.
    // Without that ledger, a retrospective accuracy calculation would
    // be synthetic. Fail closed until real prediction-versus-actual
    // records exist.
    return PredictionAnalytics.empty();
  }

  TrendAnalytics _calculateTrendAnalytics(
    List<DailyTrackingData> trackingData,
    List<cycle_data.CycleData> cycles,
  ) {
    // Calculate monthly trends
    final monthlyData = _groupDataByMonth(trackingData);
    final trends = <String, TrendData>{};

    // Mood trends
    trends['mood'] = _calculateDataTrend(
      monthlyData
          .map(
            (month) =>
                month
                    .where((t) => t.mood != null)
                    .map((t) => t.mood!.toDouble())
                    .fold(0.0, (a, b) => a + b) /
                month.where((t) => t.mood != null).length,
          )
          .toList(),
    );

    // Energy trends
    trends['energy'] = _calculateDataTrend(
      monthlyData
          .map(
            (month) =>
                month
                    .where((t) => t.energy != null)
                    .map((t) => t.energy!.toDouble())
                    .fold(0.0, (a, b) => a + b) /
                month.where((t) => t.energy != null).length,
          )
          .toList(),
    );

    // Sleep trends
    trends['sleep'] = _calculateDataTrend(
      monthlyData
          .map(
            (month) =>
                month
                    .where((t) => t.sleepHours != null)
                    .map((t) => t.sleepHours!)
                    .fold(0.0, (a, b) => a + b) /
                month.where((t) => t.sleepHours != null).length,
          )
          .toList(),
    );

    return TrendAnalytics(
      trends: trends,
      timeframe: '6 months',
      lastUpdated: DateTime.now(),
    );
  }

  List<PersonalizedRecommendation> _generatePersonalizedRecommendations(
    CycleAnalytics cycleAnalytics,
    HealthAnalytics healthAnalytics,
    TrendAnalytics trendAnalytics,
  ) {
    final recommendations = <PersonalizedRecommendation>[];

    // Cycle-based recommendations
    if (cycleAnalytics.regularityScore < 0.7) {
      recommendations.add(
        PersonalizedRecommendation(
          id: 'cycle_regularity',
          title: 'Improve Cycle Regularity',
          description:
              'Your cycles show some irregularity. Consider lifestyle adjustments.',
          category: RecommendationCategory.cycle,
          priority: RecommendationPriority.medium,
          actionItems: [
            'Maintain consistent sleep schedule',
            'Practice stress management techniques',
            'Consider consulting a healthcare provider',
          ],
          icon: 'cycle_regularity',
        ),
      );
    }

    // No generic health recommendation is generated from an
    // unvalidated numeric health score.

    // Mood-based recommendations
    if (healthAnalytics.moodTrend.isAvailable &&
        healthAnalytics.moodTrend.direction == TrendDirection.declining) {
      recommendations.add(
        PersonalizedRecommendation(
          id: 'mood_support',
          title: 'Support Your Mood',
          description: 'Your mood has been trending downward recently.',
          category: RecommendationCategory.mood,
          priority: RecommendationPriority.high,
          actionItems: [
            'Engage in activities you enjoy',
            'Connect with friends and family',
            'Consider professional support if needed',
            'Practice gratitude journaling',
          ],
          icon: 'mood_support',
        ),
      );
    }

    return recommendations;
  }

  // Helper methods
  double _calculateRegularityScore(double variation) {
    // Score from 0-1, where 1 is perfectly regular
    if (variation <= 1) return 1.0;
    if (variation <= 2) return 0.9;
    if (variation <= 3) return 0.8;
    if (variation <= 4) return 0.7;
    if (variation <= 5) return 0.6;
    return max(0.0, 0.6 - (variation - 5) * 0.1);
  }

  FlowPattern _analyzeFlowPattern(List<cycle_data.FlowIntensity> flowData) {
    if (flowData.isEmpty) return FlowPattern.unknown;

    final intensityCounts = <cycle_data.FlowIntensity, int>{};
    for (final flow in flowData) {
      intensityCounts[flow] = (intensityCounts[flow] ?? 0) + 1;
    }

    final mostCommon = intensityCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    switch (mostCommon) {
      case cycle_data.FlowIntensity.light:
        return FlowPattern.light;
      case cycle_data.FlowIntensity.medium:
        return FlowPattern.medium;
      case cycle_data.FlowIntensity.heavy:
        return FlowPattern.heavy;
      default:
        return FlowPattern.variable;
    }
  }

  Map<String, double> _calculateSymptomFrequency(
    List<DailyTrackingData> trackingData,
  ) {
    final symptomCounts = <String, int>{};
    final totalDays = trackingData.length;

    for (final data in trackingData) {
      for (final symptom in data.symptoms) {
        symptomCounts[symptom] = (symptomCounts[symptom] ?? 0) + 1;
      }
    }

    return symptomCounts.map(
      (symptom, count) => MapEntry(symptom, count / totalDays),
    );
  }

  TrendData _calculateMoodTrend(List<int> moodData) {
    if (moodData.length < 2) return TrendData.stable();

    final average = moodData.fold(0, (a, b) => a + b) / moodData.length;
    final recent = moodData
        .skip(moodData.length - min(7, moodData.length))
        .toList();
    final recentAverage = recent.fold(0, (a, b) => a + b) / recent.length;

    final difference = recentAverage - average;

    if (difference > 0.5) return TrendData.improving();
    if (difference < -0.5) return TrendData.declining();
    return TrendData.stable();
  }

  TrendData _calculateEnergyTrend(List<int> energyData) {
    return _calculateMoodTrend(energyData); // Same logic
  }

  TrendData _calculateSleepTrend(List<double> sleepData) {
    if (sleepData.length < 2) return TrendData.stable();

    final average = sleepData.fold(0.0, (a, b) => a + b) / sleepData.length;
    final recent = sleepData
        .skip(sleepData.length - min(7, sleepData.length))
        .toList();
    final recentAverage = recent.fold(0.0, (a, b) => a + b) / recent.length;

    final difference = recentAverage - average;

    if (difference > 0.5) return TrendData.improving();
    if (difference < -0.5) return TrendData.declining();
    return TrendData.stable();
  }

  Map<String, TrendData> _calculateSymptomSeverityTrends(
    List<DailyTrackingData> trackingData,
  ) {
    // Placeholder implementation
    return {};
  }

  List<List<DailyTrackingData>> _groupDataByMonth(
    List<DailyTrackingData> data,
  ) {
    final grouped = <DateTime, List<DailyTrackingData>>{};

    for (final item in data) {
      final monthKey = DateTime(item.date.year, item.date.month);
      grouped.putIfAbsent(monthKey, () => []).add(item);
    }

    return grouped.values.toList();
  }

  TrendData _calculateDataTrend(List<double> values) {
    if (values.length < 2) return TrendData.stable();

    // Simple linear regression slope
    final n = values.length;
    final x = List.generate(n, (i) => i.toDouble());
    final y = values;

    final xMean = x.fold(0.0, (a, b) => a + b) / n;
    final yMean = y.fold(0.0, (a, b) => a + b) / n;

    double numerator = 0;
    double denominator = 0;

    for (int i = 0; i < n; i++) {
      numerator += (x[i] - xMean) * (y[i] - yMean);
      denominator += (x[i] - xMean) * (x[i] - xMean);
    }

    final slope = denominator != 0 ? numerator / denominator : 0;

    if (slope > 0.1) return TrendData.improving();
    if (slope < -0.1) return TrendData.declining();
    return TrendData.stable();
  }
}

// Analytics Models

class AnalyticsHistory {
  final Map<DateTime, double> mood;
  final Map<DateTime, double> energy;
  final Map<DateTime, double> sleepHours;

  /// Actual completed cycle lengths. Empty means insufficient history.
  final List<double> cycleRegularity;

  const AnalyticsHistory({
    required this.mood,
    required this.energy,
    required this.sleepHours,
    required this.cycleRegularity,
  });

  factory AnalyticsHistory.empty() => const AnalyticsHistory(
    mood: <DateTime, double>{},
    energy: <DateTime, double>{},
    sleepHours: <DateTime, double>{},
    cycleRegularity: <double>[],
  );

  bool get isEmpty =>
      mood.isEmpty &&
      energy.isEmpty &&
      sleepHours.isEmpty &&
      cycleRegularity.isEmpty;
}

class CycleAnalytics {
  final int totalCycles;
  final double averageCycleLength;
  final double averagePeriodLength;
  final double regularityScore;
  final double cycleVariation;
  final FlowPattern flowPattern;
  final Map<String, double> symptomFrequency;
  final DateTime lastUpdated;

  CycleAnalytics({
    required this.totalCycles,
    required this.averageCycleLength,
    required this.averagePeriodLength,
    required this.regularityScore,
    required this.cycleVariation,
    required this.flowPattern,
    required this.symptomFrequency,
    required this.lastUpdated,
  });

  factory CycleAnalytics.empty() => CycleAnalytics(
    totalCycles: 0,
    averageCycleLength: 0,
    averagePeriodLength: 0,
    regularityScore: 0,
    cycleVariation: 0,
    flowPattern: FlowPattern.unknown,
    symptomFrequency: {},
    lastUpdated: DateTime.now(),
  );
}

class HealthAnalytics {
  final TrendData moodTrend;
  final TrendData energyTrend;
  final TrendData sleepTrend;
  final Map<String, TrendData> symptomSeverity;
  final double overallHealthScore;
  final DateTime lastUpdated;

  HealthAnalytics({
    required this.moodTrend,
    required this.energyTrend,
    required this.sleepTrend,
    required this.symptomSeverity,
    required this.overallHealthScore,
    required this.lastUpdated,
  });

  factory HealthAnalytics.empty() => HealthAnalytics(
    moodTrend: TrendData.unavailable(),
    energyTrend: TrendData.unavailable(),
    sleepTrend: TrendData.unavailable(),
    symptomSeverity: {},
    overallHealthScore: 0.0,
    lastUpdated: DateTime.now(),
  );
}

class PredictionAnalytics {
  final double averageAccuracyDays;
  final double confidenceScore;
  final List<PredictionAccuracy> accuracyHistory;
  final int totalPredictions;
  final DateTime lastUpdated;

  PredictionAnalytics({
    required this.averageAccuracyDays,
    required this.confidenceScore,
    required this.accuracyHistory,
    required this.totalPredictions,
    required this.lastUpdated,
  });

  factory PredictionAnalytics.empty() => PredictionAnalytics(
    averageAccuracyDays: 0,
    confidenceScore: 0,
    accuracyHistory: [],
    totalPredictions: 0,
    lastUpdated: DateTime.now(),
  );
}

class TrendAnalytics {
  final Map<String, TrendData> trends;
  final String timeframe;
  final DateTime lastUpdated;

  TrendAnalytics({
    required this.trends,
    required this.timeframe,
    required this.lastUpdated,
  });

  factory TrendAnalytics.empty() =>
      TrendAnalytics(trends: {}, timeframe: '', lastUpdated: DateTime.now());
}

class TrendData {
  final bool isAvailable;
  final TrendDirection direction;
  final double magnitude;
  final double confidence;

  TrendData({
    this.isAvailable = true,
    required this.direction,
    required this.magnitude,
    required this.confidence,
  });

  factory TrendData.improving() => TrendData(
    direction: TrendDirection.improving,
    magnitude: 0.5,
    confidence: 0.8,
  );

  factory TrendData.declining() => TrendData(
    direction: TrendDirection.declining,
    magnitude: 0.5,
    confidence: 0.8,
  );
  factory TrendData.unavailable() => TrendData(
    isAvailable: false,
    direction: TrendDirection.stable,
    magnitude: 0.0,
    confidence: 0.0,
  );

  factory TrendData.stable() => TrendData(
    direction: TrendDirection.stable,
    magnitude: 0.0,
    confidence: 0.9,
  );
}

class PredictionAccuracy {
  final int cycleNumber;
  final DateTime predictedDate;
  final DateTime actualDate;
  final int accuracyDays;

  PredictionAccuracy({
    required this.cycleNumber,
    required this.predictedDate,
    required this.actualDate,
    required this.accuracyDays,
  });
}

class PersonalizedRecommendation {
  final String id;
  final String title;
  final String description;
  final RecommendationCategory category;
  final RecommendationPriority priority;
  final List<String> actionItems;
  final String icon;

  PersonalizedRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.actionItems,
    required this.icon,
  });
}

// Helper functions for conversions
cycle_data.FlowIntensity _intToFlowIntensity(int value) {
  switch (value) {
    case 0:
      return cycle_data.FlowIntensity.none;
    case 1:
      return cycle_data.FlowIntensity.spotting;
    case 2:
      return cycle_data.FlowIntensity.light;
    case 3:
      return cycle_data.FlowIntensity.medium;
    case 4:
      return cycle_data.FlowIntensity.heavy;
    case 5:
      return cycle_data.FlowIntensity.veryHeavy;
    default:
      return cycle_data.FlowIntensity.none;
  }
}

int _flowIntensityToInt(cycle_data.FlowIntensity value) {
  switch (value) {
    case cycle_data.FlowIntensity.none:
      return 0;
    case cycle_data.FlowIntensity.spotting:
      return 1;
    case cycle_data.FlowIntensity.light:
      return 2;
    case cycle_data.FlowIntensity.medium:
      return 3;
    case cycle_data.FlowIntensity.heavy:
      return 4;
    case cycle_data.FlowIntensity.veryHeavy:
      return 5;
  }
}

enum FlowPattern { light, medium, heavy, variable, unknown }

enum TrendDirection { improving, declining, stable }

enum RecommendationCategory { cycle, health, mood, sleep, nutrition, exercise }

enum RecommendationPriority { low, medium, high, urgent }

/// Extension for RecommendationPriority to add compareTo functionality
extension RecommendationPriorityExtension on RecommendationPriority {
  int compareTo(RecommendationPriority other) {
    return index.compareTo(other.index);
  }
}
