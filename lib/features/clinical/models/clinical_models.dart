import '../../../features/tracking/screens/enhanced_daily_feelings_tracker.dart';

// === ENUMS ===

enum ClinicalCategory {
  mentalHealth,
  reproductive,
  cardiovascular,
  endocrine,
  neurological,
  dermatological,
  gastrointestinal,
  respiratory,
  musculoskeletal,
  sleep,
  lifestyle,
  general,
}

enum ClinicalSeverity {
  mild,
  moderate,
  severe,
}

enum RiskLevel {
  low,
  moderate,
  high,
}

enum RecommendationPriority {
  low,
  medium,
  high,
  urgent,
}

enum InsightCategory {
  correlation,
  trend,
  pattern,
  behavioral,
  predictive,
}

enum InsightSignificance {
  low,
  medium,
  high,
  critical,
}

enum ClinicalFlagType {
  warning,
  critical,
  urgent,
  informational,
}

enum ClinicalUrgency {
  routine,
  priority,
  urgent,
  immediate,
}

enum ClinicalReportFormat {
  pdf,
  json,
  hl7,
  csv,
}

// === CLINICAL DATA STRUCTURES ===

class ClinicalDataSet {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final FeelingsClinicalData feelingsData;
  final CycleClinicalData cycleData;
  final SymptomClinicalData symptomData;
  final BiometricClinicalData biometricData;
  final BehavioralClinicalData behavioralData;
  final double dataCompleteness;

  ClinicalDataSet({
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.feelingsData,
    required this.cycleData,
    required this.symptomData,
    required this.biometricData,
    required this.behavioralData,
    required this.dataCompleteness,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'feelings_data': feelingsData.toJson(),
      'cycle_data': cycleData.toJson(),
      'symptom_data': symptomData.toJson(),
      'biometric_data': biometricData.toJson(),
      'behavioral_data': behavioralData.toJson(),
      'data_completeness': dataCompleteness,
    };
  }
}

class FeelingsClinicalData {
  final int totalEntries;
  final int dateRange;
  final Map<String, MoodStatistics> moodStatistics;
  final WellbeingStatistics wellbeingStatistics;
  final double complianceRate;

  FeelingsClinicalData({
    required this.totalEntries,
    required this.dateRange,
    required this.moodStatistics,
    required this.wellbeingStatistics,
    required this.complianceRate,
  });

  factory FeelingsClinicalData.empty() {
    return FeelingsClinicalData(
      totalEntries: 0,
      dateRange: 0,
      moodStatistics: {},
      wellbeingStatistics: WellbeingStatistics(
        average: 0,
        minimum: 0,
        maximum: 0,
        standardDeviation: 0,
        trendDirection: TrendDirection.stable,
        daysBelow5: 0,
        daysAbove7: 0,
      ),
      complianceRate: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_entries': totalEntries,
      'date_range': dateRange,
      'mood_statistics': moodStatistics.map((k, v) => MapEntry(k, v.toJson())),
      'wellbeing_statistics': wellbeingStatistics.toJson(),
      'compliance_rate': complianceRate,
    };
  }
}

class MoodStatistics {
  final double average;
  final double minimum;
  final double maximum;
  final double standardDeviation;
  final TrendDirection trendDirection;
  final double volatility;

  MoodStatistics({
    required this.average,
    required this.minimum,
    required this.maximum,
    required this.standardDeviation,
    required this.trendDirection,
    required this.volatility,
  });

  Map<String, dynamic> toJson() {
    return {
      'average': average,
      'minimum': minimum,
      'maximum': maximum,
      'standard_deviation': standardDeviation,
      'trend_direction': trendDirection.name,
      'volatility': volatility,
    };
  }
}

class WellbeingStatistics {
  final double average;
  final double minimum;
  final double maximum;
  final double standardDeviation;
  final TrendDirection trendDirection;
  final int daysBelow5;
  final int daysAbove7;

  WellbeingStatistics({
    required this.average,
    required this.minimum,
    required this.maximum,
    required this.standardDeviation,
    required this.trendDirection,
    required this.daysBelow5,
    required this.daysAbove7,
  });

  Map<String, dynamic> toJson() {
    return {
      'average': average,
      'minimum': minimum,
      'maximum': maximum,
      'standard_deviation': standardDeviation,
      'trend_direction': trendDirection.name,
      'days_below_5': daysBelow5,
      'days_above_7': daysAbove7,
    };
  }
}

