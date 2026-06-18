import 'dart:io';

import 'package:flow_ai/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/features/cycle/screens/tracking_screen.dart',
  ).readAsStringSync();

  String extractMethod(String signature) {
    final start = source.indexOf(signature);

    if (start < 0) {
      throw StateError('Method not found: $signature');
    }

    final openingBrace = source.indexOf('{', start);

    if (openingBrace < 0) {
      throw StateError('Opening brace not found: $signature');
    }

    var depth = 0;

    for (var index = openingBrace; index < source.length; index++) {
      final character = source[index];

      if (character == '{') {
        depth++;
      } else if (character == '}') {
        depth--;

        if (depth == 0) {
          return source.substring(start, index + 1);
        }
      }
    }

    throw StateError('Method did not close: $signature');
  }

  final tabBar = extractMethod('Widget _buildTabBar()');
  final tabContent = extractMethod(
    'Widget _buildTabContent(IconData icon, String label)',
  );

  test('tracking exposes five equal shared tab lanes', () {
    expect(RegExp(r'\bTab\(').allMatches(tabBar).length, 5);
    expect(tabBar, contains('isScrollable: false'));
    expect(tabBar, contains('tabAlignment: TabAlignment.fill'));
    expect(tabBar, contains('BoxConstraints(minHeight: 56)'));

    for (final width in <double>[320, 360, 390, 430]) {
      final availableWidth = width - (2 * AppTheme.spaceLg);
      final laneWidth = availableWidth / 5;

      expect(
        laneWidth,
        greaterThanOrEqualTo(48),
        reason: '$width px must preserve a 48 px tab lane',
      );
    }
  });

  test('large text retains bounded geometry', () {
    expect(tabContent, contains('MediaQuery.textScalerOf(context).scale(1)'));
    expect(tabContent, contains('textScale > 1.3'));
    expect(tabContent, contains('FittedBox('));
    expect(tabContent, contains('fit: BoxFit.scaleDown'));
    expect(tabContent, contains('maxLines: 1'));
    expect(tabContent, contains('overflow: TextOverflow.ellipsis'));
  });

  test('each tab exposes its complete localized label', () {
    expect(tabContent, contains('Semantics('));
    expect(tabContent, contains('button: true'));
    expect(tabContent, contains('label: label'));
    expect(tabContent, contains('excludeSemantics: true'));
  });

  test('tab presentation has no platform-specific fork', () {
    final combined = '$tabBar\n$tabContent';

    expect(combined, isNot(contains('Platform.isAndroid')));
    expect(combined, isNot(contains('Platform.isIOS')));
    expect(combined, isNot(contains('defaultTargetPlatform')));
  });
}
