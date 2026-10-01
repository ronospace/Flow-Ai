import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final card = File(
    'lib/features/health/widgets/healthkit_connection_card.dart',
  ).readAsStringSync();

  test('Android and iOS use one platform-title hierarchy', () {
    expect(card, contains("'Apple HealthKit'"));
    expect(card, contains("'Health Connect'"));
    expect(card, contains('platformName'));
    expect(card, isNot(contains("'Connect \$platformName'")));
    expect(card, isNot(contains("'Uses Android Health'")));
  });

  test('native connected and disconnected actions remain', () {
    expect(card, contains("'Access Granted'"));
    expect(card, contains("'Disconnect'"));
    expect(card, contains("'Connect'"));
    expect(card, contains("'Connecting…'"));
    expect(card, contains('isConnectingHealthData'));
  });

  test('Health Connect recovery states remain intact', () {
    expect(card, contains('requiresHealthConnectInstallOrUpdate'));
    expect(card, contains("'Install Health Connect'"));
    expect(card, contains('isHealthConnectUnsupported'));
  });

  test('connection-card compact surfaces use central geometry', () {
    expect(card, contains('AppGeometry.radiusSm'));
    expect(card, isNot(contains('BorderRadius.circular(999)')));
  });
}
