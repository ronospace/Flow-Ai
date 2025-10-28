import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../database/database_service.dart';

/// Export format types
enum ExportFormat {
  pdf,
  csv,
  json,
}

/// Date range for exports
class ExportDateRange {
  final DateTime startDate;
  final DateTime endDate;

  ExportDateRange({
    required this.startDate,
    required this.endDate,
  });

  factory ExportDateRange.last30Days() {
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 30));
    return ExportDateRange(startDate: start, endDate: end);
  }

  factory ExportDateRange.last3Months() {
    final end = DateTime.now();
    final start = DateTime(end.year, end.month - 3, end.day);
    return ExportDateRange(startDate: start, endDate: end);
  }

  factory ExportDateRange.last6Months() {
    final end = DateTime.now();
    final start = DateTime(end.year, end.month - 6, end.day);
    return ExportDateRange(startDate: start, endDate: end);
  }

  factory ExportDateRange.last12Months() {
    final end = DateTime.now();
    final start = DateTime(end.year - 1, end.month, end.day);
    return ExportDateRange(startDate: start, endDate: end);
  }

  factory ExportDateRange.allTime() {
    final end = DateTime.now();
    final start = DateTime(2020, 1, 1); // Reasonable start date
    return ExportDateRange(startDate: start, endDate: end);
  }
}

/// Comprehensive data export service
class DataExportService {
  static final DataExportService _instance = DataExportService._internal();
  factory DataExportService() => _instance;
  DataExportService._internal();

  final DatabaseService _database = DatabaseService();

  /// Export data in specified format
  Future<String?> exportData({
    required ExportFormat format,
    required ExportDateRange dateRange,
    bool includeCharts = true,
  }) async {
    try {
      debugPrint('📤 Exporting data as ${format.name}...');
      debugPrint('   Date range: ${dateRange.startDate} to ${dateRange.endDate}');

      // Fetch all data for the date range
      final data = await _fetchDataForRange(dateRange);

      String? filePath;
      switch (format) {
        case ExportFormat.pdf:
          filePath = await _exportAsPDF(data, dateRange, includeCharts);
          break;
        case ExportFormat.csv:
          filePath = await _exportAsCSV(data, dateRange);
          break;
        case ExportFormat.json:
          filePath = await _exportAsJSON(data, dateRange);
          break;
      }

      if (filePath != null) {
        debugPrint('✅ Export successful: $filePath');
      }

      return filePath;
    } catch (e, stackTrace) {
      debugPrint('❌ Export failed: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Fetch all data for date range
  Future<Map<String, dynamic>> _fetchDataForRange(
    ExportDateRange dateRange,
  ) async {
    final cycles = await _database.getCyclesInRange(
      dateRange.startDate,
      dateRange.endDate,
    );

    final trackingData = await _database.getTrackingDataInRange(
      dateRange.startDate,
      dateRange.endDate,
    );

    return {
      'cycles': cycles,
      'tracking': trackingData,
      'exportDate': DateTime.now().toIso8601String(),
      'startDate': dateRange.startDate.toIso8601String(),
      'endDate': dateRange.endDate.toIso8601String(),
    };
  }

  /// Export as PDF with beautiful health report
  Future<String?> _exportAsPDF(
    Map<String, dynamic> data,
    ExportDateRange dateRange,
    bool includeCharts,
  ) async {
    try {
      final pdf = pw.Document();

      // Generate comprehensive PDF report
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            // Header
            _buildPDFHeader(),
            pw.SizedBox(height: 20),

            // Summary section
            _buildPDFSummary(data),
            pw.SizedBox(height: 20),

            // Cycles section
            _buildPDFCycles(data['cycles'] as List),
            pw.SizedBox(height: 20),

            // Tracking data section
            _buildPDFTrackingData(data['tracking'] as List),
            pw.SizedBox(height: 20),

            // Footer
            _buildPDFFooter(dateRange),
          ],
        ),
      );

      // Save PDF
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${directory.path}/FlowAi_Report_$timestamp.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      return filePath;
    } catch (e) {
      debugPrint('❌ PDF export failed: $e');
      return null;
    }
  }

