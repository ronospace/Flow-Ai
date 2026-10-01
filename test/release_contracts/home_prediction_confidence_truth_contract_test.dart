import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Home prediction confidence truth', () {
    late String home;
    late String matrix;

    setUpAll(() {
      home = File(
        'lib/features/cycle/screens/home_screen.dart',
      ).readAsStringSync();

      final start = home.indexOf('Widget _buildHealthDashboardMatrix');
      final end = home.indexOf('Widget _buildHealthMetricCard', start);

      expect(start, greaterThanOrEqualTo(0));
      expect(end, greaterThan(start));

      matrix = home.substring(start, end);
    });

    test('active Home renders the Health Dashboard Matrix', () {
      expect(home, contains('_buildHealthDashboardMatrix(cycleProvider)'));
    });

    test('real confidence and accuracy remain authoritative', () {
      expect(matrix, contains('provider.predictions!.confidence.score * 100'));
      expect(matrix, contains('provider.insights!.periodPredictionAccuracy'));
    });

    test('all four unavailable confidence values fail closed', () {
      expect(RegExp(r": '—',").allMatches(matrix).length, 4);
    });

    test('unknown confidence is never represented as measured zero', () {
      expect(matrix, isNot(contains(": '0%'")));
      expect(matrix, isNot(contains(': "0%"')));
    });

    test('fixed confidence claims are absent from active matrix', () {
      expect(matrix, isNot(contains('97% confidence')));
      expect(matrix, isNot(contains('confidence: 0.97')));
    });
  });
}
