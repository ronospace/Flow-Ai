import 'package:flutter/material.dart';
import '../models/onboarding_data.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/local_user_service.dart';
import '../../../core/services/app_state_service.dart';

/// Controller for managing onboarding flow state and navigation
class OnboardingController extends ChangeNotifier {
  final AuthService _authService;
  final LocalUserService _localUserService;

  OnboardingController({
    required AuthService authService,
    required LocalUserService localUserService,
  })  : _authService = authService,
        _localUserService = localUserService;

  // Current state
  OnboardingStep _currentStep = OnboardingStep.welcome;
  OnboardingData _data = OnboardingData();
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  OnboardingStep get currentStep => _currentStep;
  OnboardingData get data => _data;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get canGoNext => _validateCurrentStep();
  bool get canGoBack => _currentStep != OnboardingStep.welcome;

  /// Update onboarding data
  void updateData(OnboardingData newData) {
    _data = newData;
    _clearError();
    notifyListeners();
  }

  /// Update specific field in onboarding data
  void updateField<T>(String fieldName, T value) {
    switch (fieldName) {
      case 'fullName':
        _data = _data.copyWith(fullName: value as String?);
        break;
      case 'preferredName':
        _data = _data.copyWith(preferredName: value as String?);
        break;
      case 'dateOfBirth':
        _data = _data.copyWith(dateOfBirth: value as DateTime?);
        break;
      case 'age':
        _data = _data.copyWith(age: value as int?);
        break;
      case 'lastPeriodDate':
        _data = _data.copyWith(lastPeriodDate: value as DateTime?);
        break;
      case 'averageCycleLength':
        _data = _data.copyWith(averageCycleLength: value as int?);
        break;
      case 'averagePeriodLength':
        _data = _data.copyWith(averagePeriodLength: value as int?);
        break;
      case 'symptoms':
        _data = _data.copyWith(symptoms: value as List<String>);
        break;
      case 'cycleIrregularities':
        _data = _data.copyWith(cycleIrregularities: value as List<String>);
        break;
      case 'lifestyle':
        _data = _data.copyWith(lifestyle: value as LifestylePreferences?);
        break;
      case 'healthGoals':
        _data = _data.copyWith(healthGoals: value as HealthGoals?);
        break;
      case 'notificationPrefs':
        _data = _data.copyWith(notificationPrefs: value as NotificationPreferences?);
        break;
      case 'isFirstTimeTracking':
        _data = _data.copyWith(isFirstTimeTracking: value as bool);
        break;
      case 'previousTrackingMethod':
        _data = _data.copyWith(previousTrackingMethod: value as String?);
        break;
      case 'healthConcerns':
        _data = _data.copyWith(healthConcerns: value as List<String>);
        break;
      case 'shareDataForResearch':
        _data = _data.copyWith(shareDataForResearch: value as bool);
        break;
      case 'enableAIInsights':
        _data = _data.copyWith(enableAIInsights: value as bool);
        break;
      case 'preferredLanguage':
        _data = _data.copyWith(preferredLanguage: value as String?);
        break;
      case 'timeZone':
        _data = _data.copyWith(timeZone: value as String?);
        break;
    }
    _clearError();
    notifyListeners();
  }

  /// Navigate to next step
  Future<void> nextStep() async {
    if (!canGoNext) return;

    _clearError();
    
    // Handle completion step separately
    if (_currentStep == OnboardingStep.privacy) {
      await _completeOnboarding();
      return;
    }

    // Move to next step
    final steps = OnboardingStep.values;
    final currentIndex = steps.indexOf(_currentStep);
    if (currentIndex < steps.length - 1) {
      _currentStep = steps[currentIndex + 1];
      notifyListeners();
    }
  }

  /// Navigate to previous step
  void previousStep() {
    if (!canGoBack) return;

    _clearError();
    final steps = OnboardingStep.values;
    final currentIndex = steps.indexOf(_currentStep);
    if (currentIndex > 0) {
      _currentStep = steps[currentIndex - 1];
      notifyListeners();
    }
  }

  /// Skip to specific step
  void goToStep(OnboardingStep step) {
    _currentStep = step;
    _clearError();
    notifyListeners();
  }

  /// Validate current step data
  bool _validateCurrentStep() {
    switch (_currentStep) {
      case OnboardingStep.welcome:
        return true;
        
      case OnboardingStep.personalInfo:
        return _data.fullName?.isNotEmpty == true &&
               _data.dateOfBirth != null;
               
      case OnboardingStep.healthBasics:
        return true; // Optional fields
        
      case OnboardingStep.cycleHistory:
        if (_data.isFirstTimeTracking) {
          return true; // Can skip if first time
        }
        return _data.lastPeriodDate != null &&
               _data.averageCycleLength != null &&
               _data.averagePeriodLength != null;
               
      case OnboardingStep.lifestyle:
        return true; // All optional
        
      case OnboardingStep.goals:
        return _data.healthGoals != null;
        
      case OnboardingStep.notifications:
        return _data.notificationPrefs != null;
        
      case OnboardingStep.privacy:
        return true; // Optional
        
      case OnboardingStep.complete:
        return true;
    }
  }

