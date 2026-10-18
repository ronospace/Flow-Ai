import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flow_ai/features/auth/screens/auth_choice_screen.dart';

Future<void> mountAuthChoice(
  WidgetTester tester, {
  required Size size,
  required double textScale,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: size,
        textScaler: TextScaler.linear(textScale),
      ),
      child: const MaterialApp(home: AuthChoiceScreen()),
    ),
  );

  await tester.pump();
}

void main() {
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.clearAllTestValues();
  });

  for (final scenario in <({String name, Size size, double scale})>[
    (name: '320x568 scale 1.0', size: Size(320, 568), scale: 1.0),
    (name: '320x568 scale 2.0', size: Size(320, 568), scale: 2.0),
    (name: '360x640 scale 1.0', size: Size(360, 640), scale: 1.0),
    (name: '360x640 scale 2.0', size: Size(360, 640), scale: 2.0),
  ]) {
    testWidgets('AuthChoice ${scenario.name} has no overflow', (tester) async {
      await mountAuthChoice(
        tester,
        size: scenario.size,
        textScale: scenario.scale,
      );

      await tester.pump(const Duration(milliseconds: 100));

      final exception = tester.takeException();

      expect(
        exception,
        isNull,
        reason:
            'AuthChoice overflowed at ${scenario.size.width}x${scenario.size.height} '
            'textScale=${scenario.scale}',
      );
    });
  }
}
