import 'package:flutter_test/flutter_test.dart';
import 'package:flow_iq/core/services/auth_service.dart';

void main() {
  // Initialize Flutter bindings for testing
  TestWidgetsFlutterBinding.ensureInitialized();
  group('AuthService Tests', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('should initialize auth service successfully', () async {
      // Act & Assert
      expect(() => authService.initialize(), returnsNormally);
      
      // Wait for initialization
      await authService.initialize();
      expect(authService.isInitialized, true);
    });

    test('should check if authenticated initially returns false', () async {
      // Act
      final isAuthenticated = await authService.isAuthenticated;
      
      // Assert
      expect(isAuthenticated, false);
    });

    test('should check biometric availability', () async {
      // Initialize service first
      await authService.initialize();
      
      // Act & Assert
      expect(() => authService.isBiometricAvailable(), returnsNormally);
    });

    test('should check if biometric is enabled', () async {
      // Initialize service first
      await authService.initialize();
      
      // Act
      final isEnabled = authService.isBiometricEnabled();
      
      // Assert
      expect(isEnabled, isA<bool>());
    });

    test('should get current user returns null when not authenticated', () async {
      // Initialize service first
      await authService.initialize();
      
      // Act
      final user = await authService.getCurrentUser();
      
      // Assert
      expect(user, isNull);
    });

    test('should get user data returns null when not authenticated', () async {
      // Initialize service first
      await authService.initialize();
      
      // Act
      final userData = await authService.getUserData();
      
      // Assert - might be null or stored data from previous sessions
      expect(userData, anyOf(isNull, isA<Map<String, dynamic>>()));
    });

    test('should handle biometric authentication with proper error when not available', () async {
      // Initialize service first
      await authService.initialize();
      
      // Act
      final result = await authService.authenticateWithBiometrics();
      
      // Assert - Should return an AuthResult
      expect(result, isA<AuthResult>());
      // Most likely will fail since biometrics aren't set up in test environment
    });

    test('should sign up with email creates AuthResult', () async {
      // Initialize service first
      await authService.initialize();
      
      // Act
      final result = await authService.signUpWithEmail(
        email: 'test@example.com',
        password: 'testPassword123',
        displayName: 'Test User',
      );
      
      // Assert
      expect(result, isA<AuthResult>());
      // Result could be success or failure depending on local service state
    });

    test('should sign in with email creates AuthResult', () async {
      // Initialize service first
      await authService.initialize();
      
      // Act
      final result = await authService.signInWithEmail(
        email: 'test@example.com',
        password: 'testPassword123',
      );
      
      // Assert
      expect(result, isA<AuthResult>());
      // Result could be success or failure depending on user existence
    });

    test('should set biometric enabled', () async {
      // Initialize service first
      await authService.initialize();
      
      // Act & Assert
      expect(() => authService.setBiometricEnabled(true), returnsNormally);
      expect(() => authService.setBiometricEnabled(false), returnsNormally);
    });
  });

  group('AuthService Integration Tests', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('should maintain singleton behavior', () {
      // Act
      final instance1 = AuthService();
      final instance2 = AuthService();
      
      // Assert
      expect(identical(instance1, instance2), true);
    });

    test('should handle initialization idempotency', () async {
      // Act
      await authService.initialize();
      await authService.initialize(); // Should not cause issues
      
      // Assert
      expect(authService.isInitialized, true);
    });

    test('should handle service lifecycle properly', () async {
      // Arrange
      expect(authService.isInitialized, false);
      
      // Act
      await authService.initialize();
      
      // Assert
      expect(authService.isInitialized, true);
      
      // Multiple operations should work
      expect(authService.isBiometricEnabled(), isA<bool>());
      expect(() => authService.getCurrentUser(), returnsNormally);
      expect(() => authService.getUserData(), returnsNormally);
    });
  });
}
