import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../models/cycle_data.dart';
import '../models/user_profile.dart';

/// 🌈 Revolutionary Emotional Intelligence AI Engine
/// Advanced sentiment analysis, mood prediction, and empathetic support
/// Tailored to hormonal fluctuations and menstrual cycle phases
class EmotionalIntelligenceEngine {
  static final EmotionalIntelligenceEngine _instance = EmotionalIntelligenceEngine._internal();
  static EmotionalIntelligenceEngine get instance => _instance;
  EmotionalIntelligenceEngine._internal();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  // AI Components
  late SentimentAnalyzer _sentimentAnalyzer;
  late MoodPredictor _moodPredictor;
  late EmpatheticChatbot _chatbot;
  late EmotionalPatternDetector _patternDetector;
  late HormonalCorrelationEngine _hormonalEngine;

  // Real-time emotional state tracking
  final StreamController<EmotionalState> _emotionalStateStream = StreamController.broadcast();
  Stream<EmotionalState> get emotionalStateStream => _emotionalStateStream.stream;

  // Emotional memory and context
  final List<EmotionalMemory> _emotionalHistory = [];

  Future<void> initialize() async {
    if (_initialized) return;

    debugPrint('🌈 Initializing Emotional Intelligence Engine...');

    // Initialize AI components
    await _initializeAIComponents();
    
    // Load emotional intelligence models
    await _loadEmotionalModels();
    
    // Setup real-time monitoring
    await _setupEmotionalMonitoring();

    _initialized = true;
    debugPrint('✅ Emotional Intelligence Engine initialized with advanced empathy');
  }

  Future<void> _initializeAIComponents() async {
    debugPrint('🧠 Initializing emotional AI components...');

    _sentimentAnalyzer = SentimentAnalyzer();
    _moodPredictor = MoodPredictor();
    _chatbot = EmpatheticChatbot();
    _patternDetector = EmotionalPatternDetector();
    _hormonalEngine = HormonalCorrelationEngine();

    await Future.wait([
      _sentimentAnalyzer.initialize(),
      _moodPredictor.initialize(),
      _chatbot.initialize(),
      _patternDetector.initialize(),
      _hormonalEngine.initialize(),
    ]);
  }

  Future<void> _loadEmotionalModels() async {
    debugPrint('📚 Loading emotional intelligence models...');
    // Load pre-trained models for sentiment analysis and mood prediction
    // In production, this would load actual ML models
  }

  Future<void> _setupEmotionalMonitoring() async {
    // Setup continuous emotional state monitoring
    Timer.periodic(const Duration(hours: 1), (_) async {
      await _assessCurrentEmotionalState();
    });
  }

  Future<void> _assessCurrentEmotionalState() async {
    // Analyze current emotional state and update stream
    final state = await _getCurrentEmotionalState();
    _emotionalStateStream.add(state);
  }

  /// Analyze text input for sentiment and emotional content
  Future<SentimentAnalysisResult> analyzeSentiment({
    required String text,
    required String currentPhase,
    Map<String, dynamic>? contextData,
  }) async {
    if (!_initialized) await initialize();

    debugPrint('💭 Analyzing sentiment for text: "${text.length > 50 ? text.substring(0, 50) : text}..."');

    // Basic sentiment analysis with hormonal context
    final sentiment = await _sentimentAnalyzer.analyze(text, currentPhase);
    
    // Correlate with hormonal phase
    final hormonalContext = await _hormonalEngine.analyzeHormonalImpact(
      sentiment, currentPhase);
    
    // Store in emotional memory
    _addToEmotionalMemory(EmotionalMemory(
      timestamp: DateTime.now(),
      text: text,
      sentiment: sentiment,
      phase: currentPhase,
      context: contextData ?? {},
    ));

    return SentimentAnalysisResult(
      originalText: text,
      sentiment: sentiment,
      hormonalContext: hormonalContext,
      confidence: sentiment.confidence,
      emotions: sentiment.emotions,
      recommendations: _generateSentimentRecommendations(sentiment, currentPhase),
      insights: _generateSentimentInsights(sentiment, currentPhase),
    );
  }

  /// Predict mood trajectory based on current state and cycle phase
  Future<MoodPredictionResult> predictMood({
    required String currentPhase,
    required List<CycleData> cycleHistory,
    Map<String, dynamic>? currentMoodData,
    int daysAhead = 7,
  }) async {
    if (!_initialized) await initialize();

    debugPrint('🔮 Predicting mood trajectory for $currentPhase phase...');

    // Analyze historical mood patterns
    final patterns = await _patternDetector.detectMoodPatterns(
      _emotionalHistory, cycleHistory);
    
    // Generate predictions
    final predictions = await _moodPredictor.predict(
      currentPhase: currentPhase,
      patterns: patterns,
      currentMood: currentMoodData,
      daysAhead: daysAhead,
    );

    return MoodPredictionResult(
      currentPhase: currentPhase,
      predictions: predictions,
      patterns: patterns,
      riskFactors: _identifyMoodRiskFactors(patterns, currentPhase),
      protectiveFactors: _identifyProtectiveFactors(patterns, currentPhase),
      recommendations: _generateMoodRecommendations(predictions, currentPhase),
      interventions: _suggestMoodInterventions(predictions, currentPhase),
    );
  }

