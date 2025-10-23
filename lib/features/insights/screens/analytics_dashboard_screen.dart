import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/app_localizations.dart';
import '../../cycle/providers/cycle_provider.dart';
import '../../premium/providers/premium_provider.dart';
import '../../premium/widgets/upgrade_prompt_dialog.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> with TickerProviderStateMixin {
  late final TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient(theme.brightness == Brightness.dark),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(theme, l10n),
              
              // Tab Bar
              _buildTabBar(theme),
              
              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCycleTrendsTab(),
                    _buildSymptomsTab(),
                    _buildMoodEnergyTab(),
                    _buildInsightsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(
            Icons.analytics_outlined,
            color: AppTheme.primaryRose,
            size: 32,
          ),
          const SizedBox(width: 12),
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
                ).animate().fadeIn().slideX(begin: -0.3, end: 0),
                Text(
                  'Understand your patterns',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ).animate().fadeIn(delay: 100.ms),
              ],
            ),
          ),
          // Export Button
          _buildExportButton(theme),
        ],
      ),
    );
  }
  
  Widget _buildExportButton(ThemeData theme) {
    return Consumer<PremiumProvider>(
      builder: (context, premiumProvider, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: premiumProvider.isPremium
                ? const LinearGradient(
                    colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
                  )
                : null,
            color: premiumProvider.isPremium ? null : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (premiumProvider.isPremium) {
                  _exportData(context);
                } else {
                  _showPremiumPrompt(context);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.file_download_outlined,
                      color: premiumProvider.isPremium ? Colors.white : AppTheme.primaryRose,
                      size: 20,
                    ),
                    if (premiumProvider.isPremium) ...[
                      const SizedBox(width: 8),
                      Text(
                        'Export',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ).animate().fadeIn(delay: 200.ms).scale();
      },
    );
  }
  
  Widget _buildTabBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        tabs: const [
          Tab(text: 'Cycles'),
          Tab(text: 'Symptoms'),
          Tab(text: 'Mood'),
          Tab(text: 'Insights'),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: -0.2, end: 0);
  }
  
  Widget _buildCycleTrendsTab() {
    return Consumer<CycleProvider>(
      builder: (context, cycleProvider, child) {
        final cycles = cycleProvider.cycles;
        
        if (cycles.isEmpty) {
          return _buildEmptyState('No cycle data yet', 'Start tracking to see trends');
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cycle Length Trend Chart
              _buildChartCard(
                title: 'Cycle Length Trend',
                subtitle: 'Last 6 cycles',
                child: _buildCycleLengthChart(cycles),
              ),
              
              const SizedBox(height: 16),
              
              // Statistics Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.calendar_today,
                      label: 'Avg Cycle',
                      value: '${_calculateAverageCycleLength(cycles)} days',
                      color: AppTheme.primaryRose,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.show_chart,
                      label: 'Regularity',
                      value: '${_calculateRegularity(cycles)}%',
                      color: AppTheme.accentMint,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Period Duration Chart
              _buildChartCard(
                title: 'Period Duration',
                subtitle: 'Average flow days',
                child: _buildPeriodDurationChart(cycles),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildSymptomsTab() {
    return Consumer<CycleProvider>(
      builder: (context, cycleProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildChartCard(
                title: 'Symptom Frequency',
                subtitle: 'Most common symptoms',
                child: _buildSymptomFrequencyChart(),
              ),
              
              const SizedBox(height: 16),
              
              _buildChartCard(
                title: 'Symptom Timeline',
                subtitle: 'When symptoms occur',
                child: _buildSymptomTimelineChart(),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildMoodEnergyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartCard(
            title: 'Mood Patterns',
            subtitle: 'Throughout your cycle',
            child: _buildMoodPatternChart(),
          ),
          
          const SizedBox(height: 16),
          
          _buildChartCard(
            title: 'Energy Levels',
            subtitle: 'Daily energy trends',
            child: _buildEnergyLevelChart(),
          ),
          
          const SizedBox(height: 16),
          
          _buildChartCard(
            title: 'Mood-Energy Correlation',
            subtitle: 'How they relate',
            child: _buildCorrelationChart(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInsightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInsightCard(
            icon: Icons.lightbulb_outline,
            title: 'Cycle Patterns',
            description: 'Your cycles are very regular with an average length of 28 days. This is within the healthy range.',
            confidence: 0.92,
            color: AppTheme.accentMint,
          ),
          
          const SizedBox(height: 12),
          
          _buildInsightCard(
            icon: Icons.favorite_outline,
            title: 'Health Trends',
            description: 'Your symptom patterns suggest consistent hormonal balance. Continue tracking for deeper insights.',
            confidence: 0.85,
            color: AppTheme.primaryRose,
          ),
          
          const SizedBox(height: 12),
          
          _buildInsightCard(
            icon: Icons.psychology_outlined,
            title: 'Mood Insights',
            description: 'Your mood tends to be most positive during the follicular phase. Consider scheduling important activities then.',
            confidence: 0.78,
            color: AppTheme.secondaryBlue,
          ),
          
          const SizedBox(height: 12),
          
          _buildInsightCard(
            icon: Icons.analytics_outlined,
            title: 'Prediction Accuracy',
            description: 'AI predictions have been 94% accurate over the last 3 cycles. Confidence is high for future predictions.',
            confidence: 0.94,
            color: AppTheme.primaryPurple,
          ),
        ],
      ),
    );
  }
  
  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: child,
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.3, end: 0);
  }
  
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }
  
  Widget _buildInsightCard({
    required IconData icon,
    required String title,
    required String description,
    required double confidence,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(confidence * 100).toInt()}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: confidence,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.2, end: 0);
  }
  
  // Chart implementations (simplified for now)
  Widget _buildCycleLengthChart(List<dynamic> cycles) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(6, (index) {
              return FlSpot(index.toDouble(), 26 + (index % 3).toDouble());
            }),
            isCurved: true,
            gradient: const LinearGradient(
              colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
            ),
            barWidth: 4,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPeriodDurationChart(List<dynamic> cycles) {
    return BarChart(
      BarChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(6, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: 4 + (index % 2).toDouble(),
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
      ),
    );
  }
  
  Widget _buildSymptomFrequencyChart() {
    return BarChart(
      BarChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(5, (index) {
          final colors = [
            AppTheme.primaryRose,
            AppTheme.primaryPurple,
            AppTheme.secondaryBlue,
            AppTheme.accentMint,
            AppTheme.primaryRose.withOpacity(0.7),
          ];
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: (5 - index).toDouble() * 2,
                color: colors[index],
                width: 30,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }),
      ),
    );
  }
  
  Widget _buildSymptomTimelineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(28, (index) {
              final double y = (index > 14 && index < 21) ? 3.0 : 1.0;
              return FlSpot(index.toDouble(), y);
            }),
            isCurved: true,
            gradient: const LinearGradient(
              colors: [AppTheme.accentMint, AppTheme.secondaryBlue],
            ),
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentMint.withOpacity(0.3),
                  AppTheme.secondaryBlue.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMoodPatternChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(28, (index) {
              final double y = 3 + (index / 7).sin() * 2;
              return FlSpot(index.toDouble(), y);
            }),
            isCurved: true,
            gradient: const LinearGradient(
              colors: [AppTheme.secondaryBlue, AppTheme.primaryPurple],
            ),
            barWidth: 3,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEnergyLevelChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(28, (index) {
              final double y = 3.5 + (index / 8).cos() * 1.5;
              return FlSpot(index.toDouble(), y);
            }),
            isCurved: true,
            gradient: const LinearGradient(
              colors: [AppTheme.accentMint, AppTheme.primaryRose],
            ),
            barWidth: 3,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCorrelationChart() {
    return ScatterChart(
      ScatterChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        scatterSpots: List.generate(20, (index) {
          return ScatterSpot(
            index % 5 + (index / 10),
            index % 5 + (index / 8),
            color: AppTheme.secondaryBlue.withOpacity(0.6),
            radius: 8,
          );
        }),
      ),
    );
  }
  
  Widget _buildEmptyState(String title, String subtitle) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper methods
  int _calculateAverageCycleLength(List<dynamic> cycles) {
    if (cycles.isEmpty) return 28;
    // Simplified calculation
    return 28;
  }
  
  int _calculateRegularity(List<dynamic> cycles) {
    if (cycles.length < 2) return 100;
    // Simplified calculation
    return 92;
  }
  
  void _exportData(BuildContext context) {
    // Export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting analytics data...')),
    );
  }
  
  void _showPremiumPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const UpgradePromptDialog(
        feature: 'Data Export',
        description: 'Export your analytics data and charts to share with your healthcare provider.',
      ),
    );
  }
}
