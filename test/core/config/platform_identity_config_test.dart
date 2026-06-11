import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('platform identity defaults', () {
    test('active PlatformConfig defaults match native runtime identities', () {
      final platformConfig = File(
        'lib/core/config/platform_config.dart',
      ).readAsStringSync();

      expect(platformConfig, contains("'IOS_BUNDLE_ID'"));
      expect(platformConfig, contains("defaultValue: 'com.flowai.health'"));
      expect(platformConfig, contains("'ANDROID_PACKAGE_NAME'"));
      expect(platformConfig, contains("defaultValue: 'com.flowai.app'"));

      expect(
        platformConfig,
        isNot(
          contains(
            "'ANDROID_PACKAGE_NAME',\n      defaultValue: 'com.flowai.health'",
          ),
        ),
        reason:
            'Android package default must match android/app/build.gradle.kts.',
      );
    });

    test('native Android and iOS identities remain explicit', () {
      final androidGradle = File(
        'android/app/build.gradle.kts',
      ).readAsStringSync();
      final androidGoogleServices = File(
        'android/app/google-services.json',
      ).readAsStringSync();
      final iosProject = File(
        'ios/Runner.xcodeproj/project.pbxproj',
      ).readAsStringSync();
      final iosGoogleServices = File(
        'ios/Runner/GoogleService-Info.plist',
      ).readAsStringSync();

      expect(androidGradle, contains('applicationId = "com.flowai.app"'));
      expect(
        androidGoogleServices,
        contains('"package_name": "com.flowai.app"'),
      );
      expect(
        iosProject,
        contains('PRODUCT_BUNDLE_IDENTIFIER = com.flowai.health;'),
      );
      expect(iosGoogleServices, contains('<string>com.flowai.health</string>'));
    });
  });
}
