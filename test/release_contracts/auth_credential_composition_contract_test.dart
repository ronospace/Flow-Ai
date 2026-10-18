import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final auth = File(
    'lib/features/auth/screens/auth_screen.dart',
  ).readAsStringSync();

  final layout = File(
    'lib/core/layout/app_layout_metrics.dart',
  ).readAsStringSync();

  final biometric = File(
    'lib/features/auth/widgets/biometric_button.dart',
  ).readAsStringSync();

  test('credential card uses one horizontal composition boundary', () {
    expect(auth, contains('crossAxisAlignment: CrossAxisAlignment.stretch'));
    expect(auth, contains('maxWidth: AppLayoutMetrics.authCardMaxWidth'));
    expect(layout, contains('static const double authCardMaxWidth = 430;'));
  });

  test('provider actions are rendered before biometric and credentials', () {
    final form = auth.indexOf('Widget _buildAuthForm');
    final provider = auth.indexOf('_buildSocialLogin(theme)', form);
    final biometricIndex = auth.indexOf('BiometricButton(', form);
    final email = auth.indexOf("labelText: 'E-mail address:'", form);

    expect(provider, greaterThan(form));
    expect(biometricIndex, greaterThan(provider));
    expect(email, greaterThan(biometricIndex));
  });

  test('Android provider hierarchy is Google only', () {
    expect(auth, contains("label: 'Continue with Google'"));
    expect(
      auth,
      contains('PlatformService().platformInfo.platform == TargetPlatform.iOS'),
    );
  });

  test('iOS and Android credential providers are mutually exclusive', () {
    final social = auth.indexOf('Widget _buildSocialLogin');
    final bio = auth.indexOf('Future<void> _handleBiometricLogin', social);
    final source = auth.substring(social, bio);

    expect(source, contains('if (isIOS)'));
    expect(source, contains('else'));
    expect(source, contains("label: 'Continue with Apple'"));
    expect(source, contains("label: 'Continue with Google'"));
    expect(source, isNot(contains('authAppleGoogleGap')));
  });

  test('primary CTA and biometric align to card content width', () {
    expect(
      auth,
      contains(
        'width: double.infinity,\n'
        '                  height: AppLayoutMetrics.authPrimaryActionHeight,',
      ),
    );
    expect(
      layout,
      contains('static const double authPrimaryActionHeight = 52;'),
    );
    expect(
      biometric,
      contains('width: double.infinity,\n          height: 46,'),
    );
  });

  test('E-mail terminology remains canonical', () {
    expect(auth, contains("'Or use E-mail'"));
    expect(auth, contains("'E-mail address:'"));
    expect(auth, contains("'Enter your E-mail'"));
  });
}
