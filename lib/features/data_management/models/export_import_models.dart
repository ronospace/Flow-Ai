// === ENUMS ===

enum DataFormat {
  json,
  csv,
  xml,
  zyraflowBackup,
  fhir,
}

enum DataType {
  cycle,
  symptoms,
  mood,
  biometrics,
  medications,
  appointments,
  notes,
  settings,
}

enum BackupFrequency {
  daily,
  weekly,
  monthly,
}

enum MergeStrategy {
  preserve,  // Keep existing data
  overwrite, // Replace existing data
  merge,     // Combine data intelligently
}

// === CONFIGURATION MODELS ===

class ExportConfig {
  final DataFormat format;
  final Set<DataType> dataTypes;
  final DateRange? dateRange;
  final bool includeMedia;
  final bool includeSettings;
  final bool encryptData;
  final bool compressData;
  final String? password;

  ExportConfig({
    required this.format,
    required this.dataTypes,
    this.dateRange,
    this.includeMedia = false,
    this.includeSettings = true,
    this.encryptData = false,
    this.compressData = true,
    this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'format': format.name,
      'data_types': dataTypes.map((e) => e.name).toList(),
      'date_range': dateRange?.toJson(),
      'include_media': includeMedia,
      'include_settings': includeSettings,
      'encrypt_data': encryptData,
      'compress_data': compressData,
      'has_password': password != null,
    };
  }

  factory ExportConfig.fromJson(Map<String, dynamic> json) {
    return ExportConfig(
      format: DataFormat.values.firstWhere((e) => e.name == json['format']),
      dataTypes: (json['data_types'] as List)
          .map((e) => DataType.values.firstWhere((dt) => dt.name == e))
          .toSet(),
      dateRange: json['date_range'] != null 
          ? DateRange.fromJson(json['date_range'])
          : null,
      includeMedia: json['include_media'] ?? false,
      includeSettings: json['include_settings'] ?? true,
      encryptData: json['encrypt_data'] ?? false,
      compressData: json['compress_data'] ?? true,
    );
  }
}

class ImportConfig {
  final MergeStrategy mergeStrategy;
  final bool validateData;
  final bool createBackupBeforeImport;
  final Set<DataType>? limitToDataTypes;

  ImportConfig({
    this.mergeStrategy = MergeStrategy.preserve,
    this.validateData = true,
    this.createBackupBeforeImport = true,
    this.limitToDataTypes,
  });

  Map<String, dynamic> toJson() {
    return {
      'merge_strategy': mergeStrategy.name,
      'validate_data': validateData,
      'create_backup_before_import': createBackupBeforeImport,
      'limit_to_data_types': limitToDataTypes?.map((e) => e.name).toList(),
    };
  }

  factory ImportConfig.fromJson(Map<String, dynamic> json) {
    return ImportConfig(
      mergeStrategy: MergeStrategy.values
          .firstWhere((e) => e.name == json['merge_strategy']),
      validateData: json['validate_data'] ?? true,
      createBackupBeforeImport: json['create_backup_before_import'] ?? true,
      limitToDataTypes: json['limit_to_data_types'] != null
          ? (json['limit_to_data_types'] as List)
              .map((e) => DataType.values.firstWhere((dt) => dt.name == e))
              .toSet()
          : null,
    );
  }
}

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({
    required this.start,
    required this.end,
  });

  Map<String, dynamic> toJson() {
    return {
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    };
  }

  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
    );
  }
}

// === DATA COLLECTION MODELS ===

class DataCollection {
  List<Map<String, dynamic>>? cycleData;
  List<Map<String, dynamic>>? symptomData;
  List<Map<String, dynamic>>? moodData;
  List<Map<String, dynamic>>? biometricData;
  List<Map<String, dynamic>>? medicationData;
  List<Map<String, dynamic>>? appointmentData;
  List<Map<String, dynamic>>? notesData;
  Map<String, dynamic>? settingsData;

  DataCollection({
    this.cycleData,
    this.symptomData,
    this.moodData,
    this.biometricData,
    this.medicationData,
    this.appointmentData,
    this.notesData,
    this.settingsData,
  });

  Map<String, dynamic> toJson() {
    return {
      'cycle_data': cycleData,
      'symptom_data': symptomData,
      'mood_data': moodData,
      'biometric_data': biometricData,
      'medication_data': medicationData,
      'appointment_data': appointmentData,
      'notes_data': notesData,
      'settings_data': settingsData,
    };
  }

