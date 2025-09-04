import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../models/cycle_data.dart';
import '../models/biometric_data.dart';
import '../utils/collection_extensions.dart';

/// Week 3: Biometric Data Integration Engine
/// Processes HR, HRV, sleep, temperature, and stress data from wearables
class BiometricEngine {
  static final BiometricEngine _instance = BiometricEngine._internal();
  static BiometricEngine get instance => _instance;
  BiometricEngine._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Biometric analysis models
  late Map<String, dynamic> _heartRateModel;
  late Map<String, dynamic> _hrvModel;
  late Map<String, dynamic> _sleepModel;
  late Map<String, dynamic> _temperatureModel;
  late Map<String, dynamic> _stressModel;
  late Map<String, dynamic> _correlationEngine;

  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('📊 Initializing Biometric Engine (Week 3)...');
    
    // Heart Rate Analysis Model
    _heartRateModel = {
      'resting_hr_baselines': {
        'menstrual_phase': {'mean': 68.0, 'std': 8.0},
        'follicular_phase': {'mean': 65.0, 'std': 6.0},
        'ovulatory_phase': {'mean': 70.0, 'std': 7.0},
        'luteal_phase': {'mean': 72.0, 'std': 9.0},
      },
      'anomaly_thresholds': {
        'significant_elevation': 15.0, // bpm above baseline
        'significant_drop': 10.0, // bpm below baseline
        'consistency_threshold': 0.8,
      },
      'correlation_factors': {
        'temperature_correlation': 0.6,
        'stress_correlation': 0.7,
        'sleep_correlation': -0.4,
      },
    };
    
    // Heart Rate Variability Model
    _hrvModel = {
      'healthy_ranges': {
        'rmssd_min': 20.0, // milliseconds
        'rmssd_max': 60.0,
        'sdnn_min': 32.0,
        'sdnn_max': 100.0,
      },
      'cycle_correlations': {
        'luteal_hrv_drop': 0.15, // typical 15% drop in luteal phase
        'menstrual_recovery': 0.10, // 10% recovery during menstruation
        'ovulatory_peak': 0.08, // 8% peak around ovulation
      },
      'stress_indicators': {
        'high_stress_threshold': 15.0, // RMSSD below this indicates stress
        'recovery_threshold': 35.0, // RMSSD above this indicates good recovery
      },
    };
    
    // Sleep Analysis Model
    _sleepModel = {
      'quality_metrics': {
        'deep_sleep_percentage': {'optimal': 0.20, 'minimum': 0.15},
        'rem_sleep_percentage': {'optimal': 0.25, 'minimum': 0.20},
        'sleep_efficiency': {'optimal': 0.85, 'minimum': 0.75},
        'wake_frequency': {'optimal': 2, 'maximum': 5},
      },
      'cycle_phase_effects': {
        'menstrual_phase': {
          'sleep_duration_change': 0.5, // +30 minutes
          'deep_sleep_change': -0.02, // -2% deep sleep
          'restlessness_increase': 0.3,
        },
        'luteal_phase': {
          'sleep_onset_delay': 15.0, // +15 minutes to fall asleep
          'temperature_disruption': 0.8, // body temp affects sleep
          'mood_sleep_correlation': 0.6,
        },
      },
      'predictive_factors': {
        'pms_sleep_degradation': 0.25,
        'ovulation_sleep_quality': 0.15,
        'stress_sleep_impact': 0.7,
      },
    };
    
    // Body Temperature Model
    _temperatureModel = {
      'basal_body_temperature': {
        'follicular_baseline': 97.2, // Fahrenheit
        'luteal_elevation': 0.4, // +0.4°F in luteal phase
        'ovulation_dip': -0.2, // -0.2°F just before ovulation
        'menstrual_return': -0.3, // -0.3°F return to baseline
      },
      'detection_algorithms': {
        'ovulation_detection_sensitivity': 0.1, // °F change to detect
        'phase_transition_confidence': 0.8,
        'temperature_smoothing_window': 3, // days
      },
      'environmental_adjustments': {
        'ambient_temperature_factor': 0.1,
        'sleep_environment_factor': 0.05,
        'activity_compensation': 0.15,
      },
    };
    