class CycleClinicalData {
  final int totalCycles;
  final double averageCycleLength;
  final double cycleVariability;
  final int irregularCycles;
  final int missedPeriods;
  final bool ovulationDetected;
  final bool lutealPhaseDefect;
  final Map<String, SymptomFrequency> symptoms;

  CycleClinicalData({
    required this.totalCycles,
    required this.averageCycleLength,
    required this.cycleVariability,
    required this.irregularCycles,
    required this.missedPeriods,
    required this.ovulationDetected,
    required this.lutealPhaseDefect,
    required this.symptoms,
  });

  Map<String, dynamic> toJson() {
    return {
      'total_cycles': totalCycles,
      'average_cycle_length': averageCycleLength,
      'cycle_variability': cycleVariability,
      'irregular_cycles': irregularCycles,
      'missed_periods': missedPeriods,
      'ovulation_detected': ovulationDetected,
      'luteal_phase_defect': lutealPhaseDefect,
      'symptoms': symptoms.map((k, v) => MapEntry(k, v.toJson())),
    };
  }
}

class SymptomFrequency {
  final double frequency; // 0.0 to 1.0
  final double severity;  // 1.0 to 10.0

  SymptomFrequency({
    required this.frequency,
    required this.severity,
  });

  Map<String, dynamic> toJson() {
    return {
      'frequency': frequency,
      'severity': severity,
    };
  }
}

class SymptomClinicalData {
  final int totalSymptomEntries;
  final int uniqueSymptoms;
  final double averageSymptomsPerDay;
  final Map<String, SymptomFrequency> mostFrequentSymptoms;
  final Map<String, double> severityDistribution;
  final List<String> symptomPatterns;

  SymptomClinicalData({
    required this.totalSymptomEntries,
    required this.uniqueSymptoms,
    required this.averageSymptomsPerDay,
    required this.mostFrequentSymptoms,
    required this.severityDistribution,
    required this.symptomPatterns,
  });

  Map<String, dynamic> toJson() {
    return {
      'total_symptom_entries': totalSymptomEntries,
      'unique_symptoms': uniqueSymptoms,
      'average_symptoms_per_day': averageSymptomsPerDay,
      'most_frequent_symptoms': mostFrequentSymptoms.map((k, v) => MapEntry(k, v.toJson())),
      'severity_distribution': severityDistribution,
      'symptom_patterns': symptomPatterns,
    };
  }
}

class BiometricClinicalData {
  final VitalStatistics heartRate;
  final BloodPressureStatistics bloodPressure;
  final VitalStatistics temperature;
  final VitalStatistics oxygenSaturation;
  final SleepStatistics sleepData;

  BiometricClinicalData({
    required this.heartRate,
    required this.bloodPressure,
    required this.temperature,
    required this.oxygenSaturation,
    required this.sleepData,
  });

  Map<String, dynamic> toJson() {
    return {
      'heart_rate': heartRate.toJson(),
      'blood_pressure': bloodPressure.toJson(),
      'temperature': temperature.toJson(),
      'oxygen_saturation': oxygenSaturation.toJson(),
      'sleep_data': sleepData.toJson(),
    };
  }
}

class VitalStatistics {
  final double average;
  final double minimum;
  final double maximum;
  final double restingAverage;
  final double exerciseAverage;
  final int abnormalReadings;

  VitalStatistics({
    required this.average,
    required this.minimum,
    required this.maximum,
    required this.restingAverage,
    required this.exerciseAverage,
    required this.abnormalReadings,
  });

  Map<String, dynamic> toJson() {
    return {
      'average': average,
      'minimum': minimum,
      'maximum': maximum,
      'resting_average': restingAverage,
      'exercise_average': exerciseAverage,
      'abnormal_readings': abnormalReadings,
    };
  }
}

class BloodPressureStatistics {
  final double systolicAverage;
  final double diastolicAverage;
  final int hypertensiveReadings;
  final int hypotensiveReadings;

  BloodPressureStatistics({
    required this.systolicAverage,
    required this.diastolicAverage,
    required this.hypertensiveReadings,
    required this.hypotensiveReadings,
  });

