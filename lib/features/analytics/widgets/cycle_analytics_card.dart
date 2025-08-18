import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/services/analytics_service.dart';

class CycleAnalyticsCard extends StatelessWidget {
  final CycleAnalytics analytics;

  const CycleAnalyticsCard({
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
                Icons.favorite,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cycle Analytics',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Last updated ${_formatDate(analytics.lastUpdated)}',
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

          // Key Metrics Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total Cycles',
                  '${analytics.totalCycles}',
                  Icons.calendar_month,
                  theme.colorScheme.primary,
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Avg Length',
                  '${analytics.averageCycleLength.round()} days',
                  Icons.timeline,
                  Colors.blue,
                  theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Period Length',
                  '${analytics.averagePeriodLength.round()} days',
                  Icons.water_drop,
                  Colors.red,
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Regularity',
                  '${(analytics.regularityScore * 100).round()}%',
                  Icons.trending_up,
                  _getRegularityColor(analytics.regularityScore),
                  theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Regularity Chart
          _buildRegularityChart(theme),
          const SizedBox(height: 20),

          // Flow Pattern Analysis
          _buildFlowPatternSection(theme),
          const SizedBox(height: 20),

          // Symptom Frequency
          if (analytics.symptomFrequency.isNotEmpty)
            _buildSymptomFrequencySection(theme),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
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
                  Icons.arrow_upward,
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

  Widget _buildRegularityChart(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cycle Regularity Trend',
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
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 0.2,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: false,
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: 6,
              minY: 0,
              maxY: 1,
              lineBarsData: [
                LineChartBarData(
                  spots: _getRegularitySpots(),
                  isCurved: true,
                  color: _getRegularityColor(analytics.regularityScore),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: _getRegularityColor(analytics.regularityScore),
                        strokeWidth: 2,
                        strokeColor: theme.colorScheme.surface,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: _getRegularityColor(analytics.regularityScore).withValues(alpha: 0.2),
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
              'Variation: ±${analytics.cycleVariation.round()} days',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getRegularityColor(analytics.regularityScore).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getRegularityLabel(analytics.regularityScore),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getRegularityColor(analytics.regularityScore),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFlowPatternSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Flow Pattern',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getFlowPatternColor(analytics.flowPattern).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getFlowPatternColor(analytics.flowPattern).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _getFlowPatternIcon(analytics.flowPattern),
                      color: _getFlowPatternColor(analytics.flowPattern),
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getFlowPatternLabel(analytics.flowPattern),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getFlowPatternDescription(analytics.flowPattern),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSymptomFrequencySection(ThemeData theme) {
    final topSymptoms = analytics.symptomFrequency.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Common Symptoms',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...topSymptoms.take(5).map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  entry.key,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: LinearProgressIndicator(
                  value: entry.value,
                  backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(entry.value * 100).round()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  List<FlSpot> _getRegularitySpots() {
    // Generate sample regularity data
    return [
      const FlSpot(0, 0.6),
      const FlSpot(1, 0.7),
      const FlSpot(2, 0.8),
      const FlSpot(3, 0.75),
      const FlSpot(4, 0.85),
      const FlSpot(5, 0.9),
      FlSpot(6, analytics.regularityScore),
    ];
  }

  Color _getRegularityColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _getRegularityLabel(double score) {
    if (score >= 0.8) return 'Excellent';
    if (score >= 0.6) return 'Good';
    if (score >= 0.4) return 'Fair';
    return 'Irregular';
  }

  Color _getFlowPatternColor(FlowPattern pattern) {
    switch (pattern) {
      case FlowPattern.light:
        return Colors.blue;
      case FlowPattern.medium:
        return Colors.orange;
      case FlowPattern.heavy:
        return Colors.red;
      case FlowPattern.variable:
        return Colors.purple;
      case FlowPattern.unknown:
        return Colors.grey;
    }
  }

  IconData _getFlowPatternIcon(FlowPattern pattern) {
    switch (pattern) {
      case FlowPattern.light:
        return Icons.water_drop_outlined;
      case FlowPattern.medium:
        return Icons.water_drop;
      case FlowPattern.heavy:
        return Icons.water;
      case FlowPattern.variable:
        return Icons.show_chart;
      case FlowPattern.unknown:
        return Icons.help_outline;
    }
  }

  String _getFlowPatternLabel(FlowPattern pattern) {
    switch (pattern) {
      case FlowPattern.light:
        return 'Light Flow';
      case FlowPattern.medium:
        return 'Medium Flow';
      case FlowPattern.heavy:
        return 'Heavy Flow';
      case FlowPattern.variable:
        return 'Variable Flow';
      case FlowPattern.unknown:
        return 'Unknown Pattern';
    }
  }

  String _getFlowPatternDescription(FlowPattern pattern) {
    switch (pattern) {
      case FlowPattern.light:
        return 'Consistently lighter periods';
      case FlowPattern.medium:
        return 'Moderate, steady flow';
      case FlowPattern.heavy:
        return 'Heavier than average flow';
      case FlowPattern.variable:
        return 'Varies from cycle to cycle';
      case FlowPattern.unknown:
        return 'Not enough data yet';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'today';
    if (difference == 1) return 'yesterday';
    if (difference < 7) return '$difference days ago';
    
    return '${date.day}/${date.month}/${date.year}';
  }
}
