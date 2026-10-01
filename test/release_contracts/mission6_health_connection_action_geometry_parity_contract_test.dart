import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/features/health/widgets/healthkit_connection_card.dart',
  ).readAsStringSync();

  String helperSource() {
    final start = source.indexOf('Widget _buildConnectionAction(');
    expect(start, greaterThanOrEqualTo(0));

    final end = source.indexOf('\n  @override', start);
    expect(end, greaterThan(start));

    return source.substring(start, end);
  }

  String actionCallContaining(String marker) {
    final markerIndex = source.indexOf(marker);
    expect(markerIndex, greaterThanOrEqualTo(0));

    final start = source.lastIndexOf('_buildConnectionAction(', markerIndex);
    expect(start, greaterThanOrEqualTo(0));

    final end = source.indexOf('),', markerIndex);
    expect(end, greaterThan(start));

    return source.substring(start, end + 2);
  }

  test('Connect and Disconnect share one geometry owner', () {
    final helper = helperSource();

    expect(helper, contains('widthFactor: 0.70'));

    expect(helper, contains('ElevatedButton.icon'));

    expect(
      helper,
      contains('padding: const EdgeInsets.symmetric(vertical: 12)'),
    );

    expect(helper, contains('AppGeometry.radiusSm'));

    expect(
      source.indexOf('Widget _buildConnectionAction('),
      source.lastIndexOf('Widget _buildConnectionAction('),
    );
  });

  test('Connect keeps connection semantics', () {
    final connect = actionCallContaining(
      "label: isAndroidConnecting ? 'Connecting…' : 'Connect'",
    );

    expect(connect, contains('icon: Icons.link'));

    expect(connect, contains('color: AppTheme.secondaryBlue'));
  });

  test('Disconnect differs only by reversible state semantics', () {
    final disconnect = actionCallContaining("label: 'Disconnect'");

    expect(disconnect, contains('icon: Icons.link_off'));

    expect(disconnect.contains('AppTheme.disconnectCaution'), isTrue);

    expect(disconnect.contains('AppTheme.onDisconnectCaution'), isTrue);

    expect(disconnect, isNot(contains('AppTheme.errorRed')));
  });

  test('Disconnect does not duplicate button geometry locally', () {
    final disconnect = actionCallContaining("label: 'Disconnect'");

    expect(disconnect, isNot(contains('widthFactor')));

    expect(disconnect, isNot(contains('ElevatedButton')));

    expect(disconnect, isNot(contains('BorderRadius')));

    expect(disconnect, isNot(contains('EdgeInsets')));
  });
}
