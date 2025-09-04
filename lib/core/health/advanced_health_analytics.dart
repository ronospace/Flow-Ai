import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../models/cycle_data.dart';
import '../models/user_profile.dart';
import '../biometrics/advanced_biometric_engine.dart';
import '../ai/neural_prediction_engine.dart';
import '../ai/emotional_intelligence_engine.dart';

/// 🔬 Revolutionary Advanced Health Analytics Engine  
/// Comprehensive health scoring, fertility insights, condition detection, and personalized recommendations
/// Leveraging AI, biometrics, and multi-dimensional health data analysis
class AdvancedHealthAnalytics {
  static final AdvancedHealthAnalytics _instance = AdvancedHealthAnalytics._internal();
  static AdvancedHealthAnalytics get instance => _instance;
  AdvancedHealthAnalytics._internal();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  // Core Analytics Components
  late HealthScoringEngine _healthScoringEngine;
  late FertilityAnalyzer _fertilityAnalyzer;
  late ConditionDetector _conditionDetector;
  late SupplementRecommender _supplementRecommender;
  late RiskAssessment _riskAssessment;
  late PersonalizationEngine _personalizationEngine;
  late TrendAnalyzer _trendAnalyzer;

  // Integration with other engines
  late AdvancedBiometricEngine _biometricEngine;
  late NeuralPredictionEngine _predictionEngine;
  late EmotionalIntelligenceEngine _emotionalEngine;

  // Health data cache and trends
  final Map<String, HealthReport> _healthReportCache = {};
  final StreamController<HealthInsight> _healthInsightStream = StreamController.broadcast();
  Stream<HealthInsight> get healthInsightStream => _healthInsightStream.stream;

  Future<void> initialize() async {
    if (_initialized) return;

    debugPrint('🔬 Initializing Advanced Health Analytics...');

    // Initialize core analytics components
    await _initializeAnalyticsComponents();

    // Initialize external engine references
    await _initializeEngineReferences();

    // Setup health monitoring and trend analysis
    await _setupHealthMonitoring();

    _initialized = true;
    debugPrint('✅ Advanced Health Analytics initialized with comprehensive analysis capabilities');
  }

  Future<void> _initializeAnalyticsComponents() async {
    debugPrint('🧮 Initializing analytics components...');

    _healthScoringEngine = HealthScoringEngine();
    _fertilityAnalyzer = FertilityAnalyzer();
    _conditionDetector = ConditionDetector();
    _supplementRecommender = SupplementRecommender();
    _riskAssessment = RiskAssessment();
    _personalizationEngine = PersonalizationEngine();
    _trendAnalyzer = TrendAnalyzer();

    await Future.wait([
      _healthScoringEngine.initialize(),
      _fertilityAnalyzer.initialize(),
      _conditionDetector.initialize(),
      _supplementRecommender.initialize(),
      _riskAssessment.initialize(),
      _personalizationEngine.initialize(),
      _trendAnalyzer.initialize(),
    ]);
  }

  Future<void> _initializeEngineReferences() async {
    _biometricEngine = AdvancedBiometricEngine.instance;
    _predictionEngine = NeuralPredictionEngine.instance;
    _emotionalEngine = EmotionalIntelligenceEngine.instance;

    // Ensure dependencies are initialized
    if (!_biometricEngine.isInitialized) await _biometricEngine.initialize();
    if (!_predictionEngine.isInitialized) await _predictionEngine.initialize();
    if (!_emotionalEngine.isInitialized) await _emotionalEngine.initialize();
  }

  Future<void> _setupHealthMonitoring() async {
    // Setup continuous health monitoring and insights
    Timer.periodic(const Duration(hours: 6), (_) async {
      await _generateHealthInsights();
    });
  }

  /// Generate comprehensive health report with all analytics
  Future<ComprehensiveHealthReport> generateHealthReport({
    required UserProfile user,
    required List<CycleData> cycleHistory,
    required String currentPhase,
    Map<String, dynamic>? additionalData,
    int analysisDepth = 30, // days
  }) async {
    if (!_initialized) await initialize();

    debugPrint('📊 Generating comprehensive health report for user ${user.id}...');

    // Gather multi-dimensional health data
    final healthData = await _gatherHealthData(user, cycleHistory, additionalData);

    // Generate health scores across multiple dimensions
    final healthScores = await _healthScoringEngine.calculateHealthScores(
      user, cycleHistory, healthData, currentPhase);

    // Analyze fertility insights
    final fertilityAnalysis = await _fertilityAnalyzer.analyzeFertility(
      user, cycleHistory, healthData, currentPhase);

    // Screen for potential conditions
    final conditionScreening = await _conditionDetector.screenForConditions(
      user, cycleHistory, healthData, currentPhase);

    // Generate personalized supplement recommendations
    final supplementRecommendations = await _supplementRecommender.generateRecommendations(
      user, cycleHistory, healthData, healthScores, conditionScreening);

    // Assess health risks
    final riskAssessments = await _riskAssessment.assessRisks(
      user, cycleHistory, healthData, healthScores, conditionScreening);

    // Generate personalized insights
    final personalizedInsights = await _personalizationEngine.generateInsights(
      user, cycleHistory, healthData, healthScores);

    // Analyze trends and patterns
    final trendAnalysis = await _trendAnalyzer.analyzeTrends(
      user, cycleHistory, healthData, analysisDepth);

    // Generate actionable recommendations
    final recommendations = await _generateActionableRecommendations(
      user, healthScores, fertilityAnalysis, conditionScreening, 
      supplementRecommendations, riskAssessments, personalizedInsights);

    final report = ComprehensiveHealthReport(
      userId: user.id,
      generatedAt: DateTime.now(),
      analysisDepth: analysisDepth,
      currentPhase: currentPhase,
      overallHealthScore: _calculateOverallHealthScore(healthScores),
      healthScores: healthScores,
      fertilityAnalysis: fertilityAnalysis,
      conditionScreening: conditionScreening,
      supplementRecommendations: supplementRecommendations,
      riskAssessments: riskAssessments,
      personalizedInsights: personalizedInsights,
      trendAnalysis: trendAnalysis,
      recommendations: recommendations,
      keyFindings: _identifyKeyFindings(healthScores, conditionScreening, trendAnalysis),
      nextSteps: _generateNextSteps(recommendations, riskAssessments),
    );

    // Cache the report (convert to HealthReport for cache compatibility)
    _healthReportCache[user.id] = HealthReport(
      userId: report.userId,
      generatedAt: report.generatedAt,
      analysisDepth: report.analysisDepth,
      currentPhase: report.currentPhase,
      overallHealthScore: report.overallHealthScore,
      healthScores: report.healthScores,
      fertilityAnalysis: report.fertilityAnalysis,
      conditionScreening: report.conditionScreening,
      supplementRecommendations: report.supplementRecommendations,
      riskAssessments: report.riskAssessments,
      personalizedInsights: report.personalizedInsights,
      trendAnalysis: report.trendAnalysis,
      recommendations: report.recommendations,
      keyFindings: report.keyFindings,
      nextSteps: report.nextSteps,
    );

    return report;
  }

  /// Quick health assessment for immediate insights
  Future<QuickHealthAssessment> performQuickAssessment({
    required UserProfile user,
    required String currentPhase,
    Map<String, dynamic>? currentSymptoms,
    Map<String, dynamic>? recentBiometrics,
  }) async {
    if (!_initialized) await initialize();

    debugPrint('⚡ Performing quick health assessment...');

    // Generate quick health snapshot
    final quickScores = await _healthScoringEngine.calculateQuickScores(
      user, currentPhase, currentSymptoms, recentBiometrics);

    // Quick risk screening
    final immediateRisks = await _riskAssessment.assessImmediateRisks(
      user, currentPhase, currentSymptoms, recentBiometrics);

    // Emergency recommendations
    final urgentRecommendations = await _generateUrgentRecommendations(
      user, currentPhase, quickScores, immediateRisks);

    return QuickHealthAssessment(
      userId: user.id,
      assessmentTime: DateTime.now(),
      currentPhase: currentPhase,
      quickHealthScore: quickScores['overall'] ?? 0.7,
      immediateRisks: immediateRisks,
      urgentRecommendations: urgentRecommendations,
      flaggedConcerns: _identifyFlaggedConcerns(quickScores, immediateRisks),
      followUpNeeded: _determineFollowUpNeeded(quickScores, immediateRisks),
    );
  }

  /// Generate fertility window predictions with enhanced accuracy
  Future<EnhancedFertilityWindow> predictFertilityWindow({
    required UserProfile user,
    required List<CycleData> cycleHistory,
    Map<String, dynamic>? biometricData,
    int predictionDays = 14,
  }) async {
    if (!_initialized) await initialize();

    final fertilityPrediction = await _fertilityAnalyzer.predictFertilityWindow(
      user, cycleHistory, biometricData, predictionDays);

    return fertilityPrediction;
  }

  /// Detect potential reproductive health conditions
  Future<ConditionScreeningResult> screenForConditions({
    required UserProfile user,
    required List<CycleData> cycleHistory,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_initialized) await initialize();

    return await _conditionDetector.screenForConditions(
      user, cycleHistory, additionalData ?? {}, 'current');
  }

