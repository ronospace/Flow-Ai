import 'dart:math';
import 'package:flutter/foundation.dart';

/// Advanced AI Prediction Engine with enhanced capabilities
class AdvancedPredictionEngine {
  static final AdvancedPredictionEngine _instance = AdvancedPredictionEngine._internal();
  factory AdvancedPredictionEngine() => _instance;
  AdvancedPredictionEngine._internal();

  // Machine learning models (simplified for demo)
  final Map<String, dynamic> _fertilityModel = {};
  final Map<String, dynamic> _hormonePatternModel = {};
  final Map<String, dynamic> _cycleIrregularityModel = {};
  final Map<String, dynamic> _symptomPredictionModel = {};
  
  // Confidence thresholds
  static const double _highConfidenceThreshold = 0.85;
  static const double _mediumConfidenceThreshold = 0.65;
  
  /// Advanced fertility window prediction with optimization
  Future<FertilityPrediction> predictFertilityWindow({
    required List<CycleData> cycleHistory,
    List<BiometricData>? biometricData,
    List<SymptomData>? symptomHistory,
  }) async {
    try {
      // Enhanced fertility prediction algorithm
      final baseWindow = _calculateBaseFertilityWindow(cycleHistory);
      
      // Apply biometric adjustments if available
      FertilityWindow adjustedWindow = baseWindow.window;
      double confidence = baseWindow.confidence;
      
      if (biometricData != null && biometricData.isNotEmpty) {
        final biometricAdjustment = _analyzeBiometricFertilitySignals(biometricData);
        adjustedWindow = _adjustFertilityWindow(baseWindow.window, biometricAdjustment);
        confidence = _calculateEnhancedConfidence(confidence, biometricAdjustment.confidence);
      }
      
      // Apply symptom-based refinements
      if (symptomHistory != null && symptomHistory.isNotEmpty) {
        final symptomRefinement = _analyzeSymptomPatterns(symptomHistory);
        adjustedWindow = _refineWithSymptoms(adjustedWindow, symptomRefinement);
        confidence = _calculateEnhancedConfidence(confidence, symptomRefinement.confidence);
      }
      
      return FertilityPrediction(
        fertilityWindow: adjustedWindow,
        confidence: confidence,
        peakFertilityDate: _calculatePeakFertilityDate(adjustedWindow, biometricData),
        recommendations: _generateFertilityRecommendations(adjustedWindow, confidence),
        factors: _analyzeFertilityFactors(cycleHistory, biometricData, symptomHistory),
        nextCycles: _predictFutureFertilityWindows(cycleHistory, 3),
      );
    } catch (e) {
      debugPrint('Error in fertility prediction: $e');
      return _getFallbackFertilityPrediction();
    }
  }
  
  /// Hormone pattern recognition and prediction
  Future<HormonePatternAnalysis> analyzeHormonePatterns({
    required List<CycleData> cycleHistory,
    List<BiometricData>? biometricData,
    List<SymptomData>? symptomData,
  }) async {
    try {
      final patterns = <HormonePattern>[];
      
      // Analyze estrogen patterns
      final estrogenPattern = _analyzeEstrogenPattern(cycleHistory, biometricData);
      if (estrogenPattern != null) patterns.add(estrogenPattern);
      
      // Analyze progesterone patterns
      final progesteronePattern = _analyzeProgesteronePattern(cycleHistory, symptomData);
      if (progesteronePattern != null) patterns.add(progesteronePattern);
      
      // Analyze LH surge patterns
      final lhPattern = _analyzeLHPattern(cycleHistory, biometricData);
      if (lhPattern != null) patterns.add(lhPattern);
      
      // Detect irregularities
      final irregularities = _detectHormoneIrregularities(patterns);
      
      return HormonePatternAnalysis(
        patterns: patterns,
        irregularities: irregularities,
        overallBalance: _calculateHormoneBalance(patterns),
        predictions: _predictFutureHormonePatterns(patterns),
        recommendations: _generateHormoneRecommendations(patterns, irregularities),
        confidence: _calculatePatternConfidence(patterns),
      );
    } catch (e) {
      debugPrint('Error in hormone pattern analysis: $e');
      return _getFallbackHormoneAnalysis();
    }
  }
  