  factory DataCollection.fromJson(Map<String, dynamic> json) {
    return DataCollection(
      cycleData: json['cycle_data'] != null
          ? List<Map<String, dynamic>>.from(json['cycle_data'])
          : null,
      symptomData: json['symptom_data'] != null
          ? List<Map<String, dynamic>>.from(json['symptom_data'])
          : null,
      moodData: json['mood_data'] != null
          ? List<Map<String, dynamic>>.from(json['mood_data'])
          : null,
      biometricData: json['biometric_data'] != null
          ? List<Map<String, dynamic>>.from(json['biometric_data'])
          : null,
      medicationData: json['medication_data'] != null
          ? List<Map<String, dynamic>>.from(json['medication_data'])
          : null,
      appointmentData: json['appointment_data'] != null
          ? List<Map<String, dynamic>>.from(json['appointment_data'])
          : null,
      notesData: json['notes_data'] != null
          ? List<Map<String, dynamic>>.from(json['notes_data'])
          : null,
      settingsData: json['settings_data'] != null
          ? Map<String, dynamic>.from(json['settings_data'])
          : null,
    );
  }
}

class ImportedDataSet {
  final Map<DataType, List<Map<String, dynamic>>> data;
  final Map<String, dynamic>? metadata;
  final String? version;
  final DateTime? createdAt;

  ImportedDataSet({
    this.data = const {},
    this.metadata,
    this.version,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((key, value) => MapEntry(key.name, value)),
      'metadata': metadata,
      'version': version,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory ImportedDataSet.fromJson(Map<String, dynamic> json) {
    final Map<DataType, List<Map<String, dynamic>>> dataMap = {};
    
    if (json['data'] != null) {
      json['data'].forEach((key, value) {
        try {
          final DataType dataType = DataType.values
              .firstWhere((e) => e.name == key);
          dataMap[dataType] = List<Map<String, dynamic>>.from(value);
        } catch (e) {
          // Skip unknown data types
        }
      });
    }

    return ImportedDataSet(
      data: dataMap,
      metadata: json['metadata'],
      version: json['version'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}

// === RESULT MODELS ===

class ExportResult {
  final bool success;
  final String filePath;
  final int fileSize;
  final DataFormat format;
  final int exportedItems;
  final bool isEncrypted;
  final bool isCompressed;
  final String? error;

  ExportResult({
    required this.success,
    required this.filePath,
    required this.fileSize,
    required this.format,
    required this.exportedItems,
    required this.isEncrypted,
    required this.isCompressed,
    this.error,
  });

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'file_path': filePath,
      'file_size': fileSize,
      'format': format.name,
      'exported_items': exportedItems,
      'is_encrypted': isEncrypted,
      'is_compressed': isCompressed,
      'error': error,
    };
  }

  factory ExportResult.fromJson(Map<String, dynamic> json) {
    return ExportResult(
      success: json['success'],
      filePath: json['file_path'],
      fileSize: json['file_size'],
      format: DataFormat.values.firstWhere((e) => e.name == json['format']),
      exportedItems: json['exported_items'],
      isEncrypted: json['is_encrypted'],
      isCompressed: json['is_compressed'],
      error: json['error'],
    );
  }
}

class ImportResult {
  final bool success;
  final int importedItems;
  final List<String> errors;
  final List<String> warnings;
  final Map<DataType, int>? itemsByType;

  ImportResult({
    required this.success,
    required this.importedItems,
    required this.errors,
    required this.warnings,
    this.itemsByType,
  });

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'imported_items': importedItems,
      'errors': errors,
      'warnings': warnings,
      'items_by_type': itemsByType?.map((key, value) => MapEntry(key.name, value)),
    };
  }

  factory ImportResult.fromJson(Map<String, dynamic> json) {
    Map<DataType, int>? itemsByType;
    if (json['items_by_type'] != null) {
      itemsByType = {};
      json['items_by_type'].forEach((key, value) {
        try {
          final DataType dataType = DataType.values
              .firstWhere((e) => e.name == key);
          itemsByType![dataType] = value;
        } catch (e) {
          // Skip unknown data types
        }
      });
    }

    return ImportResult(
      success: json['success'],
      importedItems: json['imported_items'],
      errors: List<String>.from(json['errors'] ?? []),
      warnings: List<String>.from(json['warnings'] ?? []),
      itemsByType: itemsByType,
    );
  }
}

class BackupResult {
  final bool success;
  final String message;
  final String? filePath;
  final int? backupSize;
  final int? itemCount;

  BackupResult({
    required this.success,
    required this.message,
    this.filePath,
    this.backupSize,
    this.itemCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'file_path': filePath,
      'backup_size': backupSize,
      'item_count': itemCount,
    };
  }

