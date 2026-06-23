import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

int occurrences(String source, String value) {
  return value.allMatches(source).length;
}

void main() {
  final auth = File('lib/core/services/auth_service.dart').readAsStringSync();

  final resolver = File(
    'lib/core/utils/user_display_name_resolver.dart',
  ).readAsStringSync();

  test('Firebase identity is mapped before LocalUser fallback', () {
    expect(occurrences(auth, '    if (currentUser is User) {'), 1);

    expect(occurrences(auth, '    } else if (currentUser is LocalUser) {'), 1);

    expect(
      auth.contains('    // Handle Firebase User (disabled for iOS build)'),
      isFalse,
    );
  });

  test('Google persistence retains provider name and avatar', () {
    expect(
      occurrences(auth, "'displayName': userCredential.user?.displayName,"),
      1,
    );

    expect(occurrences(auth, "'photoURL': userCredential.user?.photoURL,"), 1);
  });

  test('explicit email token precedes provider fallback', () {
    expect(
      resolver.indexOf('firstNameFromEmail(email)'),
      lessThan(resolver.indexOf('firstNameFromDisplayName(displayName)')),
    );

    expect(
      resolver.contains(r"RegExp(r'[._+\-\s]').hasMatch(localPart)"),
      isTrue,
    );
  });

  test(
    'all sign-in paths await identity synchronization before navigation',
    () {
      final screen = File(
        'lib/features/auth/screens/auth_screen.dart',
      ).readAsStringSync();

      expect(
        occurrences(screen, 'await _settingsProvider.forceUserDataSync();'),
        3,
      );
    },
  );

  test('profile and greeting use separate identity fields', () {
    final home = File(
      'lib/features/cycle/screens/home_screen.dart',
    ).readAsStringSync();
    final profile = File(
      'lib/features/settings/widgets/profile_section.dart',
    ).readAsStringSync();
    final settings = File(
      'lib/features/settings/providers/settings_provider.dart',
    ).readAsStringSync();

    expect(profile.contains('preferences.displayName'), isTrue);
    expect(home.contains('preferences.greetingName'), isTrue);
    expect(settings.contains('Syncing user data: \$userData'), isFalse);
  });
}
