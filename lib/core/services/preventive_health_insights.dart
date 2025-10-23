import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../models/cycle_data.dart';
import '../models/user_profile.dart';
import '../utils/collection_extensions.dart';

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
    if (userProfile.familyHistory != null && userProfile.familyHistory!.values.any((h) => h.toString().toLowerCase().contains('thyroid'))) {
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
    if (userProfile.familyHistory != null && userProfile.familyHistory!.values.any((h) => h.toString().toLowerCase().contains('endometriosis'))) {
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

  // Complete implementations for all missing analysis methods

  // PCOS Detection Implementation
  Map<String, dynamic> _initializePCOSSymptomClusters() => {
    'primary_cluster': ['irregular_cycles', 'acne', 'excess_hair'],
    'secondary_cluster': ['weight_gain', 'insulin_resistance', 'mood_swings'],
    'metabolic_cluster': ['glucose_intolerance', 'lipid_abnormalities'],
  };

  Map<String, dynamic> _initializePCOSHormonalMarkers() => {
    'elevated_androgens': ['testosterone', 'dheas', 'androstenedione'],
    'lh_fsh_ratio': {'threshold': 2.5, 'significance': 'high'},
    'insulin_markers': ['fasting_insulin', 'homa_ir', 'glucose_tolerance'],
  };

  Map<String, dynamic> _initializePCOSMetabolicIndicators() => {
    'insulin_resistance': {'threshold': 2.5, 'weight': 1.3},
    'glucose_intolerance': {'threshold': 140, 'weight': 1.1},
    'lipid_profile': {'hdl_threshold': 50, 'triglyceride_threshold': 150},
  };

  Map<String, double> _analyzeMetabolicIndicators(Map<String, dynamic> biometricData) {
    final metabolicRisk = <String, double>{};
    
    if (biometricData.containsKey('glucose')) {
      final glucose = biometricData['glucose'] as double;
      if (glucose > 100) {
        metabolicRisk['glucose_elevation'] = math.min(1.0, (glucose - 100) / 40.0);
      }
    }
    
    if (biometricData.containsKey('insulin')) {
      final insulin = biometricData['insulin'] as double;
      if (insulin > 15) {
        metabolicRisk['insulin_resistance'] = math.min(1.0, (insulin - 15) / 25.0);
      }
    }
    
    return metabolicRisk;
  }

  List<String> _generatePCOSRecommendations(RiskLevel riskLevel, 
      Map<String, double> riskFactors, List<String> symptoms) {
    final recommendations = <String>[];
    
    if (riskLevel.index >= RiskLevel.moderate.index) {
      recommendations.add('Consult with a gynecologist or endocrinologist');
      recommendations.add('Consider hormonal testing (testosterone, LH, FSH)');
    }
    
    if (riskFactors.containsKey('elevated_bmi')) {
      recommendations.add('Focus on weight management through balanced diet');
      recommendations.add('Incorporate regular physical activity (150 min/week)');
    }
    
    if (riskFactors.containsKey('insulin_resistance')) {
      recommendations.add('Consider low glycemic index diet');
      recommendations.add('Monitor blood glucose levels regularly');
    }
    
    recommendations.add('Track symptoms and menstrual patterns consistently');
    recommendations.add('Consider stress management techniques');
    
    return recommendations;
  }

  // Thyroid Function Implementation
  Map<String, dynamic> _initializeHypothyroidIndicators() => {
    'cycle_changes': ['long_cycles', 'heavy_flow', 'irregular_timing'],
    'metabolic_symptoms': ['weight_gain', 'fatigue', 'cold_intolerance'],
    'mood_symptoms': ['depression', 'brain_fog', 'irritability'],
    'physical_symptoms': ['hair_loss', 'dry_skin', 'constipation'],
  };

  Map<String, dynamic> _initializeHyperthyroidIndicators() => {
    'cycle_changes': ['short_cycles', 'light_flow', 'frequent_periods'],
    'metabolic_symptoms': ['weight_loss', 'heat_intolerance', 'increased_appetite'],
    'mood_symptoms': ['anxiety', 'restlessness', 'insomnia'],
    'physical_symptoms': ['rapid_heartbeat', 'tremors', 'sweating'],
  };

  Map<String, dynamic> _initializeThyroidCyclePatterns() => {
    'hypothyroid_patterns': {'cycle_length': '>35', 'flow_intensity': 'heavy'},
    'hyperthyroid_patterns': {'cycle_length': '<21', 'flow_intensity': 'light'},
    'general_irregularity': {'variability': '>7_days'},
  };

  Map<String, dynamic> _initializeThyroidSymptomMatrix() => {
    'hypothyroid_correlations': {
      'fatigue_weight_gain': 0.8,
      'cold_hair_loss': 0.7,
      'depression_brain_fog': 0.6,
    },
    'hyperthyroid_correlations': {
      'anxiety_weight_loss': 0.8,
      'heat_rapid_heart': 0.9,
      'insomnia_restless': 0.7,
    },
  };

  Map<String, dynamic> _initializeThyroidSeverityLevels() => {
    'mild': {'tsh_range': '4.5-10', 'symptom_count': '2-3'},
    'moderate': {'tsh_range': '10-20', 'symptom_count': '4-6'},
    'severe': {'tsh_range': '>20', 'symptom_count': '>6'},
  };

  Map<String, dynamic> _analyzeHypothyroidIndicators(List<CycleData> cycles) {
    final indicators = <String>[];
    double riskScore = 0.0;
    
    // Check for long cycles
    final avgLength = _calculateAverageCycleLength(cycles);
    if (avgLength > 35) {
      indicators.add('Prolonged menstrual cycles');
      riskScore += 0.3;
    }
    
    // Check for heavy flow patterns
    int heavyFlowCount = 0;
    for (final cycle in cycles) {
      if (cycle.symptoms.contains('heavy_flow')) {
        heavyFlowCount++;
      }
    }
    
    if (heavyFlowCount > cycles.length * 0.5) {
      indicators.add('Consistently heavy menstrual flow');
      riskScore += 0.25;
    }
    
    // Check for hypothyroid symptoms
    final symptomCounts = <String, int>{};
    for (final cycle in cycles) {
      for (final symptom in cycle.symptoms) {
        if (['fatigue', 'weight_gain', 'mood_low'].contains(symptom)) {
          symptomCounts[symptom] = (symptomCounts[symptom] ?? 0) + 1;
        }
      }
    }
    
    int frequentSymptoms = 0;
    symptomCounts.forEach((symptom, count) {
      if (count > cycles.length * 0.4) {
        indicators.add('Frequent $symptom');
        frequentSymptoms++;
      }
    });
    
    riskScore += frequentSymptoms * 0.15;
    
    return {
      'risk_score': math.min(1.0, riskScore),
      'symptoms': indicators,
    };
  }

  Map<String, dynamic> _analyzeHyperthyroidIndicators(List<CycleData> cycles) {
    final indicators = <String>[];
    double riskScore = 0.0;
    
    // Check for short cycles
    final avgLength = _calculateAverageCycleLength(cycles);
    if (avgLength < 21) {
      indicators.add('Shortened menstrual cycles');
      riskScore += 0.3;
    }
    
    // Check for light flow patterns
    int lightFlowCount = 0;
    for (final cycle in cycles) {
      if (cycle.symptoms.contains('light_flow')) {
        lightFlowCount++;
      }
    }
    
    if (lightFlowCount > cycles.length * 0.5) {
      indicators.add('Consistently light menstrual flow');
      riskScore += 0.25;
    }
    
    // Check for hyperthyroid symptoms
    final symptomCounts = <String, int>{};
    for (final cycle in cycles) {
      for (final symptom in cycle.symptoms) {
        if (['anxiety', 'weight_loss', 'mood_high'].contains(symptom)) {
          symptomCounts[symptom] = (symptomCounts[symptom] ?? 0) + 1;
        }
      }
    }
    
    int frequentSymptoms = 0;
    symptomCounts.forEach((symptom, count) {
      if (count > cycles.length * 0.4) {
        indicators.add('Frequent $symptom');
        frequentSymptoms++;
      }
    });
    
    riskScore += frequentSymptoms * 0.15;
    
    return {
      'risk_score': math.min(1.0, riskScore),
      'symptoms': indicators,
    };
  }

  Map<String, double> _analyzeThyroidCycleImpact(List<CycleData> cycles) {
    final impact = <String, double>{};
    
    // Cycle length variability
    final variability = _calculateCycleVariability(cycles);
    if (variability > 7) {
      impact['cycle_irregularity'] = math.min(1.0, variability / 14.0);
    }
    
    // Flow pattern inconsistencies
    final flowVariations = _analyzeFlowVariations(cycles);
    if (flowVariations > 0.5) {
      impact['flow_irregularity'] = flowVariations;
    }
    
    return impact;
  }

  double _analyzeFlowVariations(List<CycleData> cycles) {
    if (cycles.length < 3) return 0.0;
    
    final flowIntensities = cycles.where((c) => c.flowIntensity != null)
        .map((c) => c.flowIntensity!.index.toDouble()).toList();
    
    if (flowIntensities.length < 3) return 0.0;
    
    final mean = flowIntensities.reduce((a, b) => a + b) / flowIntensities.length;
    final variance = flowIntensities.map((f) => math.pow(f - mean, 2))
        .reduce((a, b) => a + b) / flowIntensities.length;
    
    return math.min(1.0, math.sqrt(variance) / 2.0);
  }

  List<String> _generateThyroidRecommendations(RiskLevel riskLevel, 
      Map<String, double> riskFactors, List<String> symptoms) {
    final recommendations = <String>[];
    
    if (riskLevel.index >= RiskLevel.moderate.index) {
      recommendations.add('Schedule thyroid function tests (TSH, T3, T4)');
      recommendations.add('Consult with an endocrinologist');
    }
    
    if (symptoms.contains('Frequent fatigue')) {
      recommendations.add('Focus on adequate sleep (7-9 hours nightly)');
      recommendations.add('Consider iron and B12 level testing');
    }
    
    if (riskFactors.containsKey('cycle_irregularity')) {
      recommendations.add('Track basal body temperature for thyroid insights');
      recommendations.add('Monitor menstrual patterns closely');
    }
    
    recommendations.add('Maintain consistent sleep schedule');
    recommendations.add('Consider stress reduction techniques');
    
    return recommendations;
  }

  // Endometriosis Implementation
  Map<String, dynamic> _initializeEndoPainPatterns() => {
    'cyclical_pain': {'severity_threshold': 7, 'frequency_threshold': 0.8},
    'chronic_pain': {'duration_threshold': 6, 'intensity_threshold': 5},
    'pain_locations': ['pelvis', 'lower_back', 'abdomen', 'rectum'],
    'pain_types': ['cramping', 'stabbing', 'burning', 'throbbing'],
  };

  Map<String, dynamic> _initializeEndoSymptomCorrelation() => {
    'pain_bleeding_correlation': 0.8,
    'pain_timing_correlation': 0.9,
    'progressive_symptoms': 0.7,
  };

  Map<String, dynamic> _initializeEndoSeverityProgression() => {
    'mild': {'pain_score': '1-3', 'impact': 'minimal'},
    'moderate': {'pain_score': '4-6', 'impact': 'some_limitation'},
    'severe': {'pain_score': '7-10', 'impact': 'significant_limitation'},
  };

  Map<String, dynamic> _initializeEndoLocationSymptoms() => {
    'pelvic': ['cramping', 'deep_pain', 'pressure'],
    'bowel': ['painful_bowel_movements', 'bloating', 'constipation'],
    'bladder': ['painful_urination', 'frequent_urination'],
    'reproductive': ['painful_intercourse', 'irregular_bleeding'],
  };

  Map<String, dynamic> _initializeEndoQOLAssessment() => {
    'daily_activities': ['work_impact', 'social_impact', 'physical_activities'],
    'emotional_impact': ['mood_changes', 'anxiety', 'depression'],
    'relationship_impact': ['intimacy_issues', 'communication_stress'],
  };

  Map<String, dynamic> _analyzeEndometriosisPainPatterns(List<CycleData> cycles) {
    final riskFactors = <String, double>{};
    final symptoms = <String>[];
    
    // Analyze pain intensity and frequency
    int severePainCycles = 0;
    int chronicPainCycles = 0;
    
    for (final cycle in cycles) {
      if (cycle.pain != null && cycle.pain! >= 7) {
        severePainCycles++;
      }
      
      if (cycle.symptoms.any((s) => s.contains('pain') || s.contains('cramp'))) {
        chronicPainCycles++;
      }
    }
    
    if (severePainCycles > cycles.length * 0.6) {
      riskFactors['severe_cyclical_pain'] = severePainCycles / cycles.length;
      symptoms.add('Severe menstrual pain');
    }
    
    if (chronicPainCycles > cycles.length * 0.7) {
      riskFactors['chronic_pelvic_pain'] = chronicPainCycles / cycles.length;
      symptoms.add('Chronic pelvic pain');
    }
    
    // Analyze pain progression over time
    final painProgression = _analyzePainProgression(cycles);
    if (painProgression > 0.3) {
      riskFactors['pain_progression'] = painProgression;
      symptoms.add('Worsening pain over time');
    }
    
    return {
      'risk_factors': riskFactors,
      'symptoms': symptoms,
    };
  }

  double _analyzePainProgression(List<CycleData> cycles) {
    if (cycles.length < 6) return 0.0;
    
    final painScores = cycles.where((c) => c.pain != null)
        .map((c) => c.pain!.toDouble()).toList();
    
    if (painScores.length < 4) return 0.0;
    
    // Compare first half vs second half
    final firstHalf = painScores.take(painScores.length ~/ 2).toList();
    final secondHalf = painScores.skip(painScores.length ~/ 2).toList();
    
    final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;
    
    return math.max(0.0, (secondAvg - firstAvg) / 10.0);
  }

  Map<String, double> _analyzeHeavyBleedingPatterns(List<CycleData> cycles) {
    int heavyBleedingCount = 0;
    double totalSeverity = 0.0;
    
    for (final cycle in cycles) {
      if (cycle.flowIntensity != null) {
        final intensity = cycle.flowIntensity!.index;
        if (intensity >= 3) { // Heavy or very heavy
          heavyBleedingCount++;
          totalSeverity += intensity / 4.0;
        }
      }
    }
    
    return {
      'severity': cycles.isNotEmpty ? totalSeverity / cycles.length : 0.0,
      'frequency': cycles.isNotEmpty ? heavyBleedingCount / cycles.length : 0.0,
    };
  }

  Map<String, double> _analyzeSymptomProgression(List<CycleData> cycles) {
    if (cycles.length < 6) return {'worsening_trend': 0.0};
    
    // Track symptom count over time
    final symptomCounts = cycles.map((c) => c.symptoms.length.toDouble()).toList();
    
    // Calculate trend (simple linear regression slope)
    final n = symptomCounts.length;
    final x = List.generate(n, (i) => i.toDouble());
    final y = symptomCounts;
    
    final xMean = x.reduce((a, b) => a + b) / n;
    final yMean = y.reduce((a, b) => a + b) / n;
    
    double numerator = 0.0;
    double denominator = 0.0;
    
    for (int i = 0; i < n; i++) {
      numerator += (x[i] - xMean) * (y[i] - yMean);
      denominator += (x[i] - xMean) * (x[i] - xMean);
    }
    
    final slope = denominator != 0 ? numerator / denominator : 0.0;
    return {'worsening_trend': math.max(0.0, slope / 5.0)};
  }

  List<String> _generateEndometriosisRecommendations(RiskLevel riskLevel, 
      Map<String, double> riskFactors, List<String> symptoms) {
    final recommendations = <String>[];
    
    if (riskLevel.index >= RiskLevel.moderate.index) {
      recommendations.add('Consult with a gynecologist specializing in endometriosis');
      recommendations.add('Consider pelvic exam and possible imaging studies');
    }
    
    if (riskFactors.containsKey('severe_cyclical_pain')) {
      recommendations.add('Track pain patterns with detailed pain diary');
      recommendations.add('Explore pain management techniques (heat, meditation)');
    }
    
    if (riskFactors.containsKey('heavy_bleeding')) {
      recommendations.add('Monitor iron levels due to heavy bleeding');
      recommendations.add('Consider menstrual cup for flow measurement');
    }
    
    recommendations.add('Maintain anti-inflammatory diet');
    recommendations.add('Regular gentle exercise as tolerated');
    
    return recommendations;
  }

  // Fertility Assessment Implementation
  Map<String, dynamic> _initializeFertilityIndicators() => {
    'ovulation_regularity': {'threshold': 0.8, 'weight': 1.2},
    'luteal_phase_length': {'optimal_range': [12, 16], 'weight': 1.0},
    'cervical_mucus_quality': {'peak_days': 2, 'weight': 0.8},
    'basal_temperature_shift': {'minimum_rise': 0.4, 'weight': 1.1},
  };

  Map<String, dynamic> _initializeLutealPhaseAnalysis() => {
    'length_assessment': {'short': '<10', 'optimal': '12-16', 'long': '>16'},
    'progesterone_indicators': ['sustained_temperature', 'minimal_spotting'],
    'deficiency_markers': ['short_luteal', 'spotting', 'low_temperature'],
  };

  Map<String, dynamic> _initializeCervicalMucusAnalysis() => {
    'quality_indicators': ['egg_white', 'stretchy', 'clear'],
    'peak_fertility_signs': ['abundant', 'slippery', 'transparent'],
    'timing_assessment': ['pre_ovulation', 'ovulation_day', 'post_ovulation'],
  };

  Map<String, dynamic> _initializeBBTAnalysis() => {
    'biphasic_pattern': {'temperature_rise': 0.4, 'sustained_days': 10},
    'ovulation_indicators': ['thermal_shift', 'temperature_rise'],
    'luteal_phase_markers': ['elevated_temperature', 'stable_pattern'],
  };

  Map<String, dynamic> _initializeLifestyleFertilityFactors() => {
    'nutrition': ['folate', 'iron', 'vitamin_d', 'omega3'],
    'exercise': ['moderate_intensity', 'regular_schedule', 'avoid_excessive'],
    'stress_management': ['adequate_sleep', 'relaxation', 'social_support'],
    'environmental': ['avoid_toxins', 'limit_alcohol', 'no_smoking'],
  };

  Map<String, dynamic> _assessOvulationQuality(List<CycleData> cycles) {
    int ovulationCycles = 0;
    double avgLutealLength = 0.0;
    
    for (final cycle in cycles) {
      if (cycle.ovulationDate != null) {
        ovulationCycles++;
        final lutealLength = cycle.endDate?.difference(cycle.ovulationDate!).inDays ?? 0;
        avgLutealLength += lutealLength;
      }
    }
    
    final ovulationRate = cycles.isNotEmpty ? ovulationCycles / cycles.length : 0.0;
    avgLutealLength = ovulationCycles > 0 ? avgLutealLength / ovulationCycles : 0.0;
    
    return {
      'ovulation_rate': ovulationRate,
      'average_luteal_length': avgLutealLength,
      'quality_score': _calculateOvulationQualityScore(ovulationRate, avgLutealLength),
      'assessment': _assessOvulationRating(ovulationRate, avgLutealLength),
    };
  }

  double _calculateOvulationQualityScore(double ovulationRate, double lutealLength) {
    double score = ovulationRate * 0.6; // 60% weight for ovulation rate
    
    // Luteal phase quality (40% weight)
    if (lutealLength >= 12 && lutealLength <= 16) {
      score += 0.4; // Optimal luteal phase
    } else if (lutealLength >= 10 && lutealLength < 12) {
      score += 0.3; // Adequate luteal phase
    } else if (lutealLength > 16 && lutealLength <= 18) {
      score += 0.25; // Slightly long but acceptable
    } else {
      score += 0.1; // Suboptimal luteal phase
    }
    
    return math.min(1.0, score);
  }

  String _assessOvulationRating(double ovulationRate, double lutealLength) {
    if (ovulationRate >= 0.8 && lutealLength >= 12 && lutealLength <= 16) {
      return 'Excellent';
    } else if (ovulationRate >= 0.6 && lutealLength >= 10) {
      return 'Good';
    } else if (ovulationRate >= 0.4) {
      return 'Fair';
    } else {
      return 'Poor';
    }
  }

  Map<String, dynamic> _assessLutealPhaseHealth(List<CycleData> cycles) {
    final lutealLengths = <double>[];
    
    for (final cycle in cycles) {
      if (cycle.ovulationDate != null) {
        final lutealLength = cycle.endDate?.difference(cycle.ovulationDate!).inDays.toDouble() ?? 0.0;
        lutealLengths.add(lutealLength);
      }
    }
    
    if (lutealLengths.isEmpty) {
      return {
        'status': 'insufficient_data',
        'average_length': 0.0,
        'consistency': 0.0,
        'assessment': 'Unable to assess - ovulation tracking needed',
      };
    }
    
    final avgLength = lutealLengths.reduce((a, b) => a + b) / lutealLengths.length;
    final consistency = 1.0 - (_calculateVariability(lutealLengths) / avgLength);
    
    return {
      'status': 'assessed',
      'average_length': avgLength,
      'consistency': math.max(0.0, consistency),
      'assessment': _assessLutealPhaseRating(avgLength, consistency),
    };
  }

  double _calculateVariability(List<double> values) {
    if (values.length < 2) return 0.0;
    
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((v) => math.pow(v - mean, 2))
        .reduce((a, b) => a + b) / values.length;
    
    return math.sqrt(variance);
  }

  String _assessLutealPhaseRating(double avgLength, double consistency) {
    if (avgLength >= 12 && avgLength <= 16 && consistency >= 0.8) {
      return 'Excellent';
    } else if (avgLength >= 10 && avgLength <= 18 && consistency >= 0.6) {
      return 'Good';
    } else if (avgLength >= 8) {
      return 'Fair';
    } else {
      return 'Poor';
    }
  }

  Map<String, dynamic> _assessCervicalMucusPatterns(List<CycleData> cycles) {
    // Placeholder - would analyze cervical mucus tracking if available
    return {
      'tracking_available': false,
      'quality_score': 0.5,
      'assessment': 'Not tracked - consider adding cervical mucus observations',
      'recommendation': 'Track cervical mucus changes for better fertility insights',
    };
  }

  Map<String, dynamic> _assessAgeFertilityFactors(int? age) {
    if (age == null) {
      return {
        'age_factor': 0.5,
        'assessment': 'Age not provided',
        'impact': 'unknown',
      };
    }
    
    double ageFactor;
    String assessment;
    String impact;
    
    if (age <= 30) {
      ageFactor = 1.0;
      assessment = 'Optimal fertility age';
      impact = 'minimal';
    } else if (age <= 35) {
      ageFactor = 0.9;
      assessment = 'Good fertility potential';
      impact = 'slight';
    } else if (age <= 40) {
      ageFactor = 0.7;
      assessment = 'Moderate age-related decline';
      impact = 'moderate';
    } else {
      ageFactor = 0.4;
      assessment = 'Significant age-related decline';
      impact = 'significant';
    }
    
    return {
      'age_factor': ageFactor,
      'assessment': assessment,
      'impact': impact,
      'recommendations': _getAgeFertilityRecommendations(age),
    };
  }

  List<String> _getAgeFertilityRecommendations(int age) {
    if (age <= 30) {
      return ['Maintain healthy lifestyle for optimal fertility'];
    } else if (age <= 35) {
      return [
        'Consider preconception health optimization',
        'Regular health checkups recommended'
      ];
    } else if (age <= 40) {
      return [
        'Consider fertility assessment if trying to conceive',
        'Prenatal vitamins with folate recommended',
        'Discuss timeline with healthcare provider'
      ];
    } else {
      return [
        'Consult fertility specialist for guidance',
        'Consider comprehensive fertility testing',
        'Discuss all options with healthcare team'
      ];
    }
  }

  Map<String, dynamic> _assessLifestyleFertilityImpact(Map<String, dynamic>? lifestyleData) {
    if (lifestyleData == null) {
      return {
        'overall_impact': 0.5,
        'assessment': 'Lifestyle data not available',
        'recommendations': ['Track lifestyle factors for better insights'],
      };
    }
    
    double impactScore = 0.5; // Neutral starting point
    final positiveFactors = <String>[];
    final negativeFactors = <String>[];
    
    // Exercise impact
    if (lifestyleData.containsKey('exercise_frequency')) {
      final frequency = lifestyleData['exercise_frequency'] as int;
      if (frequency >= 3 && frequency <= 5) {
        impactScore += 0.1;
        positiveFactors.add('Regular moderate exercise');
      } else if (frequency > 7) {
        impactScore -= 0.1;
        negativeFactors.add('Excessive exercise');
      }
    }
    
    // Sleep impact
    if (lifestyleData.containsKey('sleep_hours')) {
      final sleepHours = lifestyleData['sleep_hours'] as double;
      if (sleepHours >= 7 && sleepHours <= 9) {
        impactScore += 0.1;
        positiveFactors.add('Adequate sleep');
      } else {
        impactScore -= 0.1;
        negativeFactors.add('Inadequate sleep');
      }
    }
    
    // Stress impact
    if (lifestyleData.containsKey('stress_level')) {
      final stressLevel = lifestyleData['stress_level'] as int;
      if (stressLevel <= 3) {
        impactScore += 0.05;
        positiveFactors.add('Low stress levels');
      } else if (stressLevel >= 7) {
        impactScore -= 0.15;
        negativeFactors.add('High stress levels');
      }
    }
    
    return {
      'overall_impact': math.max(0.0, math.min(1.0, impactScore)),
      'positive_factors': positiveFactors,
      'negative_factors': negativeFactors,
      'assessment': _assessLifestyleImpact(impactScore),
    };
  }

  String _assessLifestyleImpact(double score) {
    if (score >= 0.7) return 'Very positive lifestyle factors';
    if (score >= 0.6) return 'Positive lifestyle factors';
    if (score >= 0.4) return 'Neutral lifestyle factors';
    if (score >= 0.3) return 'Some negative lifestyle factors';
    return 'Multiple negative lifestyle factors';
  }

  Map<String, double> _calculateFertilityScore(List<Map<String, dynamic>> factors) {
    double overallScore = 0.0;
    double confidence = 0.0;
    int validFactors = 0;
    
    for (final factor in factors) {
      if (factor.containsKey('quality_score') || factor.containsKey('age_factor') || factor.containsKey('overall_impact')) {
        final score = factor['quality_score'] ?? factor['age_factor'] ?? factor['overall_impact'] ?? 0.5;
        overallScore += score as double;
        confidence += 0.2;
        validFactors++;
      }
    }
    
    return {
      'overall_score': validFactors > 0 ? overallScore / validFactors : 0.5,
      'confidence': math.min(1.0, confidence),
    };
  }

  List<String> _generateFertilityOptimizationRecommendations(
      Map<String, double> fertilityScore,
      Map<String, dynamic> ovulationQuality,
      Map<String, dynamic> lutealPhaseHealth,
      Map<String, dynamic> lifestyleImpact) {
    final recommendations = <String>[];
    
    // General recommendations
    recommendations.add('Take daily prenatal vitamins with folate');
    recommendations.add('Maintain healthy BMI (18.5-24.9)');
    
    // Ovulation-specific recommendations
    if (ovulationQuality['ovulation_rate'] < 0.6) {
      recommendations.add('Track ovulation with multiple methods (BBT, LH strips)');
      recommendations.add('Consider consulting fertility specialist');
    }
    
    // Luteal phase recommendations
    if (lutealPhaseHealth['average_length'] < 12) {
      recommendations.add('Consider progesterone support evaluation');
      recommendations.add('Ensure adequate vitamin B6 and magnesium intake');
    }
    
    // Lifestyle recommendations
    final negativeFactors = lifestyleImpact['negative_factors'] as List<String>? ?? [];
    if (negativeFactors.contains('High stress levels')) {
      recommendations.add('Implement stress management techniques (yoga, meditation)');
    }
    if (negativeFactors.contains('Inadequate sleep')) {
      recommendations.add('Prioritize 7-9 hours of quality sleep nightly');
    }
    
    return recommendations;
  }

  Map<String, dynamic> _createFertilityOptimizationPlan(Map<String, double> fertilityScore) {
    final score = fertilityScore['overall_score'] ?? 0.5;
    
    if (score >= 0.8) {
      return {
        'phase': 'maintenance',
        'focus': 'Maintain current excellent fertility health',
        'timeline': '3_months',
        'monitoring': 'monthly_check_ins',
      };
    } else if (score >= 0.6) {
      return {
        'phase': 'optimization',
        'focus': 'Enhance specific fertility factors',
        'timeline': '6_months',
        'monitoring': 'bi_weekly_tracking',
      };
    } else {
      return {
        'phase': 'improvement',
        'focus': 'Address multiple fertility concerns',
        'timeline': '12_months',
        'monitoring': 'weekly_tracking_with_professional_guidance',
      };
    }
  }

  // Hormonal Shift Assessment Implementation
  Map<String, dynamic> _initializePatternDeviationAnalysis() => {
    'cycle_length_deviation': {'threshold': 7, 'weight': 1.0},
    'flow_pattern_deviation': {'threshold': 0.3, 'weight': 0.8},
    'symptom_pattern_deviation': {'threshold': 0.4, 'weight': 0.9},
    'timing_deviation': {'threshold': 5, 'weight': 1.1},
  };

  Map<String, dynamic> _initializeEarlyWarningSystem() => {
    'significant_changes': ['cycle_length_change', 'flow_change', 'new_symptoms'],
    'warning_thresholds': {'cycle': 0.3, 'symptoms': 0.4, 'flow': 0.3},
    'alert_triggers': ['multiple_deviations', 'progressive_changes'],
  };

  Map<String, dynamic> _initializePerimenopauseIndicators() => {
    'age_thresholds': {'early': 40, 'typical': 45, 'late': 55},
    'cycle_changes': ['irregular_timing', 'skipped_periods', 'flow_changes'],
    'symptom_clusters': ['hot_flashes', 'mood_changes', 'sleep_disturbances'],
    'hormonal_markers': ['fsh_elevation', 'estrogen_decline'],
  };

  Map<String, dynamic> _analyzeRecentHormonalTrends(List<CycleData> cycles) {
    if (cycles.length < 6) {
      return {
        'detected_shifts': <String>[],
        'confidence': 0.3,
        'trend_direction': 'insufficient_data',
      };
    }
    
    final recentCycles = cycles.takeLast(3).toList();
    final previousCycles = cycles.skip(cycles.length - 6).take(3).toList();
    
    final detectedShifts = <String>[];
    
    // Cycle length comparison
    final recentAvgLength = recentCycles.map((c) => c.length).reduce((a, b) => a + b) / 3.0;
    final previousAvgLength = previousCycles.map((c) => c.length).reduce((a, b) => a + b) / 3.0;
    
    if ((recentAvgLength - previousAvgLength).abs() > 5) {
      detectedShifts.add('Significant cycle length change');
    }
    
    // Flow pattern comparison
    final recentFlowPattern = _analyzeFlowPattern(recentCycles);
    final previousFlowPattern = _analyzeFlowPattern(previousCycles);
    
    if ((recentFlowPattern - previousFlowPattern).abs() > 0.3) {
      detectedShifts.add('Flow pattern variation');
    }
    
    // Symptom pattern comparison
    final symptomShift = _analyzeSymptomShift(recentCycles, previousCycles);
    if (symptomShift > 0.4) {
      detectedShifts.add('New or changing symptoms');
    }
    
    return {
      'detected_shifts': detectedShifts,
      'recent_avg_length': recentAvgLength,
      'previous_avg_length': previousAvgLength,
      'flow_shift': (recentFlowPattern - previousFlowPattern).abs(),
      'symptom_shift': symptomShift,
      'confidence': _calculateTrendConfidence(detectedShifts.length),
      'trend_direction': _determineTrendDirection(recentAvgLength, previousAvgLength),
    };
  }

  double _analyzeFlowPattern(List<CycleData> cycles) {
    final flowIntensities = cycles.where((c) => c.flowIntensity != null)
        .map((c) => c.flowIntensity!.index.toDouble()).toList();
    
    return flowIntensities.isNotEmpty 
        ? flowIntensities.reduce((a, b) => a + b) / flowIntensities.length 
        : 2.0; // Default to medium flow
  }

  double _analyzeSymptomShift(List<CycleData> recentCycles, List<CycleData> previousCycles) {
    final recentSymptoms = recentCycles.expand((c) => c.symptoms).toSet();
    final previousSymptoms = previousCycles.expand((c) => c.symptoms).toSet();
    
    final newSymptoms = recentSymptoms.difference(previousSymptoms);
    final lostSymptoms = previousSymptoms.difference(recentSymptoms);
    
    final totalSymptoms = recentSymptoms.union(previousSymptoms).length;
    
    return totalSymptoms > 0 
        ? (newSymptoms.length + lostSymptoms.length) / totalSymptoms 
        : 0.0;
  }

  double _calculateTrendConfidence(int shiftsDetected) {
    if (shiftsDetected >= 3) return 0.9;
    if (shiftsDetected == 2) return 0.7;
    if (shiftsDetected == 1) return 0.5;
    return 0.3;
  }

  String _determineTrendDirection(double recentAvg, double previousAvg) {
    final difference = recentAvg - previousAvg;
    if (difference > 5) return 'lengthening';
    if (difference < -5) return 'shortening';
    return 'stable';
  }

  Map<String, dynamic> _detectPatternDeviations(List<CycleData> cycles) {
    final deviations = <String, dynamic>{};
    
    // Cycle length deviation from personal average
    final cycleLengths = cycles.map((c) => c.length.toDouble()).toList();
    final avgLength = cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
    final lengthVariability = _calculateVariability(cycleLengths);
    
    deviations['cycle_length_variability'] = lengthVariability;
    deviations['exceeds_normal_variability'] = lengthVariability > 7;
    
    // Flow pattern deviations
    final flowDeviations = _analyzeFlowDeviations(cycles);
    deviations.addAll(flowDeviations);
    
    // Timing deviations (ovulation timing if tracked)
    final timingDeviations = _analyzeTimingDeviations(cycles);
    deviations.addAll(timingDeviations);
    
    return deviations;
  }

  Map<String, dynamic> _analyzeFlowDeviations(List<CycleData> cycles) {
    final flowPatterns = cycles.where((c) => c.flowIntensity != null)
        .map((c) => c.flowIntensity!.index.toDouble()).toList();
    
    if (flowPatterns.length < 3) {
      return {'flow_deviation': 0.0, 'flow_tracking_insufficient': true};
    }
    
    final flowVariability = _calculateVariability(flowPatterns);
    
    return {
      'flow_deviation': flowVariability,
      'flow_inconsistency': flowVariability > 1.0,
    };
  }

  Map<String, dynamic> _analyzeTimingDeviations(List<CycleData> cycles) {
    final ovulationTimings = <double>[];
    
    for (final cycle in cycles) {
      if (cycle.ovulationDate != null) {
        final dayOfCycle = cycle.ovulationDate!.difference(cycle.startDate).inDays;
        ovulationTimings.add(dayOfCycle.toDouble());
      }
    }
    
    if (ovulationTimings.length < 3) {
      return {'timing_deviation': 0.0, 'ovulation_tracking_insufficient': true};
    }
    
    final timingVariability = _calculateVariability(ovulationTimings);
    
    return {
      'timing_deviation': timingVariability,
      'ovulation_inconsistency': timingVariability > 3.0,
    };
  }

  Map<String, dynamic> _assessPerimenopauseRisk(List<CycleData> cycles, int? age) {
    if (age == null || age < 35) {
      return {
        'risk': 0.0,
        'assessment': 'Low risk based on age',
        'indicators': <String>[],
      };
    }
    
    double riskScore = 0.0;
    final indicators = <String>[];
    
    // Age factor
    if (age >= 45) {
      riskScore += 0.4;
      indicators.add('Age-appropriate for perimenopause onset');
    } else if (age >= 40) {
      riskScore += 0.2;
      indicators.add('Approaching typical perimenopause age');
    }
    
    // Cycle irregularity
    final irregularity = _calculateCycleVariability(cycles);
    if (irregularity > 10) {
      riskScore += 0.3;
      indicators.add('Significant cycle irregularity');
    }
    
    // Skip periods detection
    int missedPeriods = 0;
    for (int i = 1; i < cycles.length; i++) {
      final daysBetween = cycles[i].startDate.difference(cycles[i-1].startDate).inDays;
      if (daysBetween > 60) {
        missedPeriods++;
      }
    }
    
    if (missedPeriods > 0) {
      riskScore += 0.2 * missedPeriods;
      indicators.add('Skipped menstrual periods detected');
    }
    
    // Symptom analysis for perimenopausal symptoms
    final perimenopausalSymptoms = [
      'hot_flashes', 'night_sweats', 'mood_swings', 'sleep_disturbances'
    ];
    
    int symptomCount = 0;
    for (final cycle in cycles) {
      for (final symptom in cycle.symptoms) {
        if (perimenopausalSymptoms.contains(symptom)) {
          symptomCount++;
          break;
        }
      }
    }
    
    if (symptomCount > cycles.length * 0.3) {
      riskScore += 0.25;
      indicators.add('Perimenopausal symptoms present');
    }
    
    return {
      'risk': math.min(1.0, riskScore),
      'assessment': _assessPerimenopauseRiskLevel(riskScore),
      'indicators': indicators,
    };
  }

  String _assessPerimenopauseRiskLevel(double riskScore) {
    if (riskScore >= 0.7) return 'High likelihood of perimenopause';
    if (riskScore >= 0.5) return 'Moderate signs of perimenopausal transition';
    if (riskScore >= 0.3) return 'Some early perimenopausal indicators';
    return 'Low current risk for perimenopause';
  }

  Map<String, dynamic> _assessStressHormonalImpact(List<CycleData> cycles) {
    final stressIndicators = ['stress', 'anxiety', 'mood_low', 'irritability'];
    int stressCycles = 0;
    
    for (final cycle in cycles) {
      if (cycle.symptoms.any((symptom) => stressIndicators.contains(symptom))) {
        stressCycles++;
      }
    }
    
    final stressFrequency = cycles.isNotEmpty ? stressCycles / cycles.length : 0.0;
    
    return {
      'stress_frequency': stressFrequency,
      'impact_level': _determineStressImpact(stressFrequency),
      'recommendations': _getStressManagementRecommendations(stressFrequency),
    };
  }

  String _determineStressImpact(double frequency) {
    if (frequency >= 0.7) return 'High stress impact on cycles';
    if (frequency >= 0.5) return 'Moderate stress impact';
    if (frequency >= 0.3) return 'Mild stress impact';
    return 'Minimal stress impact';
  }

  List<String> _getStressManagementRecommendations(double stressFrequency) {
    if (stressFrequency >= 0.5) {
      return [
        'Consider professional stress management counseling',
        'Implement daily relaxation techniques',
        'Evaluate work-life balance and make adjustments',
        'Consider mindfulness or meditation practices',
      ];
    } else if (stressFrequency >= 0.3) {
      return [
        'Practice regular stress-reduction activities',
        'Maintain consistent sleep schedule',
        'Engage in regular physical activity',
      ];
    } else {
      return [
        'Continue current stress management practices',
        'Monitor for changes in stress levels',
      ];
    }
  }

  List<String> _generateHormonalShiftAlerts(
      Map<String, dynamic> recentTrends,
      Map<String, dynamic> patternDeviations,
      Map<String, dynamic> perimenopauseRisk) {
    final alerts = <String>[];
    
    final detectedShifts = recentTrends['detected_shifts'] as List<String>;
    if (detectedShifts.length >= 2) {
      alerts.add('Multiple hormonal changes detected in recent cycles');
    }
    
    if (patternDeviations['exceeds_normal_variability'] == true) {
      alerts.add('Your cycle patterns show more variation than usual');
    }
    
    if (perimenopauseRisk['risk'] >= 0.5) {
      alerts.add('Some signs suggest possible perimenopausal transition');
    }
    
    if (alerts.isEmpty) {
      alerts.add('Your hormonal patterns appear stable');
    }
    
    return alerts;
  }

  List<String> _generateHormonalShiftRecommendations(Map<String, dynamic> trends) {
    final recommendations = <String>[];
    
    recommendations.add('Continue consistent cycle tracking');
    
    final shifts = trends['detected_shifts'] as List<String>;
    if (shifts.isNotEmpty) {
      recommendations.add('Consider discussing changes with healthcare provider');
      recommendations.add('Track additional symptoms and environmental factors');
    }
    
    if (trends['confidence'] >= 0.7) {
      recommendations.add('Consider hormone level testing for detailed assessment');
    }
    
    return recommendations;
  }

  Map<String, dynamic> _createHormonalMonitoringPlan(Map<String, dynamic> trends) {
    final shifts = trends['detected_shifts'] as List<String>;
    
    if (shifts.length >= 2) {
      return {
        'frequency': 'weekly',
        'duration': '6_months',
        'focus_areas': ['cycle_length', 'symptoms', 'flow_patterns'],
        'professional_follow_up': 'recommended',
      };
    } else if (shifts.length == 1) {
      return {
        'frequency': 'bi_weekly',
        'duration': '3_months',
        'focus_areas': ['cycle_tracking', 'symptom_monitoring'],
        'professional_follow_up': 'as_needed',
      };
    } else {
      return {
        'frequency': 'monthly',
        'duration': '3_months',
        'focus_areas': ['routine_tracking'],
        'professional_follow_up': 'routine_checkup',
      };
    }
  }

  // Additional helper methods
  double _calculateConfidenceLevel(int cycleCount, Map<String, double> riskFactors) {
    double baseConfidence = math.min(1.0, cycleCount / 12.0);
    double factorConfidence = riskFactors.isNotEmpty ? 0.8 : 0.5;
    
    return (baseConfidence + factorConfidence) / 2.0;
  }

  DateTime _calculateNextAssessmentDate(RiskLevel riskLevel) {
    final now = DateTime.now();
    
    switch (riskLevel) {
      case RiskLevel.high:
      case RiskLevel.critical:
        return now.add(const Duration(days: 30)); // 1 month
      case RiskLevel.moderate:
        return now.add(const Duration(days: 90)); // 3 months
      case RiskLevel.low:
        return now.add(const Duration(days: 180)); // 6 months
      case RiskLevel.minimal:
        return now.add(const Duration(days: 365)); // 1 year
    }
  }

  RiskLevel _calculateOverallRisk(List<MedicalConditionAssessment> assessments) {
    final highestRiskLevel = assessments.map((a) => a.riskLevel.index)
        .reduce((a, b) => math.max(a, b));
    
    return RiskLevel.values[highestRiskLevel];
  }

  Future<List<String>> _generatePreventiveRecommendations(
      List<dynamic> assessments) async {
    final recommendations = <String>[];
    
    // General preventive health recommendations
    recommendations.add('Maintain regular menstrual cycle tracking');
    recommendations.add('Schedule annual gynecological checkups');
    recommendations.add('Follow balanced nutrition and exercise routine');
    
    // Collect specific recommendations from all assessments
    for (final assessment in assessments) {
      if (assessment is MedicalConditionAssessment) {
        recommendations.addAll(assessment.recommendations);
      } else if (assessment is FertilityAssessment) {
        recommendations.addAll(assessment.recommendations);
      } else if (assessment is HormonalShiftAssessment) {
        recommendations.addAll(assessment.recommendedActions);
      }
    }
    
    // Remove duplicates and limit to top recommendations
    return recommendations.toSet().take(10).toList();
  }

  Map<String, DateTime> _createFollowUpSchedule(
      RiskLevel overallRisk, List<MedicalConditionAssessment> assessments) {
    final schedule = <String, DateTime>{};
    final now = DateTime.now();
    
    // Schedule follow-ups based on individual assessment needs
    for (final assessment in assessments) {
      schedule[assessment.conditionName] = assessment.nextAssessmentDate;
    }
    
    // Add general follow-up based on overall risk
    switch (overallRisk) {
      case RiskLevel.high:
      case RiskLevel.critical:
        schedule['General Health Check'] = now.add(const Duration(days: 30));
        break;
      case RiskLevel.moderate:
        schedule['General Health Check'] = now.add(const Duration(days: 90));
        break;
      default:
        schedule['General Health Check'] = now.add(const Duration(days: 180));
    }
    
    return schedule;
  }

  DateTime _calculateNextScreeningDate(RiskLevel riskLevel) {
    final now = DateTime.now();
    
    switch (riskLevel) {
      case RiskLevel.high:
      case RiskLevel.critical:
        return now.add(const Duration(days: 90)); // 3 months
      case RiskLevel.moderate:
        return now.add(const Duration(days: 180)); // 6 months
      case RiskLevel.low:
        return now.add(const Duration(days: 365)); // 1 year
      case RiskLevel.minimal:
        return now.add(const Duration(days: 730)); // 2 years
    }
  }
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