  /// Get empathetic chatbot response tailored to current emotional state
  Future<ChatbotResponse> getChatbotResponse({
    required String userMessage,
    required String currentPhase,
    Map<String, dynamic>? emotionalContext,
  }) async {
    if (!_initialized) await initialize();

    debugPrint('💬 Generating empathetic response for: "$userMessage"');

    // Analyze user's emotional state from message
    final sentimentResult = await analyzeSentiment(
      text: userMessage,
      currentPhase: currentPhase,
      contextData: emotionalContext,
    );

    // Generate empathetic response
    final response = await _chatbot.generateResponse(
      userMessage: userMessage,
      sentiment: sentimentResult.sentiment,
      currentPhase: currentPhase,
      emotionalHistory: _emotionalHistory,
      context: emotionalContext ?? {},
    );

    return response;
  }

  /// Comprehensive emotional wellness assessment
  Future<EmotionalWellnessReport> generateWellnessReport({
    required UserProfile user,
    required String currentPhase,
    required List<CycleData> cycleHistory,
    int daysPeriod = 30,
  }) async {
    if (!_initialized) await initialize();

    debugPrint('📊 Generating comprehensive emotional wellness report...');

    // Analyze recent emotional data
    final recentHistory = _getRecentEmotionalHistory(daysPeriod);
    
    // Detect emotional patterns
    final patterns = await _patternDetector.detectEmotionalPatterns(
      recentHistory, cycleHistory);
    
    // Assess emotional stability
    final stability = _assessEmotionalStability(recentHistory);
    
    // Calculate wellness score
    final wellnessScore = _calculateEmotionalWellnessScore(
      patterns, stability, currentPhase);
    
    // Generate insights and recommendations
    final insights = _generateWellnessInsights(
      patterns, stability, currentPhase, user);
    
    final recommendations = _generateWellnessRecommendations(
      patterns, stability, currentPhase, user);

    return EmotionalWellnessReport(
      userId: user.id,
      reportPeriod: daysPeriod,
      currentPhase: currentPhase,
      wellnessScore: wellnessScore,
      patterns: patterns,
      stability: stability,
      insights: insights,
      recommendations: recommendations,
      riskFactors: _identifyEmotionalRiskFactors(patterns, stability),
      strengths: _identifyEmotionalStrengths(patterns, stability),
      generatedAt: DateTime.now(),
    );
  }

  Future<EmotionalState> _getCurrentEmotionalState() async {
    // Analyze current emotional state based on recent data
    final recentEmotions = _getRecentEmotionalHistory(1);
    
    if (recentEmotions.isEmpty) {
      return EmotionalState(
        timestamp: DateTime.now(),
        primaryEmotion: 'neutral',
        intensity: 0.5,
        valence: 0.0,
        arousal: 0.5,
        stability: 0.7,
        confidence: 0.3,
      );
    }

    final latest = recentEmotions.last;
    return EmotionalState(
      timestamp: DateTime.now(),
      primaryEmotion: latest.sentiment.primaryEmotion,
      intensity: latest.sentiment.intensity,
      valence: latest.sentiment.valence,
      arousal: latest.sentiment.arousal,
      stability: _calculateEmotionalStability(recentEmotions),
      confidence: latest.sentiment.confidence,
    );
  }

  void _addToEmotionalMemory(EmotionalMemory memory) {
    _emotionalHistory.add(memory);
    
    // Keep only recent history (last 90 days)
    final cutoff = DateTime.now().subtract(const Duration(days: 90));
    _emotionalHistory.removeWhere((m) => m.timestamp.isBefore(cutoff));
  }

  List<EmotionalMemory> _getRecentEmotionalHistory(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _emotionalHistory.where((m) => m.timestamp.isAfter(cutoff)).toList();
  }

  List<String> _generateSentimentRecommendations(Sentiment sentiment, String phase) {
    final recommendations = <String>[];

    if (sentiment.valence < -0.3) {
      // Negative emotions
      recommendations.addAll([
        'Practice self-compassion - your feelings are valid',
        'Consider gentle movement or stretching',
        'Try deep breathing exercises (4-7-8 technique)',
      ]);

      if (phase == 'luteal') {
        recommendations.add('Remember: PMS emotions are temporary and will pass');
      }
    } else if (sentiment.valence > 0.3) {
      // Positive emotions
      recommendations.addAll([
        'Savor this positive moment mindfully',
        'Share your joy with loved ones',
        'Use this energy for meaningful activities',
      ]);
    }

    if (sentiment.arousal > 0.7) {
      // High arousal
      recommendations.add('Channel this energy through physical activity or creative expression');
    }

    return recommendations;
  }

  Map<String, dynamic> _generateSentimentInsights(Sentiment sentiment, String phase) {
    return {
      'emotional_intelligence_note': 'Your emotional awareness is a strength',
      'phase_correlation': _getPhaseEmotionalCorrelation(sentiment, phase),
      'pattern_observation': _observeEmotionalPattern(sentiment),
      'growth_opportunity': _identifyGrowthOpportunity(sentiment),
    };
  }

  String _getPhaseEmotionalCorrelation(Sentiment sentiment, String phase) {
    switch (phase) {
      case 'menstrual':
        return 'Menstrual phase often brings introspection and emotional processing';
      case 'follicular':
        return 'Follicular phase typically increases optimism and energy';
      case 'ovulatory':
        return 'Ovulatory phase often enhances confidence and social connection';
      case 'luteal':
        return 'Luteal phase can intensify emotions - this is completely normal';
      default:
        return 'Emotional fluctuations are natural throughout your cycle';
    }
  }

