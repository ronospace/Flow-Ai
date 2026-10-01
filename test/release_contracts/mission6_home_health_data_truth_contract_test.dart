import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Home preserves original health ring with truthful production data', () {
    final source = File(
      'lib/features/cycle/screens/home_screen.dart',
    ).readAsStringSync();

    // Original visual mechanics.
    expect(source, contains('_healthController.repeat()'));
    expect(source, contains('class HealthScorePainter'));

    // Objective health-data coverage, not a synthetic health rating.
    expect(source, contains('hasObservedHealthData'));
    expect(source, contains('healthDataCoverage'));
    expect(source, contains('HealthScorePainter('));
    expect(source, contains('score: healthDataCoverage,'));
    expect(source, contains(r"'${(healthDataCoverage * 100).round()}'"));

    expect(
      source,
      isNot(contains('context.watch<HealthProvider>().healthScore')),
    );
    expect(source, isNot(contains('localizations.optimal')));

    // Fixed production-looking reports are forbidden.
    expect(source, isNot(contains("'87%'")));
    expect(source, isNot(contains("'+5% this month'")));
    expect(source, isNot(contains("'28.5 days'")));
    expect(source, isNot(contains("'4.2/5'")));
  });
}
