import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final card = File(
    'lib/features/health/widgets/healthkit_connection_card.dart',
  ).readAsStringSync();

  test('normal connection CTA is centered at 70 percent width', () {
    expect(card, contains('FractionallySizedBox('));
    expect(card, contains('widthFactor: 0.70'));
  });

  test('Health Connect install recovery remains distinct', () {
    expect(card, contains("'Install Health Connect'"));
    expect(card, contains('Widget _buildConnectionAction('));
    expect(card, contains('widthFactor: 0.70'));
    expect(RegExp(r'_buildConnectionAction\(').allMatches(card).length, 3);
  });

  test('normal actions remain Connect and Disconnect', () {
    expect(card, contains("'Connect'"));
    expect(card, contains("'Disconnect'"));
  });
}
