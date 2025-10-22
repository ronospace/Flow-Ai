import 'package:json_annotation/json_annotation.dart';

part 'biometric_data.g.dart';

/// Biometric Data Model
/// Represents health metrics collected from wearable devices and health platforms
@JsonSerializable()
class BiometricData {
  final String dataId;
  final BiometricType type;
  final double value;
  final String unit;
  final DateTime timestamp;
  final String source;
  final String? deviceId;
  final double? confidence;
  final Map<String, dynamic> metadata;
  final DataQuality quality;
  final bool isProcessed;

  BiometricData({
    required this.dataId,
    required this.type,
    required this.value,
    required this.unit,
    required this.timestamp,
    required this.source,
    this.deviceId,
    this.confidence,
    this.metadata = const {},
    this.quality = DataQuality.good,
    this.isProcessed = false,
  });

  // Computed properties
  bool get isRecent => DateTime.now().difference(timestamp).inHours < 24;
  bool get isHighConfidence => confidence != null && confidence! >= 0.85;
  bool get isReliable => quality == DataQuality.excellent || quality == DataQuality.good;
  
  /// Get age of data in hours
  int get ageInHours => DateTime.now().difference(timestamp).inHours;
  
  /// Get age of data in minutes
  int get ageInMinutes => DateTime.now().difference(timestamp).inMinutes;

  /// Check if data is within normal ranges
  bool get isWithinNormalRange {
    switch (type) {
      case BiometricType.heartRate:
        return value >= 60 && value <= 100;
      case BiometricType.restingHeartRate:
        return value >= 50 && value <= 90;
      case BiometricType.bloodOxygen:
        return value >= 95 && value <= 100;
      case BiometricType.bodyTemperature:
        return value >= 36.1 && value <= 37.2; // Celsius
      case BiometricType.bloodPressureSystolic:
        return value >= 90 && value <= 120;
      case BiometricType.bloodPressureDiastolic:
        return value >= 60 && value <= 80;
      case BiometricType.respiratoryRate:
        return value >= 12 && value <= 20;
      case BiometricType.stressLevel:
        return value <= 70; // Assuming 0-100 scale
      default:
        return true; // No defined normal range
    }
  }

  /// Get severity level for abnormal values
  BiometricSeverity get severity {
    if (isWithinNormalRange) return BiometricSeverity.normal;
    
    switch (type) {
      case BiometricType.heartRate:
        if (value < 50 || value > 120) return BiometricSeverity.high;
        if (value < 60 || value > 100) return BiometricSeverity.medium;
        return BiometricSeverity.low;
      case BiometricType.bloodOxygen:
        if (value < 90) return BiometricSeverity.high;
        if (value < 95) return BiometricSeverity.medium;
        return BiometricSeverity.low;
      case BiometricType.bodyTemperature:
        if (value < 35.0 || value > 39.0) return BiometricSeverity.high;
        if (value < 36.1 || value > 37.5) return BiometricSeverity.medium;
        return BiometricSeverity.low;
      default:
        return BiometricSeverity.low;
    }
  }

  /// Get formatted display value
  String get displayValue {
    switch (type) {
      case BiometricType.heartRate:
      case BiometricType.restingHeartRate:
        return '${value.toInt()} bpm';
      case BiometricType.steps:
        return value.toInt().toString();
      case BiometricType.activeCalories:
      case BiometricType.totalCalories:
        return '${value.toInt()} cal';
      case BiometricType.distance:
        return '${(value / 1000).toStringAsFixed(2)} km';
      case BiometricType.bloodOxygen:
        return '${value.toStringAsFixed(1)}%';
      case BiometricType.bodyTemperature:
      case BiometricType.skinTemperature:
        return '${value.toStringAsFixed(1)}°C';
      case BiometricType.weight:
        return '${value.toStringAsFixed(1)} kg';
      case BiometricType.bodyFat:
        return '${value.toStringAsFixed(1)}%';
      case BiometricType.stressLevel:
        return '${value.toInt()}/100';
      default:
        return '${value.toStringAsFixed(1)} $unit';
    }
  }

  /// Get trend compared to previous value
  BiometricTrend getTrend(BiometricData? previousData) {
    if (previousData == null || previousData.type != type) {
      return BiometricTrend.noChange;
    }
    
    final difference = value - previousData.value;
    final percentChange = (difference / previousData.value) * 100;
    
    if (percentChange.abs() < 2.0) return BiometricTrend.noChange;
    
    return percentChange > 0 ? BiometricTrend.increasing : BiometricTrend.decreasing;
  }