  Future<Map<String, dynamic>> _gatherHealthData(
    UserProfile user, 
    List<CycleData> cycleHistory, 
    Map<String, dynamic>? additionalData,
  ) async {
    final healthData = <String, dynamic>{};

    // Get biometric data
    if (_biometricEngine.isInitialized) {
      try {
        final biometricSnapshot = await _biometricEngine.getBiometricSnapshot(user.id);
        healthData['biometrics'] = biometricSnapshot.toMap();
      } catch (e) {
        debugPrint('Warning: Could not fetch biometric data: $e');
        healthData['biometrics'] = <String, dynamic>{};
      }
    }

    // Get AI predictions
    if (_predictionEngine.isInitialized && cycleHistory.isNotEmpty) {
      try {
        final predictions = await _predictionEngine.generatePredictions(
          user: user,
          historicalData: cycleHistory,
          biometricData: healthData['biometrics'],
          lifestyleData: additionalData?['lifestyle'],
          moodData: additionalData?['mood'],
        );
        healthData['predictions'] = _predictionResultToMap(predictions);
      } catch (e) {
        debugPrint('Warning: Could not fetch prediction data: $e');
        healthData['predictions'] = <String, dynamic>{};
      }
    }

    // Get emotional intelligence data
    if (_emotionalEngine.isInitialized) {
      try {
        final emotionalReport = await _emotionalEngine.generateWellnessReport(
          user: user,
          currentPhase: 'current',
          cycleHistory: cycleHistory,
        );
        healthData['emotional'] = _emotionalReportToMap(emotionalReport);
      } catch (e) {
        debugPrint('Warning: Could not fetch emotional data: $e');
        healthData['emotional'] = <String, dynamic>{};
      }
    }

    // Add additional data
    if (additionalData != null) {
      healthData.addAll(additionalData);
    }

    return healthData;
  }

  Map<String, dynamic> _predictionResultToMap(PredictionResult result) {
    return {
      'confidence': result.confidence,
      'health_score': result.healthScore,
      'cycle_prediction': result.cycleLengthPrediction,
      'ovulation_prediction': result.ovulationPrediction,
      'fertility_insights': result.fertilityInsights,
      'risk_factors': result.riskFactors,
    };
  }

  Map<String, dynamic> _emotionalReportToMap(EmotionalWellnessReport report) {
    return {
      'wellness_score': report.wellnessScore,
      'stability': report.stability,
      'patterns': report.patterns,
      'risk_factors': report.riskFactors,
      'strengths': report.strengths,
    };
  }

  double _calculateOverallHealthScore(Map<String, double> healthScores) {
    if (healthScores.isEmpty) return 0.5;

    final weights = {
      'reproductive': 0.25,
      'metabolic': 0.20,
      'hormonal': 0.20,
      'cardiovascular': 0.15,
      'mental': 0.10,
      'nutritional': 0.10,
    };

    double weightedSum = 0.0;
    double totalWeight = 0.0;

    for (final entry in healthScores.entries) {
      final weight = weights[entry.key] ?? 0.1;
      weightedSum += entry.value * weight;
      totalWeight += weight;
    }

    return totalWeight > 0 ? (weightedSum / totalWeight).clamp(0.0, 1.0) : 0.5;
  }

  List<String> _identifyKeyFindings(
    Map<String, double> healthScores,
    ConditionScreeningResult conditionScreening,
    TrendAnalysisResult trendAnalysis,
  ) {
    final findings = <String>[];

    // Health score findings
    healthScores.forEach((category, score) {
      if (score < 0.4) {
        findings.add('${category.capitalize()} health shows concerning patterns (${(score * 100).round()}%)');
      } else if (score > 0.8) {
        findings.add('Excellent ${category} health indicators (${(score * 100).round()}%)');
      }
    });

    // Condition screening findings
    for (final risk in conditionScreening.detectedRisks) {
      if (risk['confidence'] > 0.7) {
        findings.add('Elevated risk detected: ${risk['condition']}');
      }
    }

    // Trend findings
    if (trendAnalysis.overallTrend == 'declining') {
      findings.add('Health trends show declining pattern over recent cycles');
    } else if (trendAnalysis.overallTrend == 'improving') {
      findings.add('Positive health trends detected across multiple indicators');
    }

    return findings.take(5).toList(); // Limit to top 5 findings
  }

  List<String> _generateNextSteps(
    List<HealthRecommendation> recommendations,
    RiskAssessmentResult riskAssessments,
  ) {
    final nextSteps = <String>[];

    // High priority recommendations
    final highPriorityRecs = recommendations
        .where((r) => r.priority == RecommendationPriority.high)
        .take(3);

    for (final rec in highPriorityRecs) {
      nextSteps.add(rec.action);
    }

    // Risk-based next steps
    for (final risk in riskAssessments.identifiedRisks.take(2)) {
      nextSteps.add('Monitor and address: ${risk['description']}');
    }

    return nextSteps;
  }

  List<String> _identifyFlaggedConcerns(
    Map<String, double> quickScores,
    List<Map<String, dynamic>> immediateRisks,
  ) {
    final concerns = <String>[];

    // Score-based concerns
    quickScores.forEach((category, score) {
      if (score < 0.3) {
        concerns.add('Critical ${category} indicators');
      }
    });

    // Risk-based concerns
    for (final risk in immediateRisks) {
      if (risk['severity'] == 'high') {
        concerns.add(risk['description']);
      }
    }

    return concerns;
  }

  bool _determineFollowUpNeeded(
    Map<String, double> quickScores,
    List<Map<String, dynamic>> immediateRisks,
  ) {
    // Check if any scores are critically low
    final hasCriticalScores = quickScores.values.any((score) => score < 0.3);

    // Check if any high-severity risks are present
    final hasHighRisks = immediateRisks.any((risk) => risk['severity'] == 'high');

    return hasCriticalScores || hasHighRisks;
  }

  Future<List<HealthRecommendation>> _generateActionableRecommendations(
    UserProfile user,
    Map<String, double> healthScores,
    FertilityAnalysisResult fertilityAnalysis,
    ConditionScreeningResult conditionScreening,
    List<SupplementRecommendation> supplementRecommendations,
    RiskAssessmentResult riskAssessments,
    PersonalizationInsights personalizedInsights,
  ) async {
    final recommendations = <HealthRecommendation>[];

    // Health score based recommendations
    healthScores.forEach((category, score) {
      if (score < 0.6) {
        recommendations.add(HealthRecommendation(
          category: category,
          priority: score < 0.4 ? RecommendationPriority.high : RecommendationPriority.medium,
          action: 'Improve ${category} health through targeted interventions',
          reasoning: 'Current ${category} score: ${(score * 100).round()}%',
          expectedOutcome: 'Enhanced ${category} function and overall wellness',
          timeframe: score < 0.4 ? '2-4 weeks' : '4-8 weeks',
        ));
      }
    });

    // Fertility-based recommendations
    if (fertilityAnalysis.fertilityScore < 0.7) {
      recommendations.add(HealthRecommendation(
        category: 'fertility',
        priority: RecommendationPriority.high,
        action: 'Optimize fertility through lifestyle and nutritional support',
        reasoning: 'Fertility analysis shows potential for improvement',
        expectedOutcome: 'Enhanced reproductive health and fertility markers',
        timeframe: '3-6 months',
      ));
    }

    // Risk-based recommendations
    for (final risk in riskAssessments.identifiedRisks.take(3)) {
      recommendations.add(HealthRecommendation(
        category: 'risk_management',
        priority: RecommendationPriority.high,
        action: 'Address identified risk: ${risk['description']}',
        reasoning: 'Risk assessment indicates attention needed',
        expectedOutcome: 'Reduced health risk and improved outcomes',
        timeframe: '2-8 weeks',
      ));
    }

    // Add supplement recommendations as health recommendations
    for (final suppRec in supplementRecommendations.take(3)) {
      recommendations.add(HealthRecommendation(
        category: 'nutrition',
        priority: RecommendationPriority.medium,
        action: 'Consider ${suppRec.name}: ${suppRec.dosage}',
        reasoning: suppRec.rationale,
        expectedOutcome: suppRec.expectedBenefits.join(', '),
        timeframe: '4-12 weeks',
      ));
    }

    return recommendations;
  }

  Future<List<String>> _generateUrgentRecommendations(
    UserProfile user,
    String currentPhase,
    Map<String, double> quickScores,
    List<Map<String, dynamic>> immediateRisks,
  ) async {
    final urgent = <String>[];

    // Critical score recommendations
    quickScores.forEach((category, score) {
      if (score < 0.3) {
        urgent.add('Immediate attention needed for ${category} health');
      }
    });

    // High-risk recommendations
    for (final risk in immediateRisks) {
      if (risk['severity'] == 'high') {
        urgent.add('Urgent: ${risk['recommendation']}');
      }
    }

    // Phase-specific urgent recommendations
    if (currentPhase == 'menstrual' && quickScores['pain'] != null && quickScores['pain']! < 0.2) {
      urgent.add('Severe menstrual symptoms detected - consider pain management');
    }

    return urgent.take(3).toList();
  }

  Future<void> _generateHealthInsights() async {
    // Generate periodic health insights for all users
    // This would typically iterate through active users and generate insights
    debugPrint('🔍 Generating health insights...');
  }

  void dispose() {
    _healthInsightStream.close();
    _healthReportCache.clear();
  }
}

// Core Analytics Components

class HealthScoringEngine {
  Future<void> initialize() async {
    debugPrint('🏥 Initializing health scoring engine...');
  }

