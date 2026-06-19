import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const portalPath =
      'lib/features/healthcare/screens/'
      'healthcare_provider_portal_screen.dart';

  const accountPath =
      'lib/features/settings/screens/'
      'account_management_screen.dart';

  test('healthcare export has no transient success notification', () {
    final source = File(portalPath).readAsStringSync();

    expect(source, isNot(contains('Health data exported successfully!')));

    expect(source, contains('_buildExportSuccessCard'));
    expect(source, contains('Export Successful!'));
    expect(source, contains('_shareExport'));
    expect(source, contains('Export failed:'));
    expect(source, contains('Failed to share:'));
  });

  test('account export has no transient success notification', () {
    final source = File(accountPath).readAsStringSync();

    expect(source, isNot(contains('Data exported successfully')));
  });
}
