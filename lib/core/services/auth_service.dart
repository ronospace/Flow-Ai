import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

/// Enhanced Authentication Service with biometric and multi-provider OAuth
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  late FirebaseAuth _auth;
  late LocalAuthentication _localAuth;
  late GoogleSignIn _googleSignIn;
  late SharedPreferences _prefs;

  static const String _userDataKey = 'user_data';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _lastLoginMethodKey = 'last_login_method';

  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => _auth.currentUser != null;

  Future<void> initialize() async {
    await Firebase.initializeApp();
    _auth = FirebaseAuth.instance;
    _localAuth = LocalAuthentication();
    _googleSignIn = GoogleSignIn();
    _prefs = await SharedPreferences.getInstance();
  }

  /// Check if biometric authentication is available and enabled
  Future<bool> isBiometricAvailable() async {
    final bool isAvailable = await _localAuth.isDeviceSupported();
    final bool hasEnrolledBiometrics = await _localAuth.getAvailableBiometrics().then((list) => list.isNotEmpty);
    return isAvailable && hasEnrolledBiometrics;
  }

  /// Enable/disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.setBool(_biometricEnabledKey, enabled);
  }

  /// Check if biometric authentication is enabled
  bool isBiometricEnabled() {
    return _prefs.getBool(_biometricEnabledKey) ?? false;
  }

  /// Authenticate using biometrics
  Future<bool> authenticateWithBiometrics() async {
    if (!await isBiometricAvailable() || !isBiometricEnabled()) {
      return false;
    }

    try {
      final bool isAuthenticated = await _localAuth.authenticate(
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
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
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
          'provider': 'email',
          'createdAt': DateTime.now().toIso8601String(),
        });

        await _prefs.setString(_lastLoginMethodKey, 'email');

        return AuthResult.success(result.user!);
      }

      return AuthResult.failure('Failed to create user');
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  /// Sign in with email and password
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        await _storeUserData({
          'uid': result.user!.uid,
          'email': email,
          'displayName': result.user!.displayName,
          'provider': 'email',
          'lastLogin': DateTime.now().toIso8601String(),
        });

        await _prefs.setString(_lastLoginMethodKey, 'email');

        return AuthResult.success(result.user!);
      }

      return AuthResult.failure('Failed to sign in');
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  /// Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult.failure('Google sign-in cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await _auth.signInWithCredential(credential);

      if (result.user != null) {
        await _storeUserData({
          'uid': result.user!.uid,
          'email': result.user!.email,
          'displayName': result.user!.displayName,
          'photoURL': result.user!.photoURL,
          'provider': 'google',
          'lastLogin': DateTime.now().toIso8601String(),
        });

        await _prefs.setString(_lastLoginMethodKey, 'google');

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

      final UserCredential result = await _auth.signInWithCredential(oauthCredential);

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

        await _prefs.setString(_lastLoginMethodKey, 'apple');

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
    return _prefs.getString(_lastLoginMethodKey);
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    await _clearStoredUserData();
    await _prefs.remove(_lastLoginMethodKey);
  }

  /// Reset password
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
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
      await _prefs.remove(_lastLoginMethodKey);
      await _prefs.remove(_biometricEnabledKey);

      return AuthResult.success(null);
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  Future<void> _storeUserData(Map<String, dynamic> userData) async {
    await _prefs.setString(_userDataKey, json.encode(userData));
  }

  Future<Map<String, dynamic>?> _getStoredUserData() async {
    final userDataString = _prefs.getString(_userDataKey);
    if (userDataString != null) {
      return Map<String, dynamic>.from(json.decode(userDataString));
    }
    return null;
  }

  Future<void> _clearStoredUserData() async {
    await _prefs.remove(_userDataKey);
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
