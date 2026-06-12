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
      final deploymentService = File(
        'lib/features/deployment/services/deployment_service.dart',
      ).readAsStringSync();
      final buildConfig = File(
        'lib/core/config/build_config.dart',
      ).readAsStringSync();

      expect(deploymentService, contains("bundleId: 'com.flowai.health'"));
      expect(deploymentService, isNot(contains('com.flowiq.app')));
      expect(buildConfig, contains("namespace 'com.flowai.app'"));
      expect(buildConfig, contains("applicationId 'com.flowai.app'"));
      expect(buildConfig, contains('signingConfig signingConfigs.release'));
      expect(
        buildConfig,
        isNot(contains('signingConfig signingConfigs.debug')),
      );
    });
  });
}
