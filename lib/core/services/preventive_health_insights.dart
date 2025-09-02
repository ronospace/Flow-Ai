import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../models/cycle_data.dart';
import '../models/user_profile.dart';
import '../models/health_insights.dart';

/// Blueprint Implementation: Preventive Health Insights
/// Early warnings for PCOS, thyroid issues, endometriosis patterns
/// Personalized alerts: "Your last 3 cycles suggest a hormonal shift"
/// Fertility health optimization
class PreventiveHealthInsights {
  static final PreventiveHealthInsights _instance = PreventiveHealthInsights._internal();
  static PreventiveHealthInsights get instance => _instance;
  PreventiveHealthInsights._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Medical condition detection models
  late Map<String, dynamic> _pcosDetectionModel;
  late Map<String, dynamic> _thyroidAnalysisModel;
  late Map<String, dynamic> _endometriosisDetectionModel;
  late Map<String, dynamic> _fertilityOptimizationModel;
  late Map<String, dynamic> _hormonalShiftDetectionModel;

  // Risk assessment parameters
  late Map<String, List<String>> _medicalConditionMarkers;
  late Map<String, Map<String, double>> _riskFactorWeights;
  late Map<String, List<String>> _warningSignPatterns;

  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('🏥 Initializing Preventive Health Insights...');

    // PCOS Detection Model
    _pcosDetectionModel = {
      'cycle_irregularity_threshold': 8, // days variation
      'cycle_length_pcos_indicator': 35, // days or longer
      'symptom_cluster_analysis': _initializePCOSSymptomClusters(),
      'hormonal_markers': _initializePCOSHormonalMarkers(),
      'metabolic_indicators': _initializePCOSMetabolicIndicators(),
      'confidence_threshold': 0.7,
      'minimum_cycles_for_detection': 6,
    };

    // Thyroid Analysis Model
    _thyroidAnalysisModel = {
      'hypothyroid_indicators': _initializeHypothyroidIndicators(),
      'hyperthyroid_indicators': _initializeHyperthyroidIndicators(),
      'cycle_impact_patterns': _initializeThyroidCyclePatterns(),
      'symptom_correlation_matrix': _initializeThyroidSymptomMatrix(),
      'severity_assessment': _initializeThyroidSeverityLevels(),
    };

    // Endometriosis Detection Model
    _endometriosisDetectionModel = {
      'pain_pattern_analysis': _initializeEndoPainPatterns(),
      'cycle_symptom_correlation': _initializeEndoSymptomCorrelation(),
      'severity_progression': _initializeEndoSeverityProgression(),
      'location_specific_symptoms': _initializeEndoLocationSymptoms(),
      'quality_of_life_impact': _initializeEndoQOLAssessment(),
    };

    // Fertility Optimization Model
    _fertilityOptimizationModel = {
      'ovulation_quality_indicators': _initializeFertilityIndicators(),
      'luteal_phase_assessment': _initializeLutealPhaseAnalysis(),
      'cervical_mucus_patterns': _initializeCervicalMucusAnalysis(),
      'basal_body_temperature': _initializeBBTAnalysis(),
      'lifestyle_fertility_factors': _initializeLifestyleFertilityFactors(),
    };

    // Hormonal Shift Detection Model
    _hormonalShiftDetectionModel = {
      'trend_analysis_window': 3, // cycles
      'significant_change_threshold': 0.25,
      'pattern_deviation_detection': _initializePatternDeviationAnalysis(),
      'early_warning_indicators': _initializeEarlyWarningSystem(),
      'perimenopause_markers': _initializePerimenopauseIndicators(),
    };

    // Initialize medical condition markers
    _initializeMedicalMarkers();

