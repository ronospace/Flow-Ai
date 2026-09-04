import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('real cycle loading fails closed without fabricated fallback data', () {
    final source = File(
      'lib/core/services/real_cycle_service.dart',
    ).readAsStringSync();

    expect(
      source.contains('monthsOfHistory: 0'),
      isFalse,
      reason: 'Production cycle loading must not generate default predictions.',
    );

    expect(
      source.contains('// Return default data if something goes wrong'),
      isFalse,
      reason: 'Production cycle loading must not use synthetic fallback data.',
    );

    expect(
      RegExp(
        r'catch\s*\([^)]*\)\s*\{\s*rethrow\s*;',
        multiLine: true,
      ).hasMatch(source),
      isTrue,
      reason: 'Real-data retrieval failures must propagate fail-closed.',
    );
  });
}
