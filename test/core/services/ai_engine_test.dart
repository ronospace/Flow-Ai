import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flow_ai/core/services/ai_engine.dart';
import 'package:flow_ai/core/services/ai_chat_service.dart';
import 'package:flow_ai/core/services/enhanced_ai_chat_service.dart';
import 'package:flow_ai/core/models/ai_insights.dart';
import 'package:flow_ai/core/models/cycle_data.dart';
import 'package:flow_ai/core/models/symptom_analysis.dart';

// Generate mocks
@GenerateMocks([AIEngine, AIChatService])
import 'ai_engine_test.mocks.dart';

void main() {
  group('AIEngine Tests', () {
    late AIEngine aiEngine;
    late MockAIChatService mockChatService;

    setUp(() {
      mockChatService = MockAIChatService();
      aiEngine = AIEngine();
    });

    test('should initialize AI engine successfully', () async {
      // Arrange & Act
      await aiEngine.initialize();

      // Assert
      expect(aiEngine.isInitialized, true);
    });

    test('should generate period predictions correctly', () async {
      // Arrange
      final cycleData = CycleData(
        userId: 'test_user',
        cycleLength: 28,
        periodLength: 5,
        lastPeriodStart: DateTime.now().subtract(const Duration(days: 25)),
        symptoms: [],
        mood: 'normal',
        flow: 'medium',
      );

      // Act
      final prediction = await aiEngine.predictNextPeriod(cycleData);

      // Assert
      expect(prediction, isNotNull);
      expect(prediction.nextPeriodDate, isA<DateTime>());
      expect(prediction.confidence, greaterThan(0.0));
      expect(prediction.confidence, lessThanOrEqualTo(1.0));
    });

    test('should analyze symptoms with AI insights', () async {
      // Arrange
      final symptoms = ['cramping', 'headache', 'mood_swings'];
      final cycleDay = 14;

      // Act
      final analysis = await aiEngine.analyzeSymptoms(symptoms, cycleDay);

      // Assert
      expect(analysis, isNotNull);
      expect(analysis.insights, isNotEmpty);
      expect(analysis.severity, isA<String>());
      expect(analysis.recommendations, isNotEmpty);
    });

    test('should generate personalized insights', () async {
      // Arrange
      final userHistory = CycleData(
        userId: 'test_user',
        cycleLength: 30,
        periodLength: 4,
        lastPeriodStart: DateTime.now().subtract(const Duration(days: 15)),
        symptoms: ['bloating'],
        mood: 'irritable',
        flow: 'light',
      );

      // Act
      final insights = await aiEngine.generatePersonalizedInsights(userHistory);

      // Assert
      expect(insights, isNotNull);
      expect(insights.personalizedTips, isNotEmpty);
      expect(insights.healthScore, greaterThan(0));
      expect(insights.healthScore, lessThanOrEqualTo(100));
    });

    test('should handle invalid data gracefully', () async {
      // Arrange
      final invalidCycleData = CycleData(
        userId: '',
        cycleLength: -1,
        periodLength: 0,
        lastPeriodStart: DateTime.now().add(const Duration(days: 10)), // Future date
        symptoms: [],
        mood: '',
        flow: '',
      );

      // Act & Assert
      expect(
        () => aiEngine.predictNextPeriod(invalidCycleData),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should cache predictions for performance', () async {
      // Arrange
      final cycleData = CycleData(
        userId: 'cache_test_user',
        cycleLength: 28,
        periodLength: 5,
        lastPeriodStart: DateTime.now().subtract(const Duration(days: 20)),
        symptoms: [],
        mood: 'normal',
        flow: 'medium',
      );

      // Act
      final firstPrediction = await aiEngine.predictNextPeriod(cycleData);
      final secondPrediction = await aiEngine.predictNextPeriod(cycleData);

      // Assert
      expect(firstPrediction.nextPeriodDate, equals(secondPrediction.nextPeriodDate));
      expect(firstPrediction.confidence, equals(secondPrediction.confidence));
    });
  });

  group('Enhanced AI Chat Service Tests', () {
    late EnhancedAIChatService chatService;

    setUp(() {
      chatService = EnhancedAIChatService();
    });

    test('should initialize chat service with memory', () async {
      // Act
      await chatService.initialize();

      // Assert
      expect(chatService.isInitialized, true);
      expect(chatService.hasMemory, true);
    });

    test('should maintain conversation context', () async {
      // Arrange
      await chatService.initialize();
      const userId = 'test_user';
      
      // Act
      await chatService.sendMessage(userId, 'Hello, I have period cramps');
      final response1 = await chatService.sendMessage(userId, 'What should I do?');
      
      // Assert
      expect(response1, contains('cramps'));
      expect(chatService.getConversationLength(userId), greaterThan(1));
    });

    test('should provide personalized health advice', () async {
      // Arrange
      await chatService.initialize();
      const userId = 'health_advice_user';
      
      // Act
      final response = await chatService.getHealthAdvice(userId, 'irregular periods');
      
      // Assert
      expect(response, isNotEmpty);
      expect(response, contains('irregular'));
      expect(response.length, greaterThan(50)); // Meaningful advice
    });

    test('should handle multiple concurrent conversations', () async {
      // Arrange
      await chatService.initialize();
      const user1 = 'user1';
      const user2 = 'user2';
      
      // Act
      await chatService.sendMessage(user1, 'I track my period daily');
      await chatService.sendMessage(user2, 'I have mood swings');
      
      final context1 = chatService.getConversationContext(user1);
      final context2 = chatService.getConversationContext(user2);
      
      // Assert
      expect(context1, contains('period'));
      expect(context2, contains('mood'));
      expect(context1, isNot(equals(context2)));
    });

    test('should clear conversation memory when requested', () async {
      // Arrange
      await chatService.initialize();
      const userId = 'memory_clear_user';
      
      await chatService.sendMessage(userId, 'Test message');
      expect(chatService.getConversationLength(userId), equals(1));
      
      // Act
      chatService.clearConversationMemory(userId);
      
      // Assert
      expect(chatService.getConversationLength(userId), equals(0));
    });
  });

  group('AI Insights Generation Tests', () {
    late AIEngine aiEngine;

    setUp(() {
      aiEngine = AIEngine();
    });

    test('should generate fertility window insights', () async {
      // Arrange
      final cycleData = CycleData(
        userId: 'fertility_user',
        cycleLength: 28,
        periodLength: 5,
        lastPeriodStart: DateTime.now().subtract(const Duration(days: 10)),
        symptoms: [],
        mood: 'normal',
        flow: 'medium',
      );

      // Act
      final insights = await aiEngine.generateFertilityInsights(cycleData);

      // Assert
      expect(insights, isNotNull);
      expect(insights.fertilityWindow, isNotNull);
      expect(insights.ovulationDate, isA<DateTime>());
      expect(insights.fertilityProbability, greaterThanOrEqualTo(0.0));
      expect(insights.fertilityProbability, lessThanOrEqualTo(1.0));
    });

    test('should detect cycle patterns and anomalies', () async {
      // Arrange
      final historicalData = List.generate(12, (index) => CycleData(
        userId: 'pattern_user',
        cycleLength: 28 + (index % 3), // Variable cycle length
        periodLength: 4 + (index % 2), // Variable period length
        lastPeriodStart: DateTime.now().subtract(Duration(days: 28 * (12 - index))),
        symptoms: index % 4 == 0 ? ['cramping'] : [],
        mood: index % 3 == 0 ? 'irritable' : 'normal',
        flow: 'medium',
      ));

      // Act
      final patterns = await aiEngine.detectCyclePatterns(historicalData);

      // Assert
      expect(patterns, isNotNull);
      expect(patterns.averageCycleLength, greaterThan(0));
      expect(patterns.cycleRegularity, isA<double>());
      expect(patterns.detectedAnomalies, isA<List>());
    });

    test('should provide mood and symptom correlations', () async {
      // Arrange
      final trackingData = List.generate(30, (index) => {
        'date': DateTime.now().subtract(Duration(days: index)),
        'mood': index % 7 < 2 ? 'sad' : 'happy',
        'symptoms': index % 5 == 0 ? ['headache'] : [],
        'cycleDay': (index % 28) + 1,
      });

      // Act
      final correlations = await aiEngine.analyzeMoodSymptomCorrelations(trackingData);

      // Assert
      expect(correlations, isNotNull);
      expect(correlations.moodPatterns, isNotEmpty);
      expect(correlations.symptomTriggers, isA<Map>());
      expect(correlations.recommendations, isNotEmpty);
    });
  });
}
