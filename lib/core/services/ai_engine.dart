import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../models/cycle_data.dart';
import '../models/ai_insights.dart';
import 'flowai_service.dart';
import '../config/flowiq_config.dart';

class AIEngine {
  static final AIEngine _instance = AIEngine._internal();
  static AIEngine get instance => _instance;
  AIEngine._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  // FlowAI Integration
  final FlowAIService _flowAIService = FlowAIService();
  bool _useFlowAI = false;

  // Enhanced AI Models for Week 1 Implementation
  late Map<String, dynamic> _predictionModel;
  late Map<String, dynamic> _patternModel;
  late Map<String, dynamic> _insightModel;
  late Map<String, dynamic> _symptomModel;
  late Map<String, dynamic> _moodEnergyModel;

  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('🧠 Initializing Enhanced AI Engine (Week 1)...');
    
    // Enhanced prediction model with multiple factors
    _predictionModel = {
      'cycle_length_weights': [0.4, 0.3, 0.2, 0.1], // Recent cycles weighted more
      'symptom_influence': 0.15,
      'mood_energy_influence': 0.1,
      'seasonal_adjustment': 0.05,
      'default_length': 28.0,
      'confidence_threshold': 0.6,
    };
    
    // Advanced pattern recognition model
    _patternModel = {
      'cycle_phase_patterns': {},
      'symptom_timing_patterns': {},
      'flow_intensity_patterns': {},
      'anomaly_detection_threshold': 0.25,
      'cycle_patterns': _generateCyclePatterns(),
      'symptom_patterns': _generateSymptomPatterns(),
    };
    
    // Sophisticated insight generation model
    _insightModel = {
      'templates': {
        'regularity': 'Your cycles show {regularity} with {variance_desc} variation',
        'prediction_accuracy': 'Our predictions have been {accuracy}% accurate for you',
        'symptom_forecast': 'Based on patterns, expect {symptoms} in your next cycle',
        'mood_energy_trend': 'Your {metric} tends to be {trend} during {phase}',
      },
      'confidence_weights': {
        'data_points': 0.3,
        'consistency': 0.4,
        'recency': 0.3,
      },
      'insight_templates': _generateInsightTemplates(),
      'recommendation_engine': _generateRecommendationRules(),
    };
    
    // Symptom prediction and correlation model
    _symptomModel = {
      'common_symptoms': ['cramps', 'fatigue', 'bloating', 'headache', 'mood_swings', 'breast_tenderness'],
      'symptom_phases': {
        'menstrual': ['cramps', 'fatigue', 'heavy_flow'],
        'follicular': ['energy_boost', 'clear_skin'],
        'ovulatory': ['increased_libido', 'cervical_changes'],
        'luteal': ['bloating', 'mood_swings', 'breast_tenderness', 'food_cravings'],
      },
      'severity_factors': {
        'stress': 1.3,
        'sleep_quality': 0.8,
        'exercise': 0.7,
      },
    };
    
    // Mood and energy forecasting model
    _moodEnergyModel = {
      'cycle_phase_effects': {
        'menstrual': {'mood': -0.8, 'energy': -1.0},
        'follicular': {'mood': 0.5, 'energy': 0.7},
        'ovulatory': {'mood': 0.8, 'energy': 1.0},
        'luteal': {'mood': -0.3, 'energy': -0.5},
      },
      'individual_variation': 0.4,
      'baseline_calculation_cycles': 6,
    };
    
    // Initialize FlowAI if configured
        if (FlowIQConfig.isConfigured) {
      try {
        await _initializeFlowAI();
      } catch (e) {
        debugPrint('FlowAI initialization failed in AI Engine: $e');
      }
    }
    
