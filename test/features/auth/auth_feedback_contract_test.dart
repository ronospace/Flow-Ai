import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('authentication validation uses inline professional feedback', () {
    final source = File(
      'lib/features/auth/screens/auth_screen.dart',
    ).readAsStringSync();

    expect(source, contains('errorText: _emailError'));
    expect(source, contains('errorText: _passwordError'));
    expect(source, contains('errorText: _displayNameError'));
    expect(source, contains('errorText: _confirmPasswordError'));
    expect(source, contains("ValueKey('auth_inline_error')"));
    expect(
      source,
      isNot(contains("_showErrorMessage('Please enter your email address');")),
    );
  });
}
