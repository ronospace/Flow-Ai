import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release advertising remains build and consent gated', () {
    final source = File(
      'lib/core/services/admob_service.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('adsEnabled => false')));
    expect(source, contains('FLOW_AI_ENABLE_ADS'));
    expect(source, contains('defaultValue: kReleaseMode'));
    expect(source, contains('_consentAllowsAds'));
  });

  test('analytics is disabled until explicit consent is persisted', () {
    final source = File(
      'lib/core/services/production_analytics_service.dart',
    ).readAsStringSync();

    expect(source, contains('bool _analyticsEnabled = false;'));
    expect(source, contains('_prefs?.getBool(_keyAnalyticsEnabled) ?? false;'));
  });

  test('Apple privacy manifest is bundled with UserDefaults reason', () {
    final manifest = File(
      'ios/Runner/PrivacyInfo.xcprivacy',
    ).readAsStringSync();
    final project = File(
      'ios/Runner.xcodeproj/project.pbxproj',
    ).readAsStringSync();

    expect(manifest, contains('NSPrivacyAccessedAPICategoryUserDefaults'));
    expect(manifest, contains('CA92.1'));
    expect(project, contains('PrivacyInfo.xcprivacy'));
  });
  test('release health integration supports iOS and Android', () {
    final service = File(
      'lib/core/services/advanced_biometric_service.dart',
    ).readAsStringSync();

    final provider = File(
      'lib/features/health/providers/health_provider.dart',
    ).readAsStringSync();

    final card = File(
      'lib/features/health/widgets/healthkit_connection_card.dart',
    ).readAsStringSync();

    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(service, contains('Platform.isAndroid'));
    expect(service, contains('_androidDataTypes'));
    expect(service, contains('HEART_RATE_VARIABILITY_RMSSD'));
    expect(service, contains('await _health!.configure();'));
    expect(service, contains('_platformDataTypes'));

    expect(
      service,
      isNot(
        contains(
          'Apple Health integration is available only on iOS in this release',
        ),
      ),
    );

    expect(provider, contains('TargetPlatform.android'));
    expect(card, contains('Platform.isAndroid'));

    for (final permission in <String>[
      'READ_HEART_RATE',
      'READ_RESTING_HEART_RATE',
      'READ_HEART_RATE_VARIABILITY',
      'READ_BODY_TEMPERATURE',
      'READ_SLEEP',
      'READ_STEPS',
      'READ_ACTIVE_CALORIES_BURNED',
      'READ_OXYGEN_SATURATION',
      'READ_RESPIRATORY_RATE',
      'READ_HYDRATION',
      'READ_MENSTRUATION',
    ]) {
      expect(
        manifest,
        contains(permission),
        reason: 'Android Health Connect requires $permission',
      );
    }

    expect(manifest, contains('com.google.android.apps.healthdata'));

    expect(
      manifest,
      contains('androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE'),
    );
  });

  test('release public destinations and health policy are aligned', () {
    for (final path in <String>[
      'lib/features/settings/screens/help_screen.dart',
      'lib/features/settings/screens/settings_screen.dart',
      'lib/features/health/widgets/healthkit_disclosure_banner.dart',
    ]) {
      expect(File(path).readAsStringSync(), isNot(contains('flowiq.app')));
    }

    for (final path in <String>[
      'PRIVACY_POLICY.md',
      'docs/index.html',
      'support/privacy.html',
      'web/privacy.html',
    ]) {
      final source = File(path).readAsStringSync();
      expect(source, isNot(contains('Google Fit')));
      expect(source, contains('current production release'));
    }
  });
}
