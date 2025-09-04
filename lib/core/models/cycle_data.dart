/// Cycle data model for menstrual cycle tracking and analytics
class CycleData {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime? endDate;
  final int? cycleLength;
  final int? periodLength;
  final FlowIntensity averageFlow;
  final Map<DateTime, DayData> dailyData;
  final List<String> symptoms;
  final List<String> moods;
  final CyclePhase currentPhase;
  final DateTime? ovulationDate;
  final DateTime? expectedNextPeriod;
  final Map<String, dynamic>? notes;
  final double? fertilityScore;
  final List<CycleEvent> events;
  final DateTime createdAt;
  final DateTime? lastUpdated;
  final bool isComplete;
  final CycleQuality quality;
  
  // Additional properties for AI engine compatibility
  final double? mood;        // 1-5 scale
  final double? energy;      // 1-5 scale
  final double? pain;        // 1-5 scale
  final FlowIntensity? flowIntensity;

  CycleData({
    required this.id,
    required this.userId,
    required this.startDate,
    this.endDate,
    this.cycleLength,
    this.periodLength,
    this.averageFlow = FlowIntensity.medium,
    required this.dailyData,
    this.symptoms = const [],
    this.moods = const [],
    this.currentPhase = CyclePhase.menstrual,
    this.ovulationDate,
    this.expectedNextPeriod,
    this.notes,
    this.fertilityScore,
    this.events = const [],
    required this.createdAt,
    this.lastUpdated,
    this.isComplete = false,
    this.quality = CycleQuality.regular,
    this.mood,
    this.energy,
    this.pain,
    this.flowIntensity,
  });

  /// Create a new cycle
  factory CycleData.newCycle({
    required String userId,
    required DateTime startDate,
  }) {
    final now = DateTime.now();
    return CycleData(
      id: 'cycle_${now.millisecondsSinceEpoch}',
      userId: userId,
      startDate: startDate,
      dailyData: {},
      createdAt: now,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'cycleLength': cycleLength,
      'periodLength': periodLength,
      'averageFlow': averageFlow.name,
      'dailyData': dailyData.map(
        (key, value) => MapEntry(key.toIso8601String(), value.toJson()),
      ),
      'symptoms': symptoms,
      'moods': moods,
      'currentPhase': currentPhase.name,
      'ovulationDate': ovulationDate?.toIso8601String(),
      'expectedNextPeriod': expectedNextPeriod?.toIso8601String(),
      'notes': notes,
      'fertilityScore': fertilityScore,
      'events': events.map((event) => event.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      'isComplete': isComplete,
      'quality': quality.name,
      'mood': mood,
      'energy': energy,
      'pain': pain,
      'flowIntensity': flowIntensity?.name,
    };
  }

  /// Create from JSON
  static CycleData fromJson(Map<String, dynamic> json) {
    final dailyDataMap = <DateTime, DayData>{};
    if (json['dailyData'] != null) {
      (json['dailyData'] as Map<String, dynamic>).forEach((key, value) {
        dailyDataMap[DateTime.parse(key)] = DayData.fromJson(value);
      });
    }

    final eventsList = <CycleEvent>[];
    if (json['events'] != null) {
      eventsList.addAll(
        (json['events'] as List)
            .map((event) => CycleEvent.fromJson(event))
            .toList(),
      );
    }

    return CycleData(
      id: json['id'],
      userId: json['userId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate'])
          : null,
      cycleLength: json['cycleLength'],
      periodLength: json['periodLength'],
      averageFlow: FlowIntensity.values.firstWhere(
        (flow) => flow.name == json['averageFlow'],
        orElse: () => FlowIntensity.medium,
      ),
      dailyData: dailyDataMap,
      symptoms: List<String>.from(json['symptoms'] ?? []),
      moods: List<String>.from(json['moods'] ?? []),
      currentPhase: CyclePhase.values.firstWhere(
        (phase) => phase.name == json['currentPhase'],
        orElse: () => CyclePhase.menstrual,
      ),
      ovulationDate: json['ovulationDate'] != null
          ? DateTime.parse(json['ovulationDate'])
          : null,
      expectedNextPeriod: json['expectedNextPeriod'] != null
          ? DateTime.parse(json['expectedNextPeriod'])
          : null,
      notes: json['notes'],
      fertilityScore: json['fertilityScore']?.toDouble(),
      events: eventsList,
      createdAt: DateTime.parse(json['createdAt']),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
      isComplete: json['isComplete'] ?? false,
      quality: CycleQuality.values.firstWhere(
        (quality) => quality.name == json['quality'],
        orElse: () => CycleQuality.regular,
      ),
      mood: json['mood']?.toDouble(),
      energy: json['energy']?.toDouble(),
      pain: json['pain']?.toDouble(),
      flowIntensity: json['flowIntensity'] != null
          ? FlowIntensity.values.firstWhere(
              (flow) => flow.name == json['flowIntensity'],
              orElse: () => FlowIntensity.none,
            )
          : null,
    );
  }

