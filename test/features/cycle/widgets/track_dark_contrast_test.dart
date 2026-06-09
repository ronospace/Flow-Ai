import 'dart:io';

import 'package:flow_ai/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double contrastRatio(Color foreground, Color background) {
  final first = foreground.computeLuminance();
  final second = background.computeLuminance();
  final lighter = first > second ? first : second;
  final darker = first > second ? second : first;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  test('Track semantic dark text meets WCAG normal-text contrast', () {
    final theme = AppTheme.darkTheme;
    final scheme = theme.colorScheme;
    final card = theme.cardColor;

    expect(contrastRatio(scheme.onSurface, card), greaterThanOrEqualTo(4.5));
    expect(
      contrastRatio(scheme.onSurfaceVariant, card),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      contrastRatio(scheme.onSurface, scheme.surface),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      contrastRatio(scheme.onSurfaceVariant, scheme.surface),
      greaterThanOrEqualTo(4.5),
    );
  });

  test('Track widgets do not use light-only legacy text colors', () {
    const files = [
      'lib/features/cycle/widgets/flow_intensity_picker.dart',
      'lib/features/cycle/widgets/symptom_selector.dart',
      'lib/features/cycle/widgets/mood_energy_slider.dart',
      'lib/features/cycle/widgets/pain_body_map.dart',
    ];

    for (final path in files) {
      final source = File(path).readAsStringSync();

      expect(
        RegExp(r'color:\s*AppTheme\.darkGrey').hasMatch(source),
        isFalse,
        reason: '$path still uses light-only primary text',
      );
      expect(
        RegExp(r'color:\s*AppTheme\.mediumGrey').hasMatch(source),
        isFalse,
        reason: '$path still uses light-only secondary text',
      );
      expect(
        source.contains('colorScheme.onSurface'),
        isTrue,
        reason: '$path lacks semantic primary text',
      );
      expect(
        source.contains('colorScheme.onSurfaceVariant'),
        isTrue,
        reason: '$path lacks semantic secondary text',
      );
    }
  });
}
