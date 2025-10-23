import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../feelings/daily_feelings_tracker.dart';
import '../utils/app_logger.dart';
import '../utils/collection_extensions.dart';

/// 📊 Performance Analytics Dashboard
/// Comprehensive analytics and visualization dashboard for tracking user mood and wellness performance
/// Provides insights, trends, and interactive visualizations for both Flow AI and Flow iQ
class PerformanceAnalyticsDashboard {
  static final PerformanceAnalyticsDashboard _instance = PerformanceAnalyticsDashboard._internal();
  static PerformanceAnalyticsDashboard get instance => _instance;
  PerformanceAnalyticsDashboard._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Analytics engines
  late TrendAnalyticsEngine _trendEngine;
  late PerformanceMetricsCalculator _metricsCalculator;
  late InsightGenerator _insightGenerator;
  late VisualizationRenderer _visualRenderer;
  late ExportManager _exportManager;

  // Cache for performance
  final Map<String, CachedAnalytics> _analyticsCache = {};
  Timer? _cacheCleanupTimer;

  /// Initialize the performance analytics dashboard
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      AppLogger.success('📊 Initializing Performance Analytics Dashboard...');

      // Initialize analytics components
      _trendEngine = TrendAnalyticsEngine();
      _metricsCalculator = PerformanceMetricsCalculator();
      _insightGenerator = InsightGenerator();
      _visualRenderer = VisualizationRenderer();
      _exportManager = ExportManager();

      await Future.wait([
        _trendEngine.initialize(),
        _metricsCalculator.initialize(),
        _insightGenerator.initialize(),
        _visualRenderer.initialize(),
        _exportManager.initialize(),
      ]);

      // Setup cache cleanup
      _setupCacheCleanup();

