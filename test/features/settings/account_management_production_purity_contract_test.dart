import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String account;
  late String settings;

  setUpAll(() {
    account = File(
      'lib/features/settings/screens/account_management_screen.dart',
    ).readAsStringSync();

    settings = File(
      'lib/features/settings/screens/settings_screen.dart',
    ).readAsStringSync();
  });

  test('account management exposes no fake or unsupported data actions', () {
    for (final forbidden in <String>[
      "title: 'Export Data'",
      "title: 'Backup Data'",
      "title: 'Clear Cache'",
      "title: 'Delete All Data'",
      'const csvData',
      '2024-01-15,1,Heavy',
      'Cloud backup is currently unavailable',
      'Cache cleared successfully',
      'All data deleted successfully',
      'Future<void> _exportUserData() async',
      'Future<void> _clearCache() async',
      'void _showDeleteAllDataDialog()',
      'Future<void> _performDataDeletion() async',
    ]) {
      expect(account, isNot(contains(forbidden)));
    }
  });

  test('verified signer-migration restore remains reachable', () {
    expect(account, contains("title: 'Restore Verified Data'"));
    expect(account, contains('pickImportFile('));
    expect(account, contains("allowedExtensions: const ['json']"));
    expect(account, contains('importSanitizedMigrationPayload('));
  });

  test('real export remains canonical in settings', () {
    expect(settings, contains("title: 'Export as PDF'"));
    expect(settings, contains("title: 'Export as CSV'"));
    expect(settings, contains("title: 'Export as JSON'"));
    expect(settings, contains('final exportService = DataExportService();'));
    expect(settings, contains('await exportService.exportData('));
    expect(settings, contains('shareExportedFile(filePath)'));
  });

  test('unrelated account actions remain for separate truth audit', () {
    expect(account, contains("title: 'Deactivate Account'"));
    expect(account, contains("title: 'Delete Account'"));
    expect(account, contains('void _showDeactivateAccountDialog()'));
    expect(account, contains('Future<void> _performAccountDeletion() async'));
  });
}