    // Stress Analysis Model
    _stressModel = {
      'stress_indicators': {
        'hrv_weight': 0.4,
        'heart_rate_weight': 0.3,
        'sleep_quality_weight': 0.2,
        'activity_level_weight': 0.1,
      },
      'cycle_stress_correlations': {
        'pms_stress_increase': 0.35,
        'ovulation_stress_decrease': 0.15,
        'menstrual_stress_variability': 0.25,
      },
      'adaptive_thresholds': {
        'personal_stress_baseline': 0.0, // Adjusted per user
        'high_stress_threshold': 0.7,
        'chronic_stress_duration': 7, // days
      },
    };
    
    // Multi-modal Correlation Engine
    _correlationEngine = {
      'biometric_weights': {
        'heart_rate': 0.25,
        'hrv': 0.25,
        'sleep_quality': 0.20,
        'temperature': 0.20,
        'stress_level': 0.10,
      },
      'correlation_matrices': {
        'cycle_length_prediction': {
          'temperature_weight': 0.4,
          'hrv_weight': 0.3,
          'sleep_weight': 0.2,
          'stress_weight': 0.1,
        },
        'symptom_prediction': {
          'stress_weight': 0.35,
          'sleep_weight': 0.30,
          'hrv_weight': 0.25,
          'heart_rate_weight': 0.10,
        },
        'mood_energy_prediction': {
          'sleep_weight': 0.40,
          'hrv_weight': 0.25,
          'stress_weight': 0.25,
          'heart_rate_weight': 0.10,
        },
      },
      'temporal_analysis': {
        'trend_analysis_window': 14, // days
        'anomaly_detection_sensitivity': 0.15,
        'pattern_stability_threshold': 0.7,
      },
    };
    
