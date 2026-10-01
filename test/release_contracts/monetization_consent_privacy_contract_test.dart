import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('current launch consent refresh completes before ad authorization', () {
    final source = File(
      'lib/core/services/ad_consent_service.dart',
    ).readAsStringSync();

    final gatherStart = source.indexOf('Future<bool> _gatherConsentOnce()');
    final finishStart = source.indexOf('Future<void> _finishConsentRefresh');

    expect(gatherStart, isNonNegative);
    expect(finishStart, greaterThan(gatherStart));

    final gatherOwner = source.substring(gatherStart, finishStart);

    expect(
      gatherOwner,
      contains('await _finishConsentRefresh(completer.future);'),
    );
    expect(
      gatherOwner,
      isNot(contains('unawaited(_finishConsentRefresh(completer.future))')),
    );
    expect(gatherOwner, isNot(contains('if (_canRequestAds)')));
    expect(gatherOwner, isNot(contains('await refreshCanRequestAds();')));
  });

  final consent = File(
    'lib/core/services/ad_consent_service.dart',
  ).readAsStringSync();

  final adMob = File('lib/core/services/admob_service.dart').readAsStringSync();

  final settings = File(
    'lib/features/settings/screens/settings_screen.dart',
  ).readAsStringSync();

  test('UMP is the single authoritative advertising-consent owner', () {
    expect(consent, contains('ConsentInformation.instance.canRequestAds()'));

    expect(adMob, contains('AdConsentService.instance.canRequestAds'));

    expect(adMob, isNot(contains('_consentAllowsAds')));
  });

  test('privacy options refresh ad eligibility after user changes consent', () {
    final start = consent.indexOf('Future<FormError?> showPrivacyOptions()');

    expect(start, greaterThanOrEqualTo(0));

    final end = (start + 1800) < consent.length ? start + 1800 : consent.length;

    final region = consent.substring(start, end);

    expect(region, contains('ConsentForm.showPrivacyOptionsForm'));

    expect(region, contains('await refreshCanRequestAds();'));

    expect(region, contains('await refreshPrivacyOptionsRequirement();'));
  });

  test('unknown UMP eligibility fails closed', () {
    expect(consent, contains('_canRequestAds = false;'));

    expect(adMob, contains('if (!canLoadAds)'));
  });

  test('settings exposes UMP privacy choices when required', () {
    expect(settings, contains('privacyOptionsRequired'));

    expect(settings, contains('Ad privacy choices'));

    expect(settings, contains('showPrivacyOptions()'));
  });

  test(
    'production source contains no consent debug geography or reset path',
    () {
      expect(consent, isNot(contains('ConsentDebugSettings')));

      expect(consent, isNot(contains('debugGeography')));

      expect(consent, isNot(contains('testDeviceIdentifiers')));

      expect(consent, isNot(contains('ConsentInformation.instance.reset(')));
    },
  );

  test('current launch UMP refresh completes before ad authorization', () {
    final source = File(
      'lib/core/services/ad_consent_service.dart',
    ).readAsStringSync();

    final requestIndex = source.indexOf('requestConsentInfoUpdate(');
    final finishIndex = source.indexOf(
      'await _finishConsentRefresh(completer.future);',
      requestIndex,
    );
    final returnIndex = source.indexOf('return _canRequestAds;', finishIndex);

    expect(requestIndex, greaterThanOrEqualTo(0));
    expect(finishIndex, greaterThan(requestIndex));
    expect(returnIndex, greaterThan(finishIndex));

    final gatherStart = source.indexOf('Future<bool> _gatherConsentOnce()');
    final finishOwnerStart = source.indexOf(
      'Future<void> _finishConsentRefresh',
    );

    expect(gatherStart, greaterThanOrEqualTo(0));
    expect(finishOwnerStart, greaterThan(gatherStart));

    final gatherOwner = source.substring(gatherStart, finishOwnerStart);

    expect(
      gatherOwner,
      isNot(contains('unawaited(_finishConsentRefresh(completer.future))')),
    );
    expect(gatherOwner, isNot(contains('if (_canRequestAds)')));
    expect(gatherOwner, isNot(contains('await refreshCanRequestAds();')));

    expect(source, contains('ConsentForm.loadAndShowConsentFormIfRequired'));
    expect(source, contains('const Duration(seconds: 20)'));
  });
}