      _isInitialized = true;
      AppLogger.success('✅ Performance Analytics Dashboard initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize Performance Analytics Dashboard: $e');
      rethrow;
    }
  }

  /// Generate comprehensive dashboard data
  Future<DashboardData> generateDashboard({
    required String userId,
    AnalyticsPeriod period = AnalyticsPeriod.month,
    bool isConsumerApp = true,
    bool useCache = true,
  }) async {
    if (!_isInitialized) await initialize();

    final cacheKey = '${userId}_${period.name}_${isConsumerApp ? 'consumer' : 'clinical'}';

    // Check cache first
    if (useCache && _analyticsCache.containsKey(cacheKey)) {
      final cached = _analyticsCache[cacheKey]!;
      if (DateTime.now().difference(cached.timestamp).inMinutes < 15) {
        AppLogger.analytics('📊 Using cached dashboard data for $userId');
        return cached.data;
      }
    }

    try {
      AppLogger.analytics('📊 Generating dashboard for user: $userId (${period.name})');

      // Get feelings data
      final feelingsTracker = DailyFeelingsTracker.instance;
      final daysBack = _getPeriodDays(period);
      
      final feelingsData = feelingsTracker.getFeelingsPattern(
        userId: userId,
        daysBack: daysBack,
        isConsumerApp: isConsumerApp,
      );

      // Get analytics report
      final analyticsReport = await feelingsTracker.getAnalyticsReport(
        userId: userId,
        daysBack: daysBack,
        isConsumerApp: isConsumerApp,
      );

      // Calculate performance metrics
      final performanceMetrics = await _metricsCalculator.calculateMetrics(
        feelingsData: feelingsData,
        period: period,
        isConsumerApp: isConsumerApp,
      );

      // Analyze trends
      final trendAnalysis = await _trendEngine.analyzeTrends(
        feelingsData: feelingsData,
        period: period,
      );

      // Generate insights
      final insights = await _insightGenerator.generateInsights(
        userId: userId,
        metrics: performanceMetrics,
        trends: trendAnalysis,
        isConsumerApp: isConsumerApp,
      );

      // Create visualization data
      final visualizations = await _visualRenderer.createVisualizations(
        feelingsData: feelingsData,
        metrics: performanceMetrics,
        trends: trendAnalysis,
      );

      // Create dashboard data
      final dashboardData = DashboardData(
        userId: userId,
        period: period,
        isConsumerApp: isConsumerApp,
        generatedAt: DateTime.now(),
        performanceMetrics: performanceMetrics,
        trendAnalysis: trendAnalysis,
        insights: insights,
        visualizations: visualizations,
        analyticsReport: analyticsReport,
        dataQuality: _assessDataQuality(feelingsData, daysBack),
      );

      // Cache the result
      if (useCache) {
        _analyticsCache[cacheKey] = CachedAnalytics(
          data: dashboardData,
          timestamp: DateTime.now(),
        );
      }

      AppLogger.success('✅ Generated dashboard with ${feelingsData.length} data points');
      return dashboardData;

    } catch (e) {
      AppLogger.error('Failed to generate dashboard: $e');
      rethrow;
    }
  }

  /// Create mood trend visualization widget
  Widget createMoodTrendChart({
    required String userId,
    AnalyticsPeriod period = AnalyticsPeriod.month,
    double height = 300,
    Color? accentColor,
  }) {
    return FutureBuilder<DashboardData>(
      future: generateDashboard(userId: userId, period: period),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingChart(height);
        }

        if (snapshot.hasError) {
          return _buildErrorChart(height, snapshot.error.toString());
        }

        final data = snapshot.data!;
        return _visualRenderer.buildMoodTrendChart(
          data: data.visualizations.moodTrendData,
          height: height,
          accentColor: accentColor ?? Theme.of(context).primaryColor,
        );
      },
    );
  }

  /// Create performance metrics widget
  Widget createPerformanceMetricsWidget({
    required String userId,
    AnalyticsPeriod period = AnalyticsPeriod.month,
    bool isConsumerApp = true,
  }) {
    return FutureBuilder<DashboardData>(
      future: generateDashboard(
        userId: userId,
        period: period,
        isConsumerApp: isConsumerApp,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        return PerformanceMetricsWidget(
          metrics: snapshot.data!.performanceMetrics,
          isConsumerApp: isConsumerApp,
        );
      },
    );
  }

  /// Create insights summary widget
  Widget createInsightsSummary({
    required String userId,
    AnalyticsPeriod period = AnalyticsPeriod.month,
    bool isConsumerApp = true,
    int maxInsights = 3,
  }) {
    return FutureBuilder<DashboardData>(
      future: generateDashboard(
        userId: userId,
        period: period,
        isConsumerApp: isConsumerApp,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Error loading insights: ${snapshot.error}');
        }

        return InsightsSummaryWidget(
          insights: snapshot.data!.insights.take(maxInsights).toList(),
          isConsumerApp: isConsumerApp,
        );
      },
    );
  }

  /// Export dashboard data
  Future<String> exportDashboardData({
    required String userId,
    AnalyticsPeriod period = AnalyticsPeriod.month,
    bool isConsumerApp = true,
    ExportFormat format = ExportFormat.json,
  }) async {
    if (!_isInitialized) await initialize();

    final dashboardData = await generateDashboard(
      userId: userId,
      period: period,
      isConsumerApp: isConsumerApp,
    );

    return await _exportManager.exportData(
      data: dashboardData,
      format: format,
    );
  }

  /// Get comparative analysis between periods
  Future<ComparativeAnalysis> getComparativeAnalysis({
    required String userId,
    required AnalyticsPeriod currentPeriod,
    required AnalyticsPeriod comparisonPeriod,
    bool isConsumerApp = true,
  }) async {
    if (!_isInitialized) await initialize();

    // Get data for both periods
    final currentData = await generateDashboard(
      userId: userId,
      period: currentPeriod,
      isConsumerApp: isConsumerApp,
    );

    // Calculate comparison period start date
    final currentDays = _getPeriodDays(currentPeriod);
    final comparisonDays = _getPeriodDays(comparisonPeriod);
    
    // Get historical data for comparison
    final feelingsTracker = DailyFeelingsTracker.instance;
    final comparisonFeelings = feelingsTracker.getHistoricalFeelings(
      userId: userId,
      startDate: DateTime.now().subtract(Duration(days: currentDays + comparisonDays)),
      endDate: DateTime.now().subtract(Duration(days: currentDays)),
      isConsumerApp: isConsumerApp,
    );

    // Convert to data points for analysis
    final comparisonDataPoints = <FeelingsDataPoint>[];
    final Map<String, List<int>> dailyScores = {};
    
    for (final feeling in comparisonFeelings) {
      final dateKey = '${feeling.timestamp.year}-${feeling.timestamp.month}-${feeling.timestamp.day}';
      dailyScores[dateKey] ??= [];
      dailyScores[dateKey]!.add(feeling.feelingScore);
    }

    for (final entry in dailyScores.entries) {
      final scores = entry.value;
      final averageScore = scores.reduce((a, b) => a + b) / scores.length;
      final dateParts = entry.key.split('-');
      final date = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );
      
      comparisonDataPoints.add(FeelingsDataPoint(
        date: date,
        score: averageScore,
        entryCount: scores.length,
      ));
    }

    // Calculate comparison metrics
    final comparisonMetrics = await _metricsCalculator.calculateMetrics(
      feelingsData: comparisonDataPoints,
      period: comparisonPeriod,
      isConsumerApp: isConsumerApp,
    );

    return ComparativeAnalysis(
      currentPeriod: currentPeriod,
      comparisonPeriod: comparisonPeriod,
      currentMetrics: currentData.performanceMetrics,
      comparisonMetrics: comparisonMetrics,
      improvements: _calculateImprovements(currentData.performanceMetrics, comparisonMetrics),
      insights: _generateComparisonInsights(currentData.performanceMetrics, comparisonMetrics, isConsumerApp),
    );
  }

  /// Clear analytics cache
  void clearCache({String? userId}) {
    if (userId != null) {
      _analyticsCache.removeWhere((key, value) => key.startsWith(userId));
    } else {
      _analyticsCache.clear();
    }
    AppLogger.success('🧹 Analytics cache cleared');
  }

  /// Get period days
  int _getPeriodDays(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.week:
        return 7;
      case AnalyticsPeriod.month:
        return 30;
      case AnalyticsPeriod.quarter:
        return 90;
      case AnalyticsPeriod.year:
        return 365;
    }
  }

  /// Assess data quality
  DataQualityScore _assessDataQuality(List<FeelingsDataPoint> data, int expectedDays) {
    final expectedEntries = expectedDays * 2; // Twice daily
    final actualEntries = data.fold<int>(0, (sum, point) => sum + point.entryCount);
    final completeness = actualEntries / expectedEntries;
    
    // Check data consistency
    final hasRecentData = data.any((point) => 
        DateTime.now().difference(point.date).inDays < 3);
    
    // Check for data gaps
    final sortedDates = data.map((d) => d.date).toList()..sort();
    int gapDays = 0;
    for (int i = 1; i < sortedDates.length; i++) {
      final gap = sortedDates[i].difference(sortedDates[i - 1]).inDays;
      if (gap > 2) gapDays += gap - 1;
    }

    final reliability = 1.0 - (gapDays / expectedDays);
    final overallScore = (completeness * 0.6 + reliability * 0.4).clamp(0.0, 1.0);

    return DataQualityScore(
      completeness: completeness,
      reliability: reliability,
      hasRecentData: hasRecentData,
      overallScore: overallScore,
      gapDays: gapDays,
      recommendation: _getDataQualityRecommendation(overallScore),
    );
  }

  String _getDataQualityRecommendation(double score) {
    if (score >= 0.8) return 'Excellent data quality - insights are highly reliable';
    if (score >= 0.6) return 'Good data quality - insights are mostly reliable';
    if (score >= 0.4) return 'Fair data quality - try to track more consistently';
    return 'Limited data - track more regularly for better insights';
  }

  /// Setup cache cleanup timer
  void _setupCacheCleanup() {
    _cacheCleanupTimer = Timer.periodic(const Duration(hours: 1), (_) {
      final now = DateTime.now();
      _analyticsCache.removeWhere((key, cached) =>
          now.difference(cached.timestamp).inHours > 2);
    });
  }

  /// Calculate improvements between periods
  Map<String, double> _calculateImprovements(
    PerformanceMetrics current,
    PerformanceMetrics comparison,
  ) {
    return {
      'averageMood': current.averageMood - comparison.averageMood,
      'consistency': current.consistencyScore - comparison.consistencyScore,
      'trendScore': current.trendScore - comparison.trendScore,
      'completionRate': current.completionRate - comparison.completionRate,
    };
  }

  /// Generate comparison insights
  List<String> _generateComparisonInsights(
    PerformanceMetrics current,
    PerformanceMetrics comparison,
    bool isConsumerApp,
  ) {
    final insights = <String>[];
    final moodImprovement = current.averageMood - comparison.averageMood;

    if (moodImprovement > 0.5) {
      insights.add(isConsumerApp 
          ? 'Great progress! Your mood has improved significantly 📈'
          : 'Patient shows significant mood improvement over time');
    } else if (moodImprovement < -0.5) {
      insights.add(isConsumerApp
          ? 'Let\'s focus on getting back to your positive patterns 💪'
          : 'Patient requires attention for declining mood trends');
    }

    final consistencyImprovement = current.consistencyScore - comparison.consistencyScore;
    if (consistencyImprovement > 0.1) {
      insights.add(isConsumerApp
          ? 'Your mood is becoming more stable - excellent progress! 🎯'
          : 'Patient demonstrates improved emotional stability');
    }

    final completionImprovement = current.completionRate - comparison.completionRate;
    if (completionImprovement > 0.1) {
      insights.add(isConsumerApp
          ? 'You\'re tracking more consistently - this will improve your insights! 📊'
          : 'Improved compliance with tracking protocol');
    }

    return insights;
  }

  /// Build loading chart widget
  Widget _buildLoadingChart(double height) {
    return SizedBox(
      height: height,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Build error chart widget
  Widget _buildErrorChart(double height, String error) {
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading chart',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Dispose resources
  void dispose() {
    _cacheCleanupTimer?.cancel();
    _analyticsCache.clear();
    
    _trendEngine.dispose();
    _metricsCalculator.dispose();
    _insightGenerator.dispose();
    _visualRenderer.dispose();
    _exportManager.dispose();
  }
}

// Analytics Engine Components

/// Trend Analytics Engine
class TrendAnalyticsEngine {
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    AppLogger.success('📈 Trend Analytics Engine initialized');
  }

  Future<TrendAnalysis> analyzeTrends({
    required List<FeelingsDataPoint> feelingsData,
    required AnalyticsPeriod period,
  }) async {
    if (feelingsData.isEmpty) return TrendAnalysis.empty();

    // Sort data by date
    final sortedData = feelingsData.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // Calculate trend metrics
    final overallTrend = _calculateOverallTrend(sortedData);
    final momentum = _calculateMomentum(sortedData);
    final volatility = _calculateVolatility(sortedData);
    final predictions = await _generatePredictions(sortedData);
    final patterns = _identifyPatterns(sortedData);

    return TrendAnalysis(
      overallTrend: overallTrend,
      momentum: momentum,
      volatility: volatility,
      predictions: predictions,
      patterns: patterns,
      confidence: _calculateConfidence(sortedData.length),
    );
  }

  TrendDirection _calculateOverallTrend(List<FeelingsDataPoint> data) {
    if (data.length < 4) return TrendDirection.stable;

    // Use linear regression approach
    final n = data.length;
    var sumX = 0.0, sumY = 0.0, sumXY = 0.0, sumX2 = 0.0;

    for (int i = 0; i < n; i++) {
      final x = i.toDouble();
      final y = data[i].score;
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);

    if (slope > 0.05) return TrendDirection.improving;
    if (slope < -0.05) return TrendDirection.declining;
    return TrendDirection.stable;
  }

  double _calculateMomentum(List<FeelingsDataPoint> data) {
    if (data.length < 7) return 0.0;

    final recent = data.takeLast(7);
    final earlier = data.length > 14 
        ? data.skip(data.length - 14).take(7)
        : data.take(7);

    final recentAvg = recent.map((d) => d.score).reduce((a, b) => a + b) / recent.length;
    final earlierAvg = earlier.map((d) => d.score).reduce((a, b) => a + b) / earlier.length;

    return recentAvg - earlierAvg;
  }

  double _calculateVolatility(List<FeelingsDataPoint> data) {
    if (data.length < 2) return 0.0;

    final scores = data.map((d) => d.score).toList();
    final mean = scores.reduce((a, b) => a + b) / scores.length;
    final variance = scores
        .map((score) => math.pow(score - mean, 2))
        .reduce((a, b) => a + b) / scores.length;

    return math.sqrt(variance);
  }

  Future<List<TrendPrediction>> _generatePredictions(List<FeelingsDataPoint> data) async {
    if (data.length < 7) return [];

    final predictions = <TrendPrediction>[];
    final recentTrend = _calculateOverallTrend(data.takeLast(14).toList());
    final momentum = _calculateMomentum(data);

    // Simple prediction logic (in production, use ML models)
    for (int days = 1; days <= 7; days++) {
      final baseScore = data.last.score;
      final predictedScore = (baseScore + (momentum * days * 0.1)).clamp(1.0, 10.0);
      
      predictions.add(TrendPrediction(
        date: DateTime.now().add(Duration(days: days)),
        predictedScore: predictedScore,
        confidence: _calculatePredictionConfidence(data.length, days),
        factors: ['Recent trend: ${recentTrend.name}', 'Momentum: ${momentum.toStringAsFixed(2)}'],
      ));
    }

    return predictions;
  }

  List<TrendPattern> _identifyPatterns(List<FeelingsDataPoint> data) {
    final patterns = <TrendPattern>[];

    // Weekly pattern
    final weeklyPattern = _analyzeWeeklyPattern(data);
    if (weeklyPattern != null) patterns.add(weeklyPattern);

    // Streak patterns
    final streakPatterns = _analyzeStreakPatterns(data);
    patterns.addAll(streakPatterns);

    return patterns;
  }

  TrendPattern? _analyzeWeeklyPattern(List<FeelingsDataPoint> data) {
    final weekdayScores = <int, List<double>>{};
    
    for (final point in data) {
      final weekday = point.date.weekday;
      weekdayScores[weekday] ??= [];
      weekdayScores[weekday]!.add(point.score);
    }

    if (weekdayScores.length < 7) return null;

    final weekdayAverages = <int, double>{};
    for (final entry in weekdayScores.entries) {
      weekdayAverages[entry.key] = 
          entry.value.reduce((a, b) => a + b) / entry.value.length;
    }

    // Find significant weekly patterns
    final maxScore = weekdayAverages.values.reduce(math.max);
    final minScore = weekdayAverages.values.reduce(math.min);
    
    if (maxScore - minScore > 1.0) {
      final bestDay = weekdayAverages.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      final worstDay = weekdayAverages.entries
          .reduce((a, b) => a.value < b.value ? a : b);

      return TrendPattern(
        type: PatternType.weekly,
        description: 'Weekly mood pattern detected',
        confidence: 0.8,
        details: {
          'bestDay': _getDayName(bestDay.key),
          'worstDay': _getDayName(worstDay.key),
          'difference': maxScore - minScore,
        },
      );
    }

    return null;
  }

  List<TrendPattern> _analyzeStreakPatterns(List<FeelingsDataPoint> data) {
    final patterns = <TrendPattern>[];
    
    // Find consecutive high/low periods
    int consecutiveHigh = 0;
    int consecutiveLow = 0;
    
    for (final point in data) {
      if (point.score >= 7.5) {
        consecutiveHigh++;
        consecutiveLow = 0;
      } else if (point.score <= 4.5) {
        consecutiveLow++;
        consecutiveHigh = 0;
      } else {
        if (consecutiveHigh >= 3) {
          patterns.add(TrendPattern(
            type: PatternType.streak,
            description: 'High mood streak detected',
            confidence: 0.9,
            details: {'length': consecutiveHigh, 'type': 'positive'},
          ));
        }
        if (consecutiveLow >= 3) {
          patterns.add(TrendPattern(
            type: PatternType.streak,
            description: 'Low mood streak detected',
            confidence: 0.9,
            details: {'length': consecutiveLow, 'type': 'negative'},
          ));
        }
        consecutiveHigh = 0;
        consecutiveLow = 0;
      }
    }

    return patterns;
  }

  double _calculateConfidence(int dataPoints) {
    if (dataPoints < 7) return 0.3;
    if (dataPoints < 30) return 0.7;
    return 0.9;
  }

  double _calculatePredictionConfidence(int dataPoints, int daysAhead) {
    final baseConfidence = _calculateConfidence(dataPoints);
    final decayFactor = math.pow(0.9, daysAhead);
    return (baseConfidence * decayFactor).clamp(0.1, 0.9);
  }

  String _getDayName(int weekday) {
    const days = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday];
  }

  void dispose() {
    // Cleanup if needed
  }
}

