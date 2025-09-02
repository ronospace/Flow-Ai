/// User Profile and Personalization Models
/// Week 2: Advanced personalization data structures

class UserProfile {
  final String id;
  final String? displayName;
  final int? age;
  final String? lifestyle;
  final List<String> healthConcerns;
  final Map<String, dynamic> preferences;
  final Map<String, dynamic> personalizedBaselines;
  final List<AdaptationEvent> adaptationHistory;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? weight;
  final double? height;
  final Map<String, dynamic>? familyHistory;

  const UserProfile({
    required this.id,
    this.displayName,
    this.age,
    this.lifestyle,
    required this.healthConcerns,
    required this.preferences,
    required this.personalizedBaselines,
    required this.adaptationHistory,
    required this.createdAt,
    required this.updatedAt,
    this.weight,
    this.height,
    this.familyHistory,
  });

  UserProfile copyWith({
    String? id,
    String? displayName,
    int? age,
    String? lifestyle,
    List<String>? healthConcerns,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? personalizedBaselines,
    List<AdaptationEvent>? adaptationHistory,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? weight,
    double? height,
    Map<String, dynamic>? familyHistory,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      age: age ?? this.age,
      lifestyle: lifestyle ?? this.lifestyle,
      healthConcerns: healthConcerns ?? this.healthConcerns,
      preferences: preferences ?? this.preferences,
      personalizedBaselines: personalizedBaselines ?? this.personalizedBaselines,
      adaptationHistory: adaptationHistory ?? this.adaptationHistory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      familyHistory: familyHistory ?? this.familyHistory,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'age': age,
      'lifestyle': lifestyle,
      'health_concerns': healthConcerns,
      'preferences': preferences,
      'personalized_baselines': personalizedBaselines,
      'adaptation_history': adaptationHistory.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'weight': weight,
      'height': height,
      'family_history': familyHistory,
    };
  }

  static UserProfile fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      displayName: json['display_name'],
      age: json['age'],
      lifestyle: json['lifestyle'],
      healthConcerns: List<String>.from(json['health_concerns'] ?? []),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      personalizedBaselines: Map<String, dynamic>.from(json['personalized_baselines'] ?? {}),
      adaptationHistory: (json['adaptation_history'] as List<dynamic>?)
          ?.map((e) => AdaptationEvent.fromJson(e))
          .toList() ?? [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      height: json['height'] != null ? (json['height'] as num).toDouble() : null,
      familyHistory: json['family_history'] != null ? Map<String, dynamic>.from(json['family_history']) : null,
    );
  }
  
  // Add fromMap and toMap for compatibility
  static UserProfile fromMap(Map<String, dynamic> map) => fromJson(map);
  Map<String, dynamic> toMap() => toJson();
}

class AdaptationEvent {
  final String id;
  final String eventType;
  final String predictionType;
  final double originalValue;
  final double correctedValue;
  final String? reason;
  final double impactScore;
  final DateTime timestamp;