  Map<String, dynamic> toJson() {
    return {
      'systolic_average': systolicAverage,
      'diastolic_average': diastolicAverage,
      'hypertensive_readings': hypertensiveReadings,
      'hypotensive_readings': hypotensiveReadings,
    };
  }
}

class SleepStatistics {
  final double averageHours;
  final double sleepEfficiency;
  final double deepSleepPercentage;
  final double remSleepPercentage;
  final double sleepLatency;
  final double nightWakings;

  SleepStatistics({
    required this.averageHours,
    required this.sleepEfficiency,
    required this.deepSleepPercentage,
    required this.remSleepPercentage,
    required this.sleepLatency,
    required this.nightWakings,
  });

  Map<String, dynamic> toJson() {
    return {
      'average_hours': averageHours,
      'sleep_efficiency': sleepEfficiency,
      'deep_sleep_percentage': deepSleepPercentage,
      'rem_sleep_percentage': remSleepPercentage,
      'sleep_latency': sleepLatency,
      'night_wakings': nightWakings,
    };
  }
}

class BehavioralClinicalData {
  final AppUsageStatistics appUsagePatterns;
  final ComplianceMetrics complianceMetrics;
  final double engagementScore;
  final List<String> riskBehaviors;

  BehavioralClinicalData({
    required this.appUsagePatterns,
    required this.complianceMetrics,
    required this.engagementScore,
    required this.riskBehaviors,
  });

  Map<String, dynamic> toJson() {
    return {
      'app_usage_patterns': appUsagePatterns.toJson(),
      'compliance_metrics': complianceMetrics.toJson(),
      'engagement_score': engagementScore,
      'risk_behaviors': riskBehaviors,
    };
  }
}

class AppUsageStatistics {
  final double dailySessionsAverage;
  final double sessionDurationAverage;
  final List<int> mostActiveHours;
  final Map<String, double> featureUsageDistribution;

  AppUsageStatistics({
    required this.dailySessionsAverage,
    required this.sessionDurationAverage,
    required this.mostActiveHours,
    required this.featureUsageDistribution,
  });

  Map<String, dynamic> toJson() {
    return {
      'daily_sessions_average': dailySessionsAverage,
      'session_duration_average': sessionDurationAverage,
      'most_active_hours': mostActiveHours,
      'feature_usage_distribution': featureUsageDistribution,
    };
  }
}

class ComplianceMetrics {
  final double dataEntryConsistency;
  final double recommendationAdherence;
  final double appointmentCompliance;

  ComplianceMetrics({
    required this.dataEntryConsistency,
    required this.recommendationAdherence,
    required this.appointmentCompliance,
  });

  Map<String, dynamic> toJson() {
    return {
      'data_entry_consistency': dataEntryConsistency,
      'recommendation_adherence': recommendationAdherence,
      'appointment_compliance': appointmentCompliance,
    };
  }
}

// === CLINICAL ANALYSIS RESULTS ===

class ClinicalAnalysis {
  final double overallHealthScore;
  final List<ClinicalFinding> findings;
  final List<ClinicalFlag> clinicalFlags;
  final TrendAnalysisResult trendAnalysis;
  final CorrelationAnalysisResult correlationAnalysis;
  final double confidenceLevel;

  ClinicalAnalysis({
    required this.overallHealthScore,
    required this.findings,
    required this.clinicalFlags,
    required this.trendAnalysis,
    required this.correlationAnalysis,
    required this.confidenceLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'overall_health_score': overallHealthScore,
      'findings': findings.map((f) => f.toJson()).toList(),
      'clinical_flags': clinicalFlags.map((f) => f.toJson()).toList(),
      'trend_analysis': trendAnalysis.toJson(),
      'correlation_analysis': correlationAnalysis.toJson(),
      'confidence_level': confidenceLevel,
    };
  }
}

class ClinicalFinding {
  final ClinicalCategory category;
  final ClinicalSeverity severity;
  final String description;
  final double evidenceScore;
  final String recommendation;

  ClinicalFinding({
    required this.category,
    required this.severity,
    required this.description,
    required this.evidenceScore,
    required this.recommendation,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category.name,
      'severity': severity.name,
      'description': description,
      'evidence_score': evidenceScore,
      'recommendation': recommendation,
    };
  }
}

class ClinicalFlag {
  final ClinicalFlagType type;
  final String message;
  final ClinicalCategory category;
  final ClinicalUrgency urgency;

