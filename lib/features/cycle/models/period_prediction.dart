import 'package:json_annotation/json_annotation.dart';
import 'cycle_data.dart';

part 'period_prediction.g.dart';

/// Period prediction model
@JsonSerializable()
class PeriodPrediction {
  final String id;
  final String userId;
  final DateTime predictedStartDate;
  final DateTime predictedEndDate;
  final double confidence;
  final int predictedLength;
  final FlowIntensity predictedIntensity;
  final List<String> predictedSymptoms;
  final DateTime createdAt;
  final DateTime? actualStartDate;
  final Map<String, dynamic> metadata;

  const PeriodPrediction({
    required this.id,
    required this.userId,
    required this.predictedStartDate,
    required this.predictedEndDate,
    required this.confidence,
    required this.predictedLength,
    this.predictedIntensity = FlowIntensity.medium,
    this.predictedSymptoms = const [],
    required this.createdAt,
    this.actualStartDate,
    this.metadata = const {},
  });

  /// Check if prediction was accurate
  bool get isAccurate {
    if (actualStartDate == null) return false;
    final daysDifference = actualStartDate!.difference(predictedStartDate).inDays.abs();
    return daysDifference <= 2; // Within 2 days is considered accurate
  }

  /// Get days until predicted period
  int get daysUntilPredicted {
    return predictedStartDate.difference(DateTime.now()).inDays;
  }

  /// Check if prediction is for current cycle
  bool get isCurrentCyclePrediction {
    final now = DateTime.now();
    return predictedStartDate.isAfter(now) && 
           predictedStartDate.difference(now).inDays <= 35;
  }

  factory PeriodPrediction.fromJson(Map<String, dynamic> json) => 
      _$PeriodPredictionFromJson(json);
  
  Map<String, dynamic> toJson() => _$PeriodPredictionToJson(this);

  /// Create a copy with updated fields
  PeriodPrediction copyWith({
    String? id,
    String? userId,
    DateTime? predictedStartDate,
    DateTime? predictedEndDate,
    double? confidence,
    int? predictedLength,
    FlowIntensity? predictedIntensity,
    List<String>? predictedSymptoms,
    DateTime? createdAt,
    DateTime? actualStartDate,
    Map<String, dynamic>? metadata,
  }) {
    return PeriodPrediction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      predictedStartDate: predictedStartDate ?? this.predictedStartDate,
      predictedEndDate: predictedEndDate ?? this.predictedEndDate,
      confidence: confidence ?? this.confidence,
      predictedLength: predictedLength ?? this.predictedLength,
      predictedIntensity: predictedIntensity ?? this.predictedIntensity,
      predictedSymptoms: predictedSymptoms ?? this.predictedSymptoms,
      createdAt: createdAt ?? this.createdAt,
      actualStartDate: actualStartDate ?? this.actualStartDate,
      metadata: metadata ?? this.metadata,
    );
  }
}
