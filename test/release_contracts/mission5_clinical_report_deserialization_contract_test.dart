import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'M5.8B clinical report deserialization never fabricates missing data',
    () {
      final source = File(
        'lib/features/clinical/models/clinical_models.dart',
      ).readAsStringSync();

      final start = source.indexOf('factory ClinicalReport.fromJson');

      expect(start, greaterThanOrEqualTo(0));

      final nextClass = source.indexOf('\nclass ', start + 1);

      final body = source.substring(
        start,
        nextClass >= 0 ? nextClass : source.length,
      );

      expect(body.contains('throw const FormatException('), isTrue);

      for (final forbidden in <String>[
        'FeelingsClinicalData.empty()',
        'CycleClinicalData(',
        'SymptomClinicalData(',
        'BiometricClinicalData(',
        'BehavioralClinicalData(',
        'totalCycles: 0',
        'average: 0',
        'Simplified for brevity',
      ]) {
        expect(
          body.contains(forbidden),
          isFalse,
          reason: 'Clinical import fabricated missing data: $forbidden',
        );
      }
    },
  );
}
