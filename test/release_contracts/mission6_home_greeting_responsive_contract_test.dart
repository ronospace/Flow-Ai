import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final home = File(
    'lib/features/cycle/screens/home_screen.dart',
  ).readAsStringSync();

  test('Home greeting preserves the complete authenticated name', () {
    final greetingPos = home.indexOf(r"'$personalizedGreeting 👋'");
    expect(greetingPos, greaterThanOrEqualTo(0));

    final start = home.lastIndexOf('FittedBox(', greetingPos);
    expect(start, greaterThanOrEqualTo(0));

    final segment = home.substring(
      start,
      (greetingPos + 500).clamp(0, home.length),
    );

    expect(segment, contains('fit: BoxFit.scaleDown'));
    expect(segment, contains('alignment: Alignment.centerLeft'));
    expect(segment, contains('maxLines: 1'));
    expect(segment, contains('softWrap: false'));
    expect(segment, isNot(contains('TextOverflow.ellipsis')));
  });

  test('responsive greeting keeps the shared Home typography', () {
    final greetingPos = home.indexOf(r"'$personalizedGreeting 👋'");
    expect(greetingPos, greaterThanOrEqualTo(0));

    final segment = home.substring(
      greetingPos,
      (greetingPos + 450).clamp(0, home.length),
    );

    expect(segment, contains('theme.textTheme.headlineSmall'));
    expect(segment, contains('FontWeight.bold'));
  });
}