  factory BackupResult.fromJson(Map<String, dynamic> json) {
    return BackupResult(
      success: json['success'],
      message: json['message'],
      filePath: json['file_path'],
      backupSize: json['backup_size'],
      itemCount: json['item_count'],
    );
  }
}

class RestoreResult {
  final bool success;
  final String message;
  final int restoredItems;
  final List<String> errors;

  RestoreResult({
    required this.success,
    required this.message,
    required this.restoredItems,
    required this.errors,
  });

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'restored_items': restoredItems,
      'errors': errors,
    };
  }

  factory RestoreResult.fromJson(Map<String, dynamic> json) {
    return RestoreResult(
      success: json['success'],
      message: json['message'],
      restoredItems: json['restored_items'],
      errors: List<String>.from(json['errors'] ?? []),
    );
  }
}

// === METADATA MODELS ===

class ExportMetadata {
  final String id;
  final DateTime exportDate;
  final String filePath;
  final DataFormat format;
  final int fileSize;
  final int exportedItems;
  final bool isEncrypted;
  final bool isCompressed;

  ExportMetadata({
    required this.id,
    required this.exportDate,
    required this.filePath,
    required this.format,
    required this.fileSize,
    required this.exportedItems,
    required this.isEncrypted,
    required this.isCompressed,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'export_date': exportDate.toIso8601String(),
      'file_path': filePath,
      'format': format.name,
      'file_size': fileSize,
      'exported_items': exportedItems,
      'is_encrypted': isEncrypted,
      'is_compressed': isCompressed,
    };
  }

  factory ExportMetadata.fromJson(Map<String, dynamic> json) {
    return ExportMetadata(
      id: json['id'],
      exportDate: DateTime.parse(json['export_date']),
      filePath: json['file_path'],
      format: DataFormat.values.firstWhere((e) => e.name == json['format']),
      fileSize: json['file_size'],
      exportedItems: json['exported_items'],
      isEncrypted: json['is_encrypted'],
      isCompressed: json['is_compressed'],
    );
  }
}

class ImportMetadata {
  final String id;
  final DateTime importDate;
  final String sourceFile;
  final int importedItems;
  final bool success;
  final List<String> errors;

  ImportMetadata({
    required this.id,
    required this.importDate,
    required this.sourceFile,
    required this.importedItems,
    required this.success,
    required this.errors,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'import_date': importDate.toIso8601String(),
      'source_file': sourceFile,
      'imported_items': importedItems,
      'success': success,
      'errors': errors,
    };
  }

  factory ImportMetadata.fromJson(Map<String, dynamic> json) {
    return ImportMetadata(
      id: json['id'],
      importDate: DateTime.parse(json['import_date']),
      sourceFile: json['source_file'],
      importedItems: json['imported_items'],
      success: json['success'],
      errors: List<String>.from(json['errors'] ?? []),
    );
  }
}

// === VALIDATION MODELS ===

class DataValidationResult {
  final bool isValid;
  final List<ValidationError> errors;
  final List<ValidationWarning> warnings;
  final double completenessScore;

  DataValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.completenessScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'is_valid': isValid,
      'errors': errors.map((e) => e.toJson()).toList(),
      'warnings': warnings.map((w) => w.toJson()).toList(),
      'completeness_score': completenessScore,
    };
  }

  factory DataValidationResult.fromJson(Map<String, dynamic> json) {
    return DataValidationResult(
      isValid: json['is_valid'],
      errors: (json['errors'] as List)
          .map((e) => ValidationError.fromJson(e))
          .toList(),
      warnings: (json['warnings'] as List)
          .map((w) => ValidationWarning.fromJson(w))
          .toList(),
      completenessScore: json['completeness_score'],
    );
  }
}

class ValidationError {
  final String field;
  final String message;
  final String? suggestedFix;

  ValidationError({
    required this.field,
    required this.message,
    this.suggestedFix,
  });

  Map<String, dynamic> toJson() {
    return {
      'field': field,
      'message': message,
      'suggested_fix': suggestedFix,
    };
  }

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      field: json['field'],
      message: json['message'],
      suggestedFix: json['suggested_fix'],
    );
  }
}

class ValidationWarning {
  final String field;
  final String message;
  final String severity;

  ValidationWarning({
    required this.field,
    required this.message,
    this.severity = 'medium',
  });

  Map<String, dynamic> toJson() {
    return {
      'field': field,
      'message': message,
      'severity': severity,
    };
  }

  factory ValidationWarning.fromJson(Map<String, dynamic> json) {
    return ValidationWarning(
      field: json['field'],
      message: json['message'],
      severity: json['severity'] ?? 'medium',
    );
  }
}
