import 'package:flutter/foundation.dart';
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

  /// Connect to HealthKit after showing the mandatory disclosure dialog
  Future<void> connectHealthKit(BuildContext context) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      debugPrint(
        'Apple Health integration is available only on iOS in this release',
      );
      return;
    }

    await HealthKitPermissionDialog.show(
      context,
      onAccept: () async {
        final prefs = await SharedPreferences.getInstance();

        try {
          final biometricService = AdvancedBiometricService.instance;

          if (!biometricService.isInitialized) {
            await biometricService.initialize();
          }

          if (!biometricService.isInitialized) {
            _isHealthKitConnected = false;
            _healthScore = 0.0;
            await prefs.setBool('healthkit_connected', false);
            notifyListeners();

            debugPrint(
              'HealthKit connection failed or authorization was not granted',
            );
            return;
          }

          final snapshot = await biometricService.getCurrentBiometricSnapshot();

          _isHealthKitConnected = true;
          _healthScore = _calculateHealthScore(snapshot);

          await prefs.setBool('healthkit_connected', true);
          notifyListeners();

          debugPrint('✅ HealthKit connected and synchronized successfully');
        } catch (error) {
          _isHealthKitConnected = false;
          _healthScore = 0.0;
          await prefs.setBool('healthkit_connected', false);
          notifyListeners();

          debugPrint('❌ Error connecting HealthKit: $error');
        }
      },
      onDecline: () {
        _isHealthKitConnected = false;
        _healthScore = 0.0;
        notifyListeners();

        debugPrint('User declined HealthKit integration');
      },
    );
  }

  /// Calculate health score from biometric snapshot
  double _calculateHealthScore(dynamic snapshot) {
    if (snapshot == null) return 0.0;

    final dataQuality = (snapshot.dataQuality as num).toDouble().clamp(
      0.0,
      1.0,
    );

    double score = dataQuality * 80.0;

    if (snapshot.heartRate != null) {
      final heartRate = (snapshot.heartRate as num).toDouble();
      if (heartRate >= 60.0 && heartRate <= 100.0) {
        score += 10.0;
      }
    }

    if (snapshot.sleepHours != null) {
      final sleepHours = (snapshot.sleepHours as num).toDouble();
      if (sleepHours >= 7.0 && sleepHours <= 9.0) {
        score += 10.0;
      }
    }

    return score.clamp(0.0, 100.0).toDouble();
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
    final storedAsConnected = prefs.getBool('healthkit_connected') ?? false;

    if (!storedAsConnected) {
      _isHealthKitConnected = false;
      _healthScore = 0.0;
      notifyListeners();
      return;
    }

    try {
      final biometricService = AdvancedBiometricService.instance;

      if (!biometricService.isInitialized) {
        await biometricService.initialize();
      }

      if (!biometricService.isInitialized) {
        _isHealthKitConnected = false;
        _healthScore = 0.0;
        await prefs.setBool('healthkit_connected', false);
        notifyListeners();
        return;
      }

      final snapshot = await biometricService.getCurrentBiometricSnapshot();

      _isHealthKitConnected = true;
      _healthScore = _calculateHealthScore(snapshot);
    } catch (error) {
      _isHealthKitConnected = false;
      _healthScore = 0.0;
      await prefs.setBool('healthkit_connected', false);

      debugPrint('Error restoring HealthKit connection: $error');
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
