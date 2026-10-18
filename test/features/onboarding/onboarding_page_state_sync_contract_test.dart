import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/features/onboarding/screens/onboarding_screen.dart',
  ).readAsStringSync();

  test('PageView owns provider current-step synchronization', () {
    expect(source, contains('onPageChanged: (index) {'));
    expect(source, contains('provider.setCurrentStep(index);'));
  });

  test('forward navigation does not pre-increment provider state', () {
    final block = source
        .split('void _nextStep(OnboardingProvider provider) {')[1]
        .split('void _previousStep(OnboardingProvider provider) {')[0];

    expect(block, isNot(contains('provider.nextStep()')));
    expect(block, contains('_pageController.animateToPage('));
    expect(block, contains('provider.currentStep + 1'));
  });

  test('backward navigation does not pre-decrement provider state', () {
    final block = source
        .split('void _previousStep(OnboardingProvider provider) {')[1]
        .split('Future<void> _completeOnboarding')[0];

    expect(block, isNot(contains('provider.previousStep()')));
    expect(block, contains('_pageController.animateToPage('));
    expect(block, contains('provider.currentStep - 1'));
    expect(block, contains('if (provider.isFirstStep) return;'));
  });

  test('navigation still uses centralized transition ownership', () {
    final nextBlock = source
        .split('void _nextStep(OnboardingProvider provider) {')[1]
        .split('void _previousStep(OnboardingProvider provider) {')[0];

    final previousBlock = source
        .split('void _previousStep(OnboardingProvider provider) {')[1]
        .split('Future<void> _completeOnboarding')[0];

    for (final block in [nextBlock, previousBlock]) {
      expect(
        block,
        contains('duration: AppLayout.onboardingPageTransitionDuration'),
      );
      expect(block, contains('curve: AppLayout.onboardingPageTransitionCurve'));
    }
  });
}