  /// Get recommended action based on value
  String? get recommendedAction {
    if (isWithinNormalRange) return null;
    
    switch (type) {
      case BiometricType.heartRate:
        if (value > 120) return 'Consider rest and relaxation techniques';
        if (value < 50) return 'Consult healthcare provider if symptomatic';
        return null;
      case BiometricType.bloodOxygen:
        if (value < 95) return 'Ensure good ventilation and consider medical consultation';
        return null;
      case BiometricType.bodyTemperature:
        if (value > 38.0) return 'Monitor for fever symptoms and stay hydrated';
        if (value < 35.5) return 'Keep warm and monitor body temperature';
        return null;
      case BiometricType.stressLevel:
        if (value > 80) return 'Practice stress reduction techniques';
        return null;
      default:
        return null;
    }
  }

  factory BiometricData.fromJson(Map<String, dynamic> json) => _$BiometricDataFromJson(json);
  Map<String, dynamic> toJson() => _$BiometricDataToJson(this);

  BiometricData copyWith({
    String? dataId,
    BiometricType? type,
    double? value,
    String? unit,
    DateTime? timestamp,
    String? source,
    String? deviceId,
    double? confidence,
    Map<String, dynamic>? metadata,
    DataQuality? quality,
    bool? isProcessed,
  }) {
    return BiometricData(
      dataId: dataId ?? this.dataId,
      type: type ?? this.type,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      timestamp: timestamp ?? this.timestamp,
      source: source ?? this.source,
      deviceId: deviceId ?? this.deviceId,
      confidence: confidence ?? this.confidence,
      metadata: metadata ?? this.metadata,
      quality: quality ?? this.quality,
      isProcessed: isProcessed ?? this.isProcessed,
    );
  }
}

/// Biometric Data Types
enum BiometricType {
  // Cardiovascular
  heartRate('Heart Rate', 'bpm', '❤️', BiometricCategory.cardiovascular),
  restingHeartRate('Resting Heart Rate', 'bpm', '💗', BiometricCategory.cardiovascular),
  heartRateVariability('Heart Rate Variability', 'ms', '📈', BiometricCategory.cardiovascular),
  bloodPressureSystolic('Blood Pressure (Systolic)', 'mmHg', '🩸', BiometricCategory.cardiovascular),
  bloodPressureDiastolic('Blood Pressure (Diastolic)', 'mmHg', '🩸', BiometricCategory.cardiovascular),
  bloodOxygen('Blood Oxygen', '%', '🫁', BiometricCategory.respiratory),
  
  // Activity & Fitness
  steps('Steps', 'steps', '👣', BiometricCategory.activity),
  distance('Distance', 'm', '📏', BiometricCategory.activity),
  activeCalories('Active Calories', 'cal', '🔥', BiometricCategory.activity),
  totalCalories('Total Calories', 'cal', '⚡', BiometricCategory.activity),
  activeMinutes('Active Minutes', 'min', '⏱️', BiometricCategory.activity),
  exerciseMinutes('Exercise Minutes', 'min', '🏃‍♀️', BiometricCategory.activity),
  
  // Body Composition
  weight('Weight', 'kg', '⚖️', BiometricCategory.bodyComposition),
  bodyFat('Body Fat', '%', '🧠', BiometricCategory.bodyComposition),
  muscleMass('Muscle Mass', 'kg', '💪', BiometricCategory.bodyComposition),
  boneDensity('Bone Density', 'g/cm²', '🦴', BiometricCategory.bodyComposition),
  waterPercentage('Water Percentage', '%', '💧', BiometricCategory.bodyComposition),
  
  // Temperature & Environment
  bodyTemperature('Body Temperature', '°C', '🌡️', BiometricCategory.temperature),
  skinTemperature('Skin Temperature', '°C', '🔥', BiometricCategory.temperature),
  basalBodyTemperature('Basal Body Temperature', '°C', '🌡️', BiometricCategory.reproductive),
  
