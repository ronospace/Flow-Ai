import 'package:flutter/material.dart';
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
  bool get isAuthenticated => _auth?.currentUser != null || _hasLocalUser();
  
  bool _hasLocalUser() {
    // Check if we have a valid local user session
    return _localUserService?.isUserSessionValid() == true;
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
  Future<bool> authenticateWithBiometrics() async {
    if (!await isBiometricAvailable() || !isBiometricEnabled()) {
      return false;
    }

    try {
      if (_localAuth == null) return false;
      final bool isAuthenticated = await _localAuth!.authenticate(
        localizedReason: 'Please authenticate to access FlowSense',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        // If biometric auth succeeds, check if we have stored credentials
        final userData = await _getStoredUserData();
        if (userData != null) {
          return true;
        }
      }

      return isAuthenticated;
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
      return false;
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

            // Store user data
            await _storeUserData({
              'uid': result.user!.uid,
              'email': email,
              'displayName': displayName,
              'username': username,
              'provider': 'firebase',
              'createdAt': DateTime.now().toIso8601String(),
            });

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
          // Store compatibility data for UI
          await _storeUserData({
            'uid': localResult.user!.uid,
            'email': email,
            'displayName': displayName,
            'username': username,
            'provider': 'local',
            'createdAt': DateTime.now().toIso8601String(),
          });

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
      if (_googleSignIn == null) {
        return AuthResult.failure('Google Sign-In not initialized');
      }
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) {
        return AuthResult.failure('Google sign-in cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      if (_auth == null) {
        return AuthResult.failure('Authentication service not initialized');
      }
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

        return AuthResult.success(result.user!);
      }

      return AuthResult.failure('Failed to sign in with Google');
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  /// Sign in with Apple (iOS only)
  Future<AuthResult> signInWithApple() async {
    if (!Platform.isIOS) {
      return AuthResult.failure('Apple Sign-In is only available on iOS');
    }

    try {
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

      if (_auth == null) {
        return AuthResult.failure('Authentication service not initialized');
      }
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

        return AuthResult.success(result.user!);
      }

      return AuthResult.failure('Failed to sign in with Apple');
    } catch (e) {
      return AuthResult.failure(e.toString());
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

  /// Get stored user data
  Future<Map<String, dynamic>?> getUserData() async {
    return await _getStoredUserData();
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
