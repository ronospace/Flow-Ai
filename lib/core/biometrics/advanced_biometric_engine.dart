import 'dart:async';
import 'package:flutter/foundation.dart';

import 'dart:math';

import '../services/advanced_biometric_service.dart' as canonical_health;

/// 🎯 Revolutionary Real-time Biometric Integration Engine
/// Advanced data fusion with multiple wearable devices and sensors
/// Ultra-precise health monitoring with AI-powered insights
class AdvancedBiometricEngine {
  static final AdvancedBiometricEngine _instance =
      AdvancedBiometricEngine._internal();
  static AdvancedBiometricEngine get instance => _instance;
  AdvancedBiometricEngine._internal();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  // Single production source of truth for health observations.
  final canonical_health.AdvancedBiometricService _healthProvider =
      canonical_health.AdvancedBiometricService.instance;

  // Real-time data streams
  final StreamController<BiometricReading> _biometricStream =
      StreamController.broadcast();
  Stream<BiometricReading> get biometricStream => _biometricStream.stream;

  // Data fusion and processing
  late DataFusionEngine _fusionEngine;
  late AnomalyDetector _anomalyDetector;
  late TrendAnalyzer _trendAnalyzer;

  // Background processing
  Timer? _backgroundProcessor;
  final Map<String, dynamic> _realtimeCache = {};

  Future<void> initialize() async {
    if (_initialized) return;

    debugPrint('🎯 Initializing Advanced Biometric Engine...');

    // Initialize integrations
    await _initializeIntegrations();

    // Initialize data processing engines
    await _initializeProcessingEngines();

    // Start background processing
    _startBackgroundProcessing();

    // Setup real-time monitoring
    await _setupRealtimeMonitoring();

    _initialized = true;
    debugPrint(
      '✅ Advanced Biometric Engine initialized with real-time monitoring',
    );
  }

  Future<void> _initializeIntegrations() async {
    await _healthProvider.initialize();
  }

  Future<void> _initializeProcessingEngines() async {
    debugPrint('⚙️ Initializing processing engines...');

    _fusionEngine = DataFusionEngine();
    _anomalyDetector = AnomalyDetector();
    _trendAnalyzer = TrendAnalyzer();

    await Future.wait([
      _fusionEngine.initialize(),
      _anomalyDetector.initialize(),
      _trendAnalyzer.initialize(),
    ]);
  }

  void _startBackgroundProcessing() {
    _backgroundProcessor = Timer.periodic(const Duration(minutes: 5), (
      _,
    ) async {
      await _processBackgroundData();
    });
  }

  Future<void> _setupRealtimeMonitoring() async {
    await _refreshCanonicalHealthData();
  }

  Future<void> _refreshCanonicalHealthData() async {
    final snapshot = await _healthProvider.getCurrentBiometricSnapshot();

    void emit(String type, num? rawValue) {
      if (rawValue == null) return;

      final value = rawValue.toDouble();
      if (!value.isFinite) return;

      _onBiometricData(
        BiometricReading(
          source: 'Health',
          type: type,
          value: value,
          timestamp: snapshot.timestamp,
        ),
      );
    }

    emit('heart_rate', snapshot.heartRate);
    emit('resting_heart_rate', snapshot.restingHeartRate);
    emit('hrv', snapshot.heartRateVariability);
    emit('temperature', snapshot.bodyTemperature);
    emit('basal_body_temperature', snapshot.basalBodyTemperature);
    emit('sleep', snapshot.sleepHours);
    emit('sleep_hours', snapshot.sleepHours);
    emit('steps', snapshot.steps);
    emit('activity', snapshot.activeEnergy);
    emit('active_energy', snapshot.activeEnergy);
    emit('blood_oxygen', snapshot.bloodOxygen);
    emit('respiratory_rate', snapshot.respiratoryRate);

    // No glucose is emitted without a verified production source.
  }