  // Sleep & Recovery
  sleep('Sleep Duration', 'h', '😴', BiometricCategory.sleep),
  sleepQuality('Sleep Quality', 'score', '⭐', BiometricCategory.sleep),
  deepSleep('Deep Sleep', 'h', '🌙', BiometricCategory.sleep),
  remSleep('REM Sleep', 'h', '💭', BiometricCategory.sleep),
  sleepEfficiency('Sleep Efficiency', '%', '📊', BiometricCategory.sleep),
  
  // Stress & Mental Health
  stressLevel('Stress Level', 'score', '😰', BiometricCategory.stress),
  mentalWellbeing('Mental Wellbeing', 'score', '🧠', BiometricCategory.stress),
  mindfulnessMinutes('Mindfulness Minutes', 'min', '🧘‍♀️', BiometricCategory.stress),
  
  // Respiratory
  respiratoryRate('Respiratory Rate', '/min', '🫁', BiometricCategory.respiratory),
  vo2Max('VO₂ Max', 'ml/kg/min', '🏃‍♂️', BiometricCategory.respiratory),
  
  // Reproductive Health
  menstrualFlow('Menstrual Flow', 'level', '🩸', BiometricCategory.reproductive),
  ovulationTest('Ovulation Test', 'result', '🥚', BiometricCategory.reproductive),
  cervicalMucus('Cervical Mucus', 'type', '💧', BiometricCategory.reproductive),
  
  // General Health
  activity('General Activity', 'score', '📊', BiometricCategory.activity),
  readiness('Readiness Score', 'score', '⚡', BiometricCategory.general),
  recovery('Recovery Score', 'score', '🔄', BiometricCategory.general),
  energy('Energy Level', 'score', '⚡', BiometricCategory.general);

  const BiometricType(this.displayName, this.unit, this.icon, this.category);

  final String displayName;
  final String unit;
  final String icon;
  final BiometricCategory category;

  /// Get normal range for this biometric type
  (double min, double max)? get normalRange {
    switch (this) {
      case BiometricType.heartRate:
        return (60.0, 100.0);
      case BiometricType.restingHeartRate:
        return (50.0, 90.0);
      case BiometricType.bloodOxygen:
        return (95.0, 100.0);
      case BiometricType.bodyTemperature:
        return (36.1, 37.2);
      case BiometricType.bloodPressureSystolic:
        return (90.0, 120.0);
      case BiometricType.bloodPressureDiastolic:
        return (60.0, 80.0);
      case BiometricType.respiratoryRate:
        return (12.0, 20.0);
      case BiometricType.bodyFat:
        return (10.0, 25.0); // Varies by gender and age
      default:
        return null;
    }
  }

  /// Get priority level for monitoring
  BiometricPriority get priority {
    switch (category) {
      case BiometricCategory.cardiovascular:
      case BiometricCategory.respiratory:
        return BiometricPriority.high;
      case BiometricCategory.reproductive:
      case BiometricCategory.temperature:
        return BiometricPriority.high;
      case BiometricCategory.sleep:
      case BiometricCategory.stress:
        return BiometricPriority.medium;
      case BiometricCategory.activity:
      case BiometricCategory.bodyComposition:
        return BiometricPriority.medium;
      case BiometricCategory.general:
        return BiometricPriority.low;
    }
  }
}

/// Biometric Categories
enum BiometricCategory {
  cardiovascular('Cardiovascular', '❤️'),
  respiratory('Respiratory', '🫁'),
  activity('Activity & Fitness', '🏃‍♀️'),
  bodyComposition('Body Composition', '⚖️'),
  temperature('Temperature', '🌡️'),
  sleep('Sleep & Recovery', '😴'),
  stress('Stress & Mental Health', '🧠'),
  reproductive('Reproductive Health', '🌸'),
  general('General Health', '💗');

  const BiometricCategory(this.displayName, this.icon);

  final String displayName;
  final String icon;
}

/// Biometric Priority Levels
enum BiometricPriority {
  low('Low', 1),
  medium('Medium', 2),
  high('High', 3),
  critical('Critical', 4);

  const BiometricPriority(this.displayName, this.level);

  final String displayName;
  final int level;
}

/// Data Quality Levels
enum DataQuality {
  excellent('Excellent', 'High accuracy, validated data', 0xFF4CAF50),
  good('Good', 'Reliable data with minor variations', 0xFF8BC34A),
  fair('Fair', 'Acceptable data with some uncertainty', 0xFFFF9800),
  poor('Poor', 'Low confidence data, use with caution', 0xFFF44336);

