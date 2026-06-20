import 'package:flow_ai/core/theme/app_theme.dart';
import 'package:flow_ai/features/cycle/widgets/premium_features_preview.dart';
import 'package:flow_ai/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const widths = <double>[320, 375, 390, 430];
  const heights = <double>[568, 844, 932];
  const scales = <double>[1.0, 1.3, 1.6, 2.0];
  const modes = <ThemeMode>[ThemeMode.light, ThemeMode.dark];

  for (final mode in modes) {
    for (final width in widths) {
      for (final height in heights) {
        for (final scale in scales) {
          testWidgets('Premium preview '
              '${mode.name} ${width.toInt()}x${height.toInt()} '
              'scale=$scale', (tester) async {
            tester.view.devicePixelRatio = 1;
            tester.view.physicalSize = Size(width, height);

            addTearDown(() {
              tester.view.resetDevicePixelRatio();
              tester.view.resetPhysicalSize();
            });

            await tester.pumpWidget(
              MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: mode,
                home: MediaQuery(
                  data: MediaQueryData(
                    size: Size(width, height),
                    textScaler: TextScaler.linear(scale),
                  ),
                  child: Scaffold(
                    body: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
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
              ),
            );

            await tester.pump();
            await tester.pump(const Duration(milliseconds: 1));
            await tester.pump(const Duration(seconds: 12));
            await tester.pump();

            expect(tester.takeException(), isNull);

            expect(find.text('Premium Features'), findsOneWidget);
            expect(find.text('AI Health Coach'), findsOneWidget);
            expect(find.text('Partner Connect'), findsOneWidget);
            expect(find.text('Healthcare Portal'), findsOneWidget);
            expect(find.text('Advanced Analytics'), findsOneWidget);

            final bounds = tester.getRect(find.byType(PremiumFeaturesPreview));

            expect(bounds.left, greaterThanOrEqualTo(-0.5));
            expect(bounds.right, lessThanOrEqualTo(width + 0.5));

            await tester.pumpWidget(const SizedBox.shrink());
            await tester.pump();
            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  }
}
