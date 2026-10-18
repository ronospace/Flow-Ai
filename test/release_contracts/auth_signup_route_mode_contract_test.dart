import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    '/auth/signup must not construct the same implicit login-mode AuthScreen',
    () {
      final router = File(
        'lib/core/routing/app_router.dart',
      ).readAsStringSync();

      final authScreen = File(
        'lib/features/auth/screens/auth_screen.dart',
      ).readAsStringSync();

      expect(router, contains("path: '/auth/signup'"));

      final signupRouteStart = router.indexOf("path: '/auth/signup'");
      expect(signupRouteStart, greaterThanOrEqualTo(0));

      final signupRouteWindow = router.substring(
        signupRouteStart,
        (signupRouteStart + 500).clamp(0, router.length),
      );

      expect(authScreen, contains('final bool initialIsLogin;'));

      expect(authScreen, contains('_isLogin = widget.initialIsLogin;'));

      expect(signupRouteWindow, contains('AuthScreen(initialIsLogin: false)'));
    },
  );
}
