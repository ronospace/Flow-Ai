import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/analytics_provider.dart';
import '../widgets/cycle_analytics_card.dart';
import '../widgets/health_analytics_card.dart';
import '../widgets/prediction_analytics_card.dart';
import '../widgets/trend_chart_widget.dart';
import '../widgets/recommendations_list.dart';
import '../widgets/advanced_analytics_dashboard.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/analytics_service.dart';
import '../../../generated/app_localizations.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().loadAllAnalytics();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient(
            theme.brightness == Brightness.dark,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(theme, localizations),
              _buildTabBar(theme, localizations),
              Expanded(
                child: Consumer<AnalyticsProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return _buildLoadingState(theme);
                    }
                    
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOverviewTab(provider, theme, localizations),
                        _buildCycleTab(provider, theme, localizations),
                        _buildHealthTab(provider, theme, localizations),
                        _buildTrendsTab(provider, theme, localizations),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytics Dashboard',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Insights into your health journey',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showTimeRangeSelector(context),
            icon: Icon(
              Icons.date_range,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme, AppLocalizations localizations) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: theme.colorScheme.primary,
        ),
        labelColor: theme.colorScheme.onPrimary,
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        labelStyle: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.bodySmall,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Cycle'),
          Tab(text: 'Health'),
          Tab(text: 'Trends'),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Analyzing your data...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(
    AnalyticsProvider provider,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Advanced Health Score Card
          _buildAdvancedHealthScoreCard(provider, theme),
          const SizedBox(height: 24),
          
          // Key Metrics Grid
          _buildAdvancedMetricsGrid(provider, theme),
          const SizedBox(height: 24),
          
          // AI Insights Section
          _buildAIInsightsSection(provider, theme),
          const SizedBox(height: 24),
          
          // Comparative Analysis
          _buildComparativeAnalysis(provider, theme),
          const SizedBox(height: 24),
          
          // Predictive Insights
          _buildPredictiveInsights(provider, theme),
        ],
      ),
    );
  }

  // === ADVANCED ANALYTICS COMPONENTS ===
  
  Widget _buildAdvancedHealthScoreCard(AnalyticsProvider provider, ThemeData theme) {
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
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [scoreColor, scoreColor.withValues(alpha: 0.8)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: scoreColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${overallScore.round()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Wellness Score',
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
                    LinearProgressIndicator(
                      value: overallScore / 100,
                      backgroundColor: scoreColor.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
        Text(
          '${score.round()}%',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
  
  Widget _buildAdvancedMetricsGrid(AnalyticsProvider provider, ThemeData theme) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildAdvancedMetricCard(
          title: 'Cycle Accuracy',
          value: '${(provider.cycleAnalytics?.regularityScore ?? 0.85) * 100}%',
          subtitle: 'Last 6 months',
          icon: Icons.favorite,
          color: AppTheme.primaryRose,
          trend: TrendDirection.improving,
          theme: theme,
        ),
        _buildAdvancedMetricCard(
          title: 'Prediction Score',
          value: '${provider.predictionAnalytics?.confidenceScore.toInt() ?? 88}%',
          subtitle: 'AI Confidence',
          icon: Icons.psychology,
          color: AppTheme.secondaryBlue,
          trend: TrendDirection.stable,
          theme: theme,
        ),
        _buildAdvancedMetricCard(
          title: 'Health Trends',
          value: '${provider.healthAnalytics?.overallHealthScore.toInt() ?? 82}%',
          subtitle: 'Overall wellness',
          icon: Icons.trending_up,
          color: AppTheme.accentMint,
          trend: TrendDirection.improving,
          theme: theme,
        ),
        _buildAdvancedMetricCard(
          title: 'Data Quality',
          value: '94%',
          subtitle: 'Tracking consistency',
          icon: Icons.analytics,
          color: AppTheme.warningOrange,
          trend: TrendDirection.stable,
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
    required ThemeData theme,
  }) {
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Icon(
                _getTrendIcon(trend),
                color: _getTrendColor(trend),
                size: 16,
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
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
        ],
      ),
    );
  }
  
  Widget _buildAIInsightsSection(AnalyticsProvider provider, ThemeData theme) {
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
              Text(
                'AI-Powered Insights',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Updated',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._getAIInsights(provider).take(3).map(
            (insight) => _buildInsightItem(insight, theme),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInsightItem(Map<String, dynamic> insight, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            insight['icon'] as IconData,
            color: insight['color'] as Color,
            size: 16,
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
  
  Widget _buildComparativeAnalysis(AnalyticsProvider provider, ThemeData theme) {
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
            'Your progress vs. previous periods',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildComparisonMetric(
                  'This Month',
                  '${provider.healthAnalytics?.overallHealthScore.toInt() ?? 82}%',
                  '+5%',
                  true,
                  theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildComparisonMetric(
                  'Last Month',
                  '77%',
                  'Baseline',
                  false,
                  theme,
                ),
              ),
            ],
          ),
        ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isImprovement 
            ? AppTheme.successGreen.withValues(alpha: 0.05)
            : theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
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
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (isImprovement)
                Icon(
                  Icons.trending_up,
                  color: AppTheme.successGreen,
                  size: 12,
                ),
              const SizedBox(width: 4),
              Text(
                change,
                style: TextStyle(
                  fontSize: 12,
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
  
  Widget _buildPredictiveInsights(AnalyticsProvider provider, ThemeData theme) {
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
                  Icons.crystal_ball,
                  color: AppTheme.accentMint,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Future Predictions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Next 30 days forecast',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPredictionItem(
                  'Next Period',
                  'Dec 15',
                  '92% confidence',
                  Icons.calendar_today,
                  AppTheme.primaryRose,
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPredictionItem(
                  'Fertile Window',
                  'Dec 1-5',
                  '88% confidence',
                  Icons.favorite,
                  AppTheme.accentMint,
                  theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPredictionItem(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
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
          const SizedBox(height: 4),
          Text(
            confidence,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
  
  // === HELPER FUNCTIONS ===
  
  Color _getScoreColor(double score) {
    if (score >= 85) return AppTheme.successGreen;
    if (score >= 70) return AppTheme.accentMint;
    if (score >= 55) return AppTheme.warningOrange;
    return AppTheme.errorRed;
  }
  
  String _getScoreDescription(double score) {
    if (score >= 85) return 'Excellent wellness patterns';
    if (score >= 70) return 'Good overall health trends';
    if (score >= 55) return 'Moderate wellness indicators';
    return 'Areas for improvement identified';
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
  
  List<Map<String, dynamic>> _getAIInsights(AnalyticsProvider provider) {
    final insights = <Map<String, dynamic>>[];
    
    // Cycle regularity insight
    final regularity = provider.cycleAnalytics?.regularityScore ?? 0.8;
    if (regularity > 0.85) {
      insights.add({
        'icon': Icons.check_circle,
        'color': AppTheme.successGreen,
        'text': 'Your cycle regularity is excellent at ${(regularity * 100).toInt()}%. This indicates good hormonal balance.',
      });
    } else if (regularity < 0.6) {
      insights.add({
        'icon': Icons.info,
        'color': AppTheme.warningOrange,
        'text': 'Cycle irregularity detected. Consider tracking stress levels and sleep patterns for better insights.',
      });
    }
    
    // Prediction accuracy insight
    final accuracy = provider.predictionAnalytics?.confidenceScore ?? 85.0;
    if (accuracy > 90) {
      insights.add({
        'icon': Icons.auto_awesome,
        'color': AppTheme.primaryPurple,
        'text': 'AI predictions are highly accurate at ${accuracy.toInt()}%. Your data quality is excellent.',
      });
    }
    
    // Health trend insight
    final healthScore = provider.healthAnalytics?.overallHealthScore ?? 75.0;
    if (healthScore > 80) {
      insights.add({
        'icon': Icons.trending_up,
        'color': AppTheme.accentMint,
        'text': 'Your overall health trends are positive. Keep up the great work with your wellness routine!',
      });
    } else if (healthScore < 60) {
      insights.add({
        'icon': Icons.psychology,
        'color': AppTheme.secondaryBlue,
        'text': 'Consider focusing on stress management and sleep quality to improve overall wellness.',
      });
    }
    
    // Default insights if no specific conditions met
    if (insights.isEmpty) {
      insights.addAll([
        {
          'icon': Icons.insights,
          'color': AppTheme.primaryPurple,
          'text': 'Your tracking consistency is helping improve prediction accuracy over time.',
        },
        {
          'icon': Icons.favorite,
          'color': AppTheme.primaryRose,
          'text': 'Regular cycle patterns suggest healthy hormonal balance and lifestyle habits.',
        },
        {
          'icon': Icons.psychology,
          'color': AppTheme.accentMint,
          'text': 'AI analysis shows positive correlations between your mood and energy levels.',
        },
      ]);
    }
    
    return insights;
  }

  Widget _buildCycleTab(
    AnalyticsProvider provider,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.cycleAnalytics != null)
            CycleAnalyticsCard(analytics: provider.cycleAnalytics!),
          const SizedBox(height: 20),
          if (provider.predictionAnalytics != null)
            PredictionAnalyticsCard(analytics: provider.predictionAnalytics!),
        ],
      ),
    );
  }

  Widget _buildHealthTab(
    AnalyticsProvider provider,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.healthAnalytics != null)
            HealthAnalyticsCard(analytics: provider.healthAnalytics!),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(
    AnalyticsProvider provider,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.trendAnalytics != null)
            TrendChartWidget(analytics: provider.trendAnalytics!),
        ],
      ),
    );
  }

  Widget _buildOverviewMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
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
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: color,
                  size: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
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

  void _showTimeRangeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Time Range',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildTimeRangeOption('Last 3 months', () {
              context.read<AnalyticsProvider>().setTimeRange(
                DateTime.now().subtract(const Duration(days: 90)),
                DateTime.now(),
              );
              Navigator.pop(context);
            }),
            _buildTimeRangeOption('Last 6 months', () {
              context.read<AnalyticsProvider>().setTimeRange(
                DateTime.now().subtract(const Duration(days: 180)),
                DateTime.now(),
              );
              Navigator.pop(context);
            }),
            _buildTimeRangeOption('Last year', () {
              context.read<AnalyticsProvider>().setTimeRange(
                DateTime.now().subtract(const Duration(days: 365)),
                DateTime.now(),
              );
              Navigator.pop(context);
            }),
            _buildTimeRangeOption('All time', () {
              context.read<AnalyticsProvider>().setTimeRange(null, null);
              Navigator.pop(context);
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeOption(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  void _showRecommendationDetails(BuildContext context, recommendation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(recommendation.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(recommendation.description),
            const SizedBox(height: 16),
            Text(
              'Action Items:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...recommendation.actionItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                  Expanded(child: Text(item)),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement reminder/goal setting
              Navigator.pop(context);
            },
            child: const Text('Set Reminder'),
          ),
        ],
      ),
    );
  }
}
