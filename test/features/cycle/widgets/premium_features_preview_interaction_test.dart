import 'package:flow_ai/features/cycle/widgets/premium_features_preview.dart';
import 'package:flow_ai/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Premium preview preserves feature callbacks and paywall entry', (
    tester,
  ) async {
    var premiumTapCount = 0;
    var aiCoachTapCount = 0;
    var partnerTapCount = 0;
    var healthcareTapCount = 0;
    var analyticsTapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: PremiumFeaturesPreview(
              onPremiumTap: () => premiumTapCount++,
              onAICoach: () => aiCoachTapCount++,
              onPartnerSharing: () => partnerTapCount++,
              onHealthcarePortal: () => healthcareTapCount++,
              onAdvancedAnalytics: () => analyticsTapCount++,
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 2));

    final premiumEntry = find.byKey(
      const ValueKey('premium-features-paywall-entry'),
    );

    expect(premiumEntry, findsOneWidget);

    await tester.ensureVisible(premiumEntry);
    await tester.tap(premiumEntry);
    await tester.pump();

    expect(premiumTapCount, 1);
    expect(aiCoachTapCount, 0);
    expect(partnerTapCount, 0);
    expect(healthcareTapCount, 0);
    expect(analyticsTapCount, 0);

    final interactions = <String, VoidCallback>{
      'AI Health Coach': () => expect(aiCoachTapCount, 1),
      'Partner Connect': () => expect(partnerTapCount, 1),
      'Healthcare Portal': () => expect(healthcareTapCount, 1),
      'Advanced Analytics': () => expect(analyticsTapCount, 1),
    };

    for (final entry in interactions.entries) {
      final finder = find.text(entry.key);
      expect(finder, findsOneWidget);
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pump();
      entry.value();
    }

    expect(premiumTapCount, 1);
    expect(tester.takeException(), isNull);
  });
}
