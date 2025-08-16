import 'package:flutter/foundation.dart';
import '../models/cycle_data.dart';

class CycleTracker {
  static final CycleTracker _instance = CycleTracker._internal();
  static CycleTracker get instance => _instance;
  CycleTracker._internal();

  final List<CycleData> _cycles = [];
  
  List<CycleData> get cycles => List.unmodifiable(_cycles);
  
  CycleData? get currentCycle {
    return _cycles.isNotEmpty ? _cycles.last : null;
  }
  
  double get averageCycleLength {
    if (_cycles.length < 2) return 28.0;
    
    final completedCycles = _cycles.where((c) => c.isCompleted).toList();
    if (completedCycles.isEmpty) return 28.0;
    
    final total = completedCycles.fold<int>(0, (sum, cycle) => sum + cycle.actualLength);
    return total / completedCycles.length;
  }
  
  void addCycle(CycleData cycle) {
    _cycles.add(cycle);
    debugPrint('➕ Added new cycle: ${cycle.id}');
  }
  
  void updateCycle(CycleData updatedCycle) {
    final index = _cycles.indexWhere((c) => c.id == updatedCycle.id);
    if (index != -1) {
      _cycles[index] = updatedCycle;
      debugPrint('✏️ Updated cycle: ${updatedCycle.id}');
    }
  }
  
  void removeCycle(String cycleId) {
    _cycles.removeWhere((c) => c.id == cycleId);
    debugPrint('🗑️ Removed cycle: $cycleId');
  }
  
  List<CycleData> getCyclesInDateRange(DateTime start, DateTime end) {
    return _cycles.where((cycle) => 
      cycle.startDate.isAfter(start) && cycle.startDate.isBefore(end)
    ).toList();
  }
}
