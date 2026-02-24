import 'package:flutter_test/flutter_test.dart';
import 'package:flow_ai/core/services/auth_service.dart';

void main() {
  group('AuthResult Tests', () {
    test('should create successful AuthResult', () {
      // Act
      final result = AuthResult.success('test_user');
      
      // Assert
      expect(result, isA<AuthResult>());
      expect(result.isSuccess, true);
      expect(result.user, equals('test_user'));
      expect(result.error, isNull);
    });

    test('should create failure AuthResult', () {
      // Act
      final result = AuthResult.failure('Authentication failed');
      
      // Assert
      expect(result, isA<AuthResult>());
      expect(result.isSuccess, false);
      expect(result.user, isNull);
      expect(result.error, equals('Authentication failed'));
    });

    test('should handle null user in success result', () {
      // Act
      final result = AuthResult.success(null);
      
      // Assert
      expect(result.isSuccess, true);
      expect(result.user, isNull);
      expect(result.error, isNull);
    });

    test('should handle empty error message', () {
      // Act
      final result = AuthResult.failure('');
      
      // Assert
      expect(result.isSuccess, false);
      expect(result.error, equals(''));
    });
  });
}
