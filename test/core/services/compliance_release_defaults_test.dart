import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('first compliance release keeps advertising disabled', () {
    final source = File(
      'lib/core/services/admob_service.dart',
    ).readAsStringSync();

    expect(source, contains('static bool get adsEnabled => false;'));
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
  test('release health integration is iOS-only', () {
    final service = File(
      'lib/core/services/advanced_biometric_service.dart',
    ).readAsStringSync();
    final provider = File(
      'lib/features/health/providers/health_provider.dart',
    ).readAsStringSync();
    final card = File(
      'lib/features/health/widgets/healthkit_connection_card.dart',
    ).readAsStringSync();
    final settings = File(
      'lib/features/settings/screens/settings_screen.dart',
    ).readAsStringSync();

    expect(service, contains('if (!Platform.isIOS)'));
    expect(provider, contains('defaultTargetPlatform != TargetPlatform.iOS'));
    expect(card, contains('return const SizedBox.shrink();'));
    expect(settings, contains('if (Platform.isIOS)'));
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
