import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/time_period.dart';
import '../providers/insights_provider.dart';
import '../../cycle/providers/cycle_provider.dart';
import '../widgets/cycle_length_chart.dart';
import '../widgets/ai_insight_card.dart';
import '../widgets/prediction_accuracy_card.dart';
import '../widgets/cycle_regularity_indicator.dart';
import '../widgets/mood_energy_chart.dart';
import '../widgets/symptom_heatmap.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
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
    _tabController = TabController(length: 3, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InsightsProvider>().loadInsights();
      context.read<CycleProvider>().loadCycles();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
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
                child: TabBarView(
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
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Insights',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGrey,
                  ),
                ).animate().fadeIn().slideX(begin: -0.3, end: 0),
                Text(
                  'Powered by machine learning',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.mediumGrey,
                  ),
                ).animate().fadeIn(delay: 100.ms),
              ],
            ),
          ),
          
          // AI Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.secondaryBlue, AppTheme.accentMint],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.secondaryBlue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'AI Powered',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: _timePeriods.asMap().entries.map((entry) {
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
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  period['label'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.mediumGrey,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
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
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.mediumGrey,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        tabs: const [
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Overview'),
            ),
          ),
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Trends'),
            ),
          ),
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        if (insightsProvider.isLoading || cycleProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryRose),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cycle Regularity
              CycleRegularityIndicator(
                regularityScore: _calculateRegularityScore(cycleProvider.cycles),
                averageCycleLength: _calculateAverageCycleLength(cycleProvider.cycles),
                standardDeviation: _calculateStandardDeviation(cycleProvider.cycles),
                totalCycles: cycleProvider.cycles.length,
              ).animate().fadeIn().slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: 20),
              
              // Prediction Accuracy
              PredictionAccuracyCard(
                accuracy: 0.87,
                totalPredictions: cycleProvider.cycles.length,
                correctPredictions: (cycleProvider.cycles.length * 0.87).round(),
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: 20),
              
              // AI Insights
              Text(
                'AI Insights',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGrey,
                ),
              ).animate().fadeIn(delay: 200.ms),
              
              const SizedBox(height: 16),
              
              ...insightsProvider.insights.asMap().entries.map((entry) {
                final index = entry.key;
                final insight = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AIInsightCard(
                    insight: insight,
                  ).animate()
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
          padding: const EdgeInsets.all(20),
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
          padding: const EdgeInsets.all(20),
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
  double _calculateRegularityScore(List<dynamic> cycles) {
    if (cycles.length < 3) return 0.5;
    
    final lengths = cycles.map((cycle) => 28).toList(); // Mock cycle lengths
    final avg = lengths.reduce((a, b) => a + b) / lengths.length;
    final variance = lengths.map((l) => (l - avg) * (l - avg)).reduce((a, b) => a + b) / lengths.length;
    final stdDev = sqrt(variance);
    
    // Higher regularity score for lower standard deviation
    return (1.0 - (stdDev / 10.0)).clamp(0.0, 1.0);
  }
  
  double _calculateAverageCycleLength(List<dynamic> cycles) {
    if (cycles.isEmpty) return 28.0;
    return 28.0; // Mock average cycle length
  }
  
  double _calculateStandardDeviation(List<dynamic> cycles) {
    if (cycles.length < 2) return 0.0;
    return 2.5; // Mock standard deviation
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
