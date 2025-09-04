import 'package:flutter_test/flutter_test.dart';
import 'package:flow_ai/core/models/user.dart';
import 'package:flow_ai/core/models/cycle_data.dart';
import 'package:flow_ai/core/models/symptom_tracking.dart';
import 'package:flow_ai/core/models/daily_tracking_data.dart';
import 'package:flow_ai/core/models/auth_result.dart';
import 'package:flow_ai/core/models/period_prediction.dart';
import 'package:flow_ai/core/ai/period_prediction_engine.dart';
import 'package:flow_ai/core/ai/emotional_intelligence_engine.dart';
import 'package:flow_ai/core/utils/collection_extensions.dart';

void main() {
  group('User Model Tests', () {
    test('should create user with required fields', () {
      // Arrange & Act
      final user = User(
        id: 'test_123',
        email: 'test@example.com',
        displayName: 'Test User',
      );

      // Assert
      expect(user.id, equals('test_123'));
      expect(user.email, equals('test@example.com'));
      expect(user.displayName, equals('Test User'));
      expect(user.createdAt, isNotNull);
    });

    test('should convert user to/from JSON', () {
      // Arrange
      final user = User(
        id: 'json_test',
        email: 'json@test.com',
        displayName: 'JSON User',
      );

      // Act
      final json = user.toJson();
      final reconstructedUser = User.fromJson(json);

      // Assert
      expect(reconstructedUser.id, equals(user.id));
      expect(reconstructedUser.email, equals(user.email));
      expect(reconstructedUser.displayName, equals(user.displayName));
    });

    test('should validate email format', () {
      expect(User.isValidEmail('test@example.com'), true);
      expect(User.isValidEmail('user@domain.co.uk'), true);
      expect(User.isValidEmail('invalid-email'), false);
      expect(User.isValidEmail('user@'), false);
      expect(User.isValidEmail(''), false);
    });
  });

  group('CycleData Model Tests', () {
    test('should create cycle data with valid parameters', () {
      // Arrange & Act
      final cycleData = CycleData(
        id: 'cycle_123',
        userId: 'user_123',
        cycleLength: 28,
        periodLength: 5,
        symptoms: ['cramping', 'headache'],
        mood: 'normal',
        flow: 'medium',
      );

      // Assert
      expect(cycleData.id, equals('cycle_123'));
      expect(cycleData.cycleLength, equals(28));
      expect(cycleData.symptoms, contains('cramping'));
      expect(cycleData.mood, equals('normal'));
    });

    test('should convert to/from JSON correctly', () {
      // Arrange
      final cycleData = CycleData(
        id: 'json_cycle',
        userId: 'json_user',
        cycleLength: 30,
        periodLength: 4,
        symptoms: ['bloating'],
        mood: 'happy',
        flow: 'light',
      );

      // Act
      final json = cycleData.toJson();
      final reconstructed = CycleData.fromJson(json);

      // Assert
      expect(reconstructed.id, equals(cycleData.id));
      expect(reconstructed.cycleLength, equals(cycleData.cycleLength));
      expect(reconstructed.symptoms, equals(cycleData.symptoms));
    });

    test('should calculate cycle phase correctly', () {
      // Arrange
      final cycleData = CycleData(
        id: 'phase_test',
        userId: 'user_123',
        cycleLength: 28,
        periodLength: 5,
      );

      // Act & Assert
      expect(cycleData.getCyclePhase(1), equals('menstrual'));
      expect(cycleData.getCyclePhase(8), equals('follicular'));
      expect(cycleData.getCyclePhase(14), equals('ovulation'));
      expect(cycleData.getCyclePhase(21), equals('luteal'));
    });
  });

  group('SymptomTracking Model Tests', () {
    test('should create symptom tracking entry', () {
      // Arrange & Act
      final symptomTracking = SymptomTracking(
        id: 'symptom_123',
        userId: 'user_123',
        symptoms: ['cramping', 'headache', 'bloating'],
        severity: {'cramping': 8, 'headache': 6, 'bloating': 4},
        notes: 'Symptoms started in morning',
        cycleDay: 1,
      );

      // Assert
      expect(symptomTracking.symptoms.length, equals(3));
      expect(symptomTracking.severity['cramping'], equals(8));
      expect(symptomTracking.notes, contains('morning'));
    });

    test('should calculate average severity', () {
      // Arrange
      final symptomTracking = SymptomTracking(
        id: 'severity_test',
        userId: 'user_123',
        symptoms: ['symptom1', 'symptom2', 'symptom3'],
        severity: {'symptom1': 6, 'symptom2': 8, 'symptom3': 4},
        cycleDay: 1,
      );

      // Act
      final averageSeverity = symptomTracking.getAverageSeverity();

      // Assert
      expect(averageSeverity, equals(6.0));
    });
  });

  group('DailyTrackingData Model Tests', () {
    test('should create daily tracking data', () {
      // Arrange & Act
      final dailyData = DailyTrackingData(
        id: 'daily_123',
        uid: 'user_123',
        date: DateTime.now(),
        mood: 8,
        energy: 7,
        sleep: 6,
        exercise: true,
        water: 8,
        notes: 'Great day overall',
        cycleDay: 15,
      );

      // Assert
      expect(dailyData.mood, equals(8));
      expect(dailyData.exercise, true);
      expect(dailyData.water, equals(8));
      expect(dailyData.notes, contains('Great'));
    });

    test('should calculate wellness score', () {
      // Arrange
      final dailyData = DailyTrackingData(
        id: 'wellness_test',
        uid: 'user_123',
        date: DateTime.now(),
        mood: 8,
        energy: 7,
        sleep: 6,
        exercise: true,
        water: 8,
        cycleDay: 15,
      );

      // Act
      final wellnessScore = dailyData.calculateWellnessScore();

      // Assert
      expect(wellnessScore, greaterThan(6.0));
      expect(wellnessScore, lessThanOrEqualTo(10.0));
    });
  });

  group('AuthResult Model Tests', () {
    test('should create successful auth result', () {
      // Arrange
      final user = User(id: 'auth_user', email: 'auth@test.com');
      
      // Act
      final result = AuthResult.success(user: user);

      // Assert
      expect(result.isSuccess, true);
      expect(result.user, isNotNull);
      expect(result.user!.id, equals('auth_user'));
      expect(result.errorMessage, isNull);
    });

    test('should create failed auth result', () {
      // Act
      final result = AuthResult.failure(message: 'Invalid credentials');

      // Assert
      expect(result.isSuccess, false);
      expect(result.user, isNull);
      expect(result.errorMessage, equals('Invalid credentials'));
    });
  });

  group('PeriodPrediction Model Tests', () {
    test('should create period prediction with valid data', () {
      // Arrange & Act
      final prediction = PeriodPrediction(
        userId: 'prediction_user',
        nextPeriodDate: DateTime.now().add(const Duration(days: 7)),
        confidence: 0.85,
        cycleLength: 28,
        fertileWindow: [
          DateTime.now().add(const Duration(days: 10)),
          DateTime.now().add(const Duration(days: 14)),
        ],
        ovulationDate: DateTime.now().add(const Duration(days: 12)),
      );

      // Assert
      expect(prediction.confidence, equals(0.85));
      expect(prediction.cycleLength, equals(28));
      expect(prediction.fertileWindow.length, equals(2));
      expect(prediction.ovulationDate, isNotNull);
    });

    test('should validate prediction confidence', () {
      // Arrange & Act
      final prediction = PeriodPrediction(
        userId: 'validation_user',
        nextPeriodDate: DateTime.now().add(const Duration(days: 7)),
        confidence: 0.95,
        cycleLength: 28,
      );

      // Assert
      expect(prediction.isHighConfidence(), true);
      expect(prediction.confidence, greaterThan(0.8));
    });
  });

  group('Period Prediction Engine Tests', () {
    late PeriodPredictionEngine engine;

    setUp(() {
      engine = PeriodPredictionEngine();
    });

    test('should initialize prediction engine', () {
      expect(engine.isInitialized, false);
      engine.initialize();
      expect(engine.isInitialized, true);
    });

    test('should predict next period based on cycle data', () {
      // Arrange
      engine.initialize();
      final historicalData = [
        CycleData(
          id: 'hist_1',
          userId: 'predict_user',
          cycleLength: 28,
          periodLength: 5,
        ),
        CycleData(
          id: 'hist_2',
          userId: 'predict_user',
          cycleLength: 29,
          periodLength: 4,
        ),
      ];

      // Act
      final prediction = engine.predictNextPeriod(historicalData);

      // Assert
      expect(prediction, isNotNull);
      expect(prediction.nextPeriodDate, isA<DateTime>());
      expect(prediction.confidence, greaterThan(0.0));
      expect(prediction.confidence, lessThanOrEqualTo(1.0));
    });

    test('should calculate fertility window', () {
      // Arrange
      engine.initialize();
      final cycleLength = 28;

      // Act
      final fertilityWindow = engine.calculateFertilityWindow(cycleLength);

      // Assert
      expect(fertilityWindow.length, equals(6)); // Typically 6-day window
      expect(fertilityWindow.every((day) => day >= 8 && day <= 18), true);
    });
  });

  group('Emotional Intelligence Engine Tests', () {
    late EmotionalIntelligenceEngine engine;

    setUp(() {
      engine = EmotionalIntelligenceEngine();
    });

    test('should analyze mood patterns', () {
      // Arrange
      final moodData = [
        {'date': DateTime.now().subtract(const Duration(days: 1)), 'mood': 8},
        {'date': DateTime.now().subtract(const Duration(days: 2)), 'mood': 6},
        {'date': DateTime.now().subtract(const Duration(days: 3)), 'mood': 7},
      ];

      // Act
      final analysis = engine.analyzeMoodPatterns(moodData);

      // Assert
      expect(analysis, isNotNull);
      expect(analysis['averageMood'], isA<double>());
      expect(analysis['moodTrend'], isA<String>());
    });

    test('should provide emotional insights', () {
      // Arrange
      final currentMood = 6;
      const cyclePhase = 'luteal';

      // Act
      final insights = engine.generateEmotionalInsights(currentMood, cyclePhase);

      // Assert
      expect(insights, isNotNull);
      expect(insights.isNotEmpty, true);
      expect(insights, contains('luteal'));
    });
  });

  group('Collection Extensions Tests', () {
    test('should calculate safe average for numbers', () {
      // Test with integers
      expect([1, 2, 3, 4, 5].safeAverage(), equals(3.0));
      expect([10].safeAverage(), equals(10.0));
      expect(<int>[].safeAverage(), equals(0.0));
      
      // Test with doubles
      expect([1.5, 2.5, 3.5].safeAverage(), equals(2.5));
    });

    test('should find safe maximum and minimum', () {
      expect([1, 5, 3, 9, 2].safeMax(), equals(9));
      expect([1, 5, 3, 9, 2].safeMin(), equals(1));
      expect(<int>[].safeMax(), equals(0));
      expect(<int>[].safeMin(), equals(0));
    });

    test('should chunk list into groups', () {
      final list = [1, 2, 3, 4, 5, 6, 7, 8, 9];
      final chunks = list.chunk(3);
      
      expect(chunks.length, equals(3));
      expect(chunks[0], equals([1, 2, 3]));
      expect(chunks[1], equals([4, 5, 6]));
      expect(chunks[2], equals([7, 8, 9]));
    });

    test('should handle edge cases in chunking', () {
      final list = [1, 2, 3, 4, 5];
      final chunks = list.chunk(2);
      
      expect(chunks.length, equals(3));
      expect(chunks[0], equals([1, 2]));
      expect(chunks[1], equals([3, 4]));
      expect(chunks[2], equals([5])); // Remainder
    });

    test('should find unique items', () {
      final list = [1, 2, 2, 3, 3, 3, 4];
      final unique = list.unique();
      
      expect(unique.length, equals(4));
      expect(unique.toSet(), equals({1, 2, 3, 4}));
    });

    test('should find most frequent item', () {
      final list = ['a', 'b', 'a', 'c', 'a', 'b'];
      final mostFrequent = list.mostFrequent();
      
      expect(mostFrequent, equals('a'));
    });

    test('should safely get item by index', () {
      final list = [1, 2, 3];
      
      expect(list.safeGet(0), equals(1));
      expect(list.safeGet(2), equals(3));
      expect(list.safeGet(5), isNull); // Out of bounds
      expect(list.safeGet(-1), isNull); // Negative index
    });
  });

  group('Data Validation Tests', () {
    test('should validate cycle data constraints', () {
      // Valid cycle data
      expect(() => CycleData(
        id: 'valid',
        userId: 'user',
        cycleLength: 28,
        periodLength: 5,
      ), returnsNormally);

      // Invalid cycle length (too short)
      expect(() => CycleData(
        id: 'invalid_short',
        userId: 'user',
        cycleLength: 15,
        periodLength: 5,
      ), throwsArgumentError);

      // Invalid cycle length (too long)
      expect(() => CycleData(
        id: 'invalid_long',
        userId: 'user',
        cycleLength: 50,
        periodLength: 5,
      ), throwsArgumentError);

      // Invalid period length
      expect(() => CycleData(
        id: 'invalid_period',
        userId: 'user',
        cycleLength: 28,
        periodLength: 15,
      ), throwsArgumentError);
    });

    test('should validate mood scores', () {
      expect(() => DailyTrackingData(
        id: 'valid_mood',
        uid: 'user',
        date: DateTime.now(),
        mood: 8,
        cycleDay: 1,
      ), returnsNormally);

      expect(() => DailyTrackingData(
        id: 'invalid_mood_low',
        uid: 'user',
        date: DateTime.now(),
        mood: -1,
        cycleDay: 1,
      ), throwsArgumentError);

      expect(() => DailyTrackingData(
        id: 'invalid_mood_high',
        uid: 'user',
        date: DateTime.now(),
        mood: 11,
        cycleDay: 1,
      ), throwsArgumentError);
    });
  });

  group('Integration Tests', () {
    test('should handle complete data flow', () {
      // Arrange - Create user
      final user = User(
        id: 'integration_user',
        email: 'integration@test.com',
        displayName: 'Integration Test User',
      );

      // Create cycle data
      final cycleData = CycleData(
        id: 'integration_cycle',
        userId: user.id,
        cycleLength: 28,
        periodLength: 5,
      );

      // Create symptom data
      final symptomData = SymptomTracking(
        id: 'integration_symptom',
        userId: user.id,
        symptoms: ['cramping', 'headache'],
        severity: {'cramping': 7, 'headache': 5},
        cycleDay: 1,
      );

      // Create daily tracking
      final dailyData = DailyTrackingData(
        id: 'integration_daily',
        uid: user.id,
        date: DateTime.now(),
        mood: 7,
        energy: 8,
        sleep: 6,
        exercise: true,
        water: 8,
        cycleDay: 1,
      );

      // Act - Validate all data is properly linked
      expect(cycleData.userId, equals(user.id));
      expect(symptomData.userId, equals(user.id));
      expect(dailyData.uid, equals(user.id));

      // Assert - All data should be consistent
      expect(cycleData.getCyclePhase(1), equals('menstrual'));
      expect(symptomData.getAverageSeverity(), equals(6.0));
      expect(dailyData.calculateWellnessScore(), greaterThan(6.0));
    });

    test('should handle empty and null data gracefully', () {
      // Empty lists
      expect(<int>[].safeAverage(), equals(0.0));
      expect(<String>[].mostFrequent(), isNull);
      
      // Null checks in models
      final user = User(id: 'test', email: 'test@example.com');
      expect(user.photoURL, isNull);
      expect(user.lastSignIn, isNotNull); // Should have default value
    });
  });
}
