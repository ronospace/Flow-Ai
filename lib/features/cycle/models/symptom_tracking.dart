import 'package:json_annotation/json_annotation.dart';

part 'symptom_tracking.g.dart';

/// Symptom types
enum SymptomType {
  physical,
  emotional,
  mental,
  energy,
  sleep,
  appetite,
  pain,
  skin,
  digestive,
  other
}

/// Symptom intensity levels
enum SymptomIntensity {
  none,
  mild,
  moderate,
  severe,
  extreme
}

/// Mood categories
enum MoodCategory {
  happy,
  sad,
  anxious,
  irritable,
  calm,
  energetic,
  tired,
  confident,
  emotional,
  neutral
}

/// Energy types
enum EnergyType {
  physical,
  mental,
  emotional,
  overall
}

/// Trend direction
enum TrendDirection {
  increasing,
  decreasing,
  stable,
  fluctuating
}

/// Symptom entry
@JsonSerializable()
class SymptomEntry {
  final String symptomName;
  final SymptomType type;
  final SymptomIntensity intensity;
  final String? notes;
  final DateTime timestamp;

  const SymptomEntry({
    required this.symptomName,
    required this.type,
    required this.intensity,
    this.notes,
    required this.timestamp,
  });

  factory SymptomEntry.fromJson(Map<String, dynamic> json) => _$SymptomEntryFromJson(json);
  Map<String, dynamic> toJson() => _$SymptomEntryToJson(this);
}

/// Symptom tracking model
@JsonSerializable()
class SymptomTracking {
  final String id;
  final String userId;
  final DateTime date;
  final Map<String, SymptomEntry> symptoms;
  final Map<MoodCategory, double> moodScores;
  final Map<EnergyType, double> energyLevels;
  final double? overallWellbeing;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SymptomTracking({
    required this.id,
    required this.userId,
    required this.date,
    required this.symptoms,
    required this.moodScores,
    required this.energyLevels,
    this.overallWellbeing,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SymptomTracking.fromJson(Map<String, dynamic> json) => _$SymptomTrackingFromJson(json);
  Map<String, dynamic> toJson() => _$SymptomTrackingToJson(this);

  /// Get symptoms by type
  List<SymptomEntry> getSymptomsByType(SymptomType type) {
    return symptoms.values.where((symptom) => symptom.type == type).toList();
  }

  /// Get average mood score
  double get averageMoodScore {
    if (moodScores.isEmpty) return 0.0;
    return moodScores.values.reduce((a, b) => a + b) / moodScores.length;
  }

  /// Get average energy level
  double get averageEnergyLevel {
    if (energyLevels.isEmpty) return 0.0;
    return energyLevels.values.reduce((a, b) => a + b) / energyLevels.length;
  }

  /// Check if has severe symptoms
  bool get hasSevereSymptoms {
    return symptoms.values.any((symptom) => 
        symptom.intensity == SymptomIntensity.severe || 
        symptom.intensity == SymptomIntensity.extreme);
  }

  /// Create a copy with updated fields
  SymptomTracking copyWith({
    String? id,
    String? userId,
    DateTime? date,
    Map<String, SymptomEntry>? symptoms,
    Map<MoodCategory, double>? moodScores,
    Map<EnergyType, double>? energyLevels,
    double? overallWellbeing,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SymptomTracking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      symptoms: symptoms ?? this.symptoms,
      moodScores: moodScores ?? this.moodScores,
      energyLevels: energyLevels ?? this.energyLevels,
      overallWellbeing: overallWellbeing ?? this.overallWellbeing,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
