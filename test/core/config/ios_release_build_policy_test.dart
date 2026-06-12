import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('iOS release build policy', () {
    test('App Store script fails analysis instead of prompting through', () {
      final script = File('build_appstore.sh').readAsStringSync();

      expect(script, contains('flutter analyze'));
      expect(script, contains('Refusing App Store release build'));
      expect(script, isNot(contains('Continue anyway')));
      expect(script, isNot(contains('--no-fatal-infos')));
      expect(script, contains('flutter build ipa'));
      expect(
        script,
        contains('--export-options-plist=ios/ExportOptionsAppStore.plist'),
      );
    });

    test('iOS deployment script delegates to signed App Store build only', () {
      final script = File('scripts/deploy-ios.sh').readAsStringSync();

      expect(script, contains('./build_appstore.sh'));
      expect(script, contains('App Store IPA'));
      expect(script, isNot(contains('--no-codesign')));
      expect(script, isNot(contains('device testing')));
      expect(script, isNot(contains('Building without codesign')));
      expect(script, isNot(contains('sign and archive manually')));
    });

    test(
      'multi-platform deployment does not build no-codesign iOS release',
      () {
        final script = File('scripts/deploy-all.sh').readAsStringSync();

        expect(script, contains('./build_appstore.sh'));
        expect(script, contains('iOS App Store IPA'));
        expect(
          script,
          isNot(contains('flutter build ios --release --no-codesign')),
        );
        expect(script, isNot(contains('Building iOS app (no codesign)')));
        expect(script, isNot(contains('needs to be signed and archived')));
      },
    );
  });
}
