import 'package:flutter/material.dart';

import '../providers/analytics_provider.dart';

class AdvancedAnalyticsDashboard extends StatelessWidget {
  final AnalyticsProvider provider;

  const AdvancedAnalyticsDashboard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final history = provider.analyticsHistory;
    final cycleAnalytics = provider.cycleAnalytics;
    final predictionAnalytics = provider.predictionAnalytics;

    final completedCycles = cycleAnalytics?.totalCycles ?? 0;
    final verifiedPredictionComparisons =
        predictionAnalytics?.totalPredictions ?? 0;

    final hasRecordedData = !history.isEmpty || completedCycles > 0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Analytics',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Only analytics derived from recorded Flow Ai data are '
            'shown here. Missing data remains missing.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          if (!hasRecordedData)
            _buildInfoCard(
              context,
              icon: Icons.analytics_outlined,
              title: 'Not enough recorded data yet',
              description:
                  'Continue tracking your cycles and daily wellness data '
                  'to build a real analytics history.',
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final tileWidth = constraints.maxWidth >= 700
                    ? (constraints.maxWidth - 12) / 2
                    : constraints.maxWidth;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: tileWidth,
                      child: _buildMetricCard(
                        context,
                        title: 'Mood entries',
                        value: '${history.mood.length}',
                        icon: Icons.mood_outlined,
                      ),
                    ),
                    SizedBox(
                      width: tileWidth,
                      child: _buildMetricCard(
                        context,
                        title: 'Energy entries',
                        value: '${history.energy.length}',
                        icon: Icons.bolt_outlined,
                      ),
                    ),
                    SizedBox(
                      width: tileWidth,
                      child: _buildMetricCard(
                        context,
                        title: 'Sleep entries',
                        value: '${history.sleepHours.length}',
                        icon: Icons.bedtime_outlined,
                      ),
                    ),
                    SizedBox(
                      width: tileWidth,
                      child: _buildMetricCard(
                        context,
                        title: 'Completed cycles',
                        value: '$completedCycles',
                        icon: Icons.calendar_month_outlined,
                      ),
                    ),
                  ],
                );
              },
            ),
          if (completedCycles > 0 && cycleAnalytics != null) ...[
            const SizedBox(height: 20),
            _buildInfoCard(
              context,
              icon: Icons.timeline,
              title: 'Recorded cycle history',
              description:
                  '${cycleAnalytics.totalCycles} completed '
                  '${cycleAnalytics.totalCycles == 1 ? 'cycle' : 'cycles'}; '
                  'average cycle length '
                  '${cycleAnalytics.averageCycleLength.toStringAsFixed(1)} '
                  'days and average period length '
                  '${cycleAnalytics.averagePeriodLength.toStringAsFixed(1)} '
                  'days.',
            ),
          ],
          const SizedBox(height: 20),
          if (verifiedPredictionComparisons > 0 && predictionAnalytics != null)
            _buildInfoCard(
              context,
              icon: Icons.fact_check_outlined,
              title: 'Verified prediction history',
              description:
                  '$verifiedPredictionComparisons stored prediction '
                  '${verifiedPredictionComparisons == 1 ? 'comparison' : 'comparisons'} '
                  'are available.',
            )
          else
            _buildInfoCard(
              context,
              icon: Icons.info_outline,
              title: 'Prediction validation unavailable',
              description:
                  'Flow Ai does not estimate prediction accuracy without '
                  'stored historical prediction-versus-actual records.',
            ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
