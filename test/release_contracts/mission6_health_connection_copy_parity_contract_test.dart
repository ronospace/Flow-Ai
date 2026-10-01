import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final card = File(
    'lib/features/health/widgets/healthkit_connection_card.dart',
  ).readAsStringSync();

  test('health connection copy uses one cross-platform sentence', () {
    expect(
      card,
      contains(
        "'Flow Ai can read the health data you choose to share through \$syncSource.'",
      ),
    );

    expect(card, isNot(contains('Allow Flow Ai to read')));
    expect(card, isNot(contains('supported health data')));
    expect(card, isNot(contains('you chose to share')));
  });

  test('platform source names remain native', () {
    expect(card, contains("'Apple Health'"));
    expect(card, contains("'Android Health'"));
  });

  test('connection state remains communicated by controls', () {
    expect(card, contains("'Access Granted'"));
    expect(card, contains("'Disconnect'"));
    expect(card, contains("'Connect'"));
    expect(card, contains("'Connecting…'"));
    expect(card, contains('isConnectingHealthData'));
  });
}
