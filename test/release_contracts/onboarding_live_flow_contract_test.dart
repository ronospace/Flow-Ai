import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/features/onboarding/models/onboarding_step.dart',
  ).readAsStringSync();

  test('live onboarding contains only four required steps', () {
    final stepsBlock = source
        .split('static List<OnboardingStep> get steps => [')[1]
        .split('];')[0];

    expect(RegExp(r'const OnboardingStep\(').allMatches(stepsBlock).length, 4);

    expect(source, contains("title: 'Your Privacy Matters'"));
    expect(source, contains("title: 'Enable Notifications'"));
    expect(source, contains("title: 'Setup Your Profile'"));
    expect(source, contains("title: 'All Set!'"));

    expect(source, isNot(contains("title: 'Welcome to Flow Ai'")));
    expect(source, isNot(contains("title: 'Powerful Features'")));
  });

  test('behavior-bearing step types remain intact', () {
    expect(source, contains('type: OnboardingStepType.privacy'));
    expect(source, contains('type: OnboardingStepType.permissions'));
    expect(source, contains('type: OnboardingStepType.setup'));
    expect(source, contains('type: OnboardingStepType.complete'));
    expect(source, contains("data: {'permission': 'notifications'}"));
  });
}
