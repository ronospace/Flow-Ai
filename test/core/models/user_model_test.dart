import 'package:flutter_test/flutter_test.dart';
import 'package:flow_iq/core/models/user.dart';

void main() {
  group('User Model Tests', () {
    test('should create User with all fields', () {
      // Arrange
      final now = DateTime.now();
      final metadata = {'theme': 'dark', 'language': 'en'};
      
      // Act
      final user = User(
        id: 'test_id_123',
        email: 'test@example.com',
        name: 'Test User',
        uid: 'test_uid_123',
        displayName: 'Test Display Name',
        createdAt: now,
        profileImageUrl: 'https://example.com/avatar.png',
        metadata: metadata,
      );
      
      // Assert
      expect(user.id, equals('test_id_123'));
      expect(user.email, equals('test@example.com'));
      expect(user.name, equals('Test User'));
      expect(user.uid, equals('test_uid_123'));
      expect(user.displayName, equals('Test Display Name'));
      expect(user.createdAt, equals(now));
      expect(user.profileImageUrl, equals('https://example.com/avatar.png'));
      expect(user.metadata, equals(metadata));
    });

    test('should create User with minimal required fields', () {
      // Act
      final user = User(
        id: 'minimal_id',
        email: 'minimal@test.com',
        name: 'Minimal User',
        createdAt: DateTime.now(),
      );
      
      // Assert
      expect(user.id, equals('minimal_id'));
      expect(user.email, equals('minimal@test.com'));
      expect(user.name, equals('Minimal User'));
      expect(user.uid, isNull);
      expect(user.displayName, isNull);
      expect(user.profileImageUrl, isNull);
      expect(user.metadata, isNull);
    });

    test('should serialize User to JSON correctly', () {
      // Arrange
      final user = User(
        uid: 'json_uid',
        email: 'json@test.com',
        displayName: 'JSON User',
        username: 'jsonuser',
        createdAt: DateTime(2024, 1, 1, 12, 0, 0),
        lastUpdated: DateTime(2024, 1, 2, 12, 0, 0),
        isEmailVerified: true,
      );
      
      // Act
      final json = user.toJson();
      
      // Assert
      expect(json['uid'], equals('json_uid'));
      expect(json['email'], equals('json@test.com'));
      expect(json['displayName'], equals('JSON User'));
      expect(json['username'], equals('jsonuser'));
      expect(json['isEmailVerified'], true);
      expect(json['createdAt'], equals('2024-01-01T12:00:00.000'));
      expect(json['lastUpdated'], equals('2024-01-02T12:00:00.000'));
    });

    test('should deserialize User from JSON correctly', () {
      // Arrange
      final json = {
        'uid': 'from_json_uid',
        'email': 'fromjson@test.com',
        'displayName': 'From JSON User',
        'username': 'fromjsonuser',
        'isEmailVerified': true,
        'isProfileComplete': false,
        'createdAt': '2024-01-01T12:00:00.000',
        'lastUpdated': '2024-01-02T12:00:00.000',
      };
      
      // Act
      final user = User.fromJson(json);
      
      // Assert
      expect(user.uid, equals('from_json_uid'));
      expect(user.email, equals('fromjson@test.com'));
      expect(user.displayName, equals('From JSON User'));
      expect(user.username, equals('fromjsonuser'));
      expect(user.isEmailVerified, true);
      expect(user.isProfileComplete, false);
      expect(user.createdAt, equals(DateTime(2024, 1, 1, 12, 0, 0)));
      expect(user.lastUpdated, equals(DateTime(2024, 1, 2, 12, 0, 0)));
    });

    test('should create copyWith maintaining original values when no changes provided', () {
      // Arrange
      final original = User(
        uid: 'copy_uid',
        email: 'copy@test.com',
        displayName: 'Copy User',
        username: 'copyuser',
        createdAt: DateTime(2024, 1, 1),
        lastUpdated: DateTime(2024, 1, 1),
        isEmailVerified: true,
      );
      
      // Act
      final copy = original.copyWith();
      
      // Assert
      expect(copy.uid, equals(original.uid));
      expect(copy.email, equals(original.email));
      expect(copy.displayName, equals(original.displayName));
      expect(copy.username, equals(original.username));
      expect(copy.isEmailVerified, equals(original.isEmailVerified));
    });

    test('should create copyWith with updated values', () {
      // Arrange
      final original = User(
        uid: 'update_uid',
        email: 'original@test.com',
        displayName: 'Original User',
        createdAt: DateTime(2024, 1, 1),
        lastUpdated: DateTime(2024, 1, 1),
        isEmailVerified: false,
      );
      
      // Act
      final updated = original.copyWith(
        displayName: 'Updated User',
        email: 'updated@test.com',
        isEmailVerified: true,
      );
      
      // Assert
      expect(updated.uid, equals('update_uid')); // Unchanged
      expect(updated.email, equals('updated@test.com')); // Updated
      expect(updated.displayName, equals('Updated User')); // Updated
      expect(updated.isEmailVerified, true); // Updated
    });
  });
}
