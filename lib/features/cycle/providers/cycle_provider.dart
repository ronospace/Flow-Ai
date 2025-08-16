import 'package:flutter/foundation.dart';
import '../../../core/models/cycle_data.dart';
import '../../../core/services/ai_engine.dart';

class CycleProvider extends ChangeNotifier {
  final List<CycleData> _cycles = [];
  CyclePrediction? _nextCyclePrediction;
  EnhancedCyclePrediction? _enhancedPrediction;
  bool _isLoading = false;

  List<CycleData> get cycles => List.unmodifiable(_cycles);
  CyclePrediction? get nextCyclePrediction => _nextCyclePrediction;
  EnhancedCyclePrediction? get enhancedPrediction => _enhancedPrediction;
  bool get isLoading => _isLoading;

  CycleData? get currentCycle => _cycles.isNotEmpty ? _cycles.last : null;

  double get averageCycleLength {
    if (_cycles.length < 2) return 28.0;
    final completedCycles = _cycles.where((c) => c.isCompleted).toList();
    if (completedCycles.isEmpty) return 28.0;
    return completedCycles.fold<int>(0, (sum, c) => sum + c.actualLength) / completedCycles.length;
  }

  Future<void> loadCycles() async {
    _isLoading = true;
    notifyListeners();

    // Simulate loading with sample data
    await Future.delayed(const Duration(seconds: 1));
    
    _cycles.addAll([
      CycleData(
        id: '1',
        startDate: DateTime.now().subtract(const Duration(days: 32)),
        endDate: DateTime.now().subtract(const Duration(days: 27)),
        length: 28,
        flowIntensity: FlowIntensity.medium,
        symptoms: ['cramps', 'fatigue'],
        mood: 3.0,
        energy: 2.5,
        pain: 3.5,
        createdAt: DateTime.now().subtract(const Duration(days: 32)),
        updatedAt: DateTime.now().subtract(const Duration(days: 27)),
      ),
      CycleData(
        id: '2',
        startDate: DateTime.now().subtract(const Duration(days: 4)),
        endDate: null,
        length: 28,
        flowIntensity: FlowIntensity.heavy,
        symptoms: ['headache', 'bloating'],
        mood: 2.5,
        energy: 2.0,
        pain: 4.0,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        updatedAt: DateTime.now(),
      ),
    ]);

    await _generatePrediction();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _generatePrediction() async {
    if (_cycles.isNotEmpty) {
      // Try to get enhanced prediction, fallback to basic prediction
      try {
        final prediction = await AIEngine.instance.predictNextCycle(_cycles);
        if (prediction is EnhancedCyclePrediction) {
          _enhancedPrediction = prediction;
          _nextCyclePrediction = prediction; // Also store as basic prediction for compatibility
        } else {
          _nextCyclePrediction = prediction;
        }
      } catch (e) {
        debugPrint('Prediction generation failed: $e');
      }
    }
  }

  void addCycle(CycleData cycle) {
    _cycles.add(cycle);
    _generatePrediction();
    notifyListeners();
  }

  void updateCycle(CycleData updatedCycle) {
    final index = _cycles.indexWhere((c) => c.id == updatedCycle.id);
    if (index != -1) {
      _cycles[index] = updatedCycle;
      _generatePrediction();
      notifyListeners();
    }
  }
}
