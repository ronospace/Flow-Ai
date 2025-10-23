
/// Period prediction model for AI-powered cycle forecasting
class PeriodPrediction {
  final String id;
  final String userId;
  final DateTime predictedStartDate;
  final DateTime? predictedEndDate;
  final int predictedLength;
  final double confidence;
  final List<String> factors;
  final FertileWindow? fertileWindow;
  final List<SymptomPrediction> symptomPredictions;
  final CyclePhase currentPhase;
  final int daysToNextPeriod;
  final DateTime generatedAt;
  final String aiModelVersion;
  final Map<String, dynamic>? additionalData;

  PeriodPrediction({
    required this.id,
    required this.userId,
    required this.predictedStartDate,
    this.predictedEndDate,
    required this.predictedLength,
    required this.confidence,
    required this.factors,
    this.fertileWindow,
    required this.symptomPredictions,
    required this.currentPhase,
    required this.daysToNextPeriod,
    DateTime? generatedAt,
    this.aiModelVersion = '1.0.0',
    this.additionalData,
  }) : generatedAt = generatedAt ?? DateTime.now();

  /// Create a default prediction when no data is available
  factory PeriodPrediction.defaultPrediction({
    required String userId,
    String? id,
  }) {
    final now = DateTime.now();
    final predictedStart = now.add(const Duration(days: 28));
    
    return PeriodPrediction(
      id: id ?? 'default_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      predictedStartDate: predictedStart,
      predictedEndDate: predictedStart.add(const Duration(days: 5)),
      predictedLength: 28,
      confidence: 0.5,
      factors: ['Default cycle pattern', 'Insufficient historical data'],
      fertileWindow: FertileWindow.defaultWindow(predictedStart),
      symptomPredictions: [],
      currentPhase: CyclePhase.follicular,
      daysToNextPeriod: 28,
      aiModelVersion: '1.0.0',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'predictedStartDate': predictedStartDate.toIso8601String(),
      'predictedEndDate': predictedEndDate?.toIso8601String(),
      'predictedLength': predictedLength,
      'confidence': confidence,
      'factors': factors,
      'fertileWindow': fertileWindow?.toJson(),
      'symptomPredictions': symptomPredictions.map((s) => s.toJson()).toList(),
      'currentPhase': currentPhase.name,
      'daysToNextPeriod': daysToNextPeriod,
      'generatedAt': generatedAt.toIso8601String(),
      'aiModelVersion': aiModelVersion,
      'additionalData': additionalData,
    };
  }

  /// Create from JSON
  factory PeriodPrediction.fromJson(Map<String, dynamic> json) {
    return PeriodPrediction(
      id: json['id'],
      userId: json['userId'],
      predictedStartDate: DateTime.parse(json['predictedStartDate']),
      predictedEndDate: json['predictedEndDate'] != null
          ? DateTime.parse(json['predictedEndDate'])
          : null,
      predictedLength: json['predictedLength'],
      confidence: json['confidence'],
      factors: List<String>.from(json['factors'] ?? []),
      fertileWindow: json['fertileWindow'] != null
          ? FertileWindow.fromJson(json['fertileWindow'])
          : null,
      symptomPredictions: (json['symptomPredictions'] as List? ?? [])
          .map((s) => SymptomPrediction.fromJson(s))
          .toList(),
      currentPhase: CyclePhase.values.firstWhere(
        (phase) => phase.name == json['currentPhase'],
        orElse: () => CyclePhase.follicular,
      ),
      daysToNextPeriod: json['daysToNextPeriod'],
      generatedAt: DateTime.parse(json['generatedAt']),
      aiModelVersion: json['aiModelVersion'] ?? '1.0.0',
      additionalData: json['additionalData'],
    );
  }

