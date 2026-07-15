import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('onboarding contains no demo or sample-data runtime path', () {
    final provider = File(
      'lib/features/onboarding/providers/onboarding_provider.dart',
    ).readAsStringSync();

    final screen = File(
      'lib/features/onboarding/screens/onboarding_screen.dart',
    ).readAsStringSync();

    final combined = '$provider\n$screen'.toLowerCase();

    expect(combined, isNot(contains('demodataset')));
    expect(combined, isNot(contains('demodataservice')));
    expect(combined, isNot(contains('generatedemo')));
    expect(combined, isNot(contains('use demo data')));
    expect(combined, isNot(contains('demo data')));
    expect(combined, isNot(contains('sample data')));

    expect(
      File('lib/core/services/demo_data_service.dart.disabled').existsSync(),
      isFalse,
    );
  });

  test('feedback opens the verified support email composer truthfully', () {
    final source = File(
      'lib/features/feedback/screens/feedback_screen.dart',
    ).readAsStringSync();

    expect(source, contains("path: 'support@flowai.app'"));
    expect(source, contains('await launchUrl('));
    expect(source, contains('LaunchMode.externalApplication'));
    expect(source, contains('_showComposerOpenedDialog'));

    expect(source, isNot(contains('Simulate API call')));
    expect(source, isNot(contains('Future.delayed')));
    expect(source, isNot(contains('Your feedback has been submitted')));
  });

  test('unimplemented CycleSync is absent from the production UI', () {
    final settingsScreen = File(
      'lib/features/settings/screens/settings_screen.dart',
    ).readAsStringSync();

    final provider = File(
      'lib/features/settings/providers/settings_provider.dart',
    ).readAsStringSync();

    final preferences = File(
      'lib/features/settings/models/user_preferences.dart',
    ).readAsStringSync();

    expect(
      File(
        'lib/features/settings/widgets/cyclesync_integration.dart',
      ).existsSync(),
      isFalse,
    );

    expect(settingsScreen, isNot(contains('cyclesync_integration.dart')));
    expect(settingsScreen, isNot(contains('FlowIQIntegration')));
    expect(provider, isNot(contains('updateCycleSyncIntegration')));

    expect(preferences, contains('syncWithCycleSync: false'));
    expect(preferences, contains('cycleSyncUserId: null'));
  });
}
