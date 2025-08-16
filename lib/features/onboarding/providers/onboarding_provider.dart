import 'package:flutter/foundation.dart';

class OnboardingProvider extends ChangeNotifier {
  bool _isCompleted = false;
  int _currentStep = 0;

  bool get isCompleted => _isCompleted;
  int get currentStep => _currentStep;

  void completeOnboarding() {
    _isCompleted = true;
    notifyListeners();
  }

  void setCurrentStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void nextStep() {
    _currentStep++;
    notifyListeners();
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }
}
