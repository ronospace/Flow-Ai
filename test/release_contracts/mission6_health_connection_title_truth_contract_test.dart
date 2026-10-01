import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final card = File(
    'lib/features/health/widgets/healthkit_connection_card.dart',
  ).readAsStringSync();

  final dialog = File(
    'lib/features/health/widgets/healthkit_permission_dialog.dart',
  ).readAsStringSync();

  test('platform identity is never prefixed by Connect', () {
    for (final forbidden in [
      "'Connect \${platformName}'",
      '"Connect \${platformName}"',
      "'Connect \$platformName'",
      '"Connect \$platformName"',
      'Connect Apple HealthKit',
      'Connect Health Connect',
    ]) {
      expect(card, isNot(contains(forbidden)));
    }
  });

  test('native platform titles remain available', () {
    expect(card, contains("'Apple HealthKit'"));
    expect(card, contains("'Health Connect'"));
    expect(card, contains('platformName'));
  });

  test('connection actions remain semantically separate', () {
    expect(card, contains("'Connect'"));
    expect(card, contains("'Disconnect'"));
    expect(card, contains("'Install Health Connect'"));
  });

  test('permission dialog keeps equal widened actions', () {
    expect(RegExp(r'width:\s*124').allMatches(dialog).length, equals(2));
    expect(dialog, contains("'Not Now'"));
    expect(dialog, contains("'Continue'"));
  });
}
