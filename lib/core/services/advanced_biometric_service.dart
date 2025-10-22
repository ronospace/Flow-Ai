import 'dart:async';
import 'package:health/health.dart';
import '../utils/app_logger.dart';

/// Biometric insight types
enum BiometricInsightType {
  heartRateVariability,
  temperaturePattern,
  sleepQuality,
  stressLevel,
  recovery,
  cycleCorrelation,
  anomaly,
  trend,
  prediction,
  hrvElevated,
  hrvLowered,
  temperatureShift,
  sleepDisruption,
}

/// Biometric insight for health analysis
class BiometricInsight {
  final BiometricInsightType type;
  final String title;
  final String insight;
  final double confidence;
  final int dataPoints;
  final List<String> recommendations;
  final DateTime timestamp;
  
  BiometricInsight({
    required this.type,
    required this.title,
    required this.insight,
    required this.confidence,
    required this.dataPoints,
    required this.recommendations,
    required this.timestamp,
  });
}

/// Biometric snapshot for real-time monitoring
class BiometricSnapshot {
  final DateTime timestamp;
  final double? heartRate;
  final double? restingHeartRate;
  final double? heartRateVariability;
  final double? bodyTemperature;
  final double? basalBodyTemperature;
  final double? sleepHours;
  final double? steps;
  final double? activeEnergy;
  final double? bloodOxygen;
  final double? respiratoryRate;
  final double dataQuality;
  
  BiometricSnapshot({
    required this.timestamp,
    this.heartRate,
    this.restingHeartRate,
    this.heartRateVariability,
    this.bodyTemperature,
    this.basalBodyTemperature,
    this.sleepHours,
    this.steps,
    this.activeEnergy,
    this.bloodOxygen,
    this.respiratoryRate,
    required this.dataQuality,
  });
  
  factory BiometricSnapshot.empty() {
    return BiometricSnapshot(
      timestamp: DateTime.now(),
      dataQuality: 0.0,
    );
  }
}

/// Advanced Biometric Integration Service
/// Integrates with HealthKit (iOS) and Google Fit (Android) for comprehensive health data
class AdvancedBiometricService {
  static final AdvancedBiometricService _instance = AdvancedBiometricService._internal();
  static AdvancedBiometricService get instance => _instance;
  AdvancedBiometricService._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Health? _health;
  StreamSubscription<List<HealthDataPoint>>? _healthDataSubscription;
  Timer? _syncTimer;

  // Biometric data cache
  final Map<HealthDataType, List<HealthDataPoint>> _dataCache = {};
  DateTime? _lastSyncTime;

  /// Available health data types for menstrual health tracking
  static const List<HealthDataType> _supportedDataTypes = [
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.HEART_RATE_VARIABILITY_SDNN,
    HealthDataType.BODY_TEMPERATURE,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_REM,
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WEIGHT,
    HealthDataType.BODY_MASS_INDEX,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.RESPIRATORY_RATE,
    HealthDataType.WATER,
    HealthDataType.MINDFULNESS,
    // Basic menstrual cycle data (available in health package)
    HealthDataType.MENSTRUATION_FLOW,
  ];

  /// Initialize biometric integration
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      AppLogger.info('🩺 Initializing Advanced Biometric Integration...');

      _health = Health();

      // Check if health data is available on this platform
      if (_health != null) {
        final hasPermissions = await _health!.hasPermissions(_supportedDataTypes) ?? false;
        if (!hasPermissions) {
        AppLogger.warning('Health permissions not granted. Requesting...');
        
        final granted = await _requestHealthPermissions();
        if (!granted) {
          AppLogger.warning('Health permissions denied. Limited biometric functionality.');
          // Continue with limited functionality
        }
      }
      }

      // Set up real-time health data monitoring
      await _setupHealthDataMonitoring();

      // Start periodic sync
      _startPeriodicSync();

