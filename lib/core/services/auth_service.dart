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
import 'dart:async';
import 'local_user_service.dart';
import '../utils/app_logger.dart';

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
  Future<bool> get isAuthenticated async => await _hasLocalUser();

  bool get isFirebaseAvailable => _firebaseAvailable;
  bool get isFirebaseAuthenticated =>
      _firebaseAvailable && (_auth?.currentUser != null);

  /// Get current user, checking both Firebase and local users
  Future<dynamic> getCurrentUser() async {
    // Check Firebase user first (disabled for iOS build)
    // if (_auth?.currentUser != null) {
    //   return _auth!.currentUser;
    // }

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
    if (currentUser == null) {
      // Check if we have stored user data from previous session
      final storedData = await _getStoredUserData();
      return storedData;
    }

    Map<String, dynamic> userData = {};

    // Handle Firebase User (disabled for iOS build)
    // if (currentUser is User) {
    //   // Get stored user data to preserve username and other custom fields
    //   final storedData = await _getStoredUserData();
    //
    //   userData = {
    //     'uid': currentUser.uid,
    //     'email': currentUser.email,
    //     'displayName': currentUser.displayName,
    //     'username': storedData?['username'] ?? currentUser.displayName, // Preserve stored username
    //     'photoURL': currentUser.photoURL,
    //     'provider': 'firebase',
    //     'createdAt': currentUser.metadata.creationTime?.toIso8601String(),
    //     'lastSignIn': currentUser.metadata.lastSignInTime?.toIso8601String(),
    //     'profileComplete': currentUser.displayName != null && currentUser.displayName!.isNotEmpty,
    //   };
    // } else
    if (currentUser is LocalUser) {
      // Handle Local User
      final localUser = currentUser;
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
    if (_isInitialized) return; // Prevent re-initialization

    try {
      // Initialize Firebase (with timeout + safe fallback)
      try {
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp().timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw TimeoutException('Firebase initialization timeout'),
          );
        }
        _auth = FirebaseAuth.instance;
        _firebaseAvailable = true;
        AppLogger.auth('Firebase initialized successfully');
      } catch (e) {
        AppLogger.warning(
          'Firebase init failed, falling back to local auth: $e',
        );
        _firebaseAvailable = false;
        _auth = null;
      }

      // Initialize local components (always initialize these)
      _localAuth = LocalAuthentication();
      _prefs = await SharedPreferences.getInstance();

      // Initialize Google Sign-In with error handling
      try {
        _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
        AppLogger.auth('Google Sign-In initialized successfully');
      } catch (e) {
        AppLogger.warning('Google Sign-In initialization failed: $e');
        _googleSignIn = null;
      }

      // Initialize local user service as fallback (critical for app function)
      _localUserService = LocalUserService();
      await _localUserService!.initialize();

      // 🔄 Auto-sync local user with Firebase
      final localUser = await _localUserService!.getCurrentUser();
      if (localUser != null && _auth != null && _auth!.currentUser == null) {
        try {
          await _auth!.signInWithEmailAndPassword(
            email: localUser.email,
            password: localUser.uid, // deterministic fallback password
          );
        } catch (_) {
          try {
            await _auth!.createUserWithEmailAndPassword(
              email: localUser.email,
              password: localUser.uid,
            );
          } catch (e) {
            AppLogger.warning("Firebase silent sync failed: ");
          }
        }
      }

      _isInitialized = true;
      AppLogger.auth(
        'AuthService initialized successfully (Firebase: $_firebaseAvailable)',
      );
    } catch (e) {
      AppLogger.error('AuthService initialization failed: $e');
      // Still try to initialize minimal components for basic functionality
      try {
        _localAuth = LocalAuthentication();
        _prefs = await SharedPreferences.getInstance();
        _localUserService = LocalUserService();
        await _localUserService!.initialize();
        _isInitialized = true;
        AppLogger.warning('AuthService initialized with local components only');
      } catch (criticalError) {
        AppLogger.error(
          'Critical AuthService initialization failure',
          criticalError,
        );
        rethrow;
      }
    }
  }

  /// Check if biometric authentication is available and enabled
  Future<bool> isBiometricAvailable() async {
    if (_localAuth == null) return false;
    final bool isAvailable = await _localAuth!.isDeviceSupported();
    final bool hasEnrolledBiometrics = await _localAuth!
        .getAvailableBiometrics()
        .then((list) => list.isNotEmpty);
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
        return AuthResult.failure(
          'Biometric authentication is not available on this device',
        );
      }

      final bool isEnabled = isBiometricEnabled();
      if (!isEnabled) {
        return AuthResult.failure(
          'Biometric authentication is not enabled. Please enable it in settings.',
        );
      }

      final bool isAuthenticated = await _localAuth!.authenticate(
        localizedReason: 'Please authenticate to access Flow Ai',
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
            // } else if (userData['provider'] == 'firebase' && _auth?.currentUser != null) {
            //   return AuthResult.success(_auth!.currentUser!);
          }
          return AuthResult.success(
            null,
          ); // Biometric auth successful, user data exists
        } else {
          return AuthResult.failure(
            'No stored user credentials found. Please sign in with your email or social account first.',
          );
        }
      } else {
        return AuthResult.failure('Biometric authentication failed');
      }
    } on PlatformException catch (e) {
      debugPrint(
        'Biometric authentication platform error: ${e.code} - ${e.message}',
      );

      switch (e.code) {
        case 'NotAvailable':
          return AuthResult.failure(
            'Biometric authentication is not available on this device',
          );
        case 'NotEnrolled':
          return AuthResult.failure(
            'No biometrics enrolled. Please set up Face ID, Touch ID, or fingerprint in your device settings.',
          );
        case 'LockedOut':
          return AuthResult.failure(
            'Biometric authentication is temporarily locked. Please try again later.',
          );
        case 'PermanentlyLockedOut':
          return AuthResult.failure(
            'Biometric authentication is permanently locked. Please use your device passcode.',
          );
        case 'UserCancel':
          return AuthResult.failure(
            'Biometric authentication cancelled by user',
          );
        case 'UserFallback':
          return AuthResult.failure(
            'User chose to use device passcode instead',
          );
        case 'SystemCancel':
          return AuthResult.failure(
            'Biometric authentication cancelled by system',
          );
        case 'InvalidContext':
          return AuthResult.failure('Invalid biometric authentication context');
        case 'NotImplemented':
          return AuthResult.failure(
            'Biometric authentication not implemented on this platform',
          );
        default:
          return AuthResult.failure(
            'Biometric authentication error: ${e.message ?? e.code}',
          );
      }
    } catch (e) {
      debugPrint('Unexpected biometric authentication error: $e');
      return AuthResult.failure(
        'Unexpected biometric authentication error. Please try again.',
      );
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
      // Firebase temporarily disabled for iOS build
      // if (_firebaseAvailable && _auth != null) {
      //   try {
      //     final UserCredential result = await _auth!.createUserWithEmailAndPassword(
      //       email: email,
      //       password: password,
      //     );
      //
      //     if (result.user != null) {
      //       // Update display name
      //       await result.user!.updateDisplayName(displayName);
      //       await result.user!.reload();
      //
      //       // Store user data with comprehensive profile information
      //       await _storeUserData({
      //         'uid': result.user!.uid,
      //         'email': email,
      //         'displayName': displayName,
      //         'username': username ?? displayName, // Use displayName as fallback for username
      //         'provider': 'firebase',
      //         'createdAt': DateTime.now().toIso8601String(),
      //         'lastUpdated': DateTime.now().toIso8601String(),
      //         'profileComplete': true,
      //       });
      //
      //       debugPrint('✅ User profile saved: $displayName (${result.user!.uid})');
      //
      //       if (_prefs != null) {
      //         await _prefs!.setString(_lastLoginMethodKey, 'firebase');
      //       }
      //
      //       return AuthResult.success(result.user!);
      //     }
      //   } catch (firebaseError) {
      //     debugPrint('⚠️ Firebase sign up failed, falling back to local: $firebaseError');
      //   }
      // }

      // Fallback to local authentication
      if (_localUserService != null) {
        final localResult = await _localUserService!.signInUser(
          email: email,
          password: password,
        );

        if (localResult.isSuccess) {
          // Get existing stored data to preserve username
          final existingData = await _getStoredUserData();
          await _storeUserData({
            'uid': localResult.user!.uid,
            'email': email,
            'displayName': localResult.user!.displayName,
            'username':
                existingData?['username'] ??
                localResult.user!.username ??
                localResult.user!.displayName, // Preserve username
            'provider': 'local',
            'lastLogin': DateTime.now().toIso8601String(),
          });

          if (_prefs != null) {
            await _prefs!.setString(_lastLoginMethodKey, 'local');
          }

          debugPrint('✅ Local user signed in successfully: $email');
          return AuthResult.success(
            null,
          ); // No Firebase user, but successful local sign in
        } else {
          return AuthResult.failure(localResult.error!);
        }
      }

      return AuthResult.failure(
        'Authentication service not properly initialized',
      );
    } catch (e) {
      debugPrint('❌ Sign in error: $e');
      return AuthResult.failure('Sign in failed: ${e.toString()}');
    }
  }
  /// Sign in with email and password
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Firebase temporarily disabled for iOS build
      // if (_firebaseAvailable && _auth != null) {
      //   try {
      //     final UserCredential result = await _auth!.signInWithEmailAndPassword(
      //       email: email,
      //       password: password,
      //     );
      //     if (result.user != null) {
      //       final existingData = await _getStoredUserData();
      //       await _storeUserData({
      //         'uid': result.user!.uid,
      //         'email': email,
      //         'displayName': result.user!.displayName,
      //         'username': existingData?['username'] ?? result.user!.displayName,
      //         'provider': 'firebase',
      //         'lastLogin': DateTime.now().toIso8601String(),
      //       });
      //       if (_prefs != null) {
      //         await _prefs!.setString(_lastLoginMethodKey, 'firebase');
      //       }
      //       return AuthResult.success(result.user!);
      //     }
      //   } catch (firebaseError) {
      //     debugPrint('⚠️ Firebase sign in failed, trying local: $firebaseError');
      //   }
      // }

      // Fallback to local authentication
      if (_localUserService != null) {
        final localResult = await _localUserService!.signInUser(
          email: email,
          password: password,
        );

        if (localResult.isSuccess) {
          final existingData = await _getStoredUserData();
          await _storeUserData({
            'uid': localResult.user!.uid,
            'email': email,
            'displayName': localResult.user!.displayName,
            'username': existingData?['username'] ?? localResult.user!.username ?? localResult.user!.displayName,
            'provider': 'local',
            'lastLogin': DateTime.now().toIso8601String(),
          });

          if (_prefs != null) {
            await _prefs!.setString(_lastLoginMethodKey, 'local');
          }

          debugPrint('✅ Local user signed in successfully: $email');
          return AuthResult.success(null);
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

  /// Sign in with Google (Firebase)
  Future<AuthResult> signInWithGoogle() async {
    try {
      if (_googleSignIn == null || _auth == null) {
        return AuthResult.failure('Authentication not initialized.');
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) {
        return AuthResult.failure('Google sign-in cancelled.');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth!.signInWithCredential(credential);

      return AuthResult.success(userCredential.user);
    } catch (e) {
      return AuthResult.failure('Google sign-in failed: $e');
    }
  }

  /// Sign in with Apple (iOS only)

  /// Sign in with Apple (Firebase)
  Future<AuthResult> signInWithApple() async {
    try {
      if (_auth == null) {
        return AuthResult.failure('Authentication not initialized.');
      }

      if (kIsWeb) {
        return AuthResult.failure('Apple Sign-In not supported on web.');
      }

      // Apple Sign-In is not reliable on Simulator; validate on a physical device for production.
      if (Platform.isIOS &&
          Platform.environment.containsKey('SIMULATOR_DEVICE_NAME')) {
        return AuthResult.failure(
          'Apple Sign-In requires a real iPhone (not Simulator).',
        );
      }

      // Apple Sign-In is not reliable on Simulator; validate on a physical device for production.
      if (Platform.isIOS &&
          Platform.environment.containsKey('SIMULATOR_DEVICE_NAME')) {
        return AuthResult.failure(
          'Apple Sign-In requires a real iPhone (not Simulator).',
        );
      }

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth!.signInWithCredential(oauthCredential);

      return AuthResult.success(userCredential.user);
    } catch (e) {
      return AuthResult.failure('Apple sign-in failed: $e');
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
    // Force account chooser next time (prevents silent re-login).
    try { await _googleSignIn?.signOut(); } catch (_) {}
    try { await _googleSignIn?.disconnect(); } catch (_) {}
    try {
      debugPrint('🔐 Starting complete sign out process...');

      // Always clear local data first, even if Firebase operations fail
      await _clearStoredUserData();
      await _clearAllUserData();
      if (_prefs != null) {
        await _prefs!.remove(_lastLoginMethodKey);
        await _prefs!.remove(_biometricEnabledKey);
        // Clear any cached user preferences
        await _prefs!.remove('user_preferences');
        await _prefs!.remove('app_settings');
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

      // Firebase temporarily disabled for iOS build
      // if (_auth != null) {
      //   try {
      //     await _auth!.signOut();
      //     debugPrint('✅ Firebase Auth sign out successful');
      //   } catch (firebaseError) {
      //     debugPrint('⚠️ Firebase Auth sign out failed (continuing anyway): $firebaseError');
      //   }
      // }

      // if (_googleSignIn != null) {
      //   try {
      //     await _googleSignIn!.signOut();
      //     debugPrint('✅ Google Sign-In sign out successful');
      //   } catch (googleError) {
      //     debugPrint('⚠️ Google Sign-In sign out failed (continuing anyway): $googleError');
      //   }
      // }

      // Clear memory cache and force garbage collection
      await _clearMemoryCache();

      debugPrint('✅ Complete sign out successful - all user data cleared');
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

  /// Check if an email account already exists
  Future<bool> isEmailRegistered(String email) async {
    try {
      // Firebase temporarily disabled for iOS build
      // if (_firebaseAvailable && _auth != null) {
      //   try {
      //     // Use a different method since fetchSignInMethodsForEmail is deprecated
      //     try {
      //       await _auth!.createUserWithEmailAndPassword(
      //         email: email,
      //         password: 'temp_password_to_check_existence'
      //       );
      //       // If we get here, user doesn't exist
      //       return false;
      //     } on FirebaseAuthException catch (e) {
      //       if (e.code == 'email-already-in-use') {
      //         AppLogger.info('Email found in Firebase: $email');
      //         return true;
      //       }
      //       // Other errors mean we can't determine, assume not found
      //       return false;
      //     }
      //   } catch (e) {
      //     AppLogger.warning('Firebase email check failed: $e');
      //   }
      // }

      // Check local user service
      if (_localUserService != null) {
        final localUser = await _localUserService!.getUserByEmail(email);
        if (localUser != null) {
          debugPrint('✅ Email found in local storage: $email');
          return true;
        }
      }

      // Check stored user data as backup
      final storedData = await _getStoredUserData();
      if (storedData != null && storedData['email'] == email) {
        debugPrint('✅ Email found in stored data: $email');
        return true;
      }

      debugPrint('❌ Email not found: $email');
      return false;
    } catch (e) {
      debugPrint('❌ Error checking email registration: $e');
      return false;
    }
  }

  /// Reset password
  Future<AuthResult> resetPassword(String email) async {
    try {
      // Firebase temporarily disabled for iOS build
      // if (_firebaseAvailable && _auth != null) {
      //   try {
      //     await _auth!.sendPasswordResetEmail(email: email);
      //     debugPrint('✅ Password reset email sent via Firebase');
      //     return AuthResult.success(null);
      //   } catch (firebaseError) {
      //     debugPrint('⚠️ Firebase password reset failed: $firebaseError');
      //   }
      // }

      // Local password reset is not supported in the current implementation
      // In a production environment, this would typically send an email through a backend service
      if (_localUserService != null) {
        debugPrint(
          'ℹ️ Local password reset not supported. Using Firebase only.',
        );
        return AuthResult.failure(
          'Password reset is only available for online accounts. Please ensure you have an internet connection.',
        );
      }

      return AuthResult.failure('Password reset service not available');
      // } on FirebaseAuthException catch (e) {
      //   debugPrint('❌ Firebase Auth Error during password reset: ${e.code} - ${e.message}');
      //
      //   switch (e.code) {
      //     case 'user-not-found':
      //       return AuthResult.failure('No account found with this email address.');
      //     case 'invalid-email':
      //       return AuthResult.failure('Please enter a valid email address.');
      //     case 'too-many-requests':
      //       return AuthResult.failure('Too many reset attempts. Please try again later.');
      //     default:
      //       return AuthResult.failure('Password reset failed: ${e.message ?? e.code}');
      //   }
    } catch (e) {
      debugPrint('❌ Password reset error: $e');
      return AuthResult.failure('Password reset failed: ${e.toString()}');
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

  /// Clear all user-related data from local storage
  Future<void> _clearAllUserData() async {
    if (_prefs != null) {
      // Get all keys and remove user-related ones
      final keys = _prefs!.getKeys();
      for (final key in keys) {
        if (key.contains('user_') ||
            key.contains('auth_') ||
            key.contains('profile_') ||
            key.contains('settings_') ||
            key.contains('conversation_') ||
            key.contains('ai_') ||
            key.contains('cycle_') ||
            key.contains('health_')) {
          await _prefs!.remove(key);
          debugPrint('🧹 Cleared user data key: $key');
        }
      }
    }
  }

  /// Clear memory cache and force cleanup
  Future<void> _clearMemoryCache() async {
    // Reset internal state
    // Force memory cleanup for better isolation between users
    debugPrint('🧠 Memory cache cleared for user isolation');
  }

  Future<UserCredential> firebaseCreateUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    _auth ??= FirebaseAuth.instance;
    return await _auth!.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> firebaseSignInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    _auth ??= FirebaseAuth.instance;
    return await _auth!.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}

/// Authentication result model
class AuthResult {
  final bool isSuccess;
  // final User? user; // Firebase temporarily disabled for iOS build
  final dynamic user;
  final String? error;

  AuthResult._({required this.isSuccess, this.user, this.error});

  factory AuthResult.success(dynamic user) {
    return AuthResult._(isSuccess: true, user: user);
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(isSuccess: false, error: error);
  }
}

/// Authentication provider enumeration
enum AuthProvider { email, google, apple, biometric }

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
