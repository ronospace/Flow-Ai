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

  test('Enhanced Daily Feelings uses responsive semantic geometry', () {
    final source = File(
      'lib/features/tracking/screens/enhanced_daily_feelings_tracker.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('height: 300')));
    expect(source, contains('BorderRadius.circular(16)'));
    expect(source, contains('surfaceContainerHighest'));
    expect(source, contains('onSurfaceVariant'));
    expect(source, contains('AnimatedBuilder('));
    expect(source, contains('AnimatedSwitcher('));
    expect(source, contains('shrinkWrap: true'));
    expect(source, contains('NeverScrollableScrollPhysics'));

    expect(
      source,
      isNot(
        contains('{for (var category in MoodCategory.values) category: 5.0}'),
      ),
    );
    expect(
      source,
      isNot(contains('{for (var type in EnergyType.values) type: 5.0}')),
    );

    expect(source, contains("'Not recorded'"));
    expect(source, contains('SliderComponentShape.noThumb'));
  });

  test('Daily Feelings C1 semantic dark mode and entry identity', () {
    final source = File(
      'lib/features/tracking/screens/enhanced_daily_feelings_tracker.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('late final TextEditingController _notesController'),
    );
    expect(source, contains('_notesController.dispose();'));
    expect(source, contains('_notesController.text = entry.notes;'));
    expect(source, contains('_notesController.clear();'));
    expect(source, contains('_currentEntry = null;'));

    expect(source, contains('controller: _notesController'));
    expect(source, isNot(contains('TextEditingController(text: _notes)')));

    expect(source, contains('scheme.onSurface'));
    expect(source, contains('scheme.onSurfaceVariant'));
    expect(source, contains('surfaceContainerHighest'));
    expect(source, contains('theme.cardColor'));

    expect(source, isNot(contains('color: AppTheme.darkGrey')));
    expect(source, isNot(contains('color: AppTheme.mediumGrey')));
  });
}
