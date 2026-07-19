import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/models/cycle_data.dart';
import '../../../core/models/time_period.dart';
import '../../../core/theme/app_theme.dart';

class MoodEnergyChart extends StatelessWidget {
  final List<CycleData> cycleData;
  final TimePeriod selectedPeriod;

  const MoodEnergyChart({
    super.key,
    required this.cycleData,
    required this.selectedPeriod,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredData = _getFilteredData();
    final moodData = _getMoodData(filteredData);
    final energyData = _getEnergyData(filteredData);

    if (moodData.isEmpty && energyData.isEmpty) {
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
                  Icon(Icons.mood, color: AppTheme.primaryPurple),
                  const SizedBox(width: 10),
                  Text(
                    'Mood & Energy Trends',
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (moodData.isNotEmpty)
                _buildLegendItem('Mood', AppTheme.primaryPurple, context),
              if (moodData.isNotEmpty && energyData.isNotEmpty)
                const SizedBox(width: 20),
              if (energyData.isNotEmpty)
                _buildLegendItem('Energy', AppTheme.accentMint, context),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: filteredData.length <= 1
                    ? 1
                    : (filteredData.length - 1).toDouble(),
                minY: 1,
                maxY: 5,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 34,
                      getTitlesWidget: (value, meta) => SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(value.toInt().toString()),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: _getBottomInterval(filteredData.length),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();

                        if ((value - index).abs() > 0.01 ||
                            index < 0 ||
                            index >= filteredData.length) {
                          return const SizedBox.shrink();
                        }

                        final cycle = filteredData[index];

                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            '${cycle.startDate.month}/${cycle.startDate.day}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  if (moodData.isNotEmpty)
                    _buildLine(
                      moodData,
                      AppTheme.primaryPurple,
                      theme,
                      fill: true,
                    ),
                  if (energyData.isNotEmpty)
                    _buildLine(energyData, AppTheme.accentMint, theme),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (spots) {
                      return spots.map((spot) {
                        final isEnergy = moodData.isEmpty || spot.barIndex == 1;
                        final label = isEnergy ? 'Energy' : 'Mood';
                        final color = isEnergy
                            ? AppTheme.accentMint
                            : AppTheme.primaryPurple;

                        return LineTooltipItem(
                          '$label: ${spot.y.toStringAsFixed(1)}/5',
                          TextStyle(color: color, fontWeight: FontWeight.bold),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Avg Mood',
                  _averageLabel(filteredData, (cycle) => cycle.mood),
                  AppTheme.primaryPurple,
                  context,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Avg Energy',
                  _averageLabel(filteredData, (cycle) => cycle.energy),
                  AppTheme.accentMint,
                  context,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Trend',
                  _getTrendDirection(moodData, energyData),
                  AppTheme.secondaryBlue,
                  context,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  LineChartBarData _buildLine(
    List<FlSpot> spots,
    Color color,
    ThemeData theme, {
    bool fill = false,
  }) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: color,
            strokeWidth: 2,
            strokeColor: theme.colorScheme.surface,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: fill,
        color: color.withValues(alpha: 0.1),
      ),
    );
  }

  List<CycleData> _getFilteredData() {
    final cutoffDate = DateTime.now().subtract(
      Duration(days: selectedPeriod.days),
    );

    return cycleData
        .where(
          (cycle) =>
              cycle.startDate.isAfter(cutoffDate) &&
              (cycle.mood != null || cycle.energy != null),
        )
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  List<FlSpot> _getMoodData(List<CycleData> data) {
    return data
        .asMap()
        .entries
        .where((entry) => entry.value.mood != null)
        .map(
          (entry) => FlSpot(
            entry.key.toDouble(),
            entry.value.mood!.clamp(1, 5).toDouble(),
          ),
        )
        .toList();
  }

  List<FlSpot> _getEnergyData(List<CycleData> data) {
    return data
        .asMap()
        .entries
        .where((entry) => entry.value.energy != null)
        .map(
          (entry) => FlSpot(
            entry.key.toDouble(),
            entry.value.energy!.clamp(1, 5).toDouble(),
          ),
        )
        .toList();
  }

  String _averageLabel(
    List<CycleData> data,
    double? Function(CycleData cycle) selector,
  ) {
    final values = data
        .map(selector)
        .whereType<double>()
        .map((value) => value.clamp(1, 5).toDouble())
        .toList();

    if (values.isEmpty) return '—';

    final average = values.reduce((a, b) => a + b) / values.length;
    return '${average.toStringAsFixed(1)}/5';
  }

  String _getTrendDirection(List<FlSpot> moodData, List<FlSpot> energyData) {
    final changes = <double>[];

    if (moodData.length >= 2) {
      changes.add(moodData.last.y - moodData.first.y);
    }

    if (energyData.length >= 2) {
      changes.add(energyData.last.y - energyData.first.y);
    }

    if (changes.isEmpty) return 'Insufficient';

    final improving = changes.any((change) => change > 0.25);
    final declining = changes.any((change) => change < -0.25);

    if (improving && declining) return 'Mixed';
    if (improving) return 'Improving';
    if (declining) return 'Declining';
    return 'Stable';
  }

  double _getBottomInterval(int dataLength) {
    if (dataLength <= 7) return 1;
    if (dataLength <= 14) return 2;
    if (dataLength <= 30) return 5;
    return 10;
  }

  Widget _buildLegendItem(String label, Color color, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    Color color,
    BuildContext context,
  ) {
    return Column(
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
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
          Icon(Icons.mood_bad, size: 48),
          SizedBox(height: 16),
          Text(
            'No Mood or Energy Data Available',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Record mood or energy values to see real trends.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
