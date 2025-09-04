import 'package:flutter_test/flutter_test.dart';
import '../../../lib/core/models/user.dart';
import '../../../lib/core/models/cycle_data.dart';
import '../../../lib/core/models/symptom_tracking.dart';
import '../../../lib/core/models/auth_result.dart';
import '../../../lib/core/models/period_prediction.dart' hide CyclePhase;
import '../../../lib/core/models/period_prediction.dart' as pp;

void main() {
  group('User Model Tests', () {
    test('should create user with required fields', () {
      final user = User(
        id: 'test_id',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(user.id, 'test_id');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.createdAt, DateTime(2024, 1, 1));
    });

    test('should serialize to and from JSON', () {
      final user = User(
        id: 'test_id',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: DateTime(2024, 1, 1),
        profileImageUrl: 'http://example.com/image.jpg',
        metadata: {'role': 'user'},
      );

      final json = user.toJson();
      final fromJson = User.fromJson(json);

      expect(fromJson.id, user.id);
      expect(fromJson.email, user.email);
      expect(fromJson.name, user.name);
      expect(fromJson.profileImageUrl, user.profileImageUrl);
      expect(fromJson.metadata, user.metadata);
    });

    test('should support copyWith', () {
      final user = User(
        id: 'test_id',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: DateTime(2024, 1, 1),
      );

      final updatedUser = user.copyWith(name: 'Updated Name');

      expect(updatedUser.name, 'Updated Name');
      expect(updatedUser.id, user.id);
      expect(updatedUser.email, user.email);
    });
  });

  group('CycleData Model Tests', () {
    test('should create cycle data with required fields', () {
      final cycleData = CycleData(
        id: 'cycle_1',
        userId: 'user_1',
        startDate: DateTime(2024, 1, 1),
        dailyData: {},
        createdAt: DateTime.now(),
      );

      expect(cycleData.id, 'cycle_1');
      expect(cycleData.userId, 'user_1');
      expect(cycleData.startDate, DateTime(2024, 1, 1));
      expect(cycleData.dailyData, isEmpty);
    });

    test('should create new cycle with factory', () {
      final cycle = CycleData.newCycle(
        userId: 'user_1',
        startDate: DateTime(2024, 1, 1),
      );

      expect(cycle.userId, 'user_1');
      expect(cycle.startDate, DateTime(2024, 1, 1));
      expect(cycle.id, isNotEmpty);
    });

    test('should serialize to and from JSON', () {
      final cycleData = CycleData(
        id: 'cycle_1',
        userId: 'user_1',
        startDate: DateTime(2024, 1, 1),
        dailyData: {},
        createdAt: DateTime(2024, 1, 1),
        cycleLength: 28,
        periodLength: 5,
      );

      final json = cycleData.toJson();
      final fromJson = CycleData.fromJson(json);

      expect(fromJson.id, cycleData.id);
      expect(fromJson.userId, cycleData.userId);
      expect(fromJson.startDate, cycleData.startDate);
      expect(fromJson.cycleLength, cycleData.cycleLength);
      expect(fromJson.periodLength, cycleData.periodLength);
    });

    test('should calculate cycle length correctly', () {
      final cycleData = CycleData(
        id: 'cycle_1',
        userId: 'user_1',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 28),
        dailyData: {},
        createdAt: DateTime(2024, 1, 1),
      );

      expect(cycleData.length, 28);
    });

    test('should update phase correctly', () {
      final cycleData = CycleData(
        id: 'cycle_1',
        userId: 'user_1',
        startDate: DateTime(2024, 1, 1),
        dailyData: {},
        createdAt: DateTime(2024, 1, 1),
        currentPhase: CyclePhase.menstrual,
      );

      final updated = cycleData.updatePhase(CyclePhase.follicular);

      expect(updated.currentPhase, CyclePhase.follicular);
      expect(updated.lastUpdated, isNotNull);
    });
  });

  group('SymptomTracking Model Tests', () {
    test('should create empty symptom tracking', () {
      final tracking = SymptomTracking.empty(userId: 'user_1');

      expect(tracking.userId, 'user_1');
      expect(tracking.symptoms, isEmpty);
      expect(tracking.context, SymptomContext.dailyTracking);
    });

    test('should serialize to and from JSON', () {
      final tracking = SymptomTracking(
        id: 'symptom_1',
        userId: 'user_1',
        recordedAt: DateTime(2024, 1, 1),
        symptoms: {
          'headache': SymptomEntry(severity: 5.0, description: 'Mild headache')
        },
        context: SymptomContext.dailyTracking,
      );

      final json = tracking.toJson();
      final fromJson = SymptomTracking.fromJson(json);

      expect(fromJson.id, tracking.id);
      expect(fromJson.userId, tracking.userId);
      expect(fromJson.symptoms.length, 1);
      expect(fromJson.symptoms['headache']?.severity, 5.0);
    });

    test('should add and remove symptoms', () {
      final tracking = SymptomTracking.empty(userId: 'user_1');
      final symptomEntry = SymptomEntry(severity: 7.0, description: 'Severe cramps');

      final withSymptom = tracking.addSymptom('cramps', symptomEntry);
      expect(withSymptom.symptoms.length, 1);
      expect(withSymptom.symptoms['cramps']?.severity, 7.0);

      final withoutSymptom = withSymptom.removeSymptom('cramps');
      expect(withoutSymptom.symptoms.length, 0);
    });

    test('should get active symptoms', () {
      final tracking = SymptomTracking(
        id: 'symptom_1',
        userId: 'user_1',
        recordedAt: DateTime(2024, 1, 1),
        symptoms: {
          'headache': SymptomEntry(severity: 5.0),
          'fatigue': SymptomEntry(severity: 0.0),
          'cramps': SymptomEntry(severity: 8.0),
        },
        context: SymptomContext.dailyTracking,
      );

      final activeSymptoms = tracking.activeSymptoms;
      expect(activeSymptoms.length, 2);
      expect(activeSymptoms.containsKey('headache'), true);
      expect(activeSymptoms.containsKey('cramps'), true);
      expect(activeSymptoms.containsKey('fatigue'), false);
    });
  });

  group('SymptomEntry Model Tests', () {
    test('should create symptom entry with severity', () {
      final entry = SymptomEntry(
        severity: 6.5,
        description: 'Moderate headache',
        tags: ['morning', 'stress-related'],
      );

      expect(entry.severity, 6.5);
      expect(entry.description, 'Moderate headache');
      expect(entry.tags.length, 2);
    });

    test('should serialize to and from JSON', () {
      final entry = SymptomEntry(
        severity: 6.5,
        description: 'Moderate headache',
        tags: ['morning', 'stress-related'],
        duration: Duration(hours: 2),
      );

      final json = entry.toJson();
      final fromJson = SymptomEntry.fromJson(json);

      expect(fromJson.severity, entry.severity);
      expect(fromJson.description, entry.description);
      expect(fromJson.tags, entry.tags);
      expect(fromJson.duration, entry.duration);
    });
  });

  group('AuthResult Model Tests', () {
    test('should create successful auth result', () {
      final authResult = AuthResult.success(
        userId: 'test_id',
        provider: AuthProvider.local,
        email: 'test@example.com',
        displayName: 'Test User',
        accessToken: 'test_token',
      );

      expect(authResult.success, true);
      expect(authResult.userId, 'test_id');
      expect(authResult.email, 'test@example.com');
      expect(authResult.accessToken, 'test_token');
    });

    test('should create failure auth result', () {
      final authResult = AuthResult.failure(
        error: 'Invalid credentials',
        provider: AuthProvider.local,
      );

      expect(authResult.success, false);
      expect(authResult.error, 'Invalid credentials');
      expect(authResult.userId, isNull);
    });

    test('should serialize to and from JSON', () {
      final authResult = AuthResult.success(
        userId: 'test_id',
        provider: AuthProvider.google,
        email: 'test@example.com',
        displayName: 'Test User',
        accessToken: 'test_token',
      );

      final json = authResult.toJson();
      final fromJson = AuthResult.fromJson(json);

      expect(fromJson.success, authResult.success);
      expect(fromJson.userId, authResult.userId);
      expect(fromJson.email, authResult.email);
      expect(fromJson.accessToken, authResult.accessToken);
    });
  });

  group('PeriodPrediction Model Tests', () {
    test('should create period prediction', () {
      final prediction = PeriodPrediction(
        id: 'prediction_1',
        userId: 'user_1',
        predictedStartDate: DateTime(2024, 2, 1),
        predictedEndDate: DateTime(2024, 2, 5),
        predictedLength: 28,
        confidence: 0.85,
        factors: ['Historical pattern', 'Cycle regularity'],
        symptomPredictions: [],
        currentPhase: pp.CyclePhase.follicular,
        daysToNextPeriod: 7,
      );

      expect(prediction.id, 'prediction_1');
      expect(prediction.userId, 'user_1');
      expect(prediction.confidence, 0.85);
      expect(prediction.predictedLength, 28);
    });

    test('should serialize to and from JSON', () {
      final prediction = PeriodPrediction(
        id: 'prediction_1',
        userId: 'user_1',
        predictedStartDate: DateTime(2024, 2, 1),
        predictedEndDate: DateTime(2024, 2, 5),
        predictedLength: 28,
        confidence: 0.85,
        factors: ['Historical pattern'],
        symptomPredictions: [],
        currentPhase: pp.CyclePhase.luteal,
        daysToNextPeriod: 5,
      );

      final json = prediction.toJson();
      final fromJson = PeriodPrediction.fromJson(json);

      expect(fromJson.id, prediction.id);
      expect(fromJson.userId, prediction.userId);
      expect(fromJson.confidence, prediction.confidence);
      expect(fromJson.predictedStartDate, prediction.predictedStartDate);
    });

    test('should use default prediction factory', () {
      final prediction = PeriodPrediction.defaultPrediction(userId: 'user_1');

      expect(prediction.userId, 'user_1');
      expect(prediction.confidence, 0.5);
      expect(prediction.predictedLength, 28);
      expect(prediction.factors.length, 2);
    });
  });

  group('Enums Tests', () {
    test('FlowIntensity should have correct display names', () {
      expect(FlowIntensity.none.displayName, 'None');
      expect(FlowIntensity.light.displayName, 'Light');
      expect(FlowIntensity.medium.displayName, 'Medium');
      expect(FlowIntensity.heavy.displayName, 'Heavy');
    });

    test('CyclePhase should have correct display names', () {
      expect(CyclePhase.menstrual.displayName, 'Menstrual');
      expect(CyclePhase.follicular.displayName, 'Follicular');
      expect(CyclePhase.ovulatory.displayName, 'Ovulatory');
      expect(CyclePhase.luteal.displayName, 'Luteal');
    });

    test('SeverityLevel should convert from numeric value', () {
      expect(SeverityLevelExtension.fromNumericValue(0.5), SeverityLevel.none);
      expect(SeverityLevelExtension.fromNumericValue(2.5), SeverityLevel.mild);
      expect(SeverityLevelExtension.fromNumericValue(5.0), SeverityLevel.moderate);
      expect(SeverityLevelExtension.fromNumericValue(8.0), SeverityLevel.severe);
      expect(SeverityLevelExtension.fromNumericValue(10.0), SeverityLevel.extreme);
    });
  });

  group('Symptom Categories Tests', () {
    test('should get correct category for symptoms', () {
      expect(getSymptomCategory('cramps'), SymptomCategory.menstrual);
      expect(getSymptomCategory('anxiety'), SymptomCategory.mood);
      expect(getSymptomCategory('headache'), SymptomCategory.physical);
      expect(getSymptomCategory('fatigue'), SymptomCategory.energy);
      expect(getSymptomCategory('unknown'), SymptomCategory.physical); // default
    });
  });
}
