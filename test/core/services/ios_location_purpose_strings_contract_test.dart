import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('iOS location privacy purpose strings are configured', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();

    for (final key in <String>[
      'NSLocationWhenInUseUsageDescription',
      'NSLocationAlwaysAndWhenInUseUsageDescription',
    ]) {
      final pattern = RegExp(
        '<key>\\s*${RegExp.escape(key)}\\s*</key>\\s*'
        '<string>\\s*[^<]{20,}\\s*</string>',
        multiLine: true,
      );

      expect(pattern.hasMatch(plist), isTrue);
    }
  });
}
