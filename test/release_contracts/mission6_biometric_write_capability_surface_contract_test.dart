import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final productionDart = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .map((file) => file.readAsStringSync())
      .join('\n');

  test('unsupported write capability is not exposed by production model', () {
    expect(productionDart, isNot(contains('canWriteData')));
  });

  test('production requests no health write authorization', () {
    expect(productionDart, isNot(contains('HealthDataAccess.WRITE')));

    expect(productionDart, isNot(contains('HealthDataAccess.READ_WRITE')));
  });
}
