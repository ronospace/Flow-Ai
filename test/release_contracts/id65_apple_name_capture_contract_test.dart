import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final auth = File('lib/core/services/auth_service.dart').readAsStringSync();
  final screen = File(
    'lib/features/auth/screens/auth_screen.dart',
  ).readAsStringSync();

  test('Apple requests structured provider name automatically', () {
    expect(auth, contains('AppleIDAuthorizationScopes.fullName'));
    expect(auth, contains('appleCredential.givenName'));
    expect(auth, contains('appleCredential.familyName'));
  });

  test('Apple preserves same-account stored greeting', () {
    expect(auth, contains('storedGreetingName'));
    expect(auth, contains('resolvedGreetingName'));
    expect(auth, contains("matchedStoredData?['greetingName']"));
  });

  test('Apple flow has no manual name recovery dialog', () {
    expect(screen, isNot(contains('What should Flow Ai call you?')));
    expect(screen, isNot(contains('Name for your greetings')));
    expect(screen, isNot(contains('shouldPromptForAppleNameRecovery')));
    expect(screen, isNot(contains('saveAppleNameRecovery')));
  });
}