    _isInitialized = true;
    debugPrint('✅ Enhanced AI Engine initialized with advanced algorithms');
  }

  /// Enhanced prediction with symptom timing and mood/energy forecasting
  Future<CyclePrediction> predictNextCycle(List<CycleData> historicalCycles) async {
    if (!_isInitialized) await initialize();
    
    if (historicalCycles.isEmpty) {
      return _generateDefaultPrediction();
    }

    // Enhanced prediction using multiple algorithms
    final lengthPrediction = _predictCycleLength(historicalCycles);
    final symptomPrediction = await _predictSymptoms(historicalCycles);
    final moodEnergyForecast = await _forecastMoodEnergy(historicalCycles);
    final fertilityPrediction = _calculateFertileWindow(lengthPrediction, historicalCycles);
    
    final lastCycle = historicalCycles.last;
    final predictedStart = _calculateNextStartDate(lastCycle, lengthPrediction.predictedLength);
    
    // Return enhanced prediction if we have enough data, otherwise basic prediction
    if (historicalCycles.length >= 2) {
      return EnhancedCyclePrediction(
        predictedStartDate: predictedStart,
        predictedLength: lengthPrediction.predictedLength,
        confidence: lengthPrediction.confidence,
        fertileWindow: fertilityPrediction,
        symptomForecast: symptomPrediction,
        moodEnergyForecast: moodEnergyForecast,
        predictionFactors: lengthPrediction.factors,
      );
    } else {
      return CyclePrediction(
        predictedStartDate: predictedStart,
        predictedLength: lengthPrediction.predictedLength,
        confidence: lengthPrediction.confidence,
        fertileWindow: fertilityPrediction,
      );
    }
  }

  /// Generate AI-powered insights from cycle data
  Future<List<AIInsight>> generateInsights(List<CycleData> cycles) async {
    if (!_isInitialized) await initialize();
    
    final insights = <AIInsight>[];
    
    // Cycle regularity insight
    if (cycles.length >= 3) {
      final regularity = _analyzeRegularity(cycles);
      insights.add(AIInsight(
        type: InsightType.cycleRegularity,
        title: regularity > 0.8 
            ? 'Your cycles are very regular! 🎯'
            : regularity > 0.6 
                ? 'Your cycles show good patterns 📊'
                : 'Your cycles show some variation 📈',
        description: _getRegularityDescription(regularity),
        confidence: regularity,
        actionable: regularity < 0.7,
        recommendations: regularity < 0.7 
            ? ['Track stress levels', 'Monitor sleep patterns', 'Consider lifestyle factors']
            : ['Keep up your healthy routine!'],
      ));
    }

    // Symptom pattern insight
    final symptomInsight = _analyzeSymptomPatterns(cycles);
    if (symptomInsight != null) {
      insights.add(symptomInsight);
    }

    // Health trend insight
    final healthInsight = _analyzeHealthTrends(cycles);
    if (healthInsight != null) {
      insights.add(healthInsight);
    }

    return insights;
  }

  /// Analyze cycle patterns and detect anomalies
  Future<List<PatternDetection>> detectPatterns(List<CycleData> cycles) async {
    if (!_isInitialized) await initialize();
    
    final patterns = <PatternDetection>[];
    
    if (cycles.length < 2) return patterns;

    // Detect length variations
    final lengths = cycles.map((c) => c.length).toList();
    final avgLength = lengths.reduce((a, b) => a + b) / lengths.length;
    final variance = _calculateVariance(lengths.map((l) => l.toDouble()).toList());
    
    if (variance > 4.0) {
      patterns.add(PatternDetection(
        type: PatternType.irregularity,
        description: 'Cycle length varies significantly',
        confidence: math.min(variance / 10.0, 1.0),
        impact: variance > 8.0 ? ImpactLevel.high : ImpactLevel.medium,
      ));
    }

    return patterns;
  }

  /// Private helper methods
  double _calculateAverageCycleLength(List<CycleData> cycles) {
    if (cycles.isEmpty) return 28.0;
    final lengths = cycles.map((c) => c.length).toList();
    return lengths.reduce((a, b) => a + b) / lengths.length;
  }

  double _calculatePredictionConfidence(List<CycleData> cycles) {
    if (cycles.length < 3) return 0.6;
    
    final lengths = cycles.map((c) => c.length.toDouble()).toList();
    final variance = _calculateVariance(lengths);
    
    // Higher variance = lower confidence
    return math.max(0.5, 1.0 - (variance / 10.0));
  }

  double _analyzeRegularity(List<CycleData> cycles) {
    final lengths = cycles.map((c) => c.length.toDouble()).toList();
    final variance = _calculateVariance(lengths);
    return math.max(0.0, 1.0 - (variance / 20.0));
  }

  double _calculateVariance(List<double> values) {
    if (values.isEmpty) return 0.0;
    
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDifferences = values.map((v) => math.pow(v - mean, 2));
    return squaredDifferences.reduce((a, b) => a + b) / values.length;
  }

  String _getRegularityDescription(double regularity) {
    if (regularity > 0.8) {
      return 'Your cycles are consistently regular, which is a great sign of reproductive health.';
    } else if (regularity > 0.6) {
      return 'Your cycles show good patterns with minor variations, which is quite normal.';
    } else {
      return 'Your cycles show some variation. Consider tracking factors like stress, sleep, and exercise.';
    }
  }

  AIInsight? _analyzeSymptomPatterns(List<CycleData> cycles) {
    // Simplified symptom analysis
    final allSymptoms = cycles.expand((c) => c.symptoms).toList();
    if (allSymptoms.isEmpty) return null;

    final symptomFrequency = <String, int>{};
    for (final symptom in allSymptoms) {
      symptomFrequency[symptom] = (symptomFrequency[symptom] ?? 0) + 1;
    }

    final mostCommon = symptomFrequency.entries
        .reduce((a, b) => a.value > b.value ? a : b);

    return AIInsight(
      type: InsightType.symptomPattern,
      title: 'Most common symptom: ${mostCommon.key}',
      description: 'You experience ${mostCommon.key} in ${((mostCommon.value / cycles.length) * 100).round()}% of your cycles.',
      confidence: 0.8,
      actionable: true,
      recommendations: ['Track timing of ${mostCommon.key}', 'Note severity levels'],
    );
  }

  AIInsight? _analyzeHealthTrends(List<CycleData> cycles) {
    // Simplified health trend analysis
    if (cycles.length < 4) return null;

    final recentCycles = cycles.skip(cycles.length - 3).toList();
    final olderCycles = cycles.take(cycles.length - 3).toList();

    final recentAvgLength = recentCycles.map((c) => c.length).reduce((a, b) => a + b) / recentCycles.length;
    final olderAvgLength = olderCycles.map((c) => c.length).reduce((a, b) => a + b) / olderCycles.length;

    if ((recentAvgLength - olderAvgLength).abs() > 2) {
      return AIInsight(
        type: InsightType.healthTrend,
        title: recentAvgLength > olderAvgLength ? 'Cycles getting longer' : 'Cycles getting shorter',
        description: 'Your recent cycles average ${recentAvgLength.toStringAsFixed(1)} days vs ${olderAvgLength.toStringAsFixed(1)} days previously.',
        confidence: 0.7,
        actionable: true,
        recommendations: ['Monitor for 2-3 more cycles', 'Consider consulting healthcare provider if trend continues'],
      );
    }

    return null;
  }

  Map<String, List<String>> _generateCyclePatterns() {
    return {
      'regular': ['21-35 days', 'consistent flow', 'predictable symptoms'],
      'irregular': ['variable length', 'unpredictable timing', 'varying symptoms'],
      'short': ['<21 days', 'frequent cycles', 'light flow patterns'],
      'long': ['>35 days', 'infrequent cycles', 'heavy flow patterns'],
    };
  }

  Map<String, List<String>> _generateSymptomPatterns() {
    return {
      'pms': ['mood changes', 'bloating', 'breast tenderness'],
      'dysmenorrhea': ['cramping', 'pain', 'fatigue'],
      'ovulation': ['mid-cycle pain', 'discharge changes', 'temperature rise'],
    };
  }

  Map<String, dynamic> _generateInsightTemplates() {
    return {
      'regular_cycles': {
        'title': 'Your cycles are beautifully regular!',
        'description': 'Consistency is a great sign of reproductive health.',
      },
      'irregular_cycles': {
        'title': 'Your cycles show some variation',
        'description': 'This is normal, but tracking can help identify patterns.',
      },
    };
  }

  Map<String, List<String>> _generateRecommendationRules() {
    return {
      'irregular_cycles': [
        'Track stress levels daily',
        'Monitor sleep patterns',
        'Note exercise intensity',
        'Consider consulting a healthcare provider',
      ],
      'heavy_bleeding': [
        'Track flow intensity',
        'Monitor for anemia symptoms',
        'Consult healthcare provider if concerned',
      ],
      'pms_symptoms': [
        'Try relaxation techniques',
        'Consider dietary changes',
        'Track symptom severity',
      ],
    };
  }

  // Enhanced prediction algorithms - Week 1 Implementation
  
  CycleLengthPrediction _predictCycleLength(List<CycleData> cycles) {
    final completedCycles = cycles.where((c) => c.isCompleted).toList();
    if (completedCycles.isEmpty) {
      return CycleLengthPrediction(28, 0.3, ['default']);
    }

    final weights = _predictionModel['cycle_length_weights'] as List<double>;
    final recentCycles = completedCycles.reversed.take(weights.length).toList();
    
    // Weighted average of recent cycles
    double weightedSum = 0.0;
    double totalWeight = 0.0;
    
    for (int i = 0; i < recentCycles.length; i++) {
      final weight = weights[math.min(i, weights.length - 1)];
      weightedSum += recentCycles[i].actualLength * weight;
      totalWeight += weight;
    }
    
    final baseLength = weightedSum / totalWeight;
    
    // Apply symptom influence
    final symptomAdjustment = _calculateSymptomInfluence(cycles.last);
    final adjustedLength = baseLength + symptomAdjustment;
    
    // Calculate confidence based on consistency
    final variance = _calculateVariance(completedCycles.map((c) => c.actualLength.toDouble()).toList());
    final dataQuality = math.min(1.0, completedCycles.length / 6.0);
    final consistency = math.max(0.0, 1.0 - (variance / 16.0));
    final confidence = (dataQuality * 0.6 + consistency * 0.4);
    
    final factors = <String>[
      'historical_average',
      if (symptomAdjustment != 0) 'symptom_patterns',
      if (completedCycles.length >= 6) 'long_term_trends',
    ];
    
    return CycleLengthPrediction(
      adjustedLength.round(),
      confidence,
      factors,
    );
  }

  Future<SymptomForecast> _predictSymptoms(List<CycleData> cycles) async {
    final symptomPatterns = _analyzeSymptomPatterns2(cycles);
    final predictedSymptoms = <String, double>{};
    
    // Predict likelihood of each symptom based on historical patterns
    for (final entry in symptomPatterns.entries) {
      final symptom = entry.key;
      final occurrences = entry.value;
      final likelihood = math.min(1.0, occurrences / cycles.length.toDouble());
      
      if (likelihood >= 0.3) { // Only include likely symptoms
        predictedSymptoms[symptom] = likelihood;
      }
    }
    
    // Add phase-specific symptoms
    final phaseSymptoms = _predictPhaseSpecificSymptoms(cycles);
    for (final entry in phaseSymptoms.entries) {
      predictedSymptoms[entry.key] = math.max(
        predictedSymptoms[entry.key] ?? 0.0,
        entry.value,
      );
    }
    
    return SymptomForecast(
      predictedSymptoms: predictedSymptoms,
      confidence: _calculateSymptomPredictionConfidence(cycles),
    );
  }

  Future<MoodEnergyForecast> _forecastMoodEnergy(List<CycleData> cycles) async {
    final moodData = cycles.where((c) => c.mood != null).map((c) => c.mood!).toList();
    final energyData = cycles.where((c) => c.energy != null).map((c) => c.energy!).toList();
    
    if (moodData.isEmpty && energyData.isEmpty) {
      return MoodEnergyForecast.empty();
    }
    
    // Calculate baseline averages
    final baselineMood = moodData.isNotEmpty ? moodData.reduce((a, b) => a + b) / moodData.length : 3.0;
    final baselineEnergy = energyData.isNotEmpty ? energyData.reduce((a, b) => a + b) / energyData.length : 3.0;
    
    // Predict based on cycle phases
    final phases = ['menstrual', 'follicular', 'ovulatory', 'luteal'];
    final moodForecast = <String, double>{};
    final energyForecast = <String, double>{};
    
    for (final phase in phases) {
      final phaseEffect = _moodEnergyModel['cycle_phase_effects'][phase] as Map<String, dynamic>;
      moodForecast[phase] = math.max(1.0, math.min(5.0, baselineMood + phaseEffect['mood']));
      energyForecast[phase] = math.max(1.0, math.min(5.0, baselineEnergy + phaseEffect['energy']));
    }
    
    return MoodEnergyForecast(
      moodByPhase: moodForecast,
      energyByPhase: energyForecast,
      confidence: math.min(1.0, (moodData.length + energyData.length) / 12.0),
    );
  }

  // Helper methods for enhanced predictions
  double _calculateSymptomInfluence(CycleData cycle) {
    const symptomEffects = {
      'stress': 2.0,
      'illness': 3.0,
      'travel': 1.0,
      'exercise_change': 0.5,
    };
    
    double influence = 0.0;
    for (final symptom in cycle.symptoms) {
      influence += symptomEffects[symptom] ?? 0.0;
    }
    
    return influence * 0.1; // Scale down the influence
  }

  Map<String, int> _analyzeSymptomPatterns2(List<CycleData> cycles) {
    final patterns = <String, int>{};
    
    for (final cycle in cycles) {
      for (final symptom in cycle.symptoms) {
        patterns[symptom] = (patterns[symptom] ?? 0) + 1;
      }
    }
    
    return patterns;
  }

  Map<String, double> _predictPhaseSpecificSymptoms(List<CycleData> cycles) {
    // This would analyze which phase the user is likely to be in
    // and predict phase-specific symptoms
    final phaseSymptoms = _symptomModel['symptom_phases']['luteal'] as List<String>;
    final predictions = <String, double>{};
    
    for (final symptom in phaseSymptoms) {
      predictions[symptom] = 0.6; // Base likelihood for phase symptoms
    }
    
    return predictions;
  }

  double _calculateSymptomPredictionConfidence(List<CycleData> cycles) {
    final cyclesWithSymptoms = cycles.where((c) => c.symptoms.isNotEmpty).length;
    return math.min(1.0, cyclesWithSymptoms / math.max(1, cycles.length).toDouble());
  }

  DateTime _calculateNextStartDate(CycleData lastCycle, int predictedLength) {
    if (lastCycle.isCompleted) {
      return lastCycle.endDate!.add(Duration(days: predictedLength - lastCycle.actualLength));
    } else {
      return lastCycle.startDate.add(Duration(days: predictedLength));
    }
  }

  CyclePrediction _generateDefaultPrediction() {
    final now = DateTime.now();
    return EnhancedCyclePrediction(
      predictedStartDate: now.add(const Duration(days: 28)),
      predictedLength: 28,
      confidence: 0.3,
      fertileWindow: FertileWindow(
        start: now.add(const Duration(days: 14)),
        end: now.add(const Duration(days: 18)),
        peak: now.add(const Duration(days: 16)),
      ),
      symptomForecast: SymptomForecast.empty(),
      moodEnergyForecast: MoodEnergyForecast.empty(),
      predictionFactors: ['default'],
    );
  }

  FertileWindow _calculateFertileWindow(CycleLengthPrediction prediction, List<CycleData> cycles) {
    final cycleLength = prediction.predictedLength;
    final ovulationDay = cycleLength - 14; // Standard luteal phase
    
    // Adjust based on historical data if available
    final adjustment = cycles.length >= 3 ? _calculateOvulationAdjustment(cycles) : 0;
    final adjustedOvulation = ovulationDay + adjustment;
    
    final today = DateTime.now();
    final ovulationDate = today.add(Duration(days: adjustedOvulation));
    
    return FertileWindow(
      start: ovulationDate.subtract(const Duration(days: 5)),
      end: ovulationDate.add(const Duration(days: 1)),
      peak: ovulationDate,
    );
  }

  int _calculateOvulationAdjustment(List<CycleData> cycles) {
    // This would use symptom patterns to adjust ovulation timing
    // For now, return 0 (no adjustment)
    return 0;
  }
  
  // FlowAI Integration Methods
  
  /// Initialize FlowAI service for enhanced insights
  Future<void> _initializeFlowAI() async {
        if (!FlowIQConfig.isConfigured) return;
    
    try {
          await _flowAIService.initialize(apiKey: FlowIQConfig.apiKey!);
      _useFlowAI = _flowAIService.isInitialized;
      debugPrint('🤖 AI Engine FlowAI integration ${_useFlowAI ? "enabled" : "failed"}');
    } catch (e) {
      debugPrint('AI Engine FlowAI initialization error: $e');
      _useFlowAI = false;
    }
  }
  
  /// Generate enhanced insights using FlowAI
  Future<List<AIInsight>> generateEnhancedInsights({
    required String userId,
    required List<CycleData> cycles,
    List<String>? detectedPatterns,
  }) async {
    if (!_useFlowAI || cycles.isEmpty) {
      // Fallback to local insights
      return generateInsights(cycles);
    }
    
    try {
      // Prepare cycle analysis data for FlowAI
      final cycleAnalysis = _prepareCycleAnalysisForFlowAI(cycles);
      
      final response = await _flowAIService.generateInsights(
        userId: userId,
        cycleAnalysis: cycleAnalysis,
        patterns: detectedPatterns,
      );
      
      // Parse FlowAI response into AIInsight objects
      final flowAIInsights = _parseFlowAIInsights(response.content);
      
      // Combine with local insights
      final localInsights = await generateInsights(cycles);
      final combinedInsights = <AIInsight>[];
      
      // Add FlowAI insights first (they're more sophisticated)
      combinedInsights.addAll(flowAIInsights);
      
      // Add local insights that don't overlap
      for (final localInsight in localInsights) {
        if (!_hasOverlapWithFlowAIInsights(localInsight, flowAIInsights)) {
          combinedInsights.add(localInsight);
        }
      }
      
      return combinedInsights;
    } catch (e) {
      debugPrint('FlowAI insights generation failed: $e');
      // Fallback to local insights on error
      return generateInsights(cycles);
    }
  }
  
  /// Prepare cycle data for FlowAI analysis
  Map<String, dynamic> _prepareCycleAnalysisForFlowAI(List<CycleData> cycles) {
    final analysis = <String, dynamic>{};
    
    if (cycles.isEmpty) return analysis;
    
    // Basic cycle statistics
    final lengths = cycles.map((c) => c.length).toList();
    analysis['cycle_count'] = cycles.length;
    analysis['average_length'] = lengths.reduce((a, b) => a + b) / lengths.length;
    analysis['length_variance'] = _calculateVariance(lengths.map((l) => l.toDouble()).toList());
    analysis['regularity_score'] = _analyzeRegularity(cycles);
    
    // Symptom analysis
    final allSymptoms = cycles.expand((c) => c.symptoms).toList();
    final symptomFrequency = <String, int>{};
    for (final symptom in allSymptoms) {
      symptomFrequency[symptom] = (symptomFrequency[symptom] ?? 0) + 1;
    }
    analysis['common_symptoms'] = symptomFrequency;
    
    // Mood and energy patterns
    final moodData = cycles.where((c) => c.mood != null).map((c) => c.mood!).toList();
    final energyData = cycles.where((c) => c.energy != null).map((c) => c.energy!).toList();
    
    if (moodData.isNotEmpty) {
      analysis['average_mood'] = moodData.reduce((a, b) => a + b) / moodData.length;
    }
    if (energyData.isNotEmpty) {
      analysis['average_energy'] = energyData.reduce((a, b) => a + b) / energyData.length;
    }
    
    // Recent trends
    if (cycles.length >= 6) {
      final recentCycles = cycles.take(3).toList();
      final olderCycles = cycles.skip(3).take(3).toList();
      
      final recentAvgLength = recentCycles.map((c) => c.length).reduce((a, b) => a + b) / recentCycles.length;
      final olderAvgLength = olderCycles.map((c) => c.length).reduce((a, b) => a + b) / olderCycles.length;
      
      analysis['length_trend'] = recentAvgLength - olderAvgLength;
    }
    
    return analysis;
  }
  
  /// Parse FlowAI response into AIInsight objects
  List<AIInsight> _parseFlowAIInsights(String response) {
    final insights = <AIInsight>[];
    
    try {
      // This is a simplified parser - in a real implementation,
      // FlowAI would return structured data
      final lines = response.split('\n').where((line) => line.trim().isNotEmpty).toList();
      
      for (int i = 0; i < lines.length; i += 2) {
        if (i + 1 < lines.length) {
          final title = lines[i].replaceAll(RegExp(r'^\d+\.\s*'), '').trim();
          final description = lines[i + 1].trim();
          
          if (title.isNotEmpty && description.isNotEmpty) {
            insights.add(AIInsight(
              type: InsightType.correlationInsight,
              title: title,
              description: description,
              confidence: 0.85, // FlowAI insights are generally high confidence
              actionable: description.contains('consider') || description.contains('try'),
              recommendations: _extractRecommendations(description),
            ));
          }
        }
      }
    } catch (e) {
      debugPrint('Error parsing FlowAI insights: $e');
    }
    
    return insights;
  }
  
  /// Extract recommendations from FlowAI insight text
  List<String> _extractRecommendations(String text) {
    final recommendations = <String>[];
    
    // Simple keyword-based extraction
    if (text.contains('track')) recommendations.add('Continue tracking your data');
    if (text.contains('exercise')) recommendations.add('Consider adjusting exercise routine');
    if (text.contains('stress')) recommendations.add('Focus on stress management');
    if (text.contains('sleep')) recommendations.add('Prioritize good sleep hygiene');
    if (text.contains('doctor') || text.contains('healthcare')) {
      recommendations.add('Consult with a healthcare provider');
    }
    
    return recommendations.isNotEmpty ? recommendations : ['Keep monitoring your patterns'];
  }
  
  /// Check if local insight overlaps with FlowAI insights
  bool _hasOverlapWithFlowAIInsights(AIInsight localInsight, List<AIInsight> flowAIInsights) {
    // Simple overlap detection based on keywords in titles
    final localKeywords = localInsight.title.toLowerCase().split(' ');
    
    for (final flowAIInsight in flowAIInsights) {
      final flowAIKeywords = flowAIInsight.title.toLowerCase().split(' ');
      
      // If there's significant keyword overlap, consider it a duplicate
      final overlap = localKeywords.where((word) => flowAIKeywords.contains(word)).length;
      if (overlap >= 2) return true;
    }
    
    return false;
  }
  
  /// Check if FlowAI is enabled
  bool get isFlowAIEnabled => _useFlowAI && _flowAIService.isInitialized;
  
  /// Get AI engine status
  String get engineStatus {
    if (!_isInitialized) return 'Not initialized';
    if (_useFlowAI && _flowAIService.isInitialized) return 'Enhanced with FlowAI';
    return 'Local processing only';
  }
}