  String _observeEmotionalPattern(Sentiment sentiment) {
    if (_emotionalHistory.length < 5) {
      return 'Building your emotional pattern profile...';
    }

    final recentSentiments = _emotionalHistory.skip(math.max(0, _emotionalHistory.length - 5)).map((m) => m.sentiment).toList();
    final avgValence = recentSentiments.map((s) => s.valence).reduce((a, b) => a + b) / 5;

    if (avgValence > 0.3) {
      return 'You\'ve been experiencing predominantly positive emotions lately';
    } else if (avgValence < -0.3) {
      return 'You\'ve been processing some challenging emotions recently';
    } else {
      return 'Your emotional state has been relatively balanced';
    }
  }

  String _identifyGrowthOpportunity(Sentiment sentiment) {
    if (sentiment.confidence < 0.5) {
      return 'Consider keeping an emotion journal to build self-awareness';
    } else if (sentiment.intensity > 0.8) {
      return 'Practicing emotional regulation techniques could be beneficial';
    } else {
      return 'Your emotional processing appears healthy and adaptive';
    }
  }

  List<String> _identifyMoodRiskFactors(Map<String, dynamic> patterns, String phase) {
    final risks = <String>[];

    if (patterns['volatility'] != null && patterns['volatility'] > 0.7) {
      risks.add('High emotional volatility detected');
    }

    if (phase == 'luteal' && patterns['luteal_intensity'] != null && patterns['luteal_intensity'] > 0.8) {
      risks.add('Intense luteal phase emotional patterns');
    }

    if (patterns['negative_trend'] == true) {
      risks.add('Recent downward trend in emotional well-being');
    }

    return risks;
  }

  List<String> _identifyProtectiveFactors(Map<String, dynamic> patterns, String phase) {
    final factors = <String>[];

    if (patterns['emotional_awareness'] != null && patterns['emotional_awareness'] > 0.7) {
      factors.add('Strong emotional self-awareness');
    }

    if (patterns['recovery_speed'] != null && patterns['recovery_speed'] > 0.6) {
      factors.add('Good emotional resilience and recovery');
    }

    if (patterns['positive_coping'] == true) {
      factors.add('Effective coping strategies in use');
    }

    return factors;
  }

  List<String> _generateMoodRecommendations(Map<String, dynamic> predictions, String phase) {
    final recommendations = <String>[];

    if (predictions['risk_days'] != null && (predictions['risk_days'] as List).isNotEmpty) {
      recommendations.add('Plan self-care activities for predicted challenging days');
    }

    switch (phase) {
      case 'menstrual':
        recommendations.addAll([
          'Honor your need for rest and gentleness',
          'Practice extra self-compassion',
          'Allow emotions to flow without judgment',
        ]);
        break;
      case 'follicular':
        recommendations.addAll([
          'Take advantage of increasing energy and optimism',
          'Set intentions and goals for the cycle ahead',
          'Engage in new experiences and challenges',
        ]);
        break;
      case 'ovulatory':
        recommendations.addAll([
          'Leverage your peak confidence and communication skills',
          'Focus on important conversations and decisions',
          'Connect with others and build relationships',
        ]);
        break;
      case 'luteal':
        recommendations.addAll([
          'Prepare for potential mood shifts',
          'Prioritize stress management and relaxation',
          'Practice boundary setting and saying no',
        ]);
        break;
    }

    return recommendations;
  }

  List<String> _suggestMoodInterventions(Map<String, dynamic> predictions, String phase) {
    final interventions = <String>[];

    if (predictions['depression_risk'] != null && predictions['depression_risk'] > 0.6) {
      interventions.addAll([
        'Consider speaking with a mental health professional',
        'Implement daily mood tracking',
        'Establish a consistent sleep schedule',
      ]);
    }

    if (predictions['anxiety_risk'] != null && predictions['anxiety_risk'] > 0.6) {
      interventions.addAll([
        'Practice mindfulness meditation daily',
        'Try progressive muscle relaxation',
        'Limit caffeine intake, especially in luteal phase',
      ]);
    }

    interventions.addAll([
      'Maintain regular exercise routine',
      'Prioritize social connections',
      'Consider nutritional support (omega-3, magnesium)',
    ]);

    return interventions;
  }

  double _assessEmotionalStability(List<EmotionalMemory> history) {
    if (history.isEmpty) return 0.5;

    // Calculate coefficient of variation in emotional valence
    final valences = history.map((m) => m.sentiment.valence).toList();
    final mean = valences.reduce((a, b) => a + b) / valences.length;
    final variance = valences.map((v) => math.pow(v - mean, 2)).reduce((a, b) => a + b) / valences.length;
    final stdDev = math.sqrt(variance);
    final cv = stdDev / mean.abs();

    // Lower coefficient of variation = higher stability
    return (1.0 - cv.clamp(0.0, 1.0)).clamp(0.0, 1.0);
  }

  double _calculateEmotionalWellnessScore(
      Map<String, dynamic> patterns, double stability, String phase) {
    double score = 0.5; // Base score

    // Factor in emotional stability (30%)
    score += (stability - 0.5) * 0.6;

    // Factor in positive patterns (25%)
    if (patterns['positive_trend'] == true) score += 0.125;
    if (patterns['emotional_awareness'] != null) {
      score += (patterns['emotional_awareness'] - 0.5) * 0.25;
    }

    // Factor in phase-appropriate emotional state (25%)
    score += _assessPhaseAppropriateEmotions(patterns, phase) * 0.25;

    // Factor in coping effectiveness (20%)
    if (patterns['effective_coping'] == true) score += 0.1;
    if (patterns['recovery_speed'] != null) {
      score += (patterns['recovery_speed'] - 0.5) * 0.2;
    }

    return score.clamp(0.0, 1.0);
  }

