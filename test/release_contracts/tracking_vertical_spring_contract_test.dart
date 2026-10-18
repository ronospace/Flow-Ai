import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all Track vertical pages use the centralized spring owner', () {
    final source = File(
      'lib/features/cycle/screens/tracking_screen.dart',
    ).readAsStringSync();

    expect(source.split('physics: AppScrollPhysics.spring').length - 1, 4);

    expect(
      source,
      contains("import '../../../core/ui/app_scroll_physics.dart';"),
    );
  });

  test('Symptoms vertical owner uses the centralized spring physics', () {
    final source = File(
      'lib/features/cycle/widgets/symptom_selector.dart',
    ).readAsStringSync();

    expect(source, contains('physics: AppScrollPhysics.spring'));
  });

  test('central owner keeps bounce plus short-page dragging', () {
    final owner = File(
      'lib/core/ui/app_scroll_physics.dart',
    ).readAsStringSync();

    expect(owner, contains('BouncingScrollPhysics('));
    expect(owner, contains('AlwaysScrollableScrollPhysics()'));
  });
}