    _isInitialized = true;
    debugPrint('✅ Preventive Health Insights initialized successfully');
  }

  /// Comprehensive health screening for all major reproductive conditions
  Future<HealthScreeningReport> performComprehensiveScreening({
    required List<CycleData> historicalCycles,
    required UserProfile userProfile,
    Map<String, dynamic>? biometricData,
    Map<String, dynamic>? lifestyleData,
  }) async {
    if (!_isInitialized) await initialize();

    debugPrint('🔍 Performing comprehensive health screening...');

    // Individual condition assessments
    final pcosAssessment = await assessPCOSRisk(
      historicalCycles, userProfile, biometricData);
    
    final thyroidAssessment = await assessThyroidFunction(
      historicalCycles, userProfile, biometricData);
    
    final endometriosisAssessment = await assessEndometriosisRisk(
      historicalCycles, userProfile);
    
    final fertilityAssessment = await assessFertilityHealth(
      historicalCycles, userProfile, lifestyleData);
    
    final hormonalAssessment = await assessHormonalShifts(
      historicalCycles, userProfile);

    // Overall risk stratification
    final overallRiskLevel = _calculateOverallRisk([
      pcosAssessment, thyroidAssessment, endometriosisAssessment]);

    // Generate personalized recommendations
    final recommendations = await _generatePreventiveRecommendations([
      pcosAssessment, thyroidAssessment, endometriosisAssessment,
      fertilityAssessment, hormonalAssessment]);

    // Create follow-up schedule
    final followUpSchedule = _createFollowUpSchedule(
      overallRiskLevel, [pcosAssessment, thyroidAssessment, endometriosisAssessment]);

    return HealthScreeningReport(
      userId: userProfile.id,
      screeningDate: DateTime.now(),
      pcosAssessment: pcosAssessment,
      thyroidAssessment: thyroidAssessment,
      endometriosisAssessment: endometriosisAssessment,
      fertilityAssessment: fertilityAssessment,
      hormonalAssessment: hormonalAssessment,
      overallRiskLevel: overallRiskLevel,
      recommendations: recommendations,
      followUpSchedule: followUpSchedule,
      nextScreeningDate: _calculateNextScreeningDate(overallRiskLevel),
    );
  }

  /// Blueprint Feature: PCOS Risk Assessment
  Future<MedicalConditionAssessment> assessPCOSRisk(
    List<CycleData> cycles,
    UserProfile userProfile,
    Map<String, dynamic>? biometricData,
  ) async {
    debugPrint('🔬 Assessing PCOS risk...');

    final riskFactors = <String, double>{};
    final detectedSymptoms = <String>[];
    
    // Cycle irregularity analysis
    if (cycles.length >= 6) {
      final cycleVariability = _calculateCycleVariability(cycles);
      if (cycleVariability > _pcosDetectionModel['cycle_irregularity_threshold']) {
        riskFactors['cycle_irregularity'] = math.min(1.0, cycleVariability / 14.0);
        detectedSymptoms.add('Irregular menstrual cycles');
      }

      // Long cycle detection
      final averageCycleLength = _calculateAverageCycleLength(cycles);
      if (averageCycleLength >= _pcosDetectionModel['cycle_length_pcos_indicator']) {
        riskFactors['long_cycles'] = math.min(1.0, 
          (averageCycleLength - 28) / 15.0);
        detectedSymptoms.add('Prolonged menstrual cycles');
      }
    }

    // Symptom cluster analysis
    final symptomClusters = _analyzePCOSSymptomClusters(cycles);
    riskFactors.addAll(symptomClusters);

    // Metabolic indicators (if biometric data available)
    if (biometricData != null) {
      final metabolicRisk = _analyzeMetabolicIndicators(biometricData);
      riskFactors.addAll(metabolicRisk);
    }

    // Weight and BMI considerations
    if (userProfile.weight != null && userProfile.height != null) {
      final bmi = _calculateBMI(userProfile.weight!, userProfile.height!);
      if (bmi > 25) {
        riskFactors['elevated_bmi'] = math.min(1.0, (bmi - 25) / 15.0);
        detectedSymptoms.add('Elevated BMI');
      }
    }

    // Calculate overall PCOS risk score
    final riskScore = _calculateRiskScore(riskFactors, 'pcos');
    final riskLevel = _determineRiskLevel(riskScore);

    // Generate PCOS-specific recommendations
    final recommendations = _generatePCOSRecommendations(
      riskLevel, riskFactors, detectedSymptoms);

    return MedicalConditionAssessment(
      conditionName: 'PCOS',
      riskScore: riskScore,
      riskLevel: riskLevel,
      riskFactors: riskFactors,
      detectedSymptoms: detectedSymptoms,
      recommendations: recommendations,
      confidenceLevel: _calculateConfidenceLevel(cycles.length, riskFactors),
      requiresMedicalAttention: riskLevel.index >= RiskLevel.moderate.index,
      nextAssessmentDate: _calculateNextAssessmentDate(riskLevel),
    );
  }

  /// Blueprint Feature: Thyroid Function Assessment
  Future<MedicalConditionAssessment> assessThyroidFunction(
    List<CycleData> cycles,
    UserProfile userProfile,
    Map<String, dynamic>? biometricData,
  ) async {
    debugPrint('🦋 Assessing thyroid function...');

    final riskFactors = <String, double>{};
    final detectedSymptoms = <String>[];

    // Hypothyroid indicators
    final hypoIndicators = _analyzeHypothyroidIndicators(cycles);
    if (hypoIndicators['risk_score']! > 0.3) {
      riskFactors['hypothyroid_risk'] = hypoIndicators['risk_score']!;
      detectedSymptoms.addAll(hypoIndicators['symptoms'] as List<String>);
    }

    // Hyperthyroid indicators
    final hyperIndicators = _analyzeHyperthyroidIndicators(cycles);
    if (hyperIndicators['risk_score']! > 0.3) {
      riskFactors['hyperthyroid_risk'] = hyperIndicators['risk_score']!;
      detectedSymptoms.addAll(hyperIndicators['symptoms'] as List<String>);
    }

    // Cycle pattern analysis for thyroid impact
    final cyclePatterns = _analyzeThyroidCycleImpact(cycles);
    riskFactors.addAll(cyclePatterns);

    // Family history consideration
    if (userProfile.familyHistory?.contains('thyroid') == true) {
      riskFactors['family_history'] = 0.4;
      detectedSymptoms.add('Family history of thyroid conditions');
    }

    final riskScore = _calculateRiskScore(riskFactors, 'thyroid');
    final riskLevel = _determineRiskLevel(riskScore);

    final recommendations = _generateThyroidRecommendations(
      riskLevel, riskFactors, detectedSymptoms);

    return MedicalConditionAssessment(
      conditionName: 'Thyroid Dysfunction',
      riskScore: riskScore,
      riskLevel: riskLevel,
      riskFactors: riskFactors,
      detectedSymptoms: detectedSymptoms,
      recommendations: recommendations,
      confidenceLevel: _calculateConfidenceLevel(cycles.length, riskFactors),
      requiresMedicalAttention: riskLevel.index >= RiskLevel.moderate.index,
      nextAssessmentDate: _calculateNextAssessmentDate(riskLevel),
    );
  }

  /// Blueprint Feature: Endometriosis Risk Assessment
  Future<MedicalConditionAssessment> assessEndometriosisRisk(
    List<CycleData> cycles,
    UserProfile userProfile,
  ) async {
    debugPrint('🌸 Assessing endometriosis risk...');

    final riskFactors = <String, double>{};
    final detectedSymptoms = <String>[];

    // Pain pattern analysis
    final painPatterns = _analyzeEndometriosisPainPatterns(cycles);
    riskFactors.addAll(painPatterns['risk_factors'] as Map<String, double>);
    detectedSymptoms.addAll(painPatterns['symptoms'] as List<String>);

    // Heavy bleeding analysis
    final bleedingPatterns = _analyzeHeavyBleedingPatterns(cycles);
    if (bleedingPatterns['severity']! > 0.6) {
      riskFactors['heavy_bleeding'] = bleedingPatterns['severity']!;
      detectedSymptoms.add('Heavy menstrual bleeding');
    }

    // Symptom progression analysis
    final symptomProgression = _analyzeSymptomProgression(cycles);
    if (symptomProgression['worsening_trend']! > 0.5) {
      riskFactors['symptom_progression'] = symptomProgression['worsening_trend']!;
      detectedSymptoms.add('Worsening symptoms over time');
    }

    // Age factor
    if (userProfile.age != null && userProfile.age! >= 25) {
      riskFactors['age_factor'] = math.min(0.5, (userProfile.age! - 25) / 20.0);
    }

    // Family history
    if (userProfile.familyHistory?.contains('endometriosis') == true) {
      riskFactors['family_history'] = 0.6;
      detectedSymptoms.add('Family history of endometriosis');
    }

    final riskScore = _calculateRiskScore(riskFactors, 'endometriosis');
    final riskLevel = _determineRiskLevel(riskScore);

    final recommendations = _generateEndometriosisRecommendations(
      riskLevel, riskFactors, detectedSymptoms);

    return MedicalConditionAssessment(
      conditionName: 'Endometriosis',
      riskScore: riskScore,
      riskLevel: riskLevel,
      riskFactors: riskFactors,
      detectedSymptoms: detectedSymptoms,
      recommendations: recommendations,
      confidenceLevel: _calculateConfidenceLevel(cycles.length, riskFactors),
      requiresMedicalAttention: riskLevel.index >= RiskLevel.moderate.index,
      nextAssessmentDate: _calculateNextAssessmentDate(riskLevel),
    );
  }

  /// Blueprint Feature: Fertility Health Optimization
  Future<FertilityAssessment> assessFertilityHealth(
    List<CycleData> cycles,
    UserProfile userProfile,
    Map<String, dynamic>? lifestyleData,
  ) async {
    debugPrint('🌱 Assessing fertility health...');

    // Ovulation quality analysis
    final ovulationQuality = _assessOvulationQuality(cycles);
    
    // Luteal phase adequacy
    final lutealPhaseHealth = _assessLutealPhaseHealth(cycles);
    
    // Cervical mucus analysis (if tracked)
    final cervicalMucusHealth = _assessCervicalMucusPatterns(cycles);
    
    // Age-related fertility factors
    final ageFactors = _assessAgeFertilityFactors(userProfile.age);
    
    // Lifestyle impact on fertility
    final lifestyleImpact = _assessLifestyleFertilityImpact(lifestyleData);

    // Overall fertility score
    final fertilityScore = _calculateFertilityScore([
      ovulationQuality, lutealPhaseHealth, cervicalMucusHealth,
      ageFactors, lifestyleImpact]);

    // Generate fertility optimization recommendations
    final recommendations = _generateFertilityOptimizationRecommendations(
      fertilityScore, ovulationQuality, lutealPhaseHealth, lifestyleImpact);

    return FertilityAssessment(
      overallFertilityScore: fertilityScore['overall_score']!,
      ovulationQuality: ovulationQuality,
      lutealPhaseHealth: lutealPhaseHealth,
      cervicalMucusHealth: cervicalMucusHealth,
      ageFactors: ageFactors,
      lifestyleFactors: lifestyleImpact,
      recommendations: recommendations,
      optimizationPlan: _createFertilityOptimizationPlan(fertilityScore),
      confidenceLevel: fertilityScore['confidence']!,
    );
  }

  /// Blueprint Feature: Hormonal Shift Detection
  Future<HormonalShiftAssessment> assessHormonalShifts(
    List<CycleData> cycles,
    UserProfile userProfile,
  ) async {
    debugPrint('📊 Assessing hormonal shifts...');

    if (cycles.length < 6) {
      return HormonalShiftAssessment.insufficient();
    }

    // Recent trend analysis (last 3 cycles vs previous 3)
    final recentTrends = _analyzeRecentHormonalTrends(cycles);
    
    // Pattern deviation detection
    final patternDeviations = _detectPatternDeviations(cycles);
    
    // Perimenopause indicators (age-dependent)
    final perimenopauseRisk = _assessPerimenopauseRisk(cycles, userProfile.age);
    
    // Stress-related hormonal changes
    final stressImpact = _assessStressHormonalImpact(cycles);

    // Generate personalized alerts
    final alerts = _generateHormonalShiftAlerts(
      recentTrends, patternDeviations, perimenopauseRisk);

    return HormonalShiftAssessment(
      detectedShifts: recentTrends['detected_shifts'] as List<String>,
      trendAnalysis: recentTrends,
      patternDeviations: patternDeviations,
      perimenopauseRisk: perimenopauseRisk,
      stressImpact: stressImpact,
      personalizedAlerts: alerts,
      recommendedActions: _generateHormonalShiftRecommendations(recentTrends),
      monitoringPlan: _createHormonalMonitoringPlan(recentTrends),
      confidenceLevel: recentTrends['confidence'] ?? 0.7,
    );
  }

  // Helper methods for medical condition analysis

  double _calculateCycleVariability(List<CycleData> cycles) {
    if (cycles.length < 3) return 0.0;
    
    final lengths = cycles.map((c) => c.length.toDouble()).toList();
    final mean = lengths.reduce((a, b) => a + b) / lengths.length;
    final variance = lengths.map((l) => math.pow(l - mean, 2))
        .reduce((a, b) => a + b) / lengths.length;
    return math.sqrt(variance);
  }

  double _calculateAverageCycleLength(List<CycleData> cycles) {
    if (cycles.isEmpty) return 28.0;
    return cycles.map((c) => c.length).reduce((a, b) => a + b) / cycles.length;
  }

  Map<String, double> _analyzePCOSSymptomClusters(List<CycleData> cycles) {
    final clusters = <String, double>{};
    
    // Analyze symptom frequency and co-occurrence
    final symptomFrequency = <String, int>{};
    for (final cycle in cycles) {
      for (final symptom in cycle.symptoms) {
        symptomFrequency[symptom] = (symptomFrequency[symptom] ?? 0) + 1;
      }
    }
    
    // PCOS-specific symptom clusters
    final pcosSymptoms = [
      'acne', 'excess_hair', 'weight_gain', 'mood_swings', 'fatigue'
    ];
    
    int pcosSymptomCount = 0;
    for (final symptom in pcosSymptoms) {
      if (symptomFrequency.containsKey(symptom) && 
          symptomFrequency[symptom]! > cycles.length * 0.3) {
        pcosSymptomCount++;
      }
    }
    
    if (pcosSymptomCount >= 2) {
      clusters['symptom_cluster'] = pcosSymptomCount / pcosSymptoms.length;
    }
    
    return clusters;
  }

  double _calculateBMI(double weight, double height) {
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  double _calculateRiskScore(Map<String, double> riskFactors, String condition) {
    if (riskFactors.isEmpty) return 0.0;
    
    final weights = _riskFactorWeights[condition] ?? {};
    double weightedSum = 0.0;
    double totalWeight = 0.0;
    
    riskFactors.forEach((factor, value) {
      final weight = weights[factor] ?? 1.0;
      weightedSum += value * weight;
      totalWeight += weight;
    });
    
    return totalWeight > 0 ? weightedSum / totalWeight : 0.0;
  }

  RiskLevel _determineRiskLevel(double riskScore) {
    if (riskScore >= 0.7) return RiskLevel.high;
    if (riskScore >= 0.5) return RiskLevel.moderate;
    if (riskScore >= 0.3) return RiskLevel.low;
    return RiskLevel.minimal;
  }

  void _initializeMedicalMarkers() {
    _medicalConditionMarkers = {
      'pcos': [
        'irregular_cycles', 'long_cycles', 'acne', 'excess_hair', 
        'weight_gain', 'insulin_resistance', 'mood_swings'
      ],
      'hypothyroid': [
        'long_cycles', 'heavy_flow', 'fatigue', 'weight_gain',
        'cold_intolerance', 'hair_loss', 'depression'
      ],
      'hyperthyroid': [
        'short_cycles', 'light_flow', 'anxiety', 'weight_loss',
        'heat_intolerance', 'rapid_heartbeat', 'insomnia'
      ],
      'endometriosis': [
        'severe_pain', 'heavy_bleeding', 'painful_periods',
        'chronic_pelvic_pain', 'pain_during_intercourse'
      ],
    };

    _riskFactorWeights = {
      'pcos': {
        'cycle_irregularity': 1.2,
        'long_cycles': 1.0,
        'symptom_cluster': 1.1,
        'elevated_bmi': 0.8,
        'insulin_resistance': 1.3,
      },
      'thyroid': {
        'cycle_patterns': 1.0,
        'symptom_cluster': 1.1,
        'family_history': 0.9,
        'age_factor': 0.7,
      },
      'endometriosis': {
        'pain_patterns': 1.3,
        'heavy_bleeding': 1.0,
        'symptom_progression': 1.2,
        'family_history': 1.0,
      },
    };
  }

  // Placeholder implementations for complex analysis methods
  Map<String, dynamic> _initializePCOSSymptomClusters() => {};
  Map<String, dynamic> _initializePCOSHormonalMarkers() => {};
  Map<String, dynamic> _initializePCOSMetabolicIndicators() => {};
  
  // Additional initialization and analysis methods would continue here...
  // (Implementation details for all the helper methods)
}

