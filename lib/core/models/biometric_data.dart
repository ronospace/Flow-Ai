import 'package:flutter/foundation.dart';

/// Week 3: Biometric Data Models
/// Comprehensive data structures for wearable device integration

// === Heart Rate Data Models ===

enum HeartRateType {
  resting,
  active,
  peak,
  recovery,
}

@immutable
class HeartRateData {
  final DateTime timestamp;
  final double beatsPerMinute;
  final HeartRateType type;
  final double? reliability;
  final String? deviceSource;
  final Map<String, dynamic>? metadata;

  const HeartRateData({
    required this.timestamp,
    required this.beatsPerMinute,
    required this.type,
    this.reliability,
    this.deviceSource,
    this.metadata,
  });

  factory HeartRateData.fromJson(Map<String, dynamic> json) {
    return HeartRateData(
      timestamp: DateTime.parse(json['timestamp']),
      beatsPerMinute: (json['beats_per_minute'] as num).toDouble(),
      type: HeartRateType.values.byName(json['type']),
      reliability: json['reliability']?.toDouble(),
      deviceSource: json['device_source'],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'beats_per_minute': beatsPerMinute,
      'type': type.name,
      'reliability': reliability,
      'device_source': deviceSource,
      'metadata': metadata,
    };
  }
}

@immutable
class HeartRateAnalysis {
  final double averageRestingHR;
  final double phaseBaseline;
  final double deviation;
  final double zScore;
  final double trend;
  final double confidence;
  final List<String> insights;
  final bool anomalyDetected;
  final DateTime analysisDate;

  const HeartRateAnalysis({
    required this.averageRestingHR,
    required this.phaseBaseline,
    required this.deviation,
    required this.zScore,
    required this.trend,
    required this.confidence,
    required this.insights,
    required this.anomalyDetected,
    required this.analysisDate,
  });

  factory HeartRateAnalysis.empty() {
    return HeartRateAnalysis(
      averageRestingHR: 0.0,
      phaseBaseline: 0.0,
      deviation: 0.0,
      zScore: 0.0,
      trend: 0.0,
      confidence: 0.0,
      insights: [],
      anomalyDetected: false,
      analysisDate: DateTime.now(),
    );
  }
}

// === Heart Rate Variability (HRV) Models ===

@immutable
class HRVData {
  final DateTime timestamp;
  final double rmssd; // Root Mean Square of Successive Differences
  final double sdnn; // Standard Deviation of NN intervals
  final double pnn50; // Percentage of successive NN intervals > 50ms
  final double triangularIndex;
  final double? stressScore;
  final String? recordingContext; // 'sleep', 'morning', 'post_exercise', etc.
  final String? deviceSource;

  const HRVData({
    required this.timestamp,
    required this.rmssd,
    required this.sdnn,
    required this.pnn50,
    required this.triangularIndex,
    this.stressScore,
    this.recordingContext,
    this.deviceSource,
  });

  factory HRVData.fromJson(Map<String, dynamic> json) {
    return HRVData(
      timestamp: DateTime.parse(json['timestamp']),
      rmssd: (json['rmssd'] as num).toDouble(),
      sdnn: (json['sdnn'] as num).toDouble(),
      pnn50: (json['pnn50'] as num).toDouble(),
      triangularIndex: (json['triangular_index'] as num).toDouble(),
      stressScore: json['stress_score']?.toDouble(),
      recordingContext: json['recording_context'],
      deviceSource: json['device_source'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'rmssd': rmssd,
      'sdnn': sdnn,
      'pnn50': pnn50,
      'triangular_index': triangularIndex,
      'stress_score': stressScore,
      'recording_context': recordingContext,
      'device_source': deviceSource,
    };
  }
}

@immutable
class HRVAnalysis {
  final double averageRMSSD;
  final double averageSDNN;
  final String recoveryStatus; // 'excellent', 'good', 'moderate', 'poor'
  final double stressLevel; // 0.0 to 1.0
  final Map<String, dynamic> phaseCorrelation;
  final double confidence;
  final List<String> recommendations;
  final DateTime analysisDate;

