import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/core/services/ad_consent_service.dart',
  ).readAsStringSync();

  test('failed consent-info refresh cannot reuse prior ad eligibility', () {
    final failedRefresh = source.indexOf('if (!updated)');
    final forceClosed = source.indexOf(
      '_setCanRequestAds(false);',
      failedRefresh,
    );
    final earlyReturn = source.indexOf('return;', forceClosed);
    final refreshEligibility = source.indexOf(
      'await refreshCanRequestAds();',
      failedRefresh,
    );

    expect(failedRefresh, greaterThanOrEqualTo(0));
    expect(forceClosed, greaterThan(failedRefresh));
    expect(earlyReturn, greaterThan(forceClosed));
    expect(refreshEligibility, greaterThan(earlyReturn));
  });

  test('failed or timed-out consent form cannot authorize ads', () {
    expect(source, contains('final formCompletion = Completer<bool>();'));
    expect(source, contains('formCompletion.complete(error == null);'));
    expect(
      source,
      contains('final formCompleted = await formCompletion.future.timeout('),
    );

    final failedForm = source.indexOf('if (!formCompleted)');
    final forceClosed = source.indexOf('_setCanRequestAds(false);', failedForm);
    final earlyReturn = source.indexOf('return;', forceClosed);
    final refreshEligibility = source.indexOf(
      'await refreshCanRequestAds();',
      failedForm,
    );

    expect(failedForm, greaterThanOrEqualTo(0));
    expect(forceClosed, greaterThan(failedForm));
    expect(earlyReturn, greaterThan(forceClosed));
    expect(refreshEligibility, greaterThan(earlyReturn));
  });

  test('Mobile Ads still initializes only after authoritative consent', () {
    final ads = File('lib/core/services/admob_service.dart').readAsStringSync();

    final consent = ads.indexOf(
      'final consentAllowsAds = await AdConsentService.instance.gatherConsent();',
    );
    final deny = ads.indexOf(
      'if (!consentAllowsAds || _mobileAdsInitialized) return;',
      consent,
    );
    final initialize = ads.indexOf(
      'await MobileAds.instance.initialize();',
      deny,
    );

    expect(consent, greaterThanOrEqualTo(0));
    expect(deny, greaterThan(consent));
    expect(initialize, greaterThan(deny));
  });
}
