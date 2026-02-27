import 'dart:math';
import '../../features/cycle/models/cycle_data.dart';

/// Service for generating demo/sample data for new users
class DemoDataService {
  final Random _random = Random();

  /// Generate demo cycles (3 months of sample data)
  List<CycleData> generateDemoCycles() {
    final now = DateTime.now();
    final cycles = <CycleData>[];
    
    // Generate 3 complete cycles
    DateTime currentDate = DateTime(now.year, now.month - 3, now.day);
    
    for (int i = 0; i < 3; i++) {
      final cycleLength = 28 + _random.nextInt(3) - 1; // 27-29 days
      final periodLength = 4 + _random.nextInt(2); // 4-5 days
      
      final startDate = currentDate;
      final endDate = startDate.add(Duration(days: cycleLength - 1));
      final nextPeriodDate = endDate.add(const Duration(days: 1));
      
      // Generate daily data for this cycle
      final dailyData = <DateTime, DailyData>{};
      for (int day = 0; day < cycleLength; day++) {
        final date = startDate.add(Duration(days: day));
        final isPeriodDay = day < periodLength;
        
        if (isPeriodDay || day == 14 || _random.nextDouble() < 0.3) {
          dailyData[date] = DailyData(
            date: date,
            flowIntensity: isPeriodDay ? _getFlowIntensity(day, periodLength) : null,
            symptoms: _getSymptoms(day, cycleLength, isPeriodDay),
            moodScore: _getMoodScore(day, cycleLength),
            energyLevel: _getEnergyLevel(day, cycleLength),
            notes: isPeriodDay ? _getPeriodNotes(day) : null,
          );
        }
      }
      
      cycles.add(CycleData(
        id: 'demo_cycle_$i',
        userId: 'demo_user',
        startDate: startDate,
        endDate: endDate,
        length: cycleLength,
        dailyData: dailyData,
        createdAt: startDate,
        updatedAt: startDate,
      ));
      
      currentDate = nextPeriodDate;
    }
    
    return cycles;
  }

  /// Get flow intensity based on period day
  FlowIntensity _getFlowIntensity(int dayIndex, int totalDays) {
    if (dayIndex == 0) return FlowIntensity.light;
    if (dayIndex == 1 || dayIndex == 2) return FlowIntensity.heavy;
    if (dayIndex == totalDays - 1) return FlowIntensity.spotting;
    return FlowIntensity.medium;
  }

  /// Generate mood score (1-10)
  int _getMoodScore(int dayOffset, int cycleLength) {
    if (dayOffset < 5) return 3 + _random.nextInt(3); // Lower during period
    if (dayOffset < 13) return 6 + _random.nextInt(3); // Higher in follicular
    if (dayOffset >= 13 && dayOffset <= 16) return 7 + _random.nextInt(2); // Peak at ovulation
    return 4 + _random.nextInt(3); // Variable in luteal
  }

  /// Generate energy level (1-10)
  int _getEnergyLevel(int dayOffset, int cycleLength) {
    if (dayOffset < 5) return 3 + _random.nextInt(3);
    if (dayOffset < 13) return 6 + _random.nextInt(3);
    if (dayOffset >= 13 && dayOffset <= 16) return 7 + _random.nextInt(2);
    return 4 + _random.nextInt(3);
  }

  /// Generate symptoms based on cycle phase
  List<String> _getSymptoms(int dayOffset, int cycleLength, bool isPeriodDay) {
    final symptoms = <String>[];
    
    if (isPeriodDay) {
      if (_random.nextBool()) symptoms.add('cramps');
      if (_random.nextDouble() < 0.3) symptoms.add('headache');
      if (_random.nextDouble() < 0.4) symptoms.add('backache');
      if (_random.nextDouble() < 0.3) symptoms.add('bloating');
    }
    
    // Add phase-specific symptoms
    if (dayOffset < 5 && isPeriodDay) {
      if (_random.nextDouble() < 0.5) symptoms.add('fatigue');
      if (_random.nextDouble() < 0.3) symptoms.add('nausea');
    } else if (dayOffset >= 13 && dayOffset <= 16) {
      if (_random.nextDouble() < 0.4) symptoms.add('breast_tenderness');
    } else if (dayOffset > 20) {
      if (_random.nextDouble() < 0.5) symptoms.add('mood_swings');
      if (_random.nextDouble() < 0.3) symptoms.add('acne');
      if (_random.nextDouble() < 0.3) symptoms.add('food_cravings');
    }
    
    return symptoms;
  }

  /// Generate period day notes
  String _getPeriodNotes(int dayIndex) {
    if (dayIndex == 0) return 'Period started today';
    if (dayIndex <= 2) return 'Heavy flow day';
    return 'Period continues';
  }

  /// Generate a complete demo dataset
  DemoDataSet generateCompleteDemo() {
    final cycles = generateDemoCycles();
    return DemoDataSet(cycles: cycles);
  }

  /// Clear all demo data (utility method)
  Future<void> clearDemoData() async {
    // This would integrate with your database service
    // Implementation depends on your DatabaseService API
  }
}

/// Container for a complete demo dataset
class DemoDataSet {
  final List<CycleData> cycles;

  const DemoDataSet({
    required this.cycles,
  });

  /// Total number of data points
  int get totalDataPoints {
    int total = cycles.length;
    for (final cycle in cycles) {
      total += cycle.dailyData.length;
    }
    return total;
  }

  /// Date range of demo data
  DateTime get startDate => cycles.first.startDate;
  DateTime? get endDate => cycles.last.endDate;
}