  const HRVAnalysis({
    required this.averageRMSSD,
    required this.averageSDNN,
    required this.recoveryStatus,
    required this.stressLevel,
    required this.phaseCorrelation,
    required this.confidence,
    required this.recommendations,
    required this.analysisDate,
  });

  factory HRVAnalysis.empty() {
    return HRVAnalysis(
      averageRMSSD: 0.0,
      averageSDNN: 0.0,
      recoveryStatus: 'unknown',
      stressLevel: 0.0,
      phaseCorrelation: {},
      confidence: 0.0,
      recommendations: [],
      analysisDate: DateTime.now(),
    );
  }
}

// === Sleep Data Models ===

enum SleepStage {
  awake,
  light,
  deep,
  rem,
  unknown,
}

@immutable
class SleepStageData {
  final SleepStage stage;
  final DateTime startTime;
  final Duration duration;

  const SleepStageData({
    required this.stage,
    required this.startTime,
    required this.duration,
  });
}

@immutable
class SleepData {
  final DateTime sleepDate;
  final DateTime bedtime;
  final DateTime sleepOnset;
  final DateTime wakeTime;
  final Duration totalDuration;
  final Duration actualSleepTime;
  final double efficiency; // actualSleepTime / totalDuration
  final double deepSleepPercentage;
  final double remSleepPercentage;
  final double lightSleepPercentage;
  final int awakeDuringNight;
  final List<SleepStageData> sleepStages;
  final double? sleepScore;
  final String? deviceSource;
  final Map<String, dynamic>? environmentalFactors;

  const SleepData({
    required this.sleepDate,
    required this.bedtime,
    required this.sleepOnset,
    required this.wakeTime,
    required this.totalDuration,
    required this.actualSleepTime,
    required this.efficiency,
    required this.deepSleepPercentage,
    required this.remSleepPercentage,
    required this.lightSleepPercentage,
    required this.awakeDuringNight,
    required this.sleepStages,
    this.sleepScore,
    this.deviceSource,
    this.environmentalFactors,
  });

  factory SleepData.fromJson(Map<String, dynamic> json) {
    return SleepData(
      sleepDate: DateTime.parse(json['sleep_date']),
      bedtime: DateTime.parse(json['bedtime']),
      sleepOnset: DateTime.parse(json['sleep_onset']),
      wakeTime: DateTime.parse(json['wake_time']),
      totalDuration: Duration(minutes: json['total_duration_minutes']),
      actualSleepTime: Duration(minutes: json['actual_sleep_time_minutes']),
      efficiency: (json['efficiency'] as num).toDouble(),
      deepSleepPercentage: (json['deep_sleep_percentage'] as num).toDouble(),
      remSleepPercentage: (json['rem_sleep_percentage'] as num).toDouble(),
      lightSleepPercentage: (json['light_sleep_percentage'] as num).toDouble(),
      awakeDuringNight: json['awake_during_night'],
      sleepStages: (json['sleep_stages'] as List?)
              ?.map((stage) => SleepStageData(
                    stage: SleepStage.values.byName(stage['stage']),
                    startTime: DateTime.parse(stage['start_time']),
                    duration: Duration(minutes: stage['duration_minutes']),
                  ))
              .toList() ??
          [],
      sleepScore: json['sleep_score']?.toDouble(),
      deviceSource: json['device_source'],
      environmentalFactors: json['environmental_factors'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sleep_date': sleepDate.toIso8601String(),
      'bedtime': bedtime.toIso8601String(),
      'sleep_onset': sleepOnset.toIso8601String(),
      'wake_time': wakeTime.toIso8601String(),
      'total_duration_minutes': totalDuration.inMinutes,
      'actual_sleep_time_minutes': actualSleepTime.inMinutes,
      'efficiency': efficiency,
      'deep_sleep_percentage': deepSleepPercentage,
      'rem_sleep_percentage': remSleepPercentage,
      'light_sleep_percentage': lightSleepPercentage,
      'awake_during_night': awakeDuringNight,
      'sleep_stages': sleepStages.map((stage) => {
        'stage': stage.stage.name,
        'start_time': stage.startTime.toIso8601String(),
        'duration_minutes': stage.duration.inMinutes,
      }).toList(),
      'sleep_score': sleepScore,
      'device_source': deviceSource,
      'environmental_factors': environmentalFactors,
    };
  }
}

@immutable
class SleepAnalysis {
  final double averageDuration;
  final double averageEfficiency;
  final double averageDeepSleepPercentage;
  final double averageREMSleepPercentage;
  final double qualityScore;
  final String trend; // 'improving', 'declining', 'stable'
  final Map<String, dynamic>? phaseImpact;
  final List<String> recommendations;
  final DateTime analysisDate;

