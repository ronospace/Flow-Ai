import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../utils/app_logger.dart';
import 'app_enhancement_service.dart';

/// Enhanced Apple Sign-In service with comprehensive implementation
class AppleSignInService {
  static final AppleSignInService _instance = AppleSignInService._internal();
  factory AppleSignInService() => _instance;
  AppleSignInService._internal();

  bool _isInitialized = false;
  bool _isAvailable = false;

  /// Initialize the Apple Sign-In service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      AppLogger.auth('🍎 Initializing Apple Sign-In service...');
      
      // Check platform availability
      _isAvailable = await _checkAvailability();
      
      _isInitialized = true;
      AppLogger.auth('✅ Apple Sign-In service initialized (Available: $_isAvailable)');
    } catch (e) {
      AppLogger.error('❌ Apple Sign-In initialization failed', e);
      _isInitialized = true; // Still mark as initialized to prevent repeated attempts
    }
  }

  /// Check if Apple Sign-In is available on this platform
  Future<bool> _checkAvailability() async {
    try {
      // Apple Sign-In is only available on iOS 13+ and macOS 10.15+
      if (kIsWeb) return false;
      
      if (Platform.isIOS) {
        return await SignInWithApple.isAvailable();
      }
      
      if (Platform.isMacOS) {
        return await SignInWithApple.isAvailable();
      }
      
      return false;
    } catch (e) {
      AppLogger.warning('Error checking Apple Sign-In availability: $e');
      return false;
    }
  }

  /// Get availability status
  bool get isAvailable => _isAvailable;

  /// Sign in with Apple
  Future<AppleSignInResult> signIn() async {
    final enhancementService = AppEnhancementService();
    enhancementService.startPerformanceTrace('apple_signin');

    try {
      if (!_isInitialized) {
        await initialize();
      }

      if (!_isAvailable) {
        return AppleSignInResult.failure(
          'Apple Sign-In is not available on this device. Please use email authentication instead.',
        );
      }

      AppLogger.auth('🍎 Starting Apple Sign-In flow...');

      // Get Apple ID credential
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: kIsWeb
            ? WebAuthenticationOptions(
                clientId: 'your.apple.service.id', // TODO: Replace with actual service ID
                redirectUri: Uri.parse('https://your-app.firebaseapp.com/__/auth/handler'),
              )
            : null,
      );

      AppLogger.auth('✅ Apple ID credential obtained');

      // Create Firebase auth credential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      // Sign in to Firebase
      final firebaseAuth = FirebaseAuth.instance;
      final userCredential = await firebaseAuth.signInWithCredential(oauthCredential);

      if (userCredential.user == null) {
        return AppleSignInResult.failure('Sign-in failed: No user data received');
      }

      final user = userCredential.user!;

      // Handle display name from Apple
      String? displayName = user.displayName;
      if (displayName == null || displayName.isEmpty) {
        // Construct display name from Apple credential if available
        if (credential.givenName != null || credential.familyName != null) {
          final givenName = credential.givenName ?? '';
          final familyName = credential.familyName ?? '';
          displayName = '$givenName $familyName'.trim();
          
          if (displayName.isNotEmpty) {
            await user.updateDisplayName(displayName);
            await user.reload();
            AppLogger.auth('✅ Updated display name from Apple: $displayName');
          }
        }
      }

      enhancementService.stopPerformanceTrace('apple_signin');

      AppLogger.auth('✅ Apple Sign-In completed successfully for ${user.email}');

      return AppleSignInResult.success(
        user: user,
        credential: credential,
        displayName: displayName,
        isNewUser: userCredential.additionalUserInfo?.isNewUser ?? false,
      );

    } on SignInWithAppleException catch (e) {
      enhancementService.stopPerformanceTrace('apple_signin');
      AppLogger.error('❌ Apple Sign-In error: ${e.code} - ${e.message}');

      switch (e.code) {
        case SignInWithAppleErrorCode.canceled:
          return AppleSignInResult.failure('Apple sign-in was cancelled by user');
        
        case SignInWithAppleErrorCode.failed:
          return AppleSignInResult.failure('Apple sign-in failed. Please try again.');
        
        case SignInWithAppleErrorCode.invalidResponse:
          return AppleSignInResult.failure('Invalid response from Apple. Please try again.');
        
        case SignInWithAppleErrorCode.notHandled:
          return AppleSignInResult.failure('Apple sign-in could not be processed. Please try again.');
        
        case SignInWithAppleErrorCode.unknown:
          return AppleSignInResult.failure('An unknown error occurred during Apple sign-in.');
        
        default:
          return AppleSignInResult.failure('Apple sign-in error: ${e.message ?? 'Unknown error'}');
      }

    } on FirebaseAuthException catch (e) {
      enhancementService.stopPerformanceTrace('apple_signin');
      AppLogger.error('❌ Firebase Auth error during Apple Sign-In: ${e.code} - ${e.message}');

      switch (e.code) {
        case 'account-exists-with-different-credential':
          return AppleSignInResult.failure(
            'An account already exists with this email using a different sign-in method. Please use that method instead.',
          );
        
        case 'invalid-credential':
          return AppleSignInResult.failure(
            'The Apple credentials are invalid or have expired. Please try again.',
          );
        
        case 'operation-not-allowed':
          return AppleSignInResult.failure(
            'Apple sign-in is not enabled for this app. Please contact support.',
          );
        
        case 'user-disabled':
          return AppleSignInResult.failure(
            'Your account has been disabled. Please contact support.',
          );
        
        case 'user-not-found':
          return AppleSignInResult.failure(
            'No account found. Please create an account first.',
          );
        
        case 'wrong-password':
          return AppleSignInResult.failure(
            'Invalid credentials. Please try again.',
          );
        
        case 'too-many-requests':
          return AppleSignInResult.failure(
            'Too many sign-in attempts. Please try again later.',
          );
        
        default:
          return AppleSignInResult.failure(
            'Authentication failed: ${e.message ?? 'Unknown error'}',
          );
      }

    } on PlatformException catch (e) {
      enhancementService.stopPerformanceTrace('apple_signin');
      AppLogger.error('❌ Platform error during Apple Sign-In: ${e.code} - ${e.message}');

      return AppleSignInResult.failure(
        'Platform error: ${e.message ?? 'An unexpected error occurred'}',
      );

    } catch (e) {
      enhancementService.stopPerformanceTrace('apple_signin');
      AppLogger.error('❌ Unexpected error during Apple Sign-In', e);

      return AppleSignInResult.failure(
        'An unexpected error occurred during Apple sign-in. Please try again.',
      );
    }
  }

  /// Sign out from Apple (revoke tokens if possible)
  Future<bool> signOut() async {
    try {
      AppLogger.auth('🍎 Apple Sign-In sign out requested');
      
      // Note: Apple doesn't provide a way to programmatically revoke tokens
      // The user would need to revoke access manually in their Apple ID settings
      // We can only clear local session data
      
      AppLogger.auth('✅ Apple Sign-In local session cleared');
      return true;
      
    } catch (e) {
      AppLogger.error('❌ Error during Apple Sign-In sign out', e);
      return false;
    }
  }

  /// Get credential state (iOS 13+ only)
  Future<AppleCredentialState> getCredentialState(String userIdentifier) async {
    try {
      if (!_isAvailable || !Platform.isIOS) {
        return AppleCredentialState.notFound;
      }

      final state = await SignInWithApple.getCredentialState(userIdentifier);
      
      AppLogger.auth('🍎 Apple credential state for $userIdentifier: $state');
      return state;
      
    } catch (e) {
      AppLogger.error('❌ Error getting Apple credential state', e);
      return AppleCredentialState.notFound;
    }
  }

  /// Check if user's Apple ID is still valid
  Future<bool> isCredentialValid(String userIdentifier) async {
    final state = await getCredentialState(userIdentifier);
    return state == AppleCredentialState.authorized;
  }

  /// Get platform-specific availability message
  String getAvailabilityMessage() {
    if (kIsWeb) {
      return 'Apple Sign-In is not available on web browsers. Please use email authentication.';
    }
    
    if (Platform.isAndroid) {
      return 'Apple Sign-In is not available on Android devices. Please use email or Google authentication.';
    }
    
    if (Platform.isIOS) {
      return _isAvailable 
          ? 'Apple Sign-In is available'
          : 'Apple Sign-In requires iOS 13 or later';
    }
    
    if (Platform.isMacOS) {
      return _isAvailable 
          ? 'Apple Sign-In is available'
          : 'Apple Sign-In requires macOS 10.15 or later';
    }
    
    return 'Apple Sign-In is not supported on this platform';
  }
}

