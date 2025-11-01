import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../models/user_profile.dart';

/// Local User Service for storing and managing user data offline
/// This service provides fallback authentication when Firebase is not available
class LocalUserService {
  static final LocalUserService _instance = LocalUserService._internal();
  factory LocalUserService() => _instance;
  LocalUserService._internal();

  SharedPreferences? _prefs;
  static const String _usersKey = 'local_users';
  static const String _currentUserKey = 'current_user';
  static const String _userSessionKey = 'user_session';

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Auto-create demo account for App Store review
    await _createDemoAccountIfNeeded();
    
    debugPrint('✅ LocalUserService initialized');
  }

  /// Create a new user account locally with clean slate data isolation
  Future<LocalAuthResult> createUser({
    required String email,
    required String password,
    required String displayName,
    String? username,
  }) async {
    try {
      if (_prefs == null) {
        return LocalAuthResult.failure('Local storage not initialized');
      }

      // Check if user already exists
      final existingUser = await getUserByEmail(email);
      if (existingUser != null) {
        return LocalAuthResult.failure('An account with this email already exists');
      }

      // Create new user with completely fresh data - no history
      final userId = _generateUserId();
      final userData = LocalUser(
        uid: userId,
        email: email,
        displayName: displayName,
        username: username ?? displayName, // Use displayName as fallback for username
        passwordHash: _hashPassword(password),
        provider: 'local',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        lastUpdated: DateTime.now(),
        isActive: true,
        profileData: UserProfileData(
          age: null,
          cycleLength: 28, // Default cycle length
          lastPeriodDate: null, // New user - no period history
          averageCycleLength: 28, // Default average
          symptoms: [], // No symptoms history
          medications: [], // No medications history
          notes: [], // No notes history
        ),
      );

      // Store user with clean slate data isolation
      await _storeUser(userData);
      await _setCurrentUser(userData);
      await _createUserSession(userData);
      
      // Clear any existing cycle data for complete data isolation
      await _clearUserCycleData(userId);
      
      debugPrint('✅ Local user created successfully: ${userData.email}');
      debugPrint('✅ Local user profile saved: ${userData.displayName} (${userData.email})');
      return LocalAuthResult.success(userData);
    } catch (e) {
      debugPrint('❌ Local user creation failed: $e');
      return LocalAuthResult.failure('Failed to create user: ${e.toString()}');
    }
  }

  /// Sign in an existing user with proper data restoration
  Future<LocalAuthResult> signInUser({
    required String email,
    required String password,
  }) async {
    try {
      if (_prefs == null) {
        return LocalAuthResult.failure('Local storage not initialized');
      }

      final user = await getUserByEmail(email);
      if (user == null) {
        return LocalAuthResult.failure('No account found with this email');
      }

      if (!_verifyPassword(password, user.passwordHash)) {
        return LocalAuthResult.failure('Invalid password');
      }

      if (!user.isActive) {
        return LocalAuthResult.failure('Account is deactivated');
      }

      // Update last login and preserve user data
      final updatedUser = user.copyWith(
        lastLogin: DateTime.now(),
        lastUpdated: DateTime.now(),
      );
      await _updateUser(updatedUser);
      await _setCurrentUser(updatedUser);
      await _createUserSession(updatedUser);

      debugPrint('✅ Local user signed in successfully: ${updatedUser.email}');
      debugPrint('✅ User data restored: ${updatedUser.displayName} with ${updatedUser.profileData.notes.length} notes, cycle data: ${updatedUser.profileData.lastPeriodDate != null}');
      return LocalAuthResult.success(updatedUser);
    } catch (e) {
      debugPrint('❌ Local user sign in failed: $e');
      return LocalAuthResult.failure('Sign in failed: ${e.toString()}');
    }
  }

  /// Get current signed-in user
  Future<LocalUser?> getCurrentUser() async {
    if (_prefs == null) return null;

    final userJson = _prefs!.getString(_currentUserKey);
    if (userJson == null) return null;

    try {
      final userData = Map<String, dynamic>.from(json.decode(userJson));
      return LocalUser.fromJson(userData);
    } catch (e) {
      debugPrint('Error parsing current user: $e');
      return null;
    }
  }

  /// Check if user session is valid
  Future<bool> isUserSessionValid() async {
    if (_prefs == null) return false;

    final sessionJson = _prefs!.getString(_userSessionKey);
    if (sessionJson == null) return false;

    try {
      final sessionData = Map<String, dynamic>.from(json.decode(sessionJson));
      final expiryTime = DateTime.parse(sessionData['expiryTime']);
      return DateTime.now().isBefore(expiryTime);
    } catch (e) {
      return false;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    if (_prefs != null) {
      await _prefs!.remove(_currentUserKey);
      await _prefs!.remove(_userSessionKey);
      debugPrint('✅ Local user signed out');
    }
  }

  /// Update user profile
  Future<LocalAuthResult> updateUserProfile(LocalUser user) async {
    try {
      if (_prefs == null) {
        return LocalAuthResult.failure('Local storage not initialized');
      }

      await _updateUser(user);
      await _setCurrentUser(user);
      
      debugPrint('✅ User profile updated: ${user.email}');
      return LocalAuthResult.success(user);
    } catch (e) {
      debugPrint('❌ Profile update failed: $e');
      return LocalAuthResult.failure('Failed to update profile: ${e.toString()}');
    }
  }

  /// Get user by email
  Future<LocalUser?> getUserByEmail(String email) async {
    if (_prefs == null) return null;

    final usersJson = _prefs!.getString(_usersKey);
    if (usersJson == null) return null;

    try {
      final usersData = Map<String, dynamic>.from(json.decode(usersJson));
      for (final userData in usersData.values) {
        final user = LocalUser.fromJson(Map<String, dynamic>.from(userData));
        if (user.email.toLowerCase() == email.toLowerCase()) {
          return user;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error searching for user: $e');
      return null;
    }
  }

  /// Get all users (for debugging)
  Future<List<LocalUser>> getAllUsers() async {
    if (_prefs == null) return [];

    final usersJson = _prefs!.getString(_usersKey);
    if (usersJson == null) return [];

    try {
      final usersData = Map<String, dynamic>.from(json.decode(usersJson));
      return usersData.values
          .map((userData) => LocalUser.fromJson(Map<String, dynamic>.from(userData)))
          .toList();
    } catch (e) {
      debugPrint('Error getting all users: $e');
      return [];
    }
  }

  // Private helper methods
  Future<void> _storeUser(LocalUser user) async {
    final usersJson = _prefs!.getString(_usersKey);
    Map<String, dynamic> usersData = {};
    
    if (usersJson != null) {
      usersData = Map<String, dynamic>.from(json.decode(usersJson));
    }
    
    usersData[user.uid] = user.toJson();
    await _prefs!.setString(_usersKey, json.encode(usersData));
  }

  Future<void> _updateUser(LocalUser user) async {
    await _storeUser(user);
  }

  Future<void> _setCurrentUser(LocalUser user) async {
    await _prefs!.setString(_currentUserKey, json.encode(user.toJson()));
  }

  Future<void> _createUserSession(LocalUser user) async {
    final sessionData = {
      'userId': user.uid,
      'email': user.email,
      'createdAt': DateTime.now().toIso8601String(),
      'expiryTime': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
    };
    await _prefs!.setString(_userSessionKey, json.encode(sessionData));
  }

  String _generateUserId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNum = random.nextInt(999999);
    return 'local_$timestamp$randomNum';
  }

  String _hashPassword(String password) {
    // Simple hash for demo purposes - in production, use proper hashing like bcrypt
    return password.hashCode.toString();
  }

  bool _verifyPassword(String password, String hash) {
    return _hashPassword(password) == hash;
  }
  
  /// Clear user-specific cycle data and AI conversation data for complete data isolation (new users)
  Future<void> _clearUserCycleData(String userId) async {
    if (_prefs == null) return;
    
    // Clear any cycle-specific data that might exist for this user
    final keysToRemove = [
      'cycle_data_$userId',
      'tracking_data_$userId', 
      'predictions_$userId',
      'insights_$userId',
      'symptoms_history_$userId',
      'period_history_$userId',
      // Clear AI conversation data for complete user isolation
      'ai_conversation_history_$userId',
      'ai_user_preferences_$userId', 
      'ai_topics_interest_$userId',
      'ai_frequent_questions_$userId',
      'ai_personalized_insights_$userId',
    ];
    
    for (final key in keysToRemove) {
      await _prefs!.remove(key);
    }
    
    debugPrint('✅ Cleared cycle data and AI conversation data for new user: $userId');
  }

  /// Mark onboarding as completed for the current user
  Future<void> setOnboardingCompleted(bool completed) async {
    if (_prefs != null) {
      await _prefs!.setBool('onboarding_completed', completed);
      debugPrint('✅ Onboarding completion status set to $completed');
    }
  }

  /// Check if current user has completed onboarding
  Future<bool> hasCompletedOnboarding() async {
    if (_prefs == null) return false;
    return _prefs!.getBool('onboarding_completed') ?? false;
  }
  
  /// Auto-create demo account for Apple App Store review
  Future<void> _createDemoAccountIfNeeded() async {
    try {
      const demoEmail = 'demo@flowai.app';
      
      // Check if demo account already exists
      final existingUser = await getUserByEmail(demoEmail);
      if (existingUser != null) {
        debugPrint('✅ Demo account already exists for App Store review');
        return;
      }
      
      // Create demo account with complete profile for App Store reviewers
      final result = await createUser(
        email: demoEmail,
        password: 'FlowAiDemo2025!',
        displayName: 'Demo User for App Review',
        username: 'demo_reviewer',
      );
      
      if (result.isSuccess && result.user != null) {
        // Add some sample data for the demo account to show app functionality
        final demoUser = result.user!;
        final updatedProfileData = demoUser.profileData.copyWith(
          age: 28,
          cycleLength: 28,
          lastPeriodDate: DateTime.now().subtract(const Duration(days: 15)),
          averageCycleLength: 28,
          notes: [
            'Welcome to Flow Ai! This is a demo account for App Store reviewers.',
            'You can explore all features including cycle tracking, mood logging, and AI insights.',
            'This account has sample data to demonstrate the app\'s capabilities.',
          ],
          symptoms: [
            'Sample symptom: Mild cramping (Day 1)',
            'Sample symptom: Light flow (Day 2-3)',
            'Sample symptom: Energy boost (Day 7)',
          ],
        );
        
        final updatedUser = demoUser.copyWith(
          profileData: updatedProfileData,
        );
        
        await updateUserProfile(updatedUser);
        
        // Set onboarding as completed for smooth demo experience
        await setOnboardingCompleted(true);
        
        debugPrint('✅ Demo account auto-created for App Store review with sample data');
        debugPrint('📧 Demo credentials: demo@flowai.app / FlowAiDemo2025!');
      } else {
        debugPrint('❌ Failed to create demo account: ${result.error}');
      }
    } catch (e) {
      debugPrint('⚠️ Error creating demo account: $e');
      // Don\'t throw error - this is a non-critical enhancement
    }
  }
  
  /// Check if user exists by email
  Future<bool> userExists(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }

  /// Get user by ID (compatibility method)
  Future<UserProfile?> getUser(String userId) async {
    // For compatibility with UserService, convert LocalUser to UserProfile
    // This is a temporary adapter method
    return null; // TODO: Implement proper conversion if needed
  }

  /// Delete user by ID (compatibility method)
  Future<bool> deleteUser(String userId) async {
    // Find user by ID and delete
    final users = await getAllUsers();
    final user = users.where((u) => u.uid == userId).firstOrNull;
    if (user == null) return false;
    
    try {
      final usersJson = _prefs!.getString(_usersKey);
      if (usersJson != null) {
        final usersData = Map<String, dynamic>.from(json.decode(usersJson));
        usersData.remove(userId);
        await _prefs!.setString(_usersKey, json.encode(usersData));
        
        // Clear current user if it's the deleted user
        final currentUser = await getCurrentUser();
        if (currentUser?.uid == userId) {
          await signOut();
        }
        
        return true;
      }
    } catch (e) {
      debugPrint('❌ Failed to delete user: $e');
    }
    return false;
  }

  /// Save user (compatibility method)
  Future<void> saveUser(UserProfile user) async {
    // This is a compatibility method for UserService
    // In practice, we'd need to convert UserProfile to LocalUser
    debugPrint('⚠️ saveUser called but not implemented for UserProfile');
  }
}

/// Local User Model
class LocalUser {
  final String uid;
  final String email;
  final String displayName;
  final String? username;
  final String passwordHash;
  final String provider;
  final DateTime createdAt;
  final DateTime lastLogin;
  final DateTime lastUpdated;
  final bool isActive;
  final UserProfileData profileData;

  LocalUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.username,
    required this.passwordHash,
    required this.provider,
    required this.createdAt,
    required this.lastLogin,
    required this.lastUpdated,
    required this.isActive,
    required this.profileData,
  });

  LocalUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? username,
    String? passwordHash,
    String? provider,
    DateTime? createdAt,
    DateTime? lastLogin,
    DateTime? lastUpdated,
    bool? isActive,
    UserProfileData? profileData,
  }) {
    return LocalUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      provider: provider ?? this.provider,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isActive: isActive ?? this.isActive,
      profileData: profileData ?? this.profileData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'username': username,
      'passwordHash': passwordHash,
      'provider': provider,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'isActive': isActive,
      'profileData': profileData.toJson(),
    };
  }

  factory LocalUser.fromJson(Map<String, dynamic> json) {
    return LocalUser(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      username: json['username'],
      passwordHash: json['passwordHash'] ?? '',
      provider: json['provider'] ?? 'local',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLogin: DateTime.parse(json['lastLogin'] ?? DateTime.now().toIso8601String()),
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
      isActive: json['isActive'] ?? true,
      profileData: UserProfileData.fromJson(json['profileData'] ?? {}),
    );
  }
}

