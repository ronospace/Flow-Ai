import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final auth = File(
    'lib/features/auth/screens/auth_screen.dart',
  ).readAsStringSync();

  test('email auth uses one minimal form surface', () {
    expect(auth, isNot(contains('_buildProviderOnlyEntry')));
    expect(auth, isNot(contains('_buildTabSelector')));
    expect(auth, isNot(contains('_buildAuthModeHeading(theme)')));
    expect(auth, contains('_buildAuthForm(theme, l10n)'));
  });

  test('email auth avoids redundant brand and mode copy', () {
    expect(auth, contains('FlowAiLogo('));
    expect(auth, contains('showWordmark: false'));
    expect(auth, isNot(contains("'Welcome back to Flow Ai'")));
    expect(auth, isNot(contains("'Create your Flow Ai account'")));
  });

  test('account mode switching remains lightweight', () {
    expect(auth, contains("'New here?'"));
    expect(auth, contains("'Already have an account?'"));
    expect(auth, contains("'Create account'"));
    expect(auth, contains("'Sign in'"));
    expect(auth, contains('_switchAuthMode(!_isLogin)'));
  });

  test(
    'credential auth surface includes providers before biometric and E-mail',
    () {
      expect(auth, contains('_buildSocialLogin(theme)'));

      final formStart = auth.indexOf('Widget _buildAuthForm');
      final social = auth.indexOf('_buildSocialLogin(theme)', formStart);
      final biometric = auth.indexOf('BiometricButton(', formStart);
      final email = auth.indexOf("labelText: 'E-mail address:'", formStart);

      expect(social, greaterThan(formStart));
      expect(biometric, greaterThan(social));
      expect(email, greaterThan(biometric));
      expect(auth, contains('BiometricButton('));
      expect(auth, contains("'E-mail address:'"));
      expect(auth, contains("'Password:'"));
    },
  );

  test('provider cancellation no longer depends on pushed route state', () {
    expect(auth, isNot(contains('_returnFromInitialProviderFailure')));
    expect(auth, isNot(contains('initialProvider')));
    expect(auth, contains('result.isCancelled'));
  });

  test('canonical post-auth authority remains unchanged', () {
    expect(auth, contains('AppStateService().getPostAuthRoute('));
    expect(auth, contains('PendingDeepLinkService.consumePendingRoute()'));
  });
}
