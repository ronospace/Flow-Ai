import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Mission 5 dashboard never fabricates health readings or history', () {
    final source = File(
      'lib/features/health/screens/real_time_health_dashboard.dart',
    ).readAsStringSync();

    for (final forbidden in <String>[
      '?? 75.0',
      '?? 36.5',
      '?? 45.0',
      '?? 82.0',
      'math.Random()',
      'random.nextDouble()',
      '_calculateTrend(',
    ]) {
      expect(source.contains(forbidden), isFalse);
    }

    expect(source.contains("fusedData['heart_rate']"), isTrue);
    expect(source.contains("fusedData['temperature']"), isTrue);

    // HRV and sleep use the centralized real-data accessor.
    expect(
      source.contains("final value = biometrics.fusedData[key]?.toDouble();"),
      isTrue,
    );
    expect(source.contains("key: 'hrv'"), isTrue);
    expect(source.contains("key: 'sleep_score'"), isTrue);

    expect(
      source.contains('No synced health readings are available yet.'),
      isTrue,
    );
    expect(
      source.contains(
        'Historical health trends will appear after real synced history is available.',
      ),
      isTrue,
    );
    expect(source.contains('return const <FlSpot>[];'), isTrue);
  });
}
