import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final shared = File(
    'lib/core/ui/app_segmented_selector.dart',
  ).readAsStringSync();

  final tracking = File(
    'lib/features/cycle/screens/tracking_screen.dart',
  ).readAsStringSync();

  test('horizontal selector physics has one centralized owner', () {
    expect(
      shared,
      contains('abstract final class AppHorizontalSelectorBehavior'),
    );
    expect(shared, contains('BouncingScrollPhysics('));
    expect(shared, contains('AlwaysScrollableScrollPhysics()'));
  });

  test('shared selector owns horizontal scrolling', () {
    expect(shared, contains('SingleChildScrollView('));
    expect(shared, contains('scrollDirection: Axis.horizontal'));
    expect(shared, contains('physics: AppHorizontalSelectorBehavior.physics'));
  });

  test('Track delegates capsule presentation to shared selector', () {
    expect(tracking, contains('AppSegmentedSelector('));
    expect(tracking, contains('selectedIndex: _tabController.index'));
    expect(tracking, contains('_tabController.animateTo(index)'));

    expect(tracking, isNot(contains('isScrollable: false')));
    expect(tracking, isNot(contains('TabAlignment.fill')));
  });

  test('shared selector centrally owns optional icons and semantics', () {
    expect(shared, contains('final List<IconData?>? icons'));
    expect(shared, contains('Semantics('));
    expect(shared, contains('button: true'));
    expect(shared, contains('selected: selected'));
    expect(shared, contains('label: widget.labels[index]'));
  });
}
