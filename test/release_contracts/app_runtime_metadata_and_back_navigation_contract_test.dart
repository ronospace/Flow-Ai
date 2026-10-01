import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('runtime app metadata has one PackageInfo owner', () {
    final result = Process.runSync('rg', [
      '-l',
      'PackageInfo\\.fromPlatform',
      'lib',
      '-g',
      '*.dart',
    ]);

    expect(result.exitCode, 0);

    final files = result.stdout
        .toString()
        .trim()
        .split('\n')
        .where((line) => line.isNotEmpty)
        .toList();

    expect(
      files,
      equals(['lib/core/services/app_runtime_metadata_service.dart']),
    );
  });

  test('known stale release metadata constants cannot return', () {
    final paths = <String>[
      'lib/features/settings/screens/settings_screen.dart',
      'lib/core/services/production_analytics_service.dart',
      'lib/features/deployment/services/deployment_service.dart',
    ];

    final combined = paths
        .map((path) => File(path).readAsStringSync())
        .join('\n');

    expect(combined, isNot(contains("applicationVersion: '2.0.0'")));
    expect(combined, isNot(contains("'app_version': '2.0.0+2'")));
    expect(combined, isNot(contains("version: '1.0.0'")));
    expect(combined, isNot(contains("buildNumber: '1'")));
  });

  test('Flow Ai themes own framework back-chevron policy centrally', () {
    final source = File('lib/core/theme/app_theme.dart').readAsStringSync();

    expect(source, contains('backNavigationActionIconTheme'));
    expect(source, contains('backButtonIconBuilder: _buildBackNavigationIcon'));
    expect(source, contains('const Icon(Icons.arrow_back_ios_new)'));

    expect(
      'actionIconTheme: backNavigationActionIconTheme'
          .allMatches(source)
          .length,
      2,
    );
  });

  test('iOS Material themes derive from centralized light/dark bases', () {
    final source = File('lib/core/theme/app_theme.dart').readAsStringSync();

    expect(source, contains('final base = lightTheme;'));
    expect(source, contains('final base = darkTheme;'));
    expect(
      source,
      contains(
        'return base.copyWith(textTheme: _iosMaterialTextTheme(base.textTheme));',
      ),
    );
  });
}
