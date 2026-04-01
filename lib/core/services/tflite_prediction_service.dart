import 'package:flutter/foundation.dart';
// Temporarily disabled due to package compatibility issue
// import 'package:tflite_flutter/tflite_flutter.dart';

/// TensorFlow Lite Prediction Service
/// Provides on-device machine learning predictions for cycle patterns
class TFLitePredictionService {
  static final TFLitePredictionService _instance =
      TFLitePredictionService._internal();
  static TFLitePredictionService get instance => _instance;
  TFLitePredictionService._internal();

  // Interpreter? _interpreter; // Temporarily disabled due to package compatibility
  bool _isInitialized = false;
  // ignore: unused_field
  bool _modelLoaded = false;

  // Model input/output shapes
  static const int inputLength = 30; // Last 30 days of features
  static const int featureCount = 10; // Number of features per day
  static const int outputLength = 7; // Predict next 7 days

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load model (will be implemented when model is available)
      // For now, use statistical fallback
      await _loadModel();
      _isInitialized = true;
      debugPrint('🤖 TensorFlow Lite service initialized');
    } catch (e) {
      debugPrint(
        '⚠️ TFLite initialization failed, using statistical fallback: $e',
      );
      _isInitialized = true; // Still mark as initialized to use fallback
    }
  }

  Future<void> _loadModel() async {
    try {
      // In production, this would load an actual .tflite model file
      // For now, we'll prepare the structure for when the model is available

      // Example path (would be in assets/models/cycle_predictor.tflite)
      // final appDir = await getApplicationDocumentsDirectory();
      // final modelPath = '${appDir.path}/models/cycle_predictor.tflite';

      // _interpreter = Interpreter.fromAsset('assets/models/cycle_predictor.tflite');
      // _modelLoaded = true;

      debugPrint(
        '📦 TFLite model loading prepared (model file not yet available)',
      );
      _modelLoaded = false; // Model not yet available
    } catch (e) {
      debugPrint('❌ Error loading TFLite model: $e');
      _modelLoaded = false;
    }
  }

  /// Predict cycle patterns using TensorFlow Lite model
  Future<CyclePredictionResult> predictCyclePatterns({
    required List<List<double>> historicalData,
  }) async {
    if (!_isInitialized) await initialize();

    // Temporarily disabled TFLite inference due to package compatibility
    // Always use statistical fallback for now
    return _statisticalFallback(historicalData);

    // if (!_modelLoaded || _interpreter == null) {
    //   // Fallback to statistical prediction
    //   return _statisticalFallback(historicalData);
    // }

    // try {
    //   // Prepare input tensor
    //   final input = _prepareInputTensor(historicalData);

    //   // Prepare output tensor
    //   final output = List.generate(outputLength, (_) => List.filled(3, 0.0));

    //   // Run inference
    //   _interpreter!.run(input, output);

    //   // Process output
    //   return _processModelOutput(output, historicalData);
    // } catch (e) {
    //   debugPrint('❌ TFLite prediction error: $e, using fallback');
    //   return _statisticalFallback(historicalData);
    // }
  }

  /// Prepare input tensor from historical data
  // ignore: unused_element
  List<List<List<double>>> _prepareInputTensor(
    List<List<double>> historicalData,
  ) {
    // Ensure we have exactly inputLength days of data
    final paddedData = _padOrTruncateData(historicalData, inputLength);

    // Reshape to [1, inputLength, featureCount] for batch processing
    return [paddedData];
  }

  List<List<double>> _padOrTruncateData(
    List<List<double>> data,
    int targetLength,
  ) {
    if (data.length == targetLength) return data;

    if (data.length > targetLength) {
      // Take the most recent data
      return data.sublist(data.length - targetLength);
    } else {
      // Pad with zeros (or average values)
      final padded = List<List<double>>.from(data);
      final average = _calculateAverageFeatures(data);

      while (padded.length < targetLength) {
        padded.insert(0, List.from(average));
      }

      return padded;
    }
  }

  List<double> _calculateAverageFeatures(List<List<double>> data) {
    if (data.isEmpty) return List.filled(featureCount, 0.0);

    final sums = List.filled(featureCount, 0.0);
    for (final row in data) {
      for (int i = 0; i < featureCount && i < row.length; i++) {
        sums[i] += row[i];
      }
    }

    return sums.map((s) => s / data.length).toList();
  }

  /// Process model output into prediction result
  // ignore: unused_element
  CyclePredictionResult _processModelOutput(
    List<List<double>> output,
    List<List<double>> historicalData,
  ) {
    // Extract predictions
    final periodProbabilities = output.map((day) => day[0]).toList();
    final ovulationProbabilities = output.map((day) => day[1]).toList();
    final symptomScores = output.map((day) => day[2]).toList();

    // Calculate confidence scores
    final avgPeriodConfidence =
        periodProbabilities.reduce((a, b) => a + b) /
        periodProbabilities.length;
    final avgOvulationConfidence =
        ovulationProbabilities.reduce((a, b) => a + b) /
        ovulationProbabilities.length;

    return CyclePredictionResult(
      periodProbabilities: periodProbabilities,
      ovulationProbabilities: ovulationProbabilities,
      symptomScores: symptomScores,
      confidence: (avgPeriodConfidence + avgOvulationConfidence) / 2,
      method: PredictionMethod.tflite,
    );
  }

  /// Statistical fallback when TFLite model is not available
  CyclePredictionResult _statisticalFallback(
    List<List<double>> historicalData,
  ) {
    // Use simple statistical methods
    // This is a placeholder - in practice would use the ML services
    final periodProbabilities = List.generate(outputLength, (i) {
      // Simple pattern: higher probability on days matching historical cycle length
      final cycleLength = historicalData.length > 0 ? 28.0 : 28.0; // Default
      final dayOfCycle = (i % cycleLength).round();
      return dayOfCycle < 5 ? 0.8 : 0.1; // Period likely in first 5 days
    });

    final ovulationProbabilities = List.generate(outputLength, (i) {
      final cycleLength = historicalData.length > 0 ? 28.0 : 28.0;
      final dayOfCycle = (i % cycleLength).round();
      return (dayOfCycle >= 12 && dayOfCycle <= 16) ? 0.7 : 0.1;
    });

    final symptomScores = List.filled(outputLength, 0.5);

    return CyclePredictionResult(
      periodProbabilities: periodProbabilities,
      ovulationProbabilities: ovulationProbabilities,
      symptomScores: symptomScores,
      confidence: 0.6, // Lower confidence for statistical fallback
      method: PredictionMethod.statistical,
    );
  }

  /// Dispose resources
  void dispose() {
    // _interpreter?.close(); // Temporarily disabled
    // _interpreter = null; // Temporarily disabled
    _modelLoaded = false;
    _isInitialized = false;
  }
}

