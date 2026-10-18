import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('social authentication must not directly complete onboarding', () {
    final auth = File('lib/core/services/auth_service.dart').readAsStringSync();

    final googleStart = auth.indexOf('Future<AuthResult> signInWithGoogle()');
    final appleStart = auth.indexOf('Future<AuthResult> signInWithApple()');

    expect(googleStart, greaterThanOrEqualTo(0));
    expect(appleStart, greaterThan(googleStart));

    final googleMethod = auth.substring(googleStart, appleStart);
    final appleMethod = auth.substring(appleStart);

    expect(googleMethod, isNot(contains('setOnboardingComplete(true)')));

    expect(appleMethod, isNot(contains('setOnboardingComplete(true)')));
  });

  test('post-auth routing must evaluate onboarding before home', () {
    final authScreen = File(
      'lib/features/auth/screens/auth_screen.dart',
    ).readAsStringSync();

    expect(
      authScreen,
      contains('getPostAuthRoute'),
      reason:
          'Successful auth must resolve one canonical post-auth destination instead of navigating directly to /home.',
    );
  });
}
