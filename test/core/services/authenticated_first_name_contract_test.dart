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
    'all sign-in authorities await identity synchronization before navigation',
    () {
      final screen = File(
        'lib/features/auth/screens/auth_screen.dart',
      ).readAsStringSync();
      final coordinator = File(
        'lib/features/auth/services/auth_provider_coordinator.dart',
      ).readAsStringSync();

      const screenSync = 'await _settingsProvider.forceUserDataSync();';
      const providerSync =
          'await context.read<SettingsProvider>().forceUserDataSync();';

      // Credential and biometric authentication remain owned by AuthScreen.
      expect(occurrences(screen, screenSync), 2);

      // Apple and Google share one centralized provider success authority.
      expect(
        coordinator.contains(
          'AuthProviderType.apple => await _authService.signInWithApple()',
        ),
        isTrue,
      );
      expect(
        coordinator.contains(
          'AuthProviderType.google => await _authService.signInWithGoogle()',
        ),
        isTrue,
      );
      expect(occurrences(coordinator, providerSync), 1);

      final providerSyncIndex = coordinator.indexOf(providerSync);
      final providerRouteIndex = coordinator.indexOf(
        'AppStateService().getPostAuthRoute(',
      );

      expect(providerSyncIndex, greaterThanOrEqualTo(0));
      expect(providerRouteIndex, greaterThan(providerSyncIndex));
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

    final resolver = File(
      'lib/core/utils/user_display_name_resolver.dart',
    ).readAsStringSync();

    expect(profile.contains('preferences.displayName'), isTrue);
    expect(home.contains('UserDisplayNameResolver.resolveIdentity('), isTrue);
    expect(
      home.contains('final greetingName = identity.greetingName;'),
      isTrue,
    );
    expect(resolver.contains('final String displayName;'), isTrue);
    expect(resolver.contains('final String greetingName;'), isTrue);
    expect(settings.contains('Syncing user data: \$userData'), isFalse);
  });
}