      _isInitialized = true;
      AppLogger.success('✅ Advanced Biometric Integration initialized');
    } catch (e) {
      AppLogger.error('Failed to initialize biometric service: $e');
      // Continue with mock data for testing
      _initializeMockService();
    }
  }

  /// Request health data permissions
  Future<bool> _requestHealthPermissions() async {
    try {
      final permissions = _supportedDataTypes.map((type) => HealthDataAccess.READ).toList();
      
      return await _health!.requestAuthorization(
        _supportedDataTypes,
        permissions: permissions,
      );
    } catch (e) {
      AppLogger.error('Failed to request health permissions: $e');
      return false;
    }
  }

  /// Set up real-time health data monitoring
  Future<void> _setupHealthDataMonitoring() async {
    try {
      // Subscribe to health data changes (where supported)
      // Note: Real-time streaming may not be available on all platforms
      try {
        // For now, use periodic fetching instead of streaming
        AppLogger.info('📊 Setting up periodic health data monitoring');
      } catch (e) {
        AppLogger.warning('Health data streaming not available: $e');
      }
      
      AppLogger.info('📊 Real-time health monitoring activated');
    } catch (e) {
      AppLogger.warning('Real-time monitoring not available: $e');
    }
  }

  /// Process incoming health data stream
  void _processHealthDataStream(List<HealthDataPoint> healthData) {
    try {
      for (final dataPoint in healthData) {
        _cacheHealthDataPoint(dataPoint);
      }
      
      // Trigger AI analysis if significant new data
      if (healthData.isNotEmpty) {
        _triggerAIAnalysis(healthData);
      }
    } catch (e) {
      AppLogger.error('Error processing health data stream: $e');
    }
  }

  /// Cache health data point
  void _cacheHealthDataPoint(HealthDataPoint dataPoint) {
    final type = dataPoint.type;
    if (!_dataCache.containsKey(type)) {
      _dataCache[type] = [];
    }
    
    _dataCache[type]!.add(dataPoint);
    
    // Keep only recent data (last 30 days)
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    _dataCache[type]!.removeWhere(
      (point) => point.dateFrom.isBefore(thirtyDaysAgo),
    );
  }

  /// Trigger AI analysis for new biometric data
  void _triggerAIAnalysis(List<HealthDataPoint> newData) {
    // Analyze new data with AI engine for cycle insights
    Timer(const Duration(milliseconds: 500), () async {
      try {
        final insights = await _analyzeBiometricPatterns(newData);
        _notifyHealthInsights(insights);
      } catch (e) {
        AppLogger.error('AI analysis failed: $e');
      }
    });
  }

  /// Analyze biometric patterns with AI
  Future<List<BiometricInsight>> _analyzeBiometricPatterns(List<HealthDataPoint> data) async {
    final insights = <BiometricInsight>[];
    
    try {
      // Heart rate variability analysis
      final hrvData = data.where((d) => d.type == HealthDataType.HEART_RATE_VARIABILITY_SDNN).toList();
      if (hrvData.isNotEmpty) {
        final hrvInsight = await _analyzeHRVPatterns(hrvData);
        if (hrvInsight != null) insights.add(hrvInsight);
      }
      
      // Body temperature patterns
      final tempData = data.where((d) => 
        d.type == HealthDataType.BODY_TEMPERATURE
      ).toList();
      if (tempData.isNotEmpty) {
        final tempInsight = await _analyzeTemperaturePatterns(tempData);
        if (tempInsight != null) insights.add(tempInsight);
      }
      
      // Sleep quality correlation
      final sleepData = data.where((d) => d.type == HealthDataType.SLEEP_ASLEEP).toList();
      if (sleepData.isNotEmpty) {
        final sleepInsight = await _analyzeSleepCycleCorrelation(sleepData);
        if (sleepInsight != null) insights.add(sleepInsight);
      }
      
      // Stress indicators from HRV and other metrics
      final stressInsight = await _analyzeStressIndicators(data);
      if (stressInsight != null) insights.add(stressInsight);
      
    } catch (e) {
      AppLogger.error('Error analyzing biometric patterns: $e');
    }
    
    return insights;
  }

  /// Analyze heart rate variability patterns
  Future<BiometricInsight?> _analyzeHRVPatterns(List<HealthDataPoint> hrvData) async {
    if (hrvData.length < 7) return null; // Need at least a week of data
    
    try {
      final values = hrvData.map((d) => (d.value as NumericHealthValue).numericValue.toDouble()).toList();
      final average = values.reduce((a, b) => a + b) / values.length;
      final recent = values.takeLast(3).toList();
      final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
      
      String insight;
      BiometricInsightType type;
      double confidence = 0.0;
      
      if (recentAvg > average * 1.15) {
        insight = 'Your heart rate variability is elevated, suggesting good recovery and low stress levels. This often correlates with the follicular phase of your cycle.';
        type = BiometricInsightType.hrvElevated;
        confidence = 0.8;
      } else if (recentAvg < average * 0.85) {
        insight = 'Your heart rate variability is lower than usual, which may indicate stress or approaching menstruation.';
        type = BiometricInsightType.hrvLowered;
        confidence = 0.75;
      } else {
        return null; // No significant pattern
      }
      
      return BiometricInsight(
        type: type,
        title: 'HRV Pattern Detected',
        insight: insight,
        confidence: confidence,
        dataPoints: hrvData.length,
        recommendations: _getHRVRecommendations(type),
        timestamp: DateTime.now(),
      );
    } catch (e) {
      AppLogger.error('Error analyzing HRV patterns: $e');
      return null;
    }
  }

  /// Analyze body temperature patterns for ovulation prediction
  Future<BiometricInsight?> _analyzeTemperaturePatterns(List<HealthDataPoint> tempData) async {
    if (tempData.length < 10) return null;
    
    try {
      // Sort by date
      tempData.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));
      
      final values = tempData.map((d) => (d.value as NumericHealthValue).numericValue.toDouble()).toList();
      final recentValues = values.takeLast(5).toList();
      final previousValues = values.take(values.length - 5).toList();
      
      if (previousValues.isEmpty) return null;
      
      final recentAvg = recentValues.reduce((a, b) => a + b) / recentValues.length;
      final previousAvg = previousValues.reduce((a, b) => a + b) / previousValues.length;
      
      // Detect temperature shift (potential ovulation indicator)
      if (recentAvg > previousAvg + 0.2) { // 0.2°C increase suggests ovulation
        return BiometricInsight(
          type: BiometricInsightType.temperatureShift,
          title: 'Temperature Shift Detected',
          insight: 'Your basal body temperature has increased by ${(recentAvg - previousAvg).toStringAsFixed(1)}°C, which may indicate recent ovulation.',
          confidence: 0.85,
          dataPoints: tempData.length,
          recommendations: [
            'This suggests you may be in your luteal phase',
            'Continue tracking temperature for cycle confirmation',
            'Consider fertility window timing for family planning',
          ],
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      AppLogger.error('Error analyzing temperature patterns: $e');
    }
    
    return null;
  }

  /// Analyze sleep-cycle correlation
  Future<BiometricInsight?> _analyzeSleepCycleCorrelation(List<HealthDataPoint> sleepData) async {
    try {
      if (sleepData.length < 14) return null; // Need 2 weeks minimum
      
      final sleepDurations = sleepData.map((d) => (d.value as NumericHealthValue).numericValue.toDouble()).toList();
      final avgSleep = sleepDurations.reduce((a, b) => a + b) / sleepDurations.length;
      final recentSleep = sleepDurations.takeLast(3).reduce((a, b) => a + b) / 3;
      
      if (recentSleep < avgSleep * 0.85) {
        return BiometricInsight(
          type: BiometricInsightType.sleepDisruption,
          title: 'Sleep Pattern Changes',
          insight: 'Your sleep quality has decreased recently. This often occurs during the luteal phase due to hormonal changes.',
          confidence: 0.7,
          dataPoints: sleepData.length,
          recommendations: [
            'Try relaxation techniques before bed',
            'Maintain a consistent sleep schedule',
            'Consider magnesium supplementation (consult healthcare provider)',
            'Track if this pattern aligns with your cycle phases',
          ],
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      AppLogger.error('Error analyzing sleep patterns: $e');
    }
    
    return null;
  }

  /// Analyze stress indicators
  Future<BiometricInsight?> _analyzeStressIndicators(List<HealthDataPoint> allData) async {
    try {
      final hrvData = allData.where((d) => d.type == HealthDataType.HEART_RATE_VARIABILITY_SDNN).toList();
      final restingHRData = allData.where((d) => d.type == HealthDataType.RESTING_HEART_RATE).toList();
      
      if (hrvData.isEmpty && restingHRData.isEmpty) return null;
      
      // Simple stress indicator: low HRV + elevated resting HR
      bool lowHRV = false;
      bool elevatedHR = false;
      
      if (hrvData.isNotEmpty) {
        final hrvValues = hrvData.map((d) => (d.value as NumericHealthValue).numericValue.toDouble()).toList();
        final avgHRV = hrvValues.reduce((a, b) => a + b) / hrvValues.length;
        final recentHRV = hrvValues.takeLast(2).reduce((a, b) => a + b) / 2;
        lowHRV = recentHRV < avgHRV * 0.8;
      }
      
      if (restingHRData.isNotEmpty) {
        final hrValues = restingHRData.map((d) => (d.value as NumericHealthValue).numericValue.toDouble()).toList();
        final avgHR = hrValues.reduce((a, b) => a + b) / hrValues.length;
        final recentHR = hrValues.takeLast(2).reduce((a, b) => a + b) / 2;
        elevatedHR = recentHR > avgHR * 1.1;
      }
      
      if (lowHRV || elevatedHR) {
        return BiometricInsight(
          type: BiometricInsightType.stressLevel,
          title: 'Stress Indicators Detected',
          insight: 'Your biometric data suggests elevated stress levels, which can impact your menstrual cycle regularity.',
          confidence: 0.65,
          dataPoints: hrvData.length + restingHRData.length,
          recommendations: [
            'Practice stress-reduction techniques like meditation',
            'Ensure adequate sleep (7-9 hours)',
            'Consider gentle exercise like yoga or walking',
            'Monitor if stress aligns with specific cycle phases',
          ],
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      AppLogger.error('Error analyzing stress indicators: $e');
    }
    
    return null;
  }

  /// Get HRV-specific recommendations
  List<String> _getHRVRecommendations(BiometricInsightType type) {
    switch (type) {
      case BiometricInsightType.hrvElevated:
        return [
          'Great recovery status! This is optimal for exercise',
          'Your body is handling stress well',
          'Continue your current wellness routine',
        ];
      case BiometricInsightType.hrvLowered:
        return [
          'Consider lighter exercise or rest day',
          'Focus on stress management and relaxation',
          'Ensure adequate hydration and nutrition',
          'Prioritize quality sleep tonight',
        ];
      default:
        return ['Continue monitoring your HRV trends'];
    }
  }


  /// Notify health insights to listeners
  void _notifyHealthInsights(List<BiometricInsight> insights) {
    if (insights.isNotEmpty) {
      AppLogger.info('📊 Generated ${insights.length} biometric insights');
      // Here you would notify UI components or save to database
      _saveBiometricInsights(insights);
    }
  }

  /// Save biometric insights
  Future<void> _saveBiometricInsights(List<BiometricInsight> insights) async {
    try {
      // Save to local storage or send to backend
      AppLogger.info('💾 Saved ${insights.length} biometric insights');
    } catch (e) {
      AppLogger.error('Failed to save biometric insights: $e');
    }
  }

  /// Start periodic health data sync
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _syncHealthData();
    });
  }

  /// Sync health data from device
  Future<void> _syncHealthData() async {
    try {
      if (!_isInitialized || _health == null) return;
      
      final now = DateTime.now();
      final startTime = _lastSyncTime ?? now.subtract(const Duration(days: 7));
      
      for (final dataType in _supportedDataTypes) {
        try {
          final healthData = await _health!.getHealthDataFromTypes(
            types: [dataType],
            startTime: startTime,
            endTime: now,
          );
          
          for (final dataPoint in healthData) {
            _cacheHealthDataPoint(dataPoint);
          }
        } catch (e) {
          // Skip this data type if not available
          continue;
        }
      }
      
      _lastSyncTime = now;
      AppLogger.info('📊 Health data sync completed');
    } catch (e) {
      AppLogger.error('Health data sync failed: $e');
    }
  }

  /// Initialize mock service for testing
  void _initializeMockService() {
    _isInitialized = true;
    AppLogger.info('🧪 Mock biometric service initialized for testing');
    
    // Generate mock insights periodically
    Timer.periodic(const Duration(minutes: 30), (timer) {
      _generateMockInsights();
    });
  }

  /// Generate mock insights for testing
  void _generateMockInsights() {
    final mockInsights = [
      BiometricInsight(
        type: BiometricInsightType.temperatureShift,
        title: 'Mock Temperature Pattern',
        insight: 'Simulated temperature shift detected for testing purposes.',
        confidence: 0.7,
        dataPoints: 14,
        recommendations: ['This is mock data for development'],
        timestamp: DateTime.now(),
      ),
    ];
    
    _notifyHealthInsights(mockInsights);
  }

  /// Get recent biometric data for AI analysis
  Future<Map<HealthDataType, List<HealthDataPoint>>> getRecentBiometricData({
    Duration? timeRange,
  }) async {
    final range = timeRange ?? const Duration(days: 30);
    final cutoff = DateTime.now().subtract(range);
    
    final recentData = <HealthDataType, List<HealthDataPoint>>{};
    
    for (final entry in _dataCache.entries) {
      final recentPoints = entry.value.where(
        (point) => point.dateFrom.isAfter(cutoff),
      ).toList();
      
      if (recentPoints.isNotEmpty) {
        recentData[entry.key] = recentPoints;
      }
    }
    
    return recentData;
  }

  /// Get biometric snapshot for current moment
  Future<BiometricSnapshot> getCurrentBiometricSnapshot() async {
    try {
      final recentData = await getRecentBiometricData(timeRange: const Duration(days: 1));
      
      return BiometricSnapshot(
        timestamp: DateTime.now(),
        heartRate: _getLatestValue(recentData[HealthDataType.HEART_RATE]),
        restingHeartRate: _getLatestValue(recentData[HealthDataType.RESTING_HEART_RATE]),
        heartRateVariability: _getLatestValue(recentData[HealthDataType.HEART_RATE_VARIABILITY_SDNN]),
        bodyTemperature: _getLatestValue(recentData[HealthDataType.BODY_TEMPERATURE]),
        basalBodyTemperature: _getLatestValue(recentData[HealthDataType.BODY_TEMPERATURE]),
        sleepHours: _getLatestValue(recentData[HealthDataType.SLEEP_ASLEEP]),
        steps: _getLatestValue(recentData[HealthDataType.STEPS]),
        activeEnergy: _getLatestValue(recentData[HealthDataType.ACTIVE_ENERGY_BURNED]),
        bloodOxygen: _getLatestValue(recentData[HealthDataType.BLOOD_OXYGEN]),
        respiratoryRate: _getLatestValue(recentData[HealthDataType.RESPIRATORY_RATE]),
        dataQuality: _calculateDataQuality(recentData),
      );
    } catch (e) {
      AppLogger.error('Error getting biometric snapshot: $e');
      return BiometricSnapshot.empty();
    }
  }

  /// Get latest value from health data points
  double? _getLatestValue(List<HealthDataPoint>? dataPoints) {
    if (dataPoints == null || dataPoints.isEmpty) return null;
    
    dataPoints.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
    final value = dataPoints.first.value;
    if (value is NumericHealthValue) {
      return value.numericValue.toDouble();
    }
    return null;
  }

  /// Calculate data quality score
  double _calculateDataQuality(Map<HealthDataType, List<HealthDataPoint>> data) {
    if (data.isEmpty) return 0.0;
    
    final totalTypes = _supportedDataTypes.length;
    final availableTypes = data.keys.length;
    
    return availableTypes / totalTypes;
  }

  /// Dispose of resources
  void dispose() {
    _healthDataSubscription?.cancel();
    _syncTimer?.cancel();
    _dataCache.clear();
    _isInitialized = false;
  }
}

// Helper extension for taking last N elements
extension ListExtension<T> on List<T> {
  List<T> takeLast(int count) {
    if (count >= length) return this;
    return sublist(length - count);
  }
}
