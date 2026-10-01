import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Account Management resolves singleton AuthService without Provider lookup',
    () {
      final source = File(
        'lib/features/settings/screens/account_management_screen.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('Provider.of<AuthService>')));

      expect(
        RegExp(r'AuthService\(\)').allMatches(source).length,
        greaterThanOrEqualTo(2),
      );
    },
  );

  test(
    'account deletion resolves dependencies before entering deleting state',
    () {
      final source = File(
        'lib/features/settings/screens/account_management_screen.dart',
      ).readAsStringSync();

      final start = source.indexOf(
        'Future<void> _performAccountDeletion() async',
      );
      expect(start, greaterThanOrEqualTo(0));

      final end = source.indexOf(
        'Future<void> _showDeleteAccountDialog() async',
        start,
      );
      expect(end, greaterThan(start));

      final block = source.substring(start, end);

      final authPos = block.indexOf('final auth = AuthService();');
      final settingsPos = block.indexOf(
        'Provider.of<SettingsProvider>(context, listen: false)',
      );
      final statePos = block.indexOf('_isDeletingAccount = true;');
      final deletePos = block.indexOf('await auth.deleteAccount();');

      expect(authPos, greaterThanOrEqualTo(0));
      expect(settingsPos, greaterThanOrEqualTo(0));
      expect(statePos, greaterThan(authPos));
      expect(statePos, greaterThan(settingsPos));
      expect(deletePos, greaterThan(statePos));
    },
  );
}
