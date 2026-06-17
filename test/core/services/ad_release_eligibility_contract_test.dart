import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release ads require build, consent, and non-Premium eligibility', () {
    final ads = File('lib/core/services/admob_service.dart').readAsStringSync();

    final consent = File(
      'lib/core/services/ad_consent_service.dart',
    ).readAsStringSync();

    final provider = File(
      'lib/features/premium/providers/subscription_provider.dart',
    ).readAsStringSync();

    expect(ads, isNot(contains('adsEnabled => false')));
    expect(ads, contains('FLOW_AI_ENABLE_ADS'));
    expect(ads, contains('defaultValue: kReleaseMode'));

    expect(
      '$ads\n$consent',
      anyOf(contains('canRequestAds'), contains('canShowAds')),
    );

    expect(provider, contains('if (isPremium) return false'));
    expect(ads, contains('dispose()'));
  });
}
