/// Clinical Data Export model for healthcare integration
class ClinicalDataExport {
  final String exportId;
  final String userId;
  final DateTime generatedDate;
  final DateRange dateRange;
  final ClinicalDataFormat format;
  final List<String> includedDataTypes;
  Map<String, dynamic>? data;
  int? fileSize;
  final String? description;
  final bool isEncrypted;
  final DateTime? expiryDate;
  final List<String> sharedWith;

  ClinicalDataExport({
    required this.exportId,
    required this.userId,
    required this.generatedDate,
    required this.dateRange,
    required this.format,
    required this.includedDataTypes,
    this.data,
    this.fileSize,
    this.description,
    this.isEncrypted = true,
    this.expiryDate,
    this.sharedWith = const [],
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'exportId': exportId,
      'userId': userId,
      'generatedDate': generatedDate.toIso8601String(),
      'dateRange': dateRange.toJson(),
      'format': format.name,
      'includedDataTypes': includedDataTypes,
      'data': data,
      'fileSize': fileSize,
      'description': description,
      'isEncrypted': isEncrypted,
      'expiryDate': expiryDate?.toIso8601String(),
      'sharedWith': sharedWith,
    };
  }

  /// Create from JSON
  factory ClinicalDataExport.fromJson(Map<String, dynamic> json) {
    return ClinicalDataExport(
      exportId: json['exportId'] as String,
      userId: json['userId'] as String,
      generatedDate: DateTime.parse(json['generatedDate'] as String),
      dateRange: DateRange.fromJson(json['dateRange'] as Map<String, dynamic>),
      format: ClinicalDataFormat.values.firstWhere(
        (f) => f.name == json['format'],
        orElse: () => ClinicalDataFormat.fhir,
      ),
      includedDataTypes: List<String>.from(json['includedDataTypes'] as List),
      data: json['data'] as Map<String, dynamic>?,
      fileSize: json['fileSize'] as int?,
      description: json['description'] as String?,
      isEncrypted: json['isEncrypted'] as bool? ?? true,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      sharedWith: List<String>.from(json['sharedWith'] as List? ?? []),
    );
  }

  /// Copy with updated fields
  ClinicalDataExport copyWith({
    String? exportId,
    String? userId,
    DateTime? generatedDate,
    DateRange? dateRange,
    ClinicalDataFormat? format,
    List<String>? includedDataTypes,
    Map<String, dynamic>? data,
    int? fileSize,
    String? description,
    bool? isEncrypted,
    DateTime? expiryDate,
    List<String>? sharedWith,
  }) {
    return ClinicalDataExport(
      exportId: exportId ?? this.exportId,
      userId: userId ?? this.userId,
      generatedDate: generatedDate ?? this.generatedDate,
      dateRange: dateRange ?? this.dateRange,
      format: format ?? this.format,
      includedDataTypes: includedDataTypes ?? this.includedDataTypes,
      data: data ?? this.data,
      fileSize: fileSize ?? this.fileSize,
      description: description ?? this.description,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      expiryDate: expiryDate ?? this.expiryDate,
      sharedWith: sharedWith ?? this.sharedWith,
    );
  }

  /// Get formatted file size
  String get formattedFileSize {
    if (fileSize == null) return 'Unknown';
    
    if (fileSize! < 1024) {
      return '${fileSize!} B';
    } else if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    } else if (fileSize! < 1024 * 1024 * 1024) {
      return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(fileSize! / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Check if export is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  /// Check if export has data
  bool get hasData => data != null && data!.isNotEmpty;

  /// Get summary of included data types
  String get dataTypesSummary {
    if (includedDataTypes.isEmpty) return 'No data types selected';
    
    if (includedDataTypes.length <= 3) {
      return includedDataTypes.join(', ');
    }
    
    return '${includedDataTypes.take(3).join(', ')} and ${includedDataTypes.length - 3} more';
  }
}

/// Supported clinical data export formats
enum ClinicalDataFormat {
  fhir,
  hl7,
  csv,
  pdf,
  json,
}

extension ClinicalDataFormatExtension on ClinicalDataFormat {
  String get displayName {
    switch (this) {
      case ClinicalDataFormat.fhir:
        return 'FHIR (JSON)';
      case ClinicalDataFormat.hl7:
        return 'HL7 v2';
      case ClinicalDataFormat.csv:
        return 'CSV (Spreadsheet)';
      case ClinicalDataFormat.pdf:
        return 'PDF Report';
      case ClinicalDataFormat.json:
        return 'JSON';
    }
  }

  String get description {
    switch (this) {
      case ClinicalDataFormat.fhir:
        return 'Healthcare industry standard format for interoperability';
      case ClinicalDataFormat.hl7:
        return 'Health Level 7 messaging standard';
      case ClinicalDataFormat.csv:
        return 'Comma-separated values for spreadsheet applications';
      case ClinicalDataFormat.pdf:
        return 'Human-readable report in PDF format';
      case ClinicalDataFormat.json:
        return 'JavaScript Object Notation for easy parsing';
    }
  }

  String get fileExtension {
    switch (this) {
      case ClinicalDataFormat.fhir:
        return 'json';
      case ClinicalDataFormat.hl7:
        return 'hl7';
      case ClinicalDataFormat.csv:
        return 'csv';
      case ClinicalDataFormat.pdf:
        return 'pdf';
      case ClinicalDataFormat.json:
        return 'json';
    }
  }

  String get mimeType {
    switch (this) {
      case ClinicalDataFormat.fhir:
        return 'application/fhir+json';
      case ClinicalDataFormat.hl7:
        return 'application/hl7-v2';
      case ClinicalDataFormat.csv:
        return 'text/csv';
      case ClinicalDataFormat.pdf:
        return 'application/pdf';
      case ClinicalDataFormat.json:
        return 'application/json';
    }
  }

  bool get isStructured {
    switch (this) {
      case ClinicalDataFormat.fhir:
      case ClinicalDataFormat.hl7:
      case ClinicalDataFormat.json:
        return true;
      case ClinicalDataFormat.csv:
      case ClinicalDataFormat.pdf:
        return false;
    }
  }

  bool get isHumanReadable {
    switch (this) {
      case ClinicalDataFormat.pdf:
      case ClinicalDataFormat.csv:
        return true;
      case ClinicalDataFormat.fhir:
      case ClinicalDataFormat.hl7:
      case ClinicalDataFormat.json:
        return false;
    }
  }
}

/// Date range class (reused from medical_report.dart if needed)
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
