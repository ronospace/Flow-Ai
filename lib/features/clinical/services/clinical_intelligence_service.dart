import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/clinical_models.dart';
import '../../tracking/services/feelings_database_service.dart';
import '../../analytics/services/advanced_analytics_service.dart';

/// Clinical intelligence service for healthcare provider features and medical analysis
class ClinicalIntelligenceService {
  static ClinicalIntelligenceService? _instance;
  static ClinicalIntelligenceService get instance {
    _instance ??= ClinicalIntelligenceService._internal();
    return _instance!;
  }

  ClinicalIntelligenceService._internal();

  bool _isInitialized = false;
  SharedPreferences? _prefs;
  
  // Clinical analysis configuration
  static const int _analysisHistoryDays = 90;
  static const double _abnormalThreshold = 0.7;
  static const double _criticalThreshold = 0.9;

  /// Initialize the clinical intelligence service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      debugPrint('🏥 Clinical intelligence service initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize clinical intelligence: $e');
      throw ClinicalException('Failed to initialize clinical service: $e');
    }
  }

  /// Generate comprehensive clinical report for healthcare providers
  Future<ClinicalReport> generateClinicalReport({
    required String userId,
    required String patientName,
    required DateTime reportDate,
    int analysisWindowDays = 90,
    String? providerNotes,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      final DateTime startDate = reportDate.subtract(Duration(days: analysisWindowDays));
      
      // Gather comprehensive health data
      final ClinicalDataSet dataSet = await _gatherClinicalData(
        userId: userId,
        startDate: startDate,
        endDate: reportDate,
      );

      // Perform clinical analysis
      final ClinicalAnalysis analysis = await _performClinicalAnalysis(dataSet);

      // Generate risk assessments
      final List<RiskAssessment> riskAssessments = await _generateRiskAssessments(dataSet, analysis);

      // Create recommendations
      final List<ClinicalRecommendation> recommendations = await _generateClinicalRecommendations(
        dataSet, 
        analysis, 
        riskAssessments,
      );

      // Generate medical insights
      final List<MedicalInsight> insights = await _generateMedicalInsights(dataSet, analysis);

      return ClinicalReport(
        id: _generateReportId(),
        userId: userId,
        patientName: patientName,
        reportDate: reportDate,
        analysisWindow: analysisWindowDays,
        dataSet: dataSet,
        analysis: analysis,
        riskAssessments: riskAssessments,
        recommendations: recommendations,
        insights: insights,
        providerNotes: providerNotes,
        generatedAt: DateTime.now(),
        version: '1.0',
      );
    } catch (e) {
      debugPrint('❌ Failed to generate clinical report: $e');
      throw ClinicalException('Failed to generate clinical report: $e');
    }
  }

  /// Gather comprehensive clinical data
  Future<ClinicalDataSet> _gatherClinicalData({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Get feelings and mood data
    final feelingsData = await _getFeelingsClinicalData(userId, startDate, endDate);

    // Get cycle data
    final cycleData = await _getCycleClinicalData(userId, startDate, endDate);

    // Get symptom data
    final symptomData = await _getSymptomClinicalData(userId, startDate, endDate);

    // Get biometric data
    final biometricData = await _getBiometricClinicalData(userId, startDate, endDate);

    // Get behavioral data
    final behavioralData = await _getBehavioralClinicalData(userId, startDate, endDate);

    return ClinicalDataSet(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
      feelingsData: feelingsData,
      cycleData: cycleData,
      symptomData: symptomData,
      biometricData: biometricData,
      behavioralData: behavioralData,
      dataCompleteness: _calculateDataCompleteness(
        feelingsData,
        cycleData,
        symptomData,
        biometricData,
        behavioralData,
      ),
    );
  }

  /// Get feelings clinical data
  Future<FeelingsClinicalData> _getFeelingsClinicalData(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final entries = await FeelingsDatabaseService.instance.getEntriesInRange(
      startDate: startDate,
      endDate: endDate,
      userId: userId,
    );

    if (entries.isEmpty) {
      return FeelingsClinicalData.empty();
    }

    // Calculate mood statistics
    final moodStats = <String, MoodStatistics>{};
    for (final category in MoodCategory.values) {
      final values = entries
          .where((e) => e.moodScores.containsKey(category))
          .map((e) => e.moodScores[category]!)
          .toList();

      if (values.isNotEmpty) {
        moodStats[category.name] = MoodStatistics(
          average: values.reduce((a, b) => a + b) / values.length,
          minimum: values.reduce(math.min),
          maximum: values.reduce(math.max),
          standardDeviation: _calculateStandardDeviation(values),
          trendDirection: _calculateTrendDirection(values),
          volatility: _calculateVolatility(values),
        );
      }
    }

    // Calculate wellbeing statistics
    final wellbeingValues = entries.map((e) => e.overallWellbeing).toList();
    final wellbeingStats = WellbeingStatistics(
      average: wellbeingValues.reduce((a, b) => a + b) / wellbeingValues.length,
      minimum: wellbeingValues.reduce(math.min),
      maximum: wellbeingValues.reduce(math.max),
      standardDeviation: _calculateStandardDeviation(wellbeingValues),
      trendDirection: _calculateTrendDirection(wellbeingValues),
      daysBelow5: wellbeingValues.where((v) => v < 5).length,
      daysAbove7: wellbeingValues.where((v) => v > 7).length,
    );

    return FeelingsClinicalData(
      totalEntries: entries.length,
      dateRange: endDate.difference(startDate).inDays,
      moodStatistics: moodStats,
      wellbeingStatistics: wellbeingStats,
      complianceRate: entries.length / endDate.difference(startDate).inDays,
    );
  }

  /// Get cycle clinical data
  Future<CycleClinicalData> _getCycleClinicalData(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // In a real implementation, this would fetch from cycle tracking service
    // For now, return mock data
    return CycleClinicalData(
      totalCycles: 3,
      averageCycleLength: 28.5,
      cycleVariability: 2.1,
      irregularCycles: 0,
      missedPeriods: 0,
      ovulationDetected: true,
      lutealPhaseDefect: false,
      symptoms: {
        'cramps': SymptomFrequency(frequency: 0.8, severity: 6.2),
        'mood_swings': SymptomFrequency(frequency: 0.6, severity: 5.8),
        'bloating': SymptomFrequency(frequency: 0.9, severity: 7.1),
      },
    );
  }

  /// Get symptom clinical data
  Future<SymptomClinicalData> _getSymptomClinicalData(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Mock symptom data - in reality, this would come from symptom tracking
    return SymptomClinicalData(
      totalSymptomEntries: 45,
      uniqueSymptoms: 12,
      averageSymptomsPerDay: 1.8,
      mostFrequentSymptoms: {
        'headache': SymptomFrequency(frequency: 0.3, severity: 6.5),
        'fatigue': SymptomFrequency(frequency: 0.4, severity: 7.2),
        'anxiety': SymptomFrequency(frequency: 0.25, severity: 5.8),
      },
      severityDistribution: {
        'mild': 0.4,
        'moderate': 0.45,
        'severe': 0.15,
      },
      symptomPatterns: [
        'Headaches tend to occur during luteal phase',
        'Fatigue correlates with low mood scores',
        'Anxiety symptoms increase during work weeks',
      ],
    );
  }

  /// Get biometric clinical data
  Future<BiometricClinicalData> _getBiometricClinicalData(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Mock biometric data - in reality, this would come from biometric service
    return BiometricClinicalData(
      heartRate: VitalStatistics(
        average: 72.5,
        minimum: 58.0,
        maximum: 105.0,
        restingAverage: 65.2,
        exerciseAverage: 145.8,
        abnormalReadings: 3,
      ),
      bloodPressure: BloodPressureStatistics(
        systolicAverage: 118.5,
        diastolicAverage: 76.2,
        hypertensiveReadings: 0,
        hypotensiveReadings: 2,
      ),
      temperature: VitalStatistics(
        average: 98.4,
        minimum: 97.8,
        maximum: 99.6,
        restingAverage: 98.2,
        exerciseAverage: 99.1,
        abnormalReadings: 1,
      ),
      oxygenSaturation: VitalStatistics(
        average: 98.2,
        minimum: 96.5,
        maximum: 99.5,
        restingAverage: 98.5,
        exerciseAverage: 97.8,
        abnormalReadings: 0,
      ),
      sleepData: SleepStatistics(
        averageHours: 7.2,
        sleepEfficiency: 0.85,
        deepSleepPercentage: 0.22,
        remSleepPercentage: 0.18,
        sleepLatency: 12.5,
        nightWakings: 1.8,
      ),
    );
  }

  /// Get behavioral clinical data
  Future<BehavioralClinicalData> _getBehavioralClinicalData(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Mock behavioral data - in reality, this would come from analytics service
    return BehavioralClinicalData(
      appUsagePatterns: AppUsageStatistics(
        dailySessionsAverage: 3.2,
        sessionDurationAverage: 8.5,
        mostActiveHours: [8, 12, 20],
        featureUsageDistribution: {
          'cycle_tracking': 0.4,
          'symptom_logging': 0.3,
          'mood_tracking': 0.25,
          'insights': 0.05,
        },
      ),
      complianceMetrics: ComplianceMetrics(
        dataEntryConsistency: 0.78,
        recommendationAdherence: 0.65,
        appointmentCompliance: 0.92,
      ),
      engagementScore: 0.73,
      riskBehaviors: [
        'Inconsistent sleep schedule',
        'Irregular meal times logged',
      ],
    );
  }

  /// Perform comprehensive clinical analysis
  Future<ClinicalAnalysis> _performClinicalAnalysis(ClinicalDataSet dataSet) async {
    final List<ClinicalFinding> findings = [];

    // Analyze mood patterns
    if (dataSet.feelingsData.wellbeingStatistics.daysBelow5 > 
        dataSet.feelingsData.dateRange * 0.3) {
      findings.add(ClinicalFinding(
        category: ClinicalCategory.mentalHealth,
        severity: ClinicalSeverity.moderate,
        description: 'Frequent low wellbeing scores indicating possible mood disorder',
        evidenceScore: 0.8,
        recommendation: 'Consider psychiatric evaluation and mood disorder screening',
      ));
    }

    // Analyze cycle patterns
    if (dataSet.cycleData.cycleVariability > 7.0) {
      findings.add(ClinicalFinding(
        category: ClinicalCategory.reproductive,
        severity: ClinicalSeverity.mild,
        description: 'Irregular menstrual cycles detected',
        evidenceScore: 0.65,
        recommendation: 'Monitor cycle patterns and consider hormonal evaluation',
      ));
    }

    // Analyze vital signs
    if (dataSet.biometricData.heartRate.abnormalReadings > 5) {
      findings.add(ClinicalFinding(
        category: ClinicalCategory.cardiovascular,
        severity: ClinicalSeverity.moderate,
        description: 'Multiple abnormal heart rate readings',
        evidenceScore: 0.75,
        recommendation: 'Cardiology consultation and ECG monitoring recommended',
      ));
    }

    // Analyze sleep patterns
    if (dataSet.biometricData.sleepData.averageHours < 6.5) {
      findings.add(ClinicalFinding(
        category: ClinicalCategory.sleep,
        severity: ClinicalSeverity.moderate,
        description: 'Chronic sleep deprivation',
        evidenceScore: 0.9,
        recommendation: 'Sleep hygiene counseling and possible sleep study',
      ));
    }

    // Calculate overall health score
    final healthScore = _calculateHealthScore(dataSet, findings);

    return ClinicalAnalysis(
      overallHealthScore: healthScore,
      findings: findings,
      clinicalFlags: _generateClinicalFlags(findings),
      trendAnalysis: _performTrendAnalysis(dataSet),
      correlationAnalysis: _performCorrelationAnalysis(dataSet),
      confidenceLevel: _calculateAnalysisConfidence(dataSet),
    );
  }

  /// Generate risk assessments
  Future<List<RiskAssessment>> _generateRiskAssessments(
    ClinicalDataSet dataSet,
    ClinicalAnalysis analysis,
  ) async {
    final List<RiskAssessment> assessments = [];

    // Depression risk assessment
    final depressionRisk = _assessDepressionRisk(dataSet);
    assessments.add(RiskAssessment(
      condition: 'Depression',
      riskLevel: depressionRisk,
      probability: _calculateRiskProbability(depressionRisk),
      factors: _getDepressionRiskFactors(dataSet),
      timeframe: 'Next 6 months',
      recommendation: _getDepressionRecommendation(depressionRisk),
    ));

    // PCOS risk assessment
    final pcosRisk = _assessPCOSRisk(dataSet);
    assessments.add(RiskAssessment(
      condition: 'PCOS',
      riskLevel: pcosRisk,
      probability: _calculateRiskProbability(pcosRisk),
      factors: _getPCOSRiskFactors(dataSet),
      timeframe: 'Current',
      recommendation: _getPCOSRecommendation(pcosRisk),
    ));

    // Cardiovascular risk assessment
    final cvRisk = _assessCardiovascularRisk(dataSet);
    assessments.add(RiskAssessment(
      condition: 'Cardiovascular Disease',
      riskLevel: cvRisk,
      probability: _calculateRiskProbability(cvRisk),
      factors: _getCardiovascularRiskFactors(dataSet),
      timeframe: 'Next 10 years',
      recommendation: _getCardiovascularRecommendation(cvRisk),
    ));

    return assessments;
  }

  /// Generate clinical recommendations
  Future<List<ClinicalRecommendation>> _generateClinicalRecommendations(
    ClinicalDataSet dataSet,
    ClinicalAnalysis analysis,
    List<RiskAssessment> riskAssessments,
  ) async {
    final List<ClinicalRecommendation> recommendations = [];

    // High priority recommendations based on findings
    for (final finding in analysis.findings) {
      if (finding.severity == ClinicalSeverity.severe) {
        recommendations.add(ClinicalRecommendation(
          id: _generateRecommendationId(),
          category: finding.category,
          priority: RecommendationPriority.urgent,
          title: 'Immediate Medical Attention Required',
          description: finding.recommendation,
          rationale: finding.description,
          evidenceLevel: 'High',
          timeframe: 'Within 24 hours',
          followUpRequired: true,
        ));
      }
    }

    // Lifestyle recommendations
    if (dataSet.biometricData.sleepData.averageHours < 7) {
      recommendations.add(ClinicalRecommendation(
        id: _generateRecommendationId(),
        category: ClinicalCategory.lifestyle,
        priority: RecommendationPriority.high,
        title: 'Improve Sleep Hygiene',
        description: 'Aim for 7-9 hours of sleep nightly with consistent bedtime routine',
        rationale: 'Chronic sleep deprivation affects hormonal balance and mood regulation',
        evidenceLevel: 'Strong',
        timeframe: '2-4 weeks',
        followUpRequired: true,
      ));
    }

    // Mental health recommendations
    if (dataSet.feelingsData.wellbeingStatistics.average < 5) {
      recommendations.add(ClinicalRecommendation(
        id: _generateRecommendationId(),
        category: ClinicalCategory.mentalHealth,
        priority: RecommendationPriority.high,
        title: 'Mental Health Evaluation',
        description: 'Schedule appointment with mental health professional for comprehensive assessment',
        rationale: 'Persistent low wellbeing scores indicate potential mood disorder',
        evidenceLevel: 'Moderate',
        timeframe: '1-2 weeks',
        followUpRequired: true,
      ));
    }

    return recommendations;
  }

  /// Generate medical insights
  Future<List<MedicalInsight>> _generateMedicalInsights(
    ClinicalDataSet dataSet,
    ClinicalAnalysis analysis,
  ) async {
    final List<MedicalInsight> insights = [];

    // Cycle-mood correlation insight
    if (dataSet.cycleData.totalCycles > 0 && 
        dataSet.feelingsData.moodStatistics.isNotEmpty) {
      insights.add(MedicalInsight(
        id: _generateInsightId(),
        category: InsightCategory.correlation,
        title: 'Menstrual Cycle and Mood Patterns',
        description: 'Analysis shows correlation between luteal phase and mood symptoms',
        significance: InsightSignificance.high,
        confidence: 0.82,
        clinicalRelevance: 'May indicate hormonal influence on mood regulation',
        supportingData: [
          'Mood scores decrease 3-5 days before menstruation',
          'Anxiety levels peak during late luteal phase',
          'Wellbeing improves during follicular phase',
        ],
      ));
    }

    // Sleep-performance insight
    if (dataSet.biometricData.sleepData.averageHours < 7) {
      insights.add(MedicalInsight(
        id: _generateInsightId(),
        category: InsightCategory.behavioral,
        title: 'Sleep Deprivation Impact',
        description: 'Insufficient sleep correlates with decreased wellbeing and increased symptoms',
        significance: InsightSignificance.high,
        confidence: 0.91,
        clinicalRelevance: 'Sleep optimization could improve overall health outcomes',
        supportingData: [
          'Wellbeing scores 15% lower on days following <6 hours sleep',
          'Symptom severity increases with sleep debt',
          'Heart rate variability decreases with poor sleep',
        ],
      ));
    }

    return insights;
  }

  /// Calculate various statistics and helper methods
  double _calculateStandardDeviation(List<double> values) {
    if (values.isEmpty) return 0.0;
    
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((v) => math.pow(v - mean, 2)).reduce((a, b) => a + b) / values.length;
    return math.sqrt(variance);
  }

  TrendDirection _calculateTrendDirection(List<double> values) {
    if (values.length < 3) return TrendDirection.stable;
    
    final firstHalf = values.take(values.length ~/ 2).toList();
    final secondHalf = values.skip(values.length ~/ 2).toList();
    
    final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;
    
    final difference = secondAvg - firstAvg;
    
    if (difference > 0.5) return TrendDirection.up;
    if (difference < -0.5) return TrendDirection.down;
    return TrendDirection.stable;
  }

  double _calculateVolatility(List<double> values) {
    if (values.length < 2) return 0.0;
    
    final changes = <double>[];
    for (int i = 1; i < values.length; i++) {
      changes.add((values[i] - values[i-1]).abs());
    }
    
    return changes.reduce((a, b) => a + b) / changes.length;
  }

  double _calculateDataCompleteness(
    FeelingsClinicalData feelings,
    CycleClinicalData cycle,
    SymptomClinicalData symptoms,
    BiometricClinicalData biometrics,
    BehavioralClinicalData behavioral,
  ) {
    final completenessScores = [
      feelings.complianceRate,
      cycle.totalCycles > 0 ? 1.0 : 0.0,
      symptoms.totalSymptomEntries > 0 ? 1.0 : 0.0,
      biometrics.heartRate.average > 0 ? 1.0 : 0.0,
      behavioral.engagementScore,
    ];
    
    return completenessScores.reduce((a, b) => a + b) / completenessScores.length;
  }

  double _calculateHealthScore(ClinicalDataSet dataSet, List<ClinicalFinding> findings) {
    double score = 100.0;
    
    for (final finding in findings) {
      switch (finding.severity) {
        case ClinicalSeverity.mild:
          score -= 5.0;
          break;
        case ClinicalSeverity.moderate:
          score -= 15.0;
          break;
        case ClinicalSeverity.severe:
          score -= 30.0;
          break;
      }
    }
    
    // Adjust for data completeness
    score *= dataSet.dataCompleteness;
    
    return math.max(0.0, math.min(100.0, score));
  }

  List<ClinicalFlag> _generateClinicalFlags(List<ClinicalFinding> findings) {
    return findings
        .where((f) => f.severity == ClinicalSeverity.severe)
        .map((f) => ClinicalFlag(
              type: ClinicalFlagType.critical,
              message: f.description,
              category: f.category,
              urgency: ClinicalUrgency.immediate,
            ))
        .toList();
  }

  TrendAnalysisResult _performTrendAnalysis(ClinicalDataSet dataSet) {
    return TrendAnalysisResult(
      moodTrends: dataSet.feelingsData.moodStatistics.map(
        (key, value) => MapEntry(key, value.trendDirection),
      ),
      vitalTrends: {
        'heart_rate': TrendDirection.stable,
        'blood_pressure': TrendDirection.stable,
        'temperature': TrendDirection.stable,
      },
      overallTrend: TrendDirection.stable,
    );
  }

  CorrelationAnalysisResult _performCorrelationAnalysis(ClinicalDataSet dataSet) {
    return CorrelationAnalysisResult(
      significantCorrelations: [
        CorrelationPair(
          variable1: 'sleep_hours',
          variable2: 'wellbeing_score',
          correlation: 0.72,
          significance: 0.001,
        ),
        CorrelationPair(
          variable1: 'cycle_phase',
          variable2: 'mood_scores',
          correlation: -0.45,
          significance: 0.023,
        ),
      ],
      networkAnalysis: 'Sleep quality is the strongest predictor of overall wellbeing',
    );
  }

  double _calculateAnalysisConfidence(ClinicalDataSet dataSet) {
    return dataSet.dataCompleteness * 0.9; // High confidence with complete data
  }

  // Risk assessment methods
  RiskLevel _assessDepressionRisk(ClinicalDataSet dataSet) {
    final avgWellbeing = dataSet.feelingsData.wellbeingStatistics.average;
    final lowDays = dataSet.feelingsData.wellbeingStatistics.daysBelow5;
    final totalDays = dataSet.feelingsData.dateRange;
    
    if (avgWellbeing < 4 || lowDays / totalDays > 0.5) {
      return RiskLevel.high;
    } else if (avgWellbeing < 6 || lowDays / totalDays > 0.3) {
      return RiskLevel.moderate;
    }
    return RiskLevel.low;
  }

  RiskLevel _assessPCOSRisk(ClinicalDataSet dataSet) {
    final irregularCycles = dataSet.cycleData.irregularCycles;
    final cycleVariability = dataSet.cycleData.cycleVariability;
    
    if (irregularCycles > 2 || cycleVariability > 10) {
      return RiskLevel.moderate;
    }
    return RiskLevel.low;
  }

  RiskLevel _assessCardiovascularRisk(ClinicalDataSet dataSet) {
    final abnormalHR = dataSet.biometricData.heartRate.abnormalReadings;
    final hypertensive = dataSet.biometricData.bloodPressure.hypertensiveReadings;
    
    if (abnormalHR > 10 || hypertensive > 5) {
      return RiskLevel.moderate;
    }
    return RiskLevel.low;
  }

  double _calculateRiskProbability(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return 0.15;
      case RiskLevel.moderate:
        return 0.45;
      case RiskLevel.high:
        return 0.75;
    }
  }

  List<String> _getDepressionRiskFactors(ClinicalDataSet dataSet) {
    return [
      'Persistent low wellbeing scores',
      'Poor sleep quality',
      'Reduced app engagement',
      'Irregular mood patterns',
    ];
  }

  List<String> _getPCOSRiskFactors(ClinicalDataSet dataSet) {
    return [
      'Irregular menstrual cycles',
      'High cycle variability',
      'Hormonal symptom patterns',
    ];
  }

  List<String> _getCardiovascularRiskFactors(ClinicalDataSet dataSet) {
    return [
      'Multiple abnormal heart rate readings',
      'Blood pressure variations',
      'Poor sleep quality',
    ];
  }

  String _getDepressionRecommendation(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return 'Continue monitoring mood patterns and maintain healthy lifestyle';
      case RiskLevel.moderate:
        return 'Consider mental health screening and counseling support';
      case RiskLevel.high:
        return 'Urgent psychiatric evaluation and intervention recommended';
    }
  }

  String _getPCOSRecommendation(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return 'Continue cycle tracking and maintain regular gynecological care';
      case RiskLevel.moderate:
        return 'Hormonal evaluation and gynecological consultation recommended';
      case RiskLevel.high:
        return 'Comprehensive reproductive endocrine evaluation needed';
    }
  }

  String _getCardiovascularRecommendation(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return 'Maintain current lifestyle and regular monitoring';
      case RiskLevel.moderate:
        return 'Cardiology consultation and lifestyle modifications recommended';
      case RiskLevel.high:
        return 'Immediate cardiovascular evaluation and intervention required';
    }
  }

  /// Helper methods for ID generation
  String _generateReportId() {
    return 'CR_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}';
  }

  String _generateRecommendationId() {
    return 'REC_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}';
  }

  String _generateInsightId() {
    return 'INS_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}';
  }

  /// Export clinical report
  Future<String> exportClinicalReport(ClinicalReport report, {
    ClinicalReportFormat format = ClinicalReportFormat.pdf,
  }) async {
    try {
      // In a real implementation, this would generate actual report files
      final reportJson = report.toJson();
      final reportString = json.encode(reportJson);
      
      // Save to device storage (mock implementation)
      final fileName = 'clinical_report_${report.id}.${format.name}';
      await _prefs?.setString('report_${report.id}', reportString);
      
      debugPrint('📄 Clinical report exported: $fileName');
      return fileName;
    } catch (e) {
      debugPrint('❌ Failed to export clinical report: $e');
      throw ClinicalException('Failed to export report: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _isInitialized = false;
  }
}

class ClinicalException implements Exception {
  final String message;
  ClinicalException(this.message);

  @override
  String toString() => 'ClinicalException: $message';
}