  const DataQuality(this.displayName, this.description, this.color);

  final String displayName;
  final String description;
  final int color;
}

/// Biometric Severity Levels
enum BiometricSeverity {
  normal('Normal', 'Within healthy range', 0xFF4CAF50),
  low('Low Risk', 'Minor deviation from normal', 0xFF8BC34A),
  medium('Medium Risk', 'Moderate concern, monitor closely', 0xFFFF9800),
  high('High Risk', 'Significant concern, seek medical advice', 0xFFF44336);

  const BiometricSeverity(this.displayName, this.description, this.color);

  final String displayName;
  final String description;
  final int color;

  String get icon {
    switch (this) {
      case BiometricSeverity.normal:
        return '✅';
      case BiometricSeverity.low:
        return '⚠️';
      case BiometricSeverity.medium:
        return '🔶';
      case BiometricSeverity.high:
        return '🚨';
    }
  }
}

/// Biometric Trend Directions
enum BiometricTrend {
  decreasing('Decreasing', '📉', 0xFFF44336),
  noChange('Stable', '➡️', 0xFF9E9E9E),
  increasing('Increasing', '📈', 0xFF4CAF50);

  const BiometricTrend(this.displayName, this.icon, this.color);

  final String displayName;
  final String icon;
  final int color;
}

/// Biometric Data Collection
@JsonSerializable()
class BiometricDataCollection {
  final String collectionId;
  final DateTime timestamp;
  final List<BiometricData> dataPoints;
  final String source;
  final Map<String, dynamic> metadata;

  BiometricDataCollection({
    required this.collectionId,
    required this.timestamp,
    required this.dataPoints,
    required this.source,
    this.metadata = const {},
  });

  /// Get data points by type
  List<BiometricData> getDataByType(BiometricType type) {
    return dataPoints.where((data) => data.type == type).toList();
  }

  /// Get data points by category
  List<BiometricData> getDataByCategory(BiometricCategory category) {
    return dataPoints.where((data) => data.type.category == category).toList();
  }

  /// Get average value for a biometric type
  double? getAverageValue(BiometricType type) {
    final typeData = getDataByType(type);
    if (typeData.isEmpty) return null;
    
    return typeData.map((d) => d.value).reduce((a, b) => a + b) / typeData.length;
  }

  /// Get data quality summary
  Map<DataQuality, int> getQualitySummary() {
    final summary = <DataQuality, int>{};
    for (final quality in DataQuality.values) {
      summary[quality] = dataPoints.where((d) => d.quality == quality).length;
    }
    return summary;
  }

  factory BiometricDataCollection.fromJson(Map<String, dynamic> json) => 
      _$BiometricDataCollectionFromJson(json);
  Map<String, dynamic> toJson() => _$BiometricDataCollectionToJson(this);
}

/// Biometric Data Summary
@JsonSerializable()
class BiometricDataSummary {
  final DateTime date;
  final Map<BiometricType, double> averageValues;
  final Map<BiometricType, double> minValues;
  final Map<BiometricType, double> maxValues;
  final Map<BiometricType, int> dataPointCounts;
  final double overallHealthScore;

  BiometricDataSummary({
    required this.date,
    required this.averageValues,
    required this.minValues,
    required this.maxValues,
    required this.dataPointCounts,
    required this.overallHealthScore,
  });

  /// Get summary for specific biometric type
  BiometricTypeSummary? getSummaryForType(BiometricType type) {
    if (!averageValues.containsKey(type)) return null;
    
    return BiometricTypeSummary(
      type: type,
      average: averageValues[type]!,
      minimum: minValues[type]!,
      maximum: maxValues[type]!,
      dataPoints: dataPointCounts[type]!,
    );
  }

  factory BiometricDataSummary.fromJson(Map<String, dynamic> json) => 
      _$BiometricDataSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$BiometricDataSummaryToJson(this);
}

/// Biometric Type Summary
class BiometricTypeSummary {
  final BiometricType type;
  final double average;
  final double minimum;
  final double maximum;
  final int dataPoints;

  BiometricTypeSummary({
    required this.type,
    required this.average,
    required this.minimum,
    required this.maximum,
    required this.dataPoints,
  });

  /// Get variability (max - min)
  double get variability => maximum - minimum;

  /// Check if values are consistent (low variability)
  bool get isConsistent => variability < (average * 0.1);
}
