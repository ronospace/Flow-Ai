import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/models/cycle_data.dart';
import '../../../core/models/time_period.dart';
import '../../../core/theme/app_theme.dart';

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
    final theme = Theme.of(context);
    final symptomData = _getSymptomData(_getFilteredData());

    if (symptomData.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.grid_view, color: AppTheme.secondaryBlue),
                  const SizedBox(width: 10),
                  Text(
                    'Symptom Frequency',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                selectedPeriod.displayName,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Darker cells mean the symptom was recorded more often '
            'among tracked entries for that cycle day.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('Frequency: '),
              ...List.generate(
                5,
                (index) => Container(
                  margin: const EdgeInsets.only(left: 2),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getFrequencyColor(index / 4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...symptomData.entries.take(8).map((entry) {
            final peakFrequency = entry.value.reduce((a, b) => a > b ? a : b);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      entry.key,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      children: entry.value.map((frequency) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 1),
                            height: 20,
                            decoration: BoxDecoration(
                              color: _getFrequencyColor(frequency),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 42,
                    child: Text(
                      '${(peakFrequency * 100).round()}%',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  List<CycleData> _getFilteredData() {
    final cutoffDate = DateTime.now().subtract(
      Duration(days: selectedPeriod.days),
    );

    return cycleData
        .where((cycle) => cycle.startDate.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  Map<String, List<double>> _getSymptomData(List<CycleData> cycles) {
    final observationsByCycleDay = List<int>.filled(28, 0);
    final symptomCounts = <String, List<int>>{};

    for (final cycle in cycles) {
      final cycleStart = DateTime.utc(
        cycle.startDate.year,
        cycle.startDate.month,
        cycle.startDate.day,
      );

      for (final entry in cycle.dailyData.entries) {
        final trackedDate = DateTime.utc(
          entry.key.year,
          entry.key.month,
          entry.key.day,
        );

        final cycleDay = trackedDate.difference(cycleStart).inDays;

        if (cycleDay < 0 || cycleDay >= 28) continue;

        observationsByCycleDay[cycleDay]++;

        final uniqueSymptoms = entry.value.symptoms
            .map(_formatSymptomName)
            .where((symptom) => symptom.isNotEmpty)
            .toSet();

        for (final symptom in uniqueSymptoms) {
          symptomCounts.putIfAbsent(
            symptom,
            () => List<int>.filled(28, 0),
          )[cycleDay]++;
        }
      }
    }

    final entries =
        symptomCounts.entries.map((entry) {
          final frequencies = List<double>.generate(28, (index) {
            final observations = observationsByCycleDay[index];
            if (observations == 0) return 0;

            return entry.value[index] / observations;
          });

          return MapEntry(entry.key, frequencies);
        }).toList()..sort((a, b) {
          final aTotal = a.value.fold<double>(0, (sum, value) => sum + value);
          final bTotal = b.value.fold<double>(0, (sum, value) => sum + value);
          return bTotal.compareTo(aTotal);
        });

    return Map<String, List<double>>.fromEntries(entries);
  }

  String _formatSymptomName(String value) {
    final words = value
        .trim()
        .split(RegExp(r'[_\s-]+'))
        .where((word) => word.isNotEmpty);

    return words
        .map(
          (word) =>
              '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  Color _getFrequencyColor(double frequency) {
    if (frequency <= 0) return AppTheme.lightGrey;

    final colors = [
      AppTheme.lightGrey,
      AppTheme.primaryRose.withValues(alpha: 0.2),
      AppTheme.primaryRose.withValues(alpha: 0.4),
      AppTheme.primaryRose.withValues(alpha: 0.6),
      AppTheme.primaryRose.withValues(alpha: 0.8),
      AppTheme.primaryRose,
    ];

    final index = (frequency.clamp(0, 1) * (colors.length - 1)).round();
    return colors[index];
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.grid_off, size: 48),
          SizedBox(height: 16),
          Text(
            'No Symptom Data Available',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Record symptoms on tracked days to see real frequencies.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
