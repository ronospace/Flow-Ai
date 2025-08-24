import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'local_user_service.dart';

/// Enhanced Authentication Service with biometric and multi-provider OAuth
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  FirebaseAuth? _auth;
  LocalAuthentication? _localAuth;
  GoogleSignIn? _googleSignIn;
  SharedPreferences? _prefs;
  LocalUserService? _localUserService;
  bool _isInitialized = false;
  bool _firebaseAvailable = false;

  static const String _userDataKey = 'user_data';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _lastLoginMethodKey = 'last_login_method';

  User? get currentUser => _auth?.currentUser;
  bool get isInitialized => _isInitialized;
  Future<bool> get isAuthenticated async => _auth?.currentUser != null || await _hasLocalUser();
  
  /// Get current user, checking both Firebase and local users
  Future<dynamic> getCurrentUser() async {
    // Check Firebase user first
    if (_auth?.currentUser != null) {
      return _auth!.currentUser;
    }
    
    // Check local user session
    if (_localUserService != null) {
      final localUser = await _localUserService!.getCurrentUser();
      if (localUser != null) {
        final isValidSession = await _localUserService!.isUserSessionValid();
        if (isValidSession) {
          return localUser;
        }
      }
    }
    
    return null;
  }
  
  /// Get comprehensive user data for UI display and persistence
  Future<Map<String, dynamic>?> getUserData() async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) return null;
    
    Map<String, dynamic> userData = {};
    
    // Handle Firebase User
    if (currentUser is User) {
      userData = {
        'uid': currentUser.uid,
        'email': currentUser.email,
        'displayName': currentUser.displayName,
        'username': currentUser.displayName, // Fallback to displayName
        'photoURL': currentUser.photoURL,
        'provider': 'firebase',
        'createdAt': currentUser.metadata.creationTime?.toIso8601String(),
        'lastSignIn': currentUser.metadata.lastSignInTime?.toIso8601String(),
        'profileComplete': currentUser.displayName != null && currentUser.displayName!.isNotEmpty,
      };
    } else if (currentUser is LocalUser) {
      // Handle Local User
      final localUser = currentUser as LocalUser;
      userData = {
        'uid': localUser.uid,
        'email': localUser.email,
        'displayName': localUser.displayName,
        'username': localUser.username ?? localUser.displayName,
        'photoURL': null,
        'provider': 'local',
        'createdAt': localUser.createdAt.toIso8601String(),
        'lastSignIn': localUser.lastLogin.toIso8601String(),
        'profileComplete': true, // Local users always have complete profiles
      };
    }
    
    return userData.isNotEmpty ? userData : null;
  }
  
  Future<bool> _hasLocalUser() async {
    // Check if we have a valid local user session
    final isValid = await _localUserService?.isUserSessionValid();
    return isValid == true;
  }

  Future<void> initialize() async {
    try {
      // Try to initialize Firebase
      try {
        await Firebase.initializeApp();
        _auth = FirebaseAuth.instance;
        _firebaseAvailable = true;
        debugPrint('✅ Firebase initialized successfully');
      } catch (e) {
        debugPrint('⚠️ Firebase initialization failed, using local auth: $e');
        _firebaseAvailable = false;
      }
      
      // Initialize local components
      _localAuth = LocalAuthentication();
      _googleSignIn = GoogleSignIn();
      _prefs = await SharedPreferences.getInstance();
      
      // Initialize local user service as fallback
      _localUserService = LocalUserService();
      await _localUserService!.initialize();
      
      _isInitialized = true;
      debugPrint('✅ AuthService initialized successfully (Firebase: $_firebaseAvailable)');
    } catch (e) {
      debugPrint('❌ AuthService initialization failed: $e');
      // Still try to initialize minimal components
      _localAuth = LocalAuthentication();
      _prefs = await SharedPreferences.getInstance();
      _localUserService = LocalUserService();
      await _localUserService!.initialize();
      _isInitialized = true;
      rethrow;
    }
  }

  /// Check if biometric authentication is available and enabled
  Future<bool> isBiometricAvailable() async {
    if (_localAuth == null) return false;
    final bool isAvailable = await _localAuth!.isDeviceSupported();
    final bool hasEnrolledBiometrics = await _localAuth!.getAvailableBiometrics().then((list) => list.isNotEmpty);
    return isAvailable && hasEnrolledBiometrics;
  }

  /// Enable/disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    if (_prefs != null) {
      await _prefs!.setBool(_biometricEnabledKey, enabled);
    }
  }

  /// Check if biometric authentication is enabled
  bool isBiometricEnabled() {
    return _prefs?.getBool(_biometricEnabledKey) ?? false;
  }

  /// Authenticate using biometrics
  Future<AuthResult> authenticateWithBiometrics() async {
    try {
      if (_localAuth == null) {
        return AuthResult.failure('Biometric authentication not initialized');
      }
      
      final bool isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return AuthResult.failure('Biometric authentication is not available on this device');
      }
      
      final bool isEnabled = isBiometricEnabled();
      if (!isEnabled) {
        return AuthResult.failure('Biometric authentication is not enabled. Please enable it in settings.');
      }

      final bool isAuthenticated = await _localAuth!.authenticate(
        localizedReason: 'Please authenticate to access ZyraFlow',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        // If biometric auth succeeds, check if we have stored credentials
        final userData = await _getStoredUserData();
        if (userData != null) {
          // Try to authenticate with stored credentials
          if (userData['provider'] == 'local' && _localUserService != null) {
            final sessionValid = await _localUserService!.isUserSessionValid();
            if (sessionValid) {
              return AuthResult.success(null); // Local user authenticated
            }
          } else if (userData['provider'] == 'firebase' && _auth?.currentUser != null) {
            return AuthResult.success(_auth!.currentUser!);
          }
          return AuthResult.success(null); // Biometric auth successful, user data exists
        } else {
          return AuthResult.failure('No stored user credentials found. Please sign in with your email or social account first.');
        }
      } else {
        return AuthResult.failure('Biometric authentication failed');
      }
    } on PlatformException catch (e) {
      debugPrint('Biometric authentication platform error: ${e.code} - ${e.message}');
      
      switch (e.code) {
        case 'NotAvailable':
          return AuthResult.failure('Biometric authentication is not available on this device');
        case 'NotEnrolled':
          return AuthResult.failure('No biometrics enrolled. Please set up Face ID, Touch ID, or fingerprint in your device settings.');
        case 'LockedOut':
          return AuthResult.failure('Biometric authentication is temporarily locked. Please try again later.');
        case 'PermanentlyLockedOut':
          return AuthResult.failure('Biometric authentication is permanently locked. Please use your device passcode.');
        case 'UserCancel':
          return AuthResult.failure('Biometric authentication cancelled by user');
        case 'UserFallback':
          return AuthResult.failure('User chose to use device passcode instead');
        case 'SystemCancel':
          return AuthResult.failure('Biometric authentication cancelled by system');
        case 'InvalidContext':
          return AuthResult.failure('Invalid biometric authentication context');
        case 'NotImplemented':
          return AuthResult.failure('Biometric authentication not implemented on this platform');
        default:
          return AuthResult.failure('Biometric authentication error: ${e.message ?? e.code}');
      }
    } catch (e) {
      debugPrint('Unexpected biometric authentication error: $e');
      return AuthResult.failure('Unexpected biometric authentication error. Please try again.');
    }
  }

  /// Sign up with email and password
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    String? username,
  }) async {
    try {
      // Try Firebase first if available
      if (_firebaseAvailable && _auth != null) {
        try {
          final UserCredential result = await _auth!.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          if (result.user != null) {
            // Update display name
            await result.user!.updateDisplayName(displayName);
            await result.user!.reload();

            // Store user data with comprehensive profile information
            await _storeUserData({
              'uid': result.user!.uid,
              'email': email,
              'displayName': displayName,
              'username': username ?? displayName, // Use displayName as fallback for username
              'provider': 'firebase',
              'createdAt': DateTime.now().toIso8601String(),
              'lastUpdated': DateTime.now().toIso8601String(),
              'profileComplete': true,
            });
            
            debugPrint('✅ User profile saved: $displayName (${result.user!.uid})');

            if (_prefs != null) {
              await _prefs!.setString(_lastLoginMethodKey, 'firebase');
            }

            return AuthResult.success(result.user!);
          }
        } catch (firebaseError) {
          debugPrint('⚠️ Firebase sign up failed, falling back to local: $firebaseError');
        }
      }

      // Fallback to local authentication
      if (_localUserService != null) {
        final localResult = await _localUserService!.createUser(
          email: email,
          password: password,
          displayName: displayName,
          username: username,
        );

        if (localResult.isSuccess) {
          // Store comprehensive user profile data
          await _storeUserData({
            'uid': localResult.user!.uid,
            'email': email,
            'displayName': displayName,
            'username': username ?? displayName, // Use displayName as fallback for username
            'provider': 'local',
            'createdAt': DateTime.now().toIso8601String(),
            'lastUpdated': DateTime.now().toIso8601String(),
            'profileComplete': true,
          });
          
          debugPrint('✅ Local user profile saved: $displayName ($email)');

          if (_prefs != null) {
            await _prefs!.setString(_lastLoginMethodKey, 'local');
          }

          debugPrint('✅ Local user created successfully: $email');
          return AuthResult.success(null); // No Firebase user, but successful local creation
        } else {
          return AuthResult.failure(localResult.error!);
        }
      }

      return AuthResult.failure('Authentication service not properly initialized');
    } catch (e) {
      debugPrint('❌ Sign up error: $e');
      return AuthResult.failure('Sign up failed: ${e.toString()}');
    }
  }

  /// Sign in with email and password
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Try Firebase first if available
      if (_firebaseAvailable && _auth != null) {
        try {
          final UserCredential result = await _auth!.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          if (result.user != null) {
            await _storeUserData({
              'uid': result.user!.uid,
              'email': email,
              'displayName': result.user!.displayName,
              'provider': 'firebase',
              'lastLogin': DateTime.now().toIso8601String(),
            });

            if (_prefs != null) {
              await _prefs!.setString(_lastLoginMethodKey, 'firebase');
            }

            return AuthResult.success(result.user!);
          }
        } catch (firebaseError) {
          debugPrint('⚠️ Firebase sign in failed, trying local: $firebaseError');
        }
      }

      // Fallback to local authentication
      if (_localUserService != null) {
        final localResult = await _localUserService!.signInUser(
          email: email,
          password: password,
        );

        if (localResult.isSuccess) {
          await _storeUserData({
            'uid': localResult.user!.uid,
            'email': email,
            'displayName': localResult.user!.displayName,
            'provider': 'local',
            'lastLogin': DateTime.now().toIso8601String(),
          });

          if (_prefs != null) {
            await _prefs!.setString(_lastLoginMethodKey, 'local');
          }

          debugPrint('✅ Local user signed in successfully: $email');
          return AuthResult.success(null); // No Firebase user, but successful local sign in
        } else {
          return AuthResult.failure(localResult.error!);
        }
      }

      return AuthResult.failure('Authentication service not properly initialized');
    } catch (e) {
      debugPrint('❌ Sign in error: $e');
      return AuthResult.failure('Sign in failed: ${e.toString()}');
    }
  }

  /// Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Check if Google Sign-In is available on this platform
      if (kIsWeb) {
        // For web, we need Firebase configuration
        if (!_firebaseAvailable) {
          return AuthResult.failure('Google Sign-In is not available on this platform. Please use email authentication instead.');
        }
      }
      
      if (_googleSignIn == null) {
        return AuthResult.failure('Google Sign-In not initialized');
      }
      
      // For platforms without Firebase, provide fallback
      if (!_firebaseAvailable) {
        debugPrint('⚠️ Firebase not available, using mock Google sign-in for development');
        // In a real app, you'd implement platform-specific Google auth here
        // For now, we'll return a helpful error message
        return AuthResult.failure('Google Sign-In requires additional platform configuration. Please use email authentication for now.');
      }
      
      if (_auth == null) {
        return AuthResult.failure('Authentication service not properly configured');
      }

      // Attempt Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) {
        return AuthResult.failure('Google sign-in cancelled by user');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        return AuthResult.failure('Failed to get Google authentication tokens');
      }
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await _auth!.signInWithCredential(credential);

      if (result.user != null) {
        await _storeUserData({
          'uid': result.user!.uid,
          'email': result.user!.email,
          'displayName': result.user!.displayName,
          'photoURL': result.user!.photoURL,
          'provider': 'google',
          'lastLogin': DateTime.now().toIso8601String(),
        });

        if (_prefs != null) {
          await _prefs!.setString(_lastLoginMethodKey, 'google');
        }

        debugPrint('✅ Google Sign-In successful: ${result.user!.email}');
        return AuthResult.success(result.user!);
      }

      return AuthResult.failure('Failed to sign in with Google: No user returned');
    } on PlatformException catch (e) {
      debugPrint('❌ Google Sign-In Platform Error: ${e.code} - ${e.message}');
      
      switch (e.code) {
        case 'sign_in_failed':
          return AuthResult.failure('Google sign-in failed. Please check your internet connection and try again.');
        case 'network_error':
          return AuthResult.failure('Network error. Please check your internet connection.');
        case 'sign_in_canceled':
          return AuthResult.failure('Google sign-in was cancelled.');
        case 'sign_in_required':
          return AuthResult.failure('Google sign-in is required but not available.');
        default:
          return AuthResult.failure('Google sign-in error: ${e.message ?? e.code}');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      
      switch (e.code) {
        case 'account-exists-with-different-credential':
          return AuthResult.failure('An account already exists with this email using a different sign-in method.');
        case 'invalid-credential':
          return AuthResult.failure('The Google credentials are invalid or expired.');
        case 'operation-not-allowed':
          return AuthResult.failure('Google sign-in is not enabled. Please contact support.');
        case 'user-disabled':
          return AuthResult.failure('This Google account has been disabled.');
        default:
          return AuthResult.failure('Authentication error: ${e.message ?? e.code}');
      }
    } catch (e) {
      debugPrint('❌ Unexpected Google Sign-In error: $e');
      return AuthResult.failure('Unexpected error during Google sign-in. Please try again or use email authentication.');
    }
  }

  /// Sign in with Apple (iOS only)
  Future<AuthResult> signInWithApple() async {
    try {
      // Check platform availability
      if (kIsWeb) {
        return AuthResult.failure('Apple Sign-In is not available on web. Please use email authentication instead.');
      }
      
      if (!Platform.isIOS) {
        return AuthResult.failure('Apple Sign-In is only available on iOS devices.');
      }

      // Check if Firebase is available for Apple Sign-In
      if (!_firebaseAvailable) {
        return AuthResult.failure('Apple Sign-In requires additional platform configuration. Please use email authentication for now.');
      }
      
      if (_auth == null) {
        return AuthResult.failure('Authentication service not properly configured');
      }

      // Check if Apple Sign-In is available on this device
      final bool isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        return AuthResult.failure('Apple Sign-In is not available on this device. Please use email authentication instead.');
      }

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final UserCredential result = await _auth!.signInWithCredential(oauthCredential);

      if (result.user != null) {
        // For Apple Sign-In, we might need to construct display name from givenName and familyName
        String? displayName = result.user!.displayName;
        if (displayName == null && credential.givenName != null) {
          displayName = '${credential.givenName} ${credential.familyName ?? ''}'.trim();
          await result.user!.updateDisplayName(displayName);
          await result.user!.reload();
        }

        await _storeUserData({
          'uid': result.user!.uid,
          'email': result.user!.email,
          'displayName': displayName,
          'provider': 'apple',
          'lastLogin': DateTime.now().toIso8601String(),
        });

        if (_prefs != null) {
          await _prefs!.setString(_lastLoginMethodKey, 'apple');
        }

        debugPrint('✅ Apple Sign-In successful: ${result.user!.email}');
        return AuthResult.success(result.user!);
      }

      return AuthResult.failure('Failed to sign in with Apple: No user returned');
    } on SignInWithAppleException catch (e) {
      debugPrint('❌ Apple Sign-In Error: ${e.toString()}');
      
      // Handle different Apple Sign-In errors
      final errorMessage = e.toString();
      if (errorMessage.contains('canceled') || errorMessage.contains('cancelled')) {
        return AuthResult.failure('Apple sign-in was cancelled.');
      } else if (errorMessage.contains('failed')) {
        return AuthResult.failure('Apple sign-in failed. Please try again.');
      } else if (errorMessage.contains('invalid')) {
        return AuthResult.failure('Invalid response from Apple. Please try again.');
      } else {
        return AuthResult.failure('Apple sign-in error. Please try again.');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      
      switch (e.code) {
        case 'account-exists-with-different-credential':
          return AuthResult.failure('An account already exists with this email using a different sign-in method.');
        case 'invalid-credential':
          return AuthResult.failure('The Apple credentials are invalid or expired.');
        case 'operation-not-allowed':
          return AuthResult.failure('Apple sign-in is not enabled. Please contact support.');
        case 'user-disabled':
          return AuthResult.failure('This Apple account has been disabled.');
        default:
          return AuthResult.failure('Authentication error: ${e.message ?? e.code}');
      }
    } on PlatformException catch (e) {
      debugPrint('❌ Apple Sign-In Platform Error: ${e.code} - ${e.message}');
      return AuthResult.failure('Apple sign-in platform error: ${e.message ?? e.code}');
    } catch (e) {
      debugPrint('❌ Unexpected Apple Sign-In error: $e');
      return AuthResult.failure('Unexpected error during Apple sign-in. Please try again or use email authentication.');
    }
  }

  /// Update user profile
  Future<AuthResult> updateProfile({
    String? displayName,
    String? username,
    String? photoURL,
  }) async {
    try {
      if (currentUser == null) {
        return AuthResult.failure('No user signed in');
      }

      if (displayName != null) {
        await currentUser!.updateDisplayName(displayName);
      }

      if (photoURL != null) {
        await currentUser!.updatePhotoURL(photoURL);
      }

      await currentUser!.reload();

      // Update stored user data
      final userData = await _getStoredUserData();
      if (userData != null) {
        userData['displayName'] = displayName ?? userData['displayName'];
        userData['username'] = username ?? userData['username'];
        userData['photoURL'] = photoURL ?? userData['photoURL'];
        userData['updatedAt'] = DateTime.now().toIso8601String();
        await _storeUserData(userData);
      }

      return AuthResult.success(currentUser!);
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }


  /// Get last used login method
  String? getLastLoginMethod() {
    return _prefs?.getString(_lastLoginMethodKey);
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      // Always clear local data first, even if Firebase operations fail
      await _clearStoredUserData();
      if (_prefs != null) {
        await _prefs!.remove(_lastLoginMethodKey);
      }
      
      // Clear local user service data
      if (_localUserService != null) {
        try {
          await _localUserService!.signOut();
          debugPrint('✅ Local user service sign out successful');
        } catch (localError) {
          debugPrint('⚠️ Local user service sign out failed: $localError');
        }
      }
      
      // Try Firebase sign out operations, but don't fail if they don't work
      if (_auth != null) {
        try {
          await _auth!.signOut();
          debugPrint('✅ Firebase Auth sign out successful');
        } catch (firebaseError) {
          debugPrint('⚠️ Firebase Auth sign out failed (continuing anyway): $firebaseError');
        }
      }
      
      if (_googleSignIn != null) {
        try {
          await _googleSignIn!.signOut();
          debugPrint('✅ Google Sign-In sign out successful');
        } catch (googleError) {
          debugPrint('⚠️ Google Sign-In sign out failed (continuing anyway): $googleError');
        }
      }
      
      debugPrint('✅ Sign out completed successfully');
    } catch (e) {
      debugPrint('❌ Critical sign out error: $e');
      // Still try to clear local data even if everything else fails
      try {
        await _clearStoredUserData();
        if (_prefs != null) {
          await _prefs!.remove(_lastLoginMethodKey);
        }
        if (_localUserService != null) {
          await _localUserService!.signOut();
        }
        debugPrint('✅ Local data cleared despite errors');
      } catch (localError) {
        debugPrint('❌ Even local data clearing failed: $localError');
      }
    }
  }

  /// Reset password
  Future<AuthResult> resetPassword(String email) async {
    try {
      if (_auth != null) {
        await _auth!.sendPasswordResetEmail(email: email);
      } else {
        return AuthResult.failure('Authentication service not initialized');
      }
      return AuthResult.success(null);
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  /// Delete account
  Future<AuthResult> deleteAccount() async {
    try {
      if (currentUser == null) {
        return AuthResult.failure('No user signed in');
      }

      await currentUser!.delete();
      await _clearStoredUserData();
      if (_prefs != null) {
        await _prefs!.remove(_lastLoginMethodKey);
        await _prefs!.remove(_biometricEnabledKey);
      }

      return AuthResult.success(null);
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  Future<void> _storeUserData(Map<String, dynamic> userData) async {
    if (_prefs != null) {
      await _prefs!.setString(_userDataKey, json.encode(userData));
    }
  }

  Future<Map<String, dynamic>?> _getStoredUserData() async {
    if (_prefs == null) return null;
    final userDataString = _prefs!.getString(_userDataKey);
    if (userDataString != null) {
      return Map<String, dynamic>.from(json.decode(userDataString));
    }
    return null;
  }

  Future<void> _clearStoredUserData() async {
    if (_prefs != null) {
      await _prefs!.remove(_userDataKey);
    }
  }
}

/// Authentication result model
class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? error;

  AuthResult._({
    required this.isSuccess,
    this.user,
    this.error,
  });

  factory AuthResult.success(User? user) {
    return AuthResult._(
      isSuccess: true,
      user: user,
    );
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(
      isSuccess: false,
      error: error,
    );
  }
}

/// Authentication provider enumeration
enum AuthProvider {
  email,
  google,
  apple,
  biometric,
}

extension AuthProviderExtension on AuthProvider {
  String get displayName {
    switch (this) {
      case AuthProvider.email:
        return 'Email';
      case AuthProvider.google:
        return 'Google';
      case AuthProvider.apple:
        return 'Apple';
      case AuthProvider.biometric:
        return 'Biometric';
    }
  }

  IconData get icon {
    switch (this) {
      case AuthProvider.email:
        return Icons.email;
      case AuthProvider.google:
        return Icons.g_mobiledata;
      case AuthProvider.apple:
        return Icons.apple;
      case AuthProvider.biometric:
        return Icons.fingerprint;
    }
  }
}
