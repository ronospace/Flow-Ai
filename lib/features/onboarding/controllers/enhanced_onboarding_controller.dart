import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/onboarding_data.dart';
import '../../../core/services/user_preferences_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/auth_service.dart';

/// Enhanced onboarding controller that manages the comprehensive onboarding flow
class EnhancedOnboardingController extends ChangeNotifier {
  final UserPreferencesService _preferencesService = UserPreferencesService();
  final NotificationService _notificationService = NotificationService.instance;
  final AuthService _authService = AuthService();

  // Current onboarding state
  OnboardingData _data = OnboardingData();
  int _currentStep = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Onboarding steps
  final List<OnboardingStep> _steps = [
    OnboardingStep.welcome,
    OnboardingStep.personalInfo,
    OnboardingStep.cycleHistory,
    OnboardingStep.lifestyle,
    OnboardingStep.goals,
    OnboardingStep.notifications,
    OnboardingStep.privacy,
    OnboardingStep.complete,
  ];

  // Getters
  OnboardingData get data => _data;
  int get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<OnboardingStep> get steps => _steps;
  OnboardingStep get currentStepType => _steps[_currentStep];
  bool get isFirstStep => _currentStep == 0;
  bool get isLastStep => _currentStep == _steps.length - 1;
  double get progress => (_currentStep + 1) / _steps.length;

