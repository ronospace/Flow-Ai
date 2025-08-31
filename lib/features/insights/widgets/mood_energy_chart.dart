import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/cycle_data.dart';
import '../../../core/models/time_period.dart';

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
    
    if (filteredData.isEmpty) {
      return _buildEmptyState(context);
    }

    final moodData = _getMoodData(filteredData);
    final energyData = _getEnergyData(filteredData);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
                      color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.mood,
                      color: AppTheme.primaryPurple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Mood & Energy Trends',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Text(
                selectedPeriod.displayName,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Mood', AppTheme.primaryPurple, context),
              const SizedBox(width: 20),
              _buildLegendItem('Energy', AppTheme.accentMint, context),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Chart
          SizedBox(height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: _getBottomInterval(filteredData.length),
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value.toInt() >= 0 && value.toInt() < filteredData.length) {
                          final data = filteredData[value.toInt()];
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              '${data.startDate.month}/${data.startDate.day}',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                ),
                minX: 0,
                maxX: (filteredData.length - 1).toDouble(),
                minY: 1,
                maxY: 5,
                lineBarsData: [
                  // Mood line
                  LineChartBarData(
                    spots: moodData,
                    isCurved: true,
                    color: AppTheme.primaryPurple,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppTheme.primaryPurple,
                          strokeWidth: 2,
                          strokeColor: theme.colorScheme.surface,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                    ),
                  ),
                  // Energy line
                  LineChartBarData(
                    spots: energyData,
                    isCurved: true,
                    color: AppTheme.accentMint,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppTheme.accentMint,
                          strokeWidth: 2,
                          strokeColor: theme.colorScheme.surface,
                        );
                      },
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    // getTooltipColor removed in newer fl_chart versions - using default styling
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final isEnergyLine = barSpot.barIndex == 1;
                        final label = isEnergyLine ? 'Energy' : 'Mood';
                        final color = isEnergyLine ? AppTheme.accentMint : AppTheme.primaryPurple;
                        
                        return LineTooltipItem(
                          '$label: ${barSpot.y.toInt()}/5',
                          TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Summary stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryItem(
                  'Avg Mood',
                  '${_getAverageMood(filteredData).toStringAsFixed(1)}/5',
                  AppTheme.primaryPurple,
                  Icons.mood,
                  context,
                ),
                _buildSummaryItem(
                  'Avg Energy',
                  '${_getAverageEnergy(filteredData).toStringAsFixed(1)}/5',
                  AppTheme.accentMint,
                  Icons.battery_charging_full,
                  context,
                ),
                _buildSummaryItem(
                  'Trend',
                  _getTrendDirection(moodData, energyData),
                  AppTheme.secondaryBlue,
                  Icons.trending_up,
                  context,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.mood_bad,
            size: 48,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No Mood Data Available',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your mood and energy levels to see trends over time.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, BuildContext context) {
    final theme = Theme.of(context);
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
        Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color, IconData icon, BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 16,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 10,
          ),
        ),
      ],
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

  List<FlSpot> _getMoodData(List<CycleData> data) {
    return data.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final cycle = entry.value;
      // Mock mood data based on cycle phase
      final moodScore = _getMockMoodScore(cycle);
      return FlSpot(index, moodScore.toDouble());
    }).toList();
  }

  List<FlSpot> _getEnergyData(List<CycleData> data) {
    return data.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final cycle = entry.value;
      // Mock energy data based on cycle phase  
      final energyScore = _getMockEnergyScore(cycle);
      return FlSpot(index, energyScore.toDouble());
    }).toList();
  }

  int _getMockMoodScore(CycleData cycle) {
    // Simulate mood patterns based on cycle phase
    final dayInCycle = DateTime.now().difference(cycle.startDate).inDays % 28;
    
    if (dayInCycle < 5) return 3; // Menstrual phase
    if (dayInCycle < 14) return 4; // Follicular phase
    if (dayInCycle < 16) return 5; // Ovulation
    return 3; // Luteal phase
  }

  int _getMockEnergyScore(CycleData cycle) {
    // Simulate energy patterns based on cycle phase
    final dayInCycle = DateTime.now().difference(cycle.startDate).inDays % 28;
    
    if (dayInCycle < 5) return 2; // Menstrual phase
    if (dayInCycle < 14) return 4; // Follicular phase  
    if (dayInCycle < 16) return 5; // Ovulation
    return 3; // Luteal phase
  }

  double _getBottomInterval(int dataLength) {
    if (dataLength <= 7) return 1;
    if (dataLength <= 14) return 2;
    if (dataLength <= 30) return 5;
    return 10;
  }

  double _getAverageMood(List<CycleData> data) {
    if (data.isEmpty) return 0;
    return data.map(_getMockMoodScore).reduce((a, b) => a + b) / data.length;
  }

  double _getAverageEnergy(List<CycleData> data) {
    if (data.isEmpty) return 0;
    return data.map(_getMockEnergyScore).reduce((a, b) => a + b) / data.length;
  }

  String _getTrendDirection(List<FlSpot> moodData, List<FlSpot> energyData) {
    if (moodData.length < 2 || energyData.length < 2) return 'Stable';
    
    final moodTrend = moodData.last.y - moodData.first.y;
    final energyTrend = energyData.last.y - energyData.first.y;
    
    if (moodTrend > 0 && energyTrend > 0) return 'Improving';
    if (moodTrend < 0 && energyTrend < 0) return 'Declining';
    return 'Mixed';
  }
}