  Future<Map<String, double>> calculateHealthScores(
    UserProfile user,
    List<CycleData> cycleHistory,
    Map<String, dynamic> healthData,
    String currentPhase,
  ) async {
    final scores = <String, double>{};

    scores['reproductive'] = _calculateReproductiveScore(cycleHistory, healthData);
    scores['hormonal'] = _calculateHormonalScore(cycleHistory, healthData, currentPhase);
    scores['metabolic'] = _calculateMetabolicScore(user, healthData);
    scores['cardiovascular'] = _calculateCardiovascularScore(healthData);
    scores['mental'] = _calculateMentalHealthScore(healthData);
    scores['nutritional'] = _calculateNutritionalScore(user, healthData);

    return scores;
  }

  Future<Map<String, double>> calculateQuickScores(
    UserProfile user,
    String currentPhase,
    Map<String, dynamic>? symptoms,
    Map<String, dynamic>? biometrics,
  ) async {
    final scores = <String, double>{};

    scores['overall'] = _calculateQuickOverallScore(user, symptoms, biometrics);
    scores['pain'] = _calculatePainScore(symptoms);
    scores['energy'] = _calculateEnergyScore(symptoms, biometrics);
    scores['mood'] = _calculateMoodScore(symptoms);

    return scores;
  }

  double _calculateReproductiveScore(List<CycleData> cycles, Map<String, dynamic> data) {
    if (cycles.isEmpty) return 0.5;

    double score = 1.0;

    // Cycle regularity
    final lengths = cycles.map((c) => c.length).toList();
    final avgLength = lengths.reduce((a, b) => a + b) / lengths.length;
    final variance = lengths.map((l) => math.pow(l - avgLength, 2)).reduce((a, b) => a + b) / lengths.length;
    final regularity = 1.0 - (math.sqrt(variance) / avgLength).clamp(0.0, 1.0);
    score *= 0.4 + (regularity * 0.6);

    // Flow consistency
    final flowIntensities = cycles.map((c) => _flowToNumeric(c.flowIntensity ?? FlowIntensity.none)).toList();
    final flowVariance = _calculateVariance(flowIntensities);
    final flowConsistency = 1.0 - (flowVariance / 5.0).clamp(0.0, 1.0);
    score *= 0.3 + (flowConsistency * 0.7);

    // Symptom severity
    final avgSymptomCount = cycles.map((c) => c.symptoms.length).reduce((a, b) => a + b) / cycles.length;
    final symptomScore = (1.0 - (avgSymptomCount / 10.0)).clamp(0.0, 1.0);
    score *= 0.5 + (symptomScore * 0.5);

    return score.clamp(0.0, 1.0);
  }

  double _calculateHormonalScore(List<CycleData> cycles, Map<String, dynamic> data, String phase) {
    double score = 0.7; // Base score

    // Mood consistency
    final moodData = data['emotional'] as Map<String, dynamic>?;
    if (moodData != null) {
      final stability = (moodData['stability'] as num?)?.toDouble() ?? 0.5;
      score *= 0.5 + (stability * 0.5);
    }

    // Cycle phase appropriateness
    final phaseScore = _assessPhaseAppropriateSymptoms(cycles, phase);
    score *= 0.6 + (phaseScore * 0.4);

    return score.clamp(0.0, 1.0);
  }

  double _calculateMetabolicScore(UserProfile user, Map<String, dynamic> data) {
    double score = 0.7;

    final biometrics = data['biometrics'] as Map<String, dynamic>?;
    if (biometrics != null) {
      // Weight stability
      final weight = (biometrics['weight'] as num?)?.toDouble();
      final height = (biometrics['height'] as num?)?.toDouble();
      if (weight != null && height != null && height > 0) {
        final bmi = weight / math.pow(height / 100, 2);
        if (bmi >= 18.5 && bmi <= 24.9) {
          score *= 1.1;
        } else {
          score *= 0.9;
        }
      }

      // Energy levels
      final energy = (biometrics['energy_level'] as num?)?.toDouble() ?? 0.5;
      score *= 0.7 + (energy * 0.3);
    }

    return score.clamp(0.0, 1.0);
  }

  double _calculateCardiovascularScore(Map<String, dynamic> data) {
    double score = 0.7;

    final biometrics = data['biometrics'] as Map<String, dynamic>?;
    if (biometrics != null) {
      // Heart rate variability
      final hrv = (biometrics['hrv'] as num?)?.toDouble();
      if (hrv != null) {
        // Higher HRV generally indicates better cardiovascular health
        final hrvScore = (hrv / 50.0).clamp(0.5, 1.0);
        score *= hrvScore;
      }

      // Resting heart rate
      final restingHR = (biometrics['resting_heart_rate'] as num?)?.toDouble();
      if (restingHR != null) {
        // Optimal resting HR is typically 60-100 bpm
        if (restingHR >= 60 && restingHR <= 80) {
          score *= 1.0;
        } else {
          score *= 0.8;
        }
      }
    }

    return score.clamp(0.0, 1.0);
  }

  double _calculateMentalHealthScore(Map<String, dynamic> data) {
    final emotional = data['emotional'] as Map<String, dynamic>?;
    if (emotional != null) {
      final wellnessScore = (emotional['wellness_score'] as num?)?.toDouble() ?? 0.5;
      final stability = (emotional['stability'] as num?)?.toDouble() ?? 0.5;
      return ((wellnessScore * 0.7) + (stability * 0.3)).clamp(0.0, 1.0);
    }
    return 0.5;
  }

  double _calculateNutritionalScore(UserProfile user, Map<String, dynamic> data) {
    double score = 0.7;

    // Base on user's reported health concerns and lifestyle
    if (user.healthConcerns.contains('nutritional_deficiency')) {
      score *= 0.8;
    }

    final biometrics = data['biometrics'] as Map<String, dynamic>?;
    if (biometrics != null) {
      // Energy consistency
      final energyStability = (biometrics['energy_stability'] as num?)?.toDouble() ?? 0.5;
      score *= 0.6 + (energyStability * 0.4);
    }

    return score.clamp(0.0, 1.0);
  }

  double _calculateQuickOverallScore(
    UserProfile user, 
    Map<String, dynamic>? symptoms, 
    Map<String, dynamic>? biometrics,
  ) {
    double score = 0.7;

    if (symptoms != null) {
      final painLevel = (symptoms['pain_level'] as num?)?.toDouble() ?? 0.0;
      score *= (1.0 - (painLevel / 10.0)).clamp(0.5, 1.0);

      final energyLevel = (symptoms['energy_level'] as num?)?.toDouble() ?? 0.5;
      score *= 0.7 + (energyLevel * 0.3);
    }

    if (biometrics != null) {
      final overallWellness = (biometrics['wellness_indicator'] as num?)?.toDouble() ?? 0.7;
      score *= 0.8 + (overallWellness * 0.2);
    }

    return score.clamp(0.0, 1.0);
  }

  double _calculatePainScore(Map<String, dynamic>? symptoms) {
    if (symptoms == null) return 0.7;
    
    final painLevel = (symptoms['pain_level'] as num?)?.toDouble() ?? 0.0;
    return (1.0 - (painLevel / 10.0)).clamp(0.0, 1.0);
  }

  double _calculateEnergyScore(Map<String, dynamic>? symptoms, Map<String, dynamic>? biometrics) {
    double score = 0.5;

    if (symptoms != null) {
      final energyLevel = (symptoms['energy_level'] as num?)?.toDouble() ?? 0.5;
      score = energyLevel;
    }

    if (biometrics != null) {
      final sleepQuality = (biometrics['sleep_quality'] as num?)?.toDouble() ?? 0.7;
      score = (score * 0.7) + (sleepQuality * 0.3);
    }

    return score.clamp(0.0, 1.0);
  }

  double _calculateMoodScore(Map<String, dynamic>? symptoms) {
    if (symptoms == null) return 0.7;
    
    final moodRating = (symptoms['mood_rating'] as num?)?.toDouble() ?? 0.7;
    return moodRating.clamp(0.0, 1.0);
  }

  double _flowToNumeric(FlowIntensity flow) {
    switch (flow) {
      case FlowIntensity.none: return 0.0;
      case FlowIntensity.spotting: return 1.0;
      case FlowIntensity.light: return 2.0;
      case FlowIntensity.medium: return 3.0;
      case FlowIntensity.heavy: return 4.0;
      case FlowIntensity.veryHeavy: return 5.0;
    }
  }

  double _calculateVariance(List<double> values) {
    if (values.isEmpty) return 0.0;
    
    final mean = values.reduce((a, b) => a + b) / values.length;
    return values.map((v) => math.pow(v - mean, 2)).reduce((a, b) => a + b) / values.length;
  }

  double _assessPhaseAppropriateSymptoms(List<CycleData> cycles, String phase) {
    // Simplified assessment of whether symptoms align with cycle phase
    return 0.7; // Placeholder
  }
}

class FertilityAnalyzer {
  Future<void> initialize() async {
    debugPrint('👶 Initializing fertility analyzer...');
  }

  Future<FertilityAnalysisResult> analyzeFertility(
    UserProfile user,
    List<CycleData> cycleHistory,
    Map<String, dynamic> healthData,
    String currentPhase,
  ) async {
    final fertilityScore = _calculateFertilityScore(user, cycleHistory, healthData);
    final ovulationPrediction = _predictOvulation(cycleHistory);
    final fertilityWindow = _calculateOptimalWindow(cycleHistory, ovulationPrediction);
    final factors = _identifyFertilityFactors(user, cycleHistory, healthData);

    return FertilityAnalysisResult(
      fertilityScore: fertilityScore,
      ovulationPrediction: ovulationPrediction,
      fertilityWindow: fertilityWindow,
      factors: factors,
      recommendations: _generateFertilityRecommendations(fertilityScore, factors),
    );
  }

