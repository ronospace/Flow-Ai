import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final productionDart = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .map((file) => file.readAsStringSync())
      .join('\n');

  test('production contains no retired synthetic health dashboard', () {
    expect(productionDart, isNot(contains('overallHealthScore: 0.75')));

    expect(productionDart, isNot(contains('cycleRegularity: 0.85')));

    expect(productionDart, isNot(contains('averageStressLevel: 4.2')));

    expect(productionDart, isNot(contains('averageSleepQuality: 0.78')));

    expect(productionDart, isNot(contains('dataCompleteness: 0.92')));
  });

  test('current Health path preserves observed-data truth semantics', () {
    final provider = File(
      'lib/features/health/providers/health_provider.dart',
    ).readAsStringSync();

    expect(provider, contains('metricProvenance.isNotEmpty'));

    expect(provider, contains('dataQuality'));
  });
}
