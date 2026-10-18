import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final logo = File('lib/core/widgets/flow_ai_logo.dart').readAsStringSync();

  final choice = File(
    'lib/features/auth/screens/auth_choice_screen.dart',
  ).readAsStringSync();

  final auth = File(
    'lib/features/auth/screens/auth_screen.dart',
  ).readAsStringSync();

  final splash = File(
    'lib/features/onboarding/screens/splash_screen.dart',
  ).readAsStringSync();

  test('canonical asset has one shared widget owner', () {
    expect(logo, contains("'assets/images/flow_ai_launch_logo.png'"));

    for (final source in [choice, auth, splash]) {
      expect(
        source,
        isNot(contains("'assets/images/flow_ai_launch_logo.png'")),
      );
    }
  });

  test('active first-run surfaces delegate to FlowAiLogo', () {
    expect(choice, contains('FlowAiLogo('));
    expect(auth, contains('FlowAiLogo('));
    expect(splash, contains('FlowAiLogo('));
  });

  test('shared brand owner carries canonical Flow Ai identity', () {
    expect(logo, contains("'Flow Ai'"));
    expect(choice, contains('FlowAiLogo('));
    expect(auth, contains('FlowAiLogo('));
    expect(splash, contains('FlowAiLogo('));
  });
}
