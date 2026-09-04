import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/models/cycle_data.dart';
import '../../../core/database/database_service.dart';
import '../../../core/analytics/statistics.dart';

import '../models/visualization_models.dart';
import '../../tracking/services/feelings_database_service.dart';
import '../../../core/services/advanced_biometric_service.dart'
    as canonical_health;
import '../../tracking/screens/enhanced_daily_feelings_tracker.dart'
    show MoodCategory;

/// Advanced visualization service for interactive charts and data presentation
class AdvancedVisualizationService {
  static AdvancedVisualizationService? _instance;
  static AdvancedVisualizationService get instance {
    _instance ??= AdvancedVisualizationService._internal();
    return _instance!;
  }

  AdvancedVisualizationService._internal();

  bool _isInitialized = false;
  late ThemeData _currentTheme;
  final Map<String, ChartConfiguration> _chartConfigurations = {};
  final Map<String, dynamic> _cachedData = {};

  /// Initialize the visualization service
  Future<void> initialize({ThemeData? theme}) async {
    if (_isInitialized) return;

    try {
      _currentTheme = theme ?? ThemeData.light();
      _setupDefaultConfigurations();

      _isInitialized = true;
      debugPrint('📊 Advanced visualization service initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize visualization service: $e');
      throw VisualizationException(
        'Failed to initialize visualization service: $e',
      );
    }
  }

  /// Update theme for visualizations
  void updateTheme(ThemeData theme) {
    _currentTheme = theme;
    _updateChartThemes();
  }

  /// Generate mood trend chart data
  Future<ChartData> generateMoodTrendChart({
    required String userId,
    required DateRange dateRange,
    ChartType chartType = ChartType.lineChart,
    String? moodCategory,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      // Get mood data from database
      final entries = await FeelingsDatabaseService.instance.getEntriesInRange(
        startDate: dateRange.start,
        endDate: dateRange.end,
        userId: userId,
      );

      if (entries.isEmpty) {
        return ChartData.empty(ChartType.lineChart, 'No mood data available');
      }

      // Process data for visualization
      final List<DataPoint> dataPoints = [];

      for (final entry in entries) {
        if (moodCategory != null) {
          // Specific mood category
          final categoryEnum = MoodCategory.values.firstWhere(
            (e) => e.name == moodCategory,
            orElse: () => MoodCategory.happiness,
          );

          final double? value = entry.moodScores[categoryEnum];
          if (value != null) {
            dataPoints.add(
              DataPoint(
                x: entry.date.millisecondsSinceEpoch.toDouble(),
                y: value,
                label: entry.date.toString().split(' ')[0],
                metadata: {'mood_category': moodCategory},
              ),
            );
          }
        } else {
          // Overall wellbeing
          dataPoints.add(
            DataPoint(
              x: entry.date.millisecondsSinceEpoch.toDouble(),
              y: entry.overallWellbeing,
              label: entry.date.toString().split(' ')[0],
              metadata: {'type': 'wellbeing'},
            ),
          );
        }
      }

      // Sort by date
      dataPoints.sort((a, b) => a.x.compareTo(b.x));

      // Create series
      final series = ChartSeries(
        name: moodCategory != null
            ? 'Mood: ${moodCategory.replaceAll('_', ' ').toUpperCase()}'
            : 'Overall Wellbeing',
        data: dataPoints,
        color: _getMoodCategoryColor(moodCategory),
        style: ChartSeriesStyle(
          strokeWidth: 2.0,
          showPoints: true,
          pointRadius: 4.0,
          fillOpacity: chartType == ChartType.areaChart ? 0.3 : 0.0,
        ),
      );

      return ChartData(
        type: chartType,
        title: 'Mood Trends',
        subtitle: _formatDateRange(dateRange),
        series: [series],
        xAxisConfig: AxisConfiguration(
          title: 'Date',
          type: AxisType.datetime,
          showGridLines: true,
        ),
        yAxisConfig: AxisConfiguration(
          title: 'Score (1-10)',
          type: AxisType.numeric,
          minimum: 1,
          maximum: 10,
          showGridLines: true,
        ),
        legend: ChartLegend(show: true, position: LegendPosition.bottom),
        interactivity: ChartInteractivity(
          enableZoom: true,
          enablePan: true,
          showTooltips: true,
          enableSelection: true,
        ),
      );
    } catch (e) {
      debugPrint('❌ Failed to generate mood trend chart: $e');
      return ChartData.error('Failed to load mood data');
    }
  }