  /// Build PDF header
  pw.Widget _buildPDFHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Flow Ai Health Report',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Your Personalized Menstrual Health Data',
          style: const pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey700,
          ),
        ),
        pw.Divider(thickness: 2),
      ],
    );
  }

  /// Build PDF summary
  pw.Widget _buildPDFSummary(Map<String, dynamic> data) {
    final cycles = data['cycles'] as List;
    final tracking = data['tracking'] as List;

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Summary',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Total Cycles', cycles.length.toString()),
              _buildSummaryItem('Tracking Days', tracking.length.toString()),
              _buildSummaryItem(
                'Export Date',
                DateFormat('MMM d, yyyy').format(DateTime.now()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build summary item
  pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Build PDF cycles section
  pw.Widget _buildPDFCycles(List cycles) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Cycle History',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 12),
        if (cycles.isEmpty)
          pw.Text('No cycle data available')
        else
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.grey300,
            ),
            headers: ['Start Date', 'Length', 'Flow Intensity', 'Notes'],
            data: cycles.take(20).map((cycle) {
              return [
                DateFormat('MMM d, yyyy').format(
                  DateTime.parse(cycle['start_date']),
                ),
                '${cycle['length'] ?? 'N/A'} days',
                cycle['flow_intensity'] ?? 'N/A',
                cycle['notes'] ?? '-',
              ];
            }).toList(),
          ),
      ],
    );
  }

  /// Build PDF tracking data section
  pw.Widget _buildPDFTrackingData(List tracking) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Daily Tracking Summary',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Text(
          'Tracked ${tracking.length} days with symptoms, mood, and energy data.',
          style: const pw.TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  /// Build PDF footer
  pw.Widget _buildPDFFooter(ExportDateRange dateRange) {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.Text(
          'Generated by Flow Ai on ${DateFormat('MMMM d, yyyy \'at\' h:mm a').format(DateTime.now())}',
          style: const pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey600,
          ),
        ),
        pw.Text(
          'Data range: ${DateFormat('MMM d, yyyy').format(dateRange.startDate)} - ${DateFormat('MMM d, yyyy').format(dateRange.endDate)}',
          style: const pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey600,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'This report is for personal use only and is not a substitute for medical advice.',
          style: const pw.TextStyle(
            fontSize: 8,
            color: PdfColors.grey500,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  /// Export as CSV
  Future<String?> _exportAsCSV(
    Map<String, dynamic> data,
    ExportDateRange dateRange,
  ) async {
    try {
      final cycles = data['cycles'] as List;
      final tracking = data['tracking'] as List;

      // Build CSV content
      final csvBuffer = StringBuffer();

      // Cycles CSV
      csvBuffer.writeln('=== CYCLE DATA ===');
      csvBuffer.writeln('Start Date,End Date,Length (days),Flow Intensity,Notes');

      for (final cycle in cycles) {
        final startDate = DateFormat('yyyy-MM-dd').format(
          DateTime.parse(cycle['start_date']),
        );
        final endDate = cycle['end_date'] != null
            ? DateFormat('yyyy-MM-dd').format(
                DateTime.parse(cycle['end_date']),
              )
            : 'N/A';
        final length = cycle['length'] ?? 'N/A';
        final flow = cycle['flow_intensity'] ?? 'N/A';
        final notes = (cycle['notes'] ?? '').replaceAll(',', ';');

        csvBuffer.writeln('$startDate,$endDate,$length,$flow,"$notes"');
      }

      csvBuffer.writeln();
      csvBuffer.writeln('=== TRACKING DATA ===');
      csvBuffer.writeln(
        'Date,Flow,Symptoms,Mood,Energy,Pain,Notes',
      );

      for (final track in tracking) {
        final date = DateFormat('yyyy-MM-dd').format(
          DateTime.parse(track['date']),
        );
        final flow = track['flow_intensity'] ?? 'N/A';
        final symptoms = (track['symptoms'] as List?)?.join(';') ?? 'N/A';
        final mood = track['mood'] ?? 'N/A';
        final energy = track['energy'] ?? 'N/A';
        final pain = track['pain'] ?? 'N/A';
        final notes = (track['notes'] ?? '').replaceAll(',', ';');

        csvBuffer.writeln('$date,$flow,"$symptoms",$mood,$energy,$pain,"$notes"');
      }

      // Save CSV
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${directory.path}/FlowAi_Data_$timestamp.csv';
      final file = File(filePath);
      await file.writeAsString(csvBuffer.toString());

      return filePath;
    } catch (e) {
      debugPrint('❌ CSV export failed: $e');
      return null;
    }
  }

  /// Export as JSON
  Future<String?> _exportAsJSON(
    Map<String, dynamic> data,
    ExportDateRange dateRange,
  ) async {
    try {
      // Create comprehensive JSON structure
      final jsonData = {
        'export_info': {
          'app': 'Flow Ai',
          'version': '2.1.2',
          'export_date': DateTime.now().toIso8601String(),
          'date_range': {
            'start': dateRange.startDate.toIso8601String(),
            'end': dateRange.endDate.toIso8601String(),
          },
        },
        'data': data,
      };

      // Convert to formatted JSON
      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);

      // Save JSON
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${directory.path}/FlowAi_Backup_$timestamp.json';
      final file = File(filePath);
      await file.writeAsString(jsonString);

      return filePath;
    } catch (e) {
      debugPrint('❌ JSON export failed: $e');
      return null;
    }
  }

  /// Share exported file
  Future<void> shareExportedFile(String filePath) async {
    try {
      debugPrint('📤 Sharing file: $filePath');
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Flow Ai Health Data Export',
        text: 'My Flow Ai health data export',
      );
      debugPrint('✅ File shared successfully');
    } catch (e) {
      debugPrint('❌ Sharing failed: $e');
    }
  }

  /// Delete exported file
  Future<void> deleteExportedFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('✅ Exported file deleted: $filePath');
      }
    } catch (e) {
      debugPrint('❌ Failed to delete file: $e');
    }
  }
}
