import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Runner disables quoted framework-header warnings', () {
    final project = File(
      'ios/Runner.xcodeproj/project.pbxproj',
    ).readAsStringSync();

    const enabledSetting =
        'CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;';
    const disabledSetting =
        'CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = NO;';

    expect(project.contains(enabledSetting), isFalse);
    expect(disabledSetting.allMatches(project).length, greaterThanOrEqualTo(3));
  });
}