  /// Initialize the onboarding controller
  Future<void> initialize() async {
    _setLoading(true);
    try {
      // Check if user is already authenticated
      final isAuthenticated = await _authService.isAuthenticated;
      if (!isAuthenticated) {
        _setError('Please sign in to continue with onboarding');
        return;
      }

      // Load any existing partial onboarding data
      await _loadExistingData();
      
      _clearError();
    } catch (e) {
      _setError('Failed to initialize onboarding: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load existing user preferences if any
  Future<void> _loadExistingData() async {
    try {
      // Check if user has any existing preferences
      final cycleLength = _preferencesService.getAverageCycleLength();
      final periodLength = _preferencesService.getAveragePeriodLength();
      final trackingGoals = _preferencesService.getTrackingGoals();
      
      if (cycleLength != null || periodLength != null || trackingGoals.isNotEmpty) {
        _data = _data.copyWith(
          averageCycleLength: cycleLength,
          averagePeriodLength: periodLength,
        );
      }
    } catch (e) {
      debugPrint('Error loading existing data: $e');
    }
  }

  /// Move to the next step
  void nextStep() {
    if (!isLastStep) {
      _currentStep++;
      notifyListeners();
    }
  }

  /// Move to the previous step
  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  /// Jump to a specific step
  void goToStep(int step) {
    if (step >= 0 && step < _steps.length) {
      _currentStep = step;
      notifyListeners();
    }
  }

  /// Update onboarding data
  void updateData(OnboardingData newData) {
    _data = newData;
    notifyListeners();
  }

  /// Save personal information
  Future<void> savePersonalInfo(OnboardingData personalData) async {
    _setLoading(true);
    try {
      _data = personalData;
      
      // Save to preferences service
      if (personalData.fullName != null) {
        await _preferencesService.setDisplayName(personalData.fullName!);
      }
      if (personalData.preferredName != null) {
        await _preferencesService.setPreferredName(personalData.preferredName!);
      }
      if (personalData.dateOfBirth != null) {
        await _preferencesService.setDateOfBirth(personalData.dateOfBirth!);
      }
      
      _clearError();
      nextStep();
    } catch (e) {
      _setError('Failed to save personal information: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Save cycle history
  Future<void> saveCycleHistory(OnboardingData cycleData) async {
    _setLoading(true);
    try {
      _data = cycleData;
      
      // Save cycle preferences
      if (cycleData.averageCycleLength != null) {
        await _preferencesService.setAverageCycleLength(cycleData.averageCycleLength!);
      }
      if (cycleData.averagePeriodLength != null) {
        await _preferencesService.setAveragePeriodLength(cycleData.averagePeriodLength!);
      }
      if (cycleData.lastPeriodDate != null) {
        await _preferencesService.setLastPeriodDate(cycleData.lastPeriodDate!);
      }
      
      // Save tracking experience
      await _preferencesService.setIsFirstTimeTracking(cycleData.isFirstTimeTracking);
      if (cycleData.previousTrackingMethod != null) {
        await _preferencesService.setPreviousTrackingMethod(cycleData.previousTrackingMethod!);
      }
      
      _clearError();
      nextStep();
    } catch (e) {
      _setError('Failed to save cycle history: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Save lifestyle preferences
  Future<void> saveLifestyle(OnboardingData lifestyleData) async {
    _setLoading(true);
    try {
      _data = lifestyleData;
      
      // Save lifestyle preferences
      if (lifestyleData.lifestyle != null) {
        await _preferencesService.setLifestylePreferences(lifestyleData.lifestyle!.toJson());
      }
      
      _clearError();
      nextStep();
    } catch (e) {
      _setError('Failed to save lifestyle preferences: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Save health goals
  Future<void> saveHealthGoals(OnboardingData goalsData) async {
    _setLoading(true);
    try {
      _data = goalsData;
      
      // Save health goals
      if (goalsData.healthGoals != null) {
        await _preferencesService.setHealthGoals(goalsData.healthGoals!.toJson());
      }
      
      _clearError();
      nextStep();
    } catch (e) {
      _setError('Failed to save health goals: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Save notification preferences
  Future<void> saveNotificationPreferences(OnboardingData notificationData) async {
    _setLoading(true);
    try {
      _data = notificationData;
      
      // Request notification permissions if enabled
      if (notificationData.notificationPrefs?.enableNotifications == true) {
        final granted = await _notificationService.requestPermission();
        if (granted) {
          await _notificationService.initialize();
        }
      }
      
      // Save notification preferences
      if (notificationData.notificationPrefs != null) {
        await _preferencesService.setNotificationPreferences(
          notificationData.notificationPrefs!.toJson(),
        );
      }
      
      _clearError();
      nextStep();
    } catch (e) {
      _setError('Failed to save notification preferences: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Save privacy preferences
  Future<void> savePrivacyPreferences(OnboardingData privacyData) async {
    _setLoading(true);
    try {
      _data = privacyData;
      
      // Save privacy preferences
      await _preferencesService.setShareDataForResearch(
        privacyData.shareDataForResearch,
      );
      await _preferencesService.setEnableAIInsights(
        privacyData.enableAIInsights,
      );
      
      _clearError();
      nextStep();
    } catch (e) {
      _setError('Failed to save privacy preferences: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Complete the onboarding process
  Future<void> completeOnboarding() async {
    _setLoading(true);
    try {
      // Mark onboarding as completed
      await _preferencesService.setOnboardingCompleted(true);
      await _preferencesService.setFirstLaunch(false);
      
      // Save final onboarding data
      await _preferencesService.setOnboardingData(_data.toJson());
      
      // Schedule welcome notification if notifications are enabled
      if (_data.notificationPrefs?.enableNotifications == true) {
        await _scheduleWelcomeNotification();
      }
      
      // Initialize user tracking data based on collected information
      await _initializeUserTrackingData();
      
      _clearError();
    } catch (e) {
      _setError('Failed to complete onboarding: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Initialize user tracking data based on onboarding information
  Future<void> _initializeUserTrackingData() async {
    try {
      // If user provided last period date and isn't first time tracking,
      // create initial cycle entry
      if (_data.lastPeriodDate != null && !_data.isFirstTimeTracking) {
        // This would integrate with the cycle tracking service
        // await _cycleTrackingService.createInitialCycle(_data.lastPeriodDate!);
      }
      
      // Set up initial health goals and tracking preferences
      if (_data.healthGoals != null) {
        await _preferencesService.setTrackingGoals(_getTrackingGoalsFromHealthGoals());
      }
      
    } catch (e) {
      debugPrint('Error initializing user tracking data: $e');
    }
  }

  /// Convert health goals to tracking goals list
  List<String> _getTrackingGoalsFromHealthGoals() {
    final goals = <String>[];
    final healthGoals = _data.healthGoals;
    
    if (healthGoals?.trackCycleRegularity == true) {
      goals.add('cycle_regularity');
    }
    if (healthGoals?.predictPeriods == true) {
      goals.add('period_prediction');
    }
    if (healthGoals?.manageSymptoms == true) {
      goals.add('symptom_management');
    }
    if (healthGoals?.improveFertility == true) {
      goals.add('fertility');
    }
    if (healthGoals?.trackMoodPatterns == true) {
      goals.add('mood_tracking');
    }
    if (healthGoals?.monitorHealth == true) {
      goals.add('general_health');
    }
    
    return goals;
  }

  /// Schedule welcome notification
  Future<void> _scheduleWelcomeNotification() async {
    try {
      final userName = _data.preferredName ?? _data.fullName ?? 'there';
      await _notificationService.scheduleNotification(
        id: 0,
        title: 'Welcome to FlowSense, $userName! 🌸',
        body: 'Ready to start your personalized health journey?',
        scheduledDate: DateTime.now().add(const Duration(hours: 2)),
      );
    } catch (e) {
      debugPrint('Error scheduling welcome notification: $e');
    }
  }

  /// Skip onboarding (sets minimal defaults)
  Future<void> skipOnboarding() async {
    _setLoading(true);
    try {
      // Set minimal default data
      _data = OnboardingData(
        averageCycleLength: 28,
        averagePeriodLength: 5,
        isFirstTimeTracking: true,
        enableAIInsights: true,
        shareDataForResearch: false,
      );
      
      // Save basic preferences
      await _preferencesService.setAverageCycleLength(28);
      await _preferencesService.setAveragePeriodLength(5);
      await _preferencesService.setOnboardingCompleted(true);
      await _preferencesService.setFirstLaunch(false);
      
      _clearError();
    } catch (e) {
      _setError('Failed to skip onboarding: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Reset onboarding (for testing or re-onboarding)
  Future<void> resetOnboarding() async {
    _setLoading(true);
    try {
      await _preferencesService.setOnboardingCompleted(false);
      await _preferencesService.setFirstLaunch(true);
      
      _data = OnboardingData();
      _currentStep = 0;
      _clearError();
    } catch (e) {
      _setError('Failed to reset onboarding: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Check if onboarding is required
  Future<bool> isOnboardingRequired() async {
    try {
      final isCompleted = _preferencesService.isOnboardingCompleted();
      final isAuthenticated = await _authService.isAuthenticated;
      return !isCompleted && isAuthenticated;
    } catch (e) {
      debugPrint('Error checking onboarding requirement: $e');
      return true; // Default to requiring onboarding if there's an error
    }
  }

  // Private helper methods

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

}
