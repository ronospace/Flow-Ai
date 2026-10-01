import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Zyra geometry remains max until physical IME dismissal completes', () {
    final source = File(
      'lib/features/insights/widgets/floating_ai_chat.dart',
    ).readAsStringSync();

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
      contains(
        'final forceMaxMode = keyboardOpen || _shellController.isFullScreen;',
      ),
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
  });

  test('Zyra positioned bottom uses the same authoritative IME inset', () {
    final source = File(
      'lib/features/insights/widgets/floating_ai_chat.dart',
    ).readAsStringSync();

    expect(source, contains('MediaQuery.of(context).padding.bottom +'));
    expect(source, contains('keyboardInset +'));
  });

  test('IME dismissal is finalized by window metrics, not focus loss', () {
    final source = File(
      'lib/features/insights/widgets/floating_ai_chat.dart',
    ).readAsStringSync();

    final shell = File(
      'lib/features/insights/widgets/zyra/controllers/'
      'zyra_shell_controller.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('with TickerProviderStateMixin, WidgetsBindingObserver'),
    );

    expect(source, contains('void didChangeMetrics()'));

    expect(source, contains('final physicalImeVisible = rawImeInset > 0;'));

    expect(source, contains('_shellController.setKeyboardVisibility(true);'));

    expect(
      source,
      isNot(
        contains(
          '_shellController.setKeyboardVisibility('
          '_inputFocusNode.hasFocus)',
        ),
      ),
    );

    final restoreStart = shell.indexOf('void restoreDialogState');
    expect(restoreStart, greaterThanOrEqualTo(0));

    final restoreEnd = shell.indexOf('\n  }', restoreStart);
    expect(restoreEnd, greaterThan(restoreStart));

    final restore = shell.substring(restoreStart, restoreEnd);

    expect(restore, isNot(contains('isKeyboardVisible')));
  });

  test(
    'keyboard lifecycle is monotonic across Android pre-open zero metrics',
    () {
      final source = File(
        'lib/features/insights/widgets/floating_ai_chat.dart',
      ).readAsStringSync();

      expect(source, contains('bool _awaitingPhysicalImeOpen = false;'));

      expect(source, contains('bool _hasObservedPhysicalIme = false;'));

      expect(
        source,
        contains(
          'if (_awaitingPhysicalImeOpen && '
          '_inputFocusNode.hasFocus)',
        ),
      );

      expect(source, contains('if (_hasObservedPhysicalIme)'));

      expect(
        source,
        contains(
          'final physicalImeVisible = '
          'rawImeInset > 0;',
        ),
      );

      final focusStart = source.indexOf('_inputFocusNode = FocusNode()');

      final focusEnd = source.indexOf('// Initialize chat service', focusStart);

      expect(focusStart, greaterThanOrEqualTo(0));
      expect(focusEnd, greaterThan(focusStart));

      final focusBlock = source.substring(focusStart, focusEnd);

      expect(focusBlock, isNot(contains('setKeyboardVisibility(false)')));

      expect(focusBlock, isNot(contains('setState(')));
    },
  );
}
