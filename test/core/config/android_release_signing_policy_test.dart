import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Android release signing policy', () {
    test(
      'Gradle release build uses release signing and release lint gates',
      () {
        final gradle = File('android/app/build.gradle.kts').readAsStringSync();

        expect(gradle, contains('keystorePropertiesFile'));
        expect(gradle, contains('requiredReleaseSigningKeys'));
        expect(gradle, contains('releaseSigningConfigured'));
        expect(gradle, contains('GradleException'));
        expect(gradle, contains('debug or unsigned signing.'));
        expect(gradle, contains('checkReleaseBuilds = true'));
        expect(gradle, contains('abortOnError = true'));
        expect(
          gradle,
          contains('signingConfig = signingConfigs.getByName("release")'),
        );

        expect(
          gradle,
          isNot(contains('signingConfig = signingConfigs.getByName("debug")')),
        );
        expect(gradle, isNot(contains('checkReleaseBuilds = false')));
        expect(gradle, isNot(contains('abortOnError = false')));
        expect(gradle, isNot(contains('TODO: Add your own signing config')));
        expect(gradle, isNot(contains('Signing with the debug keys')));
      },
    );

    test('release scripts refuse unsigned Android builds', () {
      final deployAndroid = File(
        'scripts/deploy-android.sh',
      ).readAsStringSync();
      final deployAll = File('scripts/deploy-all.sh').readAsStringSync();

      for (final script in [deployAndroid, deployAll]) {
        expect(script, contains('require_android_release_signing'));
        expect(script, contains('Refusing unsigned Android release build.'));
        expect(script, contains('storeFile'));
        expect(script, contains('storePassword'));
        expect(script, contains('keyAlias'));
        expect(script, contains('keyPassword'));
        expect(script, isNot(contains('Building unsigned APK')));
        expect(script, isNot(contains('Unsigned APK built successfully')));
        expect(script, isNot(contains('Android (APK - Unsigned)')));
        expect(script, isNot(contains('direct distribution or testing')));
      }
    });

    test('Android signing material remains ignored', () {
      final androidGitignore = File('android/.gitignore').readAsStringSync();

      expect(androidGitignore, contains('key.properties'));
      expect(androidGitignore, contains('**/*.jks'));
      expect(androidGitignore, contains('**/*.keystore'));
      expect(androidGitignore, contains('upload-keystore'));
    });
  });
}
