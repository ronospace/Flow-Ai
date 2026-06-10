// ignore_for_file: avoid_print

import 'dart:math' as math;

import 'package:flow_ai/core/theme/app_theme.dart';
import 'package:flow_ai/features/cycle/widgets/mood_energy_slider.dart';
import 'package:flow_ai/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MoodResponsiveHarness extends StatelessWidget {
  const MoodResponsiveHarness({super.key, required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: TickerMode(
        enabled: false,
        child: MoodEnergySlider(
          label: 'Mood',
          value: value,
          min: 1,
          max: 5,
          emoji: '🙂',
          color: AppTheme.primaryRose,
          onChanged: (_) {},
        ),
      ),
    );
  }
}

Widget buildResponsiveApp({
  required double width,
  required double height,
  required double scale,
  required Brightness brightness,
  required Locale locale,
  required double value,
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.lightTheme,
    darkTheme: AppTheme.darkTheme,
    themeMode: brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
    home: MediaQuery(
      data: MediaQueryData(
        size: Size(width, height),
        textScaler: TextScaler.linear(scale),
      ),
      child: Scaffold(
        body: SafeArea(child: MoodResponsiveHarness(value: value)),
      ),
    ),
  );
}

List<Object> drainExceptions(WidgetTester tester) {
  final errors = <Object>[];

  for (var index = 0; index < 100; index++) {
    final error = tester.takeException();

    if (error == null) {
      break;
    }

    errors.add(error);
  }

  return errors;
}

String summarize(Object error) {
  final lines = error.toString().split('\n');

  for (final line in lines) {
    final trimmed = line.trim();

    if (trimmed.contains('RenderFlex overflowed')) {
      return trimmed;
    }
  }

  return lines.first.trim();
}

double horizontalEscape(Rect rect, double viewportWidth) {
  final leftEscape = math.max(0.0, -rect.left);
  final rightEscape = math.max(0.0, rect.right - viewportWidth);

  return math.max(leftEscape, rightEscape);
}

