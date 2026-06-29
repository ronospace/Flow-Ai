import 'package:flow_ai/core/utils/user_display_name_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserDisplayNameResolver', () {
    test('keeps the greeting to Leah for the Leah Brown account', () {
      expect(
        UserDisplayNameResolver.resolve(
          email: 'leahbrown0488@gmail.com',
          displayName: 'Leah Brown',
        ),
        'Leah',
      );
    });

    test('keeps the greeting to Dtb for the Dtb Rono account', () {
      expect(
        UserDisplayNameResolver.resolve(
          email: 'dtbrono@gmail.com',
          displayName: 'Dtb Rono',
        ),
        'Dtb',
      );
    });

    test('does not expose a concatenated email local part', () {
      expect(
        UserDisplayNameResolver.resolve(
          email: 'leahbrown0488@gmail.com',
          displayName: null,
        ),
        isEmpty,
      );
    });

    test('uses the first email segment before placeholder display name', () {
      expect(
        UserDisplayNameResolver.resolve(
          email: 'dtb.gueye@example.com',
          displayName: 'User',
        ),
        'Dtb',
      );
    });

    test('supports underscore-separated email names', () {
      expect(
        UserDisplayNameResolver.resolve(
          email: 'mouha_gueye@hotmail.com',
          displayName: null,
        ),
        'Mouha',
      );
    });

    test('removes email plus-addressing', () {
      expect(
        UserDisplayNameResolver.resolve(
          email: 'ALICE+health@example.com',
          displayName: 'Different Name',
        ),
        'Alice',
      );
    });

    test('uses the first profile name when email is unavailable', () {
      expect(
        UserDisplayNameResolver.resolve(
          email: null,
          displayName: 'Mohameth Gueye',
        ),
        'Mohameth',
      );
    });

    test('does not expose User as a personalized name', () {
      expect(
        UserDisplayNameResolver.resolve(email: null, displayName: 'User'),
        isEmpty,
      );
    });

    test('rejects the synthetic local account identifier', () {
      expect(
        UserDisplayNameResolver.resolve(email: 'local.ai', displayName: null),
        isEmpty,
      );
    });

    test('keeps the full profile name and derives the greeting first name', () {
      final identity = UserDisplayNameResolver.resolveIdentity(
        userId: 'uid-1',
        email: 'mouha_gueye@hotmail.com',
        displayName: 'Mohameth Gueye',
        existingUserId: '',
        existingDisplayName: '',
      );

      expect(identity.displayName, 'Mohameth Gueye');
      expect(identity.greetingName, 'Mohameth');
    });

    test('preserves a saved name only for the same authenticated user', () {
      final identity = UserDisplayNameResolver.resolveIdentity(
        userId: 'uid-1',
        email: 'accountwithoutseparator@example.com',
        displayName: null,
        existingUserId: 'uid-1',
        existingDisplayName: 'Leah Brown',
      );

      expect(identity.displayName, 'Leah Brown');
      expect(identity.greetingName, 'Leah');
    });

    test('does not leak the previous account name after account switching', () {
      final identity = UserDisplayNameResolver.resolveIdentity(
        userId: 'uid-2',
        email: 'new.user@example.com',
        displayName: null,
        existingUserId: 'uid-1',
        existingDisplayName: 'Previous Person',
      );

      expect(identity.displayName, 'New');
      expect(identity.greetingName, 'New');
    });
  });
}
