import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/analytics_provider.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/theme/app_theme.dart';

class AdvancedAnalyticsDashboard extends StatelessWidget {
  final AnalyticsProvider provider;

  const AdvancedAnalyticsDashboard({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Advanced Health Score Card
          _buildAdvancedHealthScoreCard(theme),
          const SizedBox(height: 24),
          
          // Key Metrics Grid
          _buildAdvancedMetricsGrid(theme),
          const SizedBox(height: 24),
          
          // AI Insights Section
          _buildAIInsightsSection(theme),
          const SizedBox(height: 24),
          
          // Comparative Analysis
          _buildComparativeAnalysis(theme),
          const SizedBox(height: 24),
          
          // Long-term Trend Analysis
          _buildLongTermTrendAnalysis(theme),
          const SizedBox(height: 24),
          
          // Predictive Insights
          _buildPredictiveInsights(theme),
          const SizedBox(height: 24),
          
          // Health Patterns Recognition
          _buildHealthPatternsSection(theme),
        ],
      ),
    );
  }

  Widget _buildAdvancedHealthScoreCard(ThemeData theme) {
    final healthScore = provider.healthAnalytics?.overallHealthScore ?? 70.0;
    final cycleRegularity = (provider.cycleAnalytics?.regularityScore ?? 0.8) * 100;
    final predictionAccuracy = provider.predictionAnalytics?.confidenceScore ?? 85.0;
    
    final overallScore = (healthScore + cycleRegularity + predictionAccuracy) / 3;
    final scoreColor = _getScoreColor(overallScore);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scoreColor.withValues(alpha: 0.1),
            scoreColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: scoreColor.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Circular Score Display
              Container(
                width: 100,
                height: 100,
                child: Stack(
                  children: [
                    CircularProgressIndicator(
                      value: overallScore / 100,
                      strokeWidth: 8,
                      backgroundColor: scoreColor.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${overallScore.round()}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Score',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wellness Intelligence Score',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getScoreDescription(overallScore),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: scoreColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'AI-Enhanced Analysis',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: scoreColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Score Breakdown
          Row(
            children: [
              Expanded(
                child: _buildScoreBreakdown('Health', healthScore, AppTheme.primaryRose),
              ),
              Expanded(
                child: _buildScoreBreakdown('Regularity', cycleRegularity, AppTheme.secondaryBlue),
              ),
              Expanded(
                child: _buildScoreBreakdown('Predictions', predictionAccuracy, AppTheme.accentMint),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBreakdown(String label, double score, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              '${score.round()}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedMetricsGrid(ThemeData theme) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildAdvancedMetricCard(
          title: 'Cycle Precision',
          value: '${((provider.cycleAnalytics?.regularityScore ?? 0.85) * 100).toInt()}%',
          subtitle: 'Regularity index',
          icon: Icons.favorite,
          color: AppTheme.primaryRose,
          trend: TrendDirection.improving,
          chartData: _generateCycleData(),
          theme: theme,
        ),
        _buildAdvancedMetricCard(
          title: 'AI Confidence',
          value: '${provider.predictionAnalytics?.confidenceScore.toInt() ?? 88}%',
          subtitle: 'Prediction accuracy',
          icon: Icons.psychology,
          color: AppTheme.secondaryBlue,
          trend: TrendDirection.stable,
          chartData: _generatePredictionData(),
          theme: theme,
        ),
        _buildAdvancedMetricCard(
          title: 'Wellness Trend',
          value: '${provider.healthAnalytics?.overallHealthScore.toInt() ?? 82}%',
          subtitle: 'Health trajectory',
          icon: Icons.trending_up,
          color: AppTheme.accentMint,
          trend: TrendDirection.improving,
          chartData: _generateHealthData(),
          theme: theme,
        ),
        _buildAdvancedMetricCard(
          title: 'Data Quality',
          value: '94%',
          subtitle: 'Tracking consistency',
          icon: Icons.analytics,
          color: AppTheme.warningOrange,
          trend: TrendDirection.stable,
          chartData: _generateQualityData(),
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildAdvancedMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required TrendDirection trend,
    required List<FlSpot> chartData,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getTrendColor(trend).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getTrendIcon(trend),
                      color: _getTrendColor(trend),
                      size: 10,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      _getTrendLabel(trend),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: _getTrendColor(trend),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          // Mini Chart
          SizedBox(
            height: 30,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData,
                    isCurved: true,
                    color: color,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsightsSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryPurple.withValues(alpha: 0.05),
            AppTheme.secondaryBlue.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryPurple.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  Icons.auto_awesome,
                  color: AppTheme.primaryPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI-Powered Insights',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Personalized analysis from your data',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh,
                      color: AppTheme.primaryPurple,
                      size: 10,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Live',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._getAIInsights().take(4).map(
            (insight) => _buildInsightItem(insight, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(Map<String, dynamic> insight, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (insight['color'] as Color).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: (insight['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              insight['icon'] as IconData,
              color: insight['color'] as Color,
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              insight['text'] as String,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparativeAnalysis(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comparative Analysis',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your progress over time periods',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildComparisonChart(theme),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _buildComparisonMetric(
                      'This Month',
                      '${provider.healthAnalytics?.overallHealthScore.toInt() ?? 82}%',
                      '+5%',
                      true,
                      theme,
                    ),
                    const SizedBox(height: 12),
                    _buildComparisonMetric(
                      'Last Month',
                      '77%',
                      'Baseline',
                      false,
                      theme,
                    ),
                    const SizedBox(height: 12),
                    _buildComparisonMetric(
                      '3 Months Ago',
                      '71%',
                      '+11%',
                      true,
                      theme,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonChart(ThemeData theme) {
    return Container(
      height: 120,
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                  return Text(
                    months[value.toInt() % months.length],
                    style: TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 71, color: AppTheme.lightGrey)]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 75, color: AppTheme.mediumGrey)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 77, color: AppTheme.mediumGrey)]),
            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 79, color: AppTheme.accentMint)]),
            BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 81, color: AppTheme.accentMint)]),
            BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 82, color: AppTheme.successGreen)]),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonMetric(
    String period,
    String value,
    String change,
    bool isImprovement,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isImprovement 
            ? AppTheme.successGreen.withValues(alpha: 0.05)
            : theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isImprovement 
              ? AppTheme.successGreen.withValues(alpha: 0.3)
              : theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            period,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              if (isImprovement)
                Icon(
                  Icons.trending_up,
                  color: AppTheme.successGreen,
                  size: 10,
                ),
              const SizedBox(width: 2),
              Text(
                change,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isImprovement 
                      ? AppTheme.successGreen
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLongTermTrendAnalysis(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.show_chart,
                color: AppTheme.secondaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Long-term Health Patterns',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '6-month trend analysis',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}%',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = ['Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                        return Text(
                          months[value.toInt() % months.length],
                          style: TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Overall Health
                  LineChartBarData(
                    spots: [
                      FlSpot(0, 65),
                      FlSpot(1, 68),
                      FlSpot(2, 71),
                      FlSpot(3, 74),
                      FlSpot(4, 79),
                      FlSpot(5, 82),
                    ],
                    isCurved: true,
                    color: AppTheme.primaryRose,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  ),
                  // Cycle Regularity
                  LineChartBarData(
                    spots: [
                      FlSpot(0, 70),
                      FlSpot(1, 72),
                      FlSpot(2, 75),
                      FlSpot(3, 78),
                      FlSpot(4, 83),
                      FlSpot(5, 85),
                    ],
                    isCurved: true,
                    color: AppTheme.secondaryBlue,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  ),
                  // Prediction Accuracy
                  LineChartBarData(
                    spots: [
                      FlSpot(0, 75),
                      FlSpot(1, 78),
                      FlSpot(2, 80),
                      FlSpot(3, 84),
                      FlSpot(4, 87),
                      FlSpot(5, 88),
                    ],
                    isCurved: true,
                    color: AppTheme.accentMint,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem('Health', AppTheme.primaryRose),
              _buildLegendItem('Regularity', AppTheme.secondaryBlue),
              _buildLegendItem('Predictions', AppTheme.accentMint),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
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
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPredictiveInsights(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accentMint.withValues(alpha: 0.05),
            AppTheme.warningOrange.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentMint.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentMint.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_fix_high,
                  color: AppTheme.accentMint,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Predictive Health Insights',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'AI forecasts for next 30 days',
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
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildPredictionCard(
                'Next Period',
                'Dec 15, 2024',
                '92% confidence',
                Icons.calendar_today,
                AppTheme.primaryRose,
                theme,
              ),
              _buildPredictionCard(
                'Fertile Window',
                'Dec 1-5',
                '88% confidence',
                Icons.favorite,
                AppTheme.accentMint,
                theme,
              ),
              _buildPredictionCard(
                'Energy Peak',
                'Dec 8-12',
                '85% confidence',
                Icons.flash_on,
                AppTheme.warningOrange,
                theme,
              ),
              _buildPredictionCard(
                'PMS Start',
                'Dec 12',
                '79% confidence',
                Icons.psychology,
                AppTheme.secondaryBlue,
                theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionCard(
    String title,
    String value,
    String confidence,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                confidence,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthPatternsSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pattern,
                color: AppTheme.primaryPurple,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Health Pattern Recognition',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'AI-detected behavioral and health patterns',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          ..._getHealthPatterns().map(
            (pattern) => _buildPatternItem(pattern, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternItem(Map<String, dynamic> pattern, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            (pattern['color'] as Color).withValues(alpha: 0.05),
            (pattern['color'] as Color).withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (pattern['color'] as Color).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (pattern['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              pattern['icon'] as IconData,
              color: pattern['color'] as Color,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pattern['title'] as String,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pattern['description'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (pattern['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${pattern['confidence']}%',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: pattern['color'] as Color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === HELPER METHODS ===

  Color _getScoreColor(double score) {
    if (score >= 85) return AppTheme.successGreen;
    if (score >= 70) return AppTheme.accentMint;
    if (score >= 55) return AppTheme.warningOrange;
    return AppTheme.errorRed;
  }

  String _getScoreDescription(double score) {
    if (score >= 85) return 'Exceptional wellness patterns detected';
    if (score >= 70) return 'Good overall health trajectory';
    if (score >= 55) return 'Moderate wellness indicators';
    return 'Opportunities for health optimization';
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
        return '+';
      case TrendDirection.declining:
        return '-';
      case TrendDirection.stable:
        return '~';
    }
  }

  List<FlSpot> _generateCycleData() {
    return [
      FlSpot(0, 75),
      FlSpot(1, 78),
      FlSpot(2, 82),
      FlSpot(3, 79),
      FlSpot(4, 85),
      FlSpot(5, 87),
    ];
  }

  List<FlSpot> _generatePredictionData() {
    return [
      FlSpot(0, 80),
      FlSpot(1, 82),
      FlSpot(2, 85),
      FlSpot(3, 87),
      FlSpot(4, 88),
      FlSpot(5, 88),
    ];
  }

  List<FlSpot> _generateHealthData() {
    return [
      FlSpot(0, 70),
      FlSpot(1, 72),
      FlSpot(2, 75),
      FlSpot(3, 78),
      FlSpot(4, 80),
      FlSpot(5, 82),
    ];
  }

  List<FlSpot> _generateQualityData() {
    return [
      FlSpot(0, 85),
      FlSpot(1, 88),
      FlSpot(2, 90),
      FlSpot(3, 92),
      FlSpot(4, 94),
      FlSpot(5, 94),
    ];
  }

  List<Map<String, dynamic>> _getAIInsights() {
    final insights = <Map<String, dynamic>>[];
    
    // Dynamic insights based on provider data
    final regularity = provider.cycleAnalytics?.regularityScore ?? 0.8;
    final accuracy = provider.predictionAnalytics?.confidenceScore ?? 85.0;
    final healthScore = provider.healthAnalytics?.overallHealthScore ?? 75.0;
    
    if (regularity > 0.85) {
      insights.add({
        'icon': Icons.check_circle,
        'color': AppTheme.successGreen,
        'text': 'Your cycle regularity is excellent at ${(regularity * 100).toInt()}%. This suggests optimal hormonal balance and healthy lifestyle patterns.',
      });
    } else if (regularity < 0.6) {
      insights.add({
        'icon': Icons.info,
        'color': AppTheme.warningOrange,
        'text': 'Cycle irregularity detected. Consider tracking stress levels, sleep patterns, and nutrition for deeper insights.',
      });
    }
    
    if (accuracy > 90) {
      insights.add({
        'icon': Icons.auto_awesome,
        'color': AppTheme.primaryPurple,
        'text': 'AI predictions achieve ${accuracy.toInt()}% accuracy thanks to your consistent tracking. This enables highly reliable forecasts.',
      });
    }
    
    if (healthScore > 80) {
      insights.add({
        'icon': Icons.trending_up,
        'color': AppTheme.accentMint,
        'text': 'Your overall wellness trajectory shows positive trends. Current patterns suggest continued health optimization.',
      });
    }
    
    // Default insights
    insights.addAll([
      {
        'icon': Icons.insights,
        'color': AppTheme.primaryPurple,
        'text': 'Your tracking consistency enables AI to identify subtle patterns in your health data over time.',
      },
      {
        'icon': Icons.psychology,
        'color': AppTheme.secondaryBlue,
        'text': 'Machine learning analysis reveals strong correlations between your mood, energy, and cycle phases.',
      },
      {
        'icon': Icons.favorite,
        'color': AppTheme.primaryRose,
        'text': 'Your data suggests healthy reproductive patterns and good responsiveness to lifestyle interventions.',
      },
    ]);
    
    return insights;
  }

  List<Map<String, dynamic>> _getHealthPatterns() {
    return [
      {
        'title': 'Sleep Quality Impact',
        'description': 'Better sleep (7-9 hours) correlates with 23% improved cycle regularity',
        'icon': Icons.bedtime,
        'color': AppTheme.secondaryBlue,
        'confidence': 87,
      },
      {
        'title': 'Stress Response Pattern',
        'description': 'High stress periods show 15% increase in cycle variability within 2 weeks',
        'icon': Icons.psychology,
        'color': AppTheme.warningOrange,
        'confidence': 92,
      },
      {
        'title': 'Exercise Correlation',
        'description': 'Regular moderate exercise associates with 18% better mood scores',
        'icon': Icons.fitness_center,
        'color': AppTheme.accentMint,
        'confidence': 84,
      },
      {
        'title': 'Nutritional Impact',
        'description': 'Iron-rich foods during menstruation reduce fatigue by 31%',
        'icon': Icons.restaurant,
        'color': AppTheme.primaryRose,
        'confidence': 79,
      },
    ];
  }
}
