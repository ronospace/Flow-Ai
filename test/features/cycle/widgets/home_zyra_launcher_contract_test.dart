import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

int occurrences(String source, String value) {
  return value.allMatches(source).length;
}

void main() {
  final zyra = File(
    'lib/features/insights/widgets/floating_ai_chat.dart',
  ).readAsStringSync();

  final insights = File(
    'lib/features/insights/screens/insights_screen.dart',
  ).readAsStringSync();

  final home = File(
    'lib/features/cycle/screens/home_screen.dart',
  ).readAsStringSync();

  test('one canonical FloatingAIChat implementation remains', () {
    expect(occurrences(zyra, 'class FloatingAIChat'), 1);
  });

  test('Home and Insights each mount one launcher', () {
    expect(occurrences(home, 'FloatingAIChat('), 1);

    expect(occurrences(insights, 'FloatingAIChat('), 1);
  });

  test('Home uses its own Hero tag', () {
    expect(home.contains("'home_ai_chat_fab'"), isTrue);

    expect(zyra.contains('heroTag: widget.heroTag'), isTrue);
  });

  test('layout anchor keys are optional outside Insights', () {
    expect(zyra.contains('final GlobalKey? tabsKey;'), isTrue);

    expect(zyra.contains('final GlobalKey? periodSelectorKey;'), isTrue);
  });
}
