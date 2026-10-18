import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final splash = File(
    'lib/features/onboarding/screens/splash_screen.dart',
  ).readAsStringSync();

  final storyboard = File(
    'ios/Runner/Base.lproj/LaunchScreen.storyboard',
  ).readAsStringSync();

  test('startup retains circular loading presentation', () {
    expect(splash, contains('CircularProgressIndicator('));
    expect(splash, isNot(contains('LinearProgressIndicator(')));
  });

  test('startup no longer imposes legacy four second dwell', () {
    expect(splash, isNot(contains('Duration(seconds: 4)')));
    expect(splash, contains('Duration(milliseconds: 900)'));
  });

  test(
    'route resolution occurs concurrently with minimum brand transition',
    () {
      expect(splash, contains('AppStateService().getInitialRoute()'));
      expect(splash, contains('Future.wait<Object?>'));
    },
  );

  test('canonical Flutter splash identity is retained', () {
    expect(splash, contains('FlowAiLogo('));
    expect(splash, contains("'Flow Ai'"));
  });

  test('iOS native launch remains background-only', () {
    expect(storyboard, isNot(contains('image="LaunchImage"')));
    expect(storyboard, isNot(contains('<imageView')));
    expect(
      storyboard,
      contains('backgroundColor" systemColor="systemBackgroundColor"'),
    );
    expect(storyboard, contains('launchScreen="YES"'));
  });
}
