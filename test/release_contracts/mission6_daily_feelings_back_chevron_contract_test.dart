import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Daily Feelings uses explicit pure back chevron', () {
    final source = File(
      'lib/features/tracking/screens/enhanced_daily_feelings_tracker.dart',
    ).readAsStringSync();

    expect(source, contains('automaticallyImplyLeading: false'));
    expect(source, contains('Icons.chevron_left'));
    expect(source, contains('Navigator.of(context).maybePop()'));

    expect(source, isNot(contains('Icons.arrow_back,')));
    expect(source, isNot(contains('Icons.arrow_back_ios,')));
    expect(source, isNot(contains('Icons.arrow_back_ios_new,')));
  });
  test('Daily Feelings header and tabs follow centralized theme state', () {
    final source = File(
      'lib/features/tracking/screens/enhanced_daily_feelings_tracker.dart',
    ).readAsStringSync();

    final theme = File('lib/core/theme/app_theme.dart').readAsStringSync();

    expect(
      source,
      contains('AppTheme.featureHeaderGradient(theme.brightness)'),
    );
    expect(source, contains('AppSegmentedSelector'));

    expect(theme, contains('featureHeaderGradient(Brightness brightness)'));
    expect(theme, contains('segmentedTabUnselectedColor(ThemeData theme)'));
    expect(theme, contains('brightness == Brightness.dark'));
  });
  test('Notes uses Done-gated Save UX', () {
    final source = File(
      'lib/features/tracking/screens/enhanced_daily_feelings_tracker.dart',
    ).readAsStringSync();

    expect(source, contains('textInputAction: TextInputAction.done'));
    expect(source, contains('_notesEditCommitted = false;'));
    expect(source, contains('onSubmitted: (_)'));
    expect(source, contains('FocusScope.of(context).unfocus();'));
    expect(
      source,
      contains('if (!_hasUnsavedChanges || !_notesEditCommitted)'),
    );
    expect(source, isNot(contains('Feelings saved successfully')));
    expect(source, contains('Failed to save feelings'));
  });
}
