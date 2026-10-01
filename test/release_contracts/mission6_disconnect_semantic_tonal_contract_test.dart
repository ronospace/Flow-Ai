import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/features/health/widgets/healthkit_connection_card.dart',
  ).readAsStringSync();

  final theme = File('lib/core/theme/app_theme.dart').readAsStringSync();

  String disconnectCall() {
    final label = source.indexOf("label: 'Disconnect'");
    expect(label, greaterThanOrEqualTo(0));

    final start = source.lastIndexOf('_buildConnectionAction(', label);
    expect(start, greaterThanOrEqualTo(0));

    final end = source.indexOf('),', label);
    expect(end, greaterThan(start));

    return source.substring(start, end + 2);
  }

  test('Disconnect uses reversible caution semantics', () {
    final call = disconnectCall();

    expect(call, contains('AppTheme.disconnectCautionDark'));

    expect(call, contains('AppTheme.disconnectCaution'));

    expect(call, contains('AppTheme.onDisconnectCautionDark'));

    expect(call, contains('AppTheme.onDisconnectCaution'));

    expect(call, isNot(contains('AppTheme.errorRed')));

    expect(call, isNot(contains('.colorScheme.errorContainer')));
  });

  test('reversible caution tokens are centrally owned', () {
    expect(theme, contains('disconnectCaution'));

    expect(theme, contains('disconnectCautionDark'));

    expect(theme, contains('onDisconnectCaution'));

    expect(theme, contains('onDisconnectCautionDark'));
  });

  test('shared action helper keeps geometry ownership', () {
    expect(source, contains('widthFactor: 0.70'));

    expect(source, contains('Color? foregroundColor'));

    expect(
      source,
      contains('foregroundColor: foregroundColor ?? Colors.white'),
    );
  });
}
