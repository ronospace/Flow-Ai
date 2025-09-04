import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:archive/archive.dart';

import '../models/export_import_models.dart';
import '../../security/services/security_privacy_service.dart';
import '../../tracking/services/feelings_database_service.dart';
import '../../clinical/services/clinical_intelligence_service.dart';

/// Data export/import service for comprehensive data management
class DataExportImportService {
  static DataExportImportService? _instance;
  static DataExportImportService get instance {
    _instance ??= DataExportImportService._internal();
    return _instance!;
  }

  DataExportImportService._internal();

  bool _isInitialized = false;
  SharedPreferences? _prefs;
  Directory? _documentsDirectory;
  Directory? _tempDirectory;

  // Export/Import configuration
  static const String _exportConfigKey = 'export_config';
  static const String _lastExportKey = 'last_export_timestamp';
  static const String _importHistoryKey = 'import_history';
  static const int _maxExportHistory = 50;
  static const int _compressionLevel = 6;

  /// Initialize the data export/import service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _documentsDirectory = await getApplicationDocumentsDirectory();
      _tempDirectory = await getTemporaryDirectory();
      
      // Ensure export directory exists
      final exportDir = Directory('${_documentsDirectory!.path}/exports');
      if (!exportDir.existsSync()) {
        exportDir.createSync(recursive: true);
      }