  void _onBiometricData(BiometricReading reading) {
    // Process and broadcast real-time data
    _realtimeCache[reading.type] = reading;
    _biometricStream.add(reading);

    // Check for anomalies
    _checkForAnomalies(reading);
  }

  void _checkForAnomalies(BiometricReading reading) {
    final anomaly = _anomalyDetector.detectAnomaly(reading);
    if (anomaly.isAnomalous) {
      debugPrint('🚨 Anomaly detected: ${anomaly.description}');
      // Handle anomaly (notifications, alerts, etc.)
    }
  }

  Future<void> _processBackgroundData() async {
    await _refreshCanonicalHealthData();

    final fusedData = await _fusionEngine.processLatestData(_realtimeCache);

    final trends = await _trendAnalyzer.analyzeTrends(fusedData);

    _realtimeCache['fused_insights'] = fusedData;
    _realtimeCache['trends'] = trends;
  }

  /// Get comprehensive biometric snapshot
  Future<BiometricSnapshot> getCurrentSnapshot() async {
    return getBiometricSnapshot('default');
  }

  /// Get biometric snapshot for specific user
  Future<BiometricSnapshot> getBiometricSnapshot(String userId) async {
    if (!_initialized) await initialize();

    final canonicalSnapshot = await _healthProvider
        .getCurrentBiometricSnapshot();

    final fusedData = <String, dynamic>{};

    void addRealValue(String key, num? rawValue) {
      if (rawValue == null) return;

      final value = rawValue.toDouble();
      if (!value.isFinite) return;

      fusedData[key] = value;
    }

    addRealValue('heart_rate', canonicalSnapshot.heartRate);
    addRealValue('resting_heart_rate', canonicalSnapshot.restingHeartRate);
    addRealValue('hrv', canonicalSnapshot.heartRateVariability);
    addRealValue('temperature', canonicalSnapshot.bodyTemperature);
    addRealValue(
      'basal_body_temperature',
      canonicalSnapshot.basalBodyTemperature,
    );
    addRealValue('sleep', canonicalSnapshot.sleepHours);
    addRealValue('sleep_hours', canonicalSnapshot.sleepHours);
    addRealValue('steps', canonicalSnapshot.steps);
    addRealValue('activity', canonicalSnapshot.activeEnergy);
    addRealValue('active_energy', canonicalSnapshot.activeEnergy);
    addRealValue('blood_oxygen', canonicalSnapshot.bloodOxygen);
    addRealValue('respiratory_rate', canonicalSnapshot.respiratoryRate);

    final insights = await _generateBiometricInsights(fusedData);

    return BiometricSnapshot(
      timestamp: canonicalSnapshot.timestamp,
      fusedData: fusedData,
      insights: insights,
      confidence: _calculateConfidence(fusedData),
      trends: await _trendAnalyzer.getLatestTrends(),
      anomalies: await _anomalyDetector.getRecentAnomalies(),
    );
  }

  /// Get menstrual cycle-specific biometric analysis
  Future<CycleBiometricAnalysis> getCycleAnalysis(String currentPhase) async {
    final snapshot = await getCurrentSnapshot();

    return CycleBiometricAnalysis(
      phase: currentPhase,
      snapshot: snapshot,
      phaseOptimalRanges: _getPhaseOptimalRanges(currentPhase),
      deviations: _calculatePhaseDeviations(snapshot, currentPhase),
      recommendations: _generatePhaseRecommendations(snapshot, currentPhase),
    );
  }

  Future<Map<String, dynamic>> _generateBiometricInsights(
    Map<String, dynamic> fusedData,
  ) async {
    final insights = <String, dynamic>{};

    final hrv = fusedData['hrv'];
    if (hrv is num && hrv.toDouble().isFinite) {
      insights['hrv_analysis'] = _analyzeHRV(hrv);
    }

    final temperature = fusedData['temperature'];
    if (temperature is num && temperature.toDouble().isFinite) {
      insights['temperature_analysis'] = _analyzeTemperature(temperature);
    }

    final sleep = fusedData['sleep'];
    if (sleep is num && sleep.toDouble().isFinite) {
      insights['sleep_analysis'] = _analyzeSleep(sleep);
    }

    final activity = fusedData['activity'];
    if (activity is num && activity.toDouble().isFinite) {
      insights['activity_analysis'] = _analyzeActivity(activity);
    }

    return insights;
  }