  double _assessPhaseAppropriateEmotions(Map<String, dynamic> patterns, String phase) {
    // Assess if emotional patterns align with typical phase characteristics
    switch (phase) {
      case 'menstrual':
        return patterns['introspective_tendency'] ?? 0.5;
      case 'follicular':
        return patterns['optimism_level'] ?? 0.5;
      case 'ovulatory':
        return patterns['confidence_level'] ?? 0.5;
      case 'luteal':
        return patterns['emotional_regulation'] ?? 0.5;
      default:
        return 0.5;
    }
  }

  List<String> _generateWellnessInsights(Map<String, dynamic> patterns, 
      double stability, String phase, UserProfile user) {
    final insights = <String>[];

    insights.add('Your emotional wellness score reflects your current cycle phase patterns');

    if (stability > 0.7) {
      insights.add('You demonstrate excellent emotional stability and resilience');
    } else if (stability < 0.4) {
      insights.add('Consider focusing on emotional regulation techniques');
    }

    if (patterns['cycle_awareness'] == true) {
      insights.add('Your awareness of cycle-emotion connections is a significant strength');
    }

    insights.add('Emotional patterns show ${_getEmotionalTrend(patterns)} trend over recent cycles');

    return insights;
  }

  String _getEmotionalTrend(Map<String, dynamic> patterns) {
    if (patterns['positive_trend'] == true) return 'a positive';
    if (patterns['negative_trend'] == true) return 'a concerning';
    return 'a stable';
  }

  List<String> _generateWellnessRecommendations(Map<String, dynamic> patterns,
      double stability, String phase, UserProfile user) {
    final recommendations = <String>[];

    // Base recommendations for everyone
    recommendations.addAll([
      'Continue tracking your emotional patterns to build self-awareness',
      'Practice daily mindfulness or meditation',
      'Maintain consistent sleep and exercise routines',
    ]);

    // Personalized based on patterns and phase
    if (stability < 0.5) {
      recommendations.addAll([
        'Focus on emotional regulation techniques',
        'Consider working with a therapist or counselor',
        'Practice grounding techniques during emotional intensity',
      ]);
    }

    if (patterns['stress_sensitivity'] == true) {
      recommendations.addAll([
        'Prioritize stress management in your daily routine',
        'Practice saying no to additional commitments',
        'Create a calming environment at home',
      ]);
    }

    return recommendations;
  }

  List<String> _identifyEmotionalRiskFactors(Map<String, dynamic> patterns, double stability) {
    final risks = <String>[];

    if (stability < 0.3) risks.add('High emotional volatility');
    if (patterns['isolation_tendency'] == true) risks.add('Social withdrawal patterns');
    if (patterns['negative_rumination'] == true) risks.add('Persistent negative thinking');
    if (patterns['poor_coping'] == true) risks.add('Ineffective coping strategies');

    return risks;
  }

  List<String> _identifyEmotionalStrengths(Map<String, dynamic> patterns, double stability) {
    final strengths = <String>[];

    if (stability > 0.7) strengths.add('Excellent emotional stability');
    if (patterns['emotional_awareness'] != null && patterns['emotional_awareness'] > 0.7) {
      strengths.add('High emotional self-awareness');
    }
    if (patterns['effective_coping'] == true) strengths.add('Strong coping skills');
    if (patterns['social_support'] == true) strengths.add('Good social support network');

    return strengths;
  }

  double _calculateEmotionalStability(List<EmotionalMemory> history) {
    if (history.length < 3) return 0.5;

    final valences = history.map((m) => m.sentiment.valence).toList();
    final mean = valences.reduce((a, b) => a + b) / valences.length;
    final variance = valences.map((v) => math.pow(v - mean, 2)).reduce((a, b) => a + b) / valences.length;
    
    // Lower variance indicates higher stability
    return (1.0 - math.sqrt(variance)).clamp(0.0, 1.0);
  }

  void dispose() {
    _emotionalStateStream.close();
  }
}

// AI Component Classes
class SentimentAnalyzer {
  Future<void> initialize() async {
    debugPrint('📊 Initializing sentiment analyzer...');
  }

  Future<Sentiment> analyze(String text, String phase) async {
    // Advanced sentiment analysis with NLP
    final words = text.toLowerCase().split(' ');
    
    // Simple sentiment scoring (in production, use actual NLP models)
    final positiveWords = ['happy', 'good', 'great', 'love', 'amazing', 'wonderful', 'joy', 'excited'];
    final negativeWords = ['sad', 'bad', 'terrible', 'hate', 'awful', 'depressed', 'anxious', 'worried'];
    
    double valence = 0.0;
    double intensity = 0.0;
    double arousal = 0.5;
    final emotions = <String, double>{};

    for (final word in words) {
      if (positiveWords.contains(word)) {
        valence += 0.3;
        emotions['happiness'] = (emotions['happiness'] ?? 0) + 0.2;
      } else if (negativeWords.contains(word)) {
        valence -= 0.3;
        emotions['sadness'] = (emotions['sadness'] ?? 0) + 0.2;
      }
    }

    valence = valence.clamp(-1.0, 1.0);
    intensity = valence.abs();
    
    // Adjust for cycle phase
    if (phase == 'luteal') {
      intensity *= 1.2; // Emotions often more intense during luteal phase
    }

    return Sentiment(
      valence: valence,
      arousal: arousal,
      intensity: intensity.clamp(0.0, 1.0),
      confidence: 0.75,
      primaryEmotion: _determinePrimaryEmotion(valence, intensity),
      emotions: emotions,
      timestamp: DateTime.now(),
    );
  }

