import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Health Connect SDK availability is centrally owned', () {
    final service = File(
      'lib/core/services/advanced_biometric_service.dart',
    ).readAsStringSync();

    final provider = File(
      'lib/features/health/providers/health_provider.dart',
    ).readAsStringSync();

    expect(service, contains('getHealthConnectSdkStatus()'));
    expect(service, contains('HealthConnectSdkStatus.sdkAvailable'));
    expect(
      service,
      contains('HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired'),
    );
    expect(service, contains('HealthConnectSdkStatus.sdkUnavailable'));
    expect(service, contains('installHealthConnect()'));

    expect(provider, contains('requiresHealthConnectInstallOrUpdate'));
    expect(provider, contains('isHealthConnectUnsupported'));
    expect(provider, contains('installHealthConnect()'));
  });

  test('connection card exposes truthful Android availability states', () {
    final card = File(
      'lib/features/health/widgets/healthkit_connection_card.dart',
    ).readAsStringSync();

    expect(card, contains('requiresHealthConnectInstallOrUpdate'));
    expect(card, contains('Install Health Connect'));
    expect(card, contains('isHealthConnectUnsupported'));
    expect(
      card,
      contains('Health Connect is unavailable on this Android device.'),
    );
    expect(card, contains('healthProvider.connectHealthKit(context)'));
  });

  test('Privacy details uses the single information-only disclosure', () {
    final card = File(
      'lib/features/health/widgets/healthkit_connection_card.dart',
    ).readAsStringSync();

    final dialog = File(
      'lib/features/health/widgets/healthkit_permission_dialog.dart',
    ).readAsStringSync();

    expect(card, contains('HealthKitPermissionDialog.showDetails(context)'));

    expect(card, isNot(contains('_showHealthKitDisclosure')));
    expect(card, isNot(contains('_buildDisclosureItem')));
    expect(card, isNot(contains('if tracked in HealthKit')));

    expect(dialog, contains('showDetails(BuildContext context)'));
    expect(dialog, contains('informationOnly: true'));
    expect(dialog, contains("Text('Close')"));
    expect(dialog, contains("Text('Not Now')"));
    expect(dialog, contains("Text('Continue')"));
  });

  test('failed health access remains fail-closed', () {
    final provider = File(
      'lib/features/health/providers/health_provider.dart',
    ).readAsStringSync();

    expect(provider, contains("setBool('health_data_access_granted', false)"));
  });
}