  const SleepAnalysis({
    required this.averageDuration,
    required this.averageEfficiency,
    required this.averageDeepSleepPercentage,
    required this.averageREMSleepPercentage,
    required this.qualityScore,
    required this.trend,
    this.phaseImpact,
    required this.recommendations,
    required this.analysisDate,
  });

  factory SleepAnalysis.empty() {
    return SleepAnalysis(
      averageDuration: 0.0,
      averageEfficiency: 0.0,
      averageDeepSleepPercentage: 0.0,
      averageREMSleepPercentage: 0.0,
      qualityScore: 0.0,
      trend: 'insufficient_data',
      recommendations: [],
      analysisDate: DateTime.now(),
    );
  }
}

// === Temperature Data Models ===

enum TemperatureType {
  basalBodyTemperature,
  skinTemperature,
  coreTemperature,
  wristTemperature,
}

@immutable
class TemperatureData {
  final DateTime timestamp;
  final double temperature; // in Fahrenheit
  final TemperatureType type;
  final String? measurementSite; // 'oral', 'wrist', 'finger', etc.
  final double? ambientTemperature;
  final double? humidity;
  final String? deviceSource;
  final Map<String, dynamic>? calibrationData;

  const TemperatureData({
    required this.timestamp,
    required this.temperature,
    required this.type,
    this.measurementSite,
    this.ambientTemperature,
    this.humidity,
    this.deviceSource,
    this.calibrationData,
  });

  factory TemperatureData.fromJson(Map<String, dynamic> json) {
    return TemperatureData(
      timestamp: DateTime.parse(json['timestamp']),
      temperature: (json['temperature'] as num).toDouble(),
      type: TemperatureType.values.byName(json['type']),
      measurementSite: json['measurement_site'],
      ambientTemperature: json['ambient_temperature']?.toDouble(),
      humidity: json['humidity']?.toDouble(),
      deviceSource: json['device_source'],
      calibrationData: json['calibration_data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'temperature': temperature,
      'type': type.name,
      'measurement_site': measurementSite,
      'ambient_temperature': ambientTemperature,
      'humidity': humidity,
      'device_source': deviceSource,
      'calibration_data': calibrationData,
    };
  }

  // Convert Fahrenheit to Celsius
  double get temperatureCelsius => (temperature - 32) * 5 / 9;
}

enum TemperatureSignalType {
  ovulationPattern,
  phaseTransition,
  thermalShift,
  anomaly,
}

@immutable
class TemperatureSignal {
  final TemperatureSignalType type;
  final DateTime timestamp;
  final double temperature;
  final double confidence;
  final String description;
  final Map<String, dynamic>? additionalData;

