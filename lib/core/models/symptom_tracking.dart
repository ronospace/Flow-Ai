import 'dart:convert';

/// Symptom tracking model for comprehensive health monitoring
class SymptomTracking {
  final String id;
  final String userId;
  final DateTime recordedAt;
  final Map<String, SymptomEntry> symptoms;
  final double? overallSeverity;
  final String? notes;
  final List<String> triggers;
  final Map<String, dynamic>? medications;
  final SymptomContext context;
  final DateTime? lastUpdated;

  SymptomTracking({
    required this.id,
    required this.userId,
    required this.recordedAt,
    required this.symptoms,
    this.overallSeverity,
    this.notes,
    this.triggers = const [],
    this.medications,
    required this.context,
    this.lastUpdated,
  });

  /// Create empty symptom tracking entry
  factory SymptomTracking.empty({
    required String userId,
    DateTime? recordedAt,
  }) {
    final now = recordedAt ?? DateTime.now();
    return SymptomTracking(
      id: 'symptom_${now.millisecondsSinceEpoch}',
      userId: userId,
      recordedAt: now,
      symptoms: {},
      context: SymptomContext.dailyTracking,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'recordedAt': recordedAt.toIso8601String(),
      'symptoms': symptoms.map((key, value) => MapEntry(key, value.toJson())),
      'overallSeverity': overallSeverity,
      'notes': notes,
      'triggers': triggers,
      'medications': medications,
      'context': context.name,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory SymptomTracking.fromJson(Map<String, dynamic> json) {
    final symptomsMap = <String, SymptomEntry>{};
    if (json['symptoms'] != null) {
      (json['symptoms'] as Map<String, dynamic>).forEach((key, value) {
        symptomsMap[key] = SymptomEntry.fromJson(value);
      });
    }

    return SymptomTracking(
      id: json['id'],
      userId: json['userId'],
      recordedAt: DateTime.parse(json['recordedAt']),
      symptoms: symptomsMap,
      overallSeverity: json['overallSeverity']?.toDouble(),
      notes: json['notes'],
      triggers: List<String>.from(json['triggers'] ?? []),
      medications: json['medications'],
      context: SymptomContext.values.firstWhere(
        (ctx) => ctx.name == json['context'],
        orElse: () => SymptomContext.dailyTracking,
      ),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
    );
  }

  /// Add or update a symptom
  SymptomTracking addSymptom(String symptomType, SymptomEntry entry) {
    final updatedSymptoms = Map<String, SymptomEntry>.from(symptoms);
    updatedSymptoms[symptomType] = entry;

    return copyWith(
      symptoms: updatedSymptoms,
      lastUpdated: DateTime.now(),
      overallSeverity: _calculateOverallSeverity(updatedSymptoms),
    );
  }

  /// Remove a symptom
  SymptomTracking removeSymptom(String symptomType) {
    final updatedSymptoms = Map<String, SymptomEntry>.from(symptoms);
    updatedSymptoms.remove(symptomType);

    return copyWith(
      symptoms: updatedSymptoms,
      lastUpdated: DateTime.now(),
      overallSeverity: _calculateOverallSeverity(updatedSymptoms),
    );
  }

  /// Calculate overall severity from all symptoms
  double? _calculateOverallSeverity(Map<String, SymptomEntry> symptoms) {
    if (symptoms.isEmpty) return null;

    final severities = symptoms.values
        .map((entry) => entry.severity)
        .where((severity) => severity != null)
        .toList();

    if (severities.isEmpty) return null;

    final total = severities.reduce((a, b) => a! + b!)!;
    return total / severities.length;
  }

  /// Get symptoms by category
  Map<String, SymptomEntry> getSymptomsByCategory(SymptomCategory category) {
    return Map.fromEntries(
      symptoms.entries.where(
        (entry) => getSymptomCategory(entry.key) == category,
      ),
    );
  }

  /// Get all active symptoms (with severity > 0)
  Map<String, SymptomEntry> get activeSymptoms {
    return Map.fromEntries(
      symptoms.entries.where(
        (entry) => entry.value.severity != null && entry.value.severity! > 0,
      ),
    );
  }

  /// Copy with new values
  SymptomTracking copyWith({
    String? id,
    String? userId,
    DateTime? recordedAt,
    Map<String, SymptomEntry>? symptoms,
    double? overallSeverity,
    String? notes,
    List<String>? triggers,
    Map<String, dynamic>? medications,
    SymptomContext? context,
    DateTime? lastUpdated,
  }) {
    return SymptomTracking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      recordedAt: recordedAt ?? this.recordedAt,
      symptoms: symptoms ?? this.symptoms,
      overallSeverity: overallSeverity ?? this.overallSeverity,
      notes: notes ?? this.notes,
      triggers: triggers ?? this.triggers,
      medications: medications ?? this.medications,
      context: context ?? this.context,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() {
    return 'SymptomTracking(id: $id, recordedAt: $recordedAt, activeSymptoms: ${activeSymptoms.length})';
  }
}

/// Individual symptom entry
class SymptomEntry {
  final double? severity; // 1-10 scale
  final String? description;
  final List<String> tags;
  final DateTime? onsetTime;
  final Duration? duration;
  final Map<String, dynamic>? additionalData;

  SymptomEntry({
    this.severity,
    this.description,
    this.tags = const [],
    this.onsetTime,
    this.duration,
    this.additionalData,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'severity': severity,
      'description': description,
      'tags': tags,
      'onsetTime': onsetTime?.toIso8601String(),
      'duration': duration?.inSeconds,
      'additionalData': additionalData,
    };
  }

  /// Create from JSON
  factory SymptomEntry.fromJson(Map<String, dynamic> json) {
    return SymptomEntry(
      severity: json['severity']?.toDouble(),
      description: json['description'],
      tags: List<String>.from(json['tags'] ?? []),
      onsetTime: json['onsetTime'] != null
          ? DateTime.parse(json['onsetTime'])
          : null,
      duration: json['duration'] != null
          ? Duration(seconds: json['duration'])
          : null,
      additionalData: json['additionalData'],
    );
  }

  /// Copy with new values
  SymptomEntry copyWith({
    double? severity,
    String? description,
    List<String>? tags,
    DateTime? onsetTime,
    Duration? duration,
    Map<String, dynamic>? additionalData,
  }) {
    return SymptomEntry(
      severity: severity ?? this.severity,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      onsetTime: onsetTime ?? this.onsetTime,
      duration: duration ?? this.duration,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  String toString() {
    return 'SymptomEntry(severity: $severity, description: $description)';
  }
}

/// Symptom context enum
enum SymptomContext {
  dailyTracking,
  periodTracking,
  pregnancyTracking,
  menopauseTracking,
  clinicalAssessment,
  emergencyReport,
}

/// Symptom categories
enum SymptomCategory {
  menstrual,
  mood,
  physical,
  digestive,
  skin,
  sleep,
  pain,
  energy,
  cognitive,
  reproductive,
}

/// Common symptoms with their categories
const Map<String, SymptomCategory> symptomCategories = {
  // Menstrual
  'cramps': SymptomCategory.menstrual,
  'heavy_bleeding': SymptomCategory.menstrual,
  'light_bleeding': SymptomCategory.menstrual,
  'spotting': SymptomCategory.menstrual,
  'clots': SymptomCategory.menstrual,
  'irregular_flow': SymptomCategory.menstrual,

  // Mood
  'anxiety': SymptomCategory.mood,
  'depression': SymptomCategory.mood,
  'irritability': SymptomCategory.mood,
  'mood_swings': SymptomCategory.mood,
  'emotional_sensitivity': SymptomCategory.mood,
  'stress': SymptomCategory.mood,

  // Physical
  'headache': SymptomCategory.physical,
  'migraine': SymptomCategory.physical,
  'back_pain': SymptomCategory.physical,
  'breast_tenderness': SymptomCategory.physical,
  'bloating': SymptomCategory.physical,
  'weight_gain': SymptomCategory.physical,
  'nausea': SymptomCategory.physical,

  // Digestive
  'constipation': SymptomCategory.digestive,
  'diarrhea': SymptomCategory.digestive,
  'indigestion': SymptomCategory.digestive,
  'food_cravings': SymptomCategory.digestive,
  'appetite_changes': SymptomCategory.digestive,

  // Skin
  'acne': SymptomCategory.skin,
  'dry_skin': SymptomCategory.skin,
  'oily_skin': SymptomCategory.skin,
  'rash': SymptomCategory.skin,
  'sensitivity': SymptomCategory.skin,

  // Sleep
  'insomnia': SymptomCategory.sleep,
  'vivid_dreams': SymptomCategory.sleep,
  'nightmares': SymptomCategory.sleep,
  'sleep_disturbances': SymptomCategory.sleep,
  'oversleeping': SymptomCategory.sleep,

  // Pain
  'pelvic_pain': SymptomCategory.pain,
  'joint_pain': SymptomCategory.pain,
  'muscle_aches': SymptomCategory.pain,
  'leg_pain': SymptomCategory.pain,

  // Energy
  'fatigue': SymptomCategory.energy,
  'low_energy': SymptomCategory.energy,
  'hyperenergy': SymptomCategory.energy,
  'weakness': SymptomCategory.energy,

  // Cognitive
  'brain_fog': SymptomCategory.cognitive,
  'memory_issues': SymptomCategory.cognitive,
  'concentration_difficulties': SymptomCategory.cognitive,
  'confusion': SymptomCategory.cognitive,

  // Reproductive
  'discharge_changes': SymptomCategory.reproductive,
  'vaginal_dryness': SymptomCategory.reproductive,
  'libido_changes': SymptomCategory.reproductive,
  'ovulation_pain': SymptomCategory.reproductive,
};

/// Get symptom category
SymptomCategory getSymptomCategory(String symptomType) {
  return symptomCategories[symptomType] ?? SymptomCategory.physical;
}

/// Severity levels with descriptions
enum SeverityLevel {
  none,
  mild,
  moderate,
  severe,
  extreme,
}

/// Extension for severity level
extension SeverityLevelExtension on SeverityLevel {
  double get numericValue {
    switch (this) {
      case SeverityLevel.none:
        return 0.0;
      case SeverityLevel.mild:
        return 2.5;
      case SeverityLevel.moderate:
        return 5.0;
      case SeverityLevel.severe:
        return 7.5;
      case SeverityLevel.extreme:
        return 10.0;
    }
  }

  String get description {
    switch (this) {
      case SeverityLevel.none:
        return 'None';
      case SeverityLevel.mild:
        return 'Mild - noticeable but not disruptive';
      case SeverityLevel.moderate:
        return 'Moderate - somewhat disruptive to daily activities';
      case SeverityLevel.severe:
        return 'Severe - significantly disruptive';
      case SeverityLevel.extreme:
        return 'Extreme - completely disruptive';
    }
  }

  static SeverityLevel fromNumericValue(double value) {
    if (value <= 1) return SeverityLevel.none;
    if (value <= 3) return SeverityLevel.mild;
    if (value <= 6) return SeverityLevel.moderate;
    if (value <= 8) return SeverityLevel.severe;
    return SeverityLevel.extreme;
  }
}
