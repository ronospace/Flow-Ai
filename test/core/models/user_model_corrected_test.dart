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
      // Arrange
      final now = DateTime.now();
      
      // Act
      final user = User(
        id: 'minimal_id',
        email: 'minimal@test.com',
        name: 'Minimal User',
        createdAt: now,
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
        id: 'json_id',
        email: 'json@test.com',
        name: 'JSON User',
        uid: 'json_uid',
        displayName: 'JSON Display Name',
        createdAt: DateTime(2024, 1, 1, 12, 0, 0),
        profileImageUrl: 'https://example.com/json.png',
        metadata: {'key': 'value'},
      );
      
      // Act
      final json = user.toJson();
      
      // Assert
      expect(json['id'], equals('json_id'));
      expect(json['email'], equals('json@test.com'));
      expect(json['name'], equals('JSON User'));
      expect(json['uid'], equals('json_uid'));
      expect(json['displayName'], equals('JSON Display Name'));
      expect(json['created_at'], equals('2024-01-01T12:00:00.000'));
      expect(json['profile_image_url'], equals('https://example.com/json.png'));
      expect(json['metadata'], equals({'key': 'value'}));
    });

    test('should deserialize User from JSON correctly', () {
      // Arrange
      final json = {
        'id': 'from_json_id',
        'email': 'fromjson@test.com',
        'name': 'From JSON User',
        'uid': 'from_json_uid',
        'displayName': 'From JSON Display Name',
        'created_at': '2024-01-01T12:00:00.000',
        'profile_image_url': 'https://example.com/fromjson.png',
        'metadata': {'theme': 'light'},
      };
      
      // Act
      final user = User.fromJson(json);
      
      // Assert
      expect(user.id, equals('from_json_id'));
      expect(user.email, equals('fromjson@test.com'));
      expect(user.name, equals('From JSON User'));
      expect(user.uid, equals('from_json_uid'));
      expect(user.displayName, equals('From JSON Display Name'));
      expect(user.createdAt, equals(DateTime(2024, 1, 1, 12, 0, 0)));
      expect(user.profileImageUrl, equals('https://example.com/fromjson.png'));
      expect(user.metadata, equals({'theme': 'light'}));
    });

    test('should create copyWith maintaining original values when no changes provided', () {
      // Arrange
      final original = User(
        id: 'copy_id',
        email: 'copy@test.com',
        name: 'Copy User',
        uid: 'copy_uid',
        displayName: 'Copy Display Name',
        createdAt: DateTime(2024, 1, 1),
        profileImageUrl: 'https://example.com/copy.png',
        metadata: {'original': 'data'},
      );
      
      // Act
      final copy = original.copyWith();
      
      // Assert
      expect(copy.id, equals(original.id));
      expect(copy.email, equals(original.email));
      expect(copy.name, equals(original.name));
      expect(copy.uid, equals(original.uid));
      expect(copy.displayName, equals(original.displayName));
      expect(copy.createdAt, equals(original.createdAt));
      expect(copy.profileImageUrl, equals(original.profileImageUrl));
      expect(copy.metadata, equals(original.metadata));
    });

    test('should create copyWith with updated values', () {
      // Arrange
      final original = User(
        id: 'update_id',
        email: 'original@test.com',
        name: 'Original User',
        createdAt: DateTime(2024, 1, 1),
      );
      
      // Act
      final updated = original.copyWith(
        name: 'Updated User',
        email: 'updated@test.com',
        displayName: 'Updated Display Name',
        uid: 'updated_uid',
      );
      
      // Assert
      expect(updated.id, equals('update_id')); // Unchanged
      expect(updated.email, equals('updated@test.com')); // Updated
      expect(updated.name, equals('Updated User')); // Updated
      expect(updated.displayName, equals('Updated Display Name')); // Updated
      expect(updated.uid, equals('updated_uid')); // Updated
      expect(updated.createdAt, equals(original.createdAt)); // Unchanged
    });

    test('should validate email correctly using static method', () {
      // Valid emails
      expect(User.isValidEmail('user@example.com'), true);
      expect(User.isValidEmail('test.email@domain.co.uk'), true);
      expect(User.isValidEmail('user123@test-domain.org'), true);
      
      // Invalid emails
      expect(User.isValidEmail('invalid-email'), false);
      expect(User.isValidEmail('user@'), false);
      expect(User.isValidEmail('@domain.com'), false);
      expect(User.isValidEmail(''), false);
      expect(User.isValidEmail('user@.com'), false);
    });
  });
}