  ClinicalFlag({
    required this.type,
    required this.message,
    required this.category,
    required this.urgency,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'message': message,
      'category': category.name,
      'urgency': urgency.name,
    };
  }
}

class TrendAnalysisResult {
  final Map<String, TrendDirection> moodTrends;
  final Map<String, TrendDirection> vitalTrends;
  final TrendDirection overallTrend;

  TrendAnalysisResult({
    required this.moodTrends,
    required this.vitalTrends,
    required this.overallTrend,
  });

  Map<String, dynamic> toJson() {
    return {
      'mood_trends': moodTrends.map((k, v) => MapEntry(k, v.name)),
      'vital_trends': vitalTrends.map((k, v) => MapEntry(k, v.name)),
      'overall_trend': overallTrend.name,
    };
  }
}

class CorrelationAnalysisResult {
  final List<CorrelationPair> significantCorrelations;
  final String networkAnalysis;

  CorrelationAnalysisResult({
    required this.significantCorrelations,
    required this.networkAnalysis,
  });

  Map<String, dynamic> toJson() {
    return {
      'significant_correlations': significantCorrelations.map((c) => c.toJson()).toList(),
      'network_analysis': networkAnalysis,
    };
  }
}

class CorrelationPair {
  final String variable1;
  final String variable2;
  final double correlation;
  final double significance;

  CorrelationPair({
    required this.variable1,
    required this.variable2,
    required this.correlation,
    required this.significance,
  });

  Map<String, dynamic> toJson() {
    return {
      'variable1': variable1,
      'variable2': variable2,
      'correlation': correlation,
      'significance': significance,
    };
  }
}

// === RISK ASSESSMENTS ===

class RiskAssessment {
  final String condition;
  final RiskLevel riskLevel;
  final double probability;
  final List<String> factors;
  final String timeframe;
  final String recommendation;

  RiskAssessment({
    required this.condition,
    required this.riskLevel,
    required this.probability,
    required this.factors,
    required this.timeframe,
    required this.recommendation,
  });

  Map<String, dynamic> toJson() {
    return {
      'condition': condition,
      'risk_level': riskLevel.name,
      'probability': probability,
      'factors': factors,
      'timeframe': timeframe,
      'recommendation': recommendation,
    };
  }
}

// === RECOMMENDATIONS ===

class ClinicalRecommendation {
  final String id;
  final ClinicalCategory category;
  final RecommendationPriority priority;
  final String title;
  final String description;
  final String rationale;
  final String evidenceLevel;
  final String timeframe;
  final bool followUpRequired;

  ClinicalRecommendation({
    required this.id,
    required this.category,
    required this.priority,
    required this.title,
    required this.description,
    required this.rationale,
    required this.evidenceLevel,
    required this.timeframe,
    required this.followUpRequired,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.name,
      'priority': priority.name,
      'title': title,
      'description': description,
      'rationale': rationale,
      'evidence_level': evidenceLevel,
      'timeframe': timeframe,
      'follow_up_required': followUpRequired,
    };
  }
}

// === MEDICAL INSIGHTS ===

class MedicalInsight {
  final String id;
  final InsightCategory category;
  final String title;
  final String description;
  final InsightSignificance significance;
  final double confidence;
  final String clinicalRelevance;
  final List<String> supportingData;

  MedicalInsight({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.significance,
    required this.confidence,
    required this.clinicalRelevance,
    required this.supportingData,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.name,
      'title': title,
      'description': description,
      'significance': significance.name,
      'confidence': confidence,
      'clinical_relevance': clinicalRelevance,
      'supporting_data': supportingData,
    };
  }
}

// === CLINICAL REPORT ===

class ClinicalReport {
  final String id;
  final String userId;
  final String patientName;
  final DateTime reportDate;
  final int analysisWindow;
  final ClinicalDataSet dataSet;
  final ClinicalAnalysis analysis;
  final List<RiskAssessment> riskAssessments;
  final List<ClinicalRecommendation> recommendations;
  final List<MedicalInsight> insights;
  final String? providerNotes;
  final DateTime generatedAt;
  final String version;

