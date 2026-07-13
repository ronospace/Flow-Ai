import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('biometric release contract', () {
    test('iOS declares Face ID purpose string', () {
      final plist = File('ios/Runner/Info.plist').readAsStringSync();

      expect(plist, contains('NSFaceIDUsageDescription'));
      expect(plist, contains('Use Face ID to securely unlock Flow Ai.'));
    });

    test('Android declares modern and legacy biometric permissions', () {
      final manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();

      expect(manifest, contains('android.permission.USE_BIOMETRIC'));
      expect(manifest, contains('android.permission.USE_FINGERPRINT'));
      expect(manifest, contains('android:maxSdkVersion="27"'));
    });

    test('auth screen gates biometric login on enrolled biometrics', () {
      final authScreen = File(
        'lib/features/auth/screens/auth_screen.dart',
      ).readAsStringSync();
      final biometricButton = File(
        'lib/features/auth/widgets/biometric_button.dart',
      ).readAsStringSync();

      expect(authScreen, contains('LocalAuthentication'));
      expect(authScreen, contains('canCheckBiometrics'));
      expect(authScreen, contains('isDeviceSupported'));
      expect(authScreen, contains('getAvailableBiometrics'));
      expect(authScreen, contains('availableBiometrics.isNotEmpty'));
      expect(authScreen, contains('_biometricsAvailable && _isLogin'));
      expect(biometricButton, contains('Use \$biometricLabel'));
    });
    test('auth service bridges biometric preference keys', () {
      final authService = File(
        'lib/core/services/auth_service.dart',
      ).readAsStringSync();

      expect(
        authService,
        contains("_biometricEnabledKey = 'biometric_enabled'"),
      );
      expect(
        authService,
        contains("_biometricsEnabledPreferenceKey = 'biometrics_enabled'"),
      );
      expect(
        authService,
        contains('setBool(_biometricsEnabledPreferenceKey, enabled)'),
      );
      expect(authService, contains('getBool(_biometricsEnabledPreferenceKey)'));
    });

    test('auth screen gates biometric login on enabled preference', () {
      final authScreen = File(
        'lib/features/auth/screens/auth_screen.dart',
      ).readAsStringSync();

      expect(authScreen, contains('await _authService.initialize()'));
      expect(
        authScreen,
        contains('final biometricsEnabled = _authService.isBiometricEnabled()'),
      );
      expect(authScreen, contains('biometricsEnabled &&'));
    });
  });
}
