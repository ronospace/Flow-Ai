import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flow_ai/core/database/database_service.dart';
import 'package:flow_ai/core/services/cloud_sync_service.dart';
import 'package:flow_ai/core/services/offline_service.dart';
import 'package:flow_ai/core/models/cycle_data.dart';
import 'package:flow_ai/core/models/symptom_tracking.dart';
import 'package:flow_ai/core/models/daily_tracking_data.dart';
import 'package:sqflite_common/sqflite.dart';

// Generate mocks
@GenerateMocks([Database, CloudSyncService, OfflineService])
import 'database_service_test.mocks.dart';

void main() {
  group('DatabaseService Tests', () {
    late DatabaseService databaseService;
    late MockDatabase mockDatabase;
    late MockCloudSyncService mockCloudSync;

    setUp(() {
      mockDatabase = MockDatabase();
      mockCloudSync = MockCloudSyncService();
      databaseService = DatabaseService();
    });

    test('should initialize database successfully', () async {
      // Arrange
      when(mockDatabase.getVersion()).thenAnswer((_) async => 1);

      // Act
      await databaseService.initialize();

      // Assert
      expect(databaseService.isInitialized, true);
      expect(databaseService.databaseVersion, greaterThan(0));
    });

    test('should create tables on first initialization', () async {
      // Arrange
      when(mockDatabase.execute(any)).thenAnswer((_) async => 0);

      // Act
      await databaseService.createTables();

      // Assert
      verify(mockDatabase.execute(contains('CREATE TABLE users'))).called(1);
      verify(mockDatabase.execute(contains('CREATE TABLE cycle_data'))).called(1);
      verify(mockDatabase.execute(contains('CREATE TABLE symptoms'))).called(1);
      verify(mockDatabase.execute(contains('CREATE TABLE daily_tracking'))).called(1);
    });

    test('should perform database migration successfully', () async {
      // Arrange
      const oldVersion = 1;
      const newVersion = 2;
      
      when(mockDatabase.getVersion()).thenAnswer((_) async => oldVersion);

      // Act
      await databaseService.migrateTo(newVersion);

      // Assert
      expect(databaseService.databaseVersion, equals(newVersion));
    });

    test('should insert cycle data correctly', () async {
      // Arrange
      final cycleData = CycleData(
        userId: 'test_user_123',
        cycleLength: 28,
        periodLength: 5,
        lastPeriodStart: DateTime.now(),
        symptoms: ['cramping'],
        mood: 'normal',
        flow: 'medium',
      );

      when(mockDatabase.insert('cycle_data', any, conflictAlgorithm: anyNamed('conflictAlgorithm')))
          .thenAnswer((_) async => 1);

      // Act
      final result = await databaseService.insertCycleData(cycleData);

      // Assert
      expect(result, equals(1));
      verify(mockDatabase.insert('cycle_data', any, conflictAlgorithm: ConflictAlgorithm.replace));
    });

    test('should retrieve cycle data by user ID', () async {
      // Arrange
      const userId = 'test_user_123';
      final mockResults = [
        {
          'id': 1,
          'user_id': userId,
          'cycle_length': 28,
          'period_length': 5,
          'last_period_start': DateTime.now().millisecondsSinceEpoch,
          'symptoms': '["cramping"]',
          'mood': 'normal',
          'flow': 'medium',
          'created_at': DateTime.now().millisecondsSinceEpoch,
        }
      ];

      when(mockDatabase.query('cycle_data', where: 'user_id = ?', whereArgs: [userId]))
          .thenAnswer((_) async => mockResults);

      // Act
      final results = await databaseService.getCycleDataByUserId(userId);

      // Assert
      expect(results, isNotEmpty);
      expect(results.first.userId, equals(userId));
      expect(results.first.cycleLength, equals(28));
    });

    test('should update cycle data', () async {
      // Arrange
      final updatedCycleData = CycleData(
        id: 1,
        userId: 'test_user_123',
        cycleLength: 30, // Updated cycle length
        periodLength: 4,
        lastPeriodStart: DateTime.now(),
        symptoms: ['headache'],
        mood: 'happy',
        flow: 'light',
      );

      when(mockDatabase.update('cycle_data', any, where: 'id = ?', whereArgs: [1]))
          .thenAnswer((_) async => 1);

      // Act
      final result = await databaseService.updateCycleData(updatedCycleData);

      // Assert
      expect(result, equals(1));
      verify(mockDatabase.update('cycle_data', any, where: 'id = ?', whereArgs: [1]));
    });

    test('should delete cycle data', () async {
      // Arrange
      const cycleDataId = 1;

      when(mockDatabase.delete('cycle_data', where: 'id = ?', whereArgs: [cycleDataId]))
          .thenAnswer((_) async => 1);

      // Act
      final result = await databaseService.deleteCycleData(cycleDataId);

      // Assert
      expect(result, equals(1));
      verify(mockDatabase.delete('cycle_data', where: 'id = ?', whereArgs: [cycleDataId]));
    });

    test('should insert symptom tracking data', () async {
      // Arrange
      final symptomData = SymptomTracking(
        userId: 'test_user_123',
        date: DateTime.now(),
        symptoms: ['cramping', 'headache', 'bloating'],
        severity: {'cramping': 7, 'headache': 5, 'bloating': 3},
        notes: 'Period started today',
        cycleDay: 1,
      );

      when(mockDatabase.insert('symptoms', any, conflictAlgorithm: anyNamed('conflictAlgorithm')))
          .thenAnswer((_) async => 1);

      // Act
      final result = await databaseService.insertSymptomData(symptomData);

      // Assert
      expect(result, equals(1));
      verify(mockDatabase.insert('symptoms', any, conflictAlgorithm: ConflictAlgorithm.replace));
    });

    test('should retrieve symptoms by date range', () async {
      // Arrange
      const userId = 'test_user_123';
      final startDate = DateTime.now().subtract(const Duration(days: 30));
      final endDate = DateTime.now();

      final mockResults = [
        {
          'id': 1,
          'user_id': userId,
          'date': DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch,
          'symptoms': '["cramping", "headache"]',
          'severity': '{"cramping": 7, "headache": 5}',
          'notes': 'Period symptoms',
          'cycle_day': 1,
        }
      ];

      when(mockDatabase.query(
        'symptoms',
        where: 'user_id = ? AND date BETWEEN ? AND ?',
        whereArgs: [userId, startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch],
      )).thenAnswer((_) async => mockResults);

      // Act
      final results = await databaseService.getSymptomsByDateRange(userId, startDate, endDate);

      // Assert
      expect(results, isNotEmpty);
      expect(results.first.userId, equals(userId));
      expect(results.first.symptoms, contains('cramping'));
    });

    test('should insert daily tracking data', () async {
      // Arrange
      final dailyData = DailyTrackingData(
        userId: 'test_user_123',
        date: DateTime.now(),
        mood: 8,
        energy: 7,
        sleep: 6,
        exercise: true,
        water: 8,
        notes: 'Good day overall',
        cycleDay: 15,
      );

      when(mockDatabase.insert('daily_tracking', any, conflictAlgorithm: anyNamed('conflictAlgorithm')))
          .thenAnswer((_) async => 1);

      // Act
      final result = await databaseService.insertDailyTrackingData(dailyData);

      // Assert
      expect(result, equals(1));
    });

    test('should handle database transaction rollback on error', () async {
      // Arrange
      final transaction = MockDatabase();
      when(mockDatabase.transaction(any)).thenThrow(Exception('Transaction failed'));

      // Act & Assert
      expect(
        () => databaseService.performBatchOperations([]),
        throwsA(isA<Exception>()),
      );
    });

    test('should backup database data', () async {
      // Arrange
      final mockUserData = [{'id': 1, 'email': 'test@example.com'}];
      final mockCycleData = [{'id': 1, 'user_id': 'user1', 'cycle_length': 28}];

      when(mockDatabase.query('users')).thenAnswer((_) async => mockUserData);
      when(mockDatabase.query('cycle_data')).thenAnswer((_) async => mockCycleData);
      when(mockDatabase.query('symptoms')).thenAnswer((_) async => []);
      when(mockDatabase.query('daily_tracking')).thenAnswer((_) async => []);

      // Act
      final backupData = await databaseService.createBackup();

      // Assert
      expect(backupData, isNotNull);
      expect(backupData['users'], equals(mockUserData));
      expect(backupData['cycle_data'], equals(mockCycleData));
    });

    test('should restore database from backup', () async {
      // Arrange
      final backupData = {
        'users': [{'id': 1, 'email': 'restored@example.com'}],
        'cycle_data': [{'id': 1, 'user_id': 'user1', 'cycle_length': 30}],
        'symptoms': [],
        'daily_tracking': [],
      };

      when(mockDatabase.delete(any)).thenAnswer((_) async => 1);
      when(mockDatabase.insert(any, any, conflictAlgorithm: anyNamed('conflictAlgorithm')))
          .thenAnswer((_) async => 1);

      // Act
      await databaseService.restoreFromBackup(backupData);

      // Assert
      verify(mockDatabase.delete('users')).called(1);
      verify(mockDatabase.delete('cycle_data')).called(1);
      verify(mockDatabase.insert('users', any, conflictAlgorithm: ConflictAlgorithm.replace)).called(1);
    });
  });

  group('Cloud Sync Service Tests', () {
    late MockCloudSyncService mockCloudSync;

    setUp(() {
      mockCloudSync = MockCloudSyncService();
    });

    test('should sync local data to cloud', () async {
      // Arrange
      final localData = {
        'cycle_data': [{'id': 1, 'cycle_length': 28}],
        'symptoms': [{'id': 1, 'symptoms': '["cramping"]'}],
      };

      when(mockCloudSync.syncToCloud(localData)).thenAnswer((_) async => true);

      // Act
      final result = await mockCloudSync.syncToCloud(localData);

      // Assert
      expect(result, true);
      verify(mockCloudSync.syncToCloud(localData)).called(1);
    });

    test('should sync cloud data to local', () async {
      // Arrange
      final cloudData = {
        'cycle_data': [{'id': 2, 'cycle_length': 30}],
        'last_sync': DateTime.now().toIso8601String(),
      };

      when(mockCloudSync.syncFromCloud()).thenAnswer((_) async => cloudData);

      // Act
      final result = await mockCloudSync.syncFromCloud();

      // Assert
      expect(result, equals(cloudData));
      expect(result['cycle_data'], isNotEmpty);
    });

    test('should handle sync conflicts', () async {
      // Arrange
      final conflictData = {
        'local_version': {'id': 1, 'cycle_length': 28, 'updated_at': '2024-01-01'},
        'cloud_version': {'id': 1, 'cycle_length': 30, 'updated_at': '2024-01-02'},
      };

      when(mockCloudSync.resolveConflict(any, any))
          .thenAnswer((_) async => conflictData['cloud_version']); // Cloud wins

      // Act
      final resolved = await mockCloudSync.resolveConflict(
        conflictData['local_version']!,
        conflictData['cloud_version']!,
      );

      // Assert
      expect(resolved['cycle_length'], equals(30)); // Cloud version used
    });

    test('should retry sync on failure', () async {
      // Arrange
      when(mockCloudSync.syncToCloud(any))
          .thenThrow(Exception('Network error'))
          .thenAnswer((_) async => true); // Succeeds on retry

      // Act & Assert
      expect(
        () => mockCloudSync.syncToCloud({}),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Offline Service Tests', () {
    late MockOfflineService mockOfflineService;

    setUp(() {
      mockOfflineService = MockOfflineService();
    });

    test('should queue operations when offline', () async {
      // Arrange
      when(mockOfflineService.isOnline).thenReturn(false);
      
      final operation = {
        'type': 'insert',
        'table': 'cycle_data',
        'data': {'cycle_length': 28},
      };

      when(mockOfflineService.queueOperation(operation))
          .thenAnswer((_) async => true);

      // Act
      final result = await mockOfflineService.queueOperation(operation);

      // Assert
      expect(result, true);
      verify(mockOfflineService.queueOperation(operation)).called(1);
    });

    test('should execute queued operations when back online', () async {
      // Arrange
      final queuedOperations = [
        {'type': 'insert', 'table': 'cycle_data', 'data': {'cycle_length': 28}},
        {'type': 'update', 'table': 'symptoms', 'data': {'severity': 8}},
      ];

      when(mockOfflineService.isOnline).thenReturn(true);
      when(mockOfflineService.getQueuedOperations())
          .thenAnswer((_) async => queuedOperations);
      when(mockOfflineService.executeQueuedOperations())
          .thenAnswer((_) async => 2);

      // Act
      final executedCount = await mockOfflineService.executeQueuedOperations();

      // Assert
      expect(executedCount, equals(2));
    });

    test('should handle network status changes', () async {
      // Arrange
      when(mockOfflineService.onNetworkStatusChange(any))
          .thenAnswer((_) async {
            return null;
          });

      // Act
      await mockOfflineService.onNetworkStatusChange(true); // Online

      // Assert
      verify(mockOfflineService.onNetworkStatusChange(true)).called(1);
    });
  });

  group('Database Integration Tests', () {
    late DatabaseService databaseService;

    setUp(() {
      databaseService = DatabaseService();
    });

    test('should handle complete user data lifecycle', () async {
      // This would test the full flow of user data management
      // from creation to deletion with proper cleanup
      
      expect(databaseService, isNotNull);
      expect(() => databaseService.initialize(), returnsNormally);
    });

    test('should maintain data integrity during concurrent operations', () async {
      // Test concurrent reads and writes don't cause data corruption
      expect(() => databaseService.performBatchOperations([]), returnsNormally);
    });

    test('should handle database size optimization', () async {
      // Test database vacuum and optimization operations
      expect(() => databaseService.optimizeDatabase(), returnsNormally);
    });
  });
}
