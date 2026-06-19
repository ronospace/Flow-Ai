import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legacy healthcare coming-soon helper is removed', () {
    final source = File(
      'lib/core/widgets/coming_soon_widget.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('static Widget healthcareProvider(')));
    expect(source, isNot(contains('Healthcare Provider Features Coming Soon')));
  });

  test('active healthcare export portal remains reachable', () {
    final home = File(
      'lib/features/cycle/screens/home_screen.dart',
    ).readAsStringSync();

    final portal = File(
      'lib/features/healthcare/screens/'
      'healthcare_provider_portal_screen.dart',
    ).readAsStringSync();

    expect(home, contains('HealthcareProviderPortalScreen()'));
    expect(portal, contains('class HealthcareProviderPortalScreen'));
    expect(portal, contains('Share.shareXFiles'));
  });
}
