import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../core/services/analytics_service.dart';
import '../../analytics/providers/analytics_provider.dart';
import '../../../core/biometrics/advanced_biometric_engine.dart';
import '../../../core/health/advanced_health_analytics.dart';
import '../../../core/performance/performance_optimization_engine.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/models/cycle_data.dart';
import '../widgets/real_time_metric_card.dart';
import '../widgets/health_trend_chart.dart';
import '../widgets/ai_insights_panel.dart';
import '../widgets/biometric_pulse_indicator.dart';

/// 📊 Revolutionary Real-time Health Monitoring Dashboard
/// Comprehensive real-time health data visualization with AI insights
/// Advanced biometric monitoring and predictive health analytics
class RealTimeHealthDashboard extends StatefulWidget {
  final UserProfile user;

  const RealTimeHealthDashboard({super.key, required this.user});

  @override
  State<RealTimeHealthDashboard> createState() =>
      _RealTimeHealthDashboardState();
}

class _RealTimeHealthDashboardState extends State<RealTimeHealthDashboard>
    with TickerProviderStateMixin {
  // Stream subscriptions
  StreamSubscription<BiometricReading>? _biometricSubscription;
  StreamSubscription<PerformanceMetrics>? _performanceSubscription;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  // Data and state
  BiometricSnapshot? _latestBiometrics;
  PerformanceMetrics? _latestPerformance;
  ComprehensiveHealthReport? _healthReport;
  final List<BiometricReading> _realtimeData = [];
  bool _isLoading = true;
  String _selectedMetric = 'heart_rate';
  int _selectedTimeRange = 1; // 1=1hr, 24=24hr, 168=1week

  // Refresh and update timers
  Timer? _dataRefreshTimer;
  Timer? _healthReportTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeRealTimeMonitoring();
    _startDataRefresh();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AnalyticsProvider>().loadAnalyticsHistory();
    });
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _pulseController.repeat(reverse: true);
    _slideController.forward();
  }

  void _initializeRealTimeMonitoring() async {
    try {
      // Initialize engines
      await AdvancedBiometricEngine.instance.initialize();
      await PerformanceOptimizationEngine.instance.initialize();
      await AdvancedHealthAnalytics.instance.initialize();

      // Subscribe to real-time streams
      _biometricSubscription = AdvancedBiometricEngine.instance.biometricStream
          .listen(_onBiometricUpdate);

      _performanceSubscription = PerformanceOptimizationEngine
          .instance
          .metricsStream
          .listen(_onPerformanceUpdate);

      // Generate initial health report
      await _generateHealthReport();

      setState(() {
        _isLoading = false;
      });

      _triggerHapticFeedback();
    } catch (e) {
      debugPrint('Error initializing dashboard: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startDataRefresh() {
    // Refresh biometric data every 5 seconds
    _dataRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _refreshBiometricData();
    });

    // Refresh health report every 5 minutes
    _healthReportTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _generateHealthReport();
    });
  }

  void _onBiometricUpdate(BiometricReading reading) {
    const supportedTrendMetrics = <String>{'heart_rate', 'temperature', 'hrv'};

    if (!supportedTrendMetrics.contains(reading.type) ||
        !reading.value.isFinite) {
      return;
    }

    final cutoff = DateTime.now().subtract(const Duration(hours: 168));

    setState(() {
      _realtimeData.add(reading);
      _realtimeData.removeWhere((item) => item.timestamp.isBefore(cutoff));
    });
  }

  void _onPerformanceUpdate(PerformanceMetrics metrics) {
    setState(() {
      _latestPerformance = metrics;
    });
  }

  Future<void> _refreshBiometricData() async {
    try {
      final snapshot = await AdvancedBiometricEngine.instance
          .getBiometricSnapshot(widget.user.id);
      setState(() {
        _latestBiometrics = snapshot;
      });
    } catch (e) {}
  }

  Future<void> _generateHealthReport() async {
    try {
      // Load persisted cycle history from the production database.
      final cycleHistory = await AnalyticsService.instance
          .getPersistedCycleHistory();
      if (cycleHistory.isEmpty) {
        throw StateError('No cycle history available');
      }

      final report = await AdvancedHealthAnalytics.instance
          .generateHealthReport(
            user: widget.user,
            cycleHistory: cycleHistory,
            currentPhase: 'follicular',
            analysisDepth: 30,
          );

      setState(() {
        _healthReport = report;
      });
    } catch (e) {}
  }

  void _triggerHapticFeedback() {
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: _isLoading ? _buildLoadingView() : _buildDashboard(),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.pink.withValues(alpha: 0.1),
                    Colors.purple.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: const Icon(Icons.favorite, color: Colors.pink, size: 40),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Initializing Health Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Connecting to biometric sensors...',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SlideTransition(
      position: _slideAnimation,
      child: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildRealTimeMetrics(),
                const SizedBox(height: 24),
                _buildHealthTrends(),
                const SizedBox(height: 24),
                _buildAIInsights(),
                const SizedBox(height: 24),
                _buildPerformanceMetrics(),
                const SizedBox(height: 24),
                _buildDetailedAnalysis(),
                const SizedBox(height: 100), // Bottom padding for FAB
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF1D1E33),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Health Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1D1E33), Color(0xFF2A2D5A)],
            ),
          ),
          child: _buildHeaderContent(),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _showSettingsBottomSheet(),
          icon: const Icon(Icons.settings, color: Colors.white),
        ),
        IconButton(
          onPressed: () => _refreshAllData(),
          icon: const Icon(Icons.refresh, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildHeaderContent() {
    final displayName = widget.user.displayName?.trim();
    final initial = displayName != null && displayName.isNotEmpty
        ? displayName.substring(0, 1).toUpperCase()
        : 'U';

    final heartRate = _latestBiometrics?.fusedData['heart_rate']?.toDouble();
    final temperature = _latestBiometrics?.fusedData['temperature']?.toDouble();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.pink.withValues(alpha: 0.1),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.pink,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${displayName?.isNotEmpty == true ? displayName : 'User'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_healthReport != null)
                      Text(
                        'Health Score: ${(_healthReport!.overallHealthScore * 100).round()}%',
                        style: TextStyle(
                          color: _getHealthScoreColor(
                            _healthReport!.overallHealthScore,
                          ),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          if (heartRate != null || temperature != null)
            Row(
              children: [
                if (heartRate != null)
                  BiometricPulseIndicator(value: heartRate, label: 'BPM'),
                if (heartRate != null && temperature != null)
                  const SizedBox(width: 24),
                if (temperature != null)
                  BiometricPulseIndicator(value: temperature, label: '°C'),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildRealTimeMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Real-time Metrics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_latestBiometrics != null) _buildMetricsGrid(),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    final biometrics = _latestBiometrics!;
    final metrics = <Widget>[];

    void addMetric({
      required String key,
      required String title,
      required String unit,
      required IconData icon,
      required Color color,
      required int decimals,
    }) {
      final value = biometrics.fusedData[key]?.toDouble();

      if (value == null || !value.isFinite) {
        return;
      }

      metrics.add(
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  '${value.toStringAsFixed(decimals)} $unit',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Live synced reading',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      );
    }

    addMetric(
      key: 'heart_rate',
      title: 'Heart Rate',
      unit: 'BPM',
      icon: Icons.favorite,
      color: Colors.red,
      decimals: 0,
    );
    addMetric(
      key: 'temperature',
      title: 'Temperature',
      unit: '°C',
      icon: Icons.thermostat,
      color: Colors.orange,
      decimals: 1,
    );
    addMetric(
      key: 'hrv',
      title: 'HRV',
      unit: 'ms',
      icon: Icons.graphic_eq,
      color: Colors.blue,
      decimals: 0,
    );
    addMetric(
      key: 'sleep_score',
      title: 'Sleep Score',
      unit: '%',
      icon: Icons.bedtime,
      color: Colors.purple,
      decimals: 0,
    );

    if (metrics.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No synced health readings are available yet.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: metrics,
    );
  }

  Widget _buildHealthTrends() {
    final history = context.watch<AnalyticsProvider>().analyticsHistory;
    final trendData = _generateTrendData(history);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Health Trends',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildTimeRangeSelector(),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1D1E33),
            borderRadius: BorderRadius.circular(16),
          ),
          child: trendData.isEmpty
              ? const Center(
                  child: Text(
                    'Historical health trends will appear after real synced history is available.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : HealthTrendChart(
                  data: trendData,
                  selectedMetric: _selectedMetric,
                  timeRange: _selectedTimeRange,
                ),
        ),
        const SizedBox(height: 16),
        _buildMetricSelector(),
      ],
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D5A),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTimeRangeButton('1H', 1),
          _buildTimeRangeButton('24H', 24),
          _buildTimeRangeButton('1W', 168),
        ],
      ),
    );
  }

  Widget _buildTimeRangeButton(String label, int hours) {
    final isSelected = _selectedTimeRange == hours;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeRange = hours;
        });
        _triggerHapticFeedback();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricSelector() {
    final metrics = [
      {'key': 'heart_rate', 'label': 'Heart Rate', 'icon': Icons.favorite},
      {'key': 'temperature', 'label': 'Temperature', 'icon': Icons.thermostat},
      {'key': 'hrv', 'label': 'HRV', 'icon': Icons.graphic_eq},
      {'key': 'sleep', 'label': 'Sleep', 'icon': Icons.bedtime},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: metrics.map((metric) => _buildMetricChip(metric)).toList(),
      ),
    );
  }

  Widget _buildMetricChip(Map<String, dynamic> metric) {
    final isSelected = _selectedMetric == metric['key'];

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedMetric = metric['key'];
          });
          _triggerHapticFeedback();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.pink.withValues(alpha: 0.1)
                : const Color(0xFF2A2D5A),
            borderRadius: BorderRadius.circular(25),
            border: isSelected ? Border.all(color: Colors.pink) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                metric['icon'],
                color: isSelected ? Colors.pink : Colors.white54,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                metric['label'],
                style: TextStyle(
                  color: isSelected ? Colors.pink : Colors.white54,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Health Insights',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_healthReport != null)
          AIInsightsPanel(healthReport: _healthReport!),
      ],
    );
  }

  Widget _buildPerformanceMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'App Performance',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_latestPerformance != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1D1E33),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildPerformanceRow(
                  'Memory Usage',
                  '${(_latestPerformance!.memoryUsage * 100).toStringAsFixed(1)}%',
                  _latestPerformance!.memoryUsage,
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildPerformanceRow(
                  'Battery Level',
                  '${(_latestPerformance!.batteryLevel * 100).toStringAsFixed(0)}%',
                  _latestPerformance!.batteryLevel,
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildPerformanceRow(
                  'Frame Rate',
                  '${_latestPerformance!.frameRate.toStringAsFixed(1)} FPS',
                  _latestPerformance!.frameRate / 60.0,
                  Colors.orange,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPerformanceRow(
    String label,
    String value,
    double progress,
    Color color,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedAnalysis() {
    if (_healthReport == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detailed Analysis',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1D1E33),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAnalysisSection('Key Findings', _healthReport!.keyFindings),
              const SizedBox(height: 16),
              _buildAnalysisSection(
                'Recommendations',
                _healthReport!.recommendations.map((r) => r.action).toList(),
              ),
              const SizedBox(height: 16),
              _buildAnalysisSection('Next Steps', _healthReport!.nextSteps),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...items
            .take(3)
            .map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(color: Colors.pink, fontSize: 16),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  List<FlSpot> _generateTrendData(AnalyticsHistory history) {
    final now = DateTime.now();
    final start = now.subtract(Duration(hours: _selectedTimeRange));

    double xFor(DateTime timestamp) {
      final elapsed = timestamp.difference(start).inMilliseconds.toDouble();

      switch (_selectedTimeRange) {
        case 1:
          return elapsed / const Duration(minutes: 5).inMilliseconds;
        case 24:
          return elapsed / const Duration(hours: 1).inMilliseconds;
        case 168:
          return elapsed / const Duration(days: 1).inMilliseconds;
        default:
          return 0;
      }
    }

    if (_selectedMetric == 'sleep') {
      final entries =
          history.sleepHours.entries
              .where(
                (entry) =>
                    entry.value.isFinite &&
                    !entry.key.isBefore(start) &&
                    !entry.key.isAfter(now),
              )
              .toList()
            ..sort((a, b) => a.key.compareTo(b.key));

      return entries
          .map((entry) => FlSpot(xFor(entry.key), entry.value))
          .toList();
    }

    const realtimeMetrics = <String>{'heart_rate', 'temperature', 'hrv'};

    if (!realtimeMetrics.contains(_selectedMetric)) {
      return const <FlSpot>[];
    }

    final readings =
        _realtimeData
            .where(
              (reading) =>
                  reading.type == _selectedMetric &&
                  reading.value.isFinite &&
                  !reading.timestamp.isBefore(start) &&
                  !reading.timestamp.isAfter(now),
            )
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return readings
        .map((reading) => FlSpot(xFor(reading.timestamp), reading.value))
        .toList();
  }

  Color _getHealthScoreColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.yellow;
    return Colors.red;
  }

  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1D1E33),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildSettingsTile(
              'Refresh Rate',
              'Every 5 seconds',
              Icons.refresh,
              () {},
            ),
            _buildSettingsTile(
              'Notifications',
              'Health alerts enabled',
              Icons.notifications,
              () {},
            ),
            _buildSettingsTile(
              'Data Export',
              'Export health data',
              Icons.download,
              () {},
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.pink),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54)),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Future<void> _refreshAllData() async {
    _triggerHapticFeedback();

    setState(() {
      _isLoading = true;
    });

    await Future.wait([_refreshBiometricData(), _generateHealthReport()]);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _biometricSubscription?.cancel();
    _performanceSubscription?.cancel();
    _dataRefreshTimer?.cancel();
    _healthReportTimer?.cancel();
    super.dispose();
  }
}
