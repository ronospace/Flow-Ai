import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cloud identity preserves local-account isolation', () {
    final source = File(
      'lib/core/services/auth_service.dart',
    ).readAsStringSync();

    expect(source, contains('Future<User?> ensureCloudIdentity()'));
    expect(source, contains('await auth.signInAnonymously();'));
    expect(source, contains('!firebaseUser.isAnonymous'));
    expect(source, contains('await _auth?.signOut();'));

    final localAccountCheck = source.indexOf(
      'final localUser = await _localUserService!.getCurrentUser();',
    );
    final anonymousFallback = source.indexOf(
      'return firebaseUser;',
      localAccountCheck,
    );

    expect(localAccountCheck, greaterThanOrEqualTo(0));
    expect(anonymousFallback, greaterThan(localAccountCheck));
  });
}
