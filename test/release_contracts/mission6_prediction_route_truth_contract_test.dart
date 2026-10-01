import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('predictions route uses CycleProvider-backed truthful screen', () {
    final router = File('lib/core/routing/app_router.dart').readAsStringSync();

    final screen = File(
      'lib/features/cycle/screens/cycle_predictions_screen.dart',
    ).readAsStringSync();

    expect(router, contains("path: '/predictions'"));
    expect(router, contains('CyclePredictionsScreen()'));

    expect(screen, contains("context.watch<CycleProvider>().predictions"));
    expect(screen, contains('prediction == null'));
    expect(screen, contains('Prediction unavailable'));

    expect(screen, isNot(contains('PeriodPredictionEngine')));
    expect(screen, isNot(contains('anonymous_user')));
    expect(screen, isNot(contains('Future.delayed')));

    expect(router, isNot(contains('AIPredictionsScreen()')));
    expect(router, isNot(contains('ai_predictions_screen.dart')));
  });
}
