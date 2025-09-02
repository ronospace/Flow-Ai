import 'package:flutter/foundation.dart';

class HealthProvider extends ChangeNotifier {
  bool _isHealthKitConnected = false;
  double _healthScore = 0.0;

  bool get isHealthKitConnected => _isHealthKitConnected;
  double get healthScore => _healthScore;

  Future<void> connectHealthKit() async {
    await Future.delayed(const Duration(seconds: 1));
    _isHealthKitConnected = true;
    _healthScore = 85.5;
    notifyListeners();
  }

  void updateHealthScore(double score) {
    _healthScore = score;
    notifyListeners();
  }
  
  /// Clear all user health data (used during sign out)
  void clearUserData() {
    _isHealthKitConnected = false;
    _healthScore = 0.0;
    notifyListeners();
    debugPrint('✅ HealthProvider: All user data cleared');
  }
}
