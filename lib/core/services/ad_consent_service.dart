import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdConsentService {
  AdConsentService._();

  static final AdConsentService instance = AdConsentService._();

  Future<bool>? _activeRequest;
  bool _canRequestAds = false;
  bool _privacyOptionsRequired = false;

  bool get canRequestAds => _canRequestAds;
  bool get privacyOptionsRequired => _privacyOptionsRequired;

  Future<bool> gatherConsent() {
    return _activeRequest ??= _gatherConsentOnce().whenComplete(() {
      _activeRequest = null;
    });
  }

  Future<bool> _gatherConsentOnce() async {
    final completer = Completer<bool>();

    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () {
        if (!completer.isCompleted) completer.complete(true);
      },
      (error) {
        if (kDebugMode) {
          debugPrint('Ad consent information error: $error');
        }
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    final updated = await completer.future.timeout(
      const Duration(seconds: 20),
      onTimeout: () => false,
    );

    if (updated) {
      await ConsentForm.loadAndShowConsentFormIfRequired((error) {
        if (error != null && kDebugMode) {
          debugPrint('Ad consent form error: $error');
        }
      });
    }

    try {
      _canRequestAds = await ConsentInformation.instance.canRequestAds();
    } catch (error) {
      _canRequestAds = false;
      if (kDebugMode) {
        debugPrint('Unable to verify ad consent: $error');
      }
    }

    await refreshPrivacyOptionsRequirement();
    return _canRequestAds;
  }

  Future<void> refreshPrivacyOptionsRequirement() async {
    try {
      final status = await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus();
      _privacyOptionsRequired =
          status == PrivacyOptionsRequirementStatus.required;
    } catch (error) {
      _privacyOptionsRequired = false;
      if (kDebugMode) {
        debugPrint('Unable to verify ad privacy options: $error');
      }
    }
  }

  Future<FormError?> showPrivacyOptions() async {
    FormError? result;

    await ConsentForm.showPrivacyOptionsForm((error) {
      result = error;
    });

    await refreshPrivacyOptionsRequirement();
    return result;
  }
}
