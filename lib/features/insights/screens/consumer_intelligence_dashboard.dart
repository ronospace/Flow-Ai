import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

import '../../../core/services/biometric_integration_service.dart';
import '../../../core/services/enhanced_ai_chat_service.dart';
import '../../../core/models/biometric_data.dart';
import '../../../core/models/cycle_data.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/app_localizations.dart';

/// Consumer Intelligence Dashboard with AI insights and predictions
class ConsumerIntelligenceDashboard extends StatefulWidget {
  const ConsumerIntelligenceDashboard({super.key});

  @override
  State<ConsumerIntelligenceDashboard> createState() => _ConsumerIntelligenceDashboardState();
}

class _ConsumerIntelligenceDashboardState extends State<ConsumerIntelligenceDashboard>
    with TickerProviderStateMixin {
  
  final BiometricIntegrationService _biometricService = BiometricIntegrationService.instance;
  final EnhancedAIChatService _aiService = EnhancedAIChatService();
  
  late AnimationController _animationController;
  late AnimationController _refreshController;
  
  // Dashboard state
  BiometricAnalysis? _currentAnalysis;
  List<IntelligenceInsight> _insights = [];
  List<PersonalizedRecommendation> _recommendations = [];
  DashboardMetrics? _metrics;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String _selectedTimeframe = '7d';
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _initializeDashboard();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  /// Initialize dashboard data
  Future<void> _initializeDashboard() async {
    setState(() => _isLoading = true);
    
    try {
      await _biometricService.initialize();
      await _loadDashboardData();
      _animationController.forward();
    } catch (e) {
      debugPrint('Failed to initialize dashboard: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Load all dashboard data
  Future<void> _loadDashboardData() async {
    final endDate = DateTime.now();
    final startDate = _getStartDateForTimeframe(_selectedTimeframe, endDate);
    
    try {
      // Load biometric analysis
      final analysis = await _biometricService.getBiometricAnalysis(
        startDate: startDate,
        endDate: endDate,
      );
      
      // Generate AI insights
      final insights = await _generateIntelligenceInsights(analysis);
      
      // Generate personalized recommendations
      final recommendations = await _generatePersonalizedRecommendations(analysis);
      
      // Calculate metrics
      final metrics = await _calculateDashboardMetrics(analysis);
      
      setState(() {
        _currentAnalysis = analysis;
        _insights = insights;
        _recommendations = recommendations;
        _metrics = metrics;
      });
      
    } catch (e) {
      debugPrint('Failed to load dashboard data: $e');
    }
  }

  /// Refresh dashboard data
  Future<void> _refreshDashboard() async {
    if (_isRefreshing) return;
    
    setState(() => _isRefreshing = true);
    _refreshController.forward();
    
    try {
      await _biometricService.refreshCache();
      await _loadDashboardData();
    } finally {
      setState(() => _isRefreshing = false);
      _refreshController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar
          _buildAppBar(context, localizations),
          
          if (_isLoading)
            SliverFillRemaining(
              child: _buildLoadingState(),
            )
          else ...[
            // Metrics Overview
            _buildMetricsOverview(theme),
            
            // AI Insights Section
            _buildInsightsSection(theme),
            
            // Biometric Trends
            _buildTrendsSection(theme),
            
            // Personalized Recommendations
            _buildRecommendationsSection(theme),
            
            // Interactive Analytics
            _buildAnalyticsSection(theme),
            
            // Quick Actions
            _buildQuickActionsSection(theme),
            
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ],
      ),
      
      // Floating refresh button
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Build app bar
  Widget _buildAppBar(BuildContext context, AppLocalizations localizations) {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryPurple,
                AppTheme.primaryRose,
                AppTheme.accentMint,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Icon(
                          Icons.analytics,
                          color: Colors.white,
                          size: 28,
                        ),
                      ).animate().scale(delay: 200.ms),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Intelligence Dashboard',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.3),
                            Text(
                              'AI-powered health insights',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ).animate().fadeIn(delay: 600.ms),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTimeframeSelector(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build timeframe selector
  Widget _buildTimeframeSelector() {
    final timeframes = {
      '7d': '7 Days',
      '30d': '30 Days',
      '90d': '3 Months',
      '1y': '1 Year',
    };

    return Row(
      children: timeframes.entries.map((entry) {
        final isSelected = _selectedTimeframe == entry.key;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => _changeTimeframe(entry.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.white.withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                entry.value,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    ).animate().fadeIn(delay: 800.ms);
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
          ),
          const SizedBox(height: 24),
          Text(
            'Analyzing your health data...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.mediumGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a few moments',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.lightGrey,
            ),
          ),
        ],
      ),
    );
  }

  /// Build metrics overview
  Widget _buildMetricsOverview(ThemeData theme) {
    if (_metrics == null) return const SliverToBoxAdapter(child: SizedBox.shrink());
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Health Overview',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGrey,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Health Score',
                    '${(_metrics!.overallHealthScore * 100).toInt()}%',
                    Icons.favorite,
                    AppTheme.primaryRose,
                    _getHealthScoreColor(_metrics!.overallHealthScore),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Cycle Regularity',
                    '${(_metrics!.cycleRegularity * 100).toInt()}%',
                    Icons.refresh,
                    AppTheme.primaryPurple,
                    _getCycleRegularityColor(_metrics!.cycleRegularity),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Stress Level',
                    _getStressLevelText(_metrics!.averageStressLevel),
                    Icons.psychology,
                    AppTheme.warningOrange,
                    _getStressLevelColor(_metrics!.averageStressLevel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Sleep Quality',
                    '${(_metrics!.averageSleepQuality * 100).toInt()}%',
                    Icons.nights_stay,
                    AppTheme.secondaryBlue,
                    _getSleepQualityColor(_metrics!.averageSleepQuality),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
    );
  }

  /// Build metric card
  Widget _buildMetricCard(String title, String value, IconData icon, Color iconColor, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 18,
                ),
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: valueColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.mediumGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build insights section
  Widget _buildInsightsSection(ThemeData theme) {
    if (_insights.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'AI Insights',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGrey,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryPurple, AppTheme.primaryRose],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(
              math.min(_insights.length, 3),
              (index) => Padding(
                padding: EdgeInsets.only(bottom: index < 2 ? 12 : 0),
                child: _buildInsightCard(_insights[index]),
              ),
            ),
            if (_insights.length > 3)
              TextButton(
                onPressed: () => _showAllInsights(context),
                child: Text(
                  'View ${_insights.length - 3} more insights',
                  style: TextStyle(
                    color: AppTheme.primaryPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
    );
  }

  /// Build insight card
  Widget _buildInsightCard(IntelligenceInsight insight) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getInsightColor(insight.priority).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _getInsightColor(insight.priority).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getInsightIcon(insight.category),
                  color: _getInsightColor(insight.priority),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGrey,
                      ),
                    ),
                    Text(
                      insight.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        color: _getInsightColor(insight.priority),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getInsightColor(insight.priority).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(insight.confidence * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getInsightColor(insight.priority),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insight.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.mediumGrey,
              height: 1.4,
            ),
          ),
          if (insight.actionable) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: AppTheme.warningOrange,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Actionable insight',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.warningOrange,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showInsightDetails(insight),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    'Learn more',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Build trends section
  Widget _buildTrendsSection(ThemeData theme) {
    if (_currentAnalysis == null) return const SliverToBoxAdapter(child: SizedBox.shrink());
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Biometric Trends',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGrey,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildTrendsChart(),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
    );
  }

  /// Build trends chart
  Widget _buildTrendsChart() {
    if (_currentAnalysis?.heartRateData.isEmpty ?? true) {
      return const Center(
        child: Text(
          'No data available for selected timeframe',
          style: TextStyle(color: AppTheme.mediumGrey),
        ),
      );
    }

    final spots = _currentAnalysis!.heartRateData
        .asMap()
        .entries
        .map((entry) => FlSpot(
              entry.key.toDouble(),
              entry.value.value,
            ))
        .toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppTheme.lightGrey.withOpacity(0.5),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.mediumGrey,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: const LinearGradient(
              colors: [AppTheme.primaryPurple, AppTheme.primaryRose],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryPurple.withOpacity(0.1),
                  AppTheme.primaryRose.withOpacity(0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build recommendations section
  Widget _buildRecommendationsSection(ThemeData theme) {
    if (_recommendations.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personalized Recommendations',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGrey,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              math.min(_recommendations.length, 3),
              (index) => Padding(
                padding: EdgeInsets.only(bottom: index < 2 ? 12 : 0),
                child: _buildRecommendationCard(_recommendations[index]),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
    );
  }

  /// Build recommendation card
  Widget _buildRecommendationCard(PersonalizedRecommendation recommendation) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentMint.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.accentMint.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getRecommendationIcon(recommendation.type),
                  color: AppTheme.accentMint,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  recommendation.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGrey,
                  ),
                ),
              ),
              if (recommendation.priority == RecommendationPriority.high)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryRose,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            recommendation.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.mediumGrey,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: recommendation.potentialImpact,
                  backgroundColor: AppTheme.lightGrey.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getImpactColor(recommendation.potentialImpact),
                  ),
                  minHeight: 4,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Impact: ${(recommendation.potentialImpact * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: _getImpactColor(recommendation.potentialImpact),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build analytics section
  Widget _buildAnalyticsSection(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Interactive Analytics',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGrey,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticsCard(
                    'Correlations',
                    'Discover patterns',
                    Icons.hub,
                    AppTheme.primaryPurple,
                    () => _showCorrelations(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAnalyticsCard(
                    'Predictions',
                    'Future insights',
                    Icons.trending_up,
                    AppTheme.primaryRose,
                    () => _showPredictions(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticsCard(
                    'Export Data',
                    'Download reports',
                    Icons.download,
                    AppTheme.accentMint,
                    () => _exportData(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAnalyticsCard(
                    'Share Report',
                    'With healthcare provider',
                    Icons.share,
                    AppTheme.secondaryBlue,
                    () => _shareReport(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.2),
    );
  }

  /// Build analytics card
  Widget _buildAnalyticsCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGrey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.mediumGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build quick actions section
  Widget _buildQuickActionsSection(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGrey,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildQuickActionChip('Log Symptoms', Icons.add_circle_outline, () => _logSymptoms(context)),
                _buildQuickActionChip('Track Mood', Icons.sentiment_satisfied_alt, () => _trackMood(context)),
                _buildQuickActionChip('Record Temperature', Icons.thermostat, () => _recordTemperature(context)),
                _buildQuickActionChip('Ask Mira AI', Icons.psychology, () => _askMiraAI(context)),
                _buildQuickActionChip('View Calendar', Icons.calendar_today, () => _viewCalendar(context)),
                _buildQuickActionChip('Settings', Icons.settings, () => _openSettings(context)),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.2),
    );
  }

  /// Build quick action chip
  Widget _buildQuickActionChip(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.lightGrey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.mediumGrey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: AppTheme.primaryPurple,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.darkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build floating action button
  Widget _buildFloatingActionButton() {
    return AnimatedRotation(
      turns: _isRefreshing ? 1 : 0,
      duration: const Duration(milliseconds: 1200),
      child: FloatingActionButton(
        onPressed: _refreshDashboard,
        backgroundColor: AppTheme.primaryPurple,
        child: const Icon(
          Icons.refresh,
          color: Colors.white,
        ),
      ),
    ).animate().scale(delay: 1400.ms);
  }

  // === HELPER METHODS ===

  DateTime _getStartDateForTimeframe(String timeframe, DateTime endDate) {
    switch (timeframe) {
      case '7d':
        return endDate.subtract(const Duration(days: 7));
      case '30d':
        return endDate.subtract(const Duration(days: 30));
      case '90d':
        return endDate.subtract(const Duration(days: 90));
      case '1y':
        return endDate.subtract(const Duration(days: 365));
      default:
        return endDate.subtract(const Duration(days: 7));
    }
  }

  void _changeTimeframe(String timeframe) {
    setState(() {
      _selectedTimeframe = timeframe;
    });
    _loadDashboardData();
  }

  Color _getHealthScoreColor(double score) {
    if (score >= 0.8) return AppTheme.successGreen;
    if (score >= 0.6) return AppTheme.warningOrange;
    return AppTheme.primaryRose;
  }

  Color _getCycleRegularityColor(double regularity) {
    if (regularity >= 0.8) return AppTheme.successGreen;
    if (regularity >= 0.6) return AppTheme.warningOrange;
    return AppTheme.primaryRose;
  }

  String _getStressLevelText(double stress) {
    if (stress <= 3) return 'Low';
    if (stress <= 6) return 'Medium';
    return 'High';
  }

  Color _getStressLevelColor(double stress) {
    if (stress <= 3) return AppTheme.successGreen;
    if (stress <= 6) return AppTheme.warningOrange;
    return AppTheme.primaryRose;
  }

  Color _getSleepQualityColor(double quality) {
    if (quality >= 0.8) return AppTheme.successGreen;
    if (quality >= 0.6) return AppTheme.warningOrange;
    return AppTheme.primaryRose;
  }

  Color _getInsightColor(InsightPriority priority) {
    switch (priority) {
      case InsightPriority.low:
        return AppTheme.successGreen;
      case InsightPriority.medium:
        return AppTheme.warningOrange;
      case InsightPriority.high:
        return AppTheme.primaryRose;
    }
  }

  IconData _getInsightIcon(String category) {
    switch (category.toLowerCase()) {
      case 'health':
        return Icons.favorite;
      case 'cycle':
        return Icons.refresh;
      case 'sleep':
        return Icons.nights_stay;
      case 'stress':
        return Icons.psychology;
      case 'fitness':
        return Icons.fitness_center;
      default:
        return Icons.lightbulb;
    }
  }

  IconData _getRecommendationIcon(RecommendationType type) {
    switch (type) {
      case RecommendationType.lifestyle:
        return Icons.self_improvement;
      case RecommendationType.nutrition:
        return Icons.restaurant;
      case RecommendationType.exercise:
        return Icons.fitness_center;
      case RecommendationType.sleep:
        return Icons.nights_stay;
      case RecommendationType.stress:
        return Icons.psychology;
      case RecommendationType.medical:
        return Icons.medical_services;
    }
  }

  Color _getImpactColor(double impact) {
    if (impact >= 0.7) return AppTheme.successGreen;
    if (impact >= 0.4) return AppTheme.warningOrange;
    return AppTheme.mediumGrey;
  }

  // === AI DATA GENERATION ===

  Future<List<IntelligenceInsight>> _generateIntelligenceInsights(BiometricAnalysis analysis) async {
    // This would use AI service to generate insights
    return [
      IntelligenceInsight(
        id: 'insight_1',
        title: 'Sleep Quality Trend',
        description: 'Your sleep quality has improved by 15% over the last 7 days. This correlates with your increased evening routine consistency.',
        category: 'sleep',
        priority: InsightPriority.medium,
        confidence: 0.85,
        actionable: true,
        generatedAt: DateTime.now(),
        dataPoints: analysis.sleepData.length,
      ),
      IntelligenceInsight(
        id: 'insight_2',
        title: 'Stress-Cycle Correlation',
        description: 'Higher stress levels detected 3-5 days before your period. Consider stress management techniques during this phase.',
        category: 'cycle',
        priority: InsightPriority.high,
        confidence: 0.92,
        actionable: true,
        generatedAt: DateTime.now(),
        dataPoints: analysis.stressData.length,
      ),
      IntelligenceInsight(
        id: 'insight_3',
        title: 'Heart Rate Variability',
        description: 'Your HRV shows excellent recovery patterns after exercise, indicating good cardiovascular fitness.',
        category: 'health',
        priority: InsightPriority.low,
        confidence: 0.78,
        actionable: false,
        generatedAt: DateTime.now(),
        dataPoints: analysis.hrvData.length,
      ),
    ];
  }

  Future<List<PersonalizedRecommendation>> _generatePersonalizedRecommendations(BiometricAnalysis analysis) async {
    return [
      PersonalizedRecommendation(
        id: 'rec_1',
        title: 'Optimize Pre-Period Nutrition',
        description: 'Increase magnesium and B6 intake 5 days before your expected period to reduce cramping and mood fluctuations.',
        type: RecommendationType.nutrition,
        priority: RecommendationPriority.high,
        potentialImpact: 0.8,
        difficulty: RecommendationDifficulty.easy,
        estimatedTimeToEffect: const Duration(days: 14),
        basedOnData: ['Cycle patterns', 'Symptom tracking'],
        sources: ['Clinical studies', 'Personal data analysis'],
      ),
      PersonalizedRecommendation(
        id: 'rec_2',
        title: 'Evening Wind-Down Routine',
        description: 'Establish a consistent 30-minute wind-down routine starting at 9 PM to improve sleep quality further.',
        type: RecommendationType.sleep,
        priority: RecommendationPriority.medium,
        potentialImpact: 0.65,
        difficulty: RecommendationDifficulty.medium,
        estimatedTimeToEffect: const Duration(days: 7),
        basedOnData: ['Sleep data', 'Heart rate variability'],
        sources: ['Sleep research', 'Personal patterns'],
      ),
    ];
  }

  Future<DashboardMetrics> _calculateDashboardMetrics(BiometricAnalysis analysis) async {
    return DashboardMetrics(
      overallHealthScore: 0.75,
      cycleRegularity: 0.85,
      averageStressLevel: 4.2,
      averageSleepQuality: 0.78,
      dataCompleteness: 0.92,
      trendsDirection: TrendsDirection.improving,
      lastUpdated: DateTime.now(),
    );
  }

  // === NAVIGATION METHODS ===

  void _showAllInsights(BuildContext context) {
    // Navigate to detailed insights screen
    Navigator.pushNamed(context, '/insights/detailed');
  }

  void _showInsightDetails(IntelligenceInsight insight) {
    // Show detailed insight dialog or screen
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildInsightDetailSheet(insight),
    );
  }

  Widget _buildInsightDetailSheet(IntelligenceInsight insight) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.mediumGrey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getInsightColor(insight.priority).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getInsightIcon(insight.category),
                      color: _getInsightColor(insight.priority),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          insight.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkGrey,
                          ),
                        ),
                        Text(
                          insight.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getInsightColor(insight.priority),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Description
              Text(
                insight.description,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.mediumGrey,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Confidence and data points
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.lightGrey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Confidence',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.mediumGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(insight.confidence * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.lightGrey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Data Points',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.mediumGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${insight.dataPoints}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              if (insight.actionable) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.warningOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.warningOrange.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: AppTheme.warningOrange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Actionable Insight',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.warningOrange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This insight suggests specific actions you can take to improve your health outcomes.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.mediumGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 32),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppTheme.mediumGrey),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          color: AppTheme.mediumGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigate to relevant action screen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Take Action',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCorrelations(BuildContext context) {
    // Navigate to correlations screen
    Navigator.pushNamed(context, '/analytics/correlations');
  }

  void _showPredictions(BuildContext context) {
    // Navigate to predictions screen
    Navigator.pushNamed(context, '/analytics/predictions');
  }

  void _exportData(BuildContext context) {
    // Show export options dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Choose export format and data range'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement data export
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _shareReport(BuildContext context) {
    // Show share options
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share Health Report',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email to Healthcare Provider'),
              onTap: () {
                Navigator.pop(context);
                // Implement email sharing
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share via Apps'),
              onTap: () {
                Navigator.pop(context);
                // Implement general sharing
              },
            ),
          ],
        ),
      ),
    );
  }

  void _logSymptoms(BuildContext context) {
    Navigator.pushNamed(context, '/tracking/symptoms');
  }

  void _trackMood(BuildContext context) {
    Navigator.pushNamed(context, '/tracking/mood');
  }

  void _recordTemperature(BuildContext context) {
    Navigator.pushNamed(context, '/tracking/temperature');
  }

  void _askMiraAI(BuildContext context) {
    Navigator.pushNamed(context, '/ai/chat');
  }

  void _viewCalendar(BuildContext context) {
    Navigator.pushNamed(context, '/calendar');
  }

  void _openSettings(BuildContext context) {
    Navigator.pushNamed(context, '/settings');
  }
}

// === DATA MODELS ===

class IntelligenceInsight {
  final String id;
  final String title;
  final String description;
  final String category;
  final InsightPriority priority;
  final double confidence;
  final bool actionable;
  final DateTime generatedAt;
  final int dataPoints;

  IntelligenceInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.confidence,
    required this.actionable,
    required this.generatedAt,
    required this.dataPoints,
  });
}

class PersonalizedRecommendation {
  final String id;
  final String title;
  final String description;
  final RecommendationType type;
  final RecommendationPriority priority;
  final double potentialImpact;
  final RecommendationDifficulty difficulty;
  final Duration estimatedTimeToEffect;
  final List<String> basedOnData;
  final List<String> sources;

  PersonalizedRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.potentialImpact,
    required this.difficulty,
    required this.estimatedTimeToEffect,
    required this.basedOnData,
    required this.sources,
  });
}

class DashboardMetrics {
  final double overallHealthScore;
  final double cycleRegularity;
  final double averageStressLevel;
  final double averageSleepQuality;
  final double dataCompleteness;
  final TrendsDirection trendsDirection;
  final DateTime lastUpdated;

  DashboardMetrics({
    required this.overallHealthScore,
    required this.cycleRegularity,
    required this.averageStressLevel,
    required this.averageSleepQuality,
    required this.dataCompleteness,
    required this.trendsDirection,
    required this.lastUpdated,
  });
}

// === ENUMS ===

enum InsightPriority { low, medium, high }
enum RecommendationType { lifestyle, nutrition, exercise, sleep, stress, medical }
enum RecommendationPriority { low, medium, high }
enum RecommendationDifficulty { easy, medium, hard }
enum TrendsDirection { improving, stable, declining }