  Future<EnhancedFertilityWindow> predictFertilityWindow(
    UserProfile user,
    List<CycleData> cycleHistory,
    Map<String, dynamic>? biometricData,
    int predictionDays,
  ) async {
    final ovulationDay = _predictOvulation(cycleHistory);
    final confidence = _calculatePredictionConfidence(cycleHistory);

    return EnhancedFertilityWindow(
      ovulationDate: DateTime.now().add(Duration(days: ovulationDay.round())),
      fertilityStart: DateTime.now().add(Duration(days: (ovulationDay - 5).round())),
      fertilityEnd: DateTime.now().add(Duration(days: (ovulationDay + 1).round())),
      confidence: confidence,
      factors: _identifyFertilityFactors(user, cycleHistory, biometricData ?? {}),
      recommendations: _generateTimingRecommendations(ovulationDay, confidence),
    );
  }

  double _calculateFertilityScore(
    UserProfile user, 
    List<CycleData> cycles, 
    Map<String, dynamic> data,
  ) {
    double score = 0.8; // Base fertility score

    // Age factor
    final age = user.age ?? 25;
    if (age < 35) {
      score *= 1.0;
    } else if (age < 40) {
      score *= 0.9;
    } else {
      score *= 0.7;
    }

    // Cycle regularity
    if (cycles.isNotEmpty) {
      final lengths = cycles.map((c) => c.length).toList();
      final avgLength = lengths.reduce((a, b) => a + b) / lengths.length;
      final variance = lengths.map((l) => math.pow(l - avgLength, 2)).reduce((a, b) => a + b) / lengths.length;
      final regularity = 1.0 - (math.sqrt(variance) / avgLength).clamp(0.0, 0.5);
      score *= 0.7 + (regularity * 0.3);
    }

    // Health conditions
    if (user.healthConcerns.contains('pcos')) {
      score *= 0.7;
    }
    if (user.healthConcerns.contains('endometriosis')) {
      score *= 0.8;
    }

    return score.clamp(0.0, 1.0);
  }

  double _predictOvulation(List<CycleData> cycles) {
    if (cycles.isEmpty) return 14.0;

    final avgLength = cycles.map((c) => c.length).reduce((a, b) => a + b) / cycles.length;
    return avgLength / 2.0; // Simplified ovulation prediction
  }

  Map<String, DateTime> _calculateOptimalWindow(List<CycleData> cycles, double ovulationDay) {
    final now = DateTime.now();
    return {
      'fertile_start': now.add(Duration(days: (ovulationDay - 5).round())),
      'peak_fertility': now.add(Duration(days: ovulationDay.round())),
      'fertile_end': now.add(Duration(days: (ovulationDay + 1).round())),
    };
  }

  Map<String, dynamic> _identifyFertilityFactors(
    UserProfile user, 
    List<CycleData> cycles, 
    Map<String, dynamic> data,
  ) {
    final factors = <String, dynamic>{};

    factors['age_impact'] = user.age != null && user.age! > 35 ? 'moderate' : 'low';
    factors['cycle_regularity'] = cycles.isNotEmpty ? 'good' : 'unknown';
    factors['stress_level'] = data['emotional']?['stability'] < 0.5 ? 'high' : 'moderate';
    factors['lifestyle_factors'] = user.lifestyle == 'active' ? 'positive' : 'needs_improvement';

    return factors;
  }

  List<String> _generateFertilityRecommendations(double score, Map<String, dynamic> factors) {
    final recommendations = <String>[];

    if (score < 0.7) {
      recommendations.add('Consider comprehensive fertility assessment');
    }

    if (factors['stress_level'] == 'high') {
      recommendations.add('Implement stress reduction techniques');
    }

    if (factors['lifestyle_factors'] == 'needs_improvement') {
      recommendations.add('Optimize nutrition and exercise routine');
    }

    recommendations.add('Track basal body temperature for accurate ovulation detection');
    recommendations.add('Consider fertility-supporting supplements (folic acid, CoQ10)');

    return recommendations;
  }

  double _calculatePredictionConfidence(List<CycleData> cycles) {
    if (cycles.isEmpty) return 0.3;
    if (cycles.length < 3) return 0.5;
    
    // Higher confidence with more regular cycles
    final lengths = cycles.map((c) => c.length).toList();
    final avgLength = lengths.reduce((a, b) => a + b) / lengths.length;
    final variance = lengths.map((l) => math.pow(l - avgLength, 2)).reduce((a, b) => a + b) / lengths.length;
    final regularity = 1.0 - (math.sqrt(variance) / avgLength).clamp(0.0, 0.5);
    
    return (0.5 + (regularity * 0.4) + (cycles.length / 12 * 0.1)).clamp(0.3, 0.9);
  }

  List<String> _generateTimingRecommendations(double ovulationDay, double confidence) {
    final recommendations = <String>[];

    if (confidence > 0.7) {
      recommendations.add('Optimal timing: ${(ovulationDay - 2).round()} to ${ovulationDay.round()} days');
    } else {
      recommendations.add('Monitor cervical mucus and use ovulation tests for better timing');
    }

    recommendations.add('Maintain consistent tracking for improved predictions');
    return recommendations;
  }
}

class ConditionDetector {
  Future<void> initialize() async {
    debugPrint('🔍 Initializing condition detector...');
  }

  Future<ConditionScreeningResult> screenForConditions(
    UserProfile user,
    List<CycleData> cycleHistory,
    Map<String, dynamic> healthData,
    String currentPhase,
  ) async {
    final detectedRisks = <Map<String, dynamic>>[];

    // Screen for PCOS
    final pcosRisk = _screenForPCOS(user, cycleHistory, healthData);
    if (pcosRisk['risk_level'] > 0.3) detectedRisks.add(pcosRisk);

    // Screen for Endometriosis
    final endoRisk = _screenForEndometriosis(user, cycleHistory, healthData);
    if (endoRisk['risk_level'] > 0.3) detectedRisks.add(endoRisk);

    // Screen for Thyroid issues
    final thyroidRisk = _screenForThyroidIssues(user, cycleHistory, healthData);
    if (thyroidRisk['risk_level'] > 0.3) detectedRisks.add(thyroidRisk);

    // Screen for Iron deficiency
    final ironRisk = _screenForIronDeficiency(user, cycleHistory, healthData);
    if (ironRisk['risk_level'] > 0.3) detectedRisks.add(ironRisk);

    return ConditionScreeningResult(
      detectedRisks: detectedRisks,
      screeningDate: DateTime.now(),
      confidenceLevel: _calculateOverallConfidence(detectedRisks),
      recommendations: _generateScreeningRecommendations(detectedRisks),
    );
  }

  Map<String, dynamic> _screenForPCOS(
    UserProfile user, 
    List<CycleData> cycles, 
    Map<String, dynamic> data,
  ) {
    double riskLevel = 0.0;
    final indicators = <String>[];

    // Irregular cycles
    if (cycles.isNotEmpty) {
      final lengths = cycles.map((c) => c.length).toList();
      final variance = lengths.map((l) => math.pow(l - 28, 2)).reduce((a, b) => a + b) / lengths.length;
      if (math.sqrt(variance) > 7) {
        riskLevel += 0.3;
        indicators.add('Irregular menstrual cycles');
      }
    }

    // Long cycles
    final avgLength = cycles.isNotEmpty 
        ? cycles.map((c) => c.length).reduce((a, b) => a + b) / cycles.length 
        : 28.0;
    if (avgLength > 35) {
      riskLevel += 0.2;
      indicators.add('Extended cycle length');
    }

    // Heavy bleeding
    final heavyFlowCycles = cycles.where((c) => 
        c.flowIntensity == FlowIntensity.heavy || c.flowIntensity == FlowIntensity.veryHeavy).length;
    if (heavyFlowCycles > cycles.length * 0.5) {
      riskLevel += 0.1;
      indicators.add('Heavy menstrual bleeding');
    }

    // Weight/metabolic indicators
    if (user.healthConcerns.contains('weight_management')) {
      riskLevel += 0.2;
      indicators.add('Weight management concerns');
    }

    return {
      'condition': 'PCOS',
      'risk_level': riskLevel.clamp(0.0, 1.0),
      'confidence': cycles.length > 6 ? 0.8 : 0.5,
      'indicators': indicators,
      'recommendation': riskLevel > 0.5 
          ? 'Consult healthcare provider for PCOS evaluation'
          : 'Continue monitoring cycle patterns',
    };
  }

  Map<String, dynamic> _screenForEndometriosis(
    UserProfile user, 
    List<CycleData> cycles, 
    Map<String, dynamic> data,
  ) {
    double riskLevel = 0.0;
    final indicators = <String>[];

    // Severe pain patterns
    final severeSymptoms = ['severe_cramps', 'pelvic_pain', 'back_pain'];
    for (final cycle in cycles) {
      final severeCount = cycle.symptoms.where((s) => severeSymptoms.contains(s)).length;
      if (severeCount >= 2) {
        riskLevel += 0.1;
      }
    }

    if (riskLevel > 0.3) {
      indicators.add('Recurring severe pain patterns');
    }

    // Heavy bleeding
    final heavyFlowCount = cycles.where((c) => 
        c.flowIntensity == FlowIntensity.heavy || c.flowIntensity == FlowIntensity.veryHeavy).length;
    if (heavyFlowCount > cycles.length * 0.4) {
      riskLevel += 0.2;
      indicators.add('Frequent heavy bleeding');
    }

    // Pain scores
    final avgPain = cycles.where((c) => c.pain != null)
        .map((c) => c.pain!).fold(0.0, (sum, pain) => sum + pain) / 
        cycles.where((c) => c.pain != null).length;
    if (avgPain > 3.5) {
      riskLevel += 0.3;
      indicators.add('High average pain levels');
    }

    return {
      'condition': 'Endometriosis',
      'risk_level': riskLevel.clamp(0.0, 1.0),
      'confidence': cycles.length > 8 ? 0.7 : 0.4,
      'indicators': indicators,
      'recommendation': riskLevel > 0.5 
          ? 'Consider evaluation for endometriosis'
          : 'Monitor pain patterns and severity',
    };
  }