  /// Add daily data entry
  CycleData addDayData(DateTime date, DayData dayData) {
    final updatedDailyData = Map<DateTime, DayData>.from(dailyData);
    updatedDailyData[date] = dayData;

    return copyWith(
      dailyData: updatedDailyData,
      lastUpdated: DateTime.now(),
    );
  }

  /// Update cycle phase
  CycleData updatePhase(CyclePhase phase) {
    return copyWith(
      currentPhase: phase,
      lastUpdated: DateTime.now(),
    );
  }

  /// Mark cycle as complete
  CycleData complete(DateTime endDate) {
    final length = endDate.difference(startDate).inDays + 1;
    final periodDays = dailyData.values
        .where((day) => day.hasFlow)
        .length;

    return copyWith(
      endDate: endDate,
      cycleLength: length,
      periodLength: periodDays,
      isComplete: true,
      lastUpdated: DateTime.now(),
      quality: _calculateQuality(length, periodDays),
    );
  }

  /// Calculate cycle quality based on length and regularity
  CycleQuality _calculateQuality(int length, int periodDays) {
    if (length < 21 || length > 35) {
      return CycleQuality.irregular;
    }
    if (periodDays < 3 || periodDays > 7) {
      return CycleQuality.irregular;
    }
    return CycleQuality.regular;
  }

  /// Get period days
  List<DateTime> get periodDays {
    return dailyData.entries
        .where((entry) => entry.value.hasFlow)
        .map((entry) => entry.key)
        .toList()
        ..sort();
  }

  /// Get fertile window days
  List<DateTime> get fertileWindow {
    if (ovulationDate == null) return [];
    
    final fertile = <DateTime>[];
    for (int i = -5; i <= 1; i++) {
      fertile.add(ovulationDate!.add(Duration(days: i)));
    }
    return fertile;
  }

  /// Get cycle length in days
  int get length {
    if (cycleLength != null) {
      return cycleLength!;
    }
    if (endDate != null) {
      return endDate!.difference(startDate).inDays + 1;
    }
    // Return current length for ongoing cycle
    return DateTime.now().difference(startDate).inDays + 1;
  }

  /// Check if cycle is completed (alias for isComplete)
  bool get isCompleted => isComplete;

  /// Get actual cycle length (alias for length)
  int get actualLength => length;

  /// Get days in current cycle
  List<DateTime> get cycleDays {
    final days = <DateTime>[];
    final end = endDate ?? DateTime.now();
    DateTime current = startDate;
    
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }
    
