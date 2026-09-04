import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const servicePath = 'lib/core/services/export_import_service.dart';
  const uiPath = 'lib/features/settings/screens/account_management_screen.dart';

  late String service;
  late String ui;

  setUpAll(() {
    service = File(servicePath).readAsStringSync();
    ui = File(uiPath).readAsStringSync();
  });

  test('canonical service owns sanitized migration', () {
    expect(service, contains('importSanitizedMigrationPayload'));
    expect(service, contains('class MigrationImportResult'));
    expect(service, contains('sourceAccountFingerprint'));
    expect(service, contains('sha256.convert'));
    expect(service, contains('getCurrentUser'));
  });

  test('migration is fail closed for security state', () {
    expect(service, contains("'requiresSuccessfulReauthentication': true"));
    expect(service, contains("'requiresAccountFingerprintMatch': true"));
    expect(service, contains("'restoreAuthenticationSession': false"));
    expect(service, contains("'restoreBiometricEnrollment': false"));
    expect(service, contains("'restoreCryptoMaterial': false"));
    expect(service, contains('This backup belongs to a different account.'));
    expect(service, contains('Restore failed safely.'));
  });

  test('restored identity is rebound to authenticated account', () {
    expect(service, contains('final liveUid'));
    expect(service, contains("mergedSettings['userId'] = liveUid"));
    expect(service, contains("mergedMetadata['uid'] = liveUid"));
    expect(service, contains("mergedSettings.remove('biometricAuth')"));
    expect(service, contains("mergedSettings.remove('cycleSyncUserId')"));
  });

  test('settings UI reaches real picker and canonical importer', () {
    expect(ui, contains("title: 'Restore Verified Data'"));
    expect(ui, contains('pickImportFile('));
    expect(ui, contains("allowedExtensions: const ['json']"));
    expect(service, contains('return result.files.single.path;'));
    expect(service, isNot(contains('return await file.readAsString();')));

    expect(
      RegExp(
        r'importSanitizedMigrationPayload\s*\(\s*filePath\s*,?\s*\)',
        multiLine: true,
      ).hasMatch(ui),
      isTrue,
    );

    expect(ui, contains('result.message'));
    expect(ui, contains('result.success'));
  });
}
