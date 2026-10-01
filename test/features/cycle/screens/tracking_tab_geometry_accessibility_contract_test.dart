import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final tracking = File(
    'lib/features/cycle/screens/tracking_screen.dart',
  ).readAsStringSync();

  final shared = File(
    'lib/core/ui/app_segmented_selector.dart',
  ).readAsStringSync();

  test('Track exposes five localized shared selector entries', () {
    expect(tracking, contains('localizations.flowTab'));
    expect(tracking, contains('localizations.symptomsTab'));
    expect(tracking, contains('localizations.moodTab'));
    expect(tracking, contains('localizations.painTab'));
    expect(tracking, contains('localizations.notesTab'));

    expect(tracking, contains('AppSegmentedSelector('));
  });

  test('narrow widths scroll instead of rigidly compressing labels', () {
    expect(shared, contains('SingleChildScrollView('));
    expect(shared, contains('scrollDirection: Axis.horizontal'));
    expect(shared, contains('mainAxisSize: MainAxisSize.min'));
    expect(shared, contains('softWrap: false'));
    expect(shared, contains('overflow: TextOverflow.visible'));

    expect(tracking, isNot(contains('isScrollable: false')));
    expect(tracking, isNot(contains('TabAlignment.fill')));
  });

  test('each selector entry exposes its complete label semantically', () {
    expect(shared, contains('Semantics('));
    expect(shared, contains('button: true'));
    expect(shared, contains('label: widget.labels[index]'));
    expect(shared, contains('excludeSemantics: true'));
  });

  test('shared selector has no platform-specific presentation fork', () {
    expect(shared, isNot(contains('Platform.isAndroid')));
    expect(shared, isNot(contains('Platform.isIOS')));
    expect(shared, isNot(contains('defaultTargetPlatform')));
  });

  test('Track preserves PageController and TabController synchronization', () {
    expect(tracking, contains('_pageController.animateToPage('));
    expect(tracking, contains('_tabController.animateTo(index)'));
    expect(tracking, contains('onPageChanged: (index)'));
  });
}