void main() {
  testWidgets(
    'MoodEnergySlider passes the strict 360-scenario geometry matrix',
    (tester) async {
      const widths = <double>[320, 360, 390, 420, 440];
      const heights = <double>[667, 844];
      const scales = <double>[1.0, 1.3, 2.0];
      const brightnessValues = <Brightness>[Brightness.light, Brightness.dark];
      const locales = <Locale>[Locale('en'), Locale('ar')];
      const values = <double>[1, 3, 5];

      const criticalKeys = <ValueKey<String>>[
        ValueKey('mood-header-responsive-layout'),
        ValueKey('mood-header-title'),
        ValueKey('mood-neural-indicator'),
        ValueKey('mood-status-badge'),
        ValueKey('mood-range-labels'),
        ValueKey('mood-range-min'),
        ValueKey('mood-range-max'),
      ];

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      var scenarios = 0;
      var failedScenarios = 0;
      var totalExceptions = 0;
      var mountFailures = 0;
      var boundaryFailures = 0;
      var maximumEscape = 0.0;
      var maximumHeight = 0.0;

      final failureSamples = <String>[];
      final distinctErrors = <String>{};

      for (final width in widths) {
        for (final height in heights) {
          for (final scale in scales) {
            for (final brightness in brightnessValues) {
              for (final locale in locales) {
                for (final value in values) {
                  scenarios++;

                  final scenario =
                      'W=${width.toInt()} '
                      'H=${height.toInt()} '
                      'scale=$scale '
                      'theme=${brightness.name} '
                      'locale=${locale.languageCode} '
                      'value=${value.toInt()}';

                  tester.view.physicalSize = Size(width, height);
                  tester.view.devicePixelRatio = 1;

                  await tester.pumpWidget(
                    buildResponsiveApp(
                      width: width,
                      height: height,
                      scale: scale,
                      brightness: brightness,
                      locale: locale,
                      value: value,
                    ),
                  );

                  await tester.pump(const Duration(seconds: 2));
                  await tester.pump();

                  final widgetFinder = find.byType(
                    MoodEnergySlider,
                    skipOffstage: false,
                  );
                  final sliderFinder = find.byType(Slider, skipOffstage: false);

                  if (widgetFinder.evaluate().length != 1 ||
                      sliderFinder.evaluate().length != 1) {
                    mountFailures++;
                    failedScenarios++;

                    if (failureSamples.length < 40) {
                      failureSamples.add(
                        '$scenario '
                        'widget=${widgetFinder.evaluate().length} '
                        'slider=${sliderFinder.evaluate().length}',
                      );
                    }
                  } else {
                    maximumHeight = math.max(
                      maximumHeight,
                      tester.getSize(widgetFinder).height,
                    );
                  }

                  var scenarioEscape = 0.0;

                  for (final key in criticalKeys) {
                    final finder = find.byKey(key, skipOffstage: false);

                    if (finder.evaluate().length != 1) {
                      mountFailures++;
                      failedScenarios++;

                      if (failureSamples.length < 40) {
                        failureSamples.add('$scenario missingKey=${key.value}');
                      }

                      continue;
                    }

                    final rect = tester.getRect(finder);
                    final escape = horizontalEscape(rect, width);

                    scenarioEscape = math.max(scenarioEscape, escape);
                  }

                  maximumEscape = math.max(maximumEscape, scenarioEscape);

                  if (scenarioEscape > 0.5) {
                    boundaryFailures++;
                    failedScenarios++;

                    if (failureSamples.length < 40) {
                      failureSamples.add(
                        '$scenario horizontalEscape='
                        '${scenarioEscape.toStringAsFixed(1)}',
                      );
                    }
                  }

                  final errors = drainExceptions(tester);

                  if (errors.isNotEmpty) {
                    failedScenarios++;
                    totalExceptions += errors.length;

                    if (failureSamples.length < 40) {
                      failureSamples.add(
                        '$scenario exceptions=${errors.length}',
                      );
                    }

                    for (final error in errors) {
                      distinctErrors.add(summarize(error));
                    }
                  }

                  await tester.pumpWidget(const SizedBox.shrink());
                  await tester.pump(const Duration(seconds: 2));

                  final teardownErrors = drainExceptions(tester);

                  if (teardownErrors.isNotEmpty) {
                    failedScenarios++;
                    totalExceptions += teardownErrors.length;

                    for (final error in teardownErrors) {
                      distinctErrors.add(summarize(error));
                    }
                  }
                }
              }
            }
          }
        }
      }

      print('');
      print('MOOD / ENERGY RESPONSIVE VERIFICATION');
      print('=====================================');
      print('Scenarios:                  $scenarios');
      print('Failed scenarios:           $failedScenarios');
      print('Mount failures:             $mountFailures');
      print('Boundary failures:          $boundaryFailures');
      print('Rendering exceptions:       $totalExceptions');
      print(
        'Maximum horizontal escape: '
        '${maximumEscape.toStringAsFixed(1)}',
      );
      print(
        'Maximum widget height:      '
        '${maximumHeight.toStringAsFixed(1)}',
      );
      print(
        'Distinct errors:            '
        '${distinctErrors.length}',
      );

      if (failureSamples.isNotEmpty) {
        print('');
        print('FAILURE SAMPLES');
        print('---------------');

        for (final sample in failureSamples) {
          print(sample);
        }
      }

      if (distinctErrors.isNotEmpty) {
        print('');
        print('DISTINCT ERRORS');
        print('---------------');

        for (final error in distinctErrors) {
          print(error);
        }
      }

      expect(mountFailures, 0);
      expect(boundaryFailures, 0);
      expect(totalExceptions, 0);
      expect(failedScenarios, 0);
      expect(maximumEscape, lessThanOrEqualTo(0.5));
    },
  );
}
