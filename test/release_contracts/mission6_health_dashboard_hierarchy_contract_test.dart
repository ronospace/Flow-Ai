import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Health dashboard keeps related health state under one parent hierarchy',
    () {
      final source = File(
        'lib/features/health/screens/health_screen.dart',
      ).readAsStringSync();

      expect(source, contains('_buildHealthDashboard(localizations)'));
      expect(source, contains('Widget _buildHealthDashboard('));
      expect(source, contains('const HealthKitConnectionCard()'));
      expect(source, contains('_buildHealthDataCoverageCard()'));
      expect(
        source,
        contains('_buildBiometricGrid(localizations, showHeading: false)'),
      );

      expect(source, contains('borderRadius: AppGeometry.carrierRadius'));
    },
  );

  test(
    'Health no-data and symptom presentation remains truthful and themed',
    () {
      final source = File(
        'lib/features/health/screens/health_screen.dart',
      ).readAsStringSync();

      expect(source, contains("'0% coverage'"));
      expect(source, contains("'No synced observations.'"));

      expect(source, contains('theme.colorScheme.surfaceContainerHighest'));
      expect(source, contains('theme.colorScheme.onSurfaceVariant'));

      expect(source, isNot(contains('AppTheme.darkGrey')));
      expect(source, isNot(contains('AppTheme.mediumGrey')));
    },
  );

  test('Health connection has one compact granted-status owner', () {
    final source = File(
      'lib/features/health/widgets/healthkit_connection_card.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('Access granted')));
    expect(RegExp(r"'Access Granted'").allMatches(source).length, 1);

    expect(
      source,
      contains(
        "final platformName = isIOS ? 'Apple HealthKit' : 'Health Connect';",
      ),
    );
    expect(source, contains('platformName,'));
  });
}