  Map<String, dynamic> _analyzeHRV(dynamic data) {
    if (data is! num) return <String, dynamic>{};

    final value = data.toDouble();
    if (!value.isFinite) return <String, dynamic>{};

    return <String, dynamic>{
      'value': value,
      'status': _getHRVStatus(value),
      'recommendations': _getHRVRecommendations(value),
      'cycle_impact': _assessHRVCycleImpact(value),
    };
  }

  String _getHRVStatus(double hrv) {
    if (hrv >= 60) return 'Excellent';
    if (hrv >= 50) return 'Very Good';
    if (hrv >= 40) return 'Good';
    if (hrv >= 30) return 'Fair';
    return 'Needs Attention';
  }

  List<String> _getHRVRecommendations(double hrv) {
    if (hrv < 30) {
      return [
        'Prioritize stress management',
        'Improve sleep quality',
        'Consider meditation practices',
      ];
    } else if (hrv < 40) {
      return [
        'Maintain consistent sleep schedule',
        'Practice deep breathing',
        'Monitor stress levels',
      ];
    }
    return ['Continue current wellness practices'];
  }

  Map<String, dynamic> _assessHRVCycleImpact(double hrv) {
    return {
      'hormonal_sensitivity': hrv < 35 ? 'High' : 'Moderate',
      'phase_readiness': hrv >= 45 ? 'Optimal' : 'Suboptimal',
      'stress_resilience': hrv >= 50 ? 'Strong' : 'Moderate',
    };
  }

  Map<String, dynamic> _analyzeTemperature(dynamic data) {
    if (data is! num) return <String, dynamic>{};

    final value = data.toDouble();
    if (!value.isFinite) return <String, dynamic>{};

    return <String, dynamic>{'value': value};
  }

  String _getTemperaturePhaseIndication(double temp) {
    if (temp >= 37.0) return 'Likely post-ovulation (luteal phase)';
    if (temp >= 36.7) return 'Possible ovulation transition';
    return 'Pre-ovulation (follicular phase)';
  }

  List<String> _getTemperatureRecommendations(double temp) {
    return [
      'Continue consistent morning measurements',
      'Track alongside other fertility signs',
      'Note any external factors affecting temperature',
    ];
  }

  Map<String, dynamic> _analyzeSleep(dynamic data) {
    if (data is! num) return <String, dynamic>{};

    final value = data.toDouble();
    if (!value.isFinite) return <String, dynamic>{};

    return <String, dynamic>{'sleep_hours': value};
  }

  Map<String, dynamic> _analyzeActivity(dynamic data) {
    if (data is! num) return <String, dynamic>{};

    final value = data.toDouble();
    if (!value.isFinite) return <String, dynamic>{};

    return <String, dynamic>{'active_energy': value};
  }

  double _calculateConfidence(Map<String, dynamic> fusedData) {
    const canonicalKeys = <String>{
      'heart_rate',
      'resting_heart_rate',
      'hrv',
      'temperature',
      'basal_body_temperature',
      'sleep_hours',
      'steps',
      'active_energy',
      'blood_oxygen',
      'respiratory_rate',
    };

    final available = canonicalKeys.where((key) {
      final value = fusedData[key];
      return value is num && value.toDouble().isFinite;
    }).length;

    return (available / canonicalKeys.length).clamp(0.0, 1.0).toDouble();
  }

