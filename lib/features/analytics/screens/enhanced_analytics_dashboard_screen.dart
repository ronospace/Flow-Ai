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
import '../../../core/widgets/app_header_components.dart';
import '../../../generated/app_localizations.dart';

class EnhancedAnalyticsDashboardScreen extends StatefulWidget {
  const EnhancedAnalyticsDashboardScreen({super.key});

  @override
  State<EnhancedAnalyticsDashboardScreen> createState() =>
      _EnhancedAnalyticsDashboardScreenState();
}

class _EnhancedAnalyticsDashboardScreenState
    extends State<EnhancedAnalyticsDashboardScreen>
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
                        _buildRecommendationsTab(
                          provider,
                          theme,
                          localizations,
                        ),
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          AppBackButton(onPressed: () => Navigator.of(context).pop()),
          const SizedBox(width: 12),
          Expanded(
            child: AppHeaderTextBlock(
              title: 'Advanced Analytics',
              subtitle: 'AI-powered health insights',
              titleStyle: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              subtitleStyle: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          _buildHeaderActionButton(
            label: 'Select analytics time range',
            color: AppTheme.primaryPurple,
            icon: Icons.date_range,
            onTap: () => _showTimeRangeSelector(context),
          ),
          const SizedBox(width: 4),
          _buildHeaderActionButton(
            label: 'Export analytics',
            color: AppTheme.accentMint,
            icon: Icons.download,
            onTap: () => _showExportOptions(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderActionButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Semantics(
      label: label,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Center(child: Icon(icon, color: color, size: 24)),
          ),
        ),
      ),
    );
  }

  void _moveAnalyticsTab(int delta) {
    final nextIndex = (_tabController.index + delta).clamp(
      0,
      _tabController.length - 1,
    );

    if (nextIndex == _tabController.index) return;
    _tabController.animateTo(nextIndex);
  }

  Widget _buildTabBar(ThemeData theme, AppLocalizations localizations) {
    const labels = ['Overview', 'Cycles', 'Health', 'Trends', 'Insights'];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity.abs() < 120) return;

        _moveAnalyticsTab(velocity < 0 ? 1 : -1);
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.16),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: TabBar(
          controller: _tabController,
          isScrollable: false,
          tabAlignment: TabAlignment.fill,
          labelPadding: EdgeInsets.zero,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(2),
          dividerColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
            ),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: theme.colorScheme.onSurface.withValues(
            alpha: 0.68,
          ),
          labelStyle: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.02,
          ),
          unselectedLabelStyle: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.02,
          ),
          tabs: labels
              .map(
                (label) => Tab(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 6,
                    ),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          maxLines: 1,
                          softWrap: false,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
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
                  colors: [AppTheme.primaryPurple, AppTheme.secondaryBlue],
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

          const SizedBox(height: 20),
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

          const SizedBox(height: 20),
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

          const SizedBox(height: 20),
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
                Icon(Icons.date_range, color: AppTheme.primaryPurple, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Select Time Range',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                Icon(Icons.download, color: AppTheme.accentMint, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Export Analytics',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...[
              (
                'PDF Report',
                Icons.picture_as_pdf,
                () => _exportData(context, 'pdf'),
              ),
              (
                'Excel Spreadsheet',
                Icons.table_chart,
                () => _exportData(context, 'excel'),
              ),
              ('Share Summary', Icons.share, () => _shareData(context)),
            ].map(
              (option) => ListTile(
                title: Text(option.$1),
                leading: Icon(option.$2, color: AppTheme.accentMint),
                onTap: () {
                  Navigator.pop(context);
                  option.$3();
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _exportData(BuildContext context, String format) {
    // TODO: Implement data export functionality
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text('Exporting analytics as $format...'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.accentMint,
      ),
    );
  }

  void _shareData(BuildContext context) {
    // TODO: Implement data sharing functionality
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...recommendation.actionItems.map(
              (item) => Padding(
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
              ),
            ),
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
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text('Reminder set for: ${recommendation.title}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }
}