      _isInitialized = true;
      debugPrint('📤 Data export/import service initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize export/import service: $e');
      throw DataManagementException('Failed to initialize service: $e');
    }
  }

  /// Export user data in multiple formats
  Future<ExportResult> exportUserData({
    required ExportConfig config,
    String? customPath,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      debugPrint('📤 Starting data export with config: ${config.format.name}');
      
      // Collect all requested data
      final DataCollection dataCollection = await _collectUserData(config);
      
      // Generate export based on format
      final ExportResult result = await _generateExport(
        dataCollection,
        config,
        customPath,
      );

      // Save export metadata
      await _saveExportMetadata(result);

      debugPrint('✅ Data export completed: ${result.filePath}');
      return result;
    } catch (e) {
      debugPrint('❌ Failed to export data: $e');
      throw DataManagementException('Failed to export data: $e');
    }
  }

  /// Import user data from file
  Future<ImportResult> importUserData({
    required String filePath,
    ImportConfig? config,
    String? password,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      debugPrint('📥 Starting data import from: $filePath');

      // Validate file
      final File importFile = File(filePath);
      if (!importFile.existsSync()) {
        throw DataManagementException('Import file does not exist');
      }

      // Detect file format
      final DataFormat format = await _detectFileFormat(filePath);
      
      // Load and parse data
      final ImportedDataSet dataSet = await _parseImportFile(
        importFile,
        format,
        password,
      );

      // Import data into system
      final ImportResult result = await _importDataSet(dataSet, config);

      // Save import history
      await _saveImportHistory(result);

      debugPrint('✅ Data import completed: ${result.importedItems} items');
      return result;
    } catch (e) {
      debugPrint('❌ Failed to import data: $e');
      throw DataManagementException('Failed to import data: $e');
    }
  }

  /// Create automatic backup
  Future<BackupResult> createAutomaticBackup({
    BackupFrequency frequency = BackupFrequency.weekly,
    bool includeSettings = true,
    bool compressData = true,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      // Check if backup is needed
      if (!await _shouldCreateBackup(frequency)) {
        return BackupResult(
          success: false,
          message: 'Backup not needed at this time',
          filePath: null,
        );
      }

      // Create comprehensive backup configuration
      final ExportConfig config = ExportConfig(
        format: DataFormat.zyraflowBackup,
        dataTypes: DataType.values.toSet(),
        includeMedia: false,
        includeSettings: includeSettings,
        encryptData: true,
        compressData: compressData,
        dateRange: DateRange(
          start: DateTime.now().subtract(const Duration(days: 365)),
          end: DateTime.now(),
        ),
      );

      // Export data
      final ExportResult exportResult = await exportUserData(config: config);
      
      // Update last backup timestamp
      await _prefs?.setInt('last_backup_${frequency.name}', 
        DateTime.now().millisecondsSinceEpoch);

      return BackupResult(
        success: exportResult.success,
        message: 'Automatic backup completed',
        filePath: exportResult.filePath,
        backupSize: exportResult.fileSize,
        itemCount: exportResult.exportedItems,
      );
    } catch (e) {
      debugPrint('❌ Failed to create automatic backup: $e');
      return BackupResult(
        success: false,
        message: 'Failed to create backup: $e',
        filePath: null,
      );
    }
  }

  /// Restore from backup file
  Future<RestoreResult> restoreFromBackup({
    required String backupPath,
    String? password,
    bool overwriteExisting = false,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      debugPrint('🔄 Starting restore from backup: $backupPath');

      // Import backup data
      final ImportConfig config = ImportConfig(
        mergeStrategy: overwriteExisting 
          ? MergeStrategy.overwrite 
          : MergeStrategy.preserve,
        validateData: true,
        createBackupBeforeImport: true,
      );

      final ImportResult importResult = await importUserData(
        filePath: backupPath,
        config: config,
        password: password,
      );

      return RestoreResult(
        success: importResult.success,
        message: 'Restore completed successfully',
        restoredItems: importResult.importedItems,
        errors: importResult.errors,
      );
    } catch (e) {
      debugPrint('❌ Failed to restore from backup: $e');
      return RestoreResult(
        success: false,
        message: 'Failed to restore: $e',
        restoredItems: 0,
        errors: [e.toString()],
      );
    }
  }

  /// Export data in CSV format for healthcare providers
  Future<String> exportHealthcareReport({
    required String userId,
    required DateRange dateRange,
    List<DataType> includeTypes = const [
      DataType.cycle,
      DataType.symptoms,
      DataType.mood,
      DataType.biometrics,
    ],
  }) async {
    if (!_isInitialized) await initialize();

    try {
      // Collect health data
      final Map<DataType, List<Map<String, dynamic>>> healthData = {};
      
      for (final dataType in includeTypes) {
        healthData[dataType] = await _collectHealthDataByType(
          dataType,
          userId,
          dateRange,
        );
      }

      // Generate CSV files
      final String reportDir = '${_documentsDirectory!.path}/healthcare_reports';
      final Directory reportDirectory = Directory(reportDir);
      if (!reportDirectory.existsSync()) {
        reportDirectory.createSync(recursive: true);
      }

      final List<String> generatedFiles = [];
      
      for (final entry in healthData.entries) {
        if (entry.value.isNotEmpty) {
          final String fileName = 'healthcare_${entry.key.name}_${DateTime.now().millisecondsSinceEpoch}.csv';
          final String filePath = '$reportDir/$fileName';
          
          await _writeCSVFile(filePath, entry.value);
          generatedFiles.add(filePath);
        }
      }

      // Create summary report
      final String summaryPath = await _generateHealthcareSummary(
        healthData,
        reportDir,
        dateRange,
      );
      generatedFiles.add(summaryPath);

      // Create ZIP archive
      final String zipPath = '$reportDir/healthcare_report_${DateTime.now().millisecondsSinceEpoch}.zip';
      await _createZipArchive(generatedFiles, zipPath);

      // Clean up individual files
      for (final filePath in generatedFiles) {
        final File file = File(filePath);
        if (file.existsSync()) {
          file.deleteSync();
        }
      }

      debugPrint('📊 Healthcare report generated: $zipPath');
      return zipPath;
    } catch (e) {
      debugPrint('❌ Failed to generate healthcare report: $e');
      throw DataManagementException('Failed to generate healthcare report: $e');
    }
  }

  /// Get export history
  Future<List<ExportMetadata>> getExportHistory() async {
    if (!_isInitialized) await initialize();

    try {
      final List<String> historyStrings = _prefs?.getStringList('export_history') ?? [];
      
      return historyStrings.map((historyStr) {
        try {
          final Map<String, dynamic> historyJson = json.decode(historyStr);
          return ExportMetadata.fromJson(historyJson);
        } catch (e) {
          return null;
        }
      }).where((metadata) => metadata != null)
        .cast<ExportMetadata>()
        .toList();
    } catch (e) {
      debugPrint('❌ Failed to get export history: $e');
      return [];
    }
  }

  /// Get import history
  Future<List<ImportMetadata>> getImportHistory() async {
    if (!_isInitialized) await initialize();

    try {
      final List<String> historyStrings = _prefs?.getStringList(_importHistoryKey) ?? [];
      
      return historyStrings.map((historyStr) {
        try {
          final Map<String, dynamic> historyJson = json.decode(historyStr);
          return ImportMetadata.fromJson(historyJson);
        } catch (e) {
          return null;
        }
      }).where((metadata) => metadata != null)
        .cast<ImportMetadata>()
        .toList();
    } catch (e) {
      debugPrint('❌ Failed to get import history: $e');
      return [];
    }
  }

  /// Collect user data based on configuration
  Future<DataCollection> _collectUserData(ExportConfig config) async {
    final DataCollection collection = DataCollection();

    for (final dataType in config.dataTypes) {
      try {
        switch (dataType) {
          case DataType.cycle:
            collection.cycleData = await _collectCycleData(config.dateRange);
            break;
          case DataType.symptoms:
            collection.symptomData = await _collectSymptomData(config.dateRange);
            break;
          case DataType.mood:
            collection.moodData = await _collectMoodData(config.dateRange);
            break;
          case DataType.biometrics:
            collection.biometricData = await _collectBiometricData(config.dateRange);
            break;
          case DataType.medications:
            collection.medicationData = await _collectMedicationData(config.dateRange);
            break;
          case DataType.appointments:
            collection.appointmentData = await _collectAppointmentData(config.dateRange);
            break;
          case DataType.notes:
            collection.notesData = await _collectNotesData(config.dateRange);
            break;
          case DataType.settings:
            if (config.includeSettings) {
              collection.settingsData = await _collectSettingsData();
            }
            break;
        }
      } catch (e) {
        debugPrint('⚠️ Failed to collect $dataType: $e');
      }
    }

    return collection;
  }

  /// Generate export file based on format
  Future<ExportResult> _generateExport(
    DataCollection dataCollection,
    ExportConfig config,
    String? customPath,
  ) async {
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String fileName;
    String filePath;

    switch (config.format) {
      case DataFormat.json:
        fileName = 'zyraflow_export_$timestamp.json';
        filePath = customPath ?? '${_documentsDirectory!.path}/exports/$fileName';
        return await _exportAsJSON(dataCollection, filePath, config);

      case DataFormat.csv:
        fileName = 'zyraflow_export_$timestamp.csv';
        filePath = customPath ?? '${_documentsDirectory!.path}/exports/$fileName';
        return await _exportAsCSV(dataCollection, filePath, config);

      case DataFormat.xml:
        fileName = 'zyraflow_export_$timestamp.xml';
        filePath = customPath ?? '${_documentsDirectory!.path}/exports/$fileName';
        return await _exportAsXML(dataCollection, filePath, config);

      case DataFormat.zyraflowBackup:
        fileName = 'zyraflow_backup_$timestamp.zbk';
        filePath = customPath ?? '${_documentsDirectory!.path}/exports/$fileName';
        return await _exportAsZyraFlowBackup(dataCollection, filePath, config);

      case DataFormat.fhir:
        fileName = 'zyraflow_fhir_$timestamp.json';
        filePath = customPath ?? '${_documentsDirectory!.path}/exports/$fileName';
        return await _exportAsFHIR(dataCollection, filePath, config);
    }
  }

  /// Export data as JSON
  Future<ExportResult> _exportAsJSON(
    DataCollection dataCollection,
    String filePath,
    ExportConfig config,
  ) async {
    try {
      final Map<String, dynamic> exportData = {
        'version': '1.0',
        'exported_at': DateTime.now().toIso8601String(),
        'format': 'json',
        'data': dataCollection.toJson(),
      };

      String jsonContent = const JsonEncoder.withIndent('  ').convert(exportData);
      
      if (config.encryptData) {
        final SecurityPrivacyService security = SecurityPrivacyService.instance;
        final encryptedData = await security.encryptData(jsonContent);
        jsonContent = json.encode(encryptedData.toJson());
      }

      if (config.compressData) {
        final List<int> compressed = GZipEncoder().encode(utf8.encode(jsonContent));
        await File(filePath).writeAsBytes(compressed);
      } else {
        await File(filePath).writeAsString(jsonContent);
      }

      final int fileSize = await File(filePath).length();
      
      return ExportResult(
        success: true,
        filePath: filePath,
        fileSize: fileSize,
        format: DataFormat.json,
        exportedItems: _countDataItems(dataCollection),
        isEncrypted: config.encryptData,
        isCompressed: config.compressData,
      );
    } catch (e) {
      throw DataManagementException('Failed to export as JSON: $e');
    }
  }

  /// Export data as CSV
  Future<ExportResult> _exportAsCSV(
    DataCollection dataCollection,
    String filePath,
    ExportConfig config,
  ) async {
    try {
      final List<List<dynamic>> csvData = [];
      
      // Combine all data into a flat structure for CSV
      final List<Map<String, dynamic>> flatData = _flattenDataCollection(dataCollection);
      
      if (flatData.isNotEmpty) {
        // Add headers
        csvData.add(flatData.first.keys.toList());
        
        // Add data rows
        for (final item in flatData) {
          csvData.add(item.values.toList());
        }
      }

      final String csvContent = const ListToCsvConverter().convert(csvData);
      await File(filePath).writeAsString(csvContent);

      final int fileSize = await File(filePath).length();
      
      return ExportResult(
        success: true,
        filePath: filePath,
        fileSize: fileSize,
        format: DataFormat.csv,
        exportedItems: flatData.length,
        isEncrypted: false,
        isCompressed: false,
      );
    } catch (e) {
      throw DataManagementException('Failed to export as CSV: $e');
    }
  }

  /// Export data as XML
  Future<ExportResult> _exportAsXML(
    DataCollection dataCollection,
    String filePath,
    ExportConfig config,
  ) async {
    try {
      final StringBuffer xmlContent = StringBuffer();
      xmlContent.writeln('<?xml version="1.0" encoding="UTF-8"?>');
      xmlContent.writeln('<zyraflow_export>');
      xmlContent.writeln('  <metadata>');
      xmlContent.writeln('    <version>1.0</version>');
      xmlContent.writeln('    <exported_at>${DateTime.now().toIso8601String()}</exported_at>');
      xmlContent.writeln('  </metadata>');
      
      // Convert data collection to XML
      xmlContent.writeln('  <data>');
      xmlContent.writeln(_dataCollectionToXML(dataCollection));
      xmlContent.writeln('  </data>');
      xmlContent.writeln('</zyraflow_export>');

      await File(filePath).writeAsString(xmlContent.toString());

      final int fileSize = await File(filePath).length();
      
      return ExportResult(
        success: true,
        filePath: filePath,
        fileSize: fileSize,
        format: DataFormat.xml,
        exportedItems: _countDataItems(dataCollection),
        isEncrypted: false,
        isCompressed: false,
      );
    } catch (e) {
      throw DataManagementException('Failed to export as XML: $e');
    }
  }

  /// Export as ZyraFlow backup format
  Future<ExportResult> _exportAsZyraFlowBackup(
    DataCollection dataCollection,
    String filePath,
    ExportConfig config,
  ) async {
    try {
      final Map<String, dynamic> backupData = {
        'version': '1.0',
        'format': 'zyraflow_backup',
        'created_at': DateTime.now().toIso8601String(),
        'encrypted': config.encryptData,
        'compressed': config.compressData,
        'data': dataCollection.toJson(),
      };

      // Convert to JSON
      String jsonContent = json.encode(backupData);

      // Encrypt if requested
      if (config.encryptData) {
        final SecurityPrivacyService security = SecurityPrivacyService.instance;
        final encryptedData = await security.encryptData(jsonContent);
        jsonContent = json.encode({
          'encrypted': true,
          'data': encryptedData.toJson(),
        });
      }

      // Compress if requested
      List<int> finalContent = utf8.encode(jsonContent);
      if (config.compressData) {
        finalContent = GZipEncoder().encode(finalContent);
      }

      await File(filePath).writeAsBytes(finalContent);

      final int fileSize = await File(filePath).length();
      
      return ExportResult(
        success: true,
        filePath: filePath,
        fileSize: fileSize,
        format: DataFormat.zyraflowBackup,
        exportedItems: _countDataItems(dataCollection),
        isEncrypted: config.encryptData,
        isCompressed: config.compressData,
      );
    } catch (e) {
      throw DataManagementException('Failed to export as ZyraFlow backup: $e');
    }
  }

  /// Export as FHIR format
  Future<ExportResult> _exportAsFHIR(
    DataCollection dataCollection,
    String filePath,
    ExportConfig config,
  ) async {
    try {
      final Map<String, dynamic> fhirBundle = {
        'resourceType': 'Bundle',
        'id': 'zyraflow-export-${DateTime.now().millisecondsSinceEpoch}',
        'type': 'collection',
        'timestamp': DateTime.now().toIso8601String(),
        'entry': _convertToFHIRResources(dataCollection),
      };

      final String fhirContent = const JsonEncoder.withIndent('  ').convert(fhirBundle);
      await File(filePath).writeAsString(fhirContent);

      final int fileSize = await File(filePath).length();
      
      return ExportResult(
        success: true,
        filePath: filePath,
        fileSize: fileSize,
        format: DataFormat.fhir,
        exportedItems: _countDataItems(dataCollection),
        isEncrypted: false,
        isCompressed: false,
      );
    } catch (e) {
      throw DataManagementException('Failed to export as FHIR: $e');
    }
  }

  /// Detect file format from file extension and content
  Future<DataFormat> _detectFileFormat(String filePath) async {
    final String extension = filePath.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'json':
        return DataFormat.json;
      case 'csv':
        return DataFormat.csv;
      case 'xml':
        return DataFormat.xml;
      case 'zbk':
        return DataFormat.zyraflowBackup;
      default:
        // Try to detect from content
        final File file = File(filePath);
        final String content = await file.readAsString();
        
        if (content.trim().startsWith('{') || content.trim().startsWith('[')) {
          return DataFormat.json;
        } else if (content.contains('<?xml')) {
          return DataFormat.xml;
        } else {
          return DataFormat.csv;
        }
    }
  }

  /// Data collection helper methods
  Future<List<Map<String, dynamic>>> _collectCycleData(DateRange? dateRange) async {
    // Mock implementation - in reality, would fetch from cycle service
    return [
      {
        'date': '2024-01-15',
        'cycle_day': 1,
        'flow': 'heavy',
        'symptoms': ['cramps', 'mood_swings'],
      },
    ];
  }

  Future<List<Map<String, dynamic>>> _collectSymptomData(DateRange? dateRange) async {
    // Mock implementation - in reality, would fetch from symptom service
    return [
      {
        'date': '2024-01-15',
        'symptom': 'headache',
        'severity': 7,
        'notes': 'Started in the morning',
      },
    ];
  }

  Future<List<Map<String, dynamic>>> _collectMoodData(DateRange? dateRange) async {
    try {
      final entries = await FeelingsDatabaseService.instance.getRecentEntries(
        limit: dateRange != null ? 1000 : 100,
      );
      
      return entries.map((entry) => entry.toJson()).toList();
    } catch (e) {
      debugPrint('⚠️ Failed to collect mood data: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _collectBiometricData(DateRange? dateRange) async {
    // Mock implementation - in reality, would fetch from biometric service
    return [
      {
        'date': '2024-01-15',
        'heart_rate': 72,
        'blood_pressure_systolic': 120,
        'blood_pressure_diastolic': 80,
        'temperature': 98.6,
      },
    ];
  }

  Future<List<Map<String, dynamic>>> _collectMedicationData(DateRange? dateRange) async {
    // Mock implementation
    return [];
  }

  Future<List<Map<String, dynamic>>> _collectAppointmentData(DateRange? dateRange) async {
    // Mock implementation
    return [];
  }

  Future<List<Map<String, dynamic>>> _collectNotesData(DateRange? dateRange) async {
    // Mock implementation
    return [];
  }

  Future<Map<String, dynamic>> _collectSettingsData() async {
    try {
      final SecurityPrivacyService security = SecurityPrivacyService.instance;
      final privacySettings = await security.getPrivacySettings();
      
      return {
        'privacy_settings': privacySettings.toJson(),
        'app_version': '1.0.0',
        'export_timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('⚠️ Failed to collect settings: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> _collectHealthDataByType(
    DataType dataType,
    String userId,
    DateRange dateRange,
  ) async {
    switch (dataType) {
      case DataType.cycle:
        return await _collectCycleData(dateRange);
      case DataType.symptoms:
        return await _collectSymptomData(dateRange);
      case DataType.mood:
        return await _collectMoodData(dateRange);
      case DataType.biometrics:
        return await _collectBiometricData(dateRange);
      default:
        return [];
    }
  }

  /// Helper methods
  int _countDataItems(DataCollection collection) {
    int count = 0;
    count += collection.cycleData?.length ?? 0;
    count += collection.symptomData?.length ?? 0;
    count += collection.moodData?.length ?? 0;
    count += collection.biometricData?.length ?? 0;
    count += collection.medicationData?.length ?? 0;
    count += collection.appointmentData?.length ?? 0;
    count += collection.notesData?.length ?? 0;
    return count;
  }

  List<Map<String, dynamic>> _flattenDataCollection(DataCollection collection) {
    final List<Map<String, dynamic>> flatData = [];
    
    // Flatten all data types into a single list
    collection.cycleData?.forEach((item) {
      flatData.add({...item, 'data_type': 'cycle'});
    });
    
    collection.symptomData?.forEach((item) {
      flatData.add({...item, 'data_type': 'symptom'});
    });
    
    collection.moodData?.forEach((item) {
      flatData.add({...item, 'data_type': 'mood'});
    });
    
    collection.biometricData?.forEach((item) {
      flatData.add({...item, 'data_type': 'biometric'});
    });
    
    return flatData;
  }

  String _dataCollectionToXML(DataCollection collection) {
    final StringBuffer xml = StringBuffer();
    
    if (collection.cycleData != null) {
      xml.writeln('    <cycle_data>');
      for (final item in collection.cycleData!) {
        xml.writeln('      <entry>');
        item.forEach((key, value) {
          xml.writeln('        <$key>$value</$key>');
        });
        xml.writeln('      </entry>');
      }
      xml.writeln('    </cycle_data>');
    }
    
    // Similar for other data types...
    
    return xml.toString();
  }

  List<Map<String, dynamic>> _convertToFHIRResources(DataCollection collection) {
    final List<Map<String, dynamic>> resources = [];
    
    // Convert cycle data to FHIR Observation resources
    collection.cycleData?.forEach((item) {
      resources.add({
        'resource': {
          'resourceType': 'Observation',
          'status': 'final',
          'category': [
            {
              'coding': [
                {
                  'system': 'http://terminology.hl7.org/CodeSystem/observation-category',
                  'code': 'survey',
                  'display': 'Survey'
                }
              ]
            }
          ],
          'code': {
            'coding': [
              {
                'system': 'http://loinc.org',
                'code': '33747-0',
                'display': 'Menstrual cycle'
              }
            ]
          },
          'effectiveDateTime': item['date'],
          'valueString': item['flow'],
        }
      });
    });
    
    // Convert other data types to appropriate FHIR resources...
    
    return resources;
  }

  Future<bool> _shouldCreateBackup(BackupFrequency frequency) async {
    final int? lastBackup = _prefs?.getInt('last_backup_${frequency.name}');
    if (lastBackup == null) return true;
    
    final DateTime lastBackupDate = DateTime.fromMillisecondsSinceEpoch(lastBackup);
    final Duration elapsed = DateTime.now().difference(lastBackupDate);
    
    switch (frequency) {
      case BackupFrequency.daily:
        return elapsed.inDays >= 1;
      case BackupFrequency.weekly:
        return elapsed.inDays >= 7;
      case BackupFrequency.monthly:
        return elapsed.inDays >= 30;
    }
  }

  Future<void> _writeCSVFile(String filePath, List<Map<String, dynamic>> data) async {
    if (data.isEmpty) return;
    
    final List<List<dynamic>> csvData = [];
    csvData.add(data.first.keys.toList());
    
    for (final item in data) {
      csvData.add(item.values.toList());
    }
    
    final String csvContent = const ListToCsvConverter().convert(csvData);
    await File(filePath).writeAsString(csvContent);
  }

  Future<String> _generateHealthcareSummary(
    Map<DataType, List<Map<String, dynamic>>> healthData,
    String reportDir,
    DateRange dateRange,
  ) async {
    final StringBuffer summary = StringBuffer();
    summary.writeln('ZyraFlow Healthcare Report Summary');
    summary.writeln('Generated: ${DateTime.now()}');
    summary.writeln('Date Range: ${dateRange.start} to ${dateRange.end}');
    summary.writeln('');
    
    healthData.forEach((dataType, data) {
      summary.writeln('${dataType.name.toUpperCase()}: ${data.length} entries');
    });
    
    final String summaryPath = '$reportDir/summary.txt';
    await File(summaryPath).writeAsString(summary.toString());
    
    return summaryPath;
  }

  Future<void> _createZipArchive(List<String> filePaths, String zipPath) async {
    final Archive archive = Archive();
    
    for (final filePath in filePaths) {
      final File file = File(filePath);
      if (file.existsSync()) {
        final List<int> bytes = file.readAsBytesSync();
        final String fileName = filePath.split('/').last;
        archive.addFile(ArchiveFile(fileName, bytes.length, bytes));
      }
    }
    
    final List<int> zipBytes = ZipEncoder().encode(archive)!;
    await File(zipPath).writeAsBytes(zipBytes);
  }

  Future<ImportedDataSet> _parseImportFile(
    File importFile,
    DataFormat format,
    String? password,
  ) async {
    // Mock implementation - would parse based on format
    return ImportedDataSet();
  }

  Future<ImportResult> _importDataSet(
    ImportedDataSet dataSet,
    ImportConfig? config,
  ) async {
    // Mock implementation - would import data into system
    return ImportResult(
      success: true,
      importedItems: 0,
      errors: [],
      warnings: [],
    );
  }

  Future<void> _saveExportMetadata(ExportResult result) async {
    final ExportMetadata metadata = ExportMetadata(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      exportDate: DateTime.now(),
      filePath: result.filePath,
      format: result.format,
      fileSize: result.fileSize,
      exportedItems: result.exportedItems,
      isEncrypted: result.isEncrypted,
      isCompressed: result.isCompressed,
    );
    
    final List<String> history = _prefs?.getStringList('export_history') ?? [];
    history.add(json.encode(metadata.toJson()));
    
    // Keep only recent exports
    if (history.length > _maxExportHistory) {
      history.removeRange(0, history.length - _maxExportHistory);
    }
    
    await _prefs?.setStringList('export_history', history);
  }

  Future<void> _saveImportHistory(ImportResult result) async {
    final ImportMetadata metadata = ImportMetadata(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      importDate: DateTime.now(),
      sourceFile: 'imported_file',
      importedItems: result.importedItems,
      success: result.success,
      errors: result.errors,
    );
    
    final List<String> history = _prefs?.getStringList(_importHistoryKey) ?? [];
    history.add(json.encode(metadata.toJson()));
    
    // Keep only recent imports
    if (history.length > _maxExportHistory) {
      history.removeRange(0, history.length - _maxExportHistory);
    }
    
    await _prefs?.setStringList(_importHistoryKey, history);
  }

  /// Dispose resources
  void dispose() {
    _isInitialized = false;
  }
}

class DataManagementException implements Exception {
  final String message;
  DataManagementException(this.message);

  @override
  String toString() => 'DataManagementException: $message';
}
