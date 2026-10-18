import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/core/services/data_export_service.dart',
  ).readAsStringSync();

  test('export boundary serializes domain cycles before file generation', () {
    expect(source, contains('.map((cycle) => cycle.toJson())'));
    expect(source, contains("'cycles': exportCycles"));
    expect(source, contains("'tracking': exportTracking"));
  });

  test('tracking export normalization converts enums and nested values', () {
    expect(source, contains('if (value is Enum)'));
    expect(source, contains('return value.name;'));
    expect(source, contains('if (value is Map)'));
    expect(source, contains('if (value is Iterable)'));
    expect(
      source,
      contains(r"'Unsupported export value type: ${value.runtimeType}'"),
    );
  });

  test('live PDF and CSV consume the normalized CycleData JSON contract', () {
    expect(source, contains("cycle['startDate']"));
    expect(source, contains("cycle['endDate']"));
    expect(source, contains("cycle['cycleLength']"));
    expect(source, contains("cycle['flowIntensity']"));

    expect(source, isNot(contains("cycle['start_date']")));
    expect(source, isNot(contains("cycle['end_date']")));
    expect(source, isNot(contains("cycle['flow_intensity']")));
  });

  test('JSON export encodes only normalized export data', () {
    expect(source, contains("final jsonString = const JsonEncoder.withIndent"));
    expect(source, contains("'data': data"));
  });
}
