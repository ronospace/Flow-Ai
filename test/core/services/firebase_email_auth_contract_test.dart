import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final authSource = File(
    'lib/core/services/auth_service.dart',
  ).readAsStringSync();
  final screenSource = File(
    'lib/features/auth/screens/auth_screen.dart',
  ).readAsStringSync();

  test('email authentication uses active Firebase operations', () {
    expect(authSource, contains('await auth.createUserWithEmailAndPassword('));
    expect(authSource, contains('await auth.signInWithEmailAndPassword('));
    expect(authSource, contains('await auth.sendPasswordResetEmail('));

    expect(
      authSource,
      isNot(
        contains(
          '//     final UserCredential result = '
          'await _auth!.createUserWithEmailAndPassword',
        ),
      ),
    );
    expect(
      authSource,
      isNot(
        contains(
          '//     final UserCredential result = '
          'await _auth!.signInWithEmailAndPassword',
        ),
      ),
    );
    expect(
      authSource,
      isNot(contains('//     await _auth!.sendPasswordResetEmail')),
    );
  });

  test('new email accounts never downgrade to local account creation', () {
    final signUpStart = authSource.indexOf(
      'Future<AuthResult> signUpWithEmail({',
    );
    final signInStart = authSource.indexOf(
      'Future<AuthResult> signInWithEmail({',
    );

    expect(signUpStart, greaterThanOrEqualTo(0));
    expect(signInStart, greaterThan(signUpStart));

    final signUpBlock = authSource.substring(signUpStart, signInStart);

    expect(signUpBlock, contains('await auth.createUserWithEmailAndPassword('));
    expect(signUpBlock, isNot(contains('localService.createUser(')));
    expect(signUpBlock, isNot(contains("'provider': 'local'")));
    expect(
      signUpBlock,
      contains('New production accounts must be created by Firebase'),
    );
  });

  test(
    'legacy local sign-in remains explicit and general fallback is disabled',
    () {
      final signInStart = authSource.indexOf(
        'Future<AuthResult> signInWithEmail({',
      );
      final googleStart = authSource.indexOf(
        'Future<AuthResult> signInWithGoogle()',
        signInStart,
      );

      expect(signInStart, greaterThanOrEqualTo(0));
      expect(googleStart, greaterThan(signInStart));

      final signInBlock = authSource.substring(signInStart, googleStart);

      final legacyGate = signInBlock.indexOf(
        'final shouldUseLegacyLocalAccount =',
      );
      final legacySignIn = signInBlock.indexOf(
        'await localService.signInUser(',
      );
      final firebaseSignIn = signInBlock.indexOf(
        'await auth.signInWithEmailAndPassword(',
      );

      expect(legacyGate, greaterThanOrEqualTo(0));
      expect(legacySignIn, greaterThan(legacyGate));
      expect(firebaseSignIn, greaterThan(legacySignIn));

      final afterFirebase = signInBlock.substring(firebaseSignIn);
      expect(afterFirebase, isNot(contains('await localService.signInUser(')));

      expect(
        signInBlock,
        contains('General sign-in must never silently downgrade'),
      );
      expect(authSource, contains("case 'invalid-credential':"));
      expect(authSource, contains("case 'network-request-failed':"));
    },
  );

  test('device lookup does not probe Firebase by creating temporary users', () {
    expect(screenSource, contains('isEmailKnownOnDevice('));
    expect(screenSource, isNot(contains('isEmailRegistered(')));
    expect(authSource, isNot(contains('temp_password_to_check_existence')));
  });

  test('password reset actions are full width and 48 pixels high', () {
    expect(
      screenSource,
      contains('crossAxisAlignment: CrossAxisAlignment.stretch'),
    );
    expect(screenSource, contains("'Send Reset Link'"));
    expect(screenSource, contains('isExpanded: true'));
    expect(screenSource, contains('size: ModernButtonSize.large'));
    expect(screenSource, contains("'If an account exists for this email, '"));
    expect(screenSource, contains("'a reset link has been sent.'"));
    expect(screenSource, contains('dialogContext.mounted'));
    expect(
      screenSource,
      contains('whenComplete(resetEmailController.dispose)'),
    );
    expect(authSource, contains('at least eight characters'));
  });

  test('Firebase identity persistence is account-scoped', () {
    expect(
      authSource,
      contains("existingData?['uid']?.toString() == user.uid"),
    );
    expect(authSource, contains('if (!sameStoredIdentity)'));
    expect(
      authSource,
      contains("existingData?['username'] ?? user.displayName"),
    );
  });

  test('Firebase signup survives optional profile update failure', () {
    final updateIndex = authSource.indexOf(
      'await user.updateDisplayName(normalizedDisplayName);',
    );
    final warningIndex = authSource.indexOf(
      'Firebase account created, but display-name update failed:',
    );
    final successIndex = authSource.indexOf(
      'return AuthResult.success(user);',
      warningIndex,
    );

    expect(updateIndex, greaterThanOrEqualTo(0));
    expect(warningIndex, greaterThan(updateIndex));
    expect(successIndex, greaterThan(warningIndex));
  });

  test('device identity comparison is case-insensitive', () {
    expect(authSource, contains("storedEmail == email.trim().toLowerCase()"));
  });

  test('obsolete Firebase-disabled comments are removed', () {
    expect(
      authSource,
      isNot(contains('Firebase temporarily disabled for iOS build')),
    );
  });
}
