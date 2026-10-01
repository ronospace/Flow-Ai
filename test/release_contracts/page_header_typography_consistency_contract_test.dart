import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Settings Calendar and Insights share titleLarge page-title semantics',
    () {
      final home = File(
        'lib/features/cycle/screens/home_screen.dart',
      ).readAsStringSync();
      final settings = File(
        'lib/features/settings/screens/settings_screen.dart',
      ).readAsStringSync();
      final calendar = File(
        'lib/features/cycle/screens/calendar_screen.dart',
      ).readAsStringSync();
      final insights = File(
        'lib/features/insights/screens/insights_screen.dart',
      ).readAsStringSync();

      expect(home, contains('AppPageTypography.title(context)'));
      expect(settings, contains('AppPageTypography.title(context)'));
      expect(calendar, contains('AppPageTypography.title(context)'));
      expect(insights, contains('AppPageTypography.title(context)'));
    },
  );

  test('Insights learning subtitle is single-line and semantic-sized', () {
    final insights = File(
      'lib/features/insights/screens/insights_screen.dart',
    ).readAsStringSync();

    expect(
      insights,
      contains('AppLocalizations.of(context).learnYourPatterns'),
    );
    expect(insights, contains('maxLines: 1'));
    expect(insights, contains('softWrap: false'));
    expect(insights, contains('theme.textTheme.bodyMedium?.copyWith('));
  });
}
