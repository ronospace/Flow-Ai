import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final card = File(
    'lib/features/health/widgets/healthkit_connection_card.dart',
  ).readAsStringSync();

  test('disconnect does not emit redundant automatic success message', () {
    expect(card, isNot(contains('showSuccess')));
    expect(card, isNot(contains(r'${platformShort} disconnected')));
  });

  test('connection state remains visible through authoritative UI', () {
    expect(card, contains("'Access Granted'"));
    expect(card, contains("'Connect'"));
    expect(card, contains("'Disconnect'"));
  });

  test('Health Connect recovery action remains available', () {
    expect(card, contains("'Install Health Connect'"));
  });
}
