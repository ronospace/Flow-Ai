import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('iOS typography preserves Flow Ai semantic theme properties', () {
    final theme = File('lib/core/theme/app_theme.dart').readAsStringSync();
    final main = File('lib/main.dart').readAsStringSync();

    expect(
      theme,
      contains(
        'static TextTheme _iosMaterialTextTheme(TextTheme base) => '
        'base.copyWith(',
      ),
    );

    expect(
      theme,
      contains('headlineLarge: base.headlineLarge?.copyWith(fontSize: 32)'),
    );
    expect(
      theme,
      contains('headlineMedium: base.headlineMedium?.copyWith(fontSize: 28)'),
    );
    expect(
      theme,
      contains('headlineSmall: base.headlineSmall?.copyWith(fontSize: 24)'),
    );
    expect(
      theme,
      contains('titleLarge: base.titleLarge?.copyWith(fontSize: 22)'),
    );
    expect(
      theme,
      contains('titleMedium: base.titleMedium?.copyWith(fontSize: 16)'),
    );
    expect(
      theme,
      contains(
        'titleSmall: (base.titleSmall ?? const TextStyle()).copyWith('
        'fontSize: 14)',
      ),
    );
    expect(
      theme,
      contains('bodyLarge: base.bodyLarge?.copyWith(fontSize: 16)'),
    );
    expect(
      theme,
      contains('bodyMedium: base.bodyMedium?.copyWith(fontSize: 14)'),
    );
    expect(
      theme,
      contains('bodySmall: base.bodySmall?.copyWith(fontSize: 12)'),
    );

    expect(theme, isNot(contains('headlineLarge: TextStyle(fontSize: 32)')));
    expect(theme, isNot(contains('titleLarge: TextStyle(fontSize: 22)')));

    expect(main, contains('AppTheme.iosMaterialTheme'));
    expect(main, contains('AppTheme.iosMaterialDarkTheme'));
  });

  test('feature screens do not own platform typography constants', () {
    final files = [
      'lib/features/health/screens/health_screen.dart',
      'lib/features/health/widgets/health_section_header.dart',
    ];

    for (final file in files) {
      final source = File(file).readAsStringSync();

      expect(source, isNot(contains('Platform.isIOS')));
      expect(source, isNot(contains('Platform.isAndroid')));
      expect(source, isNot(contains('TargetPlatform.iOS')));
      expect(source, isNot(contains('TargetPlatform.android')));
    }
  });
}