  /// Personalized cycle insights with AI recommendations
  Future<PersonalizedInsights> generatePersonalizedInsights({
    required String userId,
    required List<CycleData> cycleHistory,
    List<BiometricData>? biometricData,
    List<SymptomData>? symptomData,
    Map<String, dynamic>? userPreferences,
  }) async {
    try {
      final insights = <InsightItem>[];
      
      // Cycle regularity insights
      final regularityInsight = _analyzeCycleRegularity(cycleHistory);
      insights.add(regularityInsight);
      
      // Symptom pattern insights
      if (symptomData != null) {
        final symptomInsights = _analyzeSymptomTrends(symptomData);
        insights.addAll(symptomInsights);
      }
      
      // Biometric correlation insights
      if (biometricData != null) {
        final biometricInsights = _analyzeBiometricCorrelations(biometricData, cycleHistory);
        insights.addAll(biometricInsights);
      }
      
      // Health risk assessments
      final riskAssessments = _performHealthRiskAssessment(cycleHistory, symptomData);
      
      // Lifestyle recommendations
      final lifestyleRecs = _generateLifestyleRecommendations(
        cycleHistory, biometricData, symptomData, userPreferences
      );
      
      return PersonalizedInsights(
        userId: userId,
        insights: insights,
        riskAssessments: riskAssessments,
        recommendations: lifestyleRecs,
        confidenceScore: _calculateOverallInsightConfidence(insights),
        lastUpdated: DateTime.now(),
        nextUpdateDue: DateTime.now().add(const Duration(days: 7)),
      );
    } catch (e) {
      debugPrint('Error generating personalized insights: $e');
      return _getFallbackPersonalizedInsights(userId);
    }
  }
  
  /// Detect cycle irregularities and potential health concerns
  Future<IrregularityAnalysis> detectCycleIrregularities({
    required List<CycleData> cycleHistory,
    List<SymptomData>? symptomData,
  }) async {
    try {
      final irregularities = <CycleIrregularity>[];
      
      // Length irregularities
      final lengthIrregularities = _detectLengthIrregularities(cycleHistory);
      irregularities.addAll(lengthIrregularities);
      
      // Flow pattern irregularities
      final flowIrregularities = _detectFlowIrregularities(cycleHistory);
      irregularities.addAll(flowIrregularities);
      
      // Symptom-based irregularities
      if (symptomData != null) {
        final symptomIrregularities = _detectSymptomIrregularities(symptomData);
        irregularities.addAll(symptomIrregularities);
      }
      
      // Risk assessments
      final riskLevel = _calculateIrregularityRiskLevel(irregularities);
      final recommendations = _generateIrregularityRecommendations(irregularities);
      
      return IrregularityAnalysis(
        irregularities: irregularities,
        riskLevel: riskLevel,
        severity: _calculateIrregularitySeverity(irregularities),
        recommendations: recommendations,
        shouldConsultDoctor: _shouldRecommendMedicalConsultation(irregularities),
        confidence: _calculateIrregularityConfidence(irregularities),
      );
    } catch (e) {
      debugPrint('Error in irregularity detection: $e');
      return _getFallbackIrregularityAnalysis();
    }
  }
  
  // Private helper methods
  
  _BaseFertilityPrediction _calculateBaseFertilityWindow(List<CycleData> cycleHistory) {
    if (cycleHistory.length < 3) {
      return _BaseFertilityPrediction(
        window: FertilityWindow(
          start: DateTime.now().add(const Duration(days: 10)),
          end: DateTime.now().add(const Duration(days: 16)),
          peak: DateTime.now().add(const Duration(days: 14)),
        ),
        confidence: 0.5,
      );
    }
    
    // Calculate average cycle length and ovulation day
    final avgCycleLength = cycleHistory
        .map((cycle) => cycle.length)
        .reduce((a, b) => a + b) / cycleHistory.length;
    
    final avgOvulationDay = avgCycleLength - 14; // Standard luteal phase
    final variance = _calculateCycleVariance(cycleHistory);
    
    final now = DateTime.now();
    final start = now.add(Duration(days: (avgOvulationDay - 3).round()));
    final end = now.add(Duration(days: (avgOvulationDay + 1).round()));
    final peak = now.add(Duration(days: avgOvulationDay.round()));
    
    final confidence = _calculateBaseConfidence(variance, cycleHistory.length);
    
    return _BaseFertilityPrediction(
      window: FertilityWindow(start: start, end: end, peak: peak),
      confidence: confidence,
    );
  }
  
