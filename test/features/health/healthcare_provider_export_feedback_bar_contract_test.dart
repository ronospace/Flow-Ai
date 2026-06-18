import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const targetPath =
      "lib/features/healthcare/screens/healthcare_provider_portal_screen.dart";

  final source = File(targetPath).readAsStringSync();

  test('health export does not show a success feedback bar', () {
    final exportSuccessSnackBar = RegExp(
      r'ScaffoldMessenger[\s\S]{0,3000}'
      r'showSnackBar[\s\S]{0,3000}'
      r'(?:Health\s*data\s*exported\s*successfully'
      r'|healthDataExportedSuccessfully)'
      r'[\s\S]{0,3000}Share',
      caseSensitive: false,
    );

    expect(
      exportSuccessSnackBar.hasMatch(source),
      isFalse,
      reason: 'Successful health export must not create a Snackbar.',
    );
  });

  test('the permanent in-page success state remains', () {
    expect(source, contains("Export Successful!"));
  });
}
