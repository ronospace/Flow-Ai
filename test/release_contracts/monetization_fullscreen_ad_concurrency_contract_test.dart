import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File('lib/core/services/admob_service.dart').readAsStringSync();
  });

  test(
    'interstitial loading is single-flight and stale-callback protected',
    () {
      expect(source, contains('bool _interstitialLoadInFlight = false;'));
      expect(source, contains('int _interstitialLoadGeneration = 0;'));
      expect(source, contains('_interstitialLoadInFlight ||'));
      expect(source, contains('generation != _interstitialLoadGeneration'));
      expect(
        source,
        contains('if (_interstitialAd != null || _isInterstitialAdReady)'),
      );
    },
  );

  test('rewarded loading is single-flight and stale-callback protected', () {
    expect(source, contains('bool _rewardedLoadInFlight = false;'));
    expect(source, contains('int _rewardedLoadGeneration = 0;'));
    expect(source, contains('_rewardedLoadInFlight ||'));
    expect(source, contains('generation != _rewardedLoadGeneration'));
    expect(source, contains('if (_rewardedAd != null || _isRewardedAdReady)'));
  });

  test('forced disposal invalidates pending full-screen loads', () {
    expect(source, contains('_interstitialLoadGeneration++;'));
    expect(source, contains('_rewardedLoadGeneration++;'));
  });
}