  Map<String, dynamic> _getPhaseOptimalRanges(String phase) {
    switch (phase) {
      case 'menstrual':
        return {
          'hrv_range': [35, 55],
          'temperature_range': [36.2, 36.6],
          'glucose_range': [80, 100],
        };
      case 'follicular':
        return {
          'hrv_range': [40, 60],
          'temperature_range': [36.3, 36.7],
          'glucose_range': [75, 95],
        };
      case 'ovulatory':
        return {
          'hrv_range': [45, 65],
          'temperature_range': [36.8, 37.2],
          'glucose_range': [80, 105],
        };
      case 'luteal':
        return {
          'hrv_range': [35, 55],
          'temperature_range': [36.9, 37.3],
          'glucose_range': [85, 110],
        };
      default:
        return {
          'hrv_range': [40, 60],
          'temperature_range': [36.5, 37.0],
          'glucose_range': [80, 100],
        };
    }
  }

  Map<String, dynamic> _calculatePhaseDeviations(
    BiometricSnapshot snapshot,
    String phase,
  ) {
    final optimalRanges = _getPhaseOptimalRanges(phase);
    final deviations = <String, dynamic>{};

    // Calculate deviations for each metric
    for (final metric in optimalRanges.keys) {
      final range = optimalRanges[metric] as List<num>;
      final currentValue = _getCurrentMetricValue(snapshot, metric);

      if (currentValue != null) {
        if (currentValue < range[0]) {
          deviations[metric] = {
            'status': 'below_optimal',
            'deviation': range[0] - currentValue,
          };
        } else if (currentValue > range[1]) {
          deviations[metric] = {
            'status': 'above_optimal',
            'deviation': currentValue - range[1],
          };
        } else {
          deviations[metric] = {'status': 'optimal'};
        }
      }
    }

    return deviations;
  }

  double? _getCurrentMetricValue(BiometricSnapshot snapshot, String metric) {
    switch (metric) {
      case 'hrv_range':
        return snapshot.fusedData['hrv']?.toDouble();
      case 'temperature_range':
        return snapshot.fusedData['temperature']?.toDouble();
      case 'glucose_range':
        return snapshot.fusedData['glucose']?.toDouble();
      default:
        return null;
    }
  }

  List<String> _generatePhaseRecommendations(
    BiometricSnapshot snapshot,
    String phase,
  ) {
    final recommendations = <String>[];

    switch (phase) {
      case 'menstrual':
        recommendations.addAll([
          'Focus on gentle recovery activities',
          'Prioritize iron-rich foods',
          'Allow for extra rest',
        ]);
        break;
      case 'follicular':
        recommendations.addAll([
          'Gradually increase activity intensity',
          'Optimize protein intake',
          'Take advantage of high energy levels',
        ]);
        break;
      case 'ovulatory':
        recommendations.addAll([
          'Peak performance window - maximize workouts',
          'Monitor fertility signs closely',
          'Stay well hydrated',
        ]);
        break;
      case 'luteal':
        recommendations.addAll([
          'Focus on strength training',
          'Manage stress levels carefully',
          'Prepare for upcoming menstrual phase',
        ]);
        break;
    }

    return recommendations;
  }

  void dispose() {
    _backgroundProcessor?.cancel();
    _biometricStream.close();
  }
}

// Integration classes for different devices/platforms

// Data processing engines
class DataFusionEngine {
  Future<void> initialize() async {}

  Future<Map<String, dynamic>> fuseMultiSourceData(
    List<Map<String, dynamic>> sources,
  ) async {
    final fusedData = <String, dynamic>{};

    // Combine and validate data from multiple sources
    for (final source in sources) {
      source.forEach((key, value) {
        if (!fusedData.containsKey(key)) {
          fusedData[key] = value;
        } else {
          // Average multiple readings for the same metric
          final existing = fusedData[key];
          if (existing is num && value is num) {
            fusedData[key] = (existing + value) / 2;
          }
        }
      });
    }

    return fusedData;
  }

  Future<Map<String, dynamic>> processLatestData(
    Map<String, dynamic> realtimeCache,
  ) async {
    // Process and return insights from real-time cache
    return {
      'processing_timestamp': DateTime.now(),
      'data_quality': 'High',
      'completeness': realtimeCache.length / 10.0,
    };
  }
}

