import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final card = File(
    'lib/features/health/widgets/healthkit_connection_card.dart',
  ).readAsStringSync();

  test('platform identity belongs to card title', () {
    expect(card, contains("'Health Connect'"));
    expect(card, contains("'Apple HealthKit'"));
  });

  test('normal disconnected action is concise', () {
    expect(card, contains("'Connect'"));
    expect(card, isNot(contains("'Connect \$platformShort'")));
    expect(card, isNot(contains("'Connect \$platformName'")));
  });

  test('connected and recovery actions remain distinct', () {
    expect(card, contains("'Disconnect'"));
    expect(card, contains("'Install Health Connect'"));
  });
}
