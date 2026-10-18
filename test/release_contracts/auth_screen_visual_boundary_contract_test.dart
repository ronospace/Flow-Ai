import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/features/auth/screens/auth_screen.dart',
  ).readAsStringSync();

  test('auth behavior remains owned by current production handlers', () {
    expect(source, contains('_authService.signInWithEmail('));
    expect(source, contains('_authService.signUpWithEmail('));
    expect(source, contains('_authService.isEmailKnownOnDevice('));
    expect(source, contains('_handleGoogleSignIn'));
    expect(source, contains('_handleAppleSignIn'));
    expect(source, contains('_handleBiometricLogin'));
    expect(source, contains('_handleForgotPassword'));
    expect(source, contains('AppStateService().getPostAuthRoute('));
    expect(source, contains('PendingDeepLinkService.consumePendingRoute()'));
  });

  test('auth state and validation ownership remain intact', () {
    expect(source, contains('_isLogin = widget.initialIsLogin'));
    expect(source, isNot(contains('_handleInitialProvider')));
    expect(source, isNot(contains('initialProvider')));
    expect(source, contains('_emailError'));
    expect(source, contains('_passwordError'));
    expect(source, contains('_displayNameError'));
    expect(source, contains('_confirmPasswordError'));
    expect(source, contains("ValueKey('auth_inline_error')"));
  });

  test('auth routes retain login signup and generic auth entry', () {
    final router = File('lib/core/routing/app_router.dart').readAsStringSync();

    expect(router, contains("path: '/auth/login'"));
    expect(router, contains('initialIsLogin: true'));
    expect(router, contains("path: '/auth/signup'"));
    expect(router, contains('initialIsLogin: false'));
    expect(router, contains("path: '/auth'"));
  });
}
