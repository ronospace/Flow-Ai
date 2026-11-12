import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flow_ai/features/cycle/widgets/flow_intensity_picker.dart';
import 'package:flow_ai/core/models/cycle_data.dart';
import 'package:flow_ai/generated/app_localizations.dart';

class _Scenario {
  final String name;
  final Size size;
  final double textScale;

  const _Scenario(this.name, this.size, this.textScale);
}

const _scenarios = <_Scenario>[
  _Scenario('small-phone', Size(320, 568), 1.0),
  _Scenario('compact-phone', Size(360, 640), 1.0),
  _Scenario('standard-phone', Size(390, 844), 1.0),
  _Scenario('large-phone', Size(430, 932), 1.0),
  _Scenario('tablet-portrait', Size(768, 1024), 1.0),
  _Scenario('large-text-phone', Size(390, 844), 1.3),
];

void main() {
  for (final scenario in _scenarios) {
    testWidgets('Flow geometry remains structurally safe: ${scenario.name}', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = scenario.size;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final errors = <FlutterErrorDetails>[];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = errors.add;

      addTearDown(() {
        FlutterError.onError = oldHandler;
      });

      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(
            size: scenario.size,
            textScaler: TextScaler.linear(scenario.textScale),
          ),
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                child: FlowIntensityPicker(
                  selectedIntensity: FlowIntensity.none,
                  onIntensitySelected: (_) {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final overflow = errors.where(
        (e) =>
            e.exceptionAsString().contains('overflowed') ||
            e.exceptionAsString().contains('RenderFlex'),
      );

      expect(
        overflow,
        isEmpty,
        reason:
            '${scenario.name} ${scenario.size.width}x${scenario.size.height} '
            'textScale=${scenario.textScale}',
      );

      for (final name in [
        'none',
        'spotting',
        'light',
        'medium',
        'heavy',
        'veryHeavy',
      ]) {
        expect(
          find.byKey(ValueKey('flow-option-$name')),
          findsOneWidget,
          reason: '${scenario.name}: missing $name tile',
        );
      }
    });
  }
}
