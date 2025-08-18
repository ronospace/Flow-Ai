import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/services/analytics_service.dart';

class PredictionAnalyticsCard extends StatelessWidget {
  final PredictionAnalytics analytics;

  const PredictionAnalyticsCard({
    super.key,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
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
          // Header
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prediction Analytics',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'AI prediction accuracy insights',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Accuracy Overview
          Row(
            children: [
              Expanded(
                child: _buildAccuracyCard(
                  'Confidence Score',
                  '${analytics.confidenceScore.round()}%',
                  Icons.psychology,
                  _getConfidenceColor(analytics.confidenceScore),
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAccuracyCard(
                  'Avg Accuracy',
                  '±${analytics.averageAccuracyDays.round()} days',
                  Icons.target,
                  _getAccuracyColor(analytics.averageAccuracyDays),
                  theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAccuracyCard(
                  'Total Predictions',
                  '${analytics.totalPredictions}',
                  Icons.timeline,
                  theme.colorScheme.primary,
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAccuracyCard(
                  'Success Rate',
                  '${_calculateSuccessRate(analytics).round()}%',
                  Icons.check_circle,
                  Colors.green,
                  theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Accuracy Trend Chart
          _buildAccuracyTrendChart(theme),
          const SizedBox(height: 20),

          // Accuracy Distribution
          _buildAccuracyDistribution(theme),
          const SizedBox(height: 20),

          // Improvement Tips
          _buildImprovementTips(theme),
        ],
      ),
    );
  }

  Widget _buildAccuracyCard(
    String title,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getAccuracyTrendIcon(analytics.confidenceScore),
                  color: color,
                  size: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyTrendChart(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prediction Accuracy Over Time',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 150,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}d',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 2,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        'C${value.toInt()}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minX: 1,
              maxX: analytics.accuracyHistory.length.toDouble(),
              minY: 0,
              maxY: 5,
              lineBarsData: [
                LineChartBarData(
                  spots: _getAccuracySpots(),
                  isCurved: true,
                  color: Colors.orange,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      final accuracy = spot.y;
                      return FlDotCirclePainter(
                        radius: 4,
                        color: _getAccuracyColor(accuracy),
                        strokeWidth: 2,
                        strokeColor: theme.colorScheme.surface,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.orange.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lower is better (days off)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getConfidenceColor(analytics.confidenceScore).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getConfidenceLabel(analytics.confidenceScore),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getConfidenceColor(analytics.confidenceScore),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccuracyDistribution(ThemeData theme) {
    final distribution = _calculateAccuracyDistribution();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prediction Accuracy Distribution',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 120,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: distribution.values.reduce((a, b) => a > b ? a : b).toDouble() + 1,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final labels = ['Perfect', '±1 day', '±2 days', '±3+ days'];
                      if (value.toInt() < labels.length) {
                        return Text(
                          labels[value.toInt()],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: false),
              barGroups: distribution.entries.map((entry) {
                final index = distribution.keys.toList().indexOf(entry.key);
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.toDouble(),
                      color: _getDistributionColor(entry.key),
                      width: 20,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImprovementTips(ThemeData theme) {
    final tips = _getImprovementTips();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Improvement Tips',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...tips.map((tip) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: theme.colorScheme.primary,
                size: 16,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tip,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  List<FlSpot> _getAccuracySpots() {
    return analytics.accuracyHistory.asMap().entries.map((entry) {
      return FlSpot(
        (entry.key + 1).toDouble(),
        entry.value.accuracyDays.toDouble(),
      );
    }).toList();
  }

  Map<String, int> _calculateAccuracyDistribution() {
    final distribution = <String, int>{
      'perfect': 0,
      '1day': 0,
      '2days': 0,
      '3plus': 0,
    };

    for (final accuracy in analytics.accuracyHistory) {
      if (accuracy.accuracyDays == 0) {
        distribution['perfect'] = distribution['perfect']! + 1;
      } else if (accuracy.accuracyDays == 1) {
        distribution['1day'] = distribution['1day']! + 1;
      } else if (accuracy.accuracyDays == 2) {
        distribution['2days'] = distribution['2days']! + 1;
      } else {
        distribution['3plus'] = distribution['3plus']! + 1;
      }
    }

    return distribution;
  }

  List<String> _getImprovementTips() {
    final tips = <String>[];
    
    if (analytics.confidenceScore < 70) {
      tips.add('Track your cycles consistently for better predictions');
    }
    
    if (analytics.averageAccuracyDays > 2) {
      tips.add('Log your period start dates accurately');
    }
    
    if (analytics.totalPredictions < 6) {
      tips.add('More cycle data will improve prediction accuracy');
    }
    
    tips.add('Note irregular patterns to help AI learn your unique cycle');
    
    return tips;
  }

  double _calculateSuccessRate(PredictionAnalytics analytics) {
    if (analytics.accuracyHistory.isEmpty) return 0.0;
    
    final successfulPredictions = analytics.accuracyHistory
        .where((accuracy) => accuracy.accuracyDays <= 1)
        .length;
    
    return (successfulPredictions / analytics.accuracyHistory.length) * 100;
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 80) return Colors.green;
    if (confidence >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy <= 1) return Colors.green;
    if (accuracy <= 2) return Colors.orange;
    return Colors.red;
  }

  Color _getDistributionColor(String category) {
    switch (category) {
      case 'perfect':
        return Colors.green;
      case '1day':
        return Colors.lightGreen;
      case '2days':
        return Colors.orange;
      case '3plus':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getConfidenceLabel(double confidence) {
    if (confidence >= 80) return 'High Confidence';
    if (confidence >= 60) return 'Medium Confidence';
    if (confidence >= 40) return 'Low Confidence';
    return 'Building Confidence';
  }

  IconData _getAccuracyTrendIcon(double confidence) {
    if (confidence >= 70) return Icons.trending_up;
    if (confidence >= 50) return Icons.trending_flat;
    return Icons.trending_down;
  }
}