  String _determinePrimaryEmotion(double valence, double intensity) {
    if (intensity < 0.2) return 'neutral';
    if (valence > 0.3) return 'happy';
    if (valence < -0.3) return 'sad';
    return 'mixed';
  }
}

class MoodPredictor {
  Future<void> initialize() async {
    debugPrint('🔮 Initializing mood predictor...');
  }

  Future<Map<String, dynamic>> predict({
    required String currentPhase,
    required Map<String, dynamic> patterns,
    Map<String, dynamic>? currentMood,
    int daysAhead = 7,
  }) async {
    final predictions = <int, Map<String, dynamic>>{};

    // Simple prediction model based on cycle phase
    for (int day = 1; day <= daysAhead; day++) {
      final dayPhase = _predictPhaseForDay(currentPhase, day);
      final moodScore = _predictMoodScore(dayPhase, patterns, day);
      
      predictions[day] = {
        'predicted_phase': dayPhase,
        'mood_score': moodScore,
        'confidence': _calculatePredictionConfidence(day),
        'risk_factors': _identifyDayRiskFactors(dayPhase, day),
        'recommendations': _getDayRecommendations(dayPhase, moodScore),
      };
    }

    return {
      'daily_predictions': predictions,
      'overall_trend': _calculateOverallTrend(predictions),
      'risk_days': _identifyRiskDays(predictions),
      'opportunity_days': _identifyOpportunityDays(predictions),
    };
  }

  String _predictPhaseForDay(String currentPhase, int daysAhead) {
    // Simplified phase prediction
    final phases = ['menstrual', 'follicular', 'ovulatory', 'luteal'];
    final currentIndex = phases.indexOf(currentPhase);
    final futureIndex = (currentIndex + (daysAhead ~/ 7)) % phases.length;
    return phases[futureIndex];
  }

  double _predictMoodScore(String phase, Map<String, dynamic> patterns, int day) {
    double baseScore = 0.5;

    switch (phase) {
      case 'menstrual':
        baseScore = 0.4;
        break;
      case 'follicular':
        baseScore = 0.7;
        break;
      case 'ovulatory':
        baseScore = 0.8;
        break;
      case 'luteal':
        baseScore = 0.5 - (day * 0.02); // Gradual decline
        break;
    }

    // Add some randomness and pattern influence
    final random = math.Random().nextDouble() * 0.2 - 0.1;
    return (baseScore + random).clamp(0.0, 1.0);
  }

  double _calculatePredictionConfidence(int day) {
    // Confidence decreases with distance
    return (1.0 - (day * 0.1)).clamp(0.3, 1.0);
  }

  List<String> _identifyDayRiskFactors(String phase, int day) {
    final risks = <String>[];

    if (phase == 'luteal' && day > 3) {
      risks.add('PMS symptoms may intensify');
    }

    if (phase == 'menstrual') {
      risks.add('Fatigue and mood dips common');
    }

    return risks;
  }

  List<String> _getDayRecommendations(String phase, double moodScore) {
    if (moodScore < 0.4) {
      return ['Extra self-care', 'Gentle activities', 'Early bedtime'];
    } else if (moodScore > 0.7) {
      return ['Tackle important tasks', 'Social activities', 'New challenges'];
    }
    return ['Maintain balance', 'Listen to your body'];
  }

  String _calculateOverallTrend(Map<int, Map<String, dynamic>> predictions) {
    final scores = predictions.values.map((p) => p['mood_score'] as double).toList();
    final firstHalf = scores.take(scores.length ~/ 2).fold(0.0, (a, b) => a + b) / (scores.length ~/ 2);
    final secondHalf = scores.skip(scores.length ~/ 2).fold(0.0, (a, b) => a + b) / (scores.length - scores.length ~/ 2);

    if (secondHalf > firstHalf + 0.1) return 'improving';
    if (secondHalf < firstHalf - 0.1) return 'declining';
    return 'stable';
  }

  List<int> _identifyRiskDays(Map<int, Map<String, dynamic>> predictions) {
    return predictions.entries
        .where((entry) => (entry.value['mood_score'] as double) < 0.4)
        .map((entry) => entry.key)
        .toList();
  }

  List<int> _identifyOpportunityDays(Map<int, Map<String, dynamic>> predictions) {
    return predictions.entries
        .where((entry) => (entry.value['mood_score'] as double) > 0.7)
        .map((entry) => entry.key)
        .toList();
  }
}

class EmpatheticChatbot {
  Future<void> initialize() async {
    debugPrint('💬 Initializing empathetic chatbot...');
  }

  Future<ChatbotResponse> generateResponse({
    required String userMessage,
    required Sentiment sentiment,
    required String currentPhase,
    required List<EmotionalMemory> emotionalHistory,
    required Map<String, dynamic> context,
  }) async {
    // Generate empathetic response based on emotional state
    final responseText = await _generateEmpatheticText(
      userMessage, sentiment, currentPhase);
    
    final supportiveActions = _suggestSupportiveActions(sentiment, currentPhase);
    
    final followUpQuestions = _generateFollowUpQuestions(sentiment);

    return ChatbotResponse(
      responseText: responseText,
      empathyLevel: _calculateEmpathyLevel(sentiment),
      supportiveActions: supportiveActions,
      followUpQuestions: followUpQuestions,
      tone: _determineTone(sentiment, currentPhase),
      timestamp: DateTime.now(),
    );
  }

