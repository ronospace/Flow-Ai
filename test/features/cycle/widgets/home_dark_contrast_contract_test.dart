import 'dart:io';

import 'package:flow_ai/core/theme/app_theme.dart';
import 'package:flow_ai/features/cycle/widgets/premium_features_preview.dart';
import 'package:flow_ai/generated/app_localizations.dart';
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
  group('Home dark contrast contract', () {
    test('semantic text passes all dark Home surfaces', () {
      final theme = AppTheme.darkTheme;
      final scheme = theme.colorScheme;

      for (final surface in <Color>[
        scheme.surface,
        theme.cardColor,
        scheme.surfaceContainerHighest,
      ]) {
        expect(
          contrastRatio(scheme.onSurface, surface),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrastRatio(scheme.onSurfaceVariant, surface),
          greaterThanOrEqualTo(4.5),
        );
      }
    });

    test('bright-gradient foreground passes endpoint contracts', () {
      const foreground = AppTheme.onBrightAccent;

      for (final endpoint in <Color>[
        AppTheme.primaryRose,
        AppTheme.primaryPurple,
        AppTheme.secondaryBlue,
        AppTheme.accentMint,
        AppTheme.successGreen,
        AppTheme.warningOrange,
      ]) {
        expect(contrastRatio(foreground, endpoint), greaterThanOrEqualTo(3.0));
      }

      for (final endpoint in <Color>[
        AppTheme.primaryRose,
        AppTheme.secondaryBlue,
        AppTheme.accentMint,
        AppTheme.warningOrange,
      ]) {
        expect(contrastRatio(foreground, endpoint), greaterThanOrEqualTo(4.5));
      }

      expect(
        contrastRatio(AppTheme.lightSurface, AppTheme.primaryPurple),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('source cannot reintroduce light-only Home colors', () {
      const paths = <String>[
        'lib/features/cycle/screens/home_screen.dart',
        'lib/features/cycle/widgets/premium_features_preview.dart',
        'lib/features/cycle/widgets/premium_feature_preview_card.dart',
      ];

      final source = paths
          .map((path) => File(path).readAsStringSync())
          .join('\n');

      expect(source.contains('AppTheme.darkGrey'), isFalse);
      expect(source.contains('AppTheme.mediumGrey'), isFalse);
      expect(
        RegExp(r'colors\s*:\s*\[\s*Colors\.white').hasMatch(source),
        isFalse,
      );
    });
  });

  testWidgets('Premium preview uses semantic dark text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: Scaffold(
          body: SingleChildScrollView(
            child: PremiumFeaturesPreview(
              onPremiumTap: () {},
              onAICoach: () {},
              onPartnerSharing: () {},
              onHealthcarePortal: () {},
              onAdvancedAnalytics: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 2));

    final scheme = AppTheme.darkTheme.colorScheme;
    final heading = tester.widget<Text>(find.text('Premium Features'));
    final subtitle = tester.widget<Text>(
      find.text('Health Intelligence Features'),
    );
    final feature = tester.widget<Text>(find.text('AI Health Coach'));

    expect(heading.style?.color, scheme.onSurface);
    expect(subtitle.style?.color, scheme.onSurfaceVariant);
    expect(feature.style?.color, scheme.onSurface);
    expect(tester.takeException(), isNull);
  });
}