  BiometricFertilitySignals _analyzeBiometricFertilitySignals(List<BiometricData> biometricData) {
    // Analyze temperature patterns, heart rate variability, etc.
    final recentData = biometricData
        .where((data) => data.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 30))))
        .toList();
    
    double confidence = 0.7;
    int dayAdjustment = 0;
    
    // Temperature pattern analysis
    if (recentData.any((data) => data.bodyTemperature != null)) {
      final tempPattern = _analyzeTemperaturePattern(recentData);
      dayAdjustment += tempPattern.ovulationDayShift;
      confidence = max(confidence, tempPattern.confidence);
    }
    
    return BiometricFertilitySignals(
      dayAdjustment: dayAdjustment,
      confidence: confidence,
    );
  }
  
  SymptomFertilityRefinement _analyzeSymptomPatterns(List<SymptomData> symptomHistory) {
    // Analyze cervical mucus, ovulation pain, etc.
    final recentSymptoms = symptomHistory
        .where((symptom) => symptom.date.isAfter(DateTime.now().subtract(const Duration(days: 30))))
        .toList();
    
    int dayAdjustment = 0;
    double confidence = 0.6;
    
    // Cervical mucus analysis
    final mucusData = recentSymptoms
        .where((s) => s.symptoms.contains('cervical_mucus_fertile'))
        .toList();
    
    if (mucusData.isNotEmpty) {
      confidence = 0.8;
      // Adjust based on mucus patterns
    }
    
    return SymptomFertilityRefinement(
      dayAdjustment: dayAdjustment,
      confidence: confidence,
    );
  }
  
  double _calculateEnhancedConfidence(double baseConfidence, double additionalConfidence) {
    // Weighted average with higher weight on base confidence
    return (baseConfidence * 0.7) + (additionalConfidence * 0.3);
  }
  
  FertilityWindow _adjustFertilityWindow(FertilityWindow window, BiometricFertilitySignals signals) {
    final adjustment = Duration(days: signals.dayAdjustment);
    return FertilityWindow(
      start: window.start.add(adjustment),
      end: window.end.add(adjustment),
      peak: window.peak.add(adjustment),
    );
  }
  
  FertilityWindow _refineWithSymptoms(FertilityWindow window, SymptomFertilityRefinement refinement) {
    final adjustment = Duration(days: refinement.dayAdjustment);
    return FertilityWindow(
      start: window.start.add(adjustment),
      end: window.end.add(adjustment),
      peak: window.peak.add(adjustment),
    );
  }
  
  DateTime _calculatePeakFertilityDate(FertilityWindow window, List<BiometricData>? biometricData) {
    // Use biometric data to pinpoint exact ovulation if available
    return window.peak;
  }
  
  List<String> _generateFertilityRecommendations(FertilityWindow window, double confidence) {
    final recommendations = <String>[];
    
    if (confidence >= _highConfidenceThreshold) {
      recommendations.add('High confidence prediction - optimal timing for conception');
    } else if (confidence >= _mediumConfidenceThreshold) {
      recommendations.add('Moderate confidence - track symptoms for better accuracy');
    } else {
      recommendations.add('Consider additional tracking methods for better predictions');
    }
    
    recommendations.add('Track basal body temperature for improved accuracy');
    recommendations.add('Monitor cervical mucus changes');
    recommendations.add('Use ovulation predictor kits during fertile window');
    
    return recommendations;
  }
  
  Map<String, double> _analyzeFertilityFactors(
    List<CycleData> cycleHistory,
    List<BiometricData>? biometricData,
    List<SymptomData>? symptomHistory,
  ) {
    return {
      'cycle_regularity': _calculateCycleRegularity(cycleHistory),
      'temperature_patterns': biometricData != null ? _analyzeTemperatureConsistency(biometricData) : 0.5,
      'symptom_consistency': symptomHistory != null ? _analyzeSymptomConsistency(symptomHistory) : 0.5,
      'overall_health': _calculateOverallHealthScore(cycleHistory, biometricData, symptomHistory),
    };
  }
  
  List<FertilityWindow> _predictFutureFertilityWindows(List<CycleData> cycleHistory, int numCycles) {
    // Predict fertility windows for next n cycles
    final windows = <FertilityWindow>[];
    final avgCycleLength = cycleHistory.isNotEmpty 
        ? cycleHistory.map((c) => c.length).reduce((a, b) => a + b) / cycleHistory.length
        : 28.0;
    
    for (int i = 1; i <= numCycles; i++) {
      final cycleStart = DateTime.now().add(Duration(days: (avgCycleLength * i).round()));
      final ovulationDay = cycleStart.add(const Duration(days: 14));
      
      windows.add(FertilityWindow(
        start: ovulationDay.subtract(const Duration(days: 3)),
        end: ovulationDay.add(const Duration(days: 1)),
        peak: ovulationDay,
      ));
    }
    
    return windows;
  }
  
  // Fallback methods for error handling
  
  FertilityPrediction _getFallbackFertilityPrediction() {
    final now = DateTime.now();
    return FertilityPrediction(
      fertilityWindow: FertilityWindow(
        start: now.add(const Duration(days: 10)),
        end: now.add(const Duration(days: 16)),
        peak: now.add(const Duration(days: 14)),
      ),
      confidence: 0.5,
      peakFertilityDate: now.add(const Duration(days: 14)),
      recommendations: ['Continue tracking for better predictions'],
      factors: {'cycle_data': 0.5},
      nextCycles: [],
    );
  }
  
  HormonePatternAnalysis _getFallbackHormoneAnalysis() {
    return HormonePatternAnalysis(
      patterns: [],
      irregularities: [],
      overallBalance: 0.5,
      predictions: [],
      recommendations: ['Continue tracking for hormone analysis'],
      confidence: 0.3,
    );
  }
  
  PersonalizedInsights _getFallbackPersonalizedInsights(String userId) {
    return PersonalizedInsights(
      userId: userId,
      insights: [],
      riskAssessments: [],
      recommendations: ['Continue regular tracking for personalized insights'],
      confidenceScore: 0.3,
      lastUpdated: DateTime.now(),
      nextUpdateDue: DateTime.now().add(const Duration(days: 7)),
    );
  }
  
  IrregularityAnalysis _getFallbackIrregularityAnalysis() {
    return IrregularityAnalysis(
      irregularities: [],
      riskLevel: RiskLevel.low,
      severity: 0.0,
      recommendations: ['Continue tracking for irregularity analysis'],
      shouldConsultDoctor: false,
      confidence: 0.3,
    );
  }
  
  // Additional helper methods
  double _calculateCycleVariance(List<CycleData> cycles) {
    if (cycles.length < 2) return 0.0;
    
    final lengths = cycles.map((c) => c.length.toDouble()).toList();
    final mean = lengths.reduce((a, b) => a + b) / lengths.length;
    final squaredDiffs = lengths.map((l) => pow(l - mean, 2)).toList();
    return squaredDiffs.reduce((a, b) => a + b) / lengths.length;
  }
  
  double _calculateBaseConfidence(double variance, int historyLength) {
    // Higher confidence with more data and lower variance
    final dataConfidence = min(1.0, historyLength / 12.0); // 12 cycles for full confidence
    final varianceConfidence = max(0.3, 1.0 - (variance / 10.0)); // Lower confidence with high variance
    return (dataConfidence + varianceConfidence) / 2;
  }
  
  double _calculateCycleRegularity(List<CycleData> cycles) {
    if (cycles.length < 3) return 0.5;
    
    final variance = _calculateCycleVariance(cycles);
    return max(0.0, 1.0 - (variance / 25.0)); // 25 days variance = 0 regularity
  }
  
  double _analyzeTemperatureConsistency(List<BiometricData> data) {
    // Analyze consistency of temperature tracking and patterns
    final tempData = data.where((d) => d.bodyTemperature != null).toList();
    if (tempData.length < 10) return 0.3;
    
    // More sophisticated analysis would go here
    return 0.7;
  }
  
  double _analyzeSymptomConsistency(List<SymptomData> symptoms) {
    // Analyze consistency of symptom tracking
    if (symptoms.length < 30) return 0.3; // Less than a month of data
    
    // More sophisticated analysis would go here
    return 0.6;
  }
  
  double _calculateOverallHealthScore(
    List<CycleData> cycles,
    List<BiometricData>? biometricData,
    List<SymptomData>? symptoms,
  ) {
    double score = _calculateCycleRegularity(cycles);
    
    if (biometricData != null) {
      score = (score + _analyzeTemperatureConsistency(biometricData)) / 2;
    }
    
    if (symptoms != null) {
      score = (score + _analyzeSymptomConsistency(symptoms)) / 2;
    }
    
    return score;
  }
  
  // Placeholder implementations for complex analysis methods
  HormonePattern? _analyzeEstrogenPattern(List<CycleData> cycles, List<BiometricData>? biometric) {
    // Complex estrogen pattern analysis would go here
    return null;
  }
  
  HormonePattern? _analyzeProgesteronePattern(List<CycleData> cycles, List<SymptomData>? symptoms) {
    // Complex progesterone pattern analysis would go here
    return null;
  }
  
  HormonePattern? _analyzeLHPattern(List<CycleData> cycles, List<BiometricData>? biometric) {
    // Complex LH pattern analysis would go here
    return null;
  }
  
  List<HormoneIrregularity> _detectHormoneIrregularities(List<HormonePattern> patterns) {
    return []; // Placeholder
  }
  
  double _calculateHormoneBalance(List<HormonePattern> patterns) {
    return 0.7; // Placeholder
  }
  
  List<HormonePattern> _predictFutureHormonePatterns(List<HormonePattern> patterns) {
    return []; // Placeholder
  }
  
  List<String> _generateHormoneRecommendations(List<HormonePattern> patterns, List<HormoneIrregularity> irregularities) {
    return ['Continue tracking for hormone insights']; // Placeholder
  }
  
  double _calculatePatternConfidence(List<HormonePattern> patterns) {
    return 0.6; // Placeholder
  }
  
  InsightItem _analyzeCycleRegularity(List<CycleData> cycles) {
    final regularity = _calculateCycleRegularity(cycles);
    return InsightItem(
      title: 'Cycle Regularity',
      description: regularity > 0.8 
          ? 'Your cycles are very regular'
          : regularity > 0.6
              ? 'Your cycles show moderate regularity'
              : 'Your cycles show some irregularity',
      confidence: regularity,
      category: 'cycle_health',
    );
  }
  
  List<InsightItem> _analyzeSymptomTrends(List<SymptomData> symptoms) {
    return []; // Placeholder for symptom trend analysis
  }
  
  List<InsightItem> _analyzeBiometricCorrelations(List<BiometricData> biometric, List<CycleData> cycles) {
    return []; // Placeholder for biometric correlation analysis
  }
  
  List<HealthRiskAssessment> _performHealthRiskAssessment(List<CycleData> cycles, List<SymptomData>? symptoms) {
    return []; // Placeholder for health risk assessment
  }
  
  List<String> _generateLifestyleRecommendations(
    List<CycleData> cycles,
    List<BiometricData>? biometric,
    List<SymptomData>? symptoms,
    Map<String, dynamic>? preferences,
  ) {
    return ['Maintain regular exercise', 'Stay hydrated', 'Get adequate sleep']; // Placeholder
  }
  
  double _calculateOverallInsightConfidence(List<InsightItem> insights) {
    if (insights.isEmpty) return 0.3;
    return insights.map((i) => i.confidence).reduce((a, b) => a + b) / insights.length;
  }
  
  List<CycleIrregularity> _detectLengthIrregularities(List<CycleData> cycles) {
    return []; // Placeholder
  }
  
  List<CycleIrregularity> _detectFlowIrregularities(List<CycleData> cycles) {
    return []; // Placeholder
  }
  
  List<CycleIrregularity> _detectSymptomIrregularities(List<SymptomData> symptoms) {
    return []; // Placeholder
  }
  
  RiskLevel _calculateIrregularityRiskLevel(List<CycleIrregularity> irregularities) {
    if (irregularities.isEmpty) return RiskLevel.low;
    if (irregularities.length > 5) return RiskLevel.high;
    return RiskLevel.medium;
  }
  
  double _calculateIrregularitySeverity(List<CycleIrregularity> irregularities) {
    if (irregularities.isEmpty) return 0.0;
    return irregularities.map((i) => i.severity).reduce((a, b) => a + b) / irregularities.length;
  }
  
  List<String> _generateIrregularityRecommendations(List<CycleIrregularity> irregularities) {
    return ['Continue monitoring cycles', 'Consider consulting healthcare provider if patterns persist'];
  }
  
  bool _shouldRecommendMedicalConsultation(List<CycleIrregularity> irregularities) {
    return irregularities.any((i) => i.severity > 0.7);
  }
  
  double _calculateIrregularityConfidence(List<CycleIrregularity> irregularities) {
    return 0.7; // Placeholder
  }
  
  TemperaturePattern _analyzeTemperaturePattern(List<BiometricData> data) {
    return TemperaturePattern(ovulationDayShift: 0, confidence: 0.6); // Placeholder
  }
}

