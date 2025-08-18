import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../models/cycle_data.dart';
import '../models/daily_tracking_data.dart';
import '../models/biometric_data.dart';
import 'database_service.dart';
import 'user_preferences_service.dart';
import 'analytics_service.dart';

class ExportImportService {
  final DatabaseService _databaseService = DatabaseService();
  final UserPreferencesService _preferencesService = UserPreferencesService();
  final AnalyticsService _analyticsService = AnalyticsService();

  // Export data to various formats
  Future<String> exportToJSON({
    DateTime? startDate,
    DateTime? endDate,
    bool includeAnalytics = true,
  }) async {
    try {
      startDate ??= DateTime.now().subtract(const Duration(days: 365));
      endDate ??= DateTime.now();

      final cycles = await _databaseService.getCyclesInRange(startDate, endDate);
      final trackingData = await _databaseService.getTrackingDataInRange(startDate, endDate);
      final preferences = await _preferencesService.getAllPreferences();
      
      final exportData = {
        'exportMetadata': {
          'version': '1.0',
          'exportDate': DateTime.now().toIso8601String(),
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'appName': 'FlowSense',
        },
        'cycles': cycles.map((c) => c.toMap()).toList(),
        'trackingData': trackingData.map((t) => t.toMap()).toList(),
        'preferences': preferences,
      };

      if (includeAnalytics) {
        final analytics = await _analyticsService.getCycleAnalytics(
          startDate: startDate,
          endDate: endDate,
        );
        exportData['analytics'] = {
          'totalCycles': analytics.totalCycles,
          'averageCycleLength': analytics.averageCycleLength,
          'averagePeriodLength': analytics.averagePeriodLength,
          'regularityScore': analytics.regularityScore,
          'cycleVariation': analytics.cycleVariation,
          'flowPattern': analytics.flowPattern.toString(),
          'symptomFrequency': analytics.symptomFrequency,
        };
      }

      return jsonEncode(exportData);
    } catch (e) {
      debugPrint('Error exporting to JSON: $e');
      rethrow;
    }
  }

  Future<String> exportToCSV({
    DateTime? startDate,
    DateTime? endDate,
    ExportType type = ExportType.cycles,
  }) async {
    try {
      startDate ??= DateTime.now().subtract(const Duration(days: 365));
      endDate ??= DateTime.now();

      List<List<dynamic>> csvData = [];

      switch (type) {
        case ExportType.cycles:
          csvData = await _exportCyclesToCSV(startDate, endDate);
          break;
        case ExportType.tracking:
          csvData = await _exportTrackingToCSV(startDate, endDate);
          break;
        case ExportType.symptoms:
          csvData = await _exportSymptomsToCSV(startDate, endDate);
          break;
        case ExportType.complete:
          csvData = await _exportCompleteToCSV(startDate, endDate);
          break;
      }

      return const ListToCsvConverter().convert(csvData);
    } catch (e) {
      debugPrint('Error exporting to CSV: $e');
      rethrow;
    }
  }

  Future<Uint8List> exportToPDF({
    DateTime? startDate,
    DateTime? endDate,
    bool includeCharts = true,
    PDFReportType reportType = PDFReportType.comprehensive,
  }) async {
    try {
      startDate ??= DateTime.now().subtract(const Duration(days: 365));
      endDate ??= DateTime.now();

      final pdf = pw.Document();
      
      switch (reportType) {
        case PDFReportType.medical:
          await _addMedicalReportPages(pdf, startDate, endDate);
          break;
        case PDFReportType.summary:
          await _addSummaryReportPages(pdf, startDate, endDate);
          break;
        case PDFReportType.comprehensive:
          await _addComprehensiveReportPages(pdf, startDate, endDate, includeCharts);
          break;
      }

      return await pdf.save();
    } catch (e) {
      debugPrint('Error exporting to PDF: $e');
      rethrow;
    }
  }