  /// Generate cycle pattern visualization
  Future<ChartData> generateCyclePatternChart({
    required String userId,
    required DateRange dateRange,
    bool showPredictions = true,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      // Mock cycle data - in a real app, this would come from cycle tracking service
      final cycles = await DatabaseService.instance.getCyclesByDateRange(
        dateRange.start,
        dateRange.end,
      );
      final currentCycle = await DatabaseService.instance.getCurrentCycle();

      if (cycles.isEmpty && currentCycle == null) {
        return ChartData.error('No cycle data available');
      }

      final cycleData = _buildCycleDataPoints(cycles, dateRange);
      final predictionData = showPredictions
          ? _buildPredictionData(currentCycle)
          : <DataPoint>[];

      final List<ChartSeries> series = [
        ChartSeries(
          name: 'Cycle Events',
          data: cycleData,
          color: Colors.red,
          style: ChartSeriesStyle(
            strokeWidth: 3.0,
            showPoints: true,
            pointRadius: 6.0,
            pointShape: PointShape.circle,
          ),
        ),
      ];

      if (predictionData.isNotEmpty) {
        series.add(
          ChartSeries(
            name: 'Predictions',
            data: predictionData,
            color: Colors.red.withValues(alpha: 0.1),
            style: ChartSeriesStyle(
              strokeWidth: 2.0,
              strokeDashPattern: [5, 5],
              showPoints: true,
              pointRadius: 4.0,
              pointShape: PointShape.diamond,
            ),
          ),
        );
      }

      return ChartData(
        type: ChartType.lineChart,
        title: 'Cycle Pattern',
        subtitle: _formatDateRange(dateRange),
        series: series,
        xAxisConfig: AxisConfiguration(
          title: 'Date',
          type: AxisType.datetime,
          showGridLines: true,
        ),
        yAxisConfig: AxisConfiguration(
          title: 'Cycle Events',
          type: AxisType.categorical,
          categories: ['Flow', 'Ovulation', 'PMS'],
          showGridLines: false,
        ),
        annotations: _generateCycleAnnotations(dateRange),
        legend: ChartLegend(show: true),
        interactivity: ChartInteractivity(
          enableZoom: true,
          enablePan: true,
          showTooltips: true,
        ),
      );
    } catch (e) {
      debugPrint('❌ Failed to generate cycle pattern chart: $e');
      return ChartData.error('Failed to load cycle data');
    }
  }

