import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('runtime contains no automatic demo-account path', () {
    final source = File(
      'lib/core/services/local_user_service.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('_createDemoAccountIfNeeded')));
    expect(source, isNot(contains('Auto-create demo account')));
    expect(source, isNot(contains('Always create demo account')));
  });

  test('advertising is production and consent gated', () {
    final source = File(
      'lib/core/services/admob_service.dart',
    ).readAsStringSync();

    expect(source, contains("'FLOW_AI_ENABLE_ADS'"));
    expect(source, contains('static bool get canLoadAds'));
    expect(source, contains('_consentAllowsAds'));
    expect(source, contains('_mobileAdsInitialized'));

    expect(source, isNot(contains('USE_TEST_ADS')));
    expect(source, isNot(contains('3940256099942544')));
    expect(source, isNot(contains('_testInterstitial')));
    expect(source, isNot(contains('_testRewarded')));
  });

  test('Android release has no debug-signing fallback', () {
    final source = File('android/app/build.gradle.kts').readAsStringSync();

    expect(
      source,
      contains('signingConfig = signingConfigs.getByName("release")'),
    );
    expect(source, contains('releaseSigningConfigured'));
    expect(
      source,
      isNot(contains('signingConfig = signingConfigs.getByName("debug")')),
    );
  });
}