/// User Profile Data for cycle tracking
class UserProfileData {
  final int? age;
  final int cycleLength;
  final DateTime? lastPeriodDate;
  final int averageCycleLength;
  final List<String> symptoms;
  final List<String> medications;
  final List<String> notes;

  UserProfileData({
    this.age,
    required this.cycleLength,
    this.lastPeriodDate,
    required this.averageCycleLength,
    required this.symptoms,
    required this.medications,
    required this.notes,
  });

  UserProfileData copyWith({
    int? age,
    int? cycleLength,
    DateTime? lastPeriodDate,
    int? averageCycleLength,
    List<String>? symptoms,
    List<String>? medications,
    List<String>? notes,
  }) {
    return UserProfileData(
      age: age ?? this.age,
      cycleLength: cycleLength ?? this.cycleLength,
      lastPeriodDate: lastPeriodDate ?? this.lastPeriodDate,
      averageCycleLength: averageCycleLength ?? this.averageCycleLength,
      symptoms: symptoms ?? this.symptoms,
      medications: medications ?? this.medications,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'cycleLength': cycleLength,
      'lastPeriodDate': lastPeriodDate?.toIso8601String(),
      'averageCycleLength': averageCycleLength,
      'symptoms': symptoms,
      'medications': medications,
      'notes': notes,
    };
  }

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    return UserProfileData(
      age: json['age'],
      cycleLength: json['cycleLength'] ?? 28,
      lastPeriodDate: json['lastPeriodDate'] != null 
          ? DateTime.parse(json['lastPeriodDate'])
          : null,
      averageCycleLength: json['averageCycleLength'] ?? 28,
      symptoms: List<String>.from(json['symptoms'] ?? []),
      medications: List<String>.from(json['medications'] ?? []),
      notes: List<String>.from(json['notes'] ?? []),
    );
  }
}

/// Local Authentication Result
class LocalAuthResult {
  final bool isSuccess;
  final LocalUser? user;
  final String? error;

  LocalAuthResult._({
    required this.isSuccess,
    this.user,
    this.error,
  });

  factory LocalAuthResult.success(LocalUser user) {
    return LocalAuthResult._(
      isSuccess: true,
      user: user,
    );
  }

  factory LocalAuthResult.failure(String error) {
    return LocalAuthResult._(
      isSuccess: false,
      error: error,
    );
  }
}
