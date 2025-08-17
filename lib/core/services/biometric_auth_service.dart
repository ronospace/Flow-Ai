import 'dart:io';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart' as platform_types;
import 'package:local_auth/error_codes.dart' as auth_error;

enum AppBiometricType {
  none,
  fingerprint,
  face,
  iris,
}

enum AuthStatus {
  success,
  failed,
  cancelled,
  notAvailable,
  notEnrolled,
  disabled,
  unknown,
}

class BiometricAuthResult {
  final AuthStatus status;
  final String? errorMessage;
  final AppBiometricType? usedBiometric;

  const BiometricAuthResult({
    required this.status,
    this.errorMessage,
    this.usedBiometric,
  });

  bool get isSuccess => status == AuthStatus.success;
  bool get isFailed => status == AuthStatus.failed;
  bool get isCancelled => status == AuthStatus.cancelled;
  bool get isNotAvailable => status == AuthStatus.notAvailable;
}

class BiometricAuthService {
  static final BiometricAuthService _instance = BiometricAuthService._internal();
  factory BiometricAuthService() => _instance;
  BiometricAuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if biometric authentication is available on device
  Future<bool> isAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  /// Check if biometric authentication is available and enrolled
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) return false;

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get list of available biometric types
  Future<List<AppBiometricType>> getAvailableBiometrics() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      return availableBiometrics.map((biometric) {
        switch (biometric) {
          case platform_types.BiometricType.fingerprint:
            return AppBiometricType.fingerprint;
          case platform_types.BiometricType.face:
            return AppBiometricType.face;
          case platform_types.BiometricType.iris:
            return AppBiometricType.iris;
          default:
            return AppBiometricType.none;
        }
      }).where((type) => type != AppBiometricType.none).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get human-readable names for available biometrics
  Future<List<String>> getAvailableBiometricNames() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      return availableBiometrics.map((biometric) {
        switch (biometric) {
          case platform_types.BiometricType.fingerprint:
            return Platform.isIOS ? 'Touch ID' : 'Fingerprint';
          case platform_types.BiometricType.face:
            return Platform.isIOS ? 'Face ID' : 'Face Recognition';
          case platform_types.BiometricType.iris:
            return 'Iris Recognition';
          default:
            return 'Biometric Authentication';
        }
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Check if device has been enrolled with biometrics
  Future<bool> isEnrolled() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Authenticate user with biometrics
  Future<BiometricAuthResult> authenticate({
    String localizedReason = 'Please verify your identity to access FlowSense',
    bool useErrorDialogs = true,
    bool stickyAuth = false,
  }) async {
    try {
      // Check if biometrics are available
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return const BiometricAuthResult(
          status: AuthStatus.notAvailable,
          errorMessage: 'Biometric authentication is not available on this device',
        );
      }

      // Check if biometrics are enrolled
      final isEnrolled = await this.isEnrolled();
      if (!isEnrolled) {
        return const BiometricAuthResult(
          status: AuthStatus.notEnrolled,
          errorMessage: 'No biometric credentials have been enrolled on this device',
        );
      }

      // Perform authentication
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        // Get the biometric type that was used (approximate)
        final availableBiometrics = await getAvailableBiometrics();
        final usedBiometric = availableBiometrics.isNotEmpty 
            ? availableBiometrics.first 
            : AppBiometricType.none;

        return BiometricAuthResult(
          status: AuthStatus.success,
          usedBiometric: usedBiometric,
        );
      } else {
        return const BiometricAuthResult(
          status: AuthStatus.failed,
          errorMessage: 'Biometric authentication failed',
        );
      }
    } on PlatformException catch (e) {
      return BiometricAuthResult(
        status: _getAuthStatusFromError(e.code),
        errorMessage: _getErrorMessage(e.code, e.message),
      );
    } catch (e) {
      return BiometricAuthResult(
        status: AuthStatus.unknown,
        errorMessage: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Quick authentication method for app lock scenarios
  Future<bool> authenticateQuick({
    String reason = 'Unlock FlowSense',
  }) async {
    final result = await authenticate(
      localizedReason: reason,
      useErrorDialogs: false,
      stickyAuth: false,
    );
    return result.isSuccess;
  }

  /// Get user-friendly biometric type name
  String getBiometricTypeName(AppBiometricType type) {
    switch (type) {
      case AppBiometricType.fingerprint:
        return Platform.isIOS ? 'Touch ID' : 'Fingerprint';
      case AppBiometricType.face:
        return Platform.isIOS ? 'Face ID' : 'Face Recognition';
      case AppBiometricType.iris:
        return 'Iris Recognition';
      case AppBiometricType.none:
        return 'None';
    }
  }

  /// Get icon name for biometric type
  String getBiometricIcon(AppBiometricType type) {
    switch (type) {
      case AppBiometricType.fingerprint:
        return '👆';
      case AppBiometricType.face:
        return '😊';
      case AppBiometricType.iris:
        return '👁️';
      case AppBiometricType.none:
        return '🔒';
    }
  }

  /// Check if specific biometric type is available
  Future<bool> isBiometricTypeAvailable(AppBiometricType type) async {
    final availableBiometrics = await getAvailableBiometrics();
    return availableBiometrics.contains(type);
  }

  /// Get primary biometric type (first available)
  Future<AppBiometricType> getPrimaryBiometricType() async {
    final availableBiometrics = await getAvailableBiometrics();
    return availableBiometrics.isNotEmpty ? availableBiometrics.first : AppBiometricType.none;
  }

  /// Convert platform exception error code to AuthStatus
  AuthStatus _getAuthStatusFromError(String errorCode) {
    switch (errorCode) {
      case auth_error.notAvailable:
        return AuthStatus.notAvailable;
      case auth_error.notEnrolled:
        return AuthStatus.notEnrolled;
      case auth_error.lockedOut:
        return AuthStatus.disabled;
      case auth_error.permanentlyLockedOut:
        return AuthStatus.disabled;
      case auth_error.biometricOnlyNotSupported:
        return AuthStatus.notAvailable;
      default:
        return AuthStatus.failed;
    }
  }

  /// Get user-friendly error message
  String _getErrorMessage(String errorCode, String? platformMessage) {
    switch (errorCode) {
      case auth_error.notAvailable:
        return 'Biometric authentication is not available on this device';
      case auth_error.notEnrolled:
        return 'No biometric credentials are enrolled on this device. Please set up biometric authentication in your device settings.';
      case auth_error.lockedOut:
        return 'Biometric authentication is temporarily locked. Please try again later or use your passcode.';
      case auth_error.permanentlyLockedOut:
        return 'Biometric authentication is permanently locked. Please use your passcode and re-enable biometrics in settings.';
      case auth_error.biometricOnlyNotSupported:
        return 'Biometric-only authentication is not supported on this device';
      default:
        return platformMessage ?? 'Authentication failed';
    }
  }

  /// Stop any ongoing authentication
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      // Ignore errors when stopping authentication
    }
  }

  /// Get device-specific biometric settings instructions
  String getBiometricSetupInstructions() {
    if (Platform.isIOS) {
      return 'Go to Settings > Touch ID & Passcode or Face ID & Passcode to set up biometric authentication';
    } else {
      return 'Go to Settings > Security > Fingerprint or Biometric authentication to set up biometric login';
    }
  }

  /// Check if device supports biometric authentication at all
  Future<bool> deviceSupportsBiometrics() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  /// Get detailed biometric capability information
  Future<Map<String, dynamic>> getBiometricCapabilities() async {
    try {
      final isDeviceSupported = await deviceSupportsBiometrics();
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      final availableTypes = await getAvailableBiometrics();
      final availableNames = await getAvailableBiometricNames();

      return {
        'isDeviceSupported': isDeviceSupported,
        'canCheckBiometrics': canCheckBiometrics,
        'isAvailable': canCheckBiometrics && availableBiometrics.isNotEmpty,
        'availableBiometrics': availableBiometrics.map((b) => b.name).toList(),
        'availableTypes': availableTypes.map((t) => t.name).toList(),
        'availableNames': availableNames,
        'primaryType': availableTypes.isNotEmpty ? availableTypes.first.name : null,
        'primaryName': availableNames.isNotEmpty ? availableNames.first : null,
      };
    } catch (e) {
      return {
        'isDeviceSupported': false,
        'canCheckBiometrics': false,
        'isAvailable': false,
        'availableBiometrics': [],
        'availableTypes': [],
        'availableNames': [],
        'primaryType': null,
        'primaryName': null,
        'error': e.toString(),
      };
    }
  }
}

/// Extension methods for cleaner API usage
extension BiometricAuthServiceExtension on BiometricAuthService {
  /// Authenticate with custom messages for different scenarios
  Future<BiometricAuthResult> authenticateForAppLock() {
    return authenticate(
      localizedReason: 'Unlock FlowSense with your biometric',
      useErrorDialogs: true,
      stickyAuth: true,
    );
  }

  Future<BiometricAuthResult> authenticateForSensitiveData() {
    return authenticate(
      localizedReason: 'Verify your identity to access sensitive health data',
      useErrorDialogs: true,
      stickyAuth: false,
    );
  }

  Future<BiometricAuthResult> authenticateForExport() {
    return authenticate(
      localizedReason: 'Verify your identity to export your health data',
      useErrorDialogs: true,
      stickyAuth: false,
    );
  }

  Future<BiometricAuthResult> authenticateForSettings() {
    return authenticate(
      localizedReason: 'Verify your identity to modify security settings',
      useErrorDialogs: true,
      stickyAuth: false,
    );
  }
}