  /// Generate symptom correlation heatmap
  Future<ChartData> generateSymptomCorrelationHeatmap({
    required String userId,
    required DateRange dateRange,
    List<String>? symptomFilter,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      final entries = await FeelingsDatabaseService.instance.getEntriesInRange(
        startDate: dateRange.start,
        endDate: dateRange.end,
        userId: userId,
      );

      final correlationMatrix = _calculateSymptomCorrelationMatrix(
        entries: entries,
        symptomFilter: symptomFilter,
      );

      if (correlationMatrix.isEmpty) {
        return ChartData.empty(
          ChartType.heatmap,
          'Not enough real symptom history to calculate correlations',
        );
      }

      final List<DataPoint> heatmapData = [];
      int xIndex = 0;

      for (final xSymptom in correlationMatrix.keys) {
        int yIndex = 0;
        for (final ySymptom in correlationMatrix[xSymptom]!.keys) {
          heatmapData.add(
            DataPoint(
              x: xIndex.toDouble(),
              y: yIndex.toDouble(),
              z: correlationMatrix[xSymptom]![ySymptom]!,
              label: '$xSymptom vs $ySymptom',
              metadata: {
                'x_symptom': xSymptom,
                'y_symptom': ySymptom,
                'correlation': correlationMatrix[xSymptom]![ySymptom]!,
              },
            ),
          );
          yIndex++;
        }
        xIndex++;
      }

      final series = ChartSeries(
        name: 'Symptom Correlations',
        data: heatmapData,
        color: Colors.blue,
        style: ChartSeriesStyle(
          heatmapColorScheme: [
            Colors.blue.withValues(alpha: 0.1),
            Colors.blue,
            Colors.red,
          ],
        ),
      );

      return ChartData(
        type: ChartType.heatmap,
        title: 'Symptom Correlations',
        subtitle: 'Correlation strength between symptoms',
        series: [series],
        xAxisConfig: AxisConfiguration(
          title: 'Symptoms',
          type: AxisType.categorical,
          categories: correlationMatrix.keys.toList(),
        ),
        yAxisConfig: AxisConfiguration(
          title: 'Symptoms',
          type: AxisType.categorical,
          categories: correlationMatrix.keys.toList(),
        ),
        legend: ChartLegend(
          show: true,
          position: LegendPosition.right,
          showColorScale: true,
        ),
        interactivity: ChartInteractivity(
          showTooltips: true,
          enableSelection: true,
        ),
      );
    } catch (e) {
      debugPrint('❌ Failed to generate symptom correlation heatmap: $e');
      return ChartData.error('Failed to load symptom correlation data');
    }
  }

  /// Generate multi-metric dashboard
  Future<List<ChartData>> generateHealthDashboard({
    required String userId,
    required DateRange dateRange,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      final List<ChartData> charts = [];

      // 1. Mood trend chart
      charts.add(
        await generateMoodTrendChart(
          userId: userId,
          dateRange: dateRange,
          chartType: ChartType.areaChart,
        ),
      );

      // 2. Sleep quality chart
      charts.add(await _generateSleepQualityChart(userId, dateRange));

      // 3. Activity level chart
      charts.add(await _generateActivityLevelChart(userId, dateRange));

      // 4. Symptom frequency chart
      charts.add(await _generateSymptomFrequencyChart(userId, dateRange));

      return charts;
    } catch (e) {
      debugPrint('❌ Failed to generate health dashboard: $e');
      return [ChartData.error('Failed to load dashboard data')];
    }
  }

  /// Generate custom visualization
  Future<ChartData> generateCustomVisualization({
    required VisualizationConfig config,
    required Map<String, dynamic> data,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      // Process custom data based on configuration
      final List<DataPoint> processedData = _processCustomData(data, config);

      final series = ChartSeries(
        name: config.title,
        data: processedData,
        color: config.primaryColor ?? _currentTheme.primaryColor,
        style: config.seriesStyle ?? ChartSeriesStyle(),
      );

      return ChartData(
        type: config.chartType,
        title: config.title,
        subtitle: config.subtitle ?? "",
        series: [series],
        xAxisConfig:
            config.xAxisConfig ??
            AxisConfiguration(
              title: "X",
              type: AxisType.numeric,
              showGridLines: true,
            ),
        yAxisConfig:
            config.yAxisConfig ??
            AxisConfiguration(
              title: "Y",
              type: AxisType.numeric,
              showGridLines: true,
            ),
        legend: config.legend ?? ChartLegend(show: true),
        interactivity: config.interactivity ?? ChartInteractivity(),
        annotations: config.annotations ?? const <ChartAnnotation>[],
      );
    } catch (e) {
      debugPrint('❌ Failed to generate custom visualization: $e');
      return ChartData.error('Failed to create custom visualization');
    }
  }