  /// Complete onboarding and save user data
  Future<void> _completeOnboarding() async {
    _setLoading(true);
    
    try {
      // Create or update user profile
      final currentUser = await _authService.getCurrentUser();
      if (currentUser != null) {
        // Update user profile with onboarding data
        await _saveUserProfile();
        
        // Initialize tracking data if cycle history provided
        if (!_data.isFirstTimeTracking && _data.lastPeriodDate != null) {
          await _initializeTrackingData();
        }
        
        // Set onboarding as completed
        await _markOnboardingCompleted();
        
        // Move to complete step
        _currentStep = OnboardingStep.complete;
        notifyListeners();
        
      } else {
        _setError('Please sign in to complete onboarding');
      }
    } catch (e) {
      _setError('Failed to complete onboarding: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Save user profile data
  Future<void> _saveUserProfile() async {
    final currentUser = await _authService.getCurrentUser();
    if (currentUser == null) return;

    final profileData = {
      'fullName': _data.fullName,
      'preferredName': _data.preferredName,
      'dateOfBirth': _data.dateOfBirth?.toIso8601String(),
      'age': _data.age,
      'healthConcerns': _data.healthConcerns,
      'lifestyle': _data.lifestyle?.toJson(),
      'healthGoals': _data.healthGoals?.toJson(),
      'notificationPrefs': _data.notificationPrefs?.toJson(),
      'shareDataForResearch': _data.shareDataForResearch,
      'enableAIInsights': _data.enableAIInsights,
      'preferredLanguage': _data.preferredLanguage,
      'timeZone': _data.timeZone,
      'onboardingCompleted': true,
      'onboardingCompletedAt': DateTime.now().toIso8601String(),
    };

    // For now, we'll save this data to the LocalUserService
    // In the future, this can be extended to save to a proper user profile system
    debugPrint('Saving user profile data from onboarding: ${profileData.keys.join(', ')}');
  }

  /// Initialize tracking data with cycle history
  Future<void> _initializeTrackingData() async {
    if (_data.lastPeriodDate == null) return;

    try {
      // For now, just log the tracking data that would be saved
      // In the future, this will be saved to a proper tracking service
      final initialEntry = {
        'date': _data.lastPeriodDate!.toIso8601String(),
        'isFlow': true,
        'flowLevel': 3, // Medium flow as default
        'symptoms': _data.symptoms,
        'notes': 'Initial cycle data from onboarding',
      };

      debugPrint('Initial tracking entry would be saved: $initialEntry');

      // If we have cycle irregularities, save them as notes
      if (_data.cycleIrregularities.isNotEmpty) {
        final irregularitiesNote = {
          'date': DateTime.now().toIso8601String(),
          'type': 'note',
          'content': 'Cycle irregularities reported during onboarding: ${_data.cycleIrregularities.join(", ")}',
        };
        debugPrint('Cycle irregularities note would be saved: $irregularitiesNote');
      }
    } catch (e) {
      // Log error but don't fail onboarding
      debugPrint('Failed to initialize tracking data: $e');
    }
  }

  /// Mark onboarding as completed
  Future<void> _markOnboardingCompleted() async {
    // Use both services to ensure consistency
    await _localUserService.setOnboardingCompleted(true);
    await AppStateService().completeOnboarding();
  }

  /// Reset onboarding (for testing or re-onboarding)
  Future<void> resetOnboarding() async {
    _currentStep = OnboardingStep.welcome;
    _data = OnboardingData();
    _clearError();
    // Reset onboarding status in both services
    await _localUserService.setOnboardingCompleted(false);
    await AppStateService().preferences.setOnboardingComplete(false);
    notifyListeners();
  }

  /// Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding() async {
    return await _localUserService.hasCompletedOnboarding();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
  }

  /// Toggle symptom selection
  void toggleSymptom(String symptom) {
    final symptoms = List<String>.from(_data.symptoms);
    if (symptoms.contains(symptom)) {
      symptoms.remove(symptom);
    } else {
      symptoms.add(symptom);
    }
    updateField('symptoms', symptoms);
  }

  /// Toggle cycle irregularity selection
  void toggleCycleIrregularity(String irregularity) {
    final irregularities = List<String>.from(_data.cycleIrregularities);
    if (irregularities.contains(irregularity)) {
      irregularities.remove(irregularity);
    } else {
      irregularities.add(irregularity);
    }
    updateField('cycleIrregularities', irregularities);
  }

  /// Toggle health concern selection
  void toggleHealthConcern(String concern) {
    final concerns = List<String>.from(_data.healthConcerns);
    if (concerns.contains(concern)) {
      concerns.remove(concern);
    } else {
      concerns.add(concern);
    }
    updateField('healthConcerns', concerns);
  }

  /// Calculate age from date of birth
  void calculateAgeFromBirthDate() {
    if (_data.dateOfBirth != null) {
      final now = DateTime.now();
      final age = now.year - _data.dateOfBirth!.year;
      final hasHadBirthdayThisYear = now.month > _data.dateOfBirth!.month ||
          (now.month == _data.dateOfBirth!.month && now.day >= _data.dateOfBirth!.day);
      
      updateField('age', hasHadBirthdayThisYear ? age : age - 1);
    }
  }

  /// Get progress percentage for current step
  double get progressPercentage => _currentStep.progress;

  /// Get total number of steps
  int get totalSteps => OnboardingStep.values.length - 1; // Exclude complete step

  /// Get current step number (1-indexed)
  int get currentStepNumber => OnboardingStep.values.indexOf(_currentStep) + 1;

}