/// Data models for preventive health insights
enum RiskLevel { minimal, low, moderate, high, critical }

class HealthScreeningReport {
  final String userId;
  final DateTime screeningDate;
  final MedicalConditionAssessment pcosAssessment;
  final MedicalConditionAssessment thyroidAssessment;
  final MedicalConditionAssessment endometriosisAssessment;
  final FertilityAssessment fertilityAssessment;
  final HormonalShiftAssessment hormonalAssessment;
  final RiskLevel overallRiskLevel;
  final List<String> recommendations;
  final Map<String, DateTime> followUpSchedule;
  final DateTime nextScreeningDate;

  HealthScreeningReport({
    required this.userId,
    required this.screeningDate,
    required this.pcosAssessment,
    required this.thyroidAssessment,
    required this.endometriosisAssessment,
    required this.fertilityAssessment,
    required this.hormonalAssessment,
    required this.overallRiskLevel,
    required this.recommendations,
    required this.followUpSchedule,
    required this.nextScreeningDate,
  });
}

class MedicalConditionAssessment {
  final String conditionName;
  final double riskScore;
  final RiskLevel riskLevel;
  final Map<String, double> riskFactors;
  final List<String> detectedSymptoms;
  final List<String> recommendations;
  final double confidenceLevel;
  final bool requiresMedicalAttention;
  final DateTime nextAssessmentDate;

