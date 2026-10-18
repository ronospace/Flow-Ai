import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final auth = File(
    'lib/features/auth/screens/auth_screen.dart',
  ).readAsStringSync();

  test('E-mail divider is independent of biometric availability', () {
    final start = auth.indexOf('Widget _buildAuthForm');
    final end = auth.indexOf('Widget _buildInlineFormError', start);
    final form = auth.substring(start, end);

    expect(
      RegExp(
        r'if \(_biometricsAvailable && _isLogin\)',
      ).allMatches(form).length,
      1,
    );

    expect(form, contains('_buildManualDivider(theme)'));
  });

  test('approved credential hierarchy remains intact', () {
    final start = auth.indexOf('Widget _buildAuthForm');
    final end = auth.indexOf('Widget _buildInlineFormError', start);
    final form = auth.substring(start, end);

    final provider = form.indexOf('_buildSocialLogin(theme)');
    final biometric = form.indexOf('BiometricButton(');
    final divider = form.indexOf('_buildManualDivider(theme)');
    final email = form.indexOf("labelText: 'E-mail address:'");

    expect(provider, greaterThanOrEqualTo(0));
    expect(biometric, greaterThan(provider));
    expect(divider, greaterThan(biometric));
    expect(email, greaterThan(divider));
  });
}