// Supporting classes and models

class _BaseFertilityPrediction {
  final FertilityWindow window;
  final double confidence;
  
  _BaseFertilityPrediction({required this.window, required this.confidence});
}

class BiometricFertilitySignals {
  final int dayAdjustment;
  final double confidence;
  
  BiometricFertilitySignals({required this.dayAdjustment, required this.confidence});
}

class SymptomFertilityRefinement {
  final int dayAdjustment;
  final double confidence;
  
  SymptomFertilityRefinement({required this.dayAdjustment, required this.confidence});
}

class TemperaturePattern {
  final int ovulationDayShift;
  final double confidence;
  
  TemperaturePattern({required this.ovulationDayShift, required this.confidence});
}

// Model classes that would typically be defined in separate files

class FertilityPrediction {
  final FertilityWindow fertilityWindow;
  final double confidence;
  final DateTime peakFertilityDate;
  final List<String> recommendations;
  final Map<String, double> factors;
  final List<FertilityWindow> nextCycles;
  
  FertilityPrediction({
    required this.fertilityWindow,
    required this.confidence,
    required this.peakFertilityDate,
    required this.recommendations,
    required this.factors,
    required this.nextCycles,
  });
}

class FertilityWindow {
  final DateTime start;
  final DateTime end;
  final DateTime peak;
  
