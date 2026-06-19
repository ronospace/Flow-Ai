import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const targetPath =
      'lib/features/healthcare/screens/'
      'healthcare_provider_portal_screen.dart';

  final source = File(targetPath).readAsStringSync();

  test('export button has idle, loading and completed states', () {
    expect(source, contains('final exportCompleted ='));
    expect(source, contains('_exportFilePath != null && !_isExporting'));

    expect(source, contains("'Export Health Data'"));
    expect(source, contains("'Exporting...'"));
    expect(source, contains("'Health Data Exported'"));

    expect(source, contains('Icons.download_rounded'));
    expect(source, contains('CircularProgressIndicator('));
    expect(source, contains('Icons.check_circle_rounded'));
  });

  test('completed export button uses the success treatment', () {
    expect(source, contains('_isExporting || exportCompleted'));
    expect(source, contains('AppTheme.successGreen'));
    expect(source, contains('disabledBackgroundColor:'));
    expect(source, contains('disabledForegroundColor:'));
  });

  test('changing export inputs invalidates the old result', () {
    expect(
      '_exportFilePath = null;'.allMatches(source).length,
      greaterThanOrEqualTo(3),
    );
  });

  test('success card reveal and Share behavior remain intact', () {
    expect(source, contains('_revealExportSuccessCard();'));
    expect(source, contains('Scrollable.ensureVisible('));
    expect(source, contains('Export Successful!'));
    expect(source, contains('_shareExport'));

    expect(source, isNot(contains('Health data exported successfully!')));
  });
}
