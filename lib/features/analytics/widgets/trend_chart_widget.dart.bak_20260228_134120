import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/theme/app_theme.dart';

class TrendChartWidget extends StatelessWidget {
  final TrendAnalytics analytics;

  const TrendChartWidget({
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
                Icons.trending_up,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trend Analysis',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Health trends over ${analytics.timeframe}',
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

          // Trend Summary Cards
          _buildTrendSummaryCards(theme),
          const SizedBox(height: 20),

          // Main Trend Chart
          _buildMainTrendChart(theme),
          const SizedBox(height: 20),

          // Individual Metric Charts
          _buildIndividualMetricCharts(theme),
        ],
      ),
    );
  }

  Widget _buildTrendSummaryCards(ThemeData theme) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: analytics.trends.entries.map((entry) {
        return _buildTrendSummaryCard(
          _getTrendTitle(entry.key),
          entry.value,
          _getTrendIcon(entry.key),
          _getTrendColor(entry.key),
          theme,
        );
      }).toList(),
    );
  }

  Widget _buildTrendSummaryCard(
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
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      _getTrendDirectionIcon(trend.direction),
                      color: _getTrendDirectionColor(trend.direction),
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getTrendDirectionLabel(trend.direction),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getTrendDirectionColor(trend.direction),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainTrendChart(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Combined Health Trends',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
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
                        value.toInt().toString(),
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
                    interval: 30,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${(value / 30).round()}M',
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
              minX: 0,
              maxX: 180,
              minY: 1,
              maxY: 5,
              lineBarsData: _buildTrendLines(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: analytics.trends.entries.map((entry) {
            return _buildLegendItem(
              _getTrendTitle(entry.key),
              _getTrendColor(entry.key),
              theme,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIndividualMetricCharts(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Individual Metric Analysis',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...analytics.trends.entries.map((entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: _buildIndividualMetricChart(
              _getTrendTitle(entry.key),
              entry.value,
              _getTrendColor(entry.key),
              theme,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildIndividualMetricChart(
    String title,
    TrendData trend,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTrendDirectionColor(trend.direction).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getTrendDirectionIcon(trend.direction),
                      color: _getTrendDirectionColor(trend.direction),
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getTrendDirectionLabel(trend.direction),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getTrendDirectionColor(trend.direction),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 80,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 30,
                minY: 1,
                maxY: 5,
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateSampleSpots(trend),
                    isCurved: true,
                    color: color,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withValues(alpha: 0.1),
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
                'Confidence: ${(trend.confidence * 100).round()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                'Magnitude: ${(trend.magnitude * 100).round()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
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

  List<LineChartBarData> _buildTrendLines() {
    return analytics.trends.entries.map((entry) {
      return LineChartBarData(
        spots: _generateSampleSpots(entry.value, extended: true),
        isCurved: true,
        color: _getTrendColor(entry.key),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
      );
    }).toList();
  }

  List<FlSpot> _generateSampleSpots(TrendData trend, {bool extended = false}) {
    final length = extended ? 180 : 30;
    final baseValue = 3.0;
    
    return List.generate(length ~/ 5, (index) {
      final x = (index * 5).toDouble();
      var y = baseValue;
      
      // Apply trend direction
      switch (trend.direction) {
        case TrendDirection.improving:
          y += (index / (length / 5)) * trend.magnitude;
          break;
        case TrendDirection.declining:
          y -= (index / (length / 5)) * trend.magnitude;
          break;
        case TrendDirection.stable:
          y += (index % 3 - 1) * 0.1; // Small random variations
          break;
      }
      
      return FlSpot(x, y.clamp(1.0, 5.0));
    });
  }

  String _getTrendTitle(String key) {
    switch (key) {
      case 'mood':
        return 'Mood';
      case 'energy':
        return 'Energy';
      case 'sleep':
        return 'Sleep';
      default:
        return key.toUpperCase();
    }
  }

  IconData _getTrendIcon(String key) {
    switch (key) {
      case 'mood':
        return Icons.mood;
      case 'energy':
        return Icons.battery_charging_full;
      case 'sleep':
        return Icons.bed;
      default:
        return Icons.show_chart;
    }
  }

  Color _getTrendColor(String key) {
    // Use AppTheme colors for consistency with brand colors
    switch (key) {
      case 'mood':
        return AppTheme.primaryPurple;
      case 'energy':
        return AppTheme.accentMint;
      case 'sleep':
        return AppTheme.secondaryBlue;
      default:
        return AppTheme.mediumGrey;
    }
  }

  IconData _getTrendDirectionIcon(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.improving:
        return Icons.trending_up;
      case TrendDirection.declining:
        return Icons.trending_down;
      case TrendDirection.stable:
        return Icons.trending_flat;
    }
  }

  Color _getTrendDirectionColor(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.improving:
        return AppTheme.successGreen;
      case TrendDirection.declining:
        return AppTheme.errorRed;
      case TrendDirection.stable:
        return AppTheme.mediumGrey;
    }
  }

  String _getTrendDirectionLabel(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.improving:
        return 'Improving';
      case TrendDirection.declining:
        return 'Declining';
      case TrendDirection.stable:
        return 'Stable';
    }
  }
}
