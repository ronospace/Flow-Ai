import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('active prediction engine is ordered and recorded-data anchored', () {
    final source = File(
      'lib/core/services/cycle_calculation_engine.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('final chronologicalCycles = List<CycleData>.from(cycles)'),
    );
    expect(source, contains('a.startDate.compareTo(b.startDate)'));

    expect(source, contains('final latestCycle = cycles.reduce('));
    expect(source, contains('.difference(latestCycle.startDate)'));

    expect(
      source,
      contains('DateTime? _predictNextPeriod(\n    CycleData currentCycle,'),
    );

    expect(
      source,
      isNot(
        contains(
          'return referenceDate.add(Duration(days: stats.averageCycleLength));',
        ),
      ),
    );

    expect(source, isNot(contains('.difference(cycles.first.startDate)')));
  });

  test('comprehensive predictions fail closed without a recent anchor', () {
    final source = File(
      'lib/core/services/cycle_calculation_engine.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('''final currentCycle = await _getCurrentCycle(referenceDate);
      if (currentCycle == null) {
        return null;
      }'''),
    );
  });

  test(
    'next-period prediction is anchored start-to-start and fails closed when stale',
    () {
      final source = File(
        'lib/core/services/cycle_calculation_engine.dart',
      ).readAsStringSync();

      expect(
        source,
        contains('final predictedStart = currentCycle.startDate.add('),
      );

      expect(source, contains('if (predictedStart.isBefore(referenceDate))'));

      expect(source, contains('if (nextPeriod == null)'));

      expect(
        source,
        isNot(
          contains(
            'estimatedEnd.add(Duration(days: stats.averageCycleLength))',
          ),
        ),
      );
    },
  );
}