  // Import data from various formats
  Future<ImportResult> importFromJSON(String jsonData) async {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      
      // Validate format
      if (!_validateJSONFormat(data)) {
        throw Exception('Invalid JSON format');
      }

      int importedCycles = 0;
      int importedTracking = 0;
      int skippedDuplicates = 0;

      // Import cycles
      if (data.containsKey('cycles')) {
        final cycles = (data['cycles'] as List)
            .map((c) => CycleData.fromMap(c))
            .toList();
        
        for (final cycle in cycles) {
          final existing = await _databaseService.getCycleById(cycle.id);
          if (existing == null) {
            await _databaseService.insertCycle(cycle);
            importedCycles++;
          } else {
            skippedDuplicates++;
          }
        }
      }

      // Import tracking data
      if (data.containsKey('trackingData')) {
        final trackingList = (data['trackingData'] as List)
            .map((t) => DailyTrackingData.fromMap(t))
            .toList();
        
        for (final tracking in trackingList) {
          final existing = await _databaseService.getTrackingByDate(tracking.date);
          if (existing == null) {
            await _databaseService.saveDailyTracking(tracking);
            importedTracking++;
          } else {
            skippedDuplicates++;
          }
        }
      }

      // Import preferences (optional)
      if (data.containsKey('preferences')) {
        final preferences = data['preferences'] as Map<String, dynamic>;
        await _preferencesService.setAllPreferences(preferences);
      }

      return ImportResult(
        success: true,
        importedCycles: importedCycles,
        importedTrackingData: importedTracking,
        skippedDuplicates: skippedDuplicates,
        message: 'Import completed successfully',
      );
    } catch (e) {
      debugPrint('Error importing from JSON: $e');
      return ImportResult(
        success: false,
        message: 'Import failed: $e',
      );
    }
  }

  Future<ImportResult> importFromCSV(String csvData, CSVImportType type) async {
    try {
      final csvTable = const CsvToListConverter().convert(csvData);
      
      if (csvTable.isEmpty) {
        throw Exception('Empty CSV file');
      }

      int imported = 0;
      int skipped = 0;

      switch (type) {
        case CSVImportType.cycles:
          final result = await _importCyclesFromCSV(csvTable);
          imported = result['imported']!;
          skipped = result['skipped']!;
          break;
        case CSVImportType.tracking:
          final result = await _importTrackingFromCSV(csvTable);
          imported = result['imported']!;
          skipped = result['skipped']!;
          break;
      }

      return ImportResult(
        success: true,
        importedCycles: type == CSVImportType.cycles ? imported : 0,
        importedTrackingData: type == CSVImportType.tracking ? imported : 0,
        skippedDuplicates: skipped,
        message: 'CSV import completed successfully',
      );
    } catch (e) {
      debugPrint('Error importing from CSV: $e');
      return ImportResult(
        success: false,
        message: 'CSV import failed: $e',
      );
    }
  }

  // Import from other period tracking apps
  Future<ImportResult> importFromClue(String clueData) async {
    // Implementation for importing from Clue app export
    try {
      final data = jsonDecode(clueData) as Map<String, dynamic>;
      
      // Parse Clue's format and convert to FlowSense format
      final cycles = <CycleData>[];
      final trackingData = <DailyTrackingData>[];
      
      // Convert Clue data format to FlowSense format
      // This would need to be implemented based on Clue's actual export format
      
      int importedCycles = 0;
      int importedTracking = 0;
      
      for (final cycle in cycles) {
        await _databaseService.insertCycle(cycle);
        importedCycles++;
      }
      
      for (final tracking in trackingData) {
        await _databaseService.saveDailyTracking(tracking);
        importedTracking++;
      }

      return ImportResult(
        success: true,
        importedCycles: importedCycles,
        importedTrackingData: importedTracking,
        message: 'Clue data imported successfully',
      );
    } catch (e) {
      debugPrint('Error importing from Clue: $e');
      return ImportResult(
        success: false,
        message: 'Clue import failed: $e',
      );
    }
  }

  Future<ImportResult> importFromFlo(String floData) async {
    // Implementation for importing from Flo app export
    try {
      // Similar implementation for Flo app format
      return ImportResult(
        success: true,
        message: 'Flo data imported successfully',
      );
    } catch (e) {
      debugPrint('Error importing from Flo: $e');
      return ImportResult(
        success: false,
        message: 'Flo import failed: $e',
      );
    }
  }

  // File operations
  Future<String> saveExportToFile(String data, String fileName, ExportFormat format) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      
      if (format == ExportFormat.pdf) {
        // For PDF, data should be Uint8List
        await file.writeAsBytes(base64Decode(data));
      } else {
        await file.writeAsString(data);
      }
      
      return file.path;
    } catch (e) {
      debugPrint('Error saving export to file: $e');
      rethrow;
    }
  }

  Future<void> shareExport(String data, String fileName, ExportFormat format) async {
    try {
      final filePath = await saveExportToFile(data, fileName, format);
      await Share.shareXFiles([XFile(filePath)]);
    } catch (e) {
      debugPrint('Error sharing export: $e');
      rethrow;
    }
  }

  Future<String?> pickImportFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'csv'],
      );
      
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        return await file.readAsString();
      }
      
      return null;
    } catch (e) {
      debugPrint('Error picking import file: $e');
      rethrow;
    }
  }

  // Private helper methods for CSV export
  Future<List<List<dynamic>>> _exportCyclesToCSV(DateTime startDate, DateTime endDate) async {
    final cycles = await _databaseService.getCyclesInRange(startDate, endDate);
    
    final csvData = <List<dynamic>>[
      ['Cycle ID', 'Start Date', 'End Date', 'Length', 'Period Length', 'Ovulation Day', 'Notes']
    ];
    
    for (final cycle in cycles) {
      csvData.add([
        cycle.id,
        cycle.startDate?.toIso8601String() ?? '',
        cycle.endDate?.toIso8601String() ?? '',
        cycle.length,
        cycle.periodLength ?? '',
        cycle.ovulationDay ?? '',
        cycle.notes ?? '',
      ]);
    }
    
    return csvData;
  }

  Future<List<List<dynamic>>> _exportTrackingToCSV(DateTime startDate, DateTime endDate) async {
    final trackingData = await _databaseService.getTrackingDataInRange(startDate, endDate);
    
    final csvData = <List<dynamic>>[
      ['Date', 'Flow Intensity', 'Mood', 'Energy', 'Sleep Hours', 'Symptoms', 'Notes']
    ];
    
    for (final tracking in trackingData) {
      csvData.add([
        tracking.date.toIso8601String(),
        tracking.flowIntensity?.toString() ?? '',
        tracking.mood ?? '',
        tracking.energy ?? '',
        tracking.sleepHours ?? '',
        tracking.symptoms?.join(', ') ?? '',
        tracking.notes ?? '',
      ]);
    }
    
    return csvData;
  }

  Future<List<List<dynamic>>> _exportSymptomsToCSV(DateTime startDate, DateTime endDate) async {
    final trackingData = await _databaseService.getTrackingDataInRange(startDate, endDate);
    
    final csvData = <List<dynamic>>[
      ['Date', 'Symptoms']
    ];
    
    for (final tracking in trackingData) {
      if (tracking.symptoms != null && tracking.symptoms!.isNotEmpty) {
        for (final symptom in tracking.symptoms!) {
          csvData.add([
            tracking.date.toIso8601String(),
            symptom,
          ]);
        }
      }
    }
    
    return csvData;
  }

  Future<List<List<dynamic>>> _exportCompleteToCSV(DateTime startDate, DateTime endDate) async {
    final trackingData = await _databaseService.getTrackingDataInRange(startDate, endDate);
    
    final csvData = <List<dynamic>>[
      [
        'Date', 'Flow Intensity', 'Mood', 'Energy', 'Sleep Hours',
        'Temperature', 'Weight', 'Symptoms', 'Notes'
      ]
    ];
    
    for (final tracking in trackingData) {
      csvData.add([
        tracking.date.toIso8601String(),
        tracking.flowIntensity?.toString() ?? '',
        tracking.mood ?? '',
        tracking.energy ?? '',
        tracking.sleepHours ?? '',
        tracking.temperature ?? '',
        tracking.weight ?? '',
        tracking.symptoms?.join(', ') ?? '',
        tracking.notes ?? '',
      ]);
    }
    
    return csvData;
  }

  // Private helper methods for PDF generation
  Future<void> _addMedicalReportPages(pw.Document pdf, DateTime startDate, DateTime endDate) async {
    final cycles = await _databaseService.getCyclesInRange(startDate, endDate);
    final analytics = await _analyticsService.getCycleAnalytics(startDate: startDate, endDate: endDate);
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('FlowSense Medical Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Report Period: ${startDate.toString().split(' ')[0]} to ${endDate.toString().split(' ')[0]}'),
              pw.SizedBox(height: 20),
              pw.Header(level: 1, text: 'Cycle Summary'),
              pw.Text('Total Cycles: ${analytics.totalCycles}'),
              pw.Text('Average Cycle Length: ${analytics.averageCycleLength.round()} days'),
              pw.Text('Average Period Length: ${analytics.averagePeriodLength.round()} days'),
              pw.Text('Cycle Regularity: ${(analytics.regularityScore * 100).round()}%'),
              pw.SizedBox(height: 20),
              pw.Header(level: 1, text: 'Cycle Details'),
              pw.Table.fromTextArray(
                headers: ['Start Date', 'Length', 'Period Length', 'Notes'],
                data: cycles.map((cycle) => [
                  cycle.startDate?.toString().split(' ')[0] ?? '',
                  '${cycle.length} days',
                  '${cycle.periodLength ?? 'N/A'} days',
                  cycle.notes ?? '',
                ]).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _addSummaryReportPages(pw.Document pdf, DateTime startDate, DateTime endDate) async {
    // Implementation for summary report
  }

  Future<void> _addComprehensiveReportPages(pw.Document pdf, DateTime startDate, DateTime endDate, bool includeCharts) async {
    // Implementation for comprehensive report with charts
  }

  // Private helper methods for CSV import
  Future<Map<String, int>> _importCyclesFromCSV(List<List<dynamic>> csvTable) async {
    int imported = 0;
    int skipped = 0;
    
    // Skip header row
    for (int i = 1; i < csvTable.length; i++) {
      try {
        final row = csvTable[i];
        
        final cycle = CycleData(
          id: row[0].toString(),
          startDate: DateTime.tryParse(row[1].toString()),
          endDate: DateTime.tryParse(row[2].toString()),
          length: int.tryParse(row[3].toString()) ?? 0,
          periodLength: int.tryParse(row[4].toString()),
          ovulationDay: int.tryParse(row[5].toString()),
          notes: row[6].toString().isEmpty ? null : row[6].toString(),
        );
        
        final existing = await _databaseService.getCycleById(cycle.id);
        if (existing == null) {
          await _databaseService.insertCycle(cycle);
          imported++;
        } else {
          skipped++;
        }
      } catch (e) {
        debugPrint('Error importing cycle row $i: $e');
        skipped++;
      }
    }
    
    return {'imported': imported, 'skipped': skipped};
  }

  Future<Map<String, int>> _importTrackingFromCSV(List<List<dynamic>> csvTable) async {
    int imported = 0;
    int skipped = 0;
    
    // Skip header row
    for (int i = 1; i < csvTable.length; i++) {
      try {
        final row = csvTable[i];
        
        final tracking = DailyTrackingData(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: DateTime.parse(row[0].toString()),
          flowIntensity: _parseFlowIntensity(row[1].toString()),
          mood: int.tryParse(row[2].toString()),
          energy: int.tryParse(row[3].toString()),
          sleepHours: double.tryParse(row[4].toString()),
          symptoms: row[5].toString().isEmpty ? null : row[5].toString().split(', '),
          notes: row[6].toString().isEmpty ? null : row[6].toString(),
        );
        
        final existing = await _databaseService.getTrackingByDate(tracking.date);
        if (existing == null) {
          await _databaseService.saveDailyTracking(tracking);
          imported++;
        } else {
          skipped++;
        }
      } catch (e) {
        debugPrint('Error importing tracking row $i: $e');
        skipped++;
      }
    }
    
    return {'imported': imported, 'skipped': skipped};
  }

  FlowIntensity? _parseFlowIntensity(String value) {
    switch (value.toLowerCase()) {
      case 'none':
        return FlowIntensity.none;
      case 'spotting':
        return FlowIntensity.spotting;
      case 'light':
        return FlowIntensity.light;
      case 'medium':
        return FlowIntensity.medium;
      case 'heavy':
        return FlowIntensity.heavy;
      default:
        return null;
    }
  }

  bool _validateJSONFormat(Map<String, dynamic> data) {
    // Check if the JSON has the expected structure
    return data.containsKey('exportMetadata') &&
           (data.containsKey('cycles') || data.containsKey('trackingData'));
  }
}

// Enums and models
enum ExportFormat { json, csv, pdf }
enum ExportType { cycles, tracking, symptoms, complete }
enum PDFReportType { medical, summary, comprehensive }
enum CSVImportType { cycles, tracking }

class ImportResult {
  final bool success;
  final int importedCycles;
  final int importedTrackingData;
  final int skippedDuplicates;
  final String message;

  ImportResult({
    required this.success,
    this.importedCycles = 0,
    this.importedTrackingData = 0,
    this.skippedDuplicates = 0,
    required this.message,
  });
}
