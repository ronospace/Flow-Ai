import 'package:json_annotation/json_annotation.dart';

part 'cycle_data.g.dart';

/// Cycle phase enumeration
enum CyclePhase {
  menstrual,
  follicular,
  ovulatory,
  ovulation, // Alias for ovulatory
  luteal,
  preMenstrual
}

/// Flow intensity levels
enum FlowIntensity {
  none,
  spotting,
  light,
  medium,
  heavy,
  veryHeavy
}

/// Cycle data model
@JsonSerializable()
class CycleData {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime? endDate;
  final int length;
  final Map<DateTime, DailyData> dailyData;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CycleData({
    required this.id,
    required this.userId,
    required this.startDate,
    this.endDate,
    required this.length,
    required this.dailyData,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CycleData.fromJson(Map<String, dynamic> json) => _$CycleDataFromJson(json);
  Map<String, dynamic> toJson() => _$CycleDataToJson(this);
  
  /// Create a copy with updated fields
  CycleData copyWith({
    String? id,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int? length,
    Map<DateTime, DailyData>? dailyData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CycleData(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      length: length ?? this.length,
      dailyData: dailyData ?? this.dailyData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

/// Daily cycle data
@JsonSerializable()
class DailyData {
  final DateTime date;
  final FlowIntensity? flowIntensity;
  final List<String> symptoms;
  final int? moodScore;
  final int? energyLevel;
  final double? bodyTemperature;
  final String? notes;
  final Map<String, dynamic> additionalData;

  const DailyData({
    required this.date,
    this.flowIntensity,
    this.symptoms = const [],
    this.moodScore,
    this.energyLevel,
    this.bodyTemperature,
    this.notes,
    this.additionalData = const {},
  });

  factory DailyData.fromJson(Map<String, dynamic> json) => _$DailyDataFromJson(json);
  Map<String, dynamic> toJson() => _$DailyDataToJson(this);
}

/// Cycle settings
@JsonSerializable()
class CycleSettings {
  final int averageCycleLength;
  final int averagePeriodLength;
  final bool enablePredictions;
  final bool enableNotifications;
  final Map<String, dynamic> customSettings;

  const CycleSettings({
    this.averageCycleLength = 28,
    this.averagePeriodLength = 5,
    this.enablePredictions = true,
    this.enableNotifications = true,
    this.customSettings = const {},
  });

  factory CycleSettings.fromJson(Map<String, dynamic> json) => _$CycleSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$CycleSettingsToJson(this);
  
  /// Create default settings
  factory CycleSettings.defaults() => const CycleSettings();
}

/// Cycle statistics
@JsonSerializable()
class CycleStatistics {
  final double averageCycleLength;
  final double averagePeriodLength;
  final double cycleVariability;
  final int totalCycles;
  final DateTime? lastPeriodStart;
  final DateTime? nextPredictedPeriod;
  final Map<String, dynamic> additionalStats;

  const CycleStatistics({
    required this.averageCycleLength,
    required this.averagePeriodLength,
    required this.cycleVariability,
    required this.totalCycles,
    this.lastPeriodStart,
    this.nextPredictedPeriod,
    this.additionalStats = const {},
  });

  factory CycleStatistics.fromJson(Map<String, dynamic> json) => _$CycleStatisticsFromJson(json);
  Map<String, dynamic> toJson() => _$CycleStatisticsToJson(this);
  
  /// Create empty statistics
  factory CycleStatistics.empty() => const CycleStatistics(
    averageCycleLength: 28.0,
    averagePeriodLength: 5.0,
    cycleVariability: 0.0,
    totalCycles: 0,
  );
  
  /// Get cycle lengths list (for backward compatibility)
  List<int> get cycleLengths => [];
}
