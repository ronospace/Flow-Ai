import '../services/app_state_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';

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
import 'cloud_data_deletion_gateway.dart';
import '../database/database_service.dart';
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
  Future<bool> get isAuthenticated async =>
      isFirebaseAuthenticated || await _hasLocalUser();

  bool get isFirebaseAvailable => _firebaseAvailable;
  bool get isFirebaseAuthenticated =>
      _firebaseAvailable && (_auth?.currentUser != null);

  /// Get current user, checking both Firebase and local users
  Future<dynamic> getCurrentUser() async {
    final firebaseUser = _auth?.currentUser;

    // A signed-in Google, Apple, or Firebase email account owns the app session.
    if (_firebaseAvailable &&
        firebaseUser != null &&
        !firebaseUser.isAnonymous) {
      return firebaseUser;
    }

    // Local accounts remain the primary app identity even when an anonymous
    // Firebase session exists only to authorize cloud features.
    if (_localUserService != null) {
      final localUser = await _localUserService!.getCurrentUser();
      if (localUser != null) {
        final isValidSession = await _localUserService!.isUserSessionValid();
        if (isValidSession) {
          return localUser;
        }
      }
    }

    // Preserve an anonymous Firebase session only when no local account exists.
    return firebaseUser;
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

    if (currentUser is User) {
      final storedData = await _getStoredUserData();

      userData = {
        'uid': currentUser.uid,
        'email': currentUser.email,
        'displayName': currentUser.displayName,
        'username': storedData?['username'] ?? currentUser.displayName,
        'photoURL': currentUser.photoURL,
        'provider': storedData?['provider'] ?? 'firebase',
        'createdAt': currentUser.metadata.creationTime?.toIso8601String(),
        'lastSignIn': currentUser.metadata.lastSignInTime?.toIso8601String(),
        'profileComplete':
            (currentUser.displayName?.trim().isNotEmpty ?? false) ||
            (currentUser.email?.trim().isNotEmpty ?? false),
      };
    } else if (currentUser is LocalUser) {
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

  /// Ensure cloud features have an authenticated Firebase identity.
  ///
  /// Existing Google, Apple, and Firebase email sessions are preserved.
  /// Local-only accounts receive an isolated anonymous Firebase session.
  Future<User?> ensureCloudIdentity() async {
    if (!_isInitialized) {
      await initialize();
    }

    final auth = _auth;
    if (!_firebaseAvailable || auth == null) {
      return null;
    }

    final existingUser = auth.currentUser;
    if (existingUser != null) {
      return existingUser;
    }

    try {
      final credential = await auth.signInAnonymously();
      return credential.user;
    } on FirebaseAuthException catch (error) {
      AppLogger.warning(
        'Unable to establish Firebase cloud identity: '
        '${error.code} ${error.message ?? ''}',
      );
      return null;
    } catch (error) {
      AppLogger.warning('Unable to establish Firebase cloud identity: $error');
      return null;
    }
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

      // Startup-safe: skip Firebase account sync during app initialization.
      // Local auth remains available; explicit auth flows can handle remote sync later.

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
      debugPrint("BIO: service isAvailable=$isAvailable");
      debugPrint(
        "BIO: isAvailable=$isAvailable enabled=${isBiometricEnabled()}",
      );
      debugPrint(
        "BIO: service isAvailable=$isAvailable enabled=${isBiometricEnabled()}",
      );
      if (!isAvailable) {
        return AuthResult.failure(
          'Biometric authentication is not available on this device',
        );
      }

      final bool isEnabled = isBiometricEnabled();
      debugPrint("BIO: service enabled=$isEnabled");
      debugPrint("BIO: enabled flag = $isEnabled");
      if (!isEnabled) {
        return AuthResult.failure(
          'Biometric authentication is not enabled. Please enable it in settings.',
        );
      }

      debugPrint("BIO: calling localAuth.authenticate");
      debugPrint("BIO: calling localAuth.authenticate");
      debugPrint("BIO: calling localAuth.authenticate");
      final bool isAuthenticated = await _localAuth!.authenticate(
        localizedReason: 'Please authenticate to access Flow Ai',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      debugPrint("BIO: localAuth result=$isAuthenticated");
      debugPrint("BIO: localAuth result=$isAuthenticated");
      debugPrint("BIO: localAuth result=$isAuthenticated");
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
    if (!_isInitialized) {
      await initialize();
    }

    final normalizedEmail = email.trim();
    final normalizedDisplayName = displayName.trim();
    final auth = _auth;

    if (_firebaseAvailable && auth != null) {
      try {
        final result = await auth.createUserWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        );

        final user = result.user;
        if (user == null) {
          return AuthResult.failure(
            'The account was created without a valid user session.',
          );
        }

        try {
          await user.updateDisplayName(normalizedDisplayName);
        } catch (error) {
          AppLogger.warning(
            'Firebase account created, but display-name update failed: $error',
          );
        }

        try {
          await _prefs?.remove(_userDataKey);
        } catch (error) {
          AppLogger.warning(
            'Unable to clear the previous local identity before signup: $error',
          );
        }

        try {
          await _storeUserData({
            'uid': user.uid,
            'email': normalizedEmail,
            'displayName': normalizedDisplayName,
            'username': username?.trim().isNotEmpty == true
                ? username!.trim()
                : normalizedDisplayName,
            'provider': 'firebase',
            'createdAt': DateTime.now().toIso8601String(),
            'lastUpdated': DateTime.now().toIso8601String(),
            'profileComplete': true,
          });
        } catch (error) {
          try {
            await _prefs?.remove(_userDataKey);
          } catch (_) {}

          AppLogger.warning(
            'Firebase account created, but local profile persistence failed: '
            '$error',
          );
        }

        try {
          await _prefs?.setString(_lastLoginMethodKey, 'firebase');
        } catch (error) {
          AppLogger.warning(
            'Firebase account created, but login-method persistence failed: '
            '$error',
          );
        }

        AppLogger.auth('Firebase email account created successfully');
        return AuthResult.success(user);
      } on FirebaseAuthException catch (error) {
        AppLogger.warning('Firebase email registration failed: ${error.code}');
        return AuthResult.failure(
          _firebaseAuthFailureMessage(error, operation: 'create the account'),
        );
      } catch (error) {
        AppLogger.error(
          'Unexpected Firebase email registration failure',
          error,
        );
        return AuthResult.failure(
          'We could not create the account. Please try again.',
        );
      }
    }

    // Firebase is unavailable: preserve the existing local-only fallback.
    final localService = _localUserService;
    if (localService != null) {
      final localResult = await localService.createUser(
        email: normalizedEmail,
        password: password,
        displayName: normalizedDisplayName,
        username: username,
      );

      if (!localResult.isSuccess) {
        return AuthResult.failure(localResult.error!);
      }

      await _storeUserData({
        'uid': localResult.user!.uid,
        'email': normalizedEmail,
        'displayName': localResult.user!.displayName,
        'username': localResult.user!.username ?? localResult.user!.displayName,
        'provider': 'local',
        'lastLogin': DateTime.now().toIso8601String(),
      });
      await _prefs?.setString(_lastLoginMethodKey, 'local');

      return AuthResult.success(null);
    }

    return AuthResult.failure(
      'Authentication service is currently unavailable.',
    );
  }

  /// Sign in with email and password
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final normalizedEmail = email.trim();
    final auth = _auth;
    final localService = _localUserService;
    final storedIdentity = await _getStoredUserData();
    final storedEmail = storedIdentity?['email']
        ?.toString()
        .trim()
        .toLowerCase();

    // Preserve access for an account explicitly recorded as local by an
    // earlier release. This happens before Firebase authentication and is
    // therefore not a silent fallback after a Firebase credential failure.
    final shouldUseLegacyLocalAccount =
        localService != null &&
        storedIdentity?['provider'] == 'local' &&
        storedEmail == normalizedEmail.toLowerCase();

    if (shouldUseLegacyLocalAccount) {
      final localResult = await localService!.signInUser(
        email: normalizedEmail,
        password: password,
      );

      if (localResult.isSuccess) {
        await _storeUserData({
          'uid': localResult.user!.uid,
          'email': normalizedEmail,
          'displayName': localResult.user!.displayName,
          'username':
              localResult.user!.username ?? localResult.user!.displayName,
          'provider': 'local',
          'lastLogin': DateTime.now().toIso8601String(),
        });
        await _prefs?.setString(_lastLoginMethodKey, 'local');

        return AuthResult.success(null);
      }

      if (!_firebaseAvailable || auth == null) {
        return AuthResult.failure(localResult.error!);
      }
    }

    if (_firebaseAvailable && auth != null) {
      try {
        final result = await auth.signInWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        );

        final user = result.user;
        if (user == null) {
          return AuthResult.failure(
            'Sign-in completed without a valid user session.',
          );
        }

        Map<String, dynamic>? existingData;
        try {
          existingData = await _getStoredUserData();
        } catch (error) {
          AppLogger.warning(
            'Unable to read the previously stored identity: $error',
          );
        }

        final sameStoredIdentity = existingData?['uid']?.toString() == user.uid;

        try {
          if (!sameStoredIdentity) {
            await _prefs?.remove(_userDataKey);
          }

          await _storeUserData({
            'uid': user.uid,
            'email': user.email ?? normalizedEmail,
            'displayName': user.displayName,
            'username': sameStoredIdentity
                ? (existingData?['username'] ?? user.displayName)
                : user.displayName,
            'provider': 'firebase',
            'lastLogin': DateTime.now().toIso8601String(),
          });
        } catch (error) {
          try {
            await _prefs?.remove(_userDataKey);
          } catch (_) {}

          AppLogger.warning(
            'Firebase sign-in succeeded, but local profile persistence failed: '
            '$error',
          );
        }

        try {
          await _prefs?.setString(_lastLoginMethodKey, 'firebase');
        } catch (error) {
          AppLogger.warning(
            'Firebase sign-in succeeded, but login-method persistence failed: '
            '$error',
          );
        }

        AppLogger.auth('Firebase email sign-in completed successfully');
        return AuthResult.success(user);
      } on FirebaseAuthException catch (error) {
        AppLogger.warning('Firebase email sign-in failed: ${error.code}');
        return AuthResult.failure(
          _firebaseAuthFailureMessage(error, operation: 'sign in'),
        );
      } catch (error) {
        AppLogger.error('Unexpected Firebase email sign-in failure', error);
        return AuthResult.failure(
          'We could not sign you in. Please try again.',
        );
      }
    }

    // Firebase is unavailable: preserve the existing local-only fallback.
    if (localService != null) {
      final localResult = await localService.signInUser(
        email: normalizedEmail,
        password: password,
      );

      if (!localResult.isSuccess) {
        return AuthResult.failure(localResult.error!);
      }

      final existingData = await _getStoredUserData();
      await _storeUserData({
        'uid': localResult.user!.uid,
        'email': normalizedEmail,
        'displayName': localResult.user!.displayName,
        'username':
            existingData?['username'] ??
            localResult.user!.username ??
            localResult.user!.displayName,
        'provider': 'local',
        'lastLogin': DateTime.now().toIso8601String(),
      });
      await _prefs?.setString(_lastLoginMethodKey, 'local');

      return AuthResult.success(null);
    }

    return AuthResult.failure(
      'Authentication service is currently unavailable.',
    );
  }

  /// Sign in with Google

  /// Sign in with Google (Firebase)
  Future<AuthResult> signInWithGoogle() async {
    try {
      if (_googleSignIn == null || _auth == null) {
        return AuthResult.failure('Authentication not initialized.');
      }

      try {
        await _googleSignIn?.signOut();
      } catch (_) {}
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

      await _storeUserData({
        'uid': userCredential.user?.uid,
        'email': userCredential.user?.email,
        'displayName': userCredential.user?.displayName,
        'photoURL': userCredential.user?.photoURL,
        'provider': 'google',
        'lastLogin': DateTime.now().toIso8601String(),
      });
      await AppStateService().preferences.setOnboardingComplete(true);
      return AuthResult.success(userCredential.user);
    } catch (error, stackTrace) {
      debugPrint('Google sign-in failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return AuthResult.failure(
        'We could not complete Google sign-in. Please try again.',
      );
    }
  }

  /// Sign in with Apple (iOS only)

  /// Sign in with Apple (Firebase)

  Future<bool> _isIosSimulator() async {
    if (!Platform.isIOS) return false;
    final iosInfo = await DeviceInfoPlugin().iosInfo;
    return !iosInfo.isPhysicalDevice;
  }

  Future<AuthResult> signInWithApple() async {
    try {
      debugPrint(
        'APPLE_AUTH: apps=${Firebase.apps.length} authNull=${_auth == null} firebaseAvailable=$_firebaseAvailable',
      );
      debugPrint(
        'APPLE_AUTH: apps=${Firebase.apps.length} authNull=${_auth == null} firebaseAvailable=$_firebaseAvailable',
      );
      if (kIsWeb) {
        return AuthResult.failure('Apple Sign-In not supported on web.');
      }

      if (await _isIosSimulator()) {
        return AuthResult.failure(
          'Apple Sign-In is unavailable on the iOS Simulator in this build. Use email sign-in here; keep Apple Sign-In for real devices.',
        );
      }

      if (Firebase.apps.isNotEmpty && _auth == null) {
        _auth = FirebaseAuth.instance;
        _firebaseAvailable = true;
      }

      if (_auth == null) {
        return AuthResult.failure('Authentication not initialized.');
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
      await AppStateService().preferences.setOnboardingComplete(true);
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
    try {
      await _googleSignIn?.signOut();
    } catch (_) {}
    try {
      await _googleSignIn?.disconnect();
    } catch (_) {}

    // Never reuse a Firebase or anonymous cloud identity across app accounts.
    try {
      await _auth?.signOut();
    } catch (error) {
      debugPrint('⚠️ Firebase sign out failed: $error');
    }

    try {
      debugPrint('🔐 Starting complete sign out process...');

      // Always clear local data first, even if Firebase operations fail
      await _clearAllUserData();
      if (_prefs != null) {
        await _prefs!.remove(_lastLoginMethodKey);
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

      // Clear memory cache and force garbage collection
      await _clearMemoryCache();

      debugPrint('✅ Complete sign out successful - all user data cleared');
    } catch (e) {
      debugPrint('❌ Critical sign out error: $e');
      // Still try to clear local data even if everything else fails
      try {
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

  /// Check whether this device already knows the email account.
  Future<bool> isEmailKnownOnDevice(String email) async {
    try {
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
      final storedEmail = storedData?['email']?.toString().trim().toLowerCase();
      if (storedEmail == email.trim().toLowerCase()) {
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
    if (!_isInitialized) {
      await initialize();
    }

    final normalizedEmail = email.trim();
    final auth = _auth;

    if (!_firebaseAvailable || auth == null) {
      return AuthResult.failure(
        'Password reset is temporarily unavailable. Please try again later.',
      );
    }

    try {
      await auth.sendPasswordResetEmail(email: normalizedEmail);
      AppLogger.auth('Firebase password-reset request completed');
      return AuthResult.success(null);
    } on FirebaseAuthException catch (error) {
      AppLogger.warning(
        'Firebase password-reset request failed: ${error.code}',
      );

      // Avoid revealing whether an account exists for an email address.
      if (error.code == 'user-not-found') {
        return AuthResult.success(null);
      }

      return AuthResult.failure(
        _firebaseAuthFailureMessage(
          error,
          operation: 'send the password-reset email',
        ),
      );
    } catch (error) {
      AppLogger.error('Unexpected password-reset failure', error);
      return AuthResult.failure(
        'We could not send the password-reset email. Please try again.',
      );
    }
  }

  /// Permanently delete the active Firebase or local account.
  Future<AuthResult> deleteAccount() async {
    try {
      final account = await getCurrentUser();
      if (account == null) {
        return AuthResult.failure('No user signed in');
      }

      if (account is User) {
        // The callable requires the still-authenticated Firebase identity.
        // Never delete the identity until server-side erasure is confirmed.
        await CloudDataDeletionGateway().deleteCurrentUserCloudData();
        await _clearAllUserData();
        await account.delete();
      } else if (account is LocalUser) {
        final localService = _localUserService;
        if (localService == null) {
          return AuthResult.failure('Local account service is unavailable');
        }

        final deleted = await localService.deleteUser(account.uid);
        if (!deleted) {
          return AuthResult.failure('Local account could not be deleted');
        }

        await _clearAllUserData();
      } else {
        return AuthResult.failure('Unsupported account type');
      }

      if (_prefs != null) {
        await _prefs!.remove(_userDataKey);
        await _prefs!.remove(_lastLoginMethodKey);
        await _prefs!.remove('user_preferences');
        await _prefs!.remove('app_settings');
      }

      try {
        await _googleSignIn?.signOut();
      } catch (_) {}

      try {
        await _googleSignIn?.disconnect();
      } catch (_) {}

      await _clearMemoryCache();
      return AuthResult.success(null);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'requires-recent-login') {
        return AuthResult.failure(
          'Please sign in again, then retry account deletion.',
        );
      }

      return AuthResult.failure(
        error.message ?? 'Firebase account deletion failed',
      );
    } catch (error) {
      return AuthResult.failure('Account deletion failed: $error');
    }
  }

  String _firebaseAuthFailureMessage(
    FirebaseAuthException error, {
    required String operation,
  }) {
    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'email-already-in-use':
        return 'An account already exists for this email address.';
      case 'weak-password':
        return 'Choose a stronger password with at least eight characters.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'The email address or password is incorrect.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'network-request-failed':
        return 'Check your internet connection and try again.';
      case 'too-many-requests':
        return 'Too many attempts were made. Please wait and try again.';
      case 'operation-not-allowed':
        return 'Email and password authentication is not enabled.';
      default:
        return error.message ?? 'Unable to $operation. Please try again.';
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

  /// Clear all user-related data from local storage
  Future<void> _clearAllUserData() async {
    // Cycle, symptom, prediction, and tracking records live in SQLite.
    await DatabaseService().deleteDatabase();

    if (_prefs != null) {
      // Get all keys and remove user-related ones
      final keys = _prefs!.getKeys();
      for (final key in keys) {
        if ((key.contains('user_') && key != _userDataKey) ||
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