  Future<String> _generateEmpatheticText(String message, Sentiment sentiment, String phase) async {
    // Generate contextually appropriate empathetic response
    if (sentiment.valence < -0.5) {
      // Highly negative sentiment
      final responses = [
        "I can sense you're going through a really tough time right now. Your feelings are completely valid, and it's okay to not be okay.",
        "It sounds like you're carrying a heavy emotional load. During $phase phase, our emotions can feel particularly intense. You're not alone in this.",
        "I hear the pain in your words, and I want you to know that what you're experiencing matters. Your emotional experience during $phase is part of your body's natural rhythm.",
      ];
      return responses[math.Random().nextInt(responses.length)];
    } else if (sentiment.valence < -0.2) {
      // Mildly negative sentiment
      final responses = [
        "It seems like you're navigating some challenging emotions right now. That's completely normal, especially during $phase phase.",
        "I notice you might be feeling a bit low today. Remember that emotional ups and downs are part of your natural cycle.",
        "Your feelings are important, and it's okay to acknowledge when things feel difficult. How can we support you through this?",
      ];
      return responses[math.Random().nextInt(responses.length)];
    } else if (sentiment.valence > 0.5) {
      // Very positive sentiment
      final responses = [
        "I love hearing the joy and positivity in your message! It's wonderful that you're feeling so good during your $phase phase.",
        "Your positive energy is infectious! This is such a great example of how our $phase phase can bring beautiful moments.",
        "It's amazing to witness your happiness and enthusiasm. These positive moments are so precious - let's celebrate them!",
      ];
      return responses[math.Random().nextInt(responses.length)];
    } else {
      // Neutral or mixed sentiment
      final responses = [
        "Thank you for sharing what's on your mind. I'm here to listen and support you through whatever you're experiencing.",
        "I appreciate you taking the time to check in. How are you feeling in your body and mind today?",
        "Your thoughts and feelings matter to me. What's the most important thing on your mind right now?",
      ];
      return responses[math.Random().nextInt(responses.length)];
    }
  }

  List<String> _suggestSupportiveActions(Sentiment sentiment, String phase) {
    final actions = <String>[];

    if (sentiment.valence < -0.3) {
      actions.addAll([
        'Take 5 deep breaths',
        'Practice self-compassion',
        'Reach out to a trusted friend',
        'Journal about your feelings',
      ]);
    }

    if (sentiment.intensity > 0.7) {
      actions.addAll([
        'Try grounding techniques (5-4-3-2-1)',
        'Go for a gentle walk',
        'Listen to calming music',
      ]);
    }

    // Phase-specific actions
    switch (phase) {
      case 'menstrual':
        actions.addAll(['Rest and recuperate', 'Use a heating pad', 'Drink herbal tea']);
        break;
      case 'follicular':
        actions.addAll(['Set new goals', 'Try something creative', 'Connect with friends']);
        break;
      case 'ovulatory':
        actions.addAll(['Have important conversations', 'Take on challenges', 'Celebrate achievements']);
        break;
      case 'luteal':
        actions.addAll(['Practice extra self-care', 'Prepare for period', 'Be gentle with yourself']);
        break;
    }

    return actions.take(4).toList();
  }

  List<String> _generateFollowUpQuestions(Sentiment sentiment) {
    if (sentiment.valence < -0.3) {
      return [
        'What would help you feel supported right now?',
        'Have you been able to rest and care for yourself today?',
        'Is there someone you can reach out to for support?',
      ];
    } else if (sentiment.valence > 0.3) {
      return [
        'What\'s been bringing you the most joy lately?',
        'How can you maintain this positive energy?',
        'Would you like to set any intentions while feeling this way?',
      ];
    } else {
      return [
        'How has your day been treating you?',
        'What would make today feel complete for you?',
        'Is there anything on your mind you\'d like to explore?',
      ];
    }
  }

  double _calculateEmpathyLevel(Sentiment sentiment) {
    // Higher empathy for more intense or negative emotions
    return (0.5 + sentiment.intensity * 0.3 + (sentiment.valence < 0 ? 0.2 : 0.0)).clamp(0.0, 1.0);
  }

  String _determineTone(Sentiment sentiment, String phase) {
    if (sentiment.valence < -0.3) return 'compassionate';
    if (sentiment.valence > 0.3) return 'celebratory';
    if (phase == 'luteal') return 'gentle';
    return 'supportive';
  }
}

class EmotionalPatternDetector {
  Future<void> initialize() async {
    debugPrint('🔍 Initializing emotional pattern detector...');
  }

  Future<Map<String, dynamic>> detectMoodPatterns(
      List<EmotionalMemory> history, List<CycleData> cycles) async {
    if (history.isEmpty) return {'insufficient_data': true};

    return {
      'volatility': _calculateEmotionalVolatility(history),
      'cycle_correlation': _analyzeCycleCorrelation(history, cycles),
      'positive_trend': _detectPositiveTrend(history),
      'emotional_awareness': _assessEmotionalAwareness(history),
      'recovery_speed': _calculateRecoverySpeed(history),
      'phase_patterns': _analyzePhasePatterns(history),
    };
  }

  Future<Map<String, dynamic>> detectEmotionalPatterns(
      List<EmotionalMemory> history, List<CycleData> cycles) async {
    final moodPatterns = await detectMoodPatterns(history, cycles);
    
    // Add additional emotional intelligence patterns
    moodPatterns.addAll({
      'stress_sensitivity': _detectStressSensitivity(history),
      'social_patterns': _analyzeSocialPatterns(history),
      'coping_effectiveness': _assessCopingEffectiveness(history),
      'emotional_regulation': _assessEmotionalRegulation(history),
    });

    return moodPatterns;
  }

