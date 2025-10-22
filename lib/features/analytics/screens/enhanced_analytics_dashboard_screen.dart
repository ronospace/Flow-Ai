import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

class EnhancedAnalyticsDashboardScreen extends StatefulWidget {
  const EnhancedAnalyticsDashboardScreen({super.key});

  @override
  State<EnhancedAnalyticsDashboardScreen> createState() => _EnhancedAnalyticsDashboardScreenState();
}

class _EnhancedAnalyticsDashboardScreenState extends State<EnhancedAnalyticsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
                        AdvancedAnalyticsDashboard(provider: provider),
                        _buildCycleTab(provider, theme, localizations),
                        _buildHealthTab(provider, theme, localizations),
                        _buildTrendsTab(provider, theme, localizations),
                        _buildRecommendationsTab(provider, theme, localizations),
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
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                Icons.arrow_back,
                color: theme.colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Advanced Analytics',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'AI-powered health insights dashboard',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showTimeRangeSelector(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                Icons.date_range,
                color: AppTheme.primaryPurple,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _showExportOptions(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentMint.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.accentMint.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                Icons.download,
                color: AppTheme.accentMint,
                size: 20,
              ),
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
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryPurple,
              AppTheme.secondaryBlue,
            ],
          ),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        labelStyle: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.bodySmall,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Cycles'),
          Tab(text: 'Health'),
          Tab(text: 'Trends'),
          Tab(text: 'Insights'),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryPurple,
                    AppTheme.secondaryBlue,
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Analyzing Your Health Data',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI is processing your patterns and trends...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
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
          Text(
            'Cycle Analysis',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Detailed cycle patterns and predictions',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
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
          Text(
            'Health Metrics',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comprehensive wellness tracking',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
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
          Text(
            'Trend Analysis',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Long-term patterns and trajectories',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          if (provider.trendAnalytics != null)
            TrendChartWidget(analytics: provider.trendAnalytics!),
        ],
      ),
    );
  }

  Widget _buildRecommendationsTab(
    AnalyticsProvider provider,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personalized Recommendations',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI-powered health optimization suggestions',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
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
            Row(
              children: [
                Icon(
                  Icons.date_range,
                  color: AppTheme.primaryPurple,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Select Time Range',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...[
              ('Last 3 months', () => _setTimeRange(90)),
              ('Last 6 months', () => _setTimeRange(180)),
              ('Last year', () => _setTimeRange(365)),
              ('All time', () => _setTimeRange(null)),
            ].map((option) => _buildTimeRangeOption(option.$1, option.$2)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeOption(String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        leading: Icon(
          Icons.access_time,
          color: AppTheme.primaryPurple,
          size: 20,
        ),
        onTap: () {
          onTap();
          Navigator.pop(context);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
      ),
    );
  }

  void _setTimeRange(int? days) {
    final provider = context.read<AnalyticsProvider>();
    if (days != null) {
      provider.setTimeRange(
        DateTime.now().subtract(Duration(days: days)),
        DateTime.now(),
      );
    } else {
      provider.setTimeRange(null, null);
    }
  }

  void _showExportOptions(BuildContext context) {
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
            Row(
              children: [
                Icon(
                  Icons.download,
                  color: AppTheme.accentMint,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Export Analytics',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...[
              ('PDF Report', Icons.picture_as_pdf, () => _exportData('pdf')),
              ('Excel Spreadsheet', Icons.table_chart, () => _exportData('excel')),
              ('Share Summary', Icons.share, () => _shareData()),
            ].map((option) => ListTile(
              title: Text(option.$1),
              leading: Icon(option.$2, color: AppTheme.accentMint),
              onTap: () {
                Navigator.pop(context);
                option.$3();
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _exportData(String format) {
    // TODO: Implement data export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting analytics as $format...'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.accentMint,
      ),
    );
  }

  void _shareData() {
    // TODO: Implement data sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preparing analytics summary for sharing...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showRecommendationDetails(BuildContext context, recommendation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.lightbulb,
                color: AppTheme.primaryPurple,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(recommendation.title)),
          ],
        ),
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
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple,
                      shape: BoxShape.circle,
                    ),
                  ),
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
              Navigator.pop(context);
              _setReminder(recommendation);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Set Reminder'),
          ),
        ],
      ),
    );
  }

  void _setReminder(recommendation) {
    // TODO: Implement reminder functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminder set for: ${recommendation.title}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }
}
