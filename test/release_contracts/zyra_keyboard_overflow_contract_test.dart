import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/features/insights/widgets/floating_ai_chat.dart',
  ).readAsStringSync();

  test('centralized IME lifecycle owns Zyra keyboard presentation', () {
    expect(
      source,
      contains('_shellController.isKeyboardVisible || keyboardInset > 0'),
    );
  });

  test('suggested questions leave layout immediately while IME is open', () {
    expect(source, contains('if (!keyboardOpen)'));

    expect(
      source,
      isNot(
        contains(
          'duration: const Duration(milliseconds: 220),\n'
          '                            curve: Curves.easeOutCubic,\n'
          '                            child: keyboardOpen',
        ),
      ),
    );
  });

  test(
    'quick replies and input remain present outside keyboard transition',
    () {
      expect(source, contains('_buildEnhancedQuickReplies(theme)'));
      expect(source, contains('_buildEnhancedInput(theme, keyboardOpen)'));
    },
  );
}
