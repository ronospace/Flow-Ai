import 'package:flutter/foundation.dart';
import 'auth_service.dart';
import 'user_preferences_service.dart';

/// Central service for managing app state and navigation flow
class AppStateService {
  static final AppStateService _instance = AppStateService._internal();
  factory AppStateService() => _instance;
  AppStateService._internal();

  late final AuthService _authService;
  late final UserPreferencesService _preferencesService;
  
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize all required services
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize services
      _authService = AuthService();
      _preferencesService = UserPreferencesService();
      
      // Initialize services in order
      await _authService.initialize();
      await _preferencesService.initialize();
      
      _isInitialized = true;
      debugPrint('✅ AppStateService initialized successfully');
    } catch (e) {
      debugPrint('❌ AppStateService initialization failed: $e');
      rethrow;
    }
  }

  /// Get the next route the user should be navigated to
  Future<String> getInitialRoute() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Check if user is authenticated
      final isAuthenticated = await _authService.isAuthenticated;
      
      if (!isAuthenticated) {
        debugPrint('📱 User not authenticated -> /auth');
        return '/auth';
      }

      // Check if user has completed onboarding
      final hasCompletedOnboarding = _preferencesService.onboardingComplete;
      
      if (!hasCompletedOnboarding) {
        debugPrint('📱 User authenticated but onboarding incomplete -> /onboarding');
        return '/onboarding';
      }

      // User is authenticated and has completed onboarding
      debugPrint('📱 User authenticated and onboarding complete -> /home');
      return '/home';
      
    } catch (e) {
      debugPrint('❌ Error determining initial route: $e');
      // Default to auth screen on error
      return '/auth';
    }
  }

  /// Check if user is authenticated
  Future<bool> isUserAuthenticated() async {
    if (!_isInitialized) {
      await initialize();
    }
    return await _authService.isAuthenticated;
  }

  /// Check if user has completed onboarding
  bool hasUserCompletedOnboarding() {
    if (!_isInitialized) {
      return false;
    }
    return _preferencesService.onboardingComplete;
  }

  /// Mark onboarding as complete
  Future<void> completeOnboarding() async {
    if (!_isInitialized) {
      await initialize();
    }
    await _preferencesService.setOnboardingComplete(true);
    debugPrint('✅ Onboarding marked as complete');
  }

  /// Reset app state (for testing or sign-out)
  Future<void> resetAppState() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    // Sign out user
    await _authService.signOut();
    
    // Reset onboarding status
    await _preferencesService.setOnboardingComplete(false);
    
    debugPrint('🔄 App state reset');
  }

  /// Get user preferences service
  UserPreferencesService get preferences => _preferencesService;
  
  /// Get auth service
  AuthService get auth => _authService;
}
