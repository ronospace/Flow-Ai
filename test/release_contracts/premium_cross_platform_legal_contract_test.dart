import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final paywall = File(
    'lib/features/premium/screens/premium_paywall_screen.dart',
  ).readAsStringSync();

  final firebase = File('firebase.json').readAsStringSync();
  final terms = File('web/terms.html').readAsStringSync();

  test('Premium uses platform-correct Terms ownership', () {
    expect(paywall, contains("final platform = Theme.of(context).platform"));
    expect(paywall, contains("platform == TargetPlatform.iOS"));
    expect(
      paywall,
      contains(
        'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
      ),
    );
    expect(paywall, contains('https://flowai-demo-project.web.app/terms.html'));
  });

  test('Android-visible Terms never depend exclusively on Apple EULA', () {
    expect(
      paywall,
      contains("return 'https://flowai-demo-project.web.app/terms.html';"),
    );
    expect(paywall, contains("label: 'Terms of Use'"));
  });

  test('legal cards use compact horizontal hierarchy', () {
    expect(
      paywall,
      contains('constraints: const BoxConstraints(minHeight: 52)'),
    );
    expect(paywall, contains('child: Row('));
    expect(paywall, contains('Icons.keyboard_arrow_down_rounded'));
    expect(paywall, contains('constraints.maxWidth < 300'));
  });

  test('Flow Ai Terms public surface exists and is routed', () {
    expect(terms, contains('Flow Ai - Terms of Use'));
    expect(terms, contains('ZyraFlow GmbH™'));
    expect(terms, contains('© 2026 ZyraFlow GmbH™ All rights reserved.'));

    expect(firebase, contains('"/terms"'));
    expect(firebase, contains('"/terms.html"'));
  });
}
