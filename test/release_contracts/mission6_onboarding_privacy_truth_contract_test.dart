import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final privacy = File(
    'lib/features/onboarding/widgets/privacy_preferences_widget.dart',
  ).readAsStringSync();

  final model = File(
    'lib/features/onboarding/models/onboarding_data.dart',
  ).readAsStringSync();

  final flowAi = File(
    'lib/core/services/flowai_service.dart',
  ).readAsStringSync();

  test('onboarding exposes no decorative privacy switches', () {
    expect(privacy, isNot(contains('Switch.adaptive')));
    expect(privacy, isNot(contains('Secure Cloud Backup')));
    expect(privacy, isNot(contains('Anonymous Research Participation')));
    expect(privacy, isNot(contains('Trusted Partner Data Sharing')));
    expect(privacy, isNot(contains('Personalized Communications')));
  });

  test('retired fake consent fields do not return', () {
    expect(model, isNot(contains('shareDataForResearch')));
    expect(model, isNot(contains('enableAIInsights')));
  });

  test('AI disclosure matches real off-device request path', () {
    expect(privacy, contains('sent over HTTPS'));
    expect(privacy, contains('account identifier'));
    expect(flowAi, contains('.post('));
    expect(flowAi, contains('userId'));
    expect(privacy, isNot(contains('No personal data leaves your device')));
  });

  test('backup disclosure is local-only and truthful', () {
    expect(privacy, contains('Current backup support is local-only'));

    expect(privacy, isNot(contains('secure cloud storage')));
  });

  test('unsupported security/compliance marketing is absent', () {
    expect(privacy, isNot(contains('Military-grade')));
    expect(privacy, isNot(contains('HIPAA Compliant')));
    expect(privacy, isNot(contains('End-to-End Encryption')));
  });

  test('Android and iOS use canonical Flow Ai display name', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    final info = File('ios/Runner/Info.plist').readAsStringSync();

    expect(manifest, contains('android:label="Flow Ai"'));

    expect(info, contains('<string>Flow Ai</string>'));
  });
}
