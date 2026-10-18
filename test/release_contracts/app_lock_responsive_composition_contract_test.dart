import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/features/auth/screens/app_lock_screen.dart',
  ).readAsStringSync();

  test('App Lock uses viewport-owned responsive scroll composition', () {
    expect(source, contains('child: LayoutBuilder('));
    expect(source, contains('return SingleChildScrollView('));
    expect(source, contains('physics: const BouncingScrollPhysics()'));
    expect(
      source,
      contains('minHeight: constraints.maxHeight - 56'),
    );
  });

  test('App Lock preserves centered bounded content', () {
    expect(source, contains('constraints: const BoxConstraints(maxWidth: 420)'));
    expect(source, contains('mainAxisAlignment: MainAxisAlignment.center'));
  });

  test('App Lock has no platform geometry fork', () {
    expect(source, isNot(contains('Platform.isAndroid')));
    expect(source, isNot(contains('Platform.isIOS')));
    expect(source, isNot(contains('defaultTargetPlatform')));
  });

  test('App Lock security actions remain production-owned', () {
    expect(source, contains('final result = await AppLockService().unlock()'));
    expect(source, contains("context.go('/home')"));
    expect(source, contains('await AppStateService().resetAppState()'));
    expect(source, contains("context.go('/auth')"));
  });
}
