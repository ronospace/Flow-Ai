import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/features/onboarding/models/onboarding_step.dart',
  ).readAsStringSync();

  test('onboarding does not make unverified privacy/compliance claims', () {
    expect(source, isNot(contains('End-to-end encryption')));
    expect(source, isNot(contains('Data stored locally on your device')));
    expect(source, isNot(contains('No sharing without your permission')));
    expect(source, isNot(contains('GDPR & HIPAA compliant')));
  });

  test('privacy onboarding uses bounded user-control language', () {
    expect(source, contains('Permissions stay under your control'));
    expect(source, contains('Security safeguards help protect your data'));
    expect(source, contains('Manage your data and preferences in Settings'));
    expect(source, contains('Review our Privacy Policy for full details'));
  });
}