    return days;
  }

  /// Calculate average cycle statistics
  CycleStatistics get statistics {
    return CycleStatistics(
      averageLength: cycleLength?.toDouble(),
      averagePeriodLength: periodLength?.toDouble(),
      averageFlow: averageFlow,
      commonSymptoms: _getMostCommonSymptoms(),
      commonMoods: _getMostCommonMoods(),
      regularityScore: _calculateRegularityScore(),
    );
  }

  List<String> _getMostCommonSymptoms() {
    final symptomCounts = <String, int>{};
    for (final day in dailyData.values) {
      for (final symptom in day.symptoms) {
        symptomCounts[symptom] = (symptomCounts[symptom] ?? 0) + 1;
      }
    }
    
    final sorted = symptomCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(5).map((e) => e.key).toList();
  }

  List<String> _getMostCommonMoods() {
    final moodCounts = <String, int>{};
    for (final day in dailyData.values) {
      for (final mood in day.moods) {
        moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
      }
    }
    
    final sorted = moodCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(3).map((e) => e.key).toList();
  }

  double _calculateRegularityScore() {
    if (cycleLength == null) return 0.0;
    
    // Regular cycles are 21-35 days
    if (cycleLength! >= 21 && cycleLength! <= 35) {
      return 1.0;
    } else if (cycleLength! >= 18 && cycleLength! <= 38) {
      return 0.7;
    } else {
      return 0.3;
    }
  }

  /// Copy with new values
  CycleData copyWith({
    String? id,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int? cycleLength,
    int? periodLength,
    FlowIntensity? averageFlow,
    Map<DateTime, DayData>? dailyData,
    List<String>? symptoms,
    List<String>? moods,
    CyclePhase? currentPhase,
    DateTime? ovulationDate,
    DateTime? expectedNextPeriod,
    Map<String, dynamic>? notes,
    double? fertilityScore,
    List<CycleEvent>? events,
    DateTime? createdAt,
    DateTime? lastUpdated,
    bool? isComplete,
    CycleQuality? quality,
    double? mood,
    double? energy,
    double? pain,
    FlowIntensity? flowIntensity,
  }) {
    return CycleData(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      cycleLength: cycleLength ?? this.cycleLength,
      periodLength: periodLength ?? this.periodLength,
      averageFlow: averageFlow ?? this.averageFlow,
      dailyData: dailyData ?? this.dailyData,
      symptoms: symptoms ?? this.symptoms,
      moods: moods ?? this.moods,
      currentPhase: currentPhase ?? this.currentPhase,
      ovulationDate: ovulationDate ?? this.ovulationDate,
      expectedNextPeriod: expectedNextPeriod ?? this.expectedNextPeriod,
      notes: notes ?? this.notes,
      fertilityScore: fertilityScore ?? this.fertilityScore,
      events: events ?? this.events,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isComplete: isComplete ?? this.isComplete,
      quality: quality ?? this.quality,
      mood: mood ?? this.mood,
      energy: energy ?? this.energy,
      pain: pain ?? this.pain,
      flowIntensity: flowIntensity ?? this.flowIntensity,
    );
  }

  @override
  String toString() {
    return 'CycleData(id: $id, startDate: $startDate, phase: $currentPhase, complete: $isComplete)';
  }
}

/// Daily data within a cycle
class DayData {
  final DateTime date;
  final FlowIntensity? flowIntensity;
  final List<String> symptoms;
  final List<String> moods;
  final double? temperature;
  final String? cervicalMucus;
  final bool? isOvulation;
  final bool? isFertile;
  final String? notes;
  final Map<String, dynamic>? customData;

  DayData({
    required this.date,
    this.flowIntensity,
    this.symptoms = const [],
    this.moods = const [],
    this.temperature,
    this.cervicalMucus,
    this.isOvulation,
    this.isFertile,
    this.notes,
    this.customData,
  });

  /// Check if there's menstrual flow
  bool get hasFlow => flowIntensity != null && flowIntensity != FlowIntensity.none;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'flowIntensity': flowIntensity?.name,
      'symptoms': symptoms,
      'moods': moods,
      'temperature': temperature,
      'cervicalMucus': cervicalMucus,
      'isOvulation': isOvulation,
      'isFertile': isFertile,
      'notes': notes,
      'customData': customData,
    };
  }

  /// Create from JSON
  static DayData fromJson(Map<String, dynamic> json) {
    return DayData(
      date: DateTime.parse(json['date']),
      flowIntensity: json['flowIntensity'] != null
          ? FlowIntensity.values.firstWhere(
              (flow) => flow.name == json['flowIntensity'],
              orElse: () => FlowIntensity.none,
            )
          : null,
      symptoms: List<String>.from(json['symptoms'] ?? []),
      moods: List<String>.from(json['moods'] ?? []),
      temperature: json['temperature']?.toDouble(),
      cervicalMucus: json['cervicalMucus'],
      isOvulation: json['isOvulation'],
      isFertile: json['isFertile'],
      notes: json['notes'],
      customData: json['customData'],
    );
  }

  /// Copy with new values
  DayData copyWith({
    DateTime? date,
    FlowIntensity? flowIntensity,
    List<String>? symptoms,
    List<String>? moods,
    double? temperature,
    String? cervicalMucus,
    bool? isOvulation,
    bool? isFertile,
    String? notes,
    Map<String, dynamic>? customData,
  }) {
    return DayData(
      date: date ?? this.date,
      flowIntensity: flowIntensity ?? this.flowIntensity,
      symptoms: symptoms ?? this.symptoms,
      moods: moods ?? this.moods,
      temperature: temperature ?? this.temperature,
      cervicalMucus: cervicalMucus ?? this.cervicalMucus,
      isOvulation: isOvulation ?? this.isOvulation,
      isFertile: isFertile ?? this.isFertile,
      notes: notes ?? this.notes,
      customData: customData ?? this.customData,
    );
  }

  @override
  String toString() {
    return 'DayData(date: $date, flow: $flowIntensity, symptoms: ${symptoms.length})';
  }
}

