import 'package:flutter/foundation.dart';

/// Model for daily tracking data including symptoms, mood, flow, etc.
@immutable
class DailyTrackingData {
  final DateTime date;
  final int? flowIntensity; // FlowIntensity enum index: 0-5
  final int? mood; // 1-5 scale
  final int? energy; // 1-5 scale
  final int? pain; // 1-5 scale
  final bool moodObserved;
  final bool energyObserved;
  final bool painObserved;
  final double? sleepHours;
  final List<String> symptoms;
  final Map<String, double> symptomSeverity;
  final Map<String, double> painAreas;
  final List<String> medications;
  final String? notes;
  final bool isPeriodDay;
  final bool isOvulationDay;
  final Map<String, dynamic>? customFields;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DailyTrackingData({
    required this.date,
    this.flowIntensity,
    this.mood,
    this.energy,
    this.pain,
    this.moodObserved = false,
    this.energyObserved = false,
    this.painObserved = false,
    this.sleepHours,
    this.symptoms = const [],
    this.symptomSeverity = const {},
    this.painAreas = const {},
    this.medications = const [],
    this.notes,
    this.isPeriodDay = false,
    this.isOvulationDay = false,
    this.customFields,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy of this DailyTrackingData with the given fields replaced
  DailyTrackingData copyWith({
    DateTime? date,
    int? flowIntensity,
    int? mood,
    int? energy,
    int? pain,
    bool? moodObserved,
    bool? energyObserved,
    bool? painObserved,
    double? sleepHours,
    List<String>? symptoms,
    Map<String, double>? symptomSeverity,
    Map<String, double>? painAreas,
    List<String>? medications,
    String? notes,
    bool? isPeriodDay,
    bool? isOvulationDay,
    Map<String, dynamic>? customFields,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyTrackingData(
      date: date ?? this.date,
      flowIntensity: flowIntensity ?? this.flowIntensity,
      mood: mood ?? this.mood,
      energy: energy ?? this.energy,
      pain: pain ?? this.pain,
      moodObserved: moodObserved ?? this.moodObserved,
      energyObserved: energyObserved ?? this.energyObserved,
      painObserved: painObserved ?? this.painObserved,
      sleepHours: sleepHours ?? this.sleepHours,
      symptoms: symptoms ?? this.symptoms,
      symptomSeverity: symptomSeverity ?? this.symptomSeverity,
      painAreas: painAreas ?? this.painAreas,
      medications: medications ?? this.medications,
      notes: notes ?? this.notes,
      isPeriodDay: isPeriodDay ?? this.isPeriodDay,
      isOvulationDay: isOvulationDay ?? this.isOvulationDay,
      customFields: customFields ?? this.customFields,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts this DailyTrackingData to a Map
  Map<String, dynamic> toMap() {
    return {
      'date': date.millisecondsSinceEpoch,
      'flowIntensity': flowIntensity,
      'mood': mood,
      'energy': energy,
      'pain': pain,
      'moodObserved': moodObserved,
      'energyObserved': energyObserved,
      'painObserved': painObserved,
      'sleepHours': sleepHours,
      'symptoms': symptoms,
      'symptomSeverity': symptomSeverity,
      'painAreas': painAreas,
      'medications': medications,
      'notes': notes,
      'isPeriodDay': isPeriodDay,
      'isOvulationDay': isOvulationDay,
      'customFields': customFields,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Creates a DailyTrackingData from a Map
  factory DailyTrackingData.fromMap(Map<String, dynamic> map) {
    return DailyTrackingData(
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      flowIntensity: map['flowIntensity'] as int?,
      mood: map['mood'] as int?,
      energy: map['energy'] as int?,
      pain: map['pain'] as int?,
      moodObserved: map['moodObserved'] as bool? ?? false,
      energyObserved: map['energyObserved'] as bool? ?? false,
      painObserved: map['painObserved'] as bool? ?? false,
      sleepHours: map['sleepHours'] as double?,
      symptoms: List<String>.from(map['symptoms'] as List? ?? []),
      symptomSeverity: Map<String, double>.from(
        (map['symptomSeverity'] as Map?) ?? const <String, double>{},
      ),
      painAreas: Map<String, double>.from(
        (map['painAreas'] as Map?) ?? const <String, double>{},
      ),
      medications: List<String>.from(map['medications'] as List? ?? []),
      notes: map['notes'] as String?,
      isPeriodDay: map['isPeriodDay'] as bool? ?? false,
      isOvulationDay: map['isOvulationDay'] as bool? ?? false,
      customFields: map['customFields'] as Map<String, dynamic>?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  /// Converts this DailyTrackingData to a JSON string
  String toJson() => toMap().toString();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyTrackingData &&
        other.date == date &&
        other.flowIntensity == flowIntensity &&
        other.mood == mood &&
        other.energy == energy &&
        other.pain == pain &&
        other.moodObserved == moodObserved &&
        other.energyObserved == energyObserved &&
        other.painObserved == painObserved &&
        other.sleepHours == sleepHours &&
        listEquals(other.symptoms, symptoms) &&
        mapEquals(other.symptomSeverity, symptomSeverity) &&
        mapEquals(other.painAreas, painAreas) &&
        listEquals(other.medications, medications) &&
        other.notes == notes &&
        other.isPeriodDay == isPeriodDay &&
        other.isOvulationDay == isOvulationDay &&
        mapEquals(other.customFields, customFields) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return date.hashCode ^
        flowIntensity.hashCode ^
        mood.hashCode ^
        energy.hashCode ^
        pain.hashCode ^
        moodObserved.hashCode ^
        energyObserved.hashCode ^
        painObserved.hashCode ^
        sleepHours.hashCode ^
        symptoms.hashCode ^
        symptomSeverity.hashCode ^
        painAreas.hashCode ^
        medications.hashCode ^
        notes.hashCode ^
        isPeriodDay.hashCode ^
        isOvulationDay.hashCode ^
        customFields.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'DailyTrackingData(date: $date, flowIntensity: $flowIntensity, mood: $mood, energy: $energy, pain: $pain, moodObserved: $moodObserved, energyObserved: $energyObserved, painObserved: $painObserved, sleepHours: $sleepHours, symptoms: $symptoms, medications: $medications, notes: $notes, isPeriodDay: $isPeriodDay, isOvulationDay: $isOvulationDay, customFields: $customFields, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
