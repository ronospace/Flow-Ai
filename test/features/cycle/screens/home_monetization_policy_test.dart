import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Home monetization policy', () {
    late String source;

    setUpAll(() {
      source = File(
        'lib/features/cycle/screens/home_screen.dart',
      ).readAsStringSync();
    });

    test('does not load or render ads inside the cycle health home flow', () {
      const forbidden = <String>[
        'google_mobile_ads',
        'admob_service.dart',
        'BannerAd',
        'InterstitialAd',
        'RewardedAd',
        'AdWidget',
        '_loadBannerAd',
        '_buildBannerAdWidget',
        '_showRewardedAdForInsights',
        'showRewardedAdWithFrequency',
        'showInterstitialAdWithFrequency',
        'PremiumInsightsUnlockCard',
        'watchAdUnlockInsights',
      ];

      for (final token in forbidden) {
        expect(
          source.contains(token),
          isFalse,
          reason: 'Home health flow must not contain ad token: $token',
        );
      }
    });

    test(
      'routes locked insight monetization to Premium instead of ad rewards',
      () {
        expect(source, contains("context.push('/premium/paywall')"));
        expect(source, contains('localizations.unlockPremiumAiInsights'));
        expect(source, contains('_showPremiumInsightsPaywall'));
        expect(source, contains('onPremiumTap: _showPremiumInsightsPaywall'));
      },
    );
  });
}
