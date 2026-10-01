import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('None flow intensity uses theme-visible semantic accent', () {
    final source = File(
      'lib/features/cycle/widgets/flow_intensity_picker.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('color: Theme.of(context).colorScheme.onSurfaceVariant,'),
    );
  });

  test('Track weekday uses semantic surface-variant contrast', () {
    final source = File(
      'lib/features/cycle/screens/tracking_screen.dart',
    ).readAsStringSync();

    final weekday = source.indexOf("DateFormat('EEEE')");
    expect(weekday, greaterThanOrEqualTo(0));

    final region = source.substring(
      weekday,
      (weekday + 500).clamp(0, source.length),
    );

    expect(region, contains('theme.colorScheme.onSurfaceVariant'));
    expect(region, isNot(contains('alpha: 0.6')));
  });
}