  MedicalConditionAssessment({
    required this.conditionName,
    required this.riskScore,
    required this.riskLevel,
    required this.riskFactors,
    required this.detectedSymptoms,
    required this.recommendations,
    required this.confidenceLevel,
    required this.requiresMedicalAttention,
    required this.nextAssessmentDate,
  });
}

class FertilityAssessment {
  final double overallFertilityScore;
  final Map<String, dynamic> ovulationQuality;
  final Map<String, dynamic> lutealPhaseHealth;
  final Map<String, dynamic> cervicalMucusHealth;
  final Map<String, dynamic> ageFactors;
  final Map<String, dynamic> lifestyleFactors;
  final List<String> recommendations;
  final Map<String, dynamic> optimizationPlan;
  final double confidenceLevel;

  FertilityAssessment({
    required this.overallFertilityScore,
    required this.ovulationQuality,
    required this.lutealPhaseHealth,
    required this.cervicalMucusHealth,
    required this.ageFactors,
    required this.lifestyleFactors,
    required this.recommendations,
    required this.optimizationPlan,
    required this.confidenceLevel,
  });
}

class HormonalShiftAssessment {
  final List<String> detectedShifts;
  final Map<String, dynamic> trendAnalysis;
  final Map<String, dynamic> patternDeviations;
  final Map<String, dynamic> perimenopauseRisk;
  final Map<String, dynamic> stressImpact;
  final List<String> personalizedAlerts;
  final List<String> recommendedActions;
  final Map<String, dynamic> monitoringPlan;
  final double confidenceLevel;

  HormonalShiftAssessment({
    required this.detectedShifts,
    required this.trendAnalysis,
    required this.patternDeviations,
    required this.perimenopauseRisk,
    required this.stressImpact,
    required this.personalizedAlerts,
    required this.recommendedActions,
    required this.monitoringPlan,
    required this.confidenceLevel,
  });

  factory HormonalShiftAssessment.insufficient() {
    return HormonalShiftAssessment(
      detectedShifts: [],
      trendAnalysis: {'status': 'insufficient_data'},
      patternDeviations: {},
      perimenopauseRisk: {'risk': 0.0},
      stressImpact: {},
      personalizedAlerts: ['Need more cycle data for accurate assessment'],
      recommendedActions: ['Continue tracking cycles for at least 3 more months'],
      monitoringPlan: {'frequency': 'monthly'},
      confidenceLevel: 0.3,
    );
  }
}