  const TemperatureSignal({
    required this.type,
    required this.timestamp,
    required this.temperature,
    required this.confidence,
    required this.description,
    this.additionalData,
  });
}

@immutable
class TemperatureAnalysis {
  final double recentAverage;
  final double baseline;
  final double deviation;
  final double trend;
  final List<TemperatureSignal> ovulationSignals;
  final Map<String, dynamic>? phaseTransition;
  final double confidence;
  final List<String> insights;
  final DateTime analysisDate;

  const TemperatureAnalysis({
    required this.recentAverage,
    required this.baseline,
    required this.deviation,
    required this.trend,
    required this.ovulationSignals,
    this.phaseTransition,
    required this.confidence,
    required this.insights,
    required this.analysisDate,
  });

  factory TemperatureAnalysis.empty() {
    return TemperatureAnalysis(
      recentAverage: 0.0,
      baseline: 0.0,
      deviation: 0.0,
      trend: 0.0,
      ovulationSignals: [],
      confidence: 0.0,
      insights: [],
      analysisDate: DateTime.now(),
    );
  }
}

// === Stress and Activity Models ===

@immutable
class StressData {
  final DateTime timestamp;
  final double stressLevel; // 0.0 to 1.0 normalized scale
  final String? stressSource; // 'hrv', 'subjective', 'multi_modal'
  final Map<String, double>? contributingFactors;
  final String? deviceSource;

  const StressData({
    required this.timestamp,
    required this.stressLevel,
    this.stressSource,
    this.contributingFactors,
    this.deviceSource,
  });

  factory StressData.fromJson(Map<String, dynamic> json) {
    return StressData(
      timestamp: DateTime.parse(json['timestamp']),
      stressLevel: (json['stress_level'] as num).toDouble(),
      stressSource: json['stress_source'],
      contributingFactors: (json['contributing_factors'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, (value as num).toDouble())),
      deviceSource: json['device_source'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'stress_level': stressLevel,
      'stress_source': stressSource,
      'contributing_factors': contributingFactors,
      'device_source': deviceSource,
    };
  }
}

@immutable
class ActivityData {
  final DateTime timestamp;
  final int steps;
  final double distanceKm;
  final double caloriesBurned;
  final double activeMinutes;
  final double maxHeartRate;
  final double averageHeartRate;
  final String? activityType; // 'walking', 'running', 'cycling', etc.
  final double? vo2Max;
  final String? deviceSource;

  const ActivityData({
    required this.timestamp,
    required this.steps,
    required this.distanceKm,
    required this.caloriesBurned,
    required this.activeMinutes,
    required this.maxHeartRate,
    required this.averageHeartRate,
    this.activityType,
    this.vo2Max,
    this.deviceSource,
  });

  factory ActivityData.fromJson(Map<String, dynamic> json) {
    return ActivityData(
      timestamp: DateTime.parse(json['timestamp']),
      steps: json['steps'],
      distanceKm: (json['distance_km'] as num).toDouble(),
      caloriesBurned: (json['calories_burned'] as num).toDouble(),
      activeMinutes: (json['active_minutes'] as num).toDouble(),
      maxHeartRate: (json['max_heart_rate'] as num).toDouble(),
      averageHeartRate: (json['average_heart_rate'] as num).toDouble(),
      activityType: json['activity_type'],
      vo2Max: json['vo2_max']?.toDouble(),
      deviceSource: json['device_source'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'steps': steps,
      'distance_km': distanceKm,
      'calories_burned': caloriesBurned,
      'active_minutes': activeMinutes,
      'max_heart_rate': maxHeartRate,
      'average_heart_rate': averageHeartRate,
      'activity_type': activityType,
      'vo2_max': vo2Max,
      'device_source': deviceSource,
    };
  }
}

// === Correlation and Analysis Models ===

@immutable
class BiometricCorrelationAnalysis {
  final Map<String, double> correlations;
  final Map<String, dynamic> predictions;
  final List<String> insights;
  final double confidence;
  final DateTime analysisDate;