  /// Export chart as image
  Future<Uint8List?> exportChartAsImage(
    ChartData chartData, {
    int width = 800,
    int height = 600,
    ImageFormat format = ImageFormat.png,
  }) async {
    try {
      // In a real implementation, this would render the chart to an image
      // For now, return null as a placeholder
      debugPrint('📸 Exporting chart as ${format.name} (${width}x$height)');
      return null;
    } catch (e) {
      debugPrint('❌ Failed to export chart as image: $e');
      return null;
    }
  }

  /// Setup default chart configurations
  void _setupDefaultConfigurations() {
    _chartConfigurations['mood_trend'] = ChartConfiguration(
      type: ChartType.lineChart,
      theme: ChartTheme.fromAppTheme(_currentTheme),
      animations: ChartAnimations(
        enabled: true,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      ),
    );

    _chartConfigurations['cycle_pattern'] = ChartConfiguration(
      type: ChartType.lineChart,
      theme: ChartTheme.fromAppTheme(_currentTheme),
      animations: ChartAnimations(
        enabled: true,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.elasticOut,
      ),
    );

    _chartConfigurations['heatmap'] = ChartConfiguration(
      type: ChartType.heatmap,
      theme: ChartTheme.fromAppTheme(_currentTheme),
      animations: ChartAnimations(
        enabled: true,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
      ),
    );
  }

  /// Update chart themes when app theme changes
  void _updateChartThemes() {
    for (final config in _chartConfigurations.values) {
      config.theme = ChartTheme.fromAppTheme(_currentTheme);
    }
  }

  /// Generate mock cycle data
  /// Generate mock prediction data
  List<DataPoint> _buildCycleDataPoints(
    List<CycleData> cycles,
    DateRange dateRange,
  ) {
    final data = <DataPoint>[];

    bool inRange(DateTime value) =>
        !value.isBefore(dateRange.start) && !value.isAfter(dateRange.end);

    for (final cycle in cycles) {
      if (inRange(cycle.startDate)) {
        data.add(
          DataPoint(
            x: cycle.startDate.millisecondsSinceEpoch.toDouble(),
            y: 0,
            label: 'Period Start',
            metadata: const {'event': 'menstruation'},
          ),
        );
      }

      final ovulationDate = cycle.ovulationDate;
      if (ovulationDate != null && inRange(ovulationDate)) {
        data.add(
          DataPoint(
            x: ovulationDate.millisecondsSinceEpoch.toDouble(),
            y: 1,
            label: 'Ovulation',
            metadata: const {'event': 'ovulation'},
          ),
        );
      }
    }

    data.sort((a, b) => a.x.compareTo(b.x));
    return data;
  }

  List<DataPoint> _buildPredictionData(CycleData? currentCycle) {
    if (currentCycle == null) return <DataPoint>[];

    final expectedPeriod = currentCycle.expectedNextPeriod;
    if (expectedPeriod == null) return <DataPoint>[];

    final data = <DataPoint>[
      DataPoint(
        x: expectedPeriod.millisecondsSinceEpoch.toDouble(),
        y: 0,
        label: 'Predicted Period',
        metadata: const {'event': 'prediction', 'type': 'menstruation'},
      ),
    ];

    final ovulationDate = currentCycle.ovulationDate;
    if (ovulationDate != null && ovulationDate.isAfter(DateTime.now())) {
      data.add(
        DataPoint(
          x: ovulationDate.millisecondsSinceEpoch.toDouble(),
          y: 1,
          label: 'Predicted Ovulation',
          metadata: const {'event': 'prediction', 'type': 'ovulation'},
        ),
      );
    }

    return data;
  }

  /// Generate cycle annotations
  List<ChartAnnotation> _generateCycleAnnotations(DateRange dateRange) {
    return [
      ChartAnnotation(
        type: AnnotationType.verticalLine,
        value: DateTime.now().millisecondsSinceEpoch.toDouble(),
        label: 'Today',
        style: AnnotationStyle(
          color: Colors.grey,
          strokeWidth: 1.0,
          strokeDashPattern: [3, 3],
        ),
      ),
    ];
  }

