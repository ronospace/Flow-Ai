import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const target =
      'lib/features/healthcare/screens/'
      'healthcare_provider_portal_screen.dart';

  final source = File(target).readAsStringSync();

  test('deep teal is limited to the completed action method', () {
    final start = source.indexOf('Widget _buildExportButton');
    final end = source.indexOf('Widget _buildExportSuccessCard', start);

    final button = source.substring(start, end);
    final successCardAndLater = source.substring(end);

    expect(button, contains('Color(0xFF0F766E)'));
    expect(button, contains('Health Data Exported'));
    expect(successCardAndLater, contains('Export Successful!'));
    expect(successCardAndLater, isNot(contains('Color(0xFF0F766E)')));
  });
}
