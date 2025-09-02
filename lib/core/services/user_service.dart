import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import 'local_user_service.dart';
import 'auth_service.dart';

/// Service for managing user profiles and related operations
class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();
  static UserService get instance => _instance;
  factory UserService() => _instance;
  UserService._internal();

  UserProfile? _currentUser;
  bool _isInitialized = false;
  
  final LocalUserService _localUserService = LocalUserService();
  final AuthService _authService = AuthService.instance;

  UserProfile? get currentUser => _currentUser;
  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _currentUser != null;

  /// Initialize the user service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    debugPrint('🔄 Initializing User Service...');
    
    try {
      // Initialize dependencies
      await _localUserService.initialize();
      
      // Load current user if exists
      await _loadCurrentUser();
      
      _isInitialized = true;
      debugPrint('✅ User Service initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize User Service: $e');
    }
  }

  /// Get the current user profile
  Future<UserProfile?> getCurrentUser() async {
    if (!_isInitialized) await initialize();
    return _currentUser;
  }

  /// Create a new user profile
  Future<UserProfile> createUser({
    required String displayName,
    int? age,
    String? lifestyle,
    List<String>? healthConcerns,
    double? weight,
    double? height,
    Map<String, dynamic>? familyHistory,
  }) async {
    if (!_isInitialized) await initialize();
    
    final now = DateTime.now();
    final user = UserProfile(
      id: 'user_${now.millisecondsSinceEpoch}',
      displayName: displayName,
      age: age,
      lifestyle: lifestyle,
      healthConcerns: healthConcerns ?? [],
      preferences: _getDefaultPreferences(),
      personalizedBaselines: {},
      adaptationHistory: [],
      createdAt: now,
      updatedAt: now,
      weight: weight,
      height: height,
      familyHistory: familyHistory,
    );

    await _saveUser(user);
    return user;
  }

  /// Update the current user profile
  Future<UserProfile> updateUser(UserProfile updatedUser) async {
    if (!_isInitialized) await initialize();
    
    final user = updatedUser.copyWith(updatedAt: DateTime.now());
    await _saveUser(user);
    return user;
  }

  /// Update specific user properties
  Future<UserProfile?> updateUserProperties({
    String? displayName,
    int? age,
    String? lifestyle,
    List<String>? healthConcerns,
    Map<String, dynamic>? preferences,
    double? weight,
    double? height,
    Map<String, dynamic>? familyHistory,
  }) async {
    if (_currentUser == null) return null;

    final updatedUser = _currentUser!.copyWith(
      displayName: displayName,
      age: age,
      lifestyle: lifestyle,
      healthConcerns: healthConcerns,
      preferences: preferences,
      weight: weight,
      height: height,
      familyHistory: familyHistory,
      updatedAt: DateTime.now(),
    );

    return await updateUser(updatedUser);
  }

  /// Sign in user
  Future<UserProfile?> signInUser(String userId) async {
    if (!_isInitialized) await initialize();
    
    try {
      final user = await _localUserService.getUser(userId);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        debugPrint('👤 User signed in: ${user.displayName}');
      }
      return user;
    } catch (e) {
      debugPrint('❌ Failed to sign in user: $e');
      return null;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    _currentUser = null;
    notifyListeners();
    debugPrint('👤 User signed out');
  }

  /// Delete user account
  Future<bool> deleteUser(String userId) async {
    if (!_isInitialized) await initialize();
    
    try {
      final success = await _localUserService.deleteUser(userId);
      if (success && _currentUser?.id == userId) {
        await signOut();
      }
      return success;
    } catch (e) {
      debugPrint('❌ Failed to delete user: $e');
      return false;
    }
  }

  /// Check if user has completed onboarding
  bool hasCompletedOnboarding() {
    return _currentUser?.preferences['onboarding_completed'] == true;
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    if (_currentUser != null) {
      final preferences = Map<String, dynamic>.from(_currentUser!.preferences);
      preferences['onboarding_completed'] = true;
      
      await updateUserProperties(preferences: preferences);
    }
  }

  /// Get user preferences
  Map<String, dynamic> getUserPreferences() {
    return Map<String, dynamic>.from(_currentUser?.preferences ?? {});
  }

  /// Update user preferences
  Future<void> updatePreferences(Map<String, dynamic> newPreferences) async {
    if (_currentUser != null) {
      final preferences = Map<String, dynamic>.from(_currentUser!.preferences);
      preferences.addAll(newPreferences);
      
      await updateUserProperties(preferences: preferences);
    }
  }

  /// Get user health concerns
  List<String> getHealthConcerns() {
    return List<String>.from(_currentUser?.healthConcerns ?? []);
  }

  /// Add health concern
  Future<void> addHealthConcern(String concern) async {
    if (_currentUser != null) {
      final concerns = List<String>.from(_currentUser!.healthConcerns);
      if (!concerns.contains(concern)) {
        concerns.add(concern);
        await updateUserProperties(healthConcerns: concerns);
      }
    }
  }

  /// Remove health concern
  Future<void> removeHealthConcern(String concern) async {
    if (_currentUser != null) {
      final concerns = List<String>.from(_currentUser!.healthConcerns);
      concerns.remove(concern);
      await updateUserProperties(healthConcerns: concerns);
    }
  }

  /// Private methods
  Future<void> _loadCurrentUser() async {
    try {
      // Try to load the most recent user
      final users = await _localUserService.getAllUsers();
      if (users.isNotEmpty) {
        _currentUser = users.first; // Get the most recent user
        notifyListeners();
        debugPrint('👤 Loaded current user: ${_currentUser!.displayName}');
      } else {
        debugPrint('👤 No existing user found');
      }
    } catch (e) {
      debugPrint('❌ Failed to load current user: $e');
    }
  }

  Future<void> _saveUser(UserProfile user) async {
    try {
      await _localUserService.saveUser(user);
      _currentUser = user;
      notifyListeners();
      debugPrint('💾 User saved: ${user.displayName}');
    } catch (e) {
      debugPrint('❌ Failed to save user: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _getDefaultPreferences() {
    return {
      'theme_mode': 'system',
      'notifications_enabled': true,
      'data_sync_enabled': true,
      'biometric_auth_enabled': false,
      'privacy_mode': false,
      'onboarding_completed': false,
      'cycle_reminders': true,
      'medication_reminders': true,
      'mood_tracking': true,
      'symptom_tracking': true,
      'health_insights': true,
      'ai_coaching': true,
    };
  }

  /// Create a mock user for development/testing
  Future<UserProfile> createMockUser() async {
    final mockUser = UserProfile(
      id: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
      displayName: 'Flow Ai User',
      age: 28,
      lifestyle: 'active',
      healthConcerns: ['irregular_cycles', 'mood_swings'],
      preferences: _getDefaultPreferences(),
      personalizedBaselines: {
        'cycle_length': 28.5,
        'flow_duration': 5.2,
        'mood_baseline': 7.5,
        'energy_baseline': 6.8,
      },
      adaptationHistory: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      weight: 65.0,
      height: 165.0,
      familyHistory: {
        'pcos': false,
        'endometriosis': false,
        'fertility_issues': false,
      },
    );

    await _saveUser(mockUser);
    return mockUser;
  }

  /// Get user BMI if height and weight are available
  double? getUserBMI() {
    if (_currentUser?.weight != null && _currentUser?.height != null) {
      final weightKg = _currentUser!.weight!;
      final heightM = _currentUser!.height! / 100; // Convert cm to m
      return weightKg / (heightM * heightM);
    }
    return null;
  }

  /// Get user age category
  String getUserAgeCategory() {
    final age = _currentUser?.age;
    if (age == null) return 'unknown';
    
    if (age < 18) return 'teen';
    if (age < 25) return 'young_adult';
    if (age < 35) return 'adult';
    if (age < 45) return 'mature_adult';
    return 'experienced_adult';
  }

  /// Dispose method
  @override
  void dispose() {
    super.dispose();
    debugPrint('🗑️ User Service disposed');
  }
}
