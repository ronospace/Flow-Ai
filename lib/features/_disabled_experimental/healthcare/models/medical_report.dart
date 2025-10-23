/// Medical Report model for healthcare integration
class MedicalReport {
  final String reportId;
  final String userId;
  final String? providerId;
  final ReportType type;
  final String title;
  final DateTime generatedDate;
  final DateRange dateRange;
  List<ReportSection> sections;
  List<ClinicalInsight> insights;
  List<MedicalRecommendation> recommendations;
  final String? notes;
  final bool isShared;
  final List<String> sharedWith;

  MedicalReport({
    required this.reportId,
    required this.userId,
    this.providerId,
    required this.type,
    required this.title,
    required this.generatedDate,
    required this.dateRange,
    this.sections = const [],
    this.insights = const [],
    this.recommendations = const [],
    this.notes,
    this.isShared = false,
    this.sharedWith = const [],
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'reportId': reportId,
      'userId': userId,
      'providerId': providerId,
      'type': type.name,
      'title': title,
      'generatedDate': generatedDate.toIso8601String(),
      'dateRange': dateRange.toJson(),
      'sections': sections.map((s) => s.toJson()).toList(),
      'insights': insights.map((i) => i.toJson()).toList(),
      'recommendations': recommendations.map((r) => r.toJson()).toList(),
      'notes': notes,
      'isShared': isShared,
      'sharedWith': sharedWith,
    };
  }

  /// Create from JSON
  factory MedicalReport.fromJson(Map<String, dynamic> json) {
    return MedicalReport(
      reportId: json['reportId'] as String,
      userId: json['userId'] as String,
      providerId: json['providerId'] as String?,
      type: ReportType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ReportType.comprehensive,
      ),
      title: json['title'] as String,
      generatedDate: DateTime.parse(json['generatedDate'] as String),
      dateRange: DateRange.fromJson(json['dateRange'] as Map<String, dynamic>),
      sections: (json['sections'] as List)
          .map((s) => ReportSection.fromJson(s as Map<String, dynamic>))
          .toList(),
      insights: (json['insights'] as List)
          .map((i) => ClinicalInsight.fromJson(i as Map<String, dynamic>))
          .toList(),
      recommendations: (json['recommendations'] as List)
          .map((r) => MedicalRecommendation.fromJson(r as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      isShared: json['isShared'] as bool? ?? false,
      sharedWith: List<String>.from(json['sharedWith'] as List? ?? []),
    );
  }

  /// Copy with updated fields
  MedicalReport copyWith({
    String? reportId,
    String? userId,
    String? providerId,
    ReportType? type,
    String? title,
    DateTime? generatedDate,
    DateRange? dateRange,
    List<ReportSection>? sections,
    List<ClinicalInsight>? insights,
    List<MedicalRecommendation>? recommendations,
    String? notes,
    bool? isShared,
    List<String>? sharedWith,
  }) {
    return MedicalReport(
      reportId: reportId ?? this.reportId,
      userId: userId ?? this.userId,
      providerId: providerId ?? this.providerId,
      type: type ?? this.type,
      title: title ?? this.title,
      generatedDate: generatedDate ?? this.generatedDate,
      dateRange: dateRange ?? this.dateRange,
      sections: sections ?? this.sections,
      insights: insights ?? this.insights,
      recommendations: recommendations ?? this.recommendations,
      notes: notes ?? this.notes,
      isShared: isShared ?? this.isShared,
      sharedWith: sharedWith ?? this.sharedWith,
    );
  }
}

/// Types of medical reports
enum ReportType {
  comprehensive,
  cycleAnalysis,
  symptomSummary,
  fertilityAssessment,
}

/// Report section
class ReportSection {
  final String title;
  final String content;
  final ReportSectionType type;
  final Map<String, dynamic>? chartData;
  final List<String>? images;

  const ReportSection({
    required this.title,
    required this.content,
    required this.type,
    this.chartData,
    this.images,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'type': type.name,
      'chartData': chartData,
      'images': images,
    };
  }

  /// Create from JSON
  factory ReportSection.fromJson(Map<String, dynamic> json) {
    return ReportSection(
      title: json['title'] as String,
      content: json['content'] as String,
      type: ReportSectionType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ReportSectionType.general,
      ),
      chartData: json['chartData'] as Map<String, dynamic>?,
      images: json['images'] != null 
          ? List<String>.from(json['images'] as List)
          : null,
    );
  }
}

/// Types of report sections
enum ReportSectionType {
  patientInfo,
  cycleAnalysis,
  symptoms,
  fertility,
  medications,
  lifestyle,
  general,
}

/// Clinical insight
class ClinicalInsight {
  final String category;
  final String insight;
  final InsightSeverity severity;
  final double confidence;
  final List<String>? supportingData;
  final DateTime timestamp;

  ClinicalInsight({
    required this.category,
    required this.insight,
    required this.severity,
    required this.confidence,
    this.supportingData,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'insight': insight,
      'severity': severity.name,
      'confidence': confidence,
      'supportingData': supportingData,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create from JSON
  factory ClinicalInsight.fromJson(Map<String, dynamic> json) {
    return ClinicalInsight(
      category: json['category'] as String,
      insight: json['insight'] as String,
      severity: InsightSeverity.values.firstWhere(
        (s) => s.name == json['severity'],
        orElse: () => InsightSeverity.informational,
      ),
      confidence: (json['confidence'] as num).toDouble(),
      supportingData: json['supportingData'] != null
          ? List<String>.from(json['supportingData'] as List)
          : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// Insight severity levels
enum InsightSeverity {
  informational,
  warning,
  critical,
}

/// Medical recommendation
class MedicalRecommendation {
  final String category;
  final String recommendation;
  final RecommendationPriority priority;
  final String? evidence;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime timestamp;

  MedicalRecommendation({
    required this.category,
    required this.recommendation,
    required this.priority,
    this.evidence,
    this.dueDate,
    this.isCompleted = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'recommendation': recommendation,
      'priority': priority.name,
      'evidence': evidence,
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create from JSON
  factory MedicalRecommendation.fromJson(Map<String, dynamic> json) {
    return MedicalRecommendation(
      category: json['category'] as String,
      recommendation: json['recommendation'] as String,
      priority: RecommendationPriority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => RecommendationPriority.medium,
      ),
      evidence: json['evidence'] as String?,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Copy with updated fields
  MedicalRecommendation copyWith({
    String? category,
    String? recommendation,
    RecommendationPriority? priority,
    String? evidence,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? timestamp,
  }) {
    return MedicalRecommendation(
      category: category ?? this.category,
      recommendation: recommendation ?? this.recommendation,
      priority: priority ?? this.priority,
      evidence: evidence ?? this.evidence,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// Recommendation priority levels
enum RecommendationPriority {
  low,
  medium,
  high,
  urgent,
}

/// Date range for reports
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({
    required this.start,
    required this.end,
  });

  /// Duration of the range
  Duration get duration => end.difference(start);

  /// Number of days in range
  int get days => duration.inDays;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    };
  }

  /// Create from JSON
  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
    );
  }

  @override
  String toString() {
    return 'DateRange(start: $start, end: $end, days: $days)';
  }
}
