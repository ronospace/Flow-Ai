import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../generated/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/time_period.dart';
import '../../../core/models/cycle_data.dart';
import '../providers/insights_provider.dart';
import '../../cycle/providers/cycle_provider.dart';
import '../widgets/cycle_length_chart.dart';
import '../widgets/ai_insight_card.dart';
import '../widgets/cycle_regularity_indicator.dart';
import '../widgets/mood_energy_chart.dart';
import '../widgets/symptom_heatmap.dart';
import '../widgets/floating_ai_chat.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with TickerProviderStateMixin {
  final GlobalKey tabsKey = GlobalKey();
  final GlobalKey periodSelectorKey = GlobalKey();
  late TabController _tabController;
  late AnimationController _aiPulseController;
  bool _isZyraExpanded = false;
  int _selectedPeriod = 3; // 3 months default

  final List<Map<String, dynamic>> _timePeriods = [
    {'label': '1M', 'months': 1},
    {'label': '3M', 'months': 3},
    {'label': '6M', 'months': 6},
    {'label': '1Y', 'months': 12},
  ];

  @override
  void initState() {
    super.initState();
    _aiPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InsightsProvider>().loadInsights();
      context.read<CycleProvider>().loadCycles();
    });
  }

  @override
  void dispose() {
    _aiPulseController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // Ensure proper cleanup when navigating away
        if (didPop && mounted) {
          // This helps prevent widget tree persistence issues
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.backgroundGradient(
                  theme.brightness == Brightness.dark,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Custom Header
                    _buildHeader(),

                    // Time Period Selector
                    _buildTimePeriodSelector(),

                    // Tab Bar
                    _buildTabBar(),

                    // Tab Content
                    Expanded(
                      child: _isZyraExpanded
                          ? DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: AppTheme.backgroundGradient(
                                  theme.brightness == Brightness.dark,
                                ),
                              ),
                            )
                          : TabBarView(
                              controller: _tabController,
                              children: [
                                _buildOverviewTab(),
                                _buildTrendsTab(),
                                _buildPatternsTab(),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),

            // Floating AI Chat - only render if mounted
            if (mounted)
              FloatingAIChat(
                tabsKey: tabsKey,
                periodSelectorKey: periodSelectorKey,
                onExpandedChanged: (expanded) {
                  if (_isZyraExpanded == expanded) return;
                  setState(() {
                    _isZyraExpanded = expanded;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Insights',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ).animate().fadeIn().slideX(begin: -0.3, end: 0),
                Text(
                  AppLocalizations.of(context).learnYourPatterns,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ).animate().fadeIn(delay: 100.ms),
              ],
            ),
          ),

          // Settings icon removed - not necessary per user request
          const SizedBox(width: 8),

          // AI Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.secondaryBlue, AppTheme.accentMint],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.secondaryBlue.withValues(
                    alpha: 0.2 + (0.2 * _aiPulseController.value),
                  ),
                  blurRadius: 8 + (6 * _aiPulseController.value),
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: AppTheme.secondaryBlue.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.psychology, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  'AI Powered',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).scale(),
        ],
      ),
    );
  }

  Widget _buildTimePeriodSelector() {
    final theme = Theme.of(context);
    return Container(
      key: periodSelectorKey,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [...AppTheme.shadowSm(theme.shadowColor)],
      ),
      child: Row(
        children: _timePeriods.asMap().entries.map((entry) {
          // ignore: unused_local_variable
          final index = entry.key;
          final period = entry.value;
          final isSelected = _selectedPeriod == period['months'];

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period['months'];
                });
                HapticFeedback.selectionClick();
              },
              child: AnimatedContainer(
                duration: AppTheme.motionFast,
                margin: const EdgeInsets.all(3),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            AppTheme.primaryRose,
                            AppTheme.primaryPurple,
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  period['label'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: AppTheme.fsMd,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildTabBar() {
    final theme = Theme.of(context);
    return Container(
      key: tabsKey,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
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
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(2),
        labelPadding: EdgeInsets.zero,
        tabAlignment: TabAlignment.fill,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStatePropertyAll(Colors.transparent),
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(
          alpha: 0.7,
        ),
        labelStyle: const TextStyle(
          fontWeight: AppTheme.fwSemi,
          fontSize: AppTheme.fsMd,
        ),
        tabs: const [
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: FittedBox(fit: BoxFit.scaleDown, child: Text('Overview')),
            ),
          ),
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text('Trends'),
            ),
          ),
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text('Patterns'),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildOverviewTab() {
    return Consumer2<InsightsProvider, CycleProvider>(
      builder: (context, insightsProvider, cycleProvider, child) {
        final theme = Theme.of(context);

        if (insightsProvider.isLoading || cycleProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryRose),
            ),
          );
        }

        final completedCycles = cycleProvider.cycles
            .where((cycle) => cycle.isComplete && cycle.cycleLength != null)
            .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (completedCycles.length >= 2)
                CycleRegularityIndicator(
                  regularityScore: _calculateRegularityScore(completedCycles),
                  averageCycleLength: _calculateAverageCycleLength(
                    completedCycles,
                  ),
                  standardDeviation: _calculateStandardDeviation(
                    completedCycles,
                  ),
                  totalCycles: completedCycles.length,
                ).animate().fadeIn().slideY(begin: 0.3, end: 0)
              else
                _buildInsufficientCycleDataCard(theme),

              const SizedBox(height: 20),

              Text(
                'AI Insights',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 16),

              ...insightsProvider.insights.asMap().entries.map((entry) {
                final index = entry.key;
                final insight = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AIInsightCard(insight: insight)
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 300 + index * 100))
                      .slideX(begin: 0.3, end: 0),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInsufficientCycleDataCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [...AppTheme.shadowSm(theme.shadowColor)],
      ),
      child: Column(
        children: [
          Icon(
            Icons.timeline,
            size: 40,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'More cycle history needed',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Complete at least two cycles to calculate regularity, '
            'average length, and variation.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    return Consumer<CycleProvider>(
      builder: (context, cycleProvider, child) {
        if (cycleProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryRose),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cycle Length Chart
              CycleLengthChart(
                cycles: cycleProvider.cycles,
                months: _selectedPeriod,
              ).animate().fadeIn().slideY(begin: 0.3, end: 0),

              const SizedBox(height: 20),

              // Mood & Energy Chart
              MoodEnergyChart(
                cycleData: cycleProvider.cycles,
                selectedPeriod: _getTimePeriod(_selectedPeriod),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPatternsTab() {
    return Consumer<CycleProvider>(
      builder: (context, cycleProvider, child) {
        if (cycleProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryRose),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Symptom Heatmap
              SymptomHeatmap(
                cycleData: cycleProvider.cycles,
                selectedPeriod: _getTimePeriod(_selectedPeriod),
              ).animate().fadeIn().slideY(begin: 0.3, end: 0),
            ],
          ),
        );
      },
    );
  }

  // Helper methods for calculations
  double _calculateRegularityScore(List<CycleData> cycles) {
    final standardDeviation = _calculateStandardDeviation(cycles);
    return (1.0 - (standardDeviation / 10.0)).clamp(0.0, 1.0);
  }

  double _calculateAverageCycleLength(List<CycleData> cycles) {
    final lengths = cycles
        .map((cycle) => cycle.cycleLength!.toDouble())
        .toList();

    return lengths.reduce((a, b) => a + b) / lengths.length;
  }

  double _calculateStandardDeviation(List<CycleData> cycles) {
    final lengths = cycles
        .map((cycle) => cycle.cycleLength!.toDouble())
        .toList();

    if (lengths.length < 2) return 0;

    final average = lengths.reduce((a, b) => a + b) / lengths.length;
    final variance =
        lengths
            .map((length) => (length - average) * (length - average))
            .reduce((a, b) => a + b) /
        lengths.length;

    return sqrt(variance);
  }

  TimePeriod _getTimePeriod(int months) {
    switch (months) {
      case 1:
        return TimePeriod.month;
      case 3:
        return TimePeriod.threeMonths;
      case 6:
        return TimePeriod.sixMonths;
      case 12:
        return TimePeriod.year;
      default:
        return TimePeriod.threeMonths;
    }
  }
}
