import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/theme/app_theme.dart';

class HealthAnalyticsCard extends StatelessWidget {
  final HealthAnalytics analytics;
  final AnalyticsHistory history;

  const HealthAnalyticsCard({
    super.key,
    required this.analytics,
    required this.history,
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
                Icons.local_hospital,
                color: AppTheme.successGreen,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Analytics',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Last updated ${_formatDate(analytics.lastUpdated)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Overall Health Score
          _buildHealthScoreSection(theme),
          const SizedBox(height: 20),

          // Health Metrics
          Row(
            children: [
              Expanded(
                child: _buildTrendCard(
                  'Mood',
                  analytics.moodTrend,
                  Icons.mood,
                  AppTheme.primaryPurple,
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTrendCard(
                  'Energy',
                  analytics.energyTrend,
                  Icons.battery_charging_full,
                  AppTheme.warningOrange,
                  theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTrendCard(
                  'Sleep',
                  analytics.sleepTrend,
                  Icons.bed,
                  AppTheme.secondaryBlue,
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              // Add wellness tips card
              Expanded(child: _buildWellnessTipsCard(theme)),
            ],
          ),
          const SizedBox(height: 20),

          // Health Trends Chart
          _buildHealthTrendsChart(theme, history),
        ],
      ),
    );
  }

  Widget _buildHealthScoreSection(ThemeData theme) {
    final score = analytics.overallHealthScore;
    final scoreColor = _getHealthScoreColor(score);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scoreColor.withValues(alpha: 0.1),
            scoreColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Score Circle
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 8,
              backgroundColor: scoreColor.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Health Score',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${score.round()}',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '/100',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _getHealthScoreLabel(score),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard(
    String title,
    TrendData trend,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const Spacer(),
              Icon(
                _getTrendIcon(trend.direction),
                color: _getTrendColor(trend.direction),
                size: 14,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _getTrendLabel(trend.direction),
            style: theme.textTheme.bodySmall?.copyWith(
              color: _getTrendColor(trend.direction),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessTipsCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: theme.colorScheme.primary, size: 16),
              const Spacer(),
              Icon(
                Icons.arrow_forward,
                color: theme.colorScheme.primary,
                size: 14,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Wellness Tips',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'View tips',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTrendsChart(ThemeData theme, AnalyticsHistory history) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Health Trends",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        _buildHistoryMetricChart(
          theme,
          label: "Mood",
          unit: "/10",
          values: history.mood,
          color: AppTheme.primaryPurple,
          fixedMaxY: 10,
        ),
        const SizedBox(height: 12),
        _buildHistoryMetricChart(
          theme,
          label: "Energy",
          unit: "/10",
          values: history.energy,
          color: AppTheme.warningOrange,
          fixedMaxY: 10,
        ),
        const SizedBox(height: 12),
        _buildHistoryMetricChart(
          theme,
          label: "Sleep",
          unit: "hours",
          values: history.sleepHours,
          color: AppTheme.secondaryBlue,
        ),
      ],
    );
  }

  Widget _buildHistoryMetricChart(
    ThemeData theme, {
    required String label,
    required String unit,
    required Map<DateTime, double> values,
    required Color color,
    double? fixedMaxY,
  }) {
    final entries =
        values.entries.where((entry) => entry.value.isFinite).toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    if (entries.isEmpty) {
      return Container(
        height: 96,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          "No $label history available",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
      );
    }

    final origin = DateTime(
      entries.first.key.year,
      entries.first.key.month,
      entries.first.key.day,
    );

    final segments = <List<FlSpot>>[];
    var segment = <FlSpot>[];
    DateTime? previousDay;
    var observedMax = 0.0;

    for (final entry in entries) {
      final day = DateTime(entry.key.year, entry.key.month, entry.key.day);

      if (previousDay != null && day.difference(previousDay).inDays > 1) {
        if (segment.isNotEmpty) {
          segments.add(segment);
        }
        segment = <FlSpot>[];
      }

      segment.add(
        FlSpot(day.difference(origin).inDays.toDouble(), entry.value),
      );

      if (entry.value > observedMax) {
        observedMax = entry.value;
      }

      previousDay = day;
    }

    if (segment.isNotEmpty) {
      segments.add(segment);
    }

    final maxX = entries.last.key.difference(origin).inDays.toDouble();

    final maxY = fixedMaxY ?? (observedMax > 0 ? observedMax * 1.1 : 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label ($unit)",
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 130,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 34,
                    getTitlesWidget: (value, meta) => Text(
                      value.toStringAsFixed(
                        value == value.roundToDouble() ? 0 : 1,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.65,
                        ),
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: maxX > 5 ? (maxX / 5).ceilToDouble() : 1,
                    getTitlesWidget: (value, meta) => Text(
                      "${value.toInt()}d",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.65,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: maxX > 0 ? maxX : 1,
              minY: 0,
              maxY: maxY,
              lineBarsData: segments
                  .map(
                    (points) => LineChartBarData(
                      spots: points,
                      isCurved: false,
                      color: color,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: points.length == 1),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 2,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Color _getHealthScoreColor(double score) {
    if (score >= 80) return AppTheme.successGreen;
    if (score >= 60) return AppTheme.warningOrange;
    return AppTheme.errorRed;
  }

  String _getHealthScoreLabel(double score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Needs Attention';
  }

  IconData _getTrendIcon(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.improving:
        return Icons.trending_up;
      case TrendDirection.declining:
        return Icons.trending_down;
      case TrendDirection.stable:
        return Icons.trending_flat;
    }
  }

  Color _getTrendColor(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.improving:
        return AppTheme.successGreen;
      case TrendDirection.declining:
        return AppTheme.errorRed;
      case TrendDirection.stable:
        return AppTheme.mediumGrey;
    }
  }

  String _getTrendLabel(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.improving:
        return 'Improving';
      case TrendDirection.declining:
        return 'Declining';
      case TrendDirection.stable:
        return 'Stable';
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
