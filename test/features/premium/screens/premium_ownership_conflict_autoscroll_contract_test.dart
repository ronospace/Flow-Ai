import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final paywall = File(
    'lib/features/premium/screens/premium_paywall_screen.dart',
  ).readAsStringSync();

  test('ownership conflict message has a stable reveal target', () {
    expect(
      paywall,
      contains('final GlobalKey _ownershipConflictKey = GlobalKey();'),
    );
    expect(paywall, contains('key: _ownershipConflictKey'));
  });

  test('status presentation automatically reveals the message', () {
    expect(
      paywall,
      contains('final conflictContext = _ownershipConflictKey.currentContext;'),
    );
    expect(paywall, contains('Scrollable.ensureVisible('));
    expect(paywall, contains('duration: const Duration(milliseconds: 350)'));
  });

  test('ownership conflict still uses the same status owner', () {
    expect(
      paywall,
      contains('_showRestoreStatus(ownershipConflict, autoClear: false);'),
    );
  });
}
