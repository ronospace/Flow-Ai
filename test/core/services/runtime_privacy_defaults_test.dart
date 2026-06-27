import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('advertising is disabled globally', () {
    final source = File(
      'lib/core/services/admob_service.dart',
    ).readAsStringSync();

    expect(source, contains('static bool get adsEnabled => false;'));
    expect(source, contains('if (!adsEnabled) return;'));
    expect(source, contains('if (!adsEnabled) return false;'));
  });

  test('analytics requires explicit opt in', () {
    final service = File(
      'lib/core/services/production_analytics_service.dart',
    ).readAsStringSync();
    final onboarding = File(
      'lib/features/onboarding/widgets/privacy_preferences_widget.dart',
    ).readAsStringSync();

    expect(service, contains('bool _analyticsEnabled = false;'));
    expect(service, contains('?? false;'));
    expect(onboarding, contains('bool _allowAnonymousAnalytics = false;'));
    expect(onboarding, contains("'defaultValue': false"));
  });
}