enum PredictionMethod { tflite, statistical, ensemble }

class CyclePredictionResult {
  final List<double> periodProbabilities;
  final List<double> ovulationProbabilities;
  final List<double> symptomScores;
  final double confidence;
  final PredictionMethod method;

  CyclePredictionResult({
    required this.periodProbabilities,
    required this.ovulationProbabilities,
    required this.symptomScores,
    required this.confidence,
    required this.method,
  });

  /// Get the day with highest period probability
  int? getMostLikelyPeriodDay() {
    if (periodProbabilities.isEmpty) return null;
    double maxProb = periodProbabilities[0];
    int maxIndex = 0;

    for (int i = 1; i < periodProbabilities.length; i++) {
      if (periodProbabilities[i] > maxProb) {
        maxProb = periodProbabilities[i];
        maxIndex = i;
      }
    }

    return maxProb > 0.5 ? maxIndex : null;
  }

  /// Get the day with highest ovulation probability
  int? getMostLikelyOvulationDay() {
    if (ovulationProbabilities.isEmpty) return null;
    double maxProb = ovulationProbabilities[0];
    int maxIndex = 0;

    for (int i = 1; i < ovulationProbabilities.length; i++) {
      if (ovulationProbabilities[i] > maxProb) {
        maxProb = ovulationProbabilities[i];
        maxIndex = i;
      }
    }

    return maxProb > 0.5 ? maxIndex : null;
  }
}
