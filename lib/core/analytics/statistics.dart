import 'dart:math' as math;

/// Canonical production statistical calculations.
///
/// Invalid, non-finite, insufficient, or zero-variance observations fail
/// closed instead of returning misleading numerical results.
class Statistics {
  Statistics._();

  static double? pearsonCorrelation(
    List<double> x,
    List<double> y, {
    int minimumSamples = 3,
  }) {
    if (minimumSamples < 2 ||
        x.length != y.length ||
        x.length < minimumSamples ||
        x.any((value) => !value.isFinite) ||
        y.any((value) => !value.isFinite)) {
      return null;
    }

    final xMean = x.reduce((a, b) => a + b) / x.length;
    final yMean = y.reduce((a, b) => a + b) / y.length;

    var numerator = 0.0;
    var xVariance = 0.0;
    var yVariance = 0.0;

    for (var i = 0; i < x.length; i++) {
      final xDelta = x[i] - xMean;
      final yDelta = y[i] - yMean;

      numerator += xDelta * yDelta;
      xVariance += xDelta * xDelta;
      yVariance += yDelta * yDelta;
    }

    if (xVariance <= 0.0 || yVariance <= 0.0) {
      return null;
    }

    final denominator = math.sqrt(xVariance * yVariance);

    if (!denominator.isFinite || denominator <= 0.0) {
      return null;
    }

    final result = numerator / denominator;

    if (!result.isFinite) {
      return null;
    }

    return result.clamp(-1.0, 1.0).toDouble();
  }
}