  const AdaptationEvent({
    required this.id,
    required this.eventType,
    required this.predictionType,
    required this.originalValue,
    required this.correctedValue,
    this.reason,
    required this.impactScore,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_type': eventType,
      'prediction_type': predictionType,
      'original_value': originalValue,
      'corrected_value': correctedValue,
      'reason': reason,
      'impact_score': impactScore,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  static AdaptationEvent fromJson(Map<String, dynamic> json) {
    return AdaptationEvent(
      id: json['id'],
      eventType: json['event_type'],
      predictionType: json['prediction_type'],
      originalValue: json['original_value'].toDouble(),
      correctedValue: json['corrected_value'].toDouble(),
      reason: json['reason'],
      impactScore: json['impact_score'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

/// Personalized AI Insights
enum PersonalizedInsightType {
  lifestyle,
  behavioral,
  health,
  predictive,
  nutritional,
  emotional,
}

class PersonalizedInsight {
  final String id;
  final PersonalizedInsightType type;
  final String title;
  final String description;
  final double confidence;
  final double relevanceScore;
  final List<String> personalizedRecommendations;
  final List<String> basedOnFactors;
  final Map<String, dynamic>? additionalData;
  final DateTime generatedAt;

  PersonalizedInsight({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.confidence,
    required this.relevanceScore,
    required this.personalizedRecommendations,
    required this.basedOnFactors,
    this.additionalData,
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'confidence': confidence,
      'relevance_score': relevanceScore,
      'personalized_recommendations': personalizedRecommendations,
      'based_on_factors': basedOnFactors,
      'additional_data': additionalData,
      'generated_at': generatedAt.toIso8601String(),
    };
  }

  static PersonalizedInsight fromJson(Map<String, dynamic> json) {
    return PersonalizedInsight(
      id: json['id'],
      type: PersonalizedInsightType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PersonalizedInsightType.health,
      ),
      title: json['title'],
      description: json['description'],
      confidence: json['confidence'].toDouble(),
      relevanceScore: json['relevance_score'].toDouble(),
      personalizedRecommendations: List<String>.from(json['personalized_recommendations'] ?? []),
      basedOnFactors: List<String>.from(json['based_on_factors'] ?? []),
      additionalData: json['additional_data'],
      generatedAt: DateTime.parse(json['generated_at']),
    );
  }
}

/// Personalized Recommendations
enum PersonalizedRecommendationType {
  lifestyle,
  health,
  behavioral,
  nutritional,
  exercise,
  mindfulness,
}

class PersonalizedRecommendation {
  final String id;
  final PersonalizedRecommendationType type;
  final String title;
  final String description;
  final List<String> actionItems;
  final double personalRelevance;
  final String expectedBenefit;
  final String timeframe;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  PersonalizedRecommendation({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.actionItems,
    required this.personalRelevance,
    required this.expectedBenefit,
    required this.timeframe,
    this.metadata,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'action_items': actionItems,
      'personal_relevance': personalRelevance,
      'expected_benefit': expectedBenefit,
      'timeframe': timeframe,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static PersonalizedRecommendation fromJson(Map<String, dynamic> json) {
    return PersonalizedRecommendation(
      id: json['id'],
      type: PersonalizedRecommendationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PersonalizedRecommendationType.health,
      ),
      title: json['title'],
      description: json['description'],
      actionItems: List<String>.from(json['action_items'] ?? []),
      personalRelevance: json['personal_relevance'].toDouble(),
      expectedBenefit: json['expected_benefit'],
      timeframe: json['timeframe'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

/// User Behavioral Patterns
class BehavioralPattern {
  final String userId;
  final String patternType;
  final Map<String, dynamic> patternData;
  final double confidence;
  final DateTime detectedAt;
  final DateTime? expiresAt;

  const BehavioralPattern({
    required this.userId,
    required this.patternType,
    required this.patternData,
    required this.confidence,
    required this.detectedAt,
    this.expiresAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'pattern_type': patternType,
      'pattern_data': patternData,
      'confidence': confidence,
      'detected_at': detectedAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  static BehavioralPattern fromJson(Map<String, dynamic> json) {
    return BehavioralPattern(
      userId: json['user_id'],
      patternType: json['pattern_type'],
      patternData: Map<String, dynamic>.from(json['pattern_data']),
      confidence: json['confidence'].toDouble(),
      detectedAt: DateTime.parse(json['detected_at']),
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
    );
  }
}

/// Personal Health Metrics
class PersonalHealthMetric {
  final String userId;
  final String metricType;
  final double value;
  final double personalBaseline;
  final double deviation;
  final String trend; // 'improving', 'stable', 'declining'
  final DateTime measuredAt;
  final Map<String, dynamic>? context;

  const PersonalHealthMetric({
    required this.userId,
    required this.metricType,
    required this.value,
    required this.personalBaseline,
    required this.deviation,
    required this.trend,
    required this.measuredAt,
    this.context,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'metric_type': metricType,
      'value': value,
      'personal_baseline': personalBaseline,
      'deviation': deviation,
      'trend': trend,
      'measured_at': measuredAt.toIso8601String(),
      'context': context,
    };
  }

  static PersonalHealthMetric fromJson(Map<String, dynamic> json) {
    return PersonalHealthMetric(
      userId: json['user_id'],
      metricType: json['metric_type'],
      value: json['value'].toDouble(),
      personalBaseline: json['personal_baseline'].toDouble(),
      deviation: json['deviation'].toDouble(),
      trend: json['trend'],
      measuredAt: DateTime.parse(json['measured_at']),
      context: json['context'],
    );
  }
}

/// Adaptive Learning Configuration
class AdaptiveLearningConfig {
  final String userId;
  final Map<String, double> learningRates;
  final Map<String, double> confidenceThresholds;
  final Map<String, int> adaptationCooldowns;
  final bool autoAdaptationEnabled;
  final DateTime lastUpdated;

  const AdaptiveLearningConfig({
    required this.userId,
    required this.learningRates,
    required this.confidenceThresholds,
    required this.adaptationCooldowns,
    required this.autoAdaptationEnabled,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'learning_rates': learningRates,
      'confidence_thresholds': confidenceThresholds,
      'adaptation_cooldowns': adaptationCooldowns,
      'auto_adaptation_enabled': autoAdaptationEnabled,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  static AdaptiveLearningConfig fromJson(Map<String, dynamic> json) {
    return AdaptiveLearningConfig(
      userId: json['user_id'],
      learningRates: Map<String, double>.from(json['learning_rates']),
      confidenceThresholds: Map<String, double>.from(json['confidence_thresholds']),
      adaptationCooldowns: Map<String, int>.from(json['adaptation_cooldowns']),
      autoAdaptationEnabled: json['auto_adaptation_enabled'],
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }
}
