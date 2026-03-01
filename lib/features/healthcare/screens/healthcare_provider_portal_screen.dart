import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../data_management/services/data_export_import_service.dart';
import '../../data_management/models/export_import_models.dart';

/// Healthcare Provider Portal Screen
/// Allows users to export their health data for medical appointments
class HealthcareProviderPortalScreen extends StatefulWidget {
  const HealthcareProviderPortalScreen({super.key});

  @override
  State<HealthcareProviderPortalScreen> createState() =>
      _HealthcareProviderPortalScreenState();
}

class _HealthcareProviderPortalScreenState
    extends State<HealthcareProviderPortalScreen> {
  final DataExportImportService _exportService =
      DataExportImportService.instance;
  bool _isExporting = false;
  String? _exportFilePath;
  DateRange? _selectedDateRange;
  DataFormat _selectedFormat = DataFormat.fhir;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDateRange = DateRange(
      start: DateTime(now.year, now.month - 6, now.day),
      end: now,
    );
    _exportService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient(
            theme.brightness == Brightness.dark,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, theme),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(context, theme),
                      const SizedBox(height: 24),
                      _buildDateRangeSelector(context, theme),
                      const SizedBox(height: 24),
                      _buildFormatSelector(context, theme),
                      const SizedBox(height: 32),
                      _buildExportButton(context, theme),
                      if (_exportFilePath != null) ...[
                        const SizedBox(height: 24),
                        _buildExportSuccessCard(context, theme),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.secondaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.medical_services_rounded,
              color: AppTheme.secondaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Healthcare Provider Portal',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Export health data for appointments',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.mediumGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.secondaryBlue.withValues(alpha: 0.1),
            AppTheme.secondaryBlue.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.secondaryBlue.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.secondaryBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Share Your Health Data',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Export your cycle data, symptoms, and health insights to share with your healthcare provider during appointments.',
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.warningOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.warningOrange.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lock_outline,
                  color: AppTheme.warningOrange,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your data is encrypted and secure. You control what is shared.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.warningOrange,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildDateRangeChip('Last 3 Months', () {
              final now = DateTime.now();
              return DateRange(
                start: DateTime(now.year, now.month - 3, now.day),
                end: now,
              );
            }),
            _buildDateRangeChip('Last 6 Months', () {
              final now = DateTime.now();
              return DateRange(
                start: DateTime(now.year, now.month - 6, now.day),
                end: now,
              );
            }),
            _buildDateRangeChip('Last 12 Months', () {
              final now = DateTime.now();
              return DateRange(
                start: DateTime(now.year - 1, now.month, now.day),
                end: now,
              );
            }),
            _buildDateRangeChip('All Time', () {
              return DateRange(
                start: DateTime(2020, 1, 1),
                end: DateTime.now(),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildDateRangeChip(String label, DateRange Function() rangeBuilder) {
    final range = rangeBuilder();
    final isSelected = _selectedDateRange?.start == range.start &&
        _selectedDateRange?.end == range.end;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedDateRange = range;
        });
        HapticFeedback.lightImpact();
      },
      selectedColor: AppTheme.secondaryBlue.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.secondaryBlue,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.secondaryBlue : AppTheme.mediumGrey,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildFormatSelector(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export Format',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFormatCard(
                'FHIR',
                'Medical standard format',
                Icons.medical_information,
                DataFormat.fhir,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFormatCard(
                'CSV',
                'For spreadsheet analysis',
                Icons.table_chart,
                DataFormat.csv,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFormatCard(
                'JSON',
                'Complete data export',
                Icons.code,
                DataFormat.json,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFormatCard(
                'XML',
                'Structured data format',
                Icons.description,
                DataFormat.xml,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormatCard(
    String title,
    String subtitle,
    IconData icon,
    DataFormat format,
  ) {
    final isSelected = _selectedFormat == format;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFormat = format;
        });
        HapticFeedback.lightImpact();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.secondaryBlue.withValues(alpha: 0.1)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.secondaryBlue
                : AppTheme.lightGrey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.secondaryBlue : AppTheme.mediumGrey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.secondaryBlue : AppTheme.darkGrey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.mediumGrey,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isExporting ? null : _exportData,
        icon: _isExporting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.file_download, size: 24),
        label: Text(
          _isExporting ? 'Exporting...' : 'Export Health Data',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.secondaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildExportSuccessCard(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.successGreen.withValues(alpha: 0.1),
            AppTheme.successGreen.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.successGreen.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppTheme.successGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Export Successful!',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _shareExport,
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Share'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.successGreen,
                    side: BorderSide(
                      color: AppTheme.successGreen.withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _exportData() async {
    setState(() {
      _isExporting = true;
      _exportFilePath = null;
    });

    try {
      HapticFeedback.mediumImpact();

      final config = ExportConfig(
        format: _selectedFormat,
        dateRange: _selectedDateRange,
        dataTypes: {
          DataType.cycle,
          DataType.symptoms,
          DataType.mood,
          DataType.biometrics,
        },
        includeSettings: false,
      );

      final result = await _exportService.exportUserData(config: config);

      if (result.success) {
        setState(() {
          _exportFilePath = result.filePath;
          _isExporting = false;
        });

        if (mounted) {
          ScaffoldMessenger.maybeOf(context).showSnackBar(
            SnackBar(
              content: const Text('Health data exported successfully!'),
              backgroundColor: AppTheme.successGreen,
              action: SnackBarAction(
                label: 'Share',
                textColor: Colors.white,
                onPressed: _shareExport,
              ),
            ),
          );
        }
      } else {
        throw Exception('Export failed');
      }
    } catch (e) {
      setState(() {
        _isExporting = false;
      });

      if (mounted) {
        ScaffoldMessenger.maybeOf(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _shareExport() async {
    if (_exportFilePath == null) return;

    try {
      await Share.shareXFiles(
        [XFile(_exportFilePath!)],
        text: 'My Flow Ai Health Data Export',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }
}