/// Performance Metrics Calculator
class PerformanceMetricsCalculator {
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    AppLogger.success('📊 Performance Metrics Calculator initialized');
  }

  Future<PerformanceMetrics> calculateMetrics({
    required List<FeelingsDataPoint> feelingsData,
    required AnalyticsPeriod period,
    required bool isConsumerApp,
  }) async {
    if (feelingsData.isEmpty) {
      return PerformanceMetrics.empty();
    }

    final scores = feelingsData.map((d) => d.score).toList();
    
    // Basic metrics
    final averageMood = scores.reduce((a, b) => a + b) / scores.length;
    final highestMood = scores.reduce(math.max);
    final lowestMood = scores.reduce(math.min);
    
    // Advanced metrics
    final consistencyScore = _calculateConsistencyScore(scores);
    final trendScore = _calculateTrendScore(feelingsData);
    final volatilityScore = _calculateVolatilityScore(scores);
    final completionRate = _calculateCompletionRate(feelingsData, period);
    final improvementRate = _calculateImprovementRate(feelingsData);
    
    // Wellness metrics
    final wellnessScore = _calculateWellnessScore(
      averageMood: averageMood,
      consistency: consistencyScore,
      trend: trendScore,
      isConsumerApp: isConsumerApp,
    );

    return PerformanceMetrics(
      averageMood: averageMood,
      highestMood: highestMood,
      lowestMood: lowestMood,
      consistencyScore: consistencyScore,
      trendScore: trendScore,
      volatilityScore: volatilityScore,
      completionRate: completionRate,
      improvementRate: improvementRate,
      wellnessScore: wellnessScore,
      totalEntries: feelingsData.fold<int>(0, (sum, point) => sum + point.entryCount),
      periodDays: _getPeriodDays(period),
      calculatedAt: DateTime.now(),
    );
  }

  double _calculateConsistencyScore(List<double> scores) {
    if (scores.length < 2) return 0.0;
    
    final mean = scores.reduce((a, b) => a + b) / scores.length;
    final variance = scores
        .map((score) => math.pow(score - mean, 2))
        .reduce((a, b) => a + b) / scores.length;
    
    final standardDeviation = math.sqrt(variance);
    
    // Convert to consistency score (lower deviation = higher consistency)
    return (1.0 - (standardDeviation / 10.0)).clamp(0.0, 1.0);
  }

  double _calculateTrendScore(List<FeelingsDataPoint> data) {
    if (data.length < 4) return 0.5; // Neutral score
    
    final sortedData = data.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    
    // Calculate slope using linear regression
    final n = sortedData.length;
    var sumX = 0.0, sumY = 0.0, sumXY = 0.0, sumX2 = 0.0;

    for (int i = 0; i < n; i++) {
      final x = i.toDouble();
      final y = sortedData[i].score;
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    
    // Convert slope to 0-1 score (0.5 = stable, >0.5 = improving, <0.5 = declining)
    return (0.5 + slope * 0.1).clamp(0.0, 1.0);
  }

  double _calculateVolatilityScore(List<double> scores) {
    if (scores.length < 2) return 0.0;
    
    // Calculate day-to-day changes
    final changes = <double>[];
    for (int i = 1; i < scores.length; i++) {
      changes.add((scores[i] - scores[i - 1]).abs());
    }
    
    final averageChange = changes.reduce((a, b) => a + b) / changes.length;
    
    // Convert to volatility score (lower change = lower volatility)
    return (averageChange / 10.0).clamp(0.0, 1.0);
  }

  double _calculateCompletionRate(List<FeelingsDataPoint> data, AnalyticsPeriod period) {
    final periodDays = _getPeriodDays(period);
    final expectedEntries = periodDays * 2; // Twice daily
    final actualEntries = data.fold<int>(0, (sum, point) => sum + point.entryCount);
    
    return (actualEntries / expectedEntries).clamp(0.0, 1.0);
  }

  double _calculateImprovementRate(List<FeelingsDataPoint> data) {
    if (data.length < 7) return 0.0;
    
    final sortedData = data.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    
    // Compare recent vs earlier periods
    final halfPoint = sortedData.length ~/ 2;
    final earlier = sortedData.take(halfPoint);
    final recent = sortedData.skip(halfPoint);
    
    if (earlier.isEmpty || recent.isEmpty) return 0.0;
    
    final earlierAvg = earlier.map((d) => d.score).reduce((a, b) => a + b) / earlier.length;
    final recentAvg = recent.map((d) => d.score).reduce((a, b) => a + b) / recent.length;
    
    return ((recentAvg - earlierAvg) / 10.0).clamp(-1.0, 1.0);
  }

  double _calculateWellnessScore({
    required double averageMood,
    required double consistency,
    required double trend,
    required bool isConsumerApp,
  }) {
    // Weighted wellness score
    const moodWeight = 0.4;
    const consistencyWeight = 0.3;
    const trendWeight = 0.3;
    
    final normalizedMood = averageMood / 10.0; // Convert to 0-1 scale
    
    final wellnessScore = (normalizedMood * moodWeight) +
                         (consistency * consistencyWeight) +
                         (trend * trendWeight);
    
    return wellnessScore.clamp(0.0, 1.0);
  }

  int _getPeriodDays(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.week:
        return 7;
      case AnalyticsPeriod.month:
        return 30;
      case AnalyticsPeriod.quarter:
        return 90;
      case AnalyticsPeriod.year:
        return 365;
    }
  }

  void dispose() {
    // Cleanup if needed
  }
}

