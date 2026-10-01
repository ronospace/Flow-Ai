import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('connection title does not duplicate Connect action', () {
    final card = File(
      'lib/features/health/widgets/healthkit_connection_card.dart',
    ).readAsStringSync();

    expect(card, contains("'Apple HealthKit'"));
    expect(card, contains("'Health Connect'"));

    expect(card, isNot(contains("'Connect \$platformName'")));
    expect(card, isNot(contains('Connect Apple HealthKit')));
    expect(card, isNot(contains('Connect Health Connect')));
  });

  test('permission actions use equal expanded widths', () {
    final dialog = File(
      'lib/features/health/widgets/healthkit_permission_dialog.dart',
    ).readAsStringSync();

    expect(RegExp(r'width:\s*124').allMatches(dialog).length, equals(2));
    expect(dialog, contains("'Not Now'"));
    expect(dialog, contains("'Continue'"));
  });

  test('permission buttons retain centralized styles', () {
    final dialog = File(
      'lib/features/health/widgets/healthkit_permission_dialog.dart',
    ).readAsStringSync();

    expect(dialog, contains('AppTheme.dialogSecondaryActionStyle(theme)'));
    expect(dialog, contains('AppTheme.dialogPrimaryActionStyle(theme)'));
  });
}
