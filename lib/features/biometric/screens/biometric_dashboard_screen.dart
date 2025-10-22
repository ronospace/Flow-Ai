import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/app_localizations.dart';
import '../../../core/models/biometric_data.dart';
import '../../../core/services/biometric_integration_service.dart';
import '../widgets/biometric_chart_widget.dart';
import '../widgets/health_metrics_card.dart';
import '../widgets/correlation_insights_card.dart';
import '../widgets/biometric_sync_status.dart';

class BiometricDashboardScreen extends StatefulWidget {
  const BiometricDashboardScreen({super.key});

  @override
  State<BiometricDashboardScreen> createState() => _BiometricDashboardScreenState();
}

class _BiometricDashboardScreenState extends State<BiometricDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  BiometricAnalysis? _currentAnalysis;
  bool _isLoading = true;
  bool _hasPermission = false;
  String? _errorMessage;
  
  // Data refresh state
  bool _isRefreshing = false;
  DateTime? _lastRefresh;
  
  // Filter state
  DateTimeRange _selectedRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 7)),
    end: DateTime.now(),
  );
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeBiometricDashboard();
    _lastRefresh = DateTime.now();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _initializeBiometricDashboard() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      final biometricService = BiometricIntegrationService.instance;
      
      // Initialize service if not already done
      if (!biometricService.isInitialized) {
        await biometricService.initialize();
      }
      
      _hasPermission = biometricService.hasHealthPermission;
      
      if (_hasPermission) {
        await _loadBiometricData();
      } else {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.healthDataAccessNotGranted;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '${AppLocalizations.of(context)!.failedToInitializeBiometricDashboard}: $e';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadBiometricData() async {
    try {
      final biometricService = BiometricIntegrationService.instance;
      
      final analysis = await biometricService.getBiometricAnalysis(
        startDate: _selectedRange.start,
        endDate: _selectedRange.end,
      );
      
      setState(() {
        _currentAnalysis = analysis;
        _isLoading = false;
        _lastRefresh = DateTime.now();
      });
    } catch (e) {
      setState(() {
        _errorMessage = '${AppLocalizations.of(context)!.failedToLoadBiometricData}: $e';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _refreshData() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });
    
    HapticFeedback.lightImpact();
    
    try {
      // Refresh cache in biometric service
      await BiometricIntegrationService.instance.refreshCache();
      
      // Reload data
      await _loadBiometricData();
      
      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.refresh, color: Colors.white),
              const SizedBox(width: 8),
              Text('Biometric data refreshed at ${DateFormat('HH:mm').format(DateTime.now())}'),
            ],
          ),
          backgroundColor: AppTheme.accentMint,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh data: $e'),
          backgroundColor: AppTheme.warningOrange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }
  
  Future<void> _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedRange,
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: AppTheme.primaryRose,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedRange) {
      setState(() {
        _selectedRange = picked;
        _isLoading = true;
      });
      await _loadBiometricData();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient(theme.brightness == Brightness.dark),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              _buildAppBar(),
              
              // Status Banner
              if (_hasPermission && _currentAnalysis != null)
                _buildStatusBanner(),
              
              // Tab Bar
              _buildTabBar(),
              
              // Content
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _hasPermission
                        ? _buildDashboardContent()
                        : _buildPermissionState(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAppBar() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).biometricDashboard,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context).aiPoweredHealthInsights,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ).animate().fadeIn(delay: 100.ms),
                  ],
                ),
              ),
              
              // Actions
              Row(
                children: [
                  // Date Range Selector
                  GestureDetector(
                    onTap: _showDateRangePicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.cardColor.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.date_range,
                            size: 16,
                            color: AppTheme.primaryRose,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_selectedRange.duration.inDays}d',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).scale(),
                  
                  const SizedBox(width: 8),
                  
                  // Refresh Button
                  GestureDetector(
                    onTap: _isRefreshing ? null : _refreshData,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.secondaryBlue, AppTheme.accentMint],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _isRefreshing
                          ? const SizedBox(width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ).animate().rotate()
                          : const Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 18,
                            ),
                    ),
                  ).animate().fadeIn(delay: 300.ms).scale(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusBanner() {
    if (_currentAnalysis == null) return const SizedBox.shrink();
    
    final analysis = _currentAnalysis!;
    final completeness = analysis.dataCompleteness;
    final hasData = analysis.hasData;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasData
              ? [AppTheme.successGreen.withValues(alpha: 0.1), AppTheme.accentMint.withValues(alpha: 0.1)]
              : [AppTheme.warningOrange.withValues(alpha: 0.1), AppTheme.warningOrange.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasData ? AppTheme.successGreen.withValues(alpha: 0.3) : AppTheme.warningOrange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: hasData ? AppTheme.successGreen : AppTheme.warningOrange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              hasData ? Icons.health_and_safety : Icons.warning,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasData ? 'Health Data Connected' : 'Limited Health Data',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  hasData
                      ? 'Data completeness: ${(completeness * 100).round()}%'
                      : 'Connect more devices for better insights',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          if (_lastRefresh != null) ...[ 
            Text(
              'Updated ${DateFormat('HH:mm').format(_lastRefresh!)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: -0.2, end: 0);
  }
  
  Widget _buildTabBar() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.center,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        tabs: [
          Tab(
            child: _buildTabContent(Icons.monitor_heart, 'Overview'),
          ),
          Tab(
            child: _buildTabContent(Icons.timeline, 'Metrics'),
          ),
          Tab(
            child: _buildTabContent(Icons.psychology, 'Insights'),
          ),
          Tab(
            child: _buildTabContent(Icons.sync, 'Sync'),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: -0.2, end: 0);
  }
  
  Widget _buildTabContent(IconData icon, String label) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }
  
  Widget _buildDashboardContent() {
    if (_errorMessage != null) {
      return _buildErrorState();
    }
    
    if (_currentAnalysis == null) {
      return _buildEmptyState();
    }
    
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildMetricsTab(),
        _buildInsightsTab(),
        _buildSyncTab(),
      ],
    );
  }
  
  Widget _buildOverviewTab() {
    final analysis = _currentAnalysis!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Health Score
          _buildHealthScoreCard(analysis),
          
          const SizedBox(height: 20),
          
          // Quick Metrics Grid
          _buildQuickMetricsGrid(analysis),
          
          const SizedBox(height: 20),
          
          // Recent Trends
          _buildRecentTrendsCard(analysis),
          
          const SizedBox(height: 20),
          
          // Cycle Correlations Preview
          if (analysis.cycleCorrelations.isNotEmpty)
            CorrelationInsightsCard(
              correlations: analysis.cycleCorrelations,
              isPreview: true,
            ),
        ],
      ),
    );
  }
  
  Widget _buildMetricsTab() {
    final analysis = _currentAnalysis!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Heart Rate Chart
          if (analysis.heartRateData.isNotEmpty) ...[
            BiometricChartWidget(
              title: 'Heart Rate',
              data: analysis.heartRateData,
              type: BiometricType.heartRate,
              color: AppTheme.primaryRose,
            ),
            const SizedBox(height: 20),
          ],
          
          // Sleep Quality Chart
          if (analysis.sleepData.isNotEmpty) ...[
            BiometricChartWidget(
              title: 'Sleep Quality',
              data: analysis.sleepData,
              type: BiometricType.sleepAnalysis,
              color: AppTheme.secondaryBlue,
            ),
            const SizedBox(height: 20),
          ],
          
          // Temperature Chart
          if (analysis.temperatureData.isNotEmpty) ...[
            BiometricChartWidget(
              title: 'Body Temperature',
              data: analysis.temperatureData,
              type: BiometricType.bodyTemperature,
              color: AppTheme.warningOrange,
            ),
            const SizedBox(height: 20),
          ],
          
          // HRV Chart
          if (analysis.hrvData.isNotEmpty) ...[
            BiometricChartWidget(
              title: 'Heart Rate Variability',
              data: analysis.hrvData,
              type: BiometricType.heartRateVariability,
              color: AppTheme.accentMint,
            ),
            const SizedBox(height: 20),
          ],
          
          // Stress Chart
          if (analysis.stressData.isNotEmpty) ...[
            BiometricChartWidget(
              title: 'Stress Level',
              data: analysis.stressData,
              type: BiometricType.stressLevel,
              color: AppTheme.warningOrange,
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildInsightsTab() {
    final analysis = _currentAnalysis!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Insights Header
          Text(
            'AI Health Insights',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Personalized insights based on your biometric patterns',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.mediumGrey,
            ),
          ),
          const SizedBox(height: 24),
          
          // Insights List
          if (analysis.insights.isNotEmpty) ...analysis.insights.map((insight) =>
            _buildInsightCard(insight),
          ) else
            _buildNoInsightsCard(),
          
          const SizedBox(height: 20),
          
          // Correlation Insights
          if (analysis.cycleCorrelations.isNotEmpty)
            CorrelationInsightsCard(
              correlations: analysis.cycleCorrelations,
              isPreview: false,
            ),
        ],
      ),
    );
  }
  
  Widget _buildSyncTab() {
    return Padding(padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Sync Status
          BiometricSyncStatus(),
          
          const SizedBox(height: 20),
          
          // Connected Devices (placeholder)
          _buildConnectedDevicesCard(),
          
          const SizedBox(height: 20),
          
          // Sync Settings
          _buildSyncSettingsCard(),
        ],
      ),
    );
  }
  
  // === HELPER WIDGETS ===
  
  Widget _buildHealthScoreCard(BiometricAnalysis analysis) {
    final score = analysis.overallHealthScore ?? 0.75;
    final scoreColor = score >= 0.8
        ? AppTheme.successGreen
        : score >= 0.6
            ? AppTheme.warningOrange
            : AppTheme.primaryRose;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scoreColor.withValues(alpha: 0.1), scoreColor.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: scoreColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${(score * 100).round()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Health Score',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getHealthScoreDescription(score),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mediumGrey,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: score,
                  backgroundColor: scoreColor.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0);
  }
  
  Widget _buildQuickMetricsGrid(BiometricAnalysis analysis) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        if (analysis.heartRateData.isNotEmpty)
          HealthMetricsCard(
            title: 'Avg Heart Rate',
            value: '${_getAverageValue(analysis.heartRateData).round()}',
            unit: 'BPM',
            icon: Icons.favorite,
            color: AppTheme.primaryRose,
            trend: _getTrend(analysis.heartRateData),
          ),
        
        if (analysis.sleepData.isNotEmpty)
          HealthMetricsCard(
            title: 'Sleep Quality',
            value: '${(_getAverageValue(analysis.sleepData) * 100).round()}',
            unit: '%',
            icon: Icons.bedtime,
            color: AppTheme.secondaryBlue,
            trend: _getTrend(analysis.sleepData),
          ),
        
        if (analysis.temperatureData.isNotEmpty)
          HealthMetricsCard(
            title: 'Body Temp',
            value: '${_getAverageValue(analysis.temperatureData).toStringAsFixed(1)}',
            unit: '°F',
            icon: Icons.thermostat,
            color: AppTheme.warningOrange,
            trend: _getTrend(analysis.temperatureData),
          ),
        
        if (analysis.stressData.isNotEmpty)
          HealthMetricsCard(
            title: 'Stress Level',
            value: '${_getAverageValue(analysis.stressData).toStringAsFixed(1)}',
            unit: '/10',
            icon: Icons.psychology,
            color: AppTheme.accentMint,
            trend: _getTrend(analysis.stressData),
          ),
      ],
    ).animate().fadeIn(delay: 700.ms);
  }
  
  Widget _buildRecentTrendsCard(BiometricAnalysis analysis) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: AppTheme.primaryRose,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Recent Trends',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Based on the last ${_selectedRange.duration.inDays} days of data',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.mediumGrey,
            ),
          ),
          const SizedBox(height: 16),
          // Trend items would go here
          _buildTrendItem('Sleep quality', 'Improving', Icons.trending_up, AppTheme.successGreen),
          _buildTrendItem('Stress levels', 'Stable', Icons.trending_flat, AppTheme.accentMint),
          _buildTrendItem('Heart rate', 'Slightly elevated', Icons.trending_up, AppTheme.warningOrange),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms);
  }
  
  Widget _buildTrendItem(String metric, String trend, IconData icon, Color color) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              metric,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            trend,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInsightCard(String insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.secondaryBlue, AppTheme.accentMint],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lightbulb,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              insight,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: AppTheme.darkGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoInsightsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.lightGrey),
      ),
      child: Column(
        children: [
          Icon(
            Icons.insights,
            size: 48,
            color: AppTheme.mediumGrey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Insights Available',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.mediumGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep tracking your health data to get personalized AI insights',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildConnectedDevicesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connected Devices',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGrey,
            ),
          ),
          const SizedBox(height: 16),
          _buildDeviceItem('iPhone Health', 'Connected', true),
          _buildDeviceItem('Apple Watch', 'Syncing', true),
          _buildDeviceItem('Garmin Connect', 'Not connected', false),
        ],
      ),
    );
  }
  
  Widget _buildDeviceItem(String name, String status, bool isConnected) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isConnected ? AppTheme.successGreen : AppTheme.mediumGrey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name)),
          Text(
            status,
            style: TextStyle(
              color: isConnected ? AppTheme.successGreen : AppTheme.mediumGrey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSyncSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sync Settings',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGrey,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Auto Sync'),
            subtitle: const Text('Automatically sync health data'),
            value: true,
            onChanged: (value) {},
            thumbColor: WidgetStateProperty.resolveWith((states) => 
              states.contains(WidgetState.selected) ? AppTheme.primaryRose : null),
            trackColor: WidgetStateProperty.resolveWith((states) => 
              states.contains(WidgetState.selected) ? AppTheme.primaryRose.withValues(alpha: 0.5) : null),
          ),
          SwitchListTile(
            title: const Text('Background Sync'),
            subtitle: const Text('Sync data in the background'),
            value: true,
            onChanged: (value) {},
            thumbColor: WidgetStateProperty.resolveWith((states) => 
              states.contains(WidgetState.selected) ? AppTheme.primaryRose : null),
            trackColor: WidgetStateProperty.resolveWith((states) => 
              states.contains(WidgetState.selected) ? AppTheme.primaryRose.withValues(alpha: 0.5) : null),
          ),
        ],
      ),
    );
  }
  
  // === STATE WIDGETS ===
  
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryRose),
          ).animate().rotate(),
          const SizedBox(height: 16),
          Text(
            'Loading biometric data...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.warningOrange,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Data',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGrey,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _errorMessage ?? 'An unexpected error occurred',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.mediumGrey,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _initializeBiometricDashboard,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.health_and_safety,
            size: 64,
            color: AppTheme.mediumGrey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Health Data',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.mediumGrey,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Connect your health devices to see biometric insights',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.mediumGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPermissionState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.health_and_safety_outlined,
            size: 64,
            color: AppTheme.warningOrange,
          ),
          const SizedBox(height: 16),
          Text(
            'Health Access Required',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGrey,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Please grant access to health data to view biometric insights',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.mediumGrey,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _initializeBiometricDashboard,
            child: const Text('Grant Access'),
          ),
        ],
      ),
    );
  }
  
  // === HELPER METHODS ===
  
  String _getHealthScoreDescription(double score) {
    if (score >= 0.9) return 'Excellent health metrics';
    if (score >= 0.8) return 'Very good health patterns';
    if (score >= 0.7) return 'Good overall health';
    if (score >= 0.6) return 'Moderate health indicators';
    return 'Focus on health improvement';
  }
  
  double _getAverageValue(List<BiometricReading> data) {
    if (data.isEmpty) return 0.0;
    return data.map((r) => r.value).reduce((a, b) => a + b) / data.length;
  }
  
  double _getTrend(List<BiometricReading> data) {
    if (data.length < 2) return 0.0;
    
    // Simple trend calculation: compare first half vs second half
    final midPoint = data.length ~/ 2;
    final firstHalf = data.take(midPoint);
    final secondHalf = data.skip(midPoint);
    
    final firstAvg = firstHalf.map((r) => r.value).reduce((a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.map((r) => r.value).reduce((a, b) => a + b) / secondHalf.length;
    
    return (secondAvg - firstAvg) / firstAvg;
  }
}