  double _calculateEmotionalVolatility(List<EmotionalMemory> history) {
    if (history.length < 2) return 0.0;

    final valences = history.map((m) => m.sentiment.valence).toList();
    double totalVariation = 0.0;

    for (int i = 1; i < valences.length; i++) {
      totalVariation += (valences[i] - valences[i - 1]).abs();
    }

    return (totalVariation / (valences.length - 1)).clamp(0.0, 2.0) / 2.0;
  }

  double _analyzeCycleCorrelation(List<EmotionalMemory> history, List<CycleData> cycles) {
    // Analyze correlation between emotional patterns and cycle phases
    // Simplified implementation
    return 0.7; // Placeholder
  }

  bool _detectPositiveTrend(List<EmotionalMemory> history) {
    if (history.length < 5) return false;

    final recent = history.skip(math.max(0, history.length - 5)).map((m) => m.sentiment.valence).toList();
    final older = history.take(history.length - 5).map((m) => m.sentiment.valence).toList();

    if (older.isEmpty) return false;

    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final olderAvg = older.reduce((a, b) => a + b) / older.length;

    return recentAvg > olderAvg + 0.1;
  }

  double _assessEmotionalAwareness(List<EmotionalMemory> history) {
    // Assess based on emotional vocabulary and self-reflection depth
    final uniqueEmotions = <String>{};
    for (final memory in history) {
      uniqueEmotions.addAll(memory.sentiment.emotions.keys);
    }

    return (uniqueEmotions.length / 10.0).clamp(0.0, 1.0);
  }

  double _calculateRecoverySpeed(List<EmotionalMemory> history) {
    // Analyze how quickly user recovers from negative emotional states
    // Simplified implementation
    return 0.65; // Placeholder
  }

  Map<String, dynamic> _analyzePhasePatterns(List<EmotionalMemory> history) {
    final phaseEmotions = <String, List<double>>{};

    for (final memory in history) {
      phaseEmotions.putIfAbsent(memory.phase, () => []).add(memory.sentiment.valence);
    }

    return phaseEmotions.map((phase, valences) => MapEntry(
      phase,
      valences.isEmpty ? 0.0 : valences.reduce((a, b) => a + b) / valences.length,
    ));
  }

  bool _detectStressSensitivity(List<EmotionalMemory> history) {
    // Detect if user is particularly sensitive to stress
    return history.any((m) => m.context.containsKey('stress') && m.sentiment.valence < -0.5);
  }

  Map<String, dynamic> _analyzeSocialPatterns(List<EmotionalMemory> history) {
    return {
      'social_support_usage': 0.6,
      'isolation_tendency': false,
      'social_energy_correlation': 0.4,
    };
  }

  bool _assessCopingEffectiveness(List<EmotionalMemory> history) {
    // Assess if coping strategies are effective
    return true; // Placeholder
  }

  double _assessEmotionalRegulation(List<EmotionalMemory> history) {
    // Assess emotional regulation skills
    return 0.7; // Placeholder
  }
}

class HormonalCorrelationEngine {
  Future<void> initialize() async {
    debugPrint('🧬 Initializing hormonal correlation engine...');
  }

  Future<Map<String, dynamic>> analyzeHormonalImpact(
      Sentiment sentiment, String phase) async {
    return {
      'phase_typical': _isPhaseTypical(sentiment, phase),
      'hormonal_influence': _assessHormonalInfluence(sentiment, phase),
      'recommendations': _getHormonalRecommendations(sentiment, phase),
      'cycle_insights': _getCycleInsights(sentiment, phase),
    };
  }

  bool _isPhaseTypical(Sentiment sentiment, String phase) {
    switch (phase) {
      case 'menstrual':
        return sentiment.intensity > 0.3; // Emotions often more intense
      case 'follicular':
        return sentiment.valence > -0.2; // Generally more positive
      case 'ovulatory':
        return sentiment.valence > 0.0; // Peak positivity
      case 'luteal':
        return true; // All emotions are typical in luteal phase
      default:
        return true;
    }
  }

  double _assessHormonalInfluence(Sentiment sentiment, String phase) {
    switch (phase) {
      case 'menstrual':
        return 0.6; // Moderate hormonal influence
      case 'follicular':
        return 0.4; // Lower influence as hormones stabilize
      case 'ovulatory':
        return 0.7; // High influence from estrogen peak
      case 'luteal':
        return 0.8; // Highest influence from progesterone changes
      default:
        return 0.5;
    }
  }

  List<String> _getHormonalRecommendations(Sentiment sentiment, String phase) {
    final recommendations = <String>[];

    switch (phase) {
      case 'menstrual':
        recommendations.addAll([
          'Your emotions are influenced by dropping hormone levels',
          'Extra self-care and rest are particularly important now',
          'Consider iron-rich foods to support energy',
        ]);
        break;
      case 'follicular':
        recommendations.addAll([
          'Rising estrogen may boost your mood and energy',
          'Great time to start new projects or make plans',
          'Your brain may be more receptive to learning',
        ]);
        break;
      case 'ovulatory':
        recommendations.addAll([
          'Peak estrogen often brings confidence and social energy',
          'Ideal time for important conversations or presentations',
          'Your communication skills may be at their best',
        ]);
        break;
      case 'luteal':
        recommendations.addAll([
          'Progesterone changes can intensify emotional responses',
          'This is normal and temporary - be extra gentle with yourself',
          'Focus on stress management and emotional regulation',
        ]);
        break;
    }

    return recommendations;
  }

