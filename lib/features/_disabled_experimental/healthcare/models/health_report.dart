/// Health Report Model
class HealthReport {
  final String id;
  final String providerId;
  final String providerName;
  final String patientId;
  final DateTime reportDate;
  final DateTime startDate;
  final DateTime endDate;
  final bool includeSymptoms;
  final bool includeMoodData;
  final bool includePredictions;
  final Map<String, dynamic> data;
  final ReportFormat format;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime? sharedAt;

  const HealthReport({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.patientId,
    required this.reportDate,
    required this.startDate,
    required this.endDate,
    this.includeSymptoms = true,
    this.includeMoodData = true,
    this.includePredictions = false,
    required this.data,
    this.format = ReportFormat.comprehensive,
    this.status = ReportStatus.draft,
    required this.createdAt,
    this.sharedAt,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'providerId': providerId,
      'providerName': providerName,
      'patientId': patientId,
      'reportDate': reportDate.toIso8601String(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'includeSymptoms': includeSymptoms,
      'includeMoodData': includeMoodData,
      'includePredictions': includePredictions,
      'data': data,
      'format': format.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'sharedAt': sharedAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory HealthReport.fromJson(Map<String, dynamic> json) {
    return HealthReport(
      id: json['id'],
      providerId: json['providerId'],
      providerName: json['providerName'],
      patientId: json['patientId'],
      reportDate: DateTime.parse(json['reportDate']),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      includeSymptoms: json['includeSymptoms'] ?? true,
      includeMoodData: json['includeMoodData'] ?? true,
      includePredictions: json['includePredictions'] ?? false,
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      format: ReportFormat.values.firstWhere(
        (f) => f.name == json['format'],
        orElse: () => ReportFormat.comprehensive,
      ),
      status: ReportStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => ReportStatus.draft,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      sharedAt: json['sharedAt'] != null
          ? DateTime.parse(json['sharedAt'])
          : null,
    );
  }

  /// Generate summary text
  String get summary {
    final period = endDate.difference(startDate).inDays;
    final cyclesAnalyzed = data['cycles_analyzed'] ?? 0;
    final avgCycleLength = data['average_cycle_length'] ?? 'N/A';
    
    return 'Health report covering $period days with $cyclesAnalyzed cycles analyzed. '
           'Average cycle length: $avgCycleLength days.';
  }

  /// Get report sections based on included data
  List<String> get sections {
    final sections = <String>['Overview', 'Summary'];
    
    if (includeSymptoms) sections.add('Symptoms Analysis');
    if (includeMoodData) sections.add('Mood Patterns');
    if (includePredictions) sections.add('AI Predictions');
    
    sections.addAll(['Recommendations', 'Notes']);
    return sections;
  }

  /// Copy with new values
  HealthReport copyWith({
    String? id,
    String? providerId,
    String? providerName,
    String? patientId,
    DateTime? reportDate,
    DateTime? startDate,
    DateTime? endDate,
    bool? includeSymptoms,
    bool? includeMoodData,
    bool? includePredictions,
    Map<String, dynamic>? data,
    ReportFormat? format,
    ReportStatus? status,
    DateTime? createdAt,
    DateTime? sharedAt,
  }) {
    return HealthReport(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      patientId: patientId ?? this.patientId,
      reportDate: reportDate ?? this.reportDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      includeSymptoms: includeSymptoms ?? this.includeSymptoms,
      includeMoodData: includeMoodData ?? this.includeMoodData,
      includePredictions: includePredictions ?? this.includePredictions,
      data: data ?? this.data,
      format: format ?? this.format,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      sharedAt: sharedAt ?? this.sharedAt,
    );
  }

  @override
  String toString() {
    return 'HealthReport(id: $id, provider: $providerName, status: ${status.displayName})';
  }
}

/// Report Format Types
enum ReportFormat {
  comprehensive,
  summary,
  symptoms,
  predictions,
  custom,
}

/// Extension for Report Format
extension ReportFormatExtension on ReportFormat {
  String get displayName {
    switch (this) {
      case ReportFormat.comprehensive:
        return 'Comprehensive Report';
      case ReportFormat.summary:
        return 'Summary Report';
      case ReportFormat.symptoms:
        return 'Symptoms Focus';
      case ReportFormat.predictions:
        return 'Predictions Report';
      case ReportFormat.custom:
        return 'Custom Report';
    }
  }

  String get description {
    switch (this) {
      case ReportFormat.comprehensive:
        return 'Complete health analysis with all available data';
      case ReportFormat.summary:
        return 'Key insights and trends summary';
      case ReportFormat.symptoms:
        return 'Detailed symptom tracking and patterns';
      case ReportFormat.predictions:
        return 'AI-powered predictions and forecasts';
      case ReportFormat.custom:
        return 'Customized report based on specific needs';
    }
  }
}

/// Report Status Types
enum ReportStatus {
  draft,
  reviewed,
  shared,
  archived,
}

/// Extension for Report Status
extension ReportStatusExtension on ReportStatus {
  String get displayName {
    switch (this) {
      case ReportStatus.draft:
        return 'Draft';
      case ReportStatus.reviewed:
        return 'Reviewed';
      case ReportStatus.shared:
        return 'Shared';
      case ReportStatus.archived:
        return 'Archived';
    }
  }

  String get description {
    switch (this) {
      case ReportStatus.draft:
        return 'Report is being prepared';
      case ReportStatus.reviewed:
        return 'Report has been reviewed by user';
      case ReportStatus.shared:
        return 'Report has been shared with provider';
      case ReportStatus.archived:
        return 'Report has been archived';
    }
  }

  String get emoji {
    switch (this) {
      case ReportStatus.draft:
        return '📝';
      case ReportStatus.reviewed:
        return '✅';
      case ReportStatus.shared:
        return '📤';
      case ReportStatus.archived:
        return '📁';
    }
  }
}
