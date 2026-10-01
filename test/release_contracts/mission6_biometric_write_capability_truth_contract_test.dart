import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final advanced = File(
    'lib/core/services/advanced_biometric_service.dart',
  ).readAsStringSync();

  final info = File('ios/Runner/Info.plist').readAsStringSync();

  final productionDart = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .map((file) => file.readAsStringSync())
      .join('\n');

  test('current Health authorization is read-only', () {
    expect(advanced, contains('HealthDataAccess.READ'));

    expect(advanced, isNot(contains('HealthDataAccess.WRITE')));

    expect(advanced, isNot(contains('HealthDataAccess.READ_WRITE')));
  });

  test('production exposes no unsupported write capability surface', () {
    expect(productionDart, isNot(contains('canWriteData')));
  });

  test('iOS Health disclosure explicitly preserves read-only truth', () {
    expect(info, contains('<key>NSHealthUpdateUsageDescription</key>'));
    expect(
      info,
      contains('Flow Ai does not write health data to Apple Health.'),
    );
  });
}
