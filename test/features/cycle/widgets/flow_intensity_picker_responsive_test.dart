import 'dart:io';

import 'package:flow_ai/core/models/cycle_data.dart';
import 'package:flow_ai/core/theme/app_theme.dart';
import 'package:flow_ai/features/cycle/widgets/flow_intensity_picker.dart';
import 'package:flow_ai/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Flow has one outer scroll owner and no fixed nested grid', () {
    final tracking = File(
      'lib/features/cycle/screens/tracking_screen.dart',
    ).readAsStringSync();

    final flow = File(
      'lib/features/cycle/widgets/flow_intensity_picker.dart',
    ).readAsStringSync();

    final start = tracking.indexOf('Widget _buildFlowTab()');
    final end = tracking.indexOf('Widget _buildSymptomsTab()', start);
    final flowTab = tracking.substring(start, end);

    expect('SingleChildScrollView'.allMatches(flowTab).length, equals(1));
    expect(flow, isNot(contains('height: 620')));
    expect(flow, isNot(contains('GridView.builder')));
    expect(flow, isNot(contains('NeverScrollableScrollPhysics')));
    expect(flow, contains('_buildResponsiveOptionGrid'));
  });

  const widths = [360.0, 390.0, 420.0, 440.0];
  const scales = [1.0, 1.3, 2.0];
  const brightnessValues = [Brightness.light, Brightness.dark];

  for (final width in widths) {
    for (final scale in scales) {
      for (final brightness in brightnessValues) {
        testWidgets('Flow $width scale $scale $brightness has six '
            'unclipped cells', (tester) async {
          tester.view.physicalSize = Size(width, 1100);
          tester.view.devicePixelRatio = 1;

          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            MaterialApp(
              locale: const Locale('en'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: brightness == Brightness.dark
                  ? ThemeMode.dark
                  : ThemeMode.light,
              home: MediaQuery(
                data: MediaQueryData(
                  size: Size(width, 1100),
                  textScaler: TextScaler.linear(scale),
                  disableAnimations: true,
                ),
                child: Scaffold(
                  body: SingleChildScrollView(
                    key: const ValueKey('flow-scroll-owner'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: FlowIntensityPicker(
                        selectedIntensity: FlowIntensity.veryHeavy,
                        onIntensitySelected: (_) {},
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();

          final expectedColumns = scale == 1.0 ? 2 : 1;

          expect(
            find.byKey(ValueKey('flow-grid-columns-$expectedColumns')),
            findsOneWidget,
          );

          const optionNames = [
            'none',
            'spotting',
            'light',
            'medium',
            'heavy',
            'veryHeavy',
          ];

          for (final name in optionNames) {
            expect(find.byKey(ValueKey('flow-option-$name')), findsOneWidget);
          }

          final lastCard = find.byKey(const ValueKey('flow-option-veryHeavy'));
          final aiPanel = find.byKey(const ValueKey('flow-ai-insights'));

          expect(aiPanel, findsOneWidget);
          expect(tester.takeException(), isNull);

          final lastRect = tester.getRect(lastCard);
          final aiRect = tester.getRect(aiPanel);

          expect(
            lastRect.bottom,
            lessThanOrEqualTo(aiRect.top),
            reason: 'AI panel must follow, not cover, the last row',
          );

          await tester.ensureVisible(lastCard);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);

          await tester.ensureVisible(aiPanel);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
