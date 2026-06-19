import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const target =
      'lib/features/healthcare/screens/'
      'healthcare_provider_portal_screen.dart';

  final source = File(target).readAsStringSync();

  test('export action exposes all three states', () {
    final start = source.indexOf('Widget _buildExportButton');
    final end = source.indexOf('Widget _buildExportSuccessCard', start);

    expect(start, greaterThanOrEqualTo(0));
    expect(end, greaterThan(start));

    final button = source.substring(start, end);

    expect(button, contains('Export Health Data'));
    expect(button, contains('Exporting...'));
    expect(button, contains('Health Data Exported'));
    expect(button, contains('check_circle'));
    expect(button, contains('exportCompleted'));
  });

  test('completed action uses deep teal and blocks duplication', () {
    final start = source.indexOf('Widget _buildExportButton');
    final end = source.indexOf('Widget _buildExportSuccessCard', start);
    final button = source.substring(start, end);

    expect(button, contains('Color(0xFF0F766E)'));
    expect(button, contains('_isExporting || exportCompleted'));
  });

  test('reveal, Share and errors remain intact', () {
    expect(source, contains('_revealExportSuccessCard'));
    expect(source, contains('Scrollable.ensureVisible'));
    expect(source, contains('Export Successful!'));
    expect(source, contains('_shareExport'));
    expect(source, contains('Export failed:'));
    expect(source, contains('Failed to share:'));
  });
}