  Map<String, dynamic> _screenForThyroidIssues(
    UserProfile user, 
    List<CycleData> cycles, 
    Map<String, dynamic> data,
  ) {
    double riskLevel = 0.0;
    final indicators = <String>[];

    // Cycle irregularity
    if (cycles.isNotEmpty) {
      final lengths = cycles.map((c) => c.length).toList();
      final variance = lengths.map((l) => math.pow(l - 28, 2)).reduce((a, b) => a + b) / lengths.length;
      if (math.sqrt(variance) > 10) {
        riskLevel += 0.2;
        indicators.add('Significant cycle irregularity');
      }
    }

    // Energy and mood patterns
    final emotional = data['emotional'] as Map<String, dynamic>?;
    if (emotional != null) {
      final stability = (emotional['stability'] as num?)?.toDouble() ?? 0.7;
      if (stability < 0.4) {
        riskLevel += 0.2;
        indicators.add('Mood instability patterns');
      }
    }

    // Energy levels from biometrics
    final biometrics = data['biometrics'] as Map<String, dynamic>?;
    if (biometrics != null) {
      final energy = (biometrics['energy_level'] as num?)?.toDouble() ?? 0.7;
      if (energy < 0.4) {
        riskLevel += 0.2;
        indicators.add('Persistent low energy');
      }
    }

    return {
      'condition': 'Thyroid Dysfunction',
      'risk_level': riskLevel.clamp(0.0, 1.0),
      'confidence': 0.6,
      'indicators': indicators,
      'recommendation': riskLevel > 0.4 
          ? 'Consider thyroid function testing'
          : 'Continue monitoring energy and cycle patterns',
    };
  }

  Map<String, dynamic> _screenForIronDeficiency(
    UserProfile user, 
    List<CycleData> cycles, 
    Map<String, dynamic> data,
  ) {
    double riskLevel = 0.0;
    final indicators = <String>[];

    // Heavy bleeding patterns
    final heavyFlowCount = cycles.where((c) => 
        c.flowIntensity == FlowIntensity.heavy || c.flowIntensity == FlowIntensity.veryHeavy).length;
    if (heavyFlowCount > cycles.length * 0.3) {
      riskLevel += 0.4;
      indicators.add('Frequent heavy menstrual bleeding');
    }

    // Fatigue indicators
    final biometrics = data['biometrics'] as Map<String, dynamic>?;
    if (biometrics != null) {
      final energy = (biometrics['energy_level'] as num?)?.toDouble() ?? 0.7;
      if (energy < 0.3) {
        riskLevel += 0.3;
        indicators.add('Persistent fatigue');
      }
    }

    // Dietary factors
    if (user.lifestyle == 'sedentary') {
      riskLevel += 0.1;
      indicators.add('Limited physical activity');
    }

    return {
      'condition': 'Iron Deficiency',
      'risk_level': riskLevel.clamp(0.0, 1.0),
      'confidence': 0.7,
      'indicators': indicators,
      'recommendation': riskLevel > 0.5 
          ? 'Consider iron level testing and dietary assessment'
          : 'Monitor energy levels and menstrual flow',
    };
  }

  double _calculateOverallConfidence(List<Map<String, dynamic>> risks) {
    if (risks.isEmpty) return 0.8;
    
    final confidences = risks.map((r) => r['confidence'] as double);
    return confidences.reduce((a, b) => a + b) / risks.length;
  }

  List<String> _generateScreeningRecommendations(List<Map<String, dynamic>> risks) {
    final recommendations = <String>[];
    
    for (final risk in risks) {
      if (risk['risk_level'] > 0.5) {
        recommendations.add(risk['recommendation']);
      }
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('Continue regular health monitoring');
    }
    
    return recommendations;
  }
}

class SupplementRecommender {
  Future<void> initialize() async {
    debugPrint('💊 Initializing supplement recommender...');
  }

  Future<List<SupplementRecommendation>> generateRecommendations(
    UserProfile user,
    List<CycleData> cycleHistory,
    Map<String, dynamic> healthData,
    Map<String, double> healthScores,
    ConditionScreeningResult conditionScreening,
  ) async {
    final recommendations = <SupplementRecommendation>[];

    // Core reproductive health supplements
    recommendations.addAll(_getCoreSupplements(user, cycleHistory));

    // Condition-specific supplements
    recommendations.addAll(_getConditionSpecificSupplements(conditionScreening));

    // Health score-based supplements
    recommendations.addAll(_getHealthScoreBasedSupplements(healthScores));

    // Personalized based on symptoms
    recommendations.addAll(_getSymptomBasedSupplements(cycleHistory));

    return recommendations;
  }

  List<SupplementRecommendation> _getCoreSupplements(UserProfile user, List<CycleData> cycles) {
    final core = <SupplementRecommendation>[];

    // Folic Acid - essential for all women of reproductive age
    core.add(SupplementRecommendation(
      name: 'Folic Acid',
      dosage: '400-800 mcg daily',
      timing: 'Morning with breakfast',
      priority: SupplementPriority.high,
      category: 'reproductive_health',
      rationale: 'Essential for reproductive health and neural tube development',
      expectedBenefits: ['Supports reproductive health', 'Prevents neural tube defects', 'Supports DNA synthesis'],
      contraindications: ['Consult doctor if taking methotrexate'],
      duration: 'Ongoing',
    ));

    // Vitamin D - often deficient
    core.add(SupplementRecommendation(
      name: 'Vitamin D3',
      dosage: '1000-2000 IU daily',
      timing: 'With meals',
      priority: SupplementPriority.high,
      category: 'immune_support',
      rationale: 'Supports immune function, bone health, and hormonal balance',
      expectedBenefits: ['Improved immune function', 'Better calcium absorption', 'Hormonal support'],
      contraindications: ['Monitor levels if taking high doses'],
      duration: 'Ongoing',
    ));

    // Omega-3 fatty acids
    core.add(SupplementRecommendation(
      name: 'Omega-3 (EPA/DHA)',
      dosage: '1000-2000 mg daily',
      timing: 'With meals',
      priority: SupplementPriority.medium,
      category: 'anti_inflammatory',
      rationale: 'Reduces inflammation and supports hormonal balance',
      expectedBenefits: ['Reduced inflammation', 'Improved mood', 'Cardiovascular support'],
      contraindications: ['Consult doctor if taking blood thinners'],
      duration: 'Ongoing',
    ));

    return core;
  }

  List<SupplementRecommendation> _getConditionSpecificSupplements(ConditionScreeningResult screening) {
    final specific = <SupplementRecommendation>[];

    for (final risk in screening.detectedRisks) {
      final condition = risk['condition'] as String;
      
      if (condition == 'PCOS' && risk['risk_level'] > 0.4) {
        specific.add(SupplementRecommendation(
          name: 'Inositol',
          dosage: '2000 mg twice daily',
          timing: 'Morning and evening',
          priority: SupplementPriority.high,
          category: 'hormonal_balance',
          rationale: 'May help improve insulin sensitivity and hormonal balance in PCOS',
          expectedBenefits: ['Improved insulin sensitivity', 'Better ovulation', 'Reduced testosterone'],
          contraindications: ['May cause mild digestive upset initially'],
          duration: '3-6 months minimum',
        ));

        specific.add(SupplementRecommendation(
          name: 'Spearmint Tea',
          dosage: '2 cups daily',
          timing: 'Between meals',
          priority: SupplementPriority.medium,
          category: 'hormonal_balance',
          rationale: 'May help reduce androgens in PCOS',
          expectedBenefits: ['Reduced excess hair growth', 'Hormonal balance'],
          contraindications: ['Avoid if pregnant or breastfeeding'],
          duration: '2-3 months',
        ));
      }

      if (condition == 'Iron Deficiency' && risk['risk_level'] > 0.5) {
        specific.add(SupplementRecommendation(
          name: 'Iron Bisglycinate',
          dosage: '25-50 mg daily',
          timing: 'On empty stomach or with vitamin C',
          priority: SupplementPriority.high,
          category: 'nutritional_support',
          rationale: 'Gentle form of iron to address deficiency without digestive upset',
          expectedBenefits: ['Improved energy', 'Better oxygen transport', 'Reduced fatigue'],
          contraindications: ['Take away from calcium and coffee', 'Monitor iron levels'],
          duration: '3-6 months',
        ));
      }
    }

    return specific;
  }

