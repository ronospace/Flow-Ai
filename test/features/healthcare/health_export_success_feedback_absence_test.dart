import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('persistent health export success feedback remains absent', () {
    const forbidden = 'Health data exported successfully!';

    final source = File(
      'lib/features/healthcare/screens/'
      'healthcare_provider_portal_screen.dart',
    ).readAsStringSync();

    expect(source, isNot(contains(forbidden)));
    expect(source, contains('Share.shareXFiles'));
  });
}
