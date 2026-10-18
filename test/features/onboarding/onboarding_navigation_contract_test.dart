import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final screen = File(
    'lib/features/onboarding/screens/onboarding_screen.dart',
  ).readAsStringSync();

  final layout = File('lib/core/constants/app_layout.dart').readAsStringSync();

  final theme = File('lib/core/theme/app_theme.dart').readAsStringSync();

  test('onboarding uses simple chevron navigation without stemmed arrows', () {
    expect(theme, contains('navigationBackIcon = Icons.chevron_left'));
    expect(theme, contains('navigationForwardIcon = Icons.chevron_right'));

    expect(screen, contains('AppTheme.navigationForwardIcon'));

    expect(screen, isNot(contains('Icons.arrow_forward')));
    expect(screen, isNot(contains('Icons.arrow_back')));
  });

  test('onboarding page transition motion is centrally owned', () {
    expect(layout, contains('onboardingPageTransitionDuration'));
    expect(layout, contains('onboardingPageTransitionCurve'));

    final nextBlock = screen
        .split('void _nextStep(OnboardingProvider provider) {')[1]
        .split('void _previousStep(OnboardingProvider provider) {')[0];

    final previousBlock = screen
        .split('void _previousStep(OnboardingProvider provider) {')[1]
        .split('Future<void> _completeOnboarding')[0];

    for (final block in [nextBlock, previousBlock]) {
      expect(
        block,
        contains('duration: AppLayout.onboardingPageTransitionDuration'),
      );
      expect(block, contains('curve: AppLayout.onboardingPageTransitionCurve'));
      expect(block, isNot(contains('Duration(milliseconds: 300)')));
      expect(block, isNot(contains('Curves.easeInOut')));
    }
  });

  test('onboarding page spring-back physics is centrally owned', () {
    expect(layout, contains('onboardingPagePhysics'));
    expect(layout, contains('PageScrollPhysics('));
    expect(layout, contains('BouncingScrollPhysics()'));

    expect(screen, contains('AppLayout.onboardingPagePhysics'));
    expect(screen, contains('AppLayout.onboardingSetupPagePhysics'));
  });
}
