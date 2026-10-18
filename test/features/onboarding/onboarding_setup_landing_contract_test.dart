import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final layout = File('lib/core/constants/app_layout.dart').readAsStringSync();

  final setup = File(
    'lib/features/onboarding/widgets/setup_form.dart',
  ).readAsStringSync();

  test('setup landing motion reuses centralized production contract', () {
    expect(layout, contains('onboardingSetupLandingTolerance'));
    expect(layout, contains('calendarLandingSpringBackTolerance'));

    expect(layout, contains('onboardingSetupLandingSpringBackDuration'));
    expect(layout, contains('calendarLandingSpringBackDuration'));

    expect(layout, contains('onboardingSetupLandingSpringBackCurve'));
    expect(layout, contains('calendarLandingSpringBackCurve'));
  });

  test('setup owns a real scroll controller and disposes it', () {
    expect(setup, contains('ScrollController _setupScrollController'));
    expect(setup, contains('controller: _setupScrollController'));
    expect(setup, contains('_setupScrollController.dispose()'));
  });

  test('setup bottom landing uses actual maxScrollExtent', () {
    expect(setup, contains('final landingOffset = position.maxScrollExtent'));
    expect(setup, contains('AppLayout.onboardingSetupLandingTolerance'));
    expect(
      setup,
      contains('AppLayout.onboardingSetupLandingSpringBackDuration'),
    );
    expect(setup, contains('AppLayout.onboardingSetupLandingSpringBackCurve'));
  });

  test('setup requests landing on pointer release and vertical scroll end', () {
    expect(setup, contains('onPointerUp:'));
    expect(setup, contains('onPointerCancel:'));
    expect(setup, contains('NotificationListener<ScrollEndNotification>'));
    expect(setup, contains('notification.metrics.axis == Axis.vertical'));
  });
}
