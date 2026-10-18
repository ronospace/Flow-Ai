import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final layout = File('lib/core/constants/app_layout.dart').readAsStringSync();

  final setup = File(
    'lib/features/onboarding/widgets/setup_form.dart',
  ).readAsStringSync();

  test('setup vertical spring behavior is centrally owned', () {
    expect(layout, contains('onboardingSetupScrollPhysics'));
    expect(layout, contains('BouncingScrollPhysics()'));
    expect(setup, contains('physics: AppLayout.onboardingSetupScrollPhysics'));
  });

  test(
    'setup resting end does not duplicate fixed-navigation bottom inset',
    () {
      expect(layout, contains('onboardingSetupScrollPadding'));
      expect(
        layout,
        matches(
          RegExp(
            r'onboardingSetupScrollPadding\s*=\s*EdgeInsets\.fromLTRB\('
            r'\s*24,\s*24,\s*24,\s*0,',
          ),
        ),
      );
      expect(
        setup,
        contains('padding: AppLayout.onboardingSetupScrollPadding'),
      );
      expect(setup, isNot(contains('padding: const EdgeInsets.all(24)')));
    },
  );
}
