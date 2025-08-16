import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/cycle_data.dart';
import '../../../core/models/time_period.dart';

class SymptomHeatmap extends StatelessWidget {
  final List<CycleData> cycleData;
  final TimePeriod selectedPeriod;

  const SymptomHeatmap({
    super.key,
    required this.cycleData,
    required this.selectedPeriod,
  });

  @override
  Widget build(BuildContext context) {
    final filteredData = _getFilteredData();
    
    if (filteredData.isEmpty) {
      return _buildEmptyState(context);
    }

    final symptomData = _getSymptomData(filteredData);
    final symptoms = symptomData.keys.toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.grid_view,
                      color: AppTheme.secondaryBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Symptom Patterns',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkGrey,
                    ),
                  ),
                ],
              ),
              Text(
                selectedPeriod.displayName,
                style: TextStyle(
                  color: AppTheme.mediumGrey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Heatmap
          if (symptoms.isNotEmpty) ...[
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Intensity: ',
                  style: TextStyle(
                    color: AppTheme.mediumGrey,
                    fontSize: 12,
                  ),
                ),
                ...List.generate(5, (index) {
                  return Container(
                    margin: const EdgeInsets.only(left: 2),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getIntensityColor(index / 4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Symptom grid
            ...symptoms.take(8).map((symptom) {
              final intensities = symptomData[symptom]!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    // Symptom label
                    SizedBox(
                      width: 100,
                      child: Text(
                        symptom,
                        style: TextStyle(
                          color: AppTheme.darkGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Intensity cells
                    Expanded(
                      child: Row(
                        children: intensities.take(28).toList().asMap().entries.map((entry) {
                          final intensity = entry.value;
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(right: 1),
                              height: 20,
                              decoration: BoxDecoration(
                                color: _getIntensityColor(intensity),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: intensity > 0 
                                  ? Center(
                                      child: Text(
                                        intensity.toInt().toString(),
                                        style: TextStyle(
                                          color: intensity > 0.5 ? Colors.white : AppTheme.darkGrey,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Average intensity
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getIntensityColor(_getAverageIntensity(intensities)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getAverageIntensity(intensities).toStringAsFixed(1),
                        style: TextStyle(
                          color: _getAverageIntensity(intensities) > 0.5 
                              ? Colors.white 
                              : AppTheme.darkGrey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          
          const SizedBox(height: 20),
          
          // Insights
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightGrey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pattern Insights',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGrey,
                  ),
                ),
                const SizedBox(height: 8),
                ...symptoms.take(3).map((symptom) {
                  final intensities = symptomData[symptom]!;
                  final pattern = _analyzePattern(intensities);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          _getPatternIcon(pattern),
                          size: 14,
                          color: AppTheme.secondaryBlue,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '$symptom: ${_getPatternDescription(pattern)}',
                            style: TextStyle(
                              color: AppTheme.mediumGrey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.grid_off,
            size: 48,
            color: AppTheme.lightGrey,
          ),
          const SizedBox(height: 16),
          Text(
            'No Symptom Data Available',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.mediumGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your symptoms to see patterns and correlations.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.mediumGrey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  List<CycleData> _getFilteredData() {
    final now = DateTime.now();
    DateTime cutoffDate;

    switch (selectedPeriod) {
      case TimePeriod.week:
        cutoffDate = now.subtract(const Duration(days: 7));
        break;
      case TimePeriod.month:
        cutoffDate = now.subtract(const Duration(days: 30));
        break;
      case TimePeriod.threeMonths:
        cutoffDate = now.subtract(const Duration(days: 90));
        break;
      case TimePeriod.sixMonths:
        cutoffDate = now.subtract(const Duration(days: 180));
        break;
      case TimePeriod.year:
        cutoffDate = now.subtract(const Duration(days: 365));
        break;
    }

    return cycleData
        .where((cycle) => cycle.startDate.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  Map<String, List<double>> _getSymptomData(List<CycleData> data) {
    // Mock symptom data with realistic patterns
    final symptoms = [
      'Cramps',
      'Headache',
      'Mood Swings',
      'Bloating',
      'Fatigue',
      'Breast Tenderness',
      'Acne',
      'Appetite Changes',
      'Sleep Issues',
      'Back Pain',
    ];

    final Map<String, List<double>> symptomData = {};
    
    for (final symptom in symptoms) {
      symptomData[symptom] = _generateSymptomPattern(symptom, data.length * 28);
    }

    return symptomData;
  }

  List<double> _generateSymptomPattern(String symptom, int totalDays) {
    final pattern = <double>[];
    
    for (int day = 0; day < totalDays.clamp(0, 28); day++) {
      final cycleDay = day % 28 + 1;
      double intensity = 0;

      // Different symptoms have different patterns
      switch (symptom) {
        case 'Cramps':
          if (cycleDay <= 5) intensity = 0.8 - (cycleDay - 1) * 0.15;
          break;
        case 'Headache':
          if (cycleDay <= 3 || cycleDay >= 25) intensity = 0.6;
          if (cycleDay >= 12 && cycleDay <= 16) intensity = 0.4;
          break;
        case 'Mood Swings':
          if (cycleDay <= 5) intensity = 0.7;
          if (cycleDay >= 20) intensity = 0.5 + (cycleDay - 20) * 0.05;
          break;
        case 'Bloating':
          if (cycleDay <= 5) intensity = 0.6;
          if (cycleDay >= 18) intensity = 0.4 + (cycleDay - 18) * 0.03;
          break;
        case 'Fatigue':
          if (cycleDay <= 6) intensity = 0.8 - (cycleDay - 1) * 0.1;
          if (cycleDay >= 22) intensity = 0.3 + (cycleDay - 22) * 0.05;
          break;
        case 'Breast Tenderness':
          if (cycleDay >= 14) intensity = 0.3 + (cycleDay - 14) * 0.03;
          break;
        case 'Acne':
          if (cycleDay >= 20) intensity = 0.4 + (cycleDay - 20) * 0.05;
          break;
        default:
          if (cycleDay <= 5) intensity = 0.4;
          if (cycleDay >= 20) intensity = 0.3;
      }

      pattern.add(intensity.clamp(0, 1));
    }

    return pattern;
  }

  Color _getIntensityColor(double intensity) {
    if (intensity <= 0) return AppTheme.lightGrey;
    
    final colors = [
      AppTheme.lightGrey,
      AppTheme.primaryRose.withOpacity(0.2),
      AppTheme.primaryRose.withOpacity(0.4),
      AppTheme.primaryRose.withOpacity(0.6),
      AppTheme.primaryRose.withOpacity(0.8),
      AppTheme.primaryRose,
    ];
    
    final index = (intensity * (colors.length - 1)).round();
    return colors[index.clamp(0, colors.length - 1)];
  }

  double _getAverageIntensity(List<double> intensities) {
    if (intensities.isEmpty) return 0;
    final nonZeroIntensities = intensities.where((i) => i > 0).toList();
    if (nonZeroIntensities.isEmpty) return 0;
    return nonZeroIntensities.reduce((a, b) => a + b) / nonZeroIntensities.length;
  }

  String _analyzePattern(List<double> intensities) {
    final nonZeroCount = intensities.where((i) => i > 0).length;
    final totalDays = intensities.length;
    
    if (nonZeroCount == 0) return 'None';
    
    final frequency = nonZeroCount / totalDays;
    
    // Check for menstrual phase pattern (first 5-7 days)
    final menstrualPhase = intensities.take(7).where((i) => i > 0).length;
    if (menstrualPhase >= 4) return 'Menstrual';
    
    // Check for luteal phase pattern (last 10-14 days)
    final lutealPhase = intensities.skip(intensities.length - 14).where((i) => i > 0).length;
    if (lutealPhase >= 7) return 'Luteal';
    
    // Check for ovulation pattern (mid-cycle)
    final midCycle = intensities.skip(10).take(8).where((i) => i > 0).length;
    if (midCycle >= 3) return 'Ovulation';
    
    if (frequency > 0.5) return 'Frequent';
    if (frequency > 0.2) return 'Moderate';
    return 'Occasional';
  }

  IconData _getPatternIcon(String pattern) {
    switch (pattern) {
      case 'Menstrual':
        return Icons.water_drop;
      case 'Luteal':
        return Icons.trending_down;
      case 'Ovulation':
        return Icons.circle;
      case 'Frequent':
        return Icons.repeat;
      case 'Moderate':
        return Icons.remove;
      case 'Occasional':
        return Icons.scatter_plot;
      default:
        return Icons.help_outline;
    }
  }

  String _getPatternDescription(String pattern) {
    switch (pattern) {
      case 'Menstrual':
        return 'Occurs primarily during menstruation';
      case 'Luteal':
        return 'Increases in the luteal phase';
      case 'Ovulation':
        return 'Peaks around ovulation';
      case 'Frequent':
        return 'Occurs regularly throughout cycle';
      case 'Moderate':
        return 'Appears moderately throughout cycle';
      case 'Occasional':
        return 'Occurs occasionally';
      case 'None':
        return 'No significant pattern detected';
      default:
        return 'Pattern analysis unavailable';
    }
  }
}
