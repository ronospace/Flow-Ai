import 'package:flutter/foundation.dart';
import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'production_analytics_service.dart';

class AdConsentService extends ChangeNotifier {
  AdConsentService._();

  static final AdConsentService instance = AdConsentService._();

  Future<bool>? _activeRequest;
  bool _canRequestAds = false;
  bool _privacyOptionsRequired = false;

  bool get canRequestAds => _canRequestAds;
  bool get privacyOptionsRequired => _privacyOptionsRequired;

  void _setCanRequestAds(bool value) {
    if (_canRequestAds == value) return;
    _canRequestAds = value;
    notifyListeners();
    unawaited(
      ProductionAnalyticsService().trackConsentLifecycle(
        'can_request_ads_changed',
        canRequestAds: value,
      ),
    );
  }

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
        unawaited(
          ProductionAnalyticsService().trackConsentLifecycle(
            'consent_info_update',
            result: 'failed',
          ),
        );
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    // Do not authorize ad requests from potentially stale prior-session
    // consent state. Complete the current launch consent-info refresh and any
    // required form before resolving whether ads may be requested.
    await _finishConsentRefresh(completer.future);
    return _canRequestAds;
  }

  Future<void> _finishConsentRefresh(Future<bool> updateFuture) async {
    final updated = await updateFuture.timeout(
      const Duration(seconds: 20),
      onTimeout: () => false,
    );

    if (!updated) {
      // A failed or timed-out consent-info refresh is not authoritative for
      // this launch. Never reuse prior-session eligibility.
      _setCanRequestAds(false);
      await refreshPrivacyOptionsRequirement();
      return;
    }

    final formCompletion = Completer<bool>();

    await ConsentForm.loadAndShowConsentFormIfRequired((error) {
      unawaited(
        ProductionAnalyticsService().trackConsentLifecycle(
          'consent_form',
          result: error == null ? 'completed' : 'failed',
        ),
      );

      if (!formCompletion.isCompleted) {
        formCompletion.complete(error == null);
      }
    });

    final formCompleted = await formCompletion.future.timeout(
      const Duration(seconds: 20),
      onTimeout: () => false,
    );

    if (!formCompleted) {
      // A required consent form that fails or times out cannot authorize ads.
      _setCanRequestAds(false);
      await refreshPrivacyOptionsRequirement();
      return;
    }

    await refreshCanRequestAds();
    await refreshPrivacyOptionsRequirement();
  }

  Future<void> refreshCanRequestAds() async {
    try {
      final next = await ConsentInformation.instance.canRequestAds();
      _setCanRequestAds(next);
    } catch (error) {
      _setCanRequestAds(false);
    }
  }

  Future<void> refreshPrivacyOptionsRequirement() async {
    try {
      final status = await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus();
      _privacyOptionsRequired =
          status == PrivacyOptionsRequirementStatus.required;
    } catch (error) {
      _privacyOptionsRequired = false;
    }
  }

  Future<FormError?> showPrivacyOptions() async {
    _setCanRequestAds(false);
    final completion = Completer<FormError?>();
    await ConsentForm.showPrivacyOptionsForm((error) {
      if (!completion.isCompleted) completion.complete(error);
    });
    final result = await completion.future;
    await refreshCanRequestAds();
    await refreshPrivacyOptionsRequirement();
    return result;
  }
}