  List<SupplementRecommendation> _getHealthScoreBasedSupplements(Map<String, double> scores) {
    final scoreBased = <SupplementRecommendation>[];

    if (scores['mental'] != null && scores['mental']! < 0.6) {
      scoreBased.add(SupplementRecommendation(
        name: 'Magnesium Glycinate',
        dosage: '200-400 mg daily',
        timing: 'Evening before bed',
        priority: SupplementPriority.medium,
        category: 'stress_support',
        rationale: 'Supports nervous system function and stress response',
        expectedBenefits: ['Improved sleep', 'Reduced anxiety', 'Better stress management'],
        contraindications: ['May cause drowsiness', 'Reduce dose if digestive upset occurs'],
        duration: '2-4 months',
      ));
    }

    if (scores['cardiovascular'] != null && scores['cardiovascular']! < 0.7) {
      scoreBased.add(SupplementRecommendation(
        name: 'CoQ10',
        dosage: '100-200 mg daily',
        timing: 'With meals',
        priority: SupplementPriority.medium,
        category: 'cardiovascular_support',
        rationale: 'Supports cellular energy production and cardiovascular health',
        expectedBenefits: ['Improved energy', 'Cardiovascular support', 'Antioxidant protection'],
        contraindications: ['May interact with blood thinners'],
        duration: '3-6 months',
      ));
    }

    return scoreBased;
  }

  List<SupplementRecommendation> _getSymptomBasedSupplements(List<CycleData> cycles) {
    final symptomBased = <SupplementRecommendation>[];

    // Analyze common symptoms across cycles
    final allSymptoms = cycles.expand((c) => c.symptoms).toList();
    final symptomCounts = <String, int>{};
    for (final symptom in allSymptoms) {
      symptomCounts[symptom] = (symptomCounts[symptom] ?? 0) + 1;
    }

    // Cramp support
    if (symptomCounts['cramps'] != null && symptomCounts['cramps']! > cycles.length * 0.5) {
      symptomBased.add(SupplementRecommendation(
        name: 'Calcium & Magnesium',
        dosage: '500 mg calcium, 250 mg magnesium daily',
        timing: 'Evening',
        priority: SupplementPriority.medium,
        category: 'symptom_relief',
        rationale: 'May help reduce menstrual cramps and muscle tension',
        expectedBenefits: ['Reduced cramp severity', 'Better muscle relaxation', 'Improved sleep'],
        contraindications: ['Space away from iron supplements'],
        duration: '2-3 cycles to assess effectiveness',
      ));
    }

    // Mood support
    if (symptomCounts['mood_swings'] != null && symptomCounts['mood_swings']! > cycles.length * 0.3) {
      symptomBased.add(SupplementRecommendation(
        name: 'Vitamin B Complex',
        dosage: 'B-50 complex daily',
        timing: 'Morning with breakfast',
        priority: SupplementPriority.medium,
        category: 'mood_support',
        rationale: 'B vitamins support neurotransmitter production and mood regulation',
        expectedBenefits: ['Improved mood stability', 'Better energy', 'Reduced PMS symptoms'],
        contraindications: ['May cause neon yellow urine (harmless)'],
        duration: '2-3 months',
      ));
    }

    return symptomBased;
  }
}

class RiskAssessment {
  Future<void> initialize() async {
    debugPrint('⚠️ Initializing risk assessment...');
  }

  Future<RiskAssessmentResult> assessRisks(
    UserProfile user,
    List<CycleData> cycleHistory,
    Map<String, dynamic> healthData,
    Map<String, double> healthScores,
    ConditionScreeningResult conditionScreening,
  ) async {
    final identifiedRisks = <Map<String, dynamic>>[];

    // Assess reproductive health risks
    identifiedRisks.addAll(await _assessReproductiveRisks(user, cycleHistory, healthData));

    // Assess metabolic risks
    identifiedRisks.addAll(await _assessMetabolicRisks(user, healthData, healthScores));

    // Assess mental health risks
    identifiedRisks.addAll(await _assessMentalHealthRisks(user, healthData, healthScores));

    // Assess lifestyle-related risks
    identifiedRisks.addAll(await _assessLifestyleRisks(user, healthData));

    return RiskAssessmentResult(
      identifiedRisks: identifiedRisks,
      overallRiskLevel: _calculateOverallRiskLevel(identifiedRisks),
      riskCategories: _categorizeRisks(identifiedRisks),
      recommendations: _generateRiskRecommendations(identifiedRisks),
      monitoringNeeded: _determineMonitoringNeeds(identifiedRisks),
    );
  }

  Future<List<Map<String, dynamic>>> assessImmediateRisks(
    UserProfile user,
    String currentPhase,
    Map<String, dynamic>? symptoms,
    Map<String, dynamic>? biometrics,
  ) async {
    final immediateRisks = <Map<String, dynamic>>[];

    // Severe pain assessment
    if (symptoms != null) {
      final painLevel = (symptoms['pain_level'] as num?)?.toDouble() ?? 0.0;
      if (painLevel > 8) {
        immediateRisks.add({
          'type': 'severe_pain',
          'severity': 'high',
          'description': 'Severe pain requiring immediate attention',
          'recommendation': 'Seek medical attention if pain persists or worsens',
        });
      }
    }

    // Abnormal bleeding patterns
    if (symptoms != null && symptoms['bleeding'] == 'heavy_unexpected') {
      immediateRisks.add({
        'type': 'abnormal_bleeding',
        'severity': 'medium',
        'description': 'Unexpected heavy bleeding outside normal cycle',
        'recommendation': 'Monitor closely and consult healthcare provider',
      });
    }

    return immediateRisks;
  }

  Future<List<Map<String, dynamic>>> _assessReproductiveRisks(
    UserProfile user,
    List<CycleData> cycles,
    Map<String, dynamic> data,
  ) async {
    final risks = <Map<String, dynamic>>[];

    // Age-related fertility risks
    if (user.age != null && user.age! > 35) {
      risks.add({
        'category': 'reproductive',
        'type': 'age_related_fertility_decline',
        'severity': user.age! > 40 ? 'high' : 'medium',
        'description': 'Age-related fertility decline',
        'risk_score': user.age! > 40 ? 0.8 : 0.5,
        'recommendation': 'Consider fertility assessment and family planning discussion',
      });
    }

    // Irregular cycle risks
    if (cycles.isNotEmpty) {
      final lengths = cycles.map((c) => c.length).toList();
      final variance = lengths.map((l) => math.pow(l - 28, 2)).reduce((a, b) => a + b) / lengths.length;
      
      if (math.sqrt(variance) > 10) {
        risks.add({
          'category': 'reproductive',
          'type': 'cycle_irregularity',
          'severity': 'medium',
          'description': 'Significant menstrual cycle irregularity',
          'risk_score': 0.6,
          'recommendation': 'Evaluate underlying hormonal causes',
        });
      }
    }

    return risks;
  }

  Future<List<Map<String, dynamic>>> _assessMetabolicRisks(
    UserProfile user,
    Map<String, dynamic> data,
    Map<String, double> scores,
  ) async {
    final risks = <Map<String, dynamic>>[];

    // Low metabolic score
    if (scores['metabolic'] != null && scores['metabolic']! < 0.4) {
      risks.add({
        'category': 'metabolic',
        'type': 'metabolic_dysfunction',
        'severity': 'medium',
        'description': 'Metabolic health indicators below optimal range',
        'risk_score': 0.7,
        'recommendation': 'Focus on nutrition optimization and metabolic support',
      });
    }

    // Weight management concerns
    if (user.healthConcerns.contains('weight_management')) {
      risks.add({
        'category': 'metabolic',
        'type': 'weight_related_risks',
        'severity': 'medium',
        'description': 'Weight management concerns affecting overall health',
        'risk_score': 0.5,
        'recommendation': 'Implement sustainable nutrition and exercise plan',
      });
    }

    return risks;
  }

  Future<List<Map<String, dynamic>>> _assessMentalHealthRisks(
    UserProfile user,
    Map<String, dynamic> data,
    Map<String, double> scores,
  ) async {
    final risks = <Map<String, dynamic>>[];

    // Mental health score assessment
    if (scores['mental'] != null && scores['mental']! < 0.3) {
      risks.add({
        'category': 'mental_health',
        'type': 'mental_health_concerns',
        'severity': 'high',
        'description': 'Mental health indicators suggest need for support',
        'risk_score': 0.8,
        'recommendation': 'Consider mental health professional consultation',
      });
    }

    // Emotional stability concerns
    final emotional = data['emotional'] as Map<String, dynamic>?;
    if (emotional != null) {
      final stability = (emotional['stability'] as num?)?.toDouble() ?? 0.7;
      if (stability < 0.3) {
        risks.add({
          'category': 'mental_health',
          'type': 'emotional_instability',
          'severity': 'medium',
          'description': 'Emotional instability patterns detected',
          'risk_score': 0.6,
          'recommendation': 'Implement stress management and emotional regulation techniques',
        });
      }
    }

    return risks;
  }

  Future<List<Map<String, dynamic>>> _assessLifestyleRisks(
    UserProfile user,
    Map<String, dynamic> data,
  ) async {
    final risks = <Map<String, dynamic>>[];

    // Sedentary lifestyle risks
    if (user.lifestyle == 'sedentary') {
      risks.add({
        'category': 'lifestyle',
        'type': 'sedentary_lifestyle',
        'severity': 'medium',
        'description': 'Sedentary lifestyle increases various health risks',
        'risk_score': 0.5,
        'recommendation': 'Gradually increase physical activity and movement',
      });
    }

    // Sleep quality risks
    final biometrics = data['biometrics'] as Map<String, dynamic>?;
    if (biometrics != null) {
      final sleepQuality = (biometrics['sleep_quality'] as num?)?.toDouble() ?? 0.7;
      if (sleepQuality < 0.4) {
        risks.add({
          'category': 'lifestyle',
          'type': 'poor_sleep_quality',
          'severity': 'medium',
          'description': 'Poor sleep quality affecting health and recovery',
          'risk_score': 0.6,
          'recommendation': 'Prioritize sleep hygiene and address sleep disorders',
        });
      }
    }

    return risks;
  }