/// Visualization Renderer
class VisualizationRenderer {
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    AppLogger.success('🎨 Visualization Renderer initialized');
  }

  Future<VisualizationData> createVisualizations({
    required List<FeelingsDataPoint> feelingsData,
    required PerformanceMetrics metrics,
    required TrendAnalysis trends,
  }) async {
    return VisualizationData(
      moodTrendData: _createMoodTrendData(feelingsData),
      performanceRadarData: _createPerformanceRadarData(metrics),
      weeklyPatternData: _createWeeklyPatternData(feelingsData),
      distributionData: _createDistributionData(feelingsData),
      comparisonData: _createComparisonData(metrics),
    );
  }

  Widget buildMoodTrendChart({
    required MoodTrendChartData data,
    required double height,
    required Color accentColor,
  }) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size(double.infinity, height),
        painter: MoodTrendChartPainter(
          data: data,
          accentColor: accentColor,
        ),
      ),
    );
  }

  MoodTrendChartData _createMoodTrendData(List<FeelingsDataPoint> data) {
    final sortedData = data.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return MoodTrendChartData(
      dataPoints: sortedData.map((point) => ChartDataPoint(
        date: point.date,
        value: point.score,
        label: point.score.toStringAsFixed(1),
      )).toList(),
      minValue: 1.0,
      maxValue: 10.0,
      averageLine: data.isEmpty ? 5.0 : data.map((d) => d.score).reduce((a, b) => a + b) / data.length,
    );
  }

  RadarChartData _createPerformanceRadarData(PerformanceMetrics metrics) {
    return RadarChartData(
      categories: [
        'Average Mood',
        'Consistency',
        'Trend',
        'Completion',
        'Wellness',
      ],
      values: [
        metrics.averageMood / 10.0,
        metrics.consistencyScore,
        metrics.trendScore,
        metrics.completionRate,
        metrics.wellnessScore,
      ],
    );
  }

  WeeklyPatternData _createWeeklyPatternData(List<FeelingsDataPoint> data) {
    final weekdayScores = <int, List<double>>{};
    
    for (final point in data) {
      final weekday = point.date.weekday;
      weekdayScores[weekday] ??= [];
      weekdayScores[weekday]!.add(point.score);
    }

    final weekdayAverages = <int, double>{};
    for (final entry in weekdayScores.entries) {
      weekdayAverages[entry.key] = 
          entry.value.reduce((a, b) => a + b) / entry.value.length;
    }

    return WeeklyPatternData(
      weekdayAverages: weekdayAverages,
      weekdayNames: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    );
  }

  DistributionData _createDistributionData(List<FeelingsDataPoint> data) {
    final scores = data.map((d) => d.score).toList();
    final buckets = <int, int>{};
    
    for (final score in scores) {
      final bucket = score.floor();
      buckets[bucket] = (buckets[bucket] ?? 0) + 1;
    }

    return DistributionData(
      buckets: buckets,
      totalCount: scores.length,
    );
  }

  ComparisonData _createComparisonData(PerformanceMetrics metrics) {
    return ComparisonData(
      currentPeriodMetrics: [
        metrics.averageMood / 10.0,
        metrics.consistencyScore,
        metrics.wellnessScore,
      ],
      labels: ['Mood', 'Consistency', 'Wellness'],
    );
  }

  void dispose() {
    // Cleanup if needed
  }
}

