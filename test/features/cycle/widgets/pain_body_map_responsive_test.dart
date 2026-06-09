import 'package:flow_ai/features/cycle/widgets/pain_body_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const widths = [360.0, 390.0, 420.0, 440.0];
  const scales = [1.0, 1.3, 2.0];
  const themes = [Brightness.light, Brightness.dark];

  for (final width in widths) {
    for (final scale in scales) {
      for (final brightness in themes) {
        testWidgets(
          'Pain map $width scale $scale $brightness has no overflow',
          (tester) async {
            tester.view.physicalSize = Size(width, 1100);
            tester.view.devicePixelRatio = 1;

            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);

            await tester.pumpWidget(
              MaterialApp(
                theme: ThemeData(useMaterial3: true, brightness: brightness),
                home: MediaQuery(
                  data: MediaQueryData(
                    size: Size(width, 1100),
                    textScaler: TextScaler.linear(scale),
                    disableAnimations: true,
                  ),
                  child: Scaffold(
                    body: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: PainBodyMap(
                          painAreas: const {},
                          onPainAreaChanged: (_, __) {},
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );

            await tester.pump(const Duration(milliseconds: 500));
            expect(tester.takeException(), isNull);

            await tester.tap(find.text('💓'));
            await tester.pump(const Duration(milliseconds: 500));

            expect(find.text('Quick Pain Levels'), findsOneWidget);
            expect(tester.takeException(), isNull);

            await tester.pumpWidget(const SizedBox.shrink());
            await tester.pump(const Duration(seconds: 2));
          },
        );
      }
    }
  }
}
