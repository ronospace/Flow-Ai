import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Track preserves top safe area but delegates bottom clearance to shell',
    () {
      final source = File(
        'lib/features/cycle/screens/tracking_screen.dart',
      ).readAsStringSync();

      expect(source, contains('child: SafeArea('));
      expect(source, contains('bottom: false,'));
    },
  );

  test('shell remains authoritative bottom safe-area owner', () {
    final router = File('lib/core/routing/app_router.dart').readAsStringSync();

    expect(router, contains('bottomNavigationBar: SafeArea('));
    expect(router, contains('top: false,'));
  });
}