  /// Calculate correlations from persisted symptom observations.
  Map<String, Map<String, double>> _calculateSymptomCorrelationMatrix({
    required List<DailyFeelingsEntry> entries,
    List<String>? symptomFilter,
  }) {
    if (entries.length < 3) {
      return <String, Map<String, double>>{};
    }

    final requested = symptomFilter
        ?.map((value) => value.trim().toLowerCase())
        .where((value) => value.isNotEmpty)
        .toSet();

    // Normalize labels per observation. Missing symptoms stay missing and
    // are never silently converted into fabricated zero observations.
    final observations = <Map<String, double>>[];
    final displayLabels = <String, String>{};

    for (final entry in entries) {
      final observation = <String, double>{};

      for (final symptom in entry.symptoms.entries) {
        final label = symptom.key.trim();
        final normalized = label.toLowerCase();

        if (normalized.isEmpty) {
          continue;
        }

        if (requested != null && !requested.contains(normalized)) {
          continue;
        }

        final value = symptom.value.toDouble();

        if (!value.isFinite) {
          continue;
        }

        observation[normalized] = value;
        displayLabels.putIfAbsent(normalized, () => label);
      }

      if (observation.isNotEmpty) {
        observations.add(observation);
      }
    }

    if (observations.length < 3 || displayLabels.length < 2) {
      return <String, Map<String, double>>{};
    }

    final keys = displayLabels.keys.toList(growable: false)..sort();
    final matrix = <String, Map<String, double>>{};

    for (final xKey in keys) {
      final row = <String, double>{};

      for (final yKey in keys) {
        final xValues = <double>[];
        final yValues = <double>[];

        for (final observation in observations) {
          final xValue = observation[xKey];
          final yValue = observation[yKey];

          if (xValue == null || yValue == null) {
            continue;
          }

          xValues.add(xValue);
          yValues.add(yValue);
        }

        final correlation = Statistics.pearsonCorrelation(
          xValues,
          yValues,
          minimumSamples: 3,
        );

        if (correlation == null) {
          continue;
        }

        row[displayLabels[yKey]!] = correlation;
      }

      if (row.isNotEmpty) {
        matrix[displayLabels[xKey]!] = row;
      }
    }

    return matrix;
  }

  /// Generate sleep quality chart
  Future<ChartData> _generateSleepQualityChart(
    String userId,
    DateRange dateRange,
  ) async {
    final history = await canonical_health.AdvancedBiometricService.instance
        .getHistoricalSleepHours(start: dateRange.start, end: dateRange.end);

    if (history.isEmpty) {
      return ChartData.empty(
        ChartType.barChart,
        'No synced sleep history is available for this period.',
      );
    }

    final sleepData = history
        .map(
          (point) => DataPoint(
            x: point.timestamp.millisecondsSinceEpoch.toDouble(),
            y: point.value,
            label: point.timestamp.toString().split(' ')[0],
            metadata: const <String, dynamic>{
              'type': 'sleep_hours',
              'source': 'health',
            },
          ),
        )
        .toList();

    return ChartData(
      type: ChartType.barChart,
      title: 'Sleep History',
      subtitle: 'Recorded sleep hours per night',
      series: [
        ChartSeries(
          name: 'Sleep Hours',
          data: sleepData,
          color: Colors.indigo,
          style: ChartSeriesStyle(strokeWidth: 1.0, fillOpacity: 0.8),
        ),
      ],
      xAxisConfig: AxisConfiguration(title: 'Date', type: AxisType.datetime),
      yAxisConfig: AxisConfiguration(
        title: 'Hours',
        type: AxisType.numeric,
        minimum: 0,
      ),
      legend: ChartLegend(show: false),
    );
  }

