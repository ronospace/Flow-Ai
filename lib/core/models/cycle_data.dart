class CycleData {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final int length; // in days
  final FlowIntensity flowIntensity;
  final List<String> symptoms;
  final double? mood; // 1-5 scale
  final double? energy; // 1-5 scale
  final double? pain; // 1-5 scale
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CycleData({
    required this.id,
    required this.startDate,
    this.endDate,
    required this.length,
    this.flowIntensity = FlowIntensity.medium,
    this.symptoms = const [],
    this.mood,
    this.energy,
    this.pain,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCompleted => endDate != null;
  
  int get actualLength => endDate != null 
      ? endDate!.difference(startDate).inDays + 1 
      : length;

  CycleData copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    int? length,
    FlowIntensity? flowIntensity,
    List<String>? symptoms,
    double? mood,
    double? energy,
    double? pain,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CycleData(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      length: length ?? this.length,
      flowIntensity: flowIntensity ?? this.flowIntensity,
      symptoms: symptoms ?? this.symptoms,
      mood: mood ?? this.mood,
      energy: energy ?? this.energy,
      pain: pain ?? this.pain,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'length': length,
      'flowIntensity': flowIntensity.name,
      'symptoms': symptoms,
      'mood': mood,
      'energy': energy,
      'pain': pain,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static CycleData fromJson(Map<String, dynamic> json) {
    return CycleData(
      id: json['id'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      length: json['length'],
      flowIntensity: FlowIntensity.values.firstWhere(
        (e) => e.name == json['flowIntensity'],
        orElse: () => FlowIntensity.medium,
      ),
      symptoms: List<String>.from(json['symptoms'] ?? []),
      mood: json['mood']?.toDouble(),
      energy: json['energy']?.toDouble(),
      pain: json['pain']?.toDouble(),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

enum FlowIntensity {
  none,
  spotting,
  light,
  medium,
  heavy,
  veryHeavy;

  String get displayName {
    switch (this) {
      case FlowIntensity.none:
        return 'None';
      case FlowIntensity.spotting:
        return 'Spotting';
      case FlowIntensity.light:
        return 'Light';
      case FlowIntensity.medium:
        return 'Medium';
      case FlowIntensity.heavy:
        return 'Heavy';
      case FlowIntensity.veryHeavy:
        return 'Very Heavy';
    }
  }

  String get emoji {
    switch (this) {
      case FlowIntensity.none:
        return '✨';
      case FlowIntensity.spotting:
        return '💧';
      case FlowIntensity.light:
        return '🌸';
      case FlowIntensity.medium:
        return '🌺';
      case FlowIntensity.heavy:
        return '🌹';
      case FlowIntensity.veryHeavy:
        return '🔴';
    }
  }
}

class CyclePrediction {
  final DateTime predictedStartDate;
  final int predictedLength;
  final double confidence; // 0-1
  final FertileWindow fertileWindow;

  const CyclePrediction({
    required this.predictedStartDate,
    required this.predictedLength,
    required this.confidence,
    required this.fertileWindow,
  });

  DateTime get predictedEndDate => 
      predictedStartDate.add(Duration(days: predictedLength - 1));
  
  int get daysUntilStart => 
      predictedStartDate.difference(DateTime.now()).inDays;
}

// Enhanced prediction with additional forecasting capabilities
class EnhancedCyclePrediction extends CyclePrediction {
  final SymptomForecast symptomForecast;
  final MoodEnergyForecast moodEnergyForecast;
  final List<String> predictionFactors;
  
  const EnhancedCyclePrediction({
    required super.predictedStartDate,
    required super.predictedLength,
    required super.confidence,
    required super.fertileWindow,
    required this.symptomForecast,
    required this.moodEnergyForecast,
    required this.predictionFactors,
  });
}

// Cycle length prediction with detailed analysis
class CycleLengthPrediction {
  final int predictedLength;
  final double confidence;
  final List<String> factors;
  
  const CycleLengthPrediction(this.predictedLength, this.confidence, this.factors);
}

// Symptom forecasting
class SymptomForecast {
  final Map<String, double> predictedSymptoms; // symptom -> likelihood (0-1)
  final double confidence;
  
  const SymptomForecast({
    required this.predictedSymptoms,
    required this.confidence,
  });
  
  static SymptomForecast empty() => const SymptomForecast(
    predictedSymptoms: {},
    confidence: 0.0,
  );
  
  List<String> get likelySymptoms => predictedSymptoms.entries
      .where((e) => e.value >= 0.6)
      .map((e) => e.key)
      .toList();
}

// Mood and energy forecasting by cycle phase
class MoodEnergyForecast {
  final Map<String, double> moodByPhase; // phase -> predicted mood (1-5)
  final Map<String, double> energyByPhase; // phase -> predicted energy (1-5)
  final double confidence;
  
  const MoodEnergyForecast({
    required this.moodByPhase,
    required this.energyByPhase,
    required this.confidence,
  });
  
  static MoodEnergyForecast empty() => const MoodEnergyForecast(
    moodByPhase: {},
    energyByPhase: {},
    confidence: 0.0,
  );
}

// Cycle anomaly detection
enum CycleAnomalyType {
  lengthDeviation,
  unusualSymptom,
  moodDeviation,
  energyChange,
  flowChange,
}

enum AnomalySeverity {
  low,
  medium,
  high,
  critical,
}

class CycleAnomaly {
  final String cycleId;
  final CycleAnomalyType type;
  final AnomalySeverity severity;
  final String description;
  final DateTime detectedAt;
  
  const CycleAnomaly({
    required this.cycleId,
    required this.type,
    required this.severity,
    required this.description,
    required this.detectedAt,
  });
}

class FertileWindow {
  final DateTime start;
  final DateTime end;
  final DateTime peak; // ovulation day

  const FertileWindow({
    required this.start,
    required this.end,
    required this.peak,
  });

  int get lengthInDays => end.difference(start).inDays + 1;
  
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(start) && now.isBefore(end.add(const Duration(days: 1)));
  }
  
  int get daysUntilStart => start.difference(DateTime.now()).inDays;
  int get daysUntilPeak => peak.difference(DateTime.now()).inDays;
}

