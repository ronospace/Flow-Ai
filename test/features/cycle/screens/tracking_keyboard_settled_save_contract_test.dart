import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/cycle/screens/tracking_screen.dart',
    ).readAsStringSync();
  });

  test('Save waits for stable keyboard dismissal', () {
    expect(source, contains('WidgetsBindingObserver'));
    expect(source, contains('void didChangeMetrics()'));
    expect(source, contains('View.of(context).viewInsets.bottom'));
    expect(source, contains('const Duration(milliseconds: 160)'));
    expect(source, contains('keyboardIsStillFullyDismissed'));
  });

  test('Save remains hidden while Notes owns focus', () {
    expect(source, contains('focusNode: _notesFocusNode,'));
    expect(source, contains('!_notesFocusNode.hasFocus'));
    expect(
      source,
      contains(
        '_notesFocusNode.addListener('
        '_handleKeyboardSaveFocusChanged);',
      ),
    );
  });

  test('Save visibility requires the settled state', () {
    final getterStart = source.indexOf('bool get _showSaveAction');
    expect(getterStart, greaterThanOrEqualTo(0));

    final getterEnd = source.indexOf(';', getterStart);
    expect(getterEnd, greaterThan(getterStart));

    final getter = source.substring(getterStart, getterEnd + 1);

    expect(getter, contains('_keyboardFullyDismissed'));
    expect(getter, contains('!_notesFocusNode.hasFocus'));
    expect(getter, contains('_hasUnsavedChanges'));
  });

  test('keyboard observer and timer are cleaned up', () {
    expect(source, contains('WidgetsBinding.instance.removeObserver(this);'));
    expect(source, contains('_keyboardDismissSettleTimer?.cancel();'));
    expect(source, contains('_notesFocusNode.dispose();'));
  });
}