/// Insight Generator
class InsightGenerator {
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    AppLogger.success('💡 Insight Generator initialized');
  }

  Future<List<DashboardInsight>> generateInsights({
    required String userId,
    required PerformanceMetrics metrics,
    required TrendAnalysis trends,
    required bool isConsumerApp,
  }) async {
    final insights = <DashboardInsight>[];
    final now = DateTime.now();

    // Mood-based insights
    if (metrics.averageMood >= 8.0) {
      insights.add(DashboardInsight(
        type: InsightType.positive,
        message: isConsumerApp
            ? 'Excellent mood patterns! You\'re thriving 🌟'
            : 'Patient demonstrates consistently positive mood patterns',
        importance: 0.8,
        generatedAt: now,
      ));
    } else if (metrics.averageMood <= 4.0) {
      insights.add(DashboardInsight(
        type: InsightType.attention,
        message: isConsumerApp
            ? 'Your mood has been lower lately. Consider reaching out for support 💙'
            : 'Patient shows concerning mood patterns requiring attention',
        importance: 0.9,
        generatedAt: now,
      ));
    }

    // Trend-based insights
    if (trends.overallTrend == TrendDirection.improving) {
      insights.add(DashboardInsight(
        type: InsightType.positive,
        message: isConsumerApp
            ? 'Great progress! Your mood is on an upward trend 📈'
            : 'Patient shows positive mood improvement trend',
        importance: 0.7,
        generatedAt: now,
      ));
    } else if (trends.overallTrend == TrendDirection.declining) {
      insights.add(DashboardInsight(
        type: InsightType.attention,
        message: isConsumerApp
            ? 'Let\'s focus on reversing this downward trend together 💪'
            : 'Declining mood trend detected - intervention recommended',
        importance: 0.8,
        generatedAt: now,
      ));
    }

    // Consistency insights
    if (metrics.consistencyScore >= 0.8) {
      insights.add(DashboardInsight(
        type: InsightType.positive,
        message: isConsumerApp
            ? 'Your mood stability is excellent - keep it up! 🎯'
            : 'Patient demonstrates excellent mood stability',
        importance: 0.6,
        generatedAt: now,
      ));
    } else if (metrics.consistencyScore <= 0.4) {
      insights.add(DashboardInsight(
        type: InsightType.recommendation,
        message: isConsumerApp
            ? 'Try establishing more consistent daily routines for better mood stability'
            : 'Consider interventions to improve mood consistency',
        importance: 0.7,
        generatedAt: now,
      ));
    }

    // Completion rate insights
    if (metrics.completionRate >= 0.9) {
      insights.add(DashboardInsight(
        type: InsightType.positive,
        message: isConsumerApp
            ? 'Fantastic tracking consistency! This helps provide better insights 📊'
            : 'Excellent tracking compliance - data quality is high',
        importance: 0.5,
        generatedAt: now,
      ));
    } else if (metrics.completionRate <= 0.3) {
      insights.add(DashboardInsight(
        type: InsightType.recommendation,
        message: isConsumerApp
            ? 'More frequent check-ins will help us understand your patterns better'
            : 'Improve tracking compliance for better clinical insights',
        importance: 0.6,
        generatedAt: now,
      ));
    }

    // Pattern-based insights
    for (final pattern in trends.patterns) {
      if (pattern.type == PatternType.weekly) {
        final bestDay = pattern.details['bestDay'] as String?;
        final worstDay = pattern.details['worstDay'] as String?;
        
        if (bestDay != null && worstDay != null) {
          insights.add(DashboardInsight(
            type: InsightType.neutral,
            message: isConsumerApp
                ? 'You tend to feel best on $bestDay and lowest on $worstDay'
                : 'Weekly pattern detected: Best day $bestDay, challenging day $worstDay',
            importance: 0.5,
            generatedAt: now,
          ));
        }
      }
    }

    // Sort by importance and return top insights
    insights.sort((a, b) => b.importance.compareTo(a.importance));
    return insights.take(5).toList();
  }

  void dispose() {
    // Cleanup if needed
  }
}