  const BiometricCorrelationAnalysis({
    required this.correlations,
    required this.predictions,
    required this.insights,
    required this.confidence,
    required this.analysisDate,
  });
}

enum BiometricAnomalySeverity {
  low,
  medium,
  high,
  critical,
}

enum BiometricAnomalyType {
  heartRateAnomaly,
  hrvAnomaly,
  sleepDisruption,
  temperatureAnomaly,
  stressSpike,
  crossMetricAnomaly,
}

@immutable
class BiometricAnomaly {
  final BiometricAnomalyType type;
  final BiometricAnomalySeverity severity;
  final DateTime timestamp;
  final String description;
  final Map<String, dynamic> data;
  final double confidence;
  final List<String> recommendations;

  const BiometricAnomaly({
    required this.type,
    required this.severity,
    required this.timestamp,
    required this.description,
    required this.data,
    required this.confidence,
    required this.recommendations,
  });
}

// === Generic Biometric Reading Model ===

enum BiometricType {
  heartRate,
  heartRateVariability,
  sleepAnalysis,
  bodyTemperature,
  stressLevel,
  activeEnergyBurned,
  steps,
  respiratoryRate,
  oxygenSaturation,
}

@immutable
class BiometricReading {
  final BiometricType type;
  final double value;
  final DateTime timestamp;
  final String unit;
  final Map<String, dynamic>? metadata;
  final String? deviceSource;
  final double? confidence;

  const BiometricReading({
    required this.type,
    required this.value,
    required this.timestamp,
    required this.unit,
    this.metadata,
    this.deviceSource,
    this.confidence,
  });