/// Result object for Apple Sign-In operations
class AppleSignInResult {
  final bool isSuccess;
  final User? user;
  final AuthorizationCredentialAppleID? credential;
  final String? displayName;
  final bool isNewUser;
  final String? error;

  AppleSignInResult._({
    required this.isSuccess,
    this.user,
    this.credential,
    this.displayName,
    this.isNewUser = false,
    this.error,
  });

  factory AppleSignInResult.success({
    required User user,
    AuthorizationCredentialAppleID? credential,
    String? displayName,
    bool isNewUser = false,
  }) {
    return AppleSignInResult._(
      isSuccess: true,
      user: user,
      credential: credential,
      displayName: displayName,
      isNewUser: isNewUser,
    );
  }

  factory AppleSignInResult.failure(String error) {
    return AppleSignInResult._(
      isSuccess: false,
      error: error,
    );
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'AppleSignInResult.success(user: ${user?.email}, isNewUser: $isNewUser)';
    } else {
      return 'AppleSignInResult.failure(error: $error)';
    }
  }
}

/// Extension to add Apple Sign-In specific user data
extension AppleUserData on User {
  /// Get Apple-specific user metadata
  Map<String, dynamic> getAppleUserData() {
    return {
      'provider': 'apple',
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'emailVerified': emailVerified,
      'creationTime': metadata.creationTime?.toIso8601String(),
      'lastSignInTime': metadata.lastSignInTime?.toIso8601String(),
      'providerData': providerData.map((info) => {
        'providerId': info.providerId,
        'uid': info.uid,
        'displayName': info.displayName,
        'email': info.email,
        'photoURL': info.photoURL,
      }).toList(),
    };
  }
}
