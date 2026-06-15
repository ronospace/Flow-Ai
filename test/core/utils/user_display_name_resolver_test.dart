import 'package:flow_ai/core/utils/user_display_name_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserDisplayNameResolver', () {
    test('keeps the greeting to Leah for the Leah Brown account', () {
      expect(
        UserDisplayNameResolver.resolve(
          email: 'tester1@example.invalid',
          displayName: 'Leah Brown',
        ),
        'Leah',
      );
    });

    test('keeps the greeting to Dtb for the Dtb Rono account', () {
      expect(
        UserDisplayNameResolver.resolve(
          email: 'tester3@example.invalid',
          displayName: 'Dtb Rono',
        ),
        'Dtb',
      );
    });

    test('does not expose a concatenated email local part', () {
      expect(
        UserDisplayNameResolver.resolve(
          email: 'tester1@example.invalid',
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
          email: 'tester2@example.invalid',
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
  });
}