  double _calculateOverallRiskLevel(List<Map<String, dynamic>> risks) {
    if (risks.isEmpty) return 0.2;

    final riskScores = risks.map((r) => r['risk_score'] as double).toList();
    final averageRisk = riskScores.reduce((a, b) => a + b) / riskScores.length;
    
    // Weight by number of risks
    final riskMultiplier = (risks.length / 10.0).clamp(1.0, 1.5);
    
    return (averageRisk * riskMultiplier).clamp(0.0, 1.0);
  }

  Map<String, int> _categorizeRisks(List<Map<String, dynamic>> risks) {
    final categories = <String, int>{};
    
    for (final risk in risks) {
      final category = risk['category'] as String;
      categories[category] = (categories[category] ?? 0) + 1;
    }
    
    return categories;
  }

  List<String> _generateRiskRecommendations(List<Map<String, dynamic>> risks) {
    final recommendations = <String>[];
    
    for (final risk in risks) {
      if (risk['severity'] == 'high') {
        recommendations.add(risk['recommendation']);
      }
    }
    
    // Add general recommendations
    if (risks.length > 3) {
      recommendations.add('Consider comprehensive health assessment');
    }
    
    return recommendations.take(5).toList();
  }

  Map<String, String> _determineMonitoringNeeds(List<Map<String, dynamic>> risks) {
    final monitoring = <String, String>{};
    
    for (final risk in risks) {
      final category = risk['category'] as String;
      final severity = risk['severity'] as String;
      
      if (severity == 'high') {
        monitoring[category] = 'weekly';
      } else if (severity == 'medium') {
        monitoring[category] = 'monthly';
      }
    }
    
    return monitoring;
  }
}

class PersonalizationEngine {
  Future<void> initialize() async {
    debugPrint('🎯 Initializing personalization engine...');
  }

  Future<PersonalizationInsights> generateInsights(
    UserProfile user,
    List<CycleData> cycleHistory,
    Map<String, dynamic> healthData,
    Map<String, double> healthScores,
  ) async {
    final personalityProfile = _buildPersonalityProfile(user, cycleHistory, healthData);
    final preferences = _identifyPreferences(user, healthData);
    final strengths = _identifyStrengths(healthScores, healthData);
    final opportunities = _identifyOpportunities(healthScores, healthData);

    return PersonalizationInsights(
      personalityProfile: personalityProfile,
      preferences: preferences,
      strengths: strengths,
      opportunities: opportunities,
      personalizedTips: _generatePersonalizedTips(personalityProfile, preferences, strengths),
      motivationalApproach: _determineMotivationalApproach(personalityProfile),
    );
  }

  Map<String, dynamic> _buildPersonalityProfile(
    UserProfile user,
    List<CycleData> cycles,
    Map<String, dynamic> data,
  ) {
    final profile = <String, dynamic>{};

    // Health consciousness level
    profile['health_consciousness'] = _assessHealthConsciousness(user, data);

    // Data engagement style
    profile['data_engagement'] = _assessDataEngagement(cycles, data);

    // Intervention preference
    profile['intervention_style'] = _assessInterventionStyle(user);

    // Communication preference
    profile['communication_style'] = _assessCommunicationStyle(user, data);

    return profile;
  }

  Map<String, String> _identifyPreferences(UserProfile user, Map<String, dynamic> data) {
    final preferences = <String, String>{};

    // Activity preferences
    if (user.lifestyle == 'active') {
      preferences['exercise'] = 'high_intensity';
    } else {
      preferences['exercise'] = 'gentle_gradual';
    }

    // Learning preferences
    preferences['learning'] = 'visual_data'; // Could be enhanced with user input

    // Intervention timing
    preferences['timing'] = 'proactive'; // vs reactive

    return preferences;
  }

  List<String> _identifyStrengths(Map<String, double> scores, Map<String, dynamic> data) {
    final strengths = <String>[];

    scores.forEach((category, score) {
      if (score > 0.8) {
        strengths.add('Excellent ${category} health');
      }
    });

    final emotional = data['emotional'] as Map<String, dynamic>?;
    if (emotional != null) {
      final emotionalStrengths = emotional['strengths'] as List<dynamic>? ?? [];
      strengths.addAll(emotionalStrengths.cast<String>());
    }

    return strengths.take(5).toList();
  }

  List<String> _identifyOpportunities(Map<String, double> scores, Map<String, dynamic> data) {
    final opportunities = <String>[];

    scores.forEach((category, score) {
      if (score < 0.6 && score > 0.3) {
        opportunities.add('Opportunity to improve ${category} health');
      }
    });

    return opportunities.take(3).toList();
  }

  List<String> _generatePersonalizedTips(
    Map<String, dynamic> profile,
    Map<String, String> preferences,
    List<String> strengths,
  ) {
    final tips = <String>[];

    final consciousness = profile['health_consciousness'] as String? ?? 'medium';
    final dataEngagement = profile['data_engagement'] as String? ?? 'moderate';

    if (consciousness == 'high' && dataEngagement == 'high') {
      tips.add('Your detailed tracking is paying off - use the advanced analytics to optimize timing');
    }

    if (preferences['exercise'] == 'high_intensity') {
      tips.add('Consider cycle syncing your workouts for optimal performance');
    }

    tips.add('Based on your profile, focus on ${_getTopPriorityArea(profile)} for maximum impact');

    return tips;
  }

  String _determineMotivationalApproach(Map<String, dynamic> profile) {
    final consciousness = profile['health_consciousness'] as String? ?? 'medium';
    final style = profile['intervention_style'] as String? ?? 'balanced';

    if (consciousness == 'high' && style == 'proactive') {
      return 'achievement_oriented';
    } else if (style == 'gentle') {
      return 'supportive_encouraging';
    } else {
      return 'balanced_informative';
    }
  }

  String _assessHealthConsciousness(UserProfile user, Map<String, dynamic> data) {
    if (user.healthConcerns.length > 3) return 'high';
    if (user.healthConcerns.length > 1) return 'medium';
    return 'low';
  }

  String _assessDataEngagement(List<CycleData> cycles, Map<String, dynamic> data) {
    if (cycles.length > 6 && cycles.any((c) => c.symptoms.length > 3)) return 'high';
    if (cycles.length > 3) return 'moderate';
    return 'low';
  }

  String _assessInterventionStyle(UserProfile user) {
    if (user.lifestyle == 'active') return 'proactive';
    return 'gentle';
  }

  String _assessCommunicationStyle(UserProfile user, Map<String, dynamic> data) {
    return 'detailed'; // Could be enhanced with user preferences
  }

  String _getTopPriorityArea(Map<String, dynamic> profile) {
    // Simplified priority determination
    return 'stress management'; // Would be more sophisticated in production
  }
}

class TrendAnalyzer {
  Future<void> initialize() async {
    debugPrint('📈 Initializing trend analyzer...');
  }

  Future<TrendAnalysisResult> analyzeTrends(
    UserProfile user,
    List<CycleData> cycleHistory,
    Map<String, dynamic> healthData,
    int analysisDepth,
  ) async {
    final cycleTrends = _analyzeCycleTrends(cycleHistory);
    final symptomTrends = _analyzeSymptomTrends(cycleHistory);
    final healthTrends = _analyzeHealthTrends(healthData);
    final overallTrend = _determineOverallTrend(cycleTrends, symptomTrends, healthTrends);

    return TrendAnalysisResult(
      analysisDepth: analysisDepth,
      cycleTrends: cycleTrends,
      symptomTrends: symptomTrends,
      healthTrends: healthTrends,
      overallTrend: overallTrend,
      trendConfidence: _calculateTrendConfidence(cycleHistory),
      predictions: _generateTrendPredictions(cycleTrends, symptomTrends),
      actionableInsights: _generateActionableInsights(overallTrend, cycleTrends),
    );
  }

  Map<String, dynamic> _analyzeCycleTrends(List<CycleData> cycles) {
    if (cycles.length < 3) {
      return {'insufficient_data': true};
    }

    final trends = <String, dynamic>{};
    
    // Length trends
    final lengths = cycles.map((c) => c.length).toList();
    trends['length_trend'] = _calculateTrend(lengths.map((l) => l.toDouble()).toList());
    trends['length_stability'] = _calculateStability(lengths.map((l) => l.toDouble()).toList());

    // Flow trends
    final flows = cycles.map((c) => _flowToNumeric(c.flowIntensity ?? FlowIntensity.none)).toList();
    trends['flow_trend'] = _calculateTrend(flows);

    return trends;
  }

  Map<String, dynamic> _analyzeSymptomTrends(List<CycleData> cycles) {
    final trends = <String, dynamic>{};
    
    if (cycles.isEmpty) return trends;

    // Symptom frequency trends
    final allSymptoms = cycles.expand((c) => c.symptoms).toSet();
    for (final symptom in allSymptoms) {
      final occurrences = cycles.map((c) => c.symptoms.contains(symptom) ? 1.0 : 0.0).toList();
      trends['${symptom}_trend'] = _calculateTrend(occurrences);
    }

    // Pain trends
    final painScores = cycles.where((c) => c.pain != null).map((c) => c.pain!).toList();
    if (painScores.isNotEmpty) {
      trends['pain_trend'] = _calculateTrend(painScores);
    }

    return trends;
  }

  Map<String, dynamic> _analyzeHealthTrends(Map<String, dynamic> healthData) {
    final trends = <String, dynamic>{};

    // Would analyze trends in biometric data, emotional data, etc.
    // For now, simplified implementation
    trends['overall_health'] = 'stable';

    return trends;
  }

