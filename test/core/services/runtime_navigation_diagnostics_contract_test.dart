import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('runtime navigation diagnostics are validation-only and path-only', () {
    final analytics = File(
      'lib/core/services/production_analytics_service.dart',
    ).readAsStringSync();

    final navigation = File(
      'lib/core/routing/runtime_navigation_telemetry.dart',
    ).readAsStringSync();

    expect(analytics, contains("'FLOW_AI_RUNTIME_DIAGNOSTICS'"));
    expect(analytics, contains('defaultValue: false'));
    expect(analytics, contains('flow_runtime_navigation.jsonl'));

    expect(navigation, contains('currentConfiguration.uri.path'));
    expect(navigation, contains('recordNavigationDiagnostic('));

    for (final forbidden in <String>[
      'queryParameters',
      'pathParameters',
      'settings.arguments',
    ]) {
      expect(navigation, isNot(contains(forbidden)));
    }

    final diagnosticStart = analytics.indexOf(
      'Future<void> recordNavigationDiagnostic(',
    );
    final diagnosticEnd = analytics.indexOf(
      '/// Track screen views',
      diagnosticStart,
    );

    expect(diagnosticStart, greaterThanOrEqualTo(0));
    expect(diagnosticEnd, greaterThan(diagnosticStart));

    final diagnosticSource = analytics.substring(
      diagnosticStart,
      diagnosticEnd,
    );

    for (final forbidden in <String>[
      '_userId',
      'user_id',
      'email',
      'token',
      'queryParameters',
      'pathParameters',
    ]) {
      expect(diagnosticSource, isNot(contains(forbidden)));
    }
  });
}
