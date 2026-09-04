import 'package:flutter_test/flutter_test.dart';
import 'package:flow_ai/core/analytics/statistics.dart';

void main() {
  group('Statistics.pearsonCorrelation', () {
    test('calculates perfect positive correlation', () {
      final result = Statistics.pearsonCorrelation(
        const <double>[1, 2, 3, 4],
        const <double>[2, 4, 6, 8],
      );

      expect(result, closeTo(1.0, 1e-12));
    });

    test('calculates perfect negative correlation', () {
      final result = Statistics.pearsonCorrelation(
        const <double>[1, 2, 3, 4],
        const <double>[8, 6, 4, 2],
      );

      expect(result, closeTo(-1.0, 1e-12));
    });

    test('fails closed below minimum sample count', () {
      expect(
        Statistics.pearsonCorrelation(
          const <double>[1, 2],
          const <double>[2, 4],
        ),
        isNull,
      );
    });

    test('fails closed for zero variance', () {
      expect(
        Statistics.pearsonCorrelation(
          const <double>[2, 2, 2],
          const <double>[1, 2, 3],
        ),
        isNull,
      );
    });

    test('fails closed for mismatched observations', () {
      expect(
        Statistics.pearsonCorrelation(
          const <double>[1, 2, 3],
          const <double>[1, 2],
        ),
        isNull,
      );
    });

    test('fails closed for non-finite observations', () {
      expect(
        Statistics.pearsonCorrelation(
          const <double>[1, double.nan, 3],
          const <double>[1, 2, 3],
        ),
        isNull,
      );
    });
  });
}
