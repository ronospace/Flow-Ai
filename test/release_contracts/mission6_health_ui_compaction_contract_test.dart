import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('health UI is compact without weakening disclosure truth', () {
    final dialog = File(
      'lib/features/health/widgets/healthkit_permission_dialog.dart',
    ).readAsStringSync();

    expect(dialog, contains('maxWidth: 440'));
    expect(dialog, contains('maxHeight: viewportHeight * 0.52'));

    expect(dialog, contains("'Health data access'"));
    expect(dialog, contains("'Data you can share:'"));

    for (final category in <String>[
      "'Heart rate and HRV'",
      "'Body temperature'",
      "'Sleep'",
      "'Sleep duration'",
      "'Menstrual flow'",
    ]) {
      expect(dialog, contains(category));
    }

    expect(dialog, contains('actionsAlignment: MainAxisAlignment.center'));
    expect(
      dialog,
      contains('actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 12)'),
    );
    expect('minimumSize: const Size(112, 44)'.allMatches(dialog).length, 0);

    final theme = File('lib/core/theme/app_theme.dart').readAsStringSync();

    final geometry = File('lib/core/ui/app_geometry.dart').readAsStringSync();

    expect(geometry, contains('static const double radiusSm = 12'));
    expect(geometry, contains('static const double capsuleHeight = 44'));

    expect(theme, contains('dialogSecondaryActionStyle'));
    expect(theme, contains('dialogPrimaryActionStyle'));
    expect(theme, contains('AppGeometry.radiusSm'));
    expect(theme, contains('AppGeometry.capsuleHeight'));

    expect(dialog, contains('AppTheme.dialogSecondaryActionStyle(theme)'));
    expect(dialog, contains('AppTheme.dialogPrimaryActionStyle(theme)'));

    expect(dialog, contains("child: const Text('Not Now')"));
    expect(dialog, contains("child: const Text('Continue')"));

    expect(
      dialog,
      isNot(contains("'Menstrual flow data (if tracked in HealthKit)'")),
    );
  });
  test('Data Coverage uses compact status typography', () {
    final healthScreen = File(
      'lib/features/health/screens/health_screen.dart',
    ).readAsStringSync();

    final start = healthScreen.indexOf("'Data Coverage'");
    expect(start, isNonNegative);

    final region = healthScreen.substring(
      start,
      (start + 1400).clamp(0, healthScreen.length),
    );

    expect(region, contains('theme.textTheme.titleMedium?.copyWith('));
    expect(region, isNot(contains('theme.textTheme.headlineSmall?.copyWith(')));
  });
  test('Health dialog consumes centralized dialog shape', () {
    final dialog = File(
      'lib/features/health/widgets/healthkit_permission_dialog.dart',
    ).readAsStringSync();

    final theme = File('lib/core/theme/app_theme.dart').readAsStringSync();

    final geometry = File('lib/core/ui/app_geometry.dart').readAsStringSync();

    expect(geometry, contains('static const BorderRadius dialogRadius'));

    expect(theme, contains('static ShapeBorder get dialogShape'));

    expect(theme, contains('AppGeometry.dialogRadius'));

    expect(dialog, contains('shape: AppTheme.dialogShape'));

    expect(dialog, isNot(contains('BorderRadius.circular(16)')));
  });
}
