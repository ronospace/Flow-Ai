import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Home greeting uses the centralized authenticated identity resolver',
    () {
      final home = File(
        'lib/features/cycle/screens/home_screen.dart',
      ).readAsStringSync();

      expect(home, contains('UserDisplayNameResolver.resolveIdentity('));

      expect(home, contains('userId: user?.uid'));
      expect(home, contains('email: user?.email'));
      expect(home, contains('displayName: user?.displayName'));

      expect(home, contains('existingUserId: preferences.userId'));

      expect(home, contains('existingDisplayName: preferences.displayName'));

      expect(
        home,
        isNot(
          contains(
            'final greetingName = '
            'settingsProvider.preferences.greetingName;',
          ),
        ),
      );
    },
  );

  test('Home greeting and date stay on one responsive line', () {
    final home = File(
      'lib/features/cycle/screens/home_screen.dart',
    ).readAsStringSync();

    final greetingStart = home.indexOf("'\$personalizedGreeting");

    expect(greetingStart, isNonNegative);

    final greetingRegion = home.substring(
      greetingStart,
      (greetingStart + 600).clamp(0, home.length),
    );

    expect(greetingRegion, contains('maxLines: 1'));
    expect(greetingRegion, contains('overflow: TextOverflow.ellipsis'));

    final dateStart = home.indexOf("DateFormat('EEEE, MMMM d')");

    expect(dateStart, isNonNegative);

    final dateRegion = home.substring(
      dateStart,
      (dateStart + 500).clamp(0, home.length),
    );

    expect(dateRegion, contains('maxLines: 1'));
    expect(dateRegion, contains('overflow: TextOverflow.ellipsis'));
  });
}