  String _determineOverallTrend(
    Map<String, dynamic> cycleTrends,
    Map<String, dynamic> symptomTrends,
    Map<String, dynamic> healthTrends,
  ) {
    final trendValues = <String>[];

    // Collect trend directions
    [cycleTrends, symptomTrends, healthTrends].forEach((trendMap) {
      trendMap.values.where((v) => v is String && ['improving', 'declining', 'stable'].contains(v))
          .forEach((v) => trendValues.add(v));
    });

    if (trendValues.isEmpty) return 'insufficient_data';

    // Determine overall trend
    final improving = trendValues.where((t) => t == 'improving').length;
    final declining = trendValues.where((t) => t == 'declining').length;

    if (improving > declining * 1.5) return 'improving';
    if (declining > improving * 1.5) return 'declining';
    return 'stable';
  }

  String _calculateTrend(List<double> values) {
    if (values.length < 3) return 'insufficient_data';

    // Simple linear trend calculation
    final n = values.length;
    final x = List.generate(n, (i) => i.toDouble());
    final y = values;

    final sumX = x.reduce((a, b) => a + b);
    final sumY = y.reduce((a, b) => a + b);
    final sumXY = List.generate(n, (i) => x[i] * y[i]).reduce((a, b) => a + b);
    final sumX2 = x.map((xi) => xi * xi).reduce((a, b) => a + b);

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);

    if (slope > 0.1) return 'improving';
    if (slope < -0.1) return 'declining';
    return 'stable';
  }

  double _calculateStability(List<double> values) {
    if (values.isEmpty) return 0.0;
    
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((v) => math.pow(v - mean, 2)).reduce((a, b) => a + b) / values.length;
    
    return 1.0 / (1.0 + math.sqrt(variance)); // Higher value = more stable
  }

  double _calculateTrendConfidence(List<CycleData> cycles) {
    if (cycles.length < 3) return 0.2;
    if (cycles.length < 6) return 0.5;
    if (cycles.length < 12) return 0.7;
    return 0.9;
  }

  List<String> _generateTrendPredictions(
    Map<String, dynamic> cycleTrends,
    Map<String, dynamic> symptomTrends,
  ) {
    final predictions = <String>[];

    if (cycleTrends['length_trend'] == 'improving') {
      predictions.add('Cycle regularity is expected to continue improving');
    } else if (cycleTrends['length_trend'] == 'declining') {
      predictions.add('Cycle irregularity may increase - consider lifestyle factors');
    }

    return predictions;
  }

  List<String> _generateActionableInsights(String overallTrend, Map<String, dynamic> cycleTrends) {
    final insights = <String>[];

    if (overallTrend == 'improving') {
      insights.add('Your health trends are positive - continue current strategies');
    } else if (overallTrend == 'declining') {
      insights.add('Consider addressing lifestyle factors that may be impacting your health');
    }

    if (cycleTrends['length_stability'] != null && cycleTrends['length_stability'] < 0.5) {
      insights.add('Focus on stress management and consistent sleep schedule for cycle regularity');
    }

    return insights;
  }

  double _flowToNumeric(FlowIntensity flow) {
    switch (flow) {
      case FlowIntensity.none: return 0.0;
      case FlowIntensity.spotting: return 1.0;
      case FlowIntensity.light: return 2.0;
      case FlowIntensity.medium: return 3.0;
      case FlowIntensity.heavy: return 4.0;
      case FlowIntensity.veryHeavy: return 5.0;
    }
  }
}

// Data Models and Results

class ComprehensiveHealthReport {
  final String userId;
  final DateTime generatedAt;
  final int analysisDepth;
  final String currentPhase;
  final double overallHealthScore;
  final Map<String, double> healthScores;
  final FertilityAnalysisResult fertilityAnalysis;
  final ConditionScreeningResult conditionScreening;
  final List<SupplementRecommendation> supplementRecommendations;
  final RiskAssessmentResult riskAssessments;
  final PersonalizationInsights personalizedInsights;
  final TrendAnalysisResult trendAnalysis;
  final List<HealthRecommendation> recommendations;
  final List<String> keyFindings;
  final List<String> nextSteps;

  ComprehensiveHealthReport({
    required this.userId,
    required this.generatedAt,
    required this.analysisDepth,
    required this.currentPhase,
    required this.overallHealthScore,
    required this.healthScores,
    required this.fertilityAnalysis,
    required this.conditionScreening,
    required this.supplementRecommendations,
    required this.riskAssessments,
    required this.personalizedInsights,
    required this.trendAnalysis,
    required this.recommendations,
    required this.keyFindings,
    required this.nextSteps,
  });
}

class QuickHealthAssessment {
  final String userId;
  final DateTime assessmentTime;
  final String currentPhase;
  final double quickHealthScore;
  final List<Map<String, dynamic>> immediateRisks;
  final List<String> urgentRecommendations;
  final List<String> flaggedConcerns;
  final bool followUpNeeded;

  QuickHealthAssessment({
    required this.userId,
    required this.assessmentTime,
    required this.currentPhase,
    required this.quickHealthScore,
    required this.immediateRisks,
    required this.urgentRecommendations,
    required this.flaggedConcerns,
    required this.followUpNeeded,
  });
}

class FertilityAnalysisResult {
  final double fertilityScore;
  final double ovulationPrediction;
  final Map<String, DateTime> fertilityWindow;
  final Map<String, dynamic> factors;
  final List<String> recommendations;

  FertilityAnalysisResult({
    required this.fertilityScore,
    required this.ovulationPrediction,
    required this.fertilityWindow,
    required this.factors,
    required this.recommendations,
  });
}

class EnhancedFertilityWindow {
  final DateTime ovulationDate;
  final DateTime fertilityStart;
  final DateTime fertilityEnd;
  final double confidence;
  final Map<String, dynamic> factors;
  final List<String> recommendations;

  EnhancedFertilityWindow({
    required this.ovulationDate,
    required this.fertilityStart,
    required this.fertilityEnd,
    required this.confidence,
    required this.factors,
    required this.recommendations,
  });
}

class ConditionScreeningResult {
  final List<Map<String, dynamic>> detectedRisks;
  final DateTime screeningDate;
  final double confidenceLevel;
  final List<String> recommendations;

  ConditionScreeningResult({
    required this.detectedRisks,
    required this.screeningDate,
    required this.confidenceLevel,
    required this.recommendations,
  });
}

class SupplementRecommendation {
  final String name;
  final String dosage;
  final String timing;
  final SupplementPriority priority;
  final String category;
  final String rationale;
  final List<String> expectedBenefits;
  final List<String> contraindications;
  final String duration;

  SupplementRecommendation({
    required this.name,
    required this.dosage,
    required this.timing,
    required this.priority,
    required this.category,
    required this.rationale,
    required this.expectedBenefits,
    required this.contraindications,
    required this.duration,
  });
}

enum SupplementPriority { low, medium, high, critical }

class RiskAssessmentResult {
  final List<Map<String, dynamic>> identifiedRisks;
  final double overallRiskLevel;
  final Map<String, int> riskCategories;
  final List<String> recommendations;
  final Map<String, String> monitoringNeeded;

  RiskAssessmentResult({
    required this.identifiedRisks,
    required this.overallRiskLevel,
    required this.riskCategories,
    required this.recommendations,
    required this.monitoringNeeded,
  });
}

class PersonalizationInsights {
  final Map<String, dynamic> personalityProfile;
  final Map<String, String> preferences;
  final List<String> strengths;
  final List<String> opportunities;
  final List<String> personalizedTips;
  final String motivationalApproach;

  PersonalizationInsights({
    required this.personalityProfile,
    required this.preferences,
    required this.strengths,
    required this.opportunities,
    required this.personalizedTips,
    required this.motivationalApproach,
  });
}

class TrendAnalysisResult {
  final int analysisDepth;
  final Map<String, dynamic> cycleTrends;
  final Map<String, dynamic> symptomTrends;
  final Map<String, dynamic> healthTrends;
  final String overallTrend;
  final double trendConfidence;
  final List<String> predictions;
  final List<String> actionableInsights;

  TrendAnalysisResult({
    required this.analysisDepth,
    required this.cycleTrends,
    required this.symptomTrends,
    required this.healthTrends,
    required this.overallTrend,
    required this.trendConfidence,
    required this.predictions,
    required this.actionableInsights,
  });
}

class HealthRecommendation {
  final String category;
  final RecommendationPriority priority;
  final String action;
  final String reasoning;
  final String expectedOutcome;
  final String timeframe;

  HealthRecommendation({
    required this.category,
    required this.priority,
    required this.action,
    required this.reasoning,
    required this.expectedOutcome,
    required this.timeframe,
  });
}

enum RecommendationPriority { low, medium, high, critical }

class HealthInsight {
  final String type;
  final String title;
  final String description;
  final DateTime timestamp;
  final String priority;

  HealthInsight({
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.priority,
  });
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

// Add missing HealthReport class
class HealthReport extends ComprehensiveHealthReport {
  HealthReport({
    required super.userId,
    required super.generatedAt,
    required super.analysisDepth,
    required super.currentPhase,
    required super.overallHealthScore,
    required super.healthScores,
    required super.fertilityAnalysis,
    required super.conditionScreening,
    required super.supplementRecommendations,
    required super.riskAssessments,
    required super.personalizedInsights,
    required super.trendAnalysis,
    required super.recommendations,
    required super.keyFindings,
    required super.nextSteps,
  });
}
