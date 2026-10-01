import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow_ai/core/models/cycle_data.dart';
import 'package:flow_ai/features/cycle/widgets/flow_intensity_picker.dart';
import 'package:flow_ai/generated/app_localizations.dart';

Widget harness({
  required FlowIntensity selected,
  required ValueChanged<FlowIntensity> onChanged,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 358,
          height: 1000,
          child: FlowIntensityPicker(
            selectedIntensity: selected,
            onIntensitySelected: onChanged,
          ),
        ),
      ),
    ),
  );
}

Rect rectOf(WidgetTester tester, FlowIntensity intensity) {
  final finder = find.byKey(ValueKey('flow-option-${intensity.name}'));

  expect(finder, findsOneWidget);

  return tester.getRect(finder);
}

void main() {
  testWidgets('report exact Flow card geometry for every selected state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final states = <FlowIntensity>[
      FlowIntensity.none,
      FlowIntensity.spotting,
      FlowIntensity.light,
      FlowIntensity.medium,
      FlowIntensity.heavy,
      FlowIntensity.veryHeavy,
    ];

    final baselineRects = <FlowIntensity, Rect>{};

    for (final selected in states) {
      await tester.pumpWidget(harness(selected: selected, onChanged: (_) {}));
      await tester.pumpAndSettle();

      final rects = <FlowIntensity, Rect>{
        for (final intensity in states) intensity: rectOf(tester, intensity),
      };

      print('SELECTED=${selected.name}');

      for (final intensity in states) {
        final r = rects[intensity]!;
        print(
          '${intensity.name}: '
          'left=${r.left.toStringAsFixed(3)} '
          'top=${r.top.toStringAsFixed(3)} '
          'width=${r.width.toStringAsFixed(3)} '
          'height=${r.height.toStringAsFixed(3)}',
        );
      }

      if (selected == FlowIntensity.none) {
        baselineRects.addAll(rects);
      } else {
        for (final intensity in states) {
          final base = baselineRects[intensity]!;
          final now = rects[intensity]!;

          final dx = now.left - base.left;
          final dy = now.top - base.top;
          final dw = now.width - base.width;
          final dh = now.height - base.height;

          print(
            'DELTA ${intensity.name}: '
            'dx=${dx.toStringAsFixed(3)} '
            'dy=${dy.toStringAsFixed(3)} '
            'dw=${dw.toStringAsFixed(3)} '
            'dh=${dh.toStringAsFixed(3)}',
          );

          expect(
            dx.abs(),
            lessThan(0.01),
            reason: '${intensity.name} x-position changed with selection',
          );
          expect(
            dy.abs(),
            lessThan(0.01),
            reason: '${intensity.name} y-position changed with selection',
          );
          expect(
            dw.abs(),
            lessThan(0.01),
            reason: '${intensity.name} width changed with selection',
          );
          expect(
            dh.abs(),
            lessThan(0.01),
            reason: '${intensity.name} height changed with selection',
          );
        }
      }

      print('---');
    }
  });
}
