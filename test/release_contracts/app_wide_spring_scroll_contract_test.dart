import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final owner = File(
    'lib/core/ui/app_scroll_physics.dart',
  ).readAsStringSync();

  final main = File(
    'lib/main.dart',
  ).readAsStringSync();

  final platform = File(
    'lib/core/services/platform_service.dart',
  ).readAsStringSync();

  test('one shared spring owner provides bounce and short-page drag', () {
    expect(owner, contains('BouncingScrollPhysics('));
    expect(owner, contains('AlwaysScrollableScrollPhysics()'));
  });

  test('both app roots inherit the same shared scroll behavior', () {
    expect(main, contains('return AppScrollPhysics.spring;'));
    expect(main.split('scrollBehavior: AppScrollBehavior()').length - 1, 2);
  });

  test('adaptive platform API no longer clamps Android scrolling', () {
    expect(platform, contains('return AppScrollPhysics.spring;'));
    expect(platform, isNot(contains('ClampingScrollPhysics()')));
  });
}
