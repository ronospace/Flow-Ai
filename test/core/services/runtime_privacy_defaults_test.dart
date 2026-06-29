import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('advertising requires platform support, consent, and SDK readiness', () {
    final source = File(
      'lib/core/services/admob_service.dart',
    ).readAsStringSync();

    expect(source, contains("'ENABLE_ADS'"));
    expect(source, contains('defaultValue: true'));
    expect(source, contains('requestConsentInfoUpdate'));
    expect(source, contains('loadAndShowConsentFormIfRequired'));
    expect(source, contains('canRequestAds'));
    expect(source, contains('_canRequestAds'));
    expect(source, contains('_sdkInitialized'));
    expect(source, contains('showPrivacyOptionsForm'));
    expect(source, contains('kDebugMode &&'));
  });

  test('sensitive dashboard remains free of automatic ad placements', () {
    final source = File(
      'lib/features/cycle/screens/home_screen.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('BannerAd')));
    expect(source, isNot(contains('showInterstitialAdWithFrequency')));
    expect(source, contains('showRewardedAdWithFrequency'));
    expect(source, contains('Premium access is already ad-free.'));
  });

  test('analytics requires explicit opt in', () {
    final service = File(
      'lib/core/services/production_analytics_service.dart',
    ).readAsStringSync();
    final onboarding = File(
      'lib/features/onboarding/widgets/privacy_preferences_widget.dart',
    ).readAsStringSync();

    expect(service, contains('bool _analyticsEnabled = false;'));
    expect(service, contains('?? false;'));
    expect(onboarding, contains('bool _allowAnonymousAnalytics = false;'));
    expect(onboarding, contains("'defaultValue': false"));
  });
}
