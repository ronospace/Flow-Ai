import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/onboarding_step.dart';
import '../../../core/services/user_preferences_service.dart';
import '../../../core/services/notification_service.dart';

class OnboardingProvider extends ChangeNotifier {
  bool _isCompleted = false;
  int _currentStep = 0;
  bool _isLoading = false;
  final List<OnboardingStep> _steps = OnboardingData.steps;
  final UserPreferencesService _preferencesService = UserPreferencesService();
  final NotificationService _notificationService = NotificationService.instance;

  // Enhanced getters
  bool get isCompleted => _isCompleted;
  int get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  List<OnboardingStep> get steps => _steps;
  OnboardingStep get currentStepData => _steps[_currentStep];
  bool get isFirstStep => _currentStep == 0;
  bool get isLastStep => _currentStep == _steps.length - 1;
  double get progress => (_currentStep + 1) / _steps.length;

  Future<void> completeOnboarding() async {
    _setLoading(true);
    try {
      _isCompleted = true;
      await _preferencesService.setOnboardingCompleted(true);
      await _preferencesService.setFirstLaunch(false);
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
    } finally {
      _setLoading(false);
    }
  }

  void setCurrentStep(int step) {
    if (step >= 0 && step < _steps.length) {
      _currentStep = step;
      notifyListeners();
    }
  }

  void nextStep() {
    if (!isLastStep) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  // Permission handling
  Future<bool> requestNotificationPermission() async {
    _setLoading(true);
    try {
      final status = await Permission.notification.request();
      if (status.isGranted) {
        await _notificationService.initialize();
        await _preferencesService.setNotificationsEnabled(true);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Setup methods
  Future<void> saveUserPreferences({
    required int averageCycleLength,
    required int averagePeriodLength,
    required List<String> trackingGoals,
    required Map<String, bool> reminderSettings,
  }) async {
    _setLoading(true);
    try {
      await _preferencesService.setAverageCycleLength(averageCycleLength);
      await _preferencesService.setAveragePeriodLength(averagePeriodLength);
      await _preferencesService.setTrackingGoals(trackingGoals);
      await _preferencesService.setReminderSettings(reminderSettings);
    } catch (e) {
      debugPrint('Error saving user preferences: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Skip onboarding
  Future<void> skipOnboarding() async {
    await completeOnboarding();
  }

  // Reset onboarding (for testing)
  Future<void> resetOnboarding() async {
    await _preferencesService.setOnboardingCompleted(false);
    await _preferencesService.setFirstLaunch(true);
    _currentStep = 0;
    _isCompleted = false;
    notifyListeners();
  }

  // Schedule welcome notification
  Future<void> scheduleWelcomeNotification() async {
    await _notificationService.scheduleNotification(
      id: 0,
      title: 'Welcome to FlowSense! 🌸',
      body: 'Ready to start tracking your health journey?',
      scheduledDate: DateTime.now().add(const Duration(hours: 24)),
    );
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
