import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/features/onboarding/widgets/onboarding_page.dart',
  ).readAsStringSync();

  test('onboarding page owns height from its actual parent viewport', () {
    expect(source, contains('return LayoutBuilder('));
    expect(source, contains('constraints.maxHeight'));
    expect(source, contains('const pagePadding = 24.0'));
    expect(
      source,
      contains('(constraints.maxHeight - (pagePadding * 2)).clamp('),
    );
  });

  test(
    'onboarding page does not derive child height from global MediaQuery',
    () {
      expect(source, isNot(contains('MediaQuery.of(context).size.height')));
      expect(source, isNot(contains('MediaQuery.sizeOf(context).height')));
    },
  );

  test(
    'onboarding page preserves scroll fallback and centered composition',
    () {
      expect(source, contains('SingleChildScrollView('));
      expect(
        source,
        contains(
          'constraints: BoxConstraints(minHeight: availableContentHeight)',
        ),
      );
      expect(source, contains('mainAxisAlignment: MainAxisAlignment.center'));
    },
  );

  test('verified mobile geometry uses no platform-specific layout branch', () {
    expect(source, isNot(contains('Platform.isAndroid')));
    expect(source, isNot(contains('Platform.isIOS')));
    expect(source, isNot(contains('defaultTargetPlatform')));
  });
}
