import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/advanced_biometric_service.dart';
import '../widgets/healthkit_permission_dialog.dart';

class HealthProvider extends ChangeNotifier {
  bool _isHealthKitConnected = false;
  double _healthScore = 0.0;
  bool _healthKitBannerDismissed = false;

  bool get isHealthKitConnected => _isHealthKitConnected;
  double get healthScore => _healthScore;
  bool get healthKitBannerDismissed => _healthKitBannerDismissed;

  /// Connect to HealthKit - Shows mandatory disclosure dialog first (App Store 2.5.1)
  Future<void> connectHealthKit(BuildContext context) async {
    // Show mandatory HealthKit disclosure dialog BEFORE requesting permissions
    // This ensures compliance with App Store Guideline 2.5.1
    final accepted = await HealthKitPermissionDialog.show(
      context,
      onAccept: () async {
        try {
          // User accepted - initialize HealthKit service
          debugPrint('✅ User accepted HealthKit integration');

          // Initialize the advanced biometric service which handles permissions
          final biometricService = AdvancedBiometricService.instance;
          if (!biometricService.isInitialized) {
            await biometricService.initialize();
          }

          // Update connection status
          _isHealthKitConnected = true;

          // Calculate health score from available data
          final snapshot = await biometricService.getCurrentBiometricSnapshot();
          _healthScore = _calculateHealthScore(snapshot);

          notifyListeners();

          // Save connection state
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('healthkit_connected', true);

          debugPrint('✅ HealthKit connected successfully');
        } catch (e) {
          debugPrint('❌ Error connecting HealthKit: $e');
          _isHealthKitConnected = false;
          notifyListeners();
        }
      },
      onDecline: () {
        // User declined - do not connect
        debugPrint('User declined HealthKit integration');
      },
    );

    if (accepted == true) {
      // Connection already handled in onAccept callback
    }
  }

  /// Calculate health score from biometric snapshot
  double _calculateHealthScore(dynamic snapshot) {
    if (snapshot == null) return 75.0;

    double score = 75.0; // Base score

    // Add points based on data quality
    score += snapshot.dataQuality * 15.0;

    // Add points for heart rate being in normal range (60-100)
    if (snapshot.heartRate != null) {
      final hr = snapshot.heartRate!;
      if (hr >= 60 && hr <= 100) {
        score += 5.0;
      }
    }

    // Add points for good sleep (7-9 hours)
    if (snapshot.sleepHours != null) {
      final sleep = snapshot.sleepHours!;
      if (sleep >= 7 && sleep <= 9) {
        score += 5.0;
      }
    }

    return score.clamp(0.0, 100.0);
  }

  /// Disconnect HealthKit
  Future<void> disconnectHealthKit() async {
    _isHealthKitConnected = false;
    _healthScore = 0.0;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('healthkit_connected', false);

    debugPrint('✅ HealthKit disconnected');
  }

  /// Load HealthKit connection state
  Future<void> loadConnectionState() async {
    final prefs = await SharedPreferences.getInstance();
    _isHealthKitConnected = prefs.getBool('healthkit_connected') ?? false;

    if (_isHealthKitConnected) {
      // Recalculate health score
      try {
        final biometricService = AdvancedBiometricService.instance;
        if (!biometricService.isInitialized) {
          await biometricService.initialize();
        }
        final snapshot = await biometricService.getCurrentBiometricSnapshot();
        _healthScore = _calculateHealthScore(snapshot);
      } catch (e) {
        debugPrint('Error loading HealthKit state: $e');
      }
    }

    notifyListeners();
  }

  void updateHealthScore(double score) {
    _healthScore = score;
    notifyListeners();
  }

  /// Dismiss HealthKit disclosure banner
  Future<void> dismissHealthKitBanner() async {
    _healthKitBannerDismissed = true;
    notifyListeners();

    // Persist dismissal preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('healthkit_banner_dismissed', true);
    debugPrint('✅ HealthKit disclosure banner dismissed');
  }

  /// Load banner dismissal state
  Future<void> loadBannerState() async {
    final prefs = await SharedPreferences.getInstance();
    _healthKitBannerDismissed =
        prefs.getBool('healthkit_banner_dismissed') ?? false;
    notifyListeners();
  }

  /// Clear all user health data (used during sign out)
  void clearUserData() {
    _isHealthKitConnected = false;
    _healthScore = 0.0;
    _healthKitBannerDismissed = false;
    notifyListeners();
    debugPrint('✅ HealthProvider: All user data cleared');
  }
}
