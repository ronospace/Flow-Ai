import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flow_ai/core/models/cycle_data.dart';
import 'package:flow_ai/features/cycle/widgets/flow_intensity_picker.dart';
import 'package:flow_ai/generated/app_localizations.dart';

class _Case {
  final String name;
  final double width;
  final double viewportHeight;
  final double textScale;

  const _Case(this.name, this.width, this.viewportHeight, this.textScale);
}

const _cases = <_Case>[
  _Case('small-phone', 320, 568, 1.0),
  _Case('compact-phone', 360, 640, 1.0),
  _Case('standard-phone', 390, 844, 1.0),
  _Case('large-phone', 430, 932, 1.0),
  _Case('standard-large-text', 390, 844, 1.3),
  _Case('tablet-portrait', 768, 1024, 1.0),
];

Future<double> _measureNaturalGridHeight(
  WidgetTester tester,
  _Case scenario,
) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(scenario.width, scenario.viewportHeight);

  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(
          size: Size(scenario.width, scenario.viewportHeight),
          textScaler: TextScaler.linear(scenario.textScale),
        ),
        child: Scaffold(
          // Scroll ownership is deliberate here:
          // measure Flow at natural height without forcing it into
          // the test viewport and creating a RenderFlex overflow.
          body: SingleChildScrollView(
            child: SizedBox(
              width: scenario.width,
              child: FlowIntensityPicker(
                selectedIntensity: FlowIntensity.none,
                onIntensitySelected: (_) {},
              ),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();

  final twoColumn = find.byKey(const ValueKey('flow-grid-columns-2'));
  final oneColumn = find.byKey(const ValueKey('flow-grid-columns-1'));

  final finder = twoColumn.evaluate().isNotEmpty ? twoColumn : oneColumn;

  expect(finder, findsOneWidget, reason: '${scenario.name}: Flow grid missing');

  return tester.getSize(finder).height;
}

void main() {
  for (final scenario in _cases) {
    testWidgets('natural Flow geometry: ${scenario.name}', (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final naturalHeight = await _measureNaturalGridHeight(tester, scenario);

      final fitsWholeScreen = naturalHeight <= scenario.viewportHeight;

      print(
        'FLOW_NATURAL '
        'name=${scenario.name} '
        'width=${scenario.width.toStringAsFixed(0)} '
        'viewportHeight=${scenario.viewportHeight.toStringAsFixed(0)} '
        'textScale=${scenario.textScale} '
        'naturalGridHeight=${naturalHeight.toStringAsFixed(2)} '
        'fitsWholeScreen=$fitsWholeScreen',
      );

      expect(naturalHeight, greaterThan(0));
    });
  }
}
