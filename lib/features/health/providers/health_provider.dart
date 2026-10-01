import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/advanced_biometric_service.dart';
import '../widgets/healthkit_permission_dialog.dart';

class HealthProvider extends ChangeNotifier {
  bool _hasHealthDataAccess = false;
  bool _isConnectingHealthData = false;
  double _healthScore = 0.0;
  bool _healthKitBannerDismissed = false;
  BiometricSnapshot? _snapshot;

  bool get hasHealthDataAccess => _hasHealthDataAccess;
  bool get isConnectingHealthData => _isConnectingHealthData;
  double get healthScore => _healthScore;
  bool get healthKitBannerDismissed => _healthKitBannerDismissed;
  BiometricSnapshot? get snapshot => _snapshot;

  bool get isHealthConnectAvailable =>
      AdvancedBiometricService.instance.isHealthConnectAvailable;

  bool get requiresHealthConnectInstallOrUpdate =>
      AdvancedBiometricService.instance.requiresHealthConnectInstallOrUpdate;

  bool get isHealthConnectUnsupported =>
      AdvancedBiometricService.instance.isHealthConnectUnsupported;

  Future<void> installHealthConnect() =>
      AdvancedBiometricService.instance.installHealthConnect();
  bool get hasVerifiedHealthData =>
      _snapshot != null && _snapshot!.dataQuality > 0.0;

  /// True only when the current snapshot contains real health-store
  /// observations with preserved provenance.
  ///
  /// This does not imply freshness, clinical quality, or a connected
  /// wearable.
  bool get hasObservedHealthData =>
      _snapshot != null && _snapshot!.metricProvenance.isNotEmpty;

  /// Connect to HealthKit after showing the mandatory disclosure dialog
  Future<void> connectHealthKit(BuildContext context) async {
    final supportedPlatform =
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;

    if (kIsWeb || !supportedPlatform) {
      return;
    }

    await HealthKitPermissionDialog.show(
      context,
      onAccept: () async {
        final prefs = await SharedPreferences.getInstance();

        _isConnectingHealthData = true;
        notifyListeners();

        try {
          final biometricService = AdvancedBiometricService.instance;

          final authorized = await biometricService
              .requestHealthAuthorization();

          if (!authorized || !biometricService.isInitialized) {
            _hasHealthDataAccess = false;
            _snapshot = null;
            _healthScore = 0.0;
            await prefs.setBool('health_data_access_granted', false);
            _isConnectingHealthData = false;
            notifyListeners();

            return;
          }

          // Authorization truth and data-sync freshness are separate states.
          // Mark access immediately once the platform confirms authorization.
          _hasHealthDataAccess = true;
          _isConnectingHealthData = false;
          notifyListeners();

          await prefs.setBool('health_data_access_granted', true);

          final snapshot = await biometricService
              .refreshCurrentBiometricSnapshot();

          _snapshot = snapshot;
          _healthScore = _calculateHealthScore(snapshot);
          notifyListeners();
        } catch (error) {
          _hasHealthDataAccess = false;
          _isConnectingHealthData = false;
          _snapshot = null;
          _healthScore = 0.0;
          await prefs.setBool('health_data_access_granted', false);
          notifyListeners();
        }
      },
      onDecline: () {
        _hasHealthDataAccess = false;
        _isConnectingHealthData = false;
        _snapshot = null;
        _healthScore = 0.0;
        notifyListeners();
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
    _hasHealthDataAccess = false;
    _isConnectingHealthData = false;
    _snapshot = null;
    _healthScore = 0.0;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('health_data_access_granted', false);
  }

  /// Load health-data access state
  Future<void> loadConnectionState() async {
    final prefs = await SharedPreferences.getInstance();
    final storedAsConnected =
        prefs.getBool('health_data_access_granted') ?? false;

    if (!storedAsConnected) {
      _hasHealthDataAccess = false;
      _snapshot = null;
      _healthScore = 0.0;
      notifyListeners();
      return;
    }

    try {
      final biometricService = AdvancedBiometricService.instance;

      if (Platform.isAndroid) {
        final stillAuthorized = await biometricService
            .hasCurrentAndroidHealthPermissions();

        if (!stillAuthorized) {
          _hasHealthDataAccess = false;
          _snapshot = null;
          _healthScore = 0.0;
          await prefs.setBool('health_data_access_granted', false);
          notifyListeners();
          return;
        }
      }

      if (!biometricService.isInitialized) {
        await biometricService.initialize();
      }

      if (!biometricService.isInitialized) {
        _hasHealthDataAccess = false;
        _snapshot = null;
        _healthScore = 0.0;
        await prefs.setBool('health_data_access_granted', false);
        notifyListeners();
        return;
      }

      final snapshot = await biometricService.getCurrentBiometricSnapshot();

      _snapshot = snapshot;
      _hasHealthDataAccess = true;
      _healthScore = _calculateHealthScore(snapshot);
    } catch (error) {
      _hasHealthDataAccess = false;
      _snapshot = null;
      _healthScore = 0.0;
      await prefs.setBool('health_data_access_granted', false);
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
    _hasHealthDataAccess = false;
    _isConnectingHealthData = false;
    _snapshot = null;
    _healthScore = 0.0;
    _healthKitBannerDismissed = false;
    notifyListeners();
  }
}