  /// Copy with new values
  PeriodPrediction copyWith({
    String? id,
    String? userId,
    DateTime? predictedStartDate,
    DateTime? predictedEndDate,
    int? predictedLength,
    double? confidence,
    List<String>? factors,
    FertileWindow? fertileWindow,
    List<SymptomPrediction>? symptomPredictions,
    CyclePhase? currentPhase,
    int? daysToNextPeriod,
    DateTime? generatedAt,
    String? aiModelVersion,
    Map<String, dynamic>? additionalData,
  }) {
    return PeriodPrediction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      predictedStartDate: predictedStartDate ?? this.predictedStartDate,
      predictedEndDate: predictedEndDate ?? this.predictedEndDate,
      predictedLength: predictedLength ?? this.predictedLength,
      confidence: confidence ?? this.confidence,
      factors: factors ?? this.factors,
      fertileWindow: fertileWindow ?? this.fertileWindow,
      symptomPredictions: symptomPredictions ?? this.symptomPredictions,
      currentPhase: currentPhase ?? this.currentPhase,
      daysToNextPeriod: daysToNextPeriod ?? this.daysToNextPeriod,
      generatedAt: generatedAt ?? this.generatedAt,
      aiModelVersion: aiModelVersion ?? this.aiModelVersion,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  String toString() {
    return 'PeriodPrediction(id: $id, predictedStartDate: $predictedStartDate, confidence: $confidence)';
  }
}

/// Fertile window prediction
class FertileWindow {
  final DateTime start;
  final DateTime end;
  final DateTime peak;
  final double confidence;

  FertileWindow({
    required this.start,
    required this.end,
    required this.peak,
    this.confidence = 0.8,
  });

  /// Create default fertile window
  factory FertileWindow.defaultWindow(DateTime cycleStart) {
    final ovulationDay = cycleStart.subtract(const Duration(days: 14));
    return FertileWindow(
      start: ovulationDay.subtract(const Duration(days: 5)),
      end: ovulationDay.add(const Duration(days: 2)),
      peak: ovulationDay,
      confidence: 0.6,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'peak': peak.toIso8601String(),
      'confidence': confidence,
    };
  }

  /// Create from JSON
  factory FertileWindow.fromJson(Map<String, dynamic> json) {
    return FertileWindow(
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
      peak: DateTime.parse(json['peak']),
      confidence: json['confidence'] ?? 0.8,
    );
  }

  /// Get fertility status for a given date
  FertilityStatus getStatusForDate(DateTime date) {
    if (date.isBefore(start)) {
      return FertilityStatus.low;
    } else if (date.isAfter(end)) {
      return FertilityStatus.low;
    } else if (date.isAtSameMomentAs(peak) ||
        (date.isAfter(peak.subtract(const Duration(days: 1))) &&
         date.isBefore(peak.add(const Duration(days: 2))))) {
      return FertilityStatus.peak;
    } else {
      return FertilityStatus.high;
    }
  }
}

/// Symptom prediction for upcoming cycle days
class SymptomPrediction {
  final String symptomType;
  final double likelihood;
  final String severity;
  final DateTime predictedDate;
  final String description;

  SymptomPrediction({
    required this.symptomType,
    required this.likelihood,
    required this.severity,
    required this.predictedDate,
    required this.description,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'symptomType': symptomType,
      'likelihood': likelihood,
      'severity': severity,
      'predictedDate': predictedDate.toIso8601String(),
      'description': description,
    };
  }

  /// Create from JSON
  factory SymptomPrediction.fromJson(Map<String, dynamic> json) {
    return SymptomPrediction(
      symptomType: json['symptomType'],
      likelihood: json['likelihood'],
      severity: json['severity'],
      predictedDate: DateTime.parse(json['predictedDate']),
      description: json['description'],
    );
  }
}

/// Cycle phases
enum CyclePhase {
  menstrual,
  follicular,
  ovulatory,
  luteal,
}

/// Fertility status
enum FertilityStatus {
  low,
  high,
  peak,
}

/// Extension methods for cycle phase
extension CyclePhaseExtension on CyclePhase {
  String get displayName {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Menstrual';
      case CyclePhase.follicular:
        return 'Follicular';
      case CyclePhase.ovulatory:
        return 'Ovulatory';
      case CyclePhase.luteal:
        return 'Luteal';
    }
  }

  String get description {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Period days - focus on rest and comfort';
      case CyclePhase.follicular:
        return 'Energy rising - great time to start new projects';
      case CyclePhase.ovulatory:
        return 'Peak fertility - highest energy and confidence';
      case CyclePhase.luteal:
        return 'Pre-menstrual phase - time for reflection';
    }
  }

  String get emoji {
    switch (this) {
      case CyclePhase.menstrual:
        return '🌙';
      case CyclePhase.follicular:
        return '🌱';
      case CyclePhase.ovulatory:
        return '🌸';
      case CyclePhase.luteal:
        return '🍂';
    }
  }
}