  /// Generate activity level chart
  Future<ChartData> _generateActivityLevelChart(
    String userId,
    DateRange dateRange,
  ) async {
    final history = await canonical_health.AdvancedBiometricService.instance
        .getHistoricalDailySteps(start: dateRange.start, end: dateRange.end);

    if (history.isEmpty) {
      return ChartData.empty(
        ChartType.areaChart,
        'No synced activity history is available for this period.',
      );
    }

    final activityData = history
        .map(
          (point) => DataPoint(
            x: point.timestamp.millisecondsSinceEpoch.toDouble(),
            y: point.value,
            label: point.timestamp.toString().split(' ')[0],
            metadata: const <String, dynamic>{
              'type': 'steps',
              'source': 'health',
            },
          ),
        )
        .toList();

    return ChartData(
      type: ChartType.areaChart,
      title: 'Daily Activity',
      subtitle: 'Recorded daily steps',
      series: [
        ChartSeries(
          name: 'Steps',
          data: activityData,
          color: Colors.green,
          style: ChartSeriesStyle(strokeWidth: 2.0, fillOpacity: 0.3),
        ),
      ],
      xAxisConfig: AxisConfiguration(title: 'Date', type: AxisType.datetime),
      yAxisConfig: AxisConfiguration(
        title: 'Steps',
        type: AxisType.numeric,
        minimum: 0,
      ),
      legend: ChartLegend(show: false),
    );
  }

  /// Generate symptom frequency chart
  Future<ChartData> _generateSymptomFrequencyChart(
    String userId,
    DateRange dateRange,
  ) async {
    final Map<String, int> symptomCounts = {
      'Headache': 15,
      'Fatigue': 12,
      'Cramps': 8,
      'Mood Swings': 10,
      'Bloating': 6,
      'Nausea': 4,
    };

    final List<DataPoint> frequencyData = symptomCounts.entries.map((entry) {
      return DataPoint(
        x: symptomCounts.keys.toList().indexOf(entry.key).toDouble(),
        y: entry.value.toDouble(),
        label: entry.key,
        metadata: {'symptom': entry.key, 'count': entry.value},
      );
    }).toList();

    return ChartData(
      type: ChartType.barChart,
      title: 'Symptom Frequency',
      subtitle: 'Most common symptoms',
      series: [
        ChartSeries(
          name: 'Frequency',
          data: frequencyData,
          color: Colors.orange,
          style: ChartSeriesStyle(strokeWidth: 1.0, fillOpacity: 0.8),
        ),
      ],
      xAxisConfig: AxisConfiguration(
        title: 'Symptoms',
        type: AxisType.categorical,
        categories: symptomCounts.keys.toList(),
      ),
      yAxisConfig: AxisConfiguration(
        title: 'Count',
        type: AxisType.numeric,
        minimum: 0,
      ),
      legend: ChartLegend(show: false),
    );
  }

  /// Process custom data for visualization
  List<DataPoint> _processCustomData(
    Map<String, dynamic> data,
    VisualizationConfig config,
  ) {
    // This is a simplified implementation
    // In a real app, this would process data based on the configuration
    return [];
  }

  /// Get color for mood category
  Color _getMoodCategoryColor(String? category) {
    switch (category) {
      case 'happiness':
        return Colors.yellow.shade700;
      case 'anxiety':
        return Colors.red.shade600;
      case 'sadness':
        return Colors.blue.shade600;
      case 'anger':
        return Colors.red.shade800;
      case 'excitement':
        return Colors.orange.shade600;
      case 'calm':
        return Colors.green.shade600;
      default:
        return _currentTheme.primaryColor;
    }
  }

  /// Format date range for chart subtitle
  String _formatDateRange(DateRange dateRange) {
    final String startStr = dateRange.start.toString().split(' ')[0];
    final String endStr = dateRange.end.toString().split(' ')[0];
    return '$startStr to $endStr';
  }

  /// Dispose resources
  void dispose() {
    _chartConfigurations.clear();
    _cachedData.clear();
    _isInitialized = false;
  }
}

class VisualizationException implements Exception {
  final String message;
  VisualizationException(this.message);

  @override
  String toString() => 'VisualizationException: $message';
}
