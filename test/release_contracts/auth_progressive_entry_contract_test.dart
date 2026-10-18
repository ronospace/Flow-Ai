import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/features/auth/screens/auth_choice_screen.dart',
  ).readAsStringSync();

  test('auth choice keeps one clean canonical brand hierarchy', () {
    expect(source, contains('FlowAiLogo('));
    expect(source, isNot(contains("'assets/images/flow_ai_launch_logo.png'")));
    expect(source, contains('showWordmark: false'));
  });

  test('story stage remains presentation-only', () {
    expect(source, contains("'Understand your health'"));
    expect(source, contains("'See the patterns'"));
    expect(source, contains("'Feel more in control'"));

    expect(
      source,
      contains(
        "child: _showAllMethods ? _buildExpandedMethods() : _buildPrimaryEntry()",
      ),
    );

    expect(
      source,
      contains("_SecondaryButton(label: 'Continue', onPressed: _showMethods)"),
    );
  });

  test('provider actions are separated from storytelling stage', () {
    expect(source, contains('Widget _buildExpandedMethods()'));
    expect(source, contains("'Continue with Apple'"));
    expect(source, contains("'Continue with Google'"));
    expect(source, contains("'Continue with E-mail'"));
  });

  test('provider actions launch directly from AuthChoice', () {
    expect(
      source,
      isNot(contains("context.push('/auth/login?provider=\$provider')")),
    );
    expect(source, contains('AuthProviderCoordinator().authenticate'));
  });

  test('Apple is conditionally available on iOS method-selection stage', () {
    expect(source, contains('if (_isIOS) ...['));
    expect(source, contains("onPressed: () => _openProvider('apple')"));
  });

  test('Google remains available on method-selection stage', () {
    expect(source, contains("onPressed: () => _openProvider('google')"));
  });

  test('email remains an explicit method-selection action', () {
    expect(source, contains("'Continue with E-mail'"));
    expect(source, contains('onPressed: _openEmail'));
  });

  test(
    'story stage keeps platform-appropriate primary provider plus Continue',
    () {
      expect(source, contains("final provider = isIOS ? 'apple' : 'google';"));
      expect(source, contains("'Continue with Apple'"));
      expect(source, contains("'Continue with Google'"));
      expect(source, contains("label: 'Continue'"));
      expect(source, contains('onPressed: _showMethods'));
    },
  );
}