/// Export Manager
class ExportManager {
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    AppLogger.success('📤 Export Manager initialized');
  }

  Future<String> exportData({
    required DashboardData data,
    required ExportFormat format,
  }) async {
    switch (format) {
      case ExportFormat.json:
        return _exportAsJson(data);
      case ExportFormat.csv:
        return _exportAsCsv(data);
      case ExportFormat.pdf:
        return _exportAsPdf(data);
    }
  }

  String _exportAsJson(DashboardData data) {
    // Implementation would create JSON export
    return 'JSON export for ${data.userId}';
  }

  String _exportAsCsv(DashboardData data) {
    // Implementation would create CSV export
    return 'CSV export for ${data.userId}';
  }

  String _exportAsPdf(DashboardData data) {
    // Implementation would create PDF export
    return 'PDF export for ${data.userId}';
  }

  void dispose() {
    // Cleanup if needed
  }
}

// Custom Widgets

/// Performance Metrics Widget
class PerformanceMetricsWidget extends StatelessWidget {
  final PerformanceMetrics metrics;
  final bool isConsumerApp;

  const PerformanceMetricsWidget({
    super.key,
    required this.metrics,
    required this.isConsumerApp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isConsumerApp ? 'Your Wellness Metrics' : 'Patient Metrics',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildMetricRow('Average Mood', '${metrics.averageMood.toStringAsFixed(1)}/10'),
            _buildMetricRow('Consistency', '${(metrics.consistencyScore * 100).toStringAsFixed(0)}%'),
            _buildMetricRow('Wellness Score', '${(metrics.wellnessScore * 100).toStringAsFixed(0)}%'),
            _buildMetricRow('Completion Rate', '${(metrics.completionRate * 100).toStringAsFixed(0)}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

/// Insights Summary Widget
class InsightsSummaryWidget extends StatelessWidget {
  final List<DashboardInsight> insights;
  final bool isConsumerApp;

  const InsightsSummaryWidget({
    super.key,
    required this.insights,
    required this.isConsumerApp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isConsumerApp ? 'Your Insights' : 'Patient Insights',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...insights.map((insight) => _buildInsightTile(insight)),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightTile(DashboardInsight insight) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_getInsightIcon(insight.type), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(insight.message),
          ),
        ],
      ),
    );
  }

  IconData _getInsightIcon(InsightType type) {
    switch (type) {
      case InsightType.positive:
        return Icons.trending_up;
      case InsightType.neutral:
        return Icons.info_outline;
      case InsightType.attention:
        return Icons.warning_outlined;
      case InsightType.recommendation:
        return Icons.lightbulb_outline;
    }
  }
}

/// Mood Trend Chart Painter
class MoodTrendChartPainter extends CustomPainter {
  final MoodTrendChartData data;
  final Color accentColor;

