import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('audited detail pages use explicit shared back control', () {
    final paths = <String>[
      'lib/features/analytics/screens/analytics_dashboard_screen.dart',
      'lib/features/partner/screens/qr_join_screen.dart',
      'lib/features/settings/screens/help_screen.dart',
      'lib/features/future_plans/screens/future_plans_screen.dart',
      'lib/features/feedback/screens/feedback_screen.dart',
    ];

    for (final path in paths) {
      final source = File(path).readAsStringSync();

      expect(
        source,
        contains('AppBackButton('),
        reason: '$path must use the shared page-back owner',
      );
    }
  });

  test('Future Plans and Feedback do not use framework implicit leading', () {
    final future = File(
      'lib/features/future_plans/screens/future_plans_screen.dart',
    ).readAsStringSync();

    final feedback = File(
      'lib/features/feedback/screens/feedback_screen.dart',
    ).readAsStringSync();

    expect(future, contains('automaticallyImplyLeading: false'));
    expect(feedback, contains('automaticallyImplyLeading: false'));
  });

  test('heavy Material page-back arrows are removed from audited pages', () {
    final paths = <String>[
      'lib/features/analytics/screens/analytics_dashboard_screen.dart',
      'lib/features/partner/screens/qr_join_screen.dart',
      'lib/features/settings/screens/help_screen.dart',
    ];

    for (final path in paths) {
      final source = File(path).readAsStringSync();

      expect(source, isNot(contains('Icons.arrow_back,')));
    }
  });
}
