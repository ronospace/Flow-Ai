import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String extractMethod(
  String source,
  String startSignature,
  String endSignature,
) {
  final start = source.indexOf(startSignature);

  if (start < 0) {
    throw StateError('Method start was not found: $startSignature');
  }

  final end = source.indexOf(endSignature, start);

  if (end <= start) {
    throw StateError('Method end was not found: $endSignature');
  }

  return source.substring(start, end);
}

void main() {
  late String appBar;
  late String quickNote;

  setUpAll(() {
    final source = File(
      'lib/features/cycle/screens/tracking_screen.dart',
    ).readAsStringSync();

    appBar = extractMethod(
      source,
      '  Widget _buildCustomAppBar() {',
      '  Widget _buildTabBar() {',
    );

    quickNote = extractMethod(
      source,
      '  Widget _buildQuickNote(',
      '  String _getMoodEmoji(',
    );
  });

  test('date selector owns bounded responsive text geometry', () {
    expect(appBar, contains('Expanded('));

    expect(RegExp(r'maxLines:\s*1').allMatches(appBar), hasLength(2));

    expect(
      RegExp(r'overflow:\s*TextOverflow\.ellipsis').allMatches(appBar),
      hasLength(2),
    );

    expect(appBar, contains('mainAxisSize: MainAxisSize.min'));

    expect(appBar, isNot(contains('const Spacer()')));
  });

  test('quick-note label owns flexible wrapping geometry', () {
    expect(quickNote, contains('Flexible('));

    expect(quickNote, contains('maxLines: 2'));

    expect(quickNote, contains('overflow: TextOverflow.ellipsis'));

    expect(quickNote, contains('softWrap: true'));
  });

  test('quick-note interaction exposes explicit semantics', () {
    expect(quickNote, contains('Semantics('));

    expect(quickNote, contains('button: true'));

    expect(quickNote, contains('selected: isSelected'));

    expect(quickNote, contains('label: label'));

    expect(quickNote, contains('excludeSemantics: true'));
  });
}
