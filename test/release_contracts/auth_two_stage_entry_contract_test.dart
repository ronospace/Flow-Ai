import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final choice = File(
    'lib/features/auth/screens/auth_choice_screen.dart',
  ).readAsStringSync();

  final auth = File(
    'lib/features/auth/screens/auth_screen.dart',
  ).readAsStringSync();

  test('primary stage uses platform-appropriate provider', () {
    expect(choice, contains("final provider = isIOS ? 'apple' : 'google';"));
    expect(choice, contains("'Continue with Apple'"));
    expect(choice, contains("'Continue with Google'"));
  });

  test('primary stage retains generic Continue for other methods', () {
    expect(choice, contains("label: 'Continue'"));
    expect(choice, contains('onPressed: _showMethods'));
  });

  test('expanded methods retain all valid choices', () {
    expect(choice, contains('Widget _buildExpandedMethods()'));
    expect(choice, contains("'Continue with Apple'"));
    expect(choice, contains("'Continue with Google'"));
    expect(choice, contains("'Continue with E-mail'"));
    expect(choice, contains('if (_isIOS) ...['));
  });

  test('provider selection launches directly from AuthChoice', () {
    expect(
      choice,
      isNot(contains("context.push('/auth/login?provider=\$provider')")),
    );
    expect(choice, contains('AuthProviderCoordinator().authenticate'));
  });

  test('credential auth surface owns the approved provider hierarchy', () {
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
  });

  test('canonical post-auth routing remains unchanged', () {
    expect(auth, contains('AppStateService().getPostAuthRoute('));
  });

  test('story remains visible when additional methods are revealed', () {
    final messageStart = choice.indexOf('Widget _buildMessage()');
    final progressStart = choice.indexOf(
      'Widget _buildStoryProgress()',
      messageStart,
    );

    expect(messageStart, greaterThanOrEqualTo(0));
    expect(progressStart, greaterThan(messageStart));

    final messageBlock = choice.substring(messageStart, progressStart);

    expect(messageBlock, contains('_buildLaunchLogo()'));
    expect(messageBlock, contains('_buildStoryContent()'));
    expect(messageBlock, contains('_buildStoryProgress()'));
    expect(messageBlock, isNot(contains('if (_showAllMethods)')));
  });
}
