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
  });
}