/// Cycle event for tracking significant occurrences
class CycleEvent {
  final String id;
  final DateTime date;
  final CycleEventType type;
  final String title;
  final String? description;
  final Map<String, dynamic>? metadata;

  CycleEvent({
    required this.id,
    required this.date,
    required this.type,
    required this.title,
    this.description,
    this.metadata,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type.name,
      'title': title,
      'description': description,
      'metadata': metadata,
    };
  }

  /// Create from JSON
  static CycleEvent fromJson(Map<String, dynamic> json) {
    return CycleEvent(
      id: json['id'],
      date: DateTime.parse(json['date']),
      type: CycleEventType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => CycleEventType.other,
      ),
      title: json['title'],
      description: json['description'],
      metadata: json['metadata'],
    );
  }
}

/// Cycle statistics
class CycleStatistics {
  final double? averageLength;
  final double? averagePeriodLength;
  final FlowIntensity averageFlow;
  final List<String> commonSymptoms;
  final List<String> commonMoods;
  final double regularityScore;

  CycleStatistics({
    this.averageLength,
    this.averagePeriodLength,
    this.averageFlow = FlowIntensity.medium,
    this.commonSymptoms = const [],
    this.commonMoods = const [],
    this.regularityScore = 0.0,
  });
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

/// Cycle phases
enum CyclePhase {
  menstrual,
  follicular,
  ovulatory,
  luteal,
  unknown,
}

/// Extension for cycle phase
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
      case CyclePhase.unknown:
        return 'Unknown';
    }
  }

  String get description {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Menstrual phase - menstruation occurs';
      case CyclePhase.follicular:
        return 'Follicular phase - follicles develop';
      case CyclePhase.ovulatory:
        return 'Ovulatory phase - ovulation occurs';
      case CyclePhase.luteal:
        return 'Luteal phase - preparation for next cycle';
      case CyclePhase.unknown:
        return 'Phase cannot be determined';
    }
  }
}

/// Cycle quality assessment
enum CycleQuality {
  regular,
  irregular,
  long,
  short,
  anovulatory,
}

/// Extension for cycle quality
extension CycleQualityExtension on CycleQuality {
  String get displayName {
    switch (this) {
      case CycleQuality.regular:
        return 'Regular';
      case CycleQuality.irregular:
        return 'Irregular';
      case CycleQuality.long:
        return 'Long Cycle';
      case CycleQuality.short:
        return 'Short Cycle';
      case CycleQuality.anovulatory:
        return 'Anovulatory';
    }
  }

  String get description {
    switch (this) {
      case CycleQuality.regular:
        return 'Cycle length is within normal range (21-35 days)';
      case CycleQuality.irregular:
        return 'Cycle length varies significantly or is outside normal range';
      case CycleQuality.long:
        return 'Cycle length is consistently longer than 35 days';
      case CycleQuality.short:
        return 'Cycle length is consistently shorter than 21 days';
      case CycleQuality.anovulatory:
        return 'Cycle without ovulation detected';
    }
  }
}

/// Cycle event types
enum CycleEventType {
  periodStart,
  periodEnd,
  ovulation,
  medication,
  contraceptive,
  pregnancy,
  other,
}

/// Extension for cycle event type
extension CycleEventTypeExtension on CycleEventType {
  String get displayName {
    switch (this) {
      case CycleEventType.periodStart:
        return 'Period Started';
      case CycleEventType.periodEnd:
        return 'Period Ended';
      case CycleEventType.ovulation:
        return 'Ovulation';
      case CycleEventType.medication:
        return 'Medication';
      case CycleEventType.contraceptive:
        return 'Contraceptive';
      case CycleEventType.pregnancy:
        return 'Pregnancy';
      case CycleEventType.other:
        return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case CycleEventType.periodStart:
        return '🔴';
      case CycleEventType.periodEnd:
        return '✅';
      case CycleEventType.ovulation:
        return '🥚';
      case CycleEventType.medication:
        return '💊';
      case CycleEventType.contraceptive:
        return '🛡️';
      case CycleEventType.pregnancy:
        return '🤰';
      case CycleEventType.other:
        return '📝';
    }
  }
}