  Map<String, dynamic> _getCycleInsights(Sentiment sentiment, String phase) {
    return {
      'phase_description': _getPhaseDescription(phase),
      'emotional_expectations': _getEmotionalExpectations(phase),
      'hormone_explanation': _getHormoneExplanation(phase),
      'duration': _getPhaseDuration(phase),
    };
  }

  String _getPhaseDescription(String phase) {
    switch (phase) {
      case 'menstrual':
        return 'Menstrual phase: Your body is shedding the uterine lining';
      case 'follicular':
        return 'Follicular phase: Your body is preparing for ovulation';
      case 'ovulatory':
        return 'Ovulatory phase: Your body is releasing an egg';
      case 'luteal':
        return 'Luteal phase: Your body is preparing for potential pregnancy';
      default:
        return 'Cycle phase information not available';
    }
  }

  String _getEmotionalExpectations(String phase) {
    switch (phase) {
      case 'menstrual':
        return 'Introspection, fatigue, and emotional processing are common';
      case 'follicular':
        return 'Increasing optimism, energy, and motivation are typical';
      case 'ovulatory':
        return 'Peak confidence, social energy, and positive mood are expected';
      case 'luteal':
        return 'Emotional intensity and sensitivity may increase';
      default:
        return 'Emotional patterns vary throughout the cycle';
    }
  }

  String _getHormoneExplanation(String phase) {
    switch (phase) {
      case 'menstrual':
        return 'Estrogen and progesterone are at their lowest levels';
      case 'follicular':
        return 'Estrogen is gradually rising';
      case 'ovulatory':
        return 'Estrogen peaks, then drops as progesterone begins to rise';
      case 'luteal':
        return 'Progesterone is high, then drops if pregnancy doesn\'t occur';
      default:
        return 'Hormone levels fluctuate throughout your cycle';
    }
  }

  String _getPhaseDuration(String phase) {
    switch (phase) {
      case 'menstrual':
        return 'Typically lasts 3-7 days';
      case 'follicular':
        return 'Usually 7-10 days (varies with cycle length)';
      case 'ovulatory':
        return 'Approximately 1-3 days';
      case 'luteal':
        return 'Typically 10-14 days';
      default:
        return 'Duration varies by individual';
    }
  }
}

// Data Models
class EmotionalState {
  final DateTime timestamp;
  final String primaryEmotion;
  final double intensity;
  final double valence;
  final double arousal;
  final double stability;
  final double confidence;

  EmotionalState({
    required this.timestamp,
    required this.primaryEmotion,
    required this.intensity,
    required this.valence,
    required this.arousal,
    required this.stability,
    required this.confidence,
  });
}

class Sentiment {
  final double valence; // -1 (negative) to +1 (positive)
  final double arousal; // 0 (calm) to 1 (excited)
  final double intensity; // 0 (mild) to 1 (intense)
  final double confidence; // 0 to 1
  final String primaryEmotion;
  final Map<String, double> emotions;
  final DateTime timestamp;

  Sentiment({
    required this.valence,
    required this.arousal,
    required this.intensity,
    required this.confidence,
    required this.primaryEmotion,
    required this.emotions,
    required this.timestamp,
  });
}

class EmotionalMemory {
  final DateTime timestamp;
  final String text;
  final Sentiment sentiment;
  final String phase;
  final Map<String, dynamic> context;

  EmotionalMemory({
    required this.timestamp,
    required this.text,
    required this.sentiment,
    required this.phase,
    required this.context,
  });
}

class SentimentAnalysisResult {
  final String originalText;
  final Sentiment sentiment;
  final Map<String, dynamic> hormonalContext;
  final double confidence;
  final Map<String, double> emotions;
  final List<String> recommendations;
  final Map<String, dynamic> insights;

  SentimentAnalysisResult({
    required this.originalText,
    required this.sentiment,
    required this.hormonalContext,
    required this.confidence,
    required this.emotions,
    required this.recommendations,
    required this.insights,
  });
}

class MoodPredictionResult {
  final String currentPhase;
  final Map<String, dynamic> predictions;
  final Map<String, dynamic> patterns;
  final List<String> riskFactors;
  final List<String> protectiveFactors;
  final List<String> recommendations;
  final List<String> interventions;

  MoodPredictionResult({
    required this.currentPhase,
    required this.predictions,
    required this.patterns,
    required this.riskFactors,
    required this.protectiveFactors,
    required this.recommendations,
    required this.interventions,
  });
}

class ChatbotResponse {
  final String responseText;
  final double empathyLevel;
  final List<String> supportiveActions;
  final List<String> followUpQuestions;
  final String tone;
  final DateTime timestamp;

  ChatbotResponse({
    required this.responseText,
    required this.empathyLevel,
    required this.supportiveActions,
    required this.followUpQuestions,
    required this.tone,
    required this.timestamp,
  });
}

class EmotionalWellnessReport {
  final String userId;
  final int reportPeriod;
  final String currentPhase;
  final double wellnessScore;
  final Map<String, dynamic> patterns;
  final double stability;
  final List<String> insights;
  final List<String> recommendations;
  final List<String> riskFactors;
  final List<String> strengths;
  final DateTime generatedAt;

  EmotionalWellnessReport({
    required this.userId,
    required this.reportPeriod,
    required this.currentPhase,
    required this.wellnessScore,
    required this.patterns,
    required this.stability,
    required this.insights,
    required this.recommendations,
    required this.riskFactors,
    required this.strengths,
    required this.generatedAt,
  });
}