  ClinicalReport({
    required this.id,
    required this.userId,
    required this.patientName,
    required this.reportDate,
    required this.analysisWindow,
    required this.dataSet,
    required this.analysis,
    required this.riskAssessments,
    required this.recommendations,
    required this.insights,
    this.providerNotes,
    required this.generatedAt,
    required this.version,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'patient_name': patientName,
      'report_date': reportDate.toIso8601String(),
      'analysis_window': analysisWindow,
      'data_set': dataSet.toJson(),
      'analysis': analysis.toJson(),
      'risk_assessments': riskAssessments.map((r) => r.toJson()).toList(),
      'recommendations': recommendations.map((r) => r.toJson()).toList(),
      'insights': insights.map((i) => i.toJson()).toList(),
      'provider_notes': providerNotes,
      'generated_at': generatedAt.toIso8601String(),
      'version': version,
    };
  }

  factory ClinicalReport.fromJson(Map<String, dynamic> json) {
    return ClinicalReport(
      id: json['id'],
      userId: json['user_id'],
      patientName: json['patient_name'],
      reportDate: DateTime.parse(json['report_date']),
      analysisWindow: json['analysis_window'],
      dataSet: ClinicalDataSet(
        userId: json['data_set']['user_id'],
        startDate: DateTime.parse(json['data_set']['start_date']),
        endDate: DateTime.parse(json['data_set']['end_date']),
        feelingsData: FeelingsClinicalData.empty(), // Simplified for brevity
        cycleData: CycleClinicalData(
          totalCycles: 0,
          averageCycleLength: 0,
          cycleVariability: 0,
          irregularCycles: 0,
          missedPeriods: 0,
          ovulationDetected: false,
          lutealPhaseDefect: false,
          symptoms: {},
        ),
        symptomData: SymptomClinicalData(
          totalSymptomEntries: 0,
          uniqueSymptoms: 0,
          averageSymptomsPerDay: 0,
          mostFrequentSymptoms: {},
          severityDistribution: {},
          symptomPatterns: [],
        ),
        biometricData: BiometricClinicalData(
          heartRate: VitalStatistics(
            average: 0,
            minimum: 0,
            maximum: 0,
            restingAverage: 0,
            exerciseAverage: 0,
            abnormalReadings: 0,
          ),
          bloodPressure: BloodPressureStatistics(
            systolicAverage: 0,
            diastolicAverage: 0,
            hypertensiveReadings: 0,
            hypotensiveReadings: 0,
          ),
          temperature: VitalStatistics(
            average: 0,
            minimum: 0,
            maximum: 0,
            restingAverage: 0,
            exerciseAverage: 0,
            abnormalReadings: 0,
          ),
          oxygenSaturation: VitalStatistics(
            average: 0,
            minimum: 0,
            maximum: 0,
            restingAverage: 0,
            exerciseAverage: 0,
            abnormalReadings: 0,
          ),
          sleepData: SleepStatistics(
            averageHours: 0,
            sleepEfficiency: 0,
            deepSleepPercentage: 0,
            remSleepPercentage: 0,
            sleepLatency: 0,
            nightWakings: 0,
          ),
        ),
        behavioralData: BehavioralClinicalData(
          appUsagePatterns: AppUsageStatistics(
            dailySessionsAverage: 0,
            sessionDurationAverage: 0,
            mostActiveHours: [],
            featureUsageDistribution: {},
          ),
          complianceMetrics: ComplianceMetrics(
            dataEntryConsistency: 0,
            recommendationAdherence: 0,
            appointmentCompliance: 0,
          ),
          engagementScore: 0,
          riskBehaviors: [],
        ),
        dataCompleteness: json['data_set']['data_completeness'] ?? 0.0,
      ),
      analysis: ClinicalAnalysis(
        overallHealthScore: json['analysis']['overall_health_score'] ?? 0.0,
        findings: [],
        clinicalFlags: [],
        trendAnalysis: TrendAnalysisResult(
          moodTrends: {},
          vitalTrends: {},
          overallTrend: TrendDirection.stable,
        ),
        correlationAnalysis: CorrelationAnalysisResult(
          significantCorrelations: [],
          networkAnalysis: '',
        ),
        confidenceLevel: json['analysis']['confidence_level'] ?? 0.0,
      ),
      riskAssessments: [],
      recommendations: [],
      insights: [],
      providerNotes: json['provider_notes'],
      generatedAt: DateTime.parse(json['generated_at']),
      version: json['version'],
    );
  }
}
