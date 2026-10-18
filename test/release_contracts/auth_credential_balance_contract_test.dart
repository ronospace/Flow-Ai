import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final auth = File(
    'lib/features/auth/screens/auth_screen.dart',
  ).readAsStringSync();

  final layout = File(
    'lib/core/layout/app_layout_metrics.dart',
  ).readAsStringSync();

  test('Flow Ai wordmark is inside card before providers', () {
    final form = auth.indexOf('Widget _buildAuthForm');
    final wordmark = auth.indexOf("'Flow Ai'", form);
    final provider = auth.indexOf('_buildSocialLogin(theme)', form);

    expect(wordmark, greaterThan(form));
    expect(provider, greaterThan(wordmark));
  });

  test('standalone auth logo is intentionally prominent', () {
    expect(
      auth,
      contains(
        'FlowAiLogo(size: AppLayoutMetrics.authLogoSize, showWordmark: false)',
      ),
    );
    expect(layout, contains('static const double authLogoSize = 84;'));
  });

  test('provider to biometric gap uses centralized compact spacing', () {
    final form = auth.indexOf('Widget _buildAuthForm');
    final bio = auth.indexOf('BiometricButton(', form);
    final prefix = auth.substring(form, bio);

    expect(prefix, contains('const SizedBox(height: AppLayoutMetrics.gap)'));
  });

  test('field rhythm remains larger than provider biometric rhythm', () {
    expect(
      auth,
      contains('const SizedBox(height: AppLayoutMetrics.authFieldGap)'),
    );
    expect(layout, contains('static const double authFieldGap = 16;'));
    expect(auth, contains("labelText: 'E-mail address:'"));
    expect(auth, contains("labelText: 'Password:'"));
  });

  test('credential provider is platform exclusive', () {
    final start = auth.indexOf('Widget _buildSocialLogin');
    final end = auth.indexOf('Future<void> _handleBiometricLogin', start);
    final social = auth.substring(start, end);

    expect(
      social,
      contains('PlatformService().platformInfo.platform == TargetPlatform.iOS'),
    );
    expect(social, contains("label: 'Continue with Apple'"));
    expect(social, contains("label: 'Continue with Google'"));
    expect(social, contains('if (isIOS)'));
    expect(social, contains('else'));
    expect(social, isNot(contains('authAppleGoogleGap')));
  });
}
