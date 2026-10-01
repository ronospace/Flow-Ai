import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/features/insights/widgets/floating_ai_chat.dart',
  ).readAsStringSync();

  test(
    'Zyra keyboard presentation uses centralized IME lifecycle authority',
    () {
      expect(
        source,
        contains(
          'final keyboardInset = MediaQuery.of(context).viewInsets.bottom;',
        ),
      );

      expect(
        source,
        contains('_shellController.isKeyboardVisible || keyboardInset > 0'),
      );

      expect(
        source,
        isNot(
          contains(
            'final keyboardOpen = _inputFocusNode.hasFocus;\n'
            '    final forceMaxMode',
          ),
        ),
      );
    },
  );

  test('AnimatedPositioned uses the same IME inset', () {
    expect(
      source,
      contains(
        'MediaQuery.of(context).padding.bottom +\n'
        '                keyboardInset +',
      ),
    );
  });
}
