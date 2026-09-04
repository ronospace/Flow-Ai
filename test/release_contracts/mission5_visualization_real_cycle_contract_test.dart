import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cycle visualization uses authoritative persisted data', () {
    final source = File(
      'lib/features/visualization/services/advanced_visualization_service.dart',
    ).readAsStringSync();

    expect(source.contains('_generateMockCycleData'), isFalse);
    expect(source.contains('_generateMockPredictionData'), isFalse);

    expect(
      source.contains('DatabaseService.instance.getCyclesByDateRange'),
      isTrue,
    );

    expect(source.contains('DatabaseService.instance.getCurrentCycle'), isTrue);

    expect(source.contains('expectedNextPeriod'), isTrue);
    expect(source.contains('final int cycleDays = 28'), isFalse);
  });
}