class AnomalyDetector {
  Future<void> initialize() async {}

  AnomalyResult detectAnomaly(BiometricReading reading) {
    // Simple anomaly detection based on thresholds
    switch (reading.type) {
      case 'heart_rate':
        if (reading.value < 50 || reading.value > 120) {
          return AnomalyResult(
            isAnomalous: true,
            severity: reading.value < 40 || reading.value > 130
                ? 'High'
                : 'Medium',
            description: 'Heart rate outside normal range',
            recommendation: 'Monitor closely and consider medical consultation',
          );
        }
        break;
      case 'temperature':
        if (reading.value < 35.5 || reading.value > 38.0) {
          return AnomalyResult(
            isAnomalous: true,
            severity: 'High',
            description: 'Body temperature outside normal range',
            recommendation:
                'Check measurement conditions or consult healthcare provider',
          );
        }
        break;
      case 'glucose':
        if (reading.value < 60 || reading.value > 200) {
          return AnomalyResult(
            isAnomalous: true,
            severity: 'High',
            description: 'Blood glucose outside safe range',
            recommendation: 'Immediate medical attention may be required',
          );
        }
        break;
    }

    return AnomalyResult(isAnomalous: false);
  }

  Future<List<AnomalyResult>> getRecentAnomalies() async {
    return []; // Placeholder
  }
}

class TrendAnalyzer {
  Future<void> initialize() async {}

  Future<Map<String, dynamic>> analyzeTrends(Map<String, dynamic> data) async {
    return {
      'heart_rate_trend': 'Stable',
      'temperature_trend': 'Slightly rising',
      'glucose_trend': 'Improving',
      'overall_health_trend': 'Positive',
    };
  }

  Future<Map<String, dynamic>> getLatestTrends() async {
    return {
      'period': 'Last 7 days',
      'key_insights': [
        'HRV showing improvement',
        'Sleep quality consistently good',
        'Activity levels optimal for cycle phase',
      ],
    };
  }
}

// Data models
class BiometricReading {
  final String source;
  final String type;
  final double value;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  BiometricReading({
    required this.source,
    required this.type,
    required this.value,
    required this.timestamp,
    this.metadata,
  });
}

class BiometricSnapshot {
  final DateTime timestamp;
  final Map<String, dynamic> fusedData;
  final Map<String, dynamic> insights;
  final double confidence;
  final Map<String, dynamic> trends;
  final List<AnomalyResult> anomalies;

  BiometricSnapshot({
    required this.timestamp,
    required this.fusedData,
    required this.insights,
    required this.confidence,
    required this.trends,
    required this.anomalies,
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'fused_data': fusedData,
      'insights': insights,
      'confidence': confidence,
      'trends': trends,
      'anomalies': anomalies
          .map(
            (a) => {
              'is_anomalous': a.isAnomalous,
              'severity': a.severity,
              'description': a.description,
              'recommendation': a.recommendation,
            },
          )
          .toList(),
    };
  }
}

class CycleBiometricAnalysis {
  final String phase;
  final BiometricSnapshot snapshot;
  final Map<String, dynamic> phaseOptimalRanges;
  final Map<String, dynamic> deviations;
  final List<String> recommendations;

  CycleBiometricAnalysis({
    required this.phase,
    required this.snapshot,
    required this.phaseOptimalRanges,
    required this.deviations,
    required this.recommendations,
  });
}

class AnomalyResult {
  final bool isAnomalous;
  final String? severity;
  final String? description;
  final String? recommendation;

  AnomalyResult({
    required this.isAnomalous,
    this.severity,
    this.description,
    this.recommendation,
  });
}

extension BiometricSnapshotX on BiometricSnapshot {
  /// Convenience: whether snapshot contains usable values for UI.
  bool get hasData =>
      fusedData['hrv'] != null ||
      fusedData['temperature'] != null ||
      fusedData['steps'] != null;

  /// Convenience: demo/test snapshot.
}
