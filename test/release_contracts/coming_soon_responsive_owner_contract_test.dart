import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String metrics;
  late String owner;

  setUpAll(() {
    metrics = File(
      'lib/core/layout/app_layout_metrics.dart',
    ).readAsStringSync();

    owner = File('lib/core/widgets/coming_soon_widget.dart').readAsStringSync();
  });

  test('Coming Soon height breakpoints are centrally owned', () {
    expect(
      metrics,
      contains('static const double comingSoonCompactHeightBreakpoint = 860;'),
    );
    expect(
      metrics,
      contains('static const double comingSoonTightHeightBreakpoint = 700;'),
    );
  });

  test('Coming Soon widget consumes centralized height breakpoints', () {
    expect(
      owner,
      contains('AppLayoutMetrics.comingSoonCompactHeightBreakpoint'),
    );
    expect(owner, contains('AppLayoutMetrics.comingSoonTightHeightBreakpoint'));

    expect(owner, isNot(contains('size.height < 860')));
    expect(owner, isNot(contains('screenSize.height < 700')));
  });

  test('responsive behavior remains viewport-driven, not platform-driven', () {
    expect(owner, isNot(contains('Platform.isAndroid')));
    expect(owner, isNot(contains('Platform.isIOS')));
    expect(owner, isNot(contains('TargetPlatform.android')));
    expect(owner, isNot(contains('TargetPlatform.iOS')));
  });
}