  MoodTrendChartPainter({
    required this.data,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.dataPoints.isEmpty) return;

    final paint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    final stepX = size.width / (data.dataPoints.length - 1);
    final valueRange = data.maxValue - data.minValue;

    // Draw trend line
    for (int i = 0; i < data.dataPoints.length; i++) {
      final x = i * stepX;
      final normalizedValue = (data.dataPoints[i].value - data.minValue) / valueRange;
      final y = size.height - (normalizedValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Draw data points
      canvas.drawCircle(Offset(x, y), 4, 
          Paint()..color = accentColor..style = PaintingStyle.fill);
    }

    canvas.drawPath(path, paint);

    // Draw average line
    final avgY = size.height - ((data.averageLine - data.minValue) / valueRange * size.height);
    final avgPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(0, avgY), Offset(size.width, avgY), avgPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Data Models

/// Dashboard Data Model
class DashboardData {
  final String userId;
  final AnalyticsPeriod period;
  final bool isConsumerApp;
  final DateTime generatedAt;
  final PerformanceMetrics performanceMetrics;
  final TrendAnalysis trendAnalysis;
  final List<DashboardInsight> insights;
  final VisualizationData visualizations;
  final FeelingsAnalyticsReport analyticsReport;
  final DataQualityScore dataQuality;

  DashboardData({
    required this.userId,
    required this.period,
    required this.isConsumerApp,
    required this.generatedAt,
    required this.performanceMetrics,
    required this.trendAnalysis,
    required this.insights,
    required this.visualizations,
    required this.analyticsReport,
    required this.dataQuality,
  });
}

/// Performance Metrics Model
class PerformanceMetrics {
  final double averageMood;
  final double highestMood;
  final double lowestMood;
  final double consistencyScore;
  final double trendScore;
  final double volatilityScore;
  final double completionRate;
  final double improvementRate;
  final double wellnessScore;
  final int totalEntries;
  final int periodDays;
  final DateTime calculatedAt;

  PerformanceMetrics({
    required this.averageMood,
    required this.highestMood,
    required this.lowestMood,
    required this.consistencyScore,
    required this.trendScore,
    required this.volatilityScore,
    required this.completionRate,
    required this.improvementRate,
    required this.wellnessScore,
    required this.totalEntries,
    required this.periodDays,
    required this.calculatedAt,
  });

  static PerformanceMetrics empty() {
    return PerformanceMetrics(
      averageMood: 0.0,
      highestMood: 0.0,
      lowestMood: 0.0,
      consistencyScore: 0.0,
      trendScore: 0.5,
      volatilityScore: 0.0,
      completionRate: 0.0,
      improvementRate: 0.0,
      wellnessScore: 0.0,
      totalEntries: 0,
      periodDays: 0,
      calculatedAt: DateTime.now(),
    );
  }
}

/// Trend Analysis Model
class TrendAnalysis {
  final TrendDirection overallTrend;
  final double momentum;
  final double volatility;
  final List<TrendPrediction> predictions;
  final List<TrendPattern> patterns;
  final double confidence;

  TrendAnalysis({
    required this.overallTrend,
    required this.momentum,
    required this.volatility,
    required this.predictions,
    required this.patterns,
    required this.confidence,
  });

  static TrendAnalysis empty() {
    return TrendAnalysis(
      overallTrend: TrendDirection.stable,
      momentum: 0.0,
      volatility: 0.0,
      predictions: [],
      patterns: [],
      confidence: 0.0,
    );
  }
}

/// Other supporting models would go here...
class TrendPrediction {
  final DateTime date;
  final double predictedScore;
  final double confidence;
  final List<String> factors;

  TrendPrediction({
    required this.date,
    required this.predictedScore,
    required this.confidence,
    required this.factors,
  });
}

class TrendPattern {
  final PatternType type;
  final String description;
  final double confidence;
  final Map<String, dynamic> details;

  TrendPattern({
    required this.type,
    required this.description,
    required this.confidence,
    required this.details,
  });
}

class DashboardInsight {
  final InsightType type;
  final String message;
  final double importance;
  final DateTime generatedAt;

  DashboardInsight({
    required this.type,
    required this.message,
    required this.importance,
    required this.generatedAt,
  });
}

class VisualizationData {
  final MoodTrendChartData moodTrendData;
  final RadarChartData performanceRadarData;
  final WeeklyPatternData weeklyPatternData;
  final DistributionData distributionData;
  final ComparisonData comparisonData;

  VisualizationData({
    required this.moodTrendData,
    required this.performanceRadarData,
    required this.weeklyPatternData,
    required this.distributionData,
    required this.comparisonData,
  });
}

class MoodTrendChartData {
  final List<ChartDataPoint> dataPoints;
  final double minValue;
  final double maxValue;
  final double averageLine;

  MoodTrendChartData({
    required this.dataPoints,
    required this.minValue,
    required this.maxValue,
    required this.averageLine,
  });
}

class ChartDataPoint {
  final DateTime date;
  final double value;
  final String label;

  ChartDataPoint({
    required this.date,
    required this.value,
    required this.label,
  });
}

class RadarChartData {
  final List<String> categories;
  final List<double> values;

  RadarChartData({
    required this.categories,
    required this.values,
  });
}

class WeeklyPatternData {
  final Map<int, double> weekdayAverages;
  final List<String> weekdayNames;

  WeeklyPatternData({
    required this.weekdayAverages,
    required this.weekdayNames,
  });
}

class DistributionData {
  final Map<int, int> buckets;
  final int totalCount;

  DistributionData({
    required this.buckets,
    required this.totalCount,
  });
}

class ComparisonData {
  final List<double> currentPeriodMetrics;
  final List<String> labels;

  ComparisonData({
    required this.currentPeriodMetrics,
    required this.labels,
  });
}

class ComparativeAnalysis {
  final AnalyticsPeriod currentPeriod;
  final AnalyticsPeriod comparisonPeriod;
  final PerformanceMetrics currentMetrics;
  final PerformanceMetrics comparisonMetrics;
  final Map<String, double> improvements;
  final List<String> insights;

  ComparativeAnalysis({
    required this.currentPeriod,
    required this.comparisonPeriod,
    required this.currentMetrics,
    required this.comparisonMetrics,
    required this.improvements,
    required this.insights,
  });
}

class DataQualityScore {
  final double completeness;
  final double reliability;
  final bool hasRecentData;
  final double overallScore;
  final int gapDays;
  final String recommendation;

  DataQualityScore({
    required this.completeness,
    required this.reliability,
    required this.hasRecentData,
    required this.overallScore,
    required this.gapDays,
    required this.recommendation,
  });
}

class CachedAnalytics {
  final DashboardData data;
  final DateTime timestamp;

  CachedAnalytics({
    required this.data,
    required this.timestamp,
  });
}

// Enums

enum AnalyticsPeriod {
  week,
  month,
  quarter,
  year,
}

enum TrendDirection {
  improving,
  stable,
  declining,
}

enum PatternType {
  weekly,
  streak,
  seasonal,
  cyclical,
}

enum InsightType {
  positive,
  neutral,
  attention,
  recommendation,
}

enum ExportFormat {
  json,
  csv,
  pdf,
}
