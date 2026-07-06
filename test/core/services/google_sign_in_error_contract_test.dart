import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Google authentication never exposes raw exceptions', () {
    final source = File(
      'lib/core/services/auth_service.dart',
    ).readAsStringSync();

    final googleMethodStart = source.indexOf(
      'Future<AuthResult> signInWithGoogle() async',
    );
    final googleMethodEnd = source.indexOf(
      'Future<AuthResult> signInWithApple() async',
    );

    expect(googleMethodStart, greaterThanOrEqualTo(0));
    expect(googleMethodEnd, greaterThan(googleMethodStart));

    final googleMethod = source.substring(googleMethodStart, googleMethodEnd);

    expect(
      googleMethod,
      isNot(contains("AuthResult.failure('Google sign-in failed:")),
    );
    expect(
      source,
      contains('We could not complete Google sign-in. Please try again.'),
    );
  });
}
