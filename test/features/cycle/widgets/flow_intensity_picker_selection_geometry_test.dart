import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flow_ai/core/models/cycle_data.dart';
import 'package:flow_ai/features/cycle/widgets/flow_intensity_picker.dart';
import 'package:flow_ai/generated/app_localizations.dart';

Widget harness({
  required FlowIntensity selected,
  double? selectedViewportHeight,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 380,
            child: FlowIntensityPicker(
              selectedIntensity: selected,
              selectedViewportHeight: selectedViewportHeight,
              onIntensitySelected: (_) {},
            ),
          ),
        ),
      ),
    ),
  );
}

Rect rectOf(WidgetTester tester, FlowIntensity state) {
  final finder = find.byKey(ValueKey('flow-option-${state.name}'));
  expect(finder, findsOneWidget);
  return tester.getRect(finder);
}

void main() {
  testWidgets(
    'selected Flow keeps width and compacts all six cells to equal row height',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const states = FlowIntensity.values;

      await tester.pumpWidget(harness(selected: FlowIntensity.none));
      await tester.pumpAndSettle();

      final natural = <FlowIntensity, Rect>{
        for (final state in states) state: rectOf(tester, state),
      };

      await tester.pumpWidget(
        harness(selected: FlowIntensity.medium, selectedViewportHeight: 560),
      );
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      final compact = <FlowIntensity, Rect>{
        for (final state in states) state: rectOf(tester, state),
      };

      final selectedHeight = compact.values.first.height;

      for (final state in states) {
        final before = natural[state]!;
        final after = compact[state]!;

        print(
          'WIDTH_STABLE_CELL '
          'state=${state.name} '
          'natural=${before.width.toStringAsFixed(3)}x'
          '${before.height.toStringAsFixed(3)} '
          'compact=${after.width.toStringAsFixed(3)}x'
          '${after.height.toStringAsFixed(3)}',
        );

        expect(
          (after.width - before.width).abs(),
          lessThan(0.75),
          reason: '${state.name}: selected width changed',
        );

        expect(
          (after.height - selectedHeight).abs(),
          lessThan(0.75),
          reason: '${state.name}: compact heights differ',
        );

        expect(
          after.height,
          lessThan(before.height),
          reason: '${state.name}: cell did not compact vertically',
        );
      }

      expect(
        find.byKey(const ValueKey('flow-selected-grid-budget')),
        findsOneWidget,
      );

      for (final state in states) {
        expect(
          find.byKey(ValueKey('flow-compact-content-${state.name}')),
          findsOneWidget,
        );
      }

      expect(tester.takeException(), isNull);
    },
  );
}
