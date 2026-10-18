import 'package:flow_ai/features/cycle/widgets/pain_body_map.dart';
import 'package:flow_ai/core/theme/app_theme.dart';
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

  testWidgets('selected feet indicator remains inside pain map bounds', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 1100);
    tester.view.devicePixelRatio = 1;

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TickerMode(
                enabled: false,
                child: PainBodyMap(
                  painAreas: const {'feet': 5.0},
                  onPainAreaChanged: (_, __) {},
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('👣'));
    await tester.pump(const Duration(milliseconds: 500));

    final mapFinder = find.descendant(
      of: find.byType(PainBodyMap),
      matching: find.byType(AspectRatio),
    );

    expect(mapFinder, findsOneWidget);

    final mapRect = tester.getRect(mapFinder);

    final feetRect = tester.getRect(
      find.byKey(const ValueKey('feet-5.0-true')),
    );

    final headRect = tester.getRect(
      find.byKey(const ValueKey('head-0.0-false')),
    );

    expect(feetRect.left, greaterThanOrEqualTo(mapRect.left));
    expect(feetRect.right, lessThanOrEqualTo(mapRect.right));
    expect(feetRect.top, greaterThanOrEqualTo(mapRect.top));
    expect(feetRect.bottom, lessThanOrEqualTo(mapRect.bottom));
    final topGap = headRect.top - mapRect.top;
    final bottomGap = mapRect.bottom - feetRect.bottom;

    expect(bottomGap, greaterThanOrEqualTo(AppTheme.spaceLg));
    expect(topGap, greaterThanOrEqualTo(AppTheme.spaceLg));
    expect((topGap - bottomGap).abs(), lessThanOrEqualTo(AppTheme.spaceLg));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });
}