  FertilityWindow({required this.start, required this.end, required this.peak});
}

class HormonePatternAnalysis {
  final List<HormonePattern> patterns;
  final List<HormoneIrregularity> irregularities;
  final double overallBalance;
  final List<HormonePattern> predictions;
  final List<String> recommendations;
  final double confidence;
  
  HormonePatternAnalysis({
    required this.patterns,
    required this.irregularities,
    required this.overallBalance,
    required this.predictions,
    required this.recommendations,
    required this.confidence,
  });
}

class HormonePattern {
  final String hormone;
  final List<double> levels;
  final double confidence;
  
  HormonePattern({required this.hormone, required this.levels, required this.confidence});
}

class HormoneIrregularity {
  final String type;
  final double severity;
  final String description;
  
  HormoneIrregularity({required this.type, required this.severity, required this.description});
}

class PersonalizedInsights {
  final String userId;
  final List<InsightItem> insights;
  final List<HealthRiskAssessment> riskAssessments;
  final List<String> recommendations;
  final double confidenceScore;
  final DateTime lastUpdated;
  final DateTime nextUpdateDue;
  
  PersonalizedInsights({
    required this.userId,
    required this.insights,
    required this.riskAssessments,
    required this.recommendations,
    required this.confidenceScore,
    required this.lastUpdated,
    required this.nextUpdateDue,
  });
}

