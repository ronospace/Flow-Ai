import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/analytics_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../analytics/providers/analytics_provider.dart';
import '../../analytics/widgets/health_analytics_card.dart';
import '../../analytics/widgets/prediction_analytics_card.dart';
import '../../analytics/widgets/recommendations_list.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _initialLoadRequested = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _initialLoadRequested) return;
      _initialLoadRequested = true;
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

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient(
            theme.brightness == Brightness.dark,
          ),
        ),
        child: SafeArea(
          child: Consumer<AnalyticsProvider>(
            builder: (context, analytics, _) {
              return Column(
                children: [
                  _buildHeader(context, analytics),
                  _buildTabBar(theme),
                  Expanded(
                    child: analytics.isLoading && !analytics.hasData
                        ? const Center(child: CircularProgressIndicator())
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildCyclesTab(context, analytics),
                              _buildHealthTab(context, analytics),
                              _buildPredictionsTab(context, analytics),
                              _buildInsightsTab(context, analytics),
                            ],
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AnalyticsProvider analytics) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spaceXl),
      child: Row(
        children: [
          Icon(Icons.analytics_outlined, color: AppTheme.primaryRose, size: 32),
          const SizedBox(width: AppTheme.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytics',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Patterns calculated from your recorded data',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Refresh analytics',
            onPressed: analytics.isLoading ? null : () => analytics.refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXl),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [
          Tab(text: 'Cycles'),
          Tab(text: 'Health'),
          Tab(text: 'Predictions'),
          Tab(text: 'Insights'),
        ],
      ),
    );
  }

  Widget _buildCyclesTab(BuildContext context, AnalyticsProvider analytics) {
    final cycle = analytics.cycleAnalytics;

    if (cycle == null || cycle.totalCycles == 0) {
      return _emptyState(
        context,
        icon: Icons.calendar_month_outlined,
        title: 'No recorded cycle history yet',
        message:
            'Keep tracking your cycles. Analytics will appear when recorded history is available.',
      );
    }

    return RefreshIndicator(
      onRefresh: analytics.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppTheme.spaceXl),
        children: [
          _sectionTitle(context, 'Recorded cycle analytics'),
          const SizedBox(height: AppTheme.spaceMd),
          _metricGrid(context, cycle),
          if (cycle.symptomFrequency.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spaceXl),
            _symptomFrequency(context, cycle.symptomFrequency),
          ],
        ],
      ),
    );
  }

  Widget _metricGrid(BuildContext context, CycleAnalytics analytics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _metricCard(
                context,
                label: 'Recorded cycles',
                value: '${analytics.totalCycles}',
                icon: Icons.history,
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: _metricCard(
                context,
                label: 'Average cycle',
                value: '${analytics.averageCycleLength.toStringAsFixed(1)} d',
                icon: Icons.calendar_today_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceMd),
        Row(
          children: [
            Expanded(
              child: _metricCard(
                context,
                label: 'Average period',
                value: '${analytics.averagePeriodLength.toStringAsFixed(1)} d',
                icon: Icons.water_drop_outlined,
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: _metricCard(
                context,
                label: 'Cycle variation',
                value: '±${analytics.cycleVariation.toStringAsFixed(1)} d',
                icon: Icons.show_chart,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceMd),
        _metricCard(
          context,
          label: 'Regularity from recorded intervals',
          value: '${(analytics.regularityScore * 100).round()}%',
          icon: Icons.timeline,
        ),
      ],
    );
  }

  Widget _symptomFrequency(BuildContext context, Map<String, double> symptoms) {
    final theme = Theme.of(context);
    final entries = symptoms.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceXl),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recorded symptom frequency',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spaceMd),
          for (final entry in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spaceSm),
              child: Row(
                children: [
                  Expanded(
                    child: Text(entry.key, style: theme.textTheme.bodyMedium),
                  ),
                  Text(
                    '${(entry.value * 100).round()}%',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHealthTab(BuildContext context, AnalyticsProvider analytics) {
    final health = analytics.healthAnalytics;

    if (health == null || analytics.analyticsHistory.isEmpty) {
      return _emptyState(
        context,
        icon: Icons.monitor_heart_outlined,
        title: 'Insufficient recorded health history',
        message:
            'Mood, energy and sleep analytics appear only when recorded history is available.',
      );
    }

    return RefreshIndicator(
      onRefresh: analytics.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppTheme.spaceXl),
        children: [
          HealthAnalyticsCard(
            analytics: health,
            history: analytics.analyticsHistory,
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionsTab(
    BuildContext context,
    AnalyticsProvider analytics,
  ) {
    final predictions = analytics.predictionAnalytics;

    if (predictions == null) {
      return _emptyState(
        context,
        icon: Icons.fact_check_outlined,
        title: 'Prediction validation unavailable',
        message:
            'Flow Ai only reports prediction performance from stored prediction-versus-actual history.',
      );
    }

    return RefreshIndicator(
      onRefresh: analytics.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppTheme.spaceXl),
        children: [PredictionAnalyticsCard(analytics: predictions)],
      ),
    );
  }

  Widget _buildInsightsTab(BuildContext context, AnalyticsProvider analytics) {
    return RefreshIndicator(
      onRefresh: analytics.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppTheme.spaceXl),
        children: [
          _sectionTitle(context, 'Personalized insights'),
          const SizedBox(height: AppTheme.spaceMd),
          RecommendationsList(recommendations: analytics.recommendations),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _metricCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
  }) {
    final theme = Theme.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppTheme.spaceXl),
      children: [
        const SizedBox(height: 72),
        Icon(icon, size: 52, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(height: AppTheme.spaceMd),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spaceSm),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
