import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/analytics_provider.dart';
import '../widgets/cycle_analytics_card.dart';
import '../widgets/health_analytics_card.dart';
import '../widgets/prediction_analytics_card.dart';
import '../widgets/trend_chart_widget.dart';
import '../widgets/recommendations_list.dart';
import '../../../core/theme/app_theme.dart';
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
          // Key Metrics Cards
          Row(
            children: [
              Expanded(
                child: _buildOverviewMetricCard(
                  title: 'Cycle Regularity',
                  value: '${(provider.cycleAnalytics?.regularityScore ?? 0 * 100).toInt()}%',
                  icon: Icons.favorite,
                  color: theme.colorScheme.primary,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverviewMetricCard(
                  title: 'Health Score',
                  value: '${provider.healthAnalytics?.overallHealthScore.toInt() ?? 0}%',
                  icon: Icons.local_hospital,
                  color: Colors.green,
                  theme: theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildOverviewMetricCard(
                  title: 'Prediction Accuracy',
                  value: '${provider.predictionAnalytics?.confidenceScore.toInt() ?? 0}%',
                  icon: Icons.analytics,
                  color: Colors.orange,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverviewMetricCard(
                  title: 'Total Cycles',
                  value: '${provider.cycleAnalytics?.totalCycles ?? 0}',
                  icon: Icons.calendar_month,
                  color: Colors.purple,
                  theme: theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recommendations Section
          Text(
            'Personalized Recommendations',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          RecommendationsList(
            recommendations: provider.recommendations,
            onRecommendationTap: (recommendation) {
              _showRecommendationDetails(context, recommendation);
            },
          ),
        ],
      ),
    );
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
