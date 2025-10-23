import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/services/advanced_biometric_service.dart';
import '../../../core/services/ai_engine.dart';
import '../../../core/models/ai_insights.dart';
import '../../../core/utils/app_logger.dart';

/// Enhanced Consumer Intelligence Dashboard with real-time biometric integration
class EnhancedConsumerDashboard extends StatefulWidget {
  const EnhancedConsumerDashboard({super.key});

  @override
  State<EnhancedConsumerDashboard> createState() => _EnhancedConsumerDashboardState();
}

class _EnhancedConsumerDashboardState extends State<EnhancedConsumerDashboard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  
  BiometricSnapshot? _currentSnapshot;
  List<BiometricInsight> _insights = [];
  List<AIInsight> _aiInsights = [];
  bool _isLoading = true;
  StreamSubscription? _dataSubscription;
  
  final Map<String, double> _healthScores = {
    'Overall': 0.85,
    'Cycle': 0.92,
    'Sleep': 0.78,
    'Stress': 0.65,
    'Energy': 0.88,
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeDashboard();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  Future<void> _initializeDashboard() async {
    try {
      AppLogger.info('🔄 Initializing Enhanced Consumer Dashboard...');
      
      // Initialize biometric service
      await AdvancedBiometricService.instance.initialize();
      
      // Load initial data
      await _loadDashboardData();
      
      // Start real-time updates
      _startRealTimeUpdates();
      
      // Animate dashboard appearance
      await _fadeController.forward();
      
      setState(() {
        _isLoading = false;
      });
      
      AppLogger.success('✅ Enhanced Dashboard initialized');
    } catch (e) {
      AppLogger.error('Failed to initialize dashboard: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDashboardData() async {
    try {
      // Load current biometric snapshot
      _currentSnapshot = await AdvancedBiometricService.instance.getCurrentBiometricSnapshot();
      
      // If no real data, use mock data for demonstration
      if (!_currentSnapshot!.hasData) {
        _currentSnapshot = BiometricSnapshot.mock();
      }
      
      // Generate AI insights based on current data
      final cycles = <CycleData>[]; // This would come from your cycle data service
      _aiInsights = await AIEngine.instance.generateInsights(cycles);
      
      // Load recent biometric insights
      _insights = await _generateMockInsights(); // This would come from the biometric service
      
      AppLogger.info('📊 Dashboard data loaded - ${_insights.length} insights');
    } catch (e) {
      AppLogger.error('Error loading dashboard data: $e');
    }
  }

  void _startRealTimeUpdates() {
    // Update dashboard data every 30 seconds
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _refreshDashboardData();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _refreshDashboardData() async {
    try {
      final newSnapshot = await AdvancedBiometricService.instance.getCurrentBiometricSnapshot();
      
      if (newSnapshot.hasData && mounted) {
        setState(() {
          _currentSnapshot = newSnapshot;
        });
      }
    } catch (e) {
      AppLogger.error('Error refreshing dashboard: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_pulseController.value * 0.1),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.health_and_safety,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Loading your health insights...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeController,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHealthScoreCard(),
                  const SizedBox(height: 16),
                  _buildBiometricOverview(),
                  const SizedBox(height: 16),
                  _buildInsightsSection(),
                  const SizedBox(height: 16),
                  _buildTrendsChart(),
                  const SizedBox(height: 16),
                  _buildRecommendationsSection(),
                  const SizedBox(height: 100), // Bottom padding for fab
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('Health Intelligence'),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withValues(alpha: 0.1),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _pulseController.value * 6.28,
                child: const Icon(Icons.refresh),
              );
            },
          ),
          onPressed: _refreshDashboardData,
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            // Navigate to settings
          },
        ),
      ],
    );
  }

  Widget _buildHealthScoreCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Overall Health Score',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Based on your biometric data and cycle patterns',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: _healthScores.entries.map((entry) {
                return Expanded(
                  child: _buildScoreIndicator(entry.key, entry.value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.3, duration: 600.ms).fadeIn();
  }

  Widget _buildScoreIndicator(String label, double score) {
    final color = _getScoreColor(score);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 60,
                width: 60,
                child: CircularProgressIndicator(
                  value: score,
                  backgroundColor: Colors.grey[200],
                  color: color,
                  strokeWidth: 6,
                ),
              ),
              Text(
                '${(score * 100).toInt()}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricOverview() {
    if (_currentSnapshot == null || !_currentSnapshot!.hasData) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.sensors_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'No biometric data available',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Connect your health apps to unlock personalized insights',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _connectHealthApps,
                child: const Text('Connect Health Apps'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.monitor_heart, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                const Text(
                  'Current Vitals',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: 0.5 + (_pulseController.value * 0.5),
                            child: const Icon(
                              Icons.circle,
                              color: Colors.green,
                              size: 8,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Live',
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (_currentSnapshot!.heartRate != null)
                  _buildVitalCard('Heart Rate', '${_currentSnapshot!.heartRate!.toInt()} BPM', Icons.favorite, Colors.red),
                if (_currentSnapshot!.heartRateVariability != null)
                  _buildVitalCard('HRV', '${_currentSnapshot!.heartRateVariability!.toInt()} ms', Icons.timeline, Colors.blue),
                if (_currentSnapshot!.bodyTemperature != null)
                  _buildVitalCard('Temperature', '${_currentSnapshot!.bodyTemperature!.toStringAsFixed(1)}°C', Icons.thermostat, Colors.orange),
                if (_currentSnapshot!.sleepHours != null)
                  _buildVitalCard('Sleep', '${_currentSnapshot!.sleepHours!.toStringAsFixed(1)}h', Icons.bedtime, Colors.purple),
                if (_currentSnapshot!.steps != null)
                  _buildVitalCard('Steps', '${(_currentSnapshot!.steps! / 1000).toStringAsFixed(1)}K', Icons.directions_walk, Colors.green),
                if (_currentSnapshot!.bloodOxygen != null)
                  _buildVitalCard('Blood O₂', '${_currentSnapshot!.bloodOxygen!.toInt()}%', Icons.air, Colors.cyan),
              ],
            ),
          ],
        ),
      ),
    ).animate().slideX(begin: -0.3, duration: 700.ms).fadeIn();
  }

  Widget _buildVitalCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                const Text(
                  'AI Insights',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_insights.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.psychology, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    const Text(
                      'Gathering insights...',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Check back soon for personalized health insights',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            else
              ...(_insights.take(3).map((insight) => _buildInsightCard(insight))),
          ],
        ),
      ),
    ).animate().slideX(begin: 0.3, duration: 800.ms).fadeIn();
  }

  Widget _buildInsightCard(BiometricInsight insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                insight.type.emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  insight.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(insight.confidence).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(insight.confidence * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getConfidenceColor(insight.confidence),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            insight.insight,
            style: TextStyle(color: Colors.grey[600]),
          ),
          if (insight.recommendations.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Recommended: ${insight.recommendations.first}',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrendsChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                const Text(
                  '7-Day Trends',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: _buildMockTrendChart(),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.3, duration: 900.ms).fadeIn();
  }

  Widget _buildMockTrendChart() {
    // Mock data for demonstration
    final spots = List.generate(7, (index) {
      final baseValue = 75.0;
      final variation = (index * 1.5) - 3;
      return FlSpot(index.toDouble(), baseValue + variation + (index % 2 == 0 ? 2 : -2));
    });

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                if (value.toInt() < days.length) {
                  return Text(
                    days[value.toInt()],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    final mockRecommendations = [
      'Take a 10-minute walk to improve circulation',
      'Consider going to bed 30 minutes earlier tonight',
      'Try deep breathing exercises to reduce stress',
      'Stay hydrated - aim for 2L of water today',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.recommend, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                const Text(
                  'Personalized Recommendations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...mockRecommendations.map((recommendation) => _buildRecommendationItem(recommendation)),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.3, duration: 1000.ms).fadeIn();
  }

  Widget _buildRecommendationItem(String recommendation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              recommendation,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.05),
          child: FloatingActionButton(
            onPressed: _refreshDashboardData,
            child: const Icon(Icons.refresh),
          ),
        );
      },
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  void _connectHealthApps() {
    // Show health apps connection dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connect Health Apps'),
        content: const Text(
          'Connect your Apple Health or Google Fit to unlock personalized insights based on your biometric data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await AdvancedBiometricService.instance.initialize();
              _refreshDashboardData();
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  Future<List<BiometricInsight>> _generateMockInsights() async {
    // Generate mock insights for demonstration
    return [
      BiometricInsight(
        type: BiometricInsightType.hrvElevated,
        title: 'Excellent Recovery Status',
        insight: 'Your heart rate variability is in the optimal range, indicating good recovery and stress management.',
        confidence: 0.87,
        dataPoints: 14,
        recommendations: ['Great time for moderate exercise', 'Maintain current wellness routine'],
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      BiometricInsight(
        type: BiometricInsightType.sleepDisruption,
        title: 'Sleep Pattern Changes',
        insight: 'Your sleep duration has decreased by 45 minutes over the past 3 days.',
        confidence: 0.72,
        dataPoints: 21,
        recommendations: ['Try a consistent bedtime routine', 'Limit screen time before bed'],
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      BiometricInsight(
        type: BiometricInsightType.temperatureShift,
        title: 'Basal Temperature Trend',
        insight: 'Your basal body temperature shows a gradual increase, suggesting you may be approaching ovulation.',
        confidence: 0.94,
        dataPoints: 10,
        recommendations: ['Continue daily temperature tracking', 'Note any additional fertility signs'],
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _dataSubscription?.cancel();
    super.dispose();
  }
}
