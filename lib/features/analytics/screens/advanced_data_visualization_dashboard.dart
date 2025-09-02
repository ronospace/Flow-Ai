import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/health/advanced_health_analytics.dart';
import '../widgets/interactive_cycle_chart.dart';
import '../widgets/health_metrics_timeline.dart';
import '../widgets/predictive_insights_panel.dart';
import '../widgets/correlation_heatmap.dart';
import '../widgets/ai_trend_analyzer.dart';

/// 📊 Advanced Data Visualization Dashboard for Flo AI
/// Revolutionary health data visualization with AI-powered insights
/// Interactive charts, predictive analytics, and personalized recommendations
class AdvancedDataVisualizationDashboard extends StatefulWidget {
  final UserProfile userProfile;

  const AdvancedDataVisualizationDashboard({
    Key? key,
    required this.userProfile,
  }) : super(key: key);

  @override
  State<AdvancedDataVisualizationDashboard> createState() =>
      _AdvancedDataVisualizationDashboardState();
}

class _AdvancedDataVisualizationDashboardState
    extends State<AdvancedDataVisualizationDashboard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _dashboardController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Dashboard state
  TimeRange _selectedTimeRange = TimeRange.month;
  DashboardView _currentView = DashboardView.overview;
  bool _isLoading = false;
  Map<String, dynamic> _dashboardData = {};

  // Chart configurations
  final List<String> _availableMetrics = [
    'cycle_length',
    'flow_intensity',
    'mood_score',
    'energy_level',
    'symptoms',
    'temperature',
    'heart_rate',
    'sleep_quality',
    'stress_level',
    'activity_level',
  ];

  List<String> _selectedMetrics = ['cycle_length', 'mood_score', 'energy_level'];
  bool _showPredictions = true;
  bool _showCorrelations = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadDashboardData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _dashboardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      // Simulate loading comprehensive health data
      await Future.delayed(const Duration(seconds: 1));

      final mockData = {
        'cycle_data': _generateMockCycleData(),
        'health_metrics': _generateMockHealthMetrics(),
        'predictions': _generateMockPredictions(),
        'correlations': _generateMockCorrelations(),
        'insights': _generateMockInsights(),
      };

      setState(() {
        _dashboardData = mockData;
        _isLoading = false;
      });

      _dashboardController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading dashboard data: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _dashboardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              _buildAdvancedAppBar(),
              if (_isLoading) _buildLoadingSection(),
              if (!_isLoading) ...[
                _buildControlPanel(),
                _buildMainVisualization(),
                _buildSecondaryCharts(),
                _buildInsightsSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAdvancedAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withOpacity(0.8),
                AppTheme.secondaryColor.withOpacity(0.6),
                AppTheme.backgroundColor,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.analytics_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Advanced Analytics',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'AI-powered health insights for ${widget.userProfile.displayName ?? 'you'}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.settings, color: Colors.white),
          ),
          onPressed: _showDashboardSettings,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLoadingSection() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Loading advanced analytics...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Analyzing your health patterns with AI',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard Controls',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTimeRangeSelector(),
            const SizedBox(height: 16),
            _buildViewSelector(),
            const SizedBox(height: 16),
            _buildMetricSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Time Range',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: TimeRange.values.map((range) {
              final isSelected = _selectedTimeRange == range;
              return GestureDetector(
                onTap: () => setState(() => _selectedTimeRange = range),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _getTimeRangeLabel(range),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildViewSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dashboard View',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: DashboardView.values.map((view) {
              final isSelected = _currentView == view;
              return GestureDetector(
                onTap: () => setState(() => _currentView = view),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.secondaryColor
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.secondaryColor
                          : Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getViewIcon(view),
                        size: 16,
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getViewLabel(view),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Selected Metrics',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextButton(
              onPressed: _showMetricSelectionDialog,
              child: const Text(
                'Customize',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedMetrics.map((metric) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getMetricColor(metric),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getMetricLabel(metric),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMainVisualization() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 400,
        child: _getCurrentViewWidget(),
      ),
    );
  }

  Widget _buildSecondaryCharts() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_showCorrelations) ...[
              const SizedBox(height: 16),
              _buildCorrelationMatrix(),
            ],
            const SizedBox(height: 16),
            _buildHealthMetricsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: PredictiveInsightsPanel(
          userProfile: widget.userProfile,
          dashboardData: _dashboardData,
          selectedMetrics: _selectedMetrics,
          timeRange: _selectedTimeRange,
        ),
      ),
    );
  }

  Widget _getCurrentViewWidget() {
    switch (_currentView) {
      case DashboardView.overview:
        return InteractiveCycleChart(
          userProfile: widget.userProfile,
          timeRange: _selectedTimeRange,
          selectedMetrics: _selectedMetrics,
          showPredictions: _showPredictions,
        );
      case DashboardView.trends:
        return HealthMetricsTimeline(
          userProfile: widget.userProfile,
          timeRange: _selectedTimeRange,
          selectedMetrics: _selectedMetrics,
        );
      case DashboardView.correlations:
        return CorrelationHeatmap(
          userProfile: widget.userProfile,
          timeRange: _selectedTimeRange,
          correlationData: _dashboardData['correlations'] ?? {},
        );
      case DashboardView.predictions:
        return AiTrendAnalyzer(
          userProfile: widget.userProfile,
          timeRange: _selectedTimeRange,
          predictionsData: _dashboardData['predictions'] ?? {},
        );
    }
  }

  Widget _buildCorrelationMatrix() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Metric Correlations',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: CorrelationHeatmap(
              userProfile: widget.userProfile,
              timeRange: _selectedTimeRange,
              correlationData: _dashboardData['correlations'] ?? {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetricsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _selectedMetrics.length,
      itemBuilder: (context, index) {
        final metric = _selectedMetrics[index];
        return _buildMetricCard(metric);
      },
    );
  }

  Widget _buildMetricCard(String metric) {
    final data = _dashboardData['health_metrics']?[metric] ?? [];
    final currentValue = data.isNotEmpty ? data.last : 0.0;
    final previousValue = data.length > 1 ? data[data.length - 2] : 0.0;
    final change = currentValue - previousValue;
    final changePercent = previousValue != 0 ? (change / previousValue) * 100 : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getMetricColor(metric),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getMetricLabel(metric),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatMetricValue(metric, currentValue),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                change >= 0 ? Icons.trending_up : Icons.trending_down,
                size: 16,
                color: change >= 0 ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                '${change >= 0 ? '+' : ''}${changePercent.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: change >= 0 ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getTimeRangeLabel(TimeRange range) {
    switch (range) {
      case TimeRange.week:
        return '1 Week';
      case TimeRange.month:
        return '1 Month';
      case TimeRange.quarter:
        return '3 Months';
      case TimeRange.year:
        return '1 Year';
    }
  }

  String _getViewLabel(DashboardView view) {
    switch (view) {
      case DashboardView.overview:
        return 'Overview';
      case DashboardView.trends:
        return 'Trends';
      case DashboardView.correlations:
        return 'Correlations';
      case DashboardView.predictions:
        return 'Predictions';
    }
  }

  IconData _getViewIcon(DashboardView view) {
    switch (view) {
      case DashboardView.overview:
        return Icons.dashboard_outlined;
      case DashboardView.trends:
        return Icons.timeline_outlined;
      case DashboardView.correlations:
        return Icons.scatter_plot_outlined;
      case DashboardView.predictions:
        return Icons.auto_graph_outlined;
    }
  }

  String _getMetricLabel(String metric) {
    switch (metric) {
      case 'cycle_length':
        return 'Cycle Length';
      case 'flow_intensity':
        return 'Flow Intensity';
      case 'mood_score':
        return 'Mood Score';
      case 'energy_level':
        return 'Energy Level';
      case 'symptoms':
        return 'Symptoms';
      case 'temperature':
        return 'Temperature';
      case 'heart_rate':
        return 'Heart Rate';
      case 'sleep_quality':
        return 'Sleep Quality';
      case 'stress_level':
        return 'Stress Level';
      case 'activity_level':
        return 'Activity Level';
      default:
        return metric.replaceAll('_', ' ').toUpperCase();
    }
  }

  Color _getMetricColor(String metric) {
    switch (metric) {
      case 'cycle_length':
        return AppTheme.primaryColor;
      case 'flow_intensity':
        return Colors.red;
      case 'mood_score':
        return Colors.amber;
      case 'energy_level':
        return Colors.green;
      case 'symptoms':
        return Colors.orange;
      case 'temperature':
        return Colors.blue;
      case 'heart_rate':
        return Colors.pink;
      case 'sleep_quality':
        return Colors.indigo;
      case 'stress_level':
        return Colors.deepOrange;
      case 'activity_level':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _formatMetricValue(String metric, double value) {
    switch (metric) {
      case 'cycle_length':
        return '${value.toInt()} days';
      case 'flow_intensity':
        return '${(value * 10).toInt()}/10';
      case 'mood_score':
        return '${(value * 10).toInt()}/10';
      case 'energy_level':
        return '${(value * 100).toInt()}%';
      case 'temperature':
        return '${value.toStringAsFixed(1)}°C';
      case 'heart_rate':
        return '${value.toInt()} bpm';
      case 'sleep_quality':
        return '${(value * 10).toInt()}/10';
      case 'stress_level':
        return '${(value * 10).toInt()}/10';
      case 'activity_level':
        return '${(value * 100).toInt()}%';
      default:
        return value.toStringAsFixed(1);
    }
  }

  void _showDashboardSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundColor,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Dashboard Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Show Predictions', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Display AI-powered predictions', style: TextStyle(color: Colors.white70)),
              value: _showPredictions,
              onChanged: (value) => setState(() => _showPredictions = value),
              activeColor: AppTheme.primaryColor,
            ),
            SwitchListTile(
              title: const Text('Show Correlations', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Display metric correlations', style: TextStyle(color: Colors.white70)),
              value: _showCorrelations,
              onChanged: (value) => setState(() => _showCorrelations = value),
              activeColor: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  void _showMetricSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        title: const Text('Select Metrics', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _availableMetrics.map((metric) {
            return CheckboxListTile(
              title: Text(_getMetricLabel(metric), style: const TextStyle(color: Colors.white)),
              value: _selectedMetrics.contains(metric),
              onChanged: (selected) {
                setState(() {
                  if (selected == true && !_selectedMetrics.contains(metric)) {
                    _selectedMetrics.add(metric);
                  } else if (selected == false) {
                    _selectedMetrics.remove(metric);
                  }
                });
                Navigator.pop(context);
              },
              activeColor: AppTheme.primaryColor,
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done', style: TextStyle(color: AppTheme.primaryColor)),
          ),
        ],
      ),
    );
  }

  // Mock data generators
  List<double> _generateMockCycleData() {
    return List.generate(30, (index) => 28.0 + (index % 5) - 2);
  }

  Map<String, List<double>> _generateMockHealthMetrics() {
    return {
      for (String metric in _availableMetrics)
        metric: List.generate(30, (index) {
          switch (metric) {
            case 'cycle_length':
              return 28.0 + (index % 4) - 2;
            case 'mood_score':
              return 0.6 + (index % 10) * 0.04;
            case 'energy_level':
              return 0.5 + (index % 8) * 0.0625;
            default:
              return 0.5 + (index % 10) * 0.05;
          }
        })
    };
  }

  Map<String, dynamic> _generateMockPredictions() {
    return {
      'next_cycle_start': DateTime.now().add(const Duration(days: 7)),
      'fertility_window': [
        DateTime.now().add(const Duration(days: 12)),
        DateTime.now().add(const Duration(days: 16)),
      ],
      'mood_forecast': List.generate(7, (index) => 0.6 + (index % 3) * 0.1),
      'energy_forecast': List.generate(7, (index) => 0.7 + (index % 4) * 0.075),
    };
  }

  Map<String, Map<String, double>> _generateMockCorrelations() {
    final metrics = _selectedMetrics.take(5).toList();
    return {
      for (String metric1 in metrics)
        metric1: {
          for (String metric2 in metrics)
            metric2: metric1 == metric2 ? 1.0 : (0.2 + (metric1.hashCode + metric2.hashCode) % 60 / 100)
        }
    };
  }

  List<String> _generateMockInsights() {
    return [
      'Your cycle length has been remarkably consistent this month',
      'Energy levels peak during your follicular phase',
      'Mood scores correlate strongly with sleep quality',
      'Activity levels show an upward trend this quarter',
    ];
  }
}

enum TimeRange { week, month, quarter, year }
enum DashboardView { overview, trends, correlations, predictions }
