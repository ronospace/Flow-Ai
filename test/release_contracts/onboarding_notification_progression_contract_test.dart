import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/features/onboarding/screens/onboarding_screen.dart',
  ).readAsStringSync();

  test('permission step does not expose generic Next progression', () {
    expect(
      RegExp(
        r'provider\.currentStepData\.type\s*!=\s*'
        r'OnboardingStepType\.permissions',
      ).hasMatch(source),
      isTrue,
    );
  });

  test('right-edge gesture cannot bypass notification permission step', () {
    expect(
      RegExp(
        r'dx > width \* 0\.78 &&\s*'
        r'provider\.currentStepData\.type !=\s*'
        r'OnboardingStepType\.permissions',
      ).hasMatch(source),
      isTrue,
    );
  });

  test('permission result owns progression to the next onboarding step', () {
    final permissionBlock = source
        .split('Future<void> _handlePermissionRequest(')[1]
        .split('Future<void> _handleSetupAutosave(')[0];

    expect(
      permissionBlock,
      contains('await provider.requestNotificationPermission();'),
    );
    expect(permissionBlock, contains('if (!mounted) return;'));
    expect(permissionBlock, contains('_nextStep(provider);'));
  });

  test('permission progression is silent after the system result', () {
    final permissionBlock = source
        .split('Future<void> _handlePermissionRequest(')[1]
        .split('Future<void> _handleSetupAutosave(')[0];

    expect(permissionBlock, isNot(contains('_showSuccessMessage')));
    expect(permissionBlock, isNot(contains('AdaptiveMessages.showSuccess')));
  });
}
