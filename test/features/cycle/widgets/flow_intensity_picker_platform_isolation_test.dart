import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flow_ai/core/models/cycle_data.dart';
import 'package:flow_ai/features/cycle/widgets/flow_intensity_picker.dart';
import 'package:flow_ai/generated/app_localizations.dart';

Widget harness({
  required TargetPlatform platform,
  required FlowIntensity selected,
  double? selectedViewportHeight,
}) {
  return MaterialApp(
    theme: ThemeData(platform: platform),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SingleChildScrollView(
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
  );
}

Rect cell(WidgetTester tester, FlowIntensity state) {
  return tester.getRect(find.byKey(ValueKey('flow-option-${state.name}')));
}

void main() {
  testWidgets('iOS preserves natural Flow geometry when selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(platform: TargetPlatform.iOS, selected: FlowIntensity.none),
    );
    await tester.pumpAndSettle();

    final baseline = {
      for (final state in FlowIntensity.values) state: cell(tester, state),
    };

    await tester.pumpWidget(
      harness(
        platform: TargetPlatform.iOS,
        selected: FlowIntensity.heavy,
        selectedViewportHeight: null,
      ),
    );
    await tester.pumpAndSettle();

    for (final state in FlowIntensity.values) {
      final before = baseline[state]!;
      final after = cell(tester, state);

      expect((after.width - before.width).abs(), lessThan(0.01));
      expect((after.height - before.height).abs(), lessThan(0.01));
    }

    expect(
      find.byKey(const ValueKey('flow-selected-grid-budget')),
      findsNothing,
    );
  });

  testWidgets('Android selected Flow keeps compact budget', (tester) async {
    await tester.pumpWidget(
      harness(
        platform: TargetPlatform.android,
        selected: FlowIntensity.heavy,
        selectedViewportHeight: 560,
      ),
    );

    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('flow-selected-grid-budget')),
      findsOneWidget,
    );
  });
}