  factory BiometricReading.fromJson(Map<String, dynamic> json) {
    return BiometricReading(
      type: BiometricType.values.byName(json['type']),
      value: (json['value'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      unit: json['unit'],
      metadata: json['metadata'] as Map<String, dynamic>?,
      deviceSource: json['device_source'],
      confidence: json['confidence']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
      'unit': unit,
      'metadata': metadata,
      'device_source': deviceSource,
      'confidence': confidence,
    };
  }
}

@immutable
class BiometricAnalysis {
  final List<BiometricReading> heartRateData;
  final List<BiometricReading> sleepData;
  final List<BiometricReading> temperatureData;
  final List<BiometricReading> hrvData;
  final List<BiometricReading> stressData;
  final List<BiometricReading> activityData;
  final DateTime analysisDate;
  final Map<String, double> cycleCorrelations;
  final double? overallHealthScore;
  final List<String> insights;
  final Map<String, dynamic>? trends;

  const BiometricAnalysis({
    required this.heartRateData,
    required this.sleepData,
    required this.temperatureData,
    required this.hrvData,
    required this.stressData,
    required this.activityData,
    required this.analysisDate,
    required this.cycleCorrelations,
    this.overallHealthScore,
    this.insights = const [],
    this.trends,
  });

  factory BiometricAnalysis.empty() {
    return BiometricAnalysis(
      heartRateData: [],
      sleepData: [],
      temperatureData: [],
      hrvData: [],
      stressData: [],
      activityData: [],
      analysisDate: DateTime.now(),
      cycleCorrelations: {},
      overallHealthScore: 0.0,
      insights: [],
      trends: {},
    );
  }

  bool get hasData => 
    heartRateData.isNotEmpty ||
    sleepData.isNotEmpty ||
    temperatureData.isNotEmpty ||
    hrvData.isNotEmpty ||
    stressData.isNotEmpty ||
    activityData.isNotEmpty;

  double get dataCompleteness {
    int categories = 0;
    int filledCategories = 0;
    
    categories += 6; // Total categories we're tracking
    if (heartRateData.isNotEmpty) filledCategories++;
    if (sleepData.isNotEmpty) filledCategories++;
    if (temperatureData.isNotEmpty) filledCategories++;
    if (hrvData.isNotEmpty) filledCategories++;
    if (stressData.isNotEmpty) filledCategories++;
    if (activityData.isNotEmpty) filledCategories++;
    
    return categories > 0 ? filledCategories / categories : 0.0;
  }
}

// === Wearable Device Integration Models ===

enum WearableDeviceType {
  smartwatch,
  fitnessTracker,
  temperatureMonitor,
  chestStrap,
  smartRing,
  other,
}

@immutable
class WearableDevice {
  final String deviceId;
  final String deviceName;
  final WearableDeviceType type;
  final String manufacturer;
  final String model;
  final String firmwareVersion;
  final List<String> supportedMetrics;
  final DateTime lastSync;
  final bool isConnected;
  final Map<String, dynamic>? deviceSettings;

  const WearableDevice({
    required this.deviceId,
    required this.deviceName,
    required this.type,
    required this.manufacturer,
    required this.model,
    required this.firmwareVersion,
    required this.supportedMetrics,
    required this.lastSync,
    required this.isConnected,
    this.deviceSettings,
  });

  factory WearableDevice.fromJson(Map<String, dynamic> json) {
    return WearableDevice(
      deviceId: json['device_id'],
      deviceName: json['device_name'],
      type: WearableDeviceType.values.byName(json['type']),
      manufacturer: json['manufacturer'],
      model: json['model'],
      firmwareVersion: json['firmware_version'],
      supportedMetrics: List<String>.from(json['supported_metrics']),
      lastSync: DateTime.parse(json['last_sync']),
      isConnected: json['is_connected'],
      deviceSettings: json['device_settings'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'device_name': deviceName,
      'type': type.name,
      'manufacturer': manufacturer,
      'model': model,
      'firmware_version': firmwareVersion,
      'supported_metrics': supportedMetrics,
      'last_sync': lastSync.toIso8601String(),
      'is_connected': isConnected,
      'device_settings': deviceSettings,
    };
  }
}

@immutable
class BiometricDataSyncStatus {
  final DateTime lastSyncTime;
  final Map<String, int> syncCounts; // metric type -> number of synced records
  final List<String> syncErrors;
  final bool isSyncing;
  final Duration syncDuration;

  const BiometricDataSyncStatus({
    required this.lastSyncTime,
    required this.syncCounts,
    required this.syncErrors,
    required this.isSyncing,
    required this.syncDuration,
  });
}

// === Aggregated Biometric Summary ===

@immutable
class DailyBiometricSummary {
  final DateTime date;
  final HeartRateData? averageHeartRate;
  final HRVData? hrvSummary;
  final SleepData? sleepData;
  final List<TemperatureData> temperatureReadings;
  final StressData? averageStress;
  final ActivityData? activitySummary;
  final double? overallHealthScore;
  final List<String> insights;
  final Map<String, dynamic>? correlationFactors;

  const DailyBiometricSummary({
    required this.date,
    this.averageHeartRate,
    this.hrvSummary,
    this.sleepData,
    required this.temperatureReadings,
    this.averageStress,
    this.activitySummary,
    this.overallHealthScore,
    required this.insights,
    this.correlationFactors,
  });

  factory DailyBiometricSummary.empty(DateTime date) {
    return DailyBiometricSummary(
      date: date,
      temperatureReadings: [],
      insights: [],
    );
  }
}

@immutable
class WeeklyBiometricTrends {
  final DateTime weekStart;
  final DateTime weekEnd;
  final Map<String, double> metricTrends; // metric name -> trend coefficient
  final List<BiometricAnomaly> detectedAnomalies;
  final Map<String, double> correlationStrengths;
  final List<String> trendInsights;
  final double overallTrendScore;

  const WeeklyBiometricTrends({
    required this.weekStart,
    required this.weekEnd,
    required this.metricTrends,
    required this.detectedAnomalies,
    required this.correlationStrengths,
    required this.trendInsights,
    required this.overallTrendScore,
  });
}
