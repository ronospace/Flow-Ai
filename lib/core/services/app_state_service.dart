import '../identity/active_account_scope.dart';
import 'app_lock_service.dart';
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
  Future<void>? _initializationFuture;
  bool get isInitialized => _isInitialized;

  /// Initialize all required services
  Future<void> initialize() {
    if (_isInitialized) {
      return Future.value();
    }
    if (_initializationFuture != null) {
      return _initializationFuture!;
    }

    _initializationFuture = _doInitialize();
    return _initializationFuture!;
  }

  Future<void> _doInitialize() async {
    try {
      // Initialize services once
      _authService = AuthService();
      _preferencesService = UserPreferencesService();

      // Initialize services in order
      await Future.wait([
        _authService.initialize(),
        _preferencesService.initialize(),
      ]);

      _isInitialized = true;
    } catch (e) {
      _initializationFuture = null;
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
        return '/auth/choice';
      }

      // Onboarding is owned by the currently authenticated account.
      final activeUserId = await ActiveAccountScope.instance.requireUserId();
      final hasCompletedOnboarding = await _preferencesService
          .isOnboardingCompleteForUser(activeUserId);

      if (!hasCompletedOnboarding) {
        return '/onboarding';
      }

      if (await AppLockService().shouldRequireLock()) {
        return '/auth/lock';
      }

      return '/home';
    } catch (e) {
      // Default to auth choice screen
      return '/auth/choice';
    }
  }

  /// Check if user is authenticated
  Future<bool> isUserAuthenticated() async {
    if (!_isInitialized) {
      await initialize();
    }
    return await _authService.isAuthenticated;
  }

  /// Resolve the canonical destination immediately after authentication.
  ///
  /// New accounts receive an explicit account-scoped incomplete state so
  /// they cannot inherit the legacy device-global onboarding flag.
  Future<String> getPostAuthRoute({required bool isNewUser}) async {
    if (!_isInitialized) {
      await initialize();
    }

    final activeUserId = await ActiveAccountScope.instance.requireUserId();

    if (isNewUser) {
      await _preferencesService.setOnboardingCompleteForUser(
        activeUserId,
        false,
      );
      return '/onboarding';
    }

    final hasCompletedOnboarding = await _preferencesService
        .isOnboardingCompleteForUser(activeUserId);

    return hasCompletedOnboarding ? '/home' : '/onboarding';
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
    final activeUserId = await ActiveAccountScope.instance.requireUserId();
    await _preferencesService.setOnboardingCompleteForUser(activeUserId, true);
  }

  /// Reset app state (for testing or sign-out)
  Future<void> resetAppState() async {
    if (!_isInitialized) {
      await initialize();
    }

    // Sign out and invalidate the memory-only biometric unlock.
    await _authService.signOut();
    AppLockService().reset();

    // Do NOT reset onboarding status on sign out
  }

  /// Get user preferences service
  UserPreferencesService get preferences => _preferencesService;

  /// Get auth service
  AuthService get auth => _authService;
}
