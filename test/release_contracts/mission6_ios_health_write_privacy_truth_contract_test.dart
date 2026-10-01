import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final info = File('ios/Runner/Info.plist').readAsStringSync();

  final production = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .map((file) => file.readAsStringSync())
      .join('\n');

  test('Apple Health read-purpose disclosure remains present', () {
    expect(info, contains('<key>NSHealthShareUsageDescription</key>'));
  });

  test(
    'Apple Health required disclosure remains truthful for read-only runtime',
    () {
      final directWriter = RegExp(
        r'HealthDataAccess\.(?:WRITE|READ_WRITE)|'
        r'\.\s*writeHealthData\s*\(|'
        r'\.\s*writeWorkoutData\s*\(|'
        r'\.\s*writeMenstruationFlow\s*\(',
      ).hasMatch(production);

      expect(directWriter, isFalse);
      expect(info, contains('<key>NSHealthUpdateUsageDescription</key>'));
      expect(
        info,
        contains('Flow Ai does not write health data to Apple Health.'),
      );
    },
  );
}
