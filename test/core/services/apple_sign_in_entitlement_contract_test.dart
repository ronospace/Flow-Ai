import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('iOS release declares Sign in with Apple entitlement', () {
    final entitlements =
        File('ios/Runner/Runner.entitlements').readAsStringSync();

    expect(
      entitlements,
      contains('<key>com.apple.developer.applesignin</key>'),
    );
    expect(entitlements, contains('<string>Default</string>'));
  });
}