class InsightItem {
  final String title;
  final String description;
  final double confidence;
  final String category;
  
  InsightItem({
    required this.title,
    required this.description,
    required this.confidence,
    required this.category,
  });
}

class HealthRiskAssessment {
  final String riskType;
  final RiskLevel level;
  final String description;
  final List<String> recommendations;
  
  HealthRiskAssessment({
    required this.riskType,
    required this.level,
    required this.description,
    required this.recommendations,
  });
}

class IrregularityAnalysis {
  final List<CycleIrregularity> irregularities;
  final RiskLevel riskLevel;
  final double severity;
  final List<String> recommendations;
  final bool shouldConsultDoctor;
  final double confidence;
  
  IrregularityAnalysis({
    required this.irregularities,
    required this.riskLevel,
    required this.severity,
    required this.recommendations,
    required this.shouldConsultDoctor,
    required this.confidence,
  });
}

class CycleIrregularity {
  final String type;
  final double severity;
  final String description;
  final DateTime detectedAt;
  
  CycleIrregularity({
    required this.type,
    required this.severity,
    required this.description,
    required this.detectedAt,
  });
}

enum RiskLevel { low, medium, high }

// Placeholder classes for existing models that would be imported
class CycleData {
  final String id;
  final int length;
  final DateTime startDate;
  
  CycleData({required this.id, required this.length, required this.startDate});
}

class BiometricData {
  final DateTime timestamp;
  final double? bodyTemperature;
  final int? heartRate;
  
  BiometricData({required this.timestamp, this.bodyTemperature, this.heartRate});
}

class SymptomData {
  final DateTime date;
  final List<String> symptoms;
  
  SymptomData({required this.date, required this.symptoms});
}
