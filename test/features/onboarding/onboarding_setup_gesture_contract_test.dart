import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final layout = File('lib/core/constants/app_layout.dart').readAsStringSync();

  final screen = File(
    'lib/features/onboarding/screens/onboarding_screen.dart',
  ).readAsStringSync();

  test('setup page disables horizontal finger paging centrally', () {
    expect(layout, contains('onboardingSetupPagePhysics'));
    expect(layout, contains('NeverScrollableScrollPhysics()'));

    expect(
      screen,
      matches(
        RegExp(
          r'provider\.currentStepData\.type\s*==\s*'
          r'OnboardingStepType\.setup',
        ),
      ),
    );
    expect(screen, contains('? AppLayout.onboardingSetupPagePhysics'));
    expect(screen, contains(': AppLayout.onboardingPagePhysics'));
  });

  test('setup keeps programmatic next and previous navigation', () {
    expect(screen, contains('_pageController.animateToPage('));
    expect(screen, contains('void _nextStep(OnboardingProvider provider)'));
    expect(screen, contains('void _previousStep(OnboardingProvider provider)'));
  });

  test('setup restores deliberate horizontal swipe navigation', () {
    expect(layout, contains('onboardingSetupSwipeVelocityThreshold = 120.0'));
    expect(screen, contains('onHorizontalDragEnd: (details)'));
    expect(screen, contains('final velocity = details.primaryVelocity ?? 0'));
    expect(screen, contains('AppLayout.onboardingSetupSwipeVelocityThreshold'));
    expect(screen, contains('if (velocity < 0)'));
    expect(screen, contains('_nextStep(provider)'));
    expect(screen, contains('_previousStep(provider)'));
  });

  test('setup vertical scroll physics remains active', () {
    expect(layout, contains('onboardingSetupScrollPhysics'));
    expect(layout, contains('BouncingScrollPhysics()'));
  });
}
