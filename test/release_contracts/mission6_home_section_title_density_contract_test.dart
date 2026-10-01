import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final home = File(
    'lib/features/cycle/screens/home_screen.dart',
  ).readAsStringSync();

  final premium = File(
    'lib/features/cycle/widgets/premium_features_preview.dart',
  ).readAsStringSync();

  test('Home main section titles use the compact shared typography step', () {
    final titles = <String>[
      'localizations.healthDashboardMatrix',
      'localizations.predictiveAnalyticsCenter',
      "'Health Insights Portal'",
      'localizations.smartActionCommandCenter',
      "'Health Trends Visualization'",
    ];

    for (final title in titles) {
      final pos = home.indexOf(title);
      expect(pos, greaterThanOrEqualTo(0), reason: title);

      final segment = home.substring(pos, (pos + 500).clamp(0, home.length));

      expect(
        segment,
        contains('theme.textTheme.titleMedium?.copyWith('),
        reason: title,
      );
      expect(segment, contains('FontWeight.bold'), reason: title);
    }
  });

  test('Premium Features uses the same compact Home title step', () {
    final pos = premium.indexOf("'Premium Features'");
    expect(pos, greaterThanOrEqualTo(0));

    final segment = premium.substring(
      pos,
      (pos + 500).clamp(0, premium.length),
    );

    expect(segment, contains('theme.textTheme.titleMedium?.copyWith('));
    expect(segment, contains('FontWeight.bold'));
  });

  test('Home AppBar and metric/value typography are not globally reduced', () {
    final appBarPos = home.indexOf('title: Text(');
    expect(appBarPos, greaterThanOrEqualTo(0));

    final appBarSegment = home.substring(
      appBarPos,
      (appBarPos + 300).clamp(0, home.length),
    );

    expect(appBarSegment, contains('AppPageTypography.title(context)'));
  });
}
