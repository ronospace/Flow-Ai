import 'package:flutter/foundation.dart';
import '../../../core/models/cycle_data.dart';
import '../../../core/database/database_service.dart';
import '../../../core/services/real_cycle_service.dart';
import '../../../core/services/cycle_calculation_engine.dart';

class CycleProvider extends ChangeNotifier {
  RealCycleService? _realCycleService;
  
  RealCycleData? _cycleData;
  CycleInsights? _insights;
  bool _isLoading = false;
  bool _isInitialized = false;
  
  CycleProvider() {
    _initializeService();
  }
  
  Future<void> _initializeService() async {
    try {
      _realCycleService = RealCycleService(DatabaseService());
      _isInitialized = true;
    } catch (e) {
      debugPrint('CycleProvider initialization failed: $e');
      // Continue without the service - UI will show fallback content
      _isInitialized = false;
    }
  }

  // Getters for compatibility with existing UI
  List<CycleData> get cycles => _cycleData?.recentCycles ?? [];
  CyclePredictions? get predictions => _cycleData?.predictions;
  bool get isLoading => _isLoading;
  CycleData? get currentCycle => _cycleData?.currentCycle;
  CycleInsights? get insights => _insights;
  RealCycleData? get cycleData => _cycleData;

  double get averageCycleLength {
    return _insights?.averageCycleLength ?? 28.0;
  }

  Future<void> loadCycles() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_realCycleService != null) {
        // Load real cycle data and predictions
        _cycleData = await _realCycleService!.getRealCycleData();
        _insights = await _realCycleService!.getCycleInsights();
      } else {
        // Set demo data when service is not available
        _cycleData = null;
        _insights = null;
      }
    } catch (e) {
      debugPrint('Error loading cycle data: $e');
      // Set default empty data on error
      _cycleData = null;
      _insights = null;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshPredictions() async {
    if (_cycleData != null && _realCycleService != null) {
      try {
        final newPredictions = await _realCycleService!.refreshPredictions();
        _cycleData = RealCycleData(
          predictions: newPredictions,
          recentCycles: _cycleData!.recentCycles,
          currentCycle: _cycleData!.currentCycle,
          recentTrackingData: _cycleData!.recentTrackingData,
          lastUpdated: DateTime.now(),
        );
        notifyListeners();
      } catch (e) {
        debugPrint('Error refreshing predictions: $e');
      }
    }
  }

  Future<void> startNewCycle({
    required DateTime startDate,
    FlowIntensity? initialFlow,
    List<String>? symptoms,
    String? notes,
  }) async {
    if (_realCycleService == null) {
      debugPrint('CycleService not available');
      return;
    }
    
    try {
      await _realCycleService!.startNewCycle(
        startDate: startDate,
        initialFlow: initialFlow,
        symptoms: symptoms,
        notes: notes,
      );
      // Reload data after starting new cycle
      await loadCycles();
    } catch (e) {
      debugPrint('Error starting new cycle: $e');
    }
  }
  
  Future<void> endCurrentCycle(DateTime endDate) async {
    if (_realCycleService == null) {
      debugPrint('CycleService not available');
      return;
    }
    
    try {
      await _realCycleService!.endCurrentCycle(endDate);
      // Reload data after ending cycle
      await loadCycles();
    } catch (e) {
      debugPrint('Error ending current cycle: $e');
    }
  }
  
  /// Clear all user cycle data (used during sign out)
  void clearUserData() {
    _cycleData = null;
    _insights = null;
    _isLoading = false;
    notifyListeners();
    debugPrint('✅ CycleProvider: All user data cleared');
  }
}