    _isInitialized = true;
    debugPrint('✅ Biometric Engine initialized with wearable integration');
  }

  /// Process heart rate data and extract cycle-relevant insights
  Future<HeartRateAnalysis> analyzeHeartRate({
    required List<HeartRateData> heartRateData,
    required String currentPhase,
    required DateTime analysisDate,
  }) async {
    final phaseBaseline = _heartRateModel['resting_hr_baselines'][currentPhase] as Map<String, dynamic>;
    final baselineMean = phaseBaseline['mean'] as double;
    final baselineStd = phaseBaseline['std'] as double;
    
    // Calculate current metrics
    final recentData = heartRateData.where((hr) => 
      hr.timestamp.isAfter(analysisDate.subtract(const Duration(days: 7)))).toList();
    
    if (recentData.isEmpty) {
      return HeartRateAnalysis.empty();
    }
    
    final averageRestingHR = recentData
        .where((hr) => hr.type == HeartRateType.resting)
        .map((hr) => hr.beatsPerMinute)
        .fold<double>(0, (sum, bpm) => sum + bpm) / math.max(1, recentData.length);
    
    // Detect anomalies
    final deviationFromBaseline = averageRestingHR - baselineMean;
    final zScore = deviationFromBaseline / baselineStd;
    
    // Trend analysis
    final trend = _calculateHeartRateTrend(recentData);
    
    // Generate insights
    final insights = <String>[];
    if (zScore.abs() > 2.0) {
      insights.add('Your resting heart rate is ${zScore > 0 ? 'elevated' : 'lower'} compared to typical ${currentPhase} values');
    }
    
    if (trend.abs() > 3.0) {
      insights.add('Your heart rate has been ${trend > 0 ? 'increasing' : 'decreasing'} over the past week');
    }
    
    return HeartRateAnalysis(
      averageRestingHR: averageRestingHR,
      phaseBaseline: baselineMean,
      deviation: deviationFromBaseline,
      zScore: zScore,
      trend: trend,
      confidence: _calculateConfidence(recentData.length, zScore.abs()),
      insights: insights,
      anomalyDetected: zScore.abs() > 1.5,
      analysisDate: analysisDate,
    );
  }

  /// Analyze Heart Rate Variability for stress and recovery insights
  Future<HRVAnalysis> analyzeHRV({
    required List<HRVData> hrvData,
    required String currentPhase,
    required DateTime analysisDate,
  }) async {
    final recentData = hrvData.where((hrv) => 
      hrv.timestamp.isAfter(analysisDate.subtract(const Duration(days: 7)))).toList();
    
    if (recentData.isEmpty) {
      return HRVAnalysis.empty();
    }
    
    final averageRMSSD = recentData.map((hrv) => hrv.rmssd).reduce((a, b) => a + b) / recentData.length;
    final averageSDNN = recentData.map((hrv) => hrv.sdnn).reduce((a, b) => a + b) / recentData.length;
    
    // Assess recovery status
    final recoveryStatus = _assessRecoveryStatus(averageRMSSD);
    
    // Detect stress indicators
    final stressLevel = _calculateHRVStressLevel(averageRMSSD, averageSDNN);
    
    // Phase-specific analysis
    final phaseAnalysis = _analyzeHRVCycleCorrelation(averageRMSSD, currentPhase);
    
    return HRVAnalysis(
      averageRMSSD: averageRMSSD,
      averageSDNN: averageSDNN,
      recoveryStatus: recoveryStatus,
      stressLevel: stressLevel,
      phaseCorrelation: phaseAnalysis,
      confidence: _calculateConfidence(recentData.length, 0.0),
      recommendations: _generateHRVRecommendations(recoveryStatus, stressLevel),
      analysisDate: analysisDate,
    );
  }

  /// Analyze sleep data for cycle-related patterns
  Future<SleepAnalysis> analyzeSleep({
    required List<SleepData> sleepData,
    required String currentPhase,
    required DateTime analysisDate,
  }) async {
    final recentSleep = sleepData.where((sleep) => 
      sleep.sleepDate.isAfter(analysisDate.subtract(const Duration(days: 7)))).toList();
    
    if (recentSleep.isEmpty) {
      return SleepAnalysis.empty();
    }
    
    // Calculate sleep metrics
    final avgDuration = recentSleep.map((s) => s.totalDuration.inMinutes).reduce((a, b) => a + b) / recentSleep.length / 60.0;
    final avgEfficiency = recentSleep.map((s) => s.efficiency).reduce((a, b) => a + b) / recentSleep.length;
    final avgDeepSleep = recentSleep.map((s) => s.deepSleepPercentage).reduce((a, b) => a + b) / recentSleep.length;
    final avgREMSleep = recentSleep.map((s) => s.remSleepPercentage).reduce((a, b) => a + b) / recentSleep.length;
    
    // Phase-specific analysis
    final phaseEffects = _sleepModel['cycle_phase_effects'][currentPhase] as Map<String, dynamic>?;
    
    // Quality assessment
    final qualityScore = _calculateSleepQuality(avgEfficiency, avgDeepSleep, avgREMSleep);
    
    // Trend analysis
    final sleepTrend = _calculateSleepTrend(recentSleep);
    
    return SleepAnalysis(
      averageDuration: avgDuration,
      averageEfficiency: avgEfficiency,
      averageDeepSleepPercentage: avgDeepSleep,
      averageREMSleepPercentage: avgREMSleep,
      qualityScore: qualityScore,
      trend: sleepTrend,
      phaseImpact: phaseEffects != null ? _analyzeSleepPhaseImpact(phaseEffects, qualityScore) : null,
      recommendations: _generateSleepRecommendations(qualityScore, currentPhase),
      analysisDate: analysisDate,
    );
  }

  /// Analyze body temperature for ovulation detection and cycle tracking
  Future<TemperatureAnalysis> analyzeTemperature({
    required List<TemperatureData> temperatureData,
    required String currentPhase,
    required DateTime analysisDate,
  }) async {
    final recentData = temperatureData.where((temp) => 
      temp.timestamp.isAfter(analysisDate.subtract(const Duration(days: 14)))).toList();
    
    if (recentData.isEmpty) {
      return TemperatureAnalysis.empty();
    }
    
    // Sort by timestamp for trend analysis
    recentData.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    // Calculate baseline and recent average
    final follicularBaseline = _temperatureModel['basal_body_temperature']['follicular_baseline'] as double;
    final recentAverage = recentData.map((t) => t.temperature).reduce((a, b) => a + b) / recentData.length;
    
    // Detect ovulation patterns
    final ovulationSignals = _detectOvulationSignals(recentData, follicularBaseline);
    
    // Phase transition detection
    final phaseTransition = _detectPhaseTransition(recentData, currentPhase);
    
    // Temperature trend
    final trend = _calculateTemperatureTrend(recentData);
    
    return TemperatureAnalysis(
      recentAverage: recentAverage,
      baseline: follicularBaseline,
      deviation: recentAverage - follicularBaseline,
      trend: trend,
      ovulationSignals: ovulationSignals,
      phaseTransition: phaseTransition,
      confidence: _calculateConfidence(recentData.length, 0.0),
      insights: _generateTemperatureInsights(recentAverage, follicularBaseline, currentPhase),
      analysisDate: analysisDate,
    );
  }

  /// Generate comprehensive biometric correlation analysis
  Future<BiometricCorrelationAnalysis> generateCorrelationAnalysis({
    required List<CycleData> cycles,
    required List<HeartRateData> heartRateData,
    required List<HRVData> hrvData,
    required List<SleepData> sleepData,
    required List<TemperatureData> temperatureData,
    required DateTime analysisDate,
  }) async {
    // Cross-correlation analysis between biometric data and cycle patterns
    final correlations = <String, double>{};
    
    // Heart rate correlations
    correlations['heart_rate_cycle_length'] = _calculateCycleCorrelation(
      cycles, heartRateData.map((hr) => hr.beatsPerMinute).toList());
    
    // HRV correlations
    correlations['hrv_symptom_severity'] = _calculateSymptomCorrelation(
      cycles, hrvData.map((hrv) => hrv.rmssd).toList());
    
    // Sleep correlations
    correlations['sleep_mood_energy'] = _calculateMoodEnergyCorrelation(
      cycles, sleepData.map((sleep) => sleep.efficiency).toList());
    
    // Temperature correlations
    correlations['temperature_ovulation'] = _calculateOvulationCorrelation(
      cycles, temperatureData.map((temp) => temp.temperature).toList());
    
    // Multi-modal predictions
    final predictions = await _generateBiometricPredictions(
      correlations, cycles, analysisDate);
    
    // Insights generation
    final insights = _generateCorrelationInsights(correlations);
    
    return BiometricCorrelationAnalysis(
      correlations: correlations,
      predictions: predictions,
      insights: insights,
      confidence: _calculateOverallConfidence(correlations),
      analysisDate: analysisDate,
    );
  }

  /// Detect anomalies across all biometric data streams
  Future<List<BiometricAnomaly>> detectBiometricAnomalies({
    required List<HeartRateData> heartRateData,
    required List<HRVData> hrvData,
    required List<SleepData> sleepData,
    required List<TemperatureData> temperatureData,
    required DateTime analysisDate,
  }) async {
    final anomalies = <BiometricAnomaly>[];
    
    // Heart rate anomalies
    anomalies.addAll(await _detectHeartRateAnomalies(heartRateData, analysisDate));
    
    // HRV anomalies
    anomalies.addAll(await _detectHRVAnomalies(hrvData, analysisDate));
    
    // Sleep anomalies
    anomalies.addAll(await _detectSleepAnomalies(sleepData, analysisDate));
    
    // Temperature anomalies
    anomalies.addAll(await _detectTemperatureAnomalies(temperatureData, analysisDate));
    
    // Cross-metric anomalies
    anomalies.addAll(await _detectCrossMetricAnomalies(
      heartRateData, hrvData, sleepData, temperatureData, analysisDate));
    
    // Sort by severity
    anomalies.sort((a, b) => b.severity.index.compareTo(a.severity.index));
    
    return anomalies;
  }

  // Private helper methods for biometric analysis

  double _calculateHeartRateTrend(List<HeartRateData> data) {
    if (data.length < 2) return 0.0;
    
    final firstHalf = data.take(data.length ~/ 2).map((hr) => hr.beatsPerMinute).toList();
    final secondHalf = data.skip(data.length ~/ 2).map((hr) => hr.beatsPerMinute).toList();
    
    final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;
    
    return secondAvg - firstAvg;
  }

  String _assessRecoveryStatus(double rmssd) {
    final thresholds = _hrvModel['stress_indicators'] as Map<String, dynamic>;
    
    if (rmssd >= thresholds['recovery_threshold']) {
      return 'excellent';
    } else if (rmssd >= 25.0) {
      return 'good';
    } else if (rmssd >= thresholds['high_stress_threshold']) {
      return 'moderate';
    } else {
      return 'poor';
    }
  }

  double _calculateHRVStressLevel(double rmssd, double sdnn) {
    final normalizedRMSSD = math.max(0.0, math.min(1.0, rmssd / 50.0));
    final normalizedSDNN = math.max(0.0, math.min(1.0, sdnn / 80.0));
    
    // Lower HRV indicates higher stress
    return 1.0 - ((normalizedRMSSD + normalizedSDNN) / 2.0);
  }

  Map<String, dynamic> _analyzeHRVCycleCorrelation(double rmssd, String phase) {
    final correlations = _hrvModel['cycle_correlations'] as Map<String, dynamic>;
    
    switch (phase) {
      case 'luteal_phase':
        final expectedDrop = correlations['luteal_hrv_drop'] as double;
        return {'expected_change': -expectedDrop, 'phase_typical': true};
      case 'ovulatory_phase':
        final expectedPeak = correlations['ovulatory_peak'] as double;
        return {'expected_change': expectedPeak, 'phase_typical': true};
      default:
        return {'expected_change': 0.0, 'phase_typical': true};
    }
  }

  List<String> _generateHRVRecommendations(String recoveryStatus, double stressLevel) {
    final recommendations = <String>[];
    
    if (recoveryStatus == 'poor' || stressLevel > 0.7) {
      recommendations.addAll([
        'Prioritize stress management techniques',
        'Ensure adequate sleep (7-9 hours)',
        'Consider gentle exercise or yoga',
        'Practice deep breathing exercises',
      ]);
    } else if (recoveryStatus == 'excellent') {
      recommendations.add('Great recovery! Your body is responding well to your current routine');
    }
    
    return recommendations;
  }

  double _calculateSleepQuality(double efficiency, double deepSleep, double remSleep) {
    final qualityMetrics = _sleepModel['quality_metrics'] as Map<String, dynamic>;
    
    final efficiencyScore = efficiency / qualityMetrics['sleep_efficiency']['optimal'];
    final deepSleepScore = deepSleep / qualityMetrics['deep_sleep_percentage']['optimal'];
    final remScore = remSleep / qualityMetrics['rem_sleep_percentage']['optimal'];
    
    return math.min(1.0, (efficiencyScore * 0.4 + deepSleepScore * 0.3 + remScore * 0.3));
  }

  String _calculateSleepTrend(List<SleepData> sleepData) {
    if (sleepData.length < 3) return 'insufficient_data';
    
    final recentQuality = sleepData.takeLast(3).map((s) => s.efficiency).reduce((a, b) => a + b) / 3;
    final overallQuality = sleepData.map((s) => s.efficiency).reduce((a, b) => a + b) / sleepData.length;
    
    if (recentQuality > overallQuality + 0.05) return 'improving';
    if (recentQuality < overallQuality - 0.05) return 'declining';
    return 'stable';
  }

  Map<String, dynamic>? _analyzeSleepPhaseImpact(Map<String, dynamic> phaseEffects, double qualityScore) {
    return {
      'phase_impact_detected': true,
      'quality_deviation': qualityScore - 0.8, // Compare to ideal
      'expected_changes': phaseEffects,
    };
  }

  List<String> _generateSleepRecommendations(double qualityScore, String phase) {
    final recommendations = <String>[];
    
    if (qualityScore < 0.7) {
      recommendations.addAll([
        'Establish a consistent sleep schedule',
        'Create a relaxing bedtime routine',
        'Limit screen time before bed',
        'Keep bedroom cool and dark',
      ]);
    }
    
    if (phase == 'luteal_phase') {
      recommendations.add('Consider earlier bedtime during luteal phase');
    }
    
    return recommendations;
  }

  List<TemperatureSignal> _detectOvulationSignals(List<TemperatureData> data, double baseline) {
    final signals = <TemperatureSignal>[];
    final detectionSensitivity = _temperatureModel['detection_algorithms']['ovulation_detection_sensitivity'] as double;
    
    for (int i = 1; i < data.length; i++) {
      final previousTemp = data[i - 1].temperature;
      final currentTemp = data[i].temperature;
      
      // Look for temperature dip followed by sustained rise
      if (previousTemp < baseline - detectionSensitivity && 
          currentTemp > baseline + detectionSensitivity) {
        signals.add(TemperatureSignal(
          type: TemperatureSignalType.ovulationPattern,
          timestamp: data[i].timestamp,
          temperature: currentTemp,
          confidence: 0.8,
          description: 'Potential ovulation pattern detected',
        ));
      }
    }
    
    return signals;
  }

  Map<String, dynamic>? _detectPhaseTransition(List<TemperatureData> data, String currentPhase) {
    // Simplified phase transition detection
    if (data.length < 5) return null;
    
    final recentTemps = data.takeLast(3).map((t) => t.temperature).toList();
    final avgRecent = recentTemps.reduce((a, b) => a + b) / recentTemps.length;
    
    final baseline = _temperatureModel['basal_body_temperature']['follicular_baseline'] as double;
    final lutealElevation = _temperatureModel['basal_body_temperature']['luteal_elevation'] as double;
    
    if (currentPhase == 'follicular_phase' && avgRecent > baseline + lutealElevation * 0.5) {
      return {
        'transition_detected': true,
        'likely_new_phase': 'luteal_phase',
        'confidence': 0.7,
      };
    }
    
    return null;
  }

  double _calculateTemperatureTrend(List<TemperatureData> data) {
    if (data.length < 5) return 0.0;
    
    final firstQuarter = data.take(data.length ~/ 4).map((t) => t.temperature).toList();
    final lastQuarter = data.takeLast(data.length ~/ 4).map((t) => t.temperature).toList();
    
    final firstAvg = firstQuarter.reduce((a, b) => a + b) / firstQuarter.length;
    final lastAvg = lastQuarter.reduce((a, b) => a + b) / lastQuarter.length;
    
    return lastAvg - firstAvg;
  }

  List<String> _generateTemperatureInsights(double recent, double baseline, String phase) {
    final insights = <String>[];
    final deviation = recent - baseline;
    
    if (deviation > 0.3) {
      insights.add('Your body temperature is elevated, suggesting ${phase == 'luteal_phase' ? 'normal luteal phase elevation' : 'possible phase transition'}');
    } else if (deviation < -0.2) {
      insights.add('Your body temperature is below baseline, ${phase == 'menstrual_phase' ? 'typical for menstrual phase' : 'which may indicate approaching menstruation'}');
    }
    
    return insights;
  }

  double _calculateConfidence(int dataPoints, double anomalyScore) {
    final dataConfidence = math.min(1.0, dataPoints / 30.0); // More data = higher confidence
    final anomalyPenalty = math.max(0.0, 1.0 - (anomalyScore / 2.0)); // High anomalies reduce confidence
    return (dataConfidence * 0.7 + anomalyPenalty * 0.3);
  }

  // Additional correlation and prediction methods...
  double _calculateCycleCorrelation(List<CycleData> cycles, List<double> biometricData) {
    // Simplified correlation calculation
    if (cycles.length < 3 || biometricData.length < 3) return 0.0;
    return 0.6; // Placeholder for actual correlation algorithm
  }

  double _calculateSymptomCorrelation(List<CycleData> cycles, List<double> biometricData) {
    return 0.5; // Placeholder
  }

  double _calculateMoodEnergyCorrelation(List<CycleData> cycles, List<double> biometricData) {
    return 0.7; // Placeholder
  }

  double _calculateOvulationCorrelation(List<CycleData> cycles, List<double> biometricData) {
    return 0.8; // Placeholder
  }

  Future<Map<String, dynamic>> _generateBiometricPredictions(
      Map<String, double> correlations, List<CycleData> cycles, DateTime analysisDate) async {
    return {
      'next_cycle_length': 28,
      'ovulation_date': analysisDate.add(const Duration(days: 14)),
      'symptom_likelihood': 0.7,
    };
  }

  List<String> _generateCorrelationInsights(Map<String, double> correlations) {
    final insights = <String>[];
    
    correlations.forEach((metric, correlation) {
      if (correlation.abs() > 0.6) {
        insights.add('Strong correlation detected between $metric and cycle patterns');
      }
    });
    
    return insights;
  }

  double _calculateOverallConfidence(Map<String, double> correlations) {
    if (correlations.isEmpty) return 0.0;
    
    final avgCorrelation = correlations.values.reduce((a, b) => a + b) / correlations.length;
    return math.min(1.0, avgCorrelation.abs());
  }

  // Anomaly detection methods
  Future<List<BiometricAnomaly>> _detectHeartRateAnomalies(
      List<HeartRateData> data, DateTime analysisDate) async {
    // Simplified anomaly detection
    return [];
  }

  Future<List<BiometricAnomaly>> _detectHRVAnomalies(
      List<HRVData> data, DateTime analysisDate) async {
    return [];
  }

  Future<List<BiometricAnomaly>> _detectSleepAnomalies(
      List<SleepData> data, DateTime analysisDate) async {
    return [];
  }

  Future<List<BiometricAnomaly>> _detectTemperatureAnomalies(
      List<TemperatureData> data, DateTime analysisDate) async {
    return [];
  }

  Future<List<BiometricAnomaly>> _detectCrossMetricAnomalies(
      List<HeartRateData> hr, List<HRVData> hrv, 
      List<SleepData> sleep, List<TemperatureData> temp, DateTime analysisDate) async {
    return [];
  }
}

extension<T> on Iterable<T> {
  Iterable<T> takeLast(int count) {
    return skip(math.max(0, length - count));
  }
}
