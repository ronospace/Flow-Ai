import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final ads = File('lib/core/services/admob_service.dart').readAsStringSync();

  test('AdMob owns one consent lifecycle listener', () {
    expect(ads, contains('static bool _consentListenerAttached = false;'));
    expect(
      ads,
      contains(
        'AdConsentService.instance.addListener(_onConsentEligibilityChanged);',
      ),
    );
    expect(ads, contains('_consentListenerAttached = true;'));
  });

  test('consent withdrawal disposes loaded fullscreen ads', () {
    final start = ads.indexOf('static void _onConsentEligibilityChanged()');
    final end = ads.indexOf(
      '// Initialize consent first, then Mobile Ads exactly once.',
      start,
    );

    expect(start, greaterThanOrEqualTo(0));
    expect(end, greaterThan(start));

    final body = ads.substring(start, end);

    expect(body, contains('if (!AdConsentService.instance.canRequestAds)'));
    expect(body, contains('AdMobService()._disposeLoadedAds();'));
    expect(body, contains('return;'));

    final denied = body.indexOf(
      'if (!AdConsentService.instance.canRequestAds)',
    );
    final dispose = body.indexOf('AdMobService()._disposeLoadedAds();');

    expect(dispose, greaterThan(denied));
  });

  test('consent granted after startup resumes Mobile Ads initialization', () {
    final start = ads.indexOf('static void _onConsentEligibilityChanged()');
    final end = ads.indexOf(
      '// Initialize consent first, then Mobile Ads exactly once.',
      start,
    );

    final body = ads.substring(start, end);

    expect(body, contains('if (!_mobileAdsInitialized)'));
    expect(body, contains('unawaited(initialize());'));
  });

  test('listener attaches before consent-dependent early return', () {
    final start = ads.indexOf('static Future<void> initialize()');
    final end = ads.indexOf('static Future<void> _initializeOnce()', start);

    expect(start, greaterThanOrEqualTo(0));
    expect(end, greaterThan(start));

    final body = ads.substring(start, end);
    final listener = body.indexOf('_ensureConsentListener();');
    final initialized = body.indexOf('if (_mobileAdsInitialized)');

    expect(listener, greaterThanOrEqualTo(0));
    expect(initialized, greaterThan(listener));
  });

  test('all ad eligibility remains fail closed through canLoadAds', () {
    expect(ads, contains('AdConsentService.instance.canRequestAds &&'));
    expect(ads, contains('if (!canLoadAds) return false;'));
  });
}
