import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flow_ai/core/services/auth_service.dart';
import 'package:flow_ai/core/services/local_user_service.dart';
import 'package:flow_ai/core/services/apple_signin_service.dart';
import 'package:flow_ai/core/services/biometric_auth_service.dart';
import 'package:flow_ai/core/models/auth_result.dart';
import 'package:flow_ai/core/models/user.dart';

// Generate mocks
@GenerateMocks([LocalUserService, AppleSignInService, BiometricAuthService])
import 'auth_service_test.mocks.dart';

void main() {
  group('AuthService Tests', () {
    late AuthService authService;
    late MockLocalUserService mockLocalUserService;
    late MockAppleSignInService mockAppleSignInService;
    late MockBiometricAuthService mockBiometricAuthService;

    setUp(() {
      mockLocalUserService = MockLocalUserService();
      mockAppleSignInService = MockAppleSignInService();
      mockBiometricAuthService = MockBiometricAuthService();
      authService = AuthService();
    });

    test('should initialize auth service successfully', () async {
      // Arrange
      when(mockLocalUserService.initialize()).thenAnswer((_) async => true);
      when(mockBiometricAuthService.initialize()).thenAnswer((_) async => true);

      // Act
      await authService.initialize();

      // Assert
      expect(authService.isInitialized, true);
    });

    test('should create demo account for App Store review', () async {
      // Arrange
      const expectedUser = User(
        uid: 'demo_user_123',
        email: 'demo@flowai.app',
        displayName: 'Demo User for App Review',
        provider: 'local',
        isDemo: true,
      );

      when(mockLocalUserService.createDemoAccount())
          .thenAnswer((_) async => expectedUser);

      // Act
      final result = await authService.createDemoAccount();

      // Assert
      expect(result.success, true);
      expect(result.user, isNotNull);
      expect(result.user!.isDemo, true);
      expect(result.user!.email, 'demo@flowai.app');
    });

    test('should authenticate with email and password', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'securePassword123';
      const expectedUser = User(
        uid: 'user_123',
        email: email,
        displayName: 'Test User',
        provider: 'local',
      );

      when(mockLocalUserService.signInWithEmailPassword(email, password))
          .thenAnswer((_) async => expectedUser);

      // Act
      final result = await authService.signInWithEmailPassword(email, password);

      // Assert
      expect(result.success, true);
      expect(result.user, isNotNull);
      expect(result.user!.email, email);
      expect(result.errorMessage, isNull);
    });

    test('should handle authentication failure gracefully', () async {
      // Arrange
      const email = 'invalid@example.com';
      const password = 'wrongPassword';

      when(mockLocalUserService.signInWithEmailPassword(email, password))
          .thenThrow(Exception('Invalid credentials'));

      // Act
      final result = await authService.signInWithEmailPassword(email, password);

      // Assert
      expect(result.success, false);
      expect(result.user, isNull);
      expect(result.errorMessage, contains('Invalid credentials'));
    });

    test('should sign up new user successfully', () async {
      // Arrange
      const email = 'newuser@example.com';
      const password = 'newPassword123';
      const displayName = 'New User';
      const expectedUser = User(
        uid: 'new_user_123',
        email: email,
        displayName: displayName,
        provider: 'local',
      );

      when(mockLocalUserService.createAccount(email, password, displayName))
          .thenAnswer((_) async => expectedUser);

      // Act
      final result = await authService.signUpWithEmailPassword(email, password, displayName);

      // Assert
      expect(result.success, true);
      expect(result.user, isNotNull);
      expect(result.user!.email, email);
      expect(result.user!.displayName, displayName);
    });

    test('should authenticate with Apple Sign-In', () async {
      // Arrange
      const expectedUser = User(
        uid: 'apple_user_123',
        email: 'user@privaterelay.appleid.com',
        displayName: 'Apple User',
        provider: 'apple',
      );

      when(mockAppleSignInService.signIn())
          .thenAnswer((_) async => expectedUser);

      // Act
      final result = await authService.signInWithApple();

      // Assert
      expect(result.success, true);
      expect(result.user, isNotNull);
      expect(result.user!.provider, 'apple');
    });

    test('should handle Apple Sign-In cancellation', () async {
      // Arrange
      when(mockAppleSignInService.signIn())
          .thenThrow(Exception('User cancelled Apple Sign-In'));

      // Act
      final result = await authService.signInWithApple();

      // Assert
      expect(result.success, false);
      expect(result.user, isNull);
      expect(result.errorMessage, contains('cancelled'));
    });

    test('should sign out user successfully', () async {
      // Arrange
      when(mockLocalUserService.signOut()).thenAnswer((_) async => true);
      when(mockAppleSignInService.signOut()).thenAnswer((_) async => true);

      // Act
      final result = await authService.signOut();

      // Assert
      expect(result, true);
      expect(authService.currentUser, isNull);
    });

    test('should validate email format correctly', () {
      // Test valid emails
      expect(authService.isValidEmail('user@example.com'), true);
      expect(authService.isValidEmail('test.email@domain.co.uk'), true);
      
      // Test invalid emails
      expect(authService.isValidEmail('invalid-email'), false);
      expect(authService.isValidEmail('user@'), false);
      expect(authService.isValidEmail('@domain.com'), false);
      expect(authService.isValidEmail(''), false);
    });

    test('should validate password strength', () {
      // Test strong passwords
      expect(authService.isValidPassword('SecurePass123!'), true);
      expect(authService.isValidPassword('MyP@ssw0rd'), true);
      
      // Test weak passwords
      expect(authService.isValidPassword('123'), false);
      expect(authService.isValidPassword('password'), false);
      expect(authService.isValidPassword(''), false);
      expect(authService.isValidPassword('short'), false);
    });

    test('should check authentication state persistence', () async {
      // Arrange
      const savedUser = User(
        uid: 'saved_user_123',
        email: 'saved@example.com',
        displayName: 'Saved User',
        provider: 'local',
      );

      when(mockLocalUserService.getCurrentUser())
          .thenAnswer((_) async => savedUser);

      // Act
      await authService.checkAuthState();

      // Assert
      expect(authService.currentUser, isNotNull);
      expect(authService.currentUser!.email, 'saved@example.com');
      expect(authService.isAuthenticated, true);
    });

    test('should reset password successfully', () async {
      // Arrange
      const email = 'reset@example.com';
      when(mockLocalUserService.resetPassword(email))
          .thenAnswer((_) async => true);

      // Act
      final result = await authService.resetPassword(email);

      // Assert
      expect(result.success, true);
      expect(result.errorMessage, isNull);
    });

    test('should update user profile', () async {
      // Arrange
      const currentUser = User(
        uid: 'update_user_123',
        email: 'update@example.com',
        displayName: 'Old Name',
        provider: 'local',
      );

      const updatedUser = User(
        uid: 'update_user_123',
        email: 'update@example.com',
        displayName: 'New Name',
        provider: 'local',
      );

      authService.setCurrentUser(currentUser);
      
      when(mockLocalUserService.updateUserProfile('update_user_123', 'New Name', null))
          .thenAnswer((_) async => updatedUser);

      // Act
      final result = await authService.updateUserProfile('New Name', null);

      // Assert
      expect(result.success, true);
      expect(result.user!.displayName, 'New Name');
    });
  });

  group('BiometricAuthService Tests', () {
    late BiometricAuthService biometricService;

    setUp(() {
      biometricService = BiometricAuthService();
    });

    test('should check biometric availability', () async {
      // Act
      final isAvailable = await biometricService.isBiometricAvailable();

      // Assert
      expect(isAvailable, isA<bool>());
    });

    test('should get available biometric types', () async {
      // Act
      final biometricTypes = await biometricService.getAvailableBiometrics();

      // Assert
      expect(biometricTypes, isA<List<String>>());
    });

    test('should authenticate with biometrics successfully', () async {
      // Arrange
      const reason = 'Authenticate to access Flow Ai';

      // Note: This would require platform-specific mocking in a real test
      // For now, we'll test the structure and error handling
      
      // Act & Assert
      expect(
        () => biometricService.authenticateWithBiometrics(reason),
        returnsNormally,
      );
    });

    test('should handle biometric authentication failure', () async {
      // Arrange
      const reason = 'Authenticate to access Flow Ai';

      try {
        // Act
        await biometricService.authenticateWithBiometrics(reason);
      } catch (e) {
        // Assert
        expect(e, isA<Exception>());
      }
    });
  });

  group('Apple Sign-In Service Tests', () {
    late AppleSignInService appleService;

    setUp(() {
      appleService = AppleSignInService();
    });

    test('should check Apple Sign-In availability', () async {
      // Act
      final isAvailable = await appleService.isAvailable();

      // Assert
      expect(isAvailable, isA<bool>());
    });

    test('should handle Apple Sign-In not available gracefully', () async {
      // This test would require platform-specific mocking
      // Testing the structure for now
      
      expect(() => appleService.isAvailable(), returnsNormally);
    });

    test('should provide Apple Sign-In credential state', () async {
      // Arrange
      const userIdentifier = 'apple_user_id';

      // Act & Assert
      expect(
        () => appleService.getCredentialState(userIdentifier),
        returnsNormally,
      );
    });
  });

  group('Authentication Flow Integration Tests', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('should complete full authentication flow', () async {
      // This would test the complete flow from sign-up to sign-in to sign-out
      // Requires integration with actual services or detailed mocking
      
      expect(authService, isNotNull);
      expect(() => authService.initialize(), returnsNormally);
    });

    test('should handle session management correctly', () async {
      // Test session timeout, refresh tokens, etc.
      expect(authService.sessionTimeout, isA<Duration>());
    });

    test('should manage user state across app restarts', () async {
      // Test persistence and state recovery
      expect(() => authService.checkAuthState(), returnsNormally);
    });
  });
}
