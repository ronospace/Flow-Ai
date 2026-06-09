// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flow_ai/core/theme/app_theme.dart';
import 'package:flow_ai/features/cycle/widgets/symptom_selector.dart';
import 'package:flow_ai/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class SymptomHarness extends StatelessWidget {
  const SymptomHarness({
    super.key,
    required this.symptoms,
    this.onSymptomsChanged,
  });

  final List<String> symptoms;
  final ValueChanged<Set<String>>? onSymptomsChanged;

  @override
  Widget build(BuildContext context) {
    final selected = symptoms.toSet();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SymptomSelector(
        selectedSymptoms: selected,
        symptomSeverity: <String, double>{
          for (final symptom in selected) symptom: 4,
        },
        onSymptomsChanged: onSymptomsChanged ?? (_) {},
        onSeverityChanged: (_, __) {},
      ),
    );
  }
}

List<String> labelsFor(String state, Locale locale) {
  final isArabic = locale.languageCode == 'ar';

  switch (state) {
    case 'empty':
      return const <String>[];

    case 'realistic':
      return isArabic
          ? const <String>['تقلصات البطن', 'ألم أسفل الظهر']
          : const <String>['Abdominal cramps', 'Lower back discomfort'];

    case 'long':
      return isArabic
          ? const <String>[
              'تقلصات شديدة ومستمرة في أسفل البطن والحوض',
              'ألم مستمر في أسفل الظهر مع توتر العضلات',
            ]
          : const <String>[
              'Severe and persistent lower abdominal cramping',
              'Persistent lower-back discomfort and muscle tension',
            ];

    case 'dense':
      return isArabic
          ? const <String>[
              'تقلصات شديدة في البطن',
              'ألم مستمر في أسفل الظهر',
              'صداع متكرر',
              'انتفاخ وضغط في البطن',
              'إرهاق شديد',
              'تغيرات ملحوظة في الشهية',
              'صعوبة في النوم',
              'حساسية وتوتر عاطفي',
            ]
          : const <String>[
              'Severe abdominal cramps',
              'Persistent lower-back discomfort',
              'Recurring headache',
              'Abdominal bloating and pressure',
              'Significant fatigue',
              'Noticeable appetite changes',
              'Difficulty sleeping',
              'Emotional sensitivity and tension',
            ];

    default:
      throw ArgumentError.value(state, 'state');
  }
}

Widget auditApp({
  required double width,
  required double height,
  required double scale,
  required Brightness brightness,
  required Locale locale,
  required List<String> symptoms,
  ValueChanged<Set<String>>? onSymptomsChanged,
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
        body: SafeArea(
          child: SymptomHarness(
            symptoms: symptoms,
            onSymptomsChanged: onSymptomsChanged,
          ),
        ),
      ),
    ),
  );
}

bool isVertical(AxisDirection direction) {
  return direction == AxisDirection.down || direction == AxisDirection.up;
}

List<Object> drainExceptions(WidgetTester tester) {
  final errors = <Object>[];

  for (var index = 0; index < 50; index++) {
    final error = tester.takeException();

    if (error == null) {
      break;
    }

    errors.add(error);
  }

  return errors;
}

String summarize(Object error) {
  return error
      .toString()
      .split('\n')
      .firstWhere(
        (line) => line.trim().isNotEmpty,
        orElse: () => error.runtimeType.toString(),
      );
}

bool isVerticalScrollView(Widget widget) {
  if (widget is CustomScrollView) {
    return widget.scrollDirection == Axis.vertical;
  }

  if (widget is SingleChildScrollView) {
    return widget.scrollDirection == Axis.vertical;
  }

  if (widget is ListView) {
    return widget.scrollDirection == Axis.vertical;
  }

  if (widget is GridView) {
    return widget.scrollDirection == Axis.vertical;
  }

  return false;
}

Future<bool> reachStableScrollEnd(
  WidgetTester tester,
  ScrollPosition position,
) async {
  const tolerance = 0.5;
  double? previousMaximum;

  for (var attempt = 0; attempt < 30; attempt++) {
    await tester.pump();

    final maximum = position.maxScrollExtent;

    if ((position.pixels - maximum).abs() > tolerance) {
      position.jumpTo(maximum);
    }

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));

    final newMaximum = position.maxScrollExtent;
    final maximumIsStable =
        previousMaximum != null &&
        (newMaximum - previousMaximum).abs() <= tolerance;
    final positionIsAtEnd = (position.pixels - newMaximum).abs() <= tolerance;

    if (maximumIsStable && positionIsAtEnd) {
      return true;
    }

    previousMaximum = newMaximum;
  }

  return (position.pixels - position.maxScrollExtent).abs() <= tolerance;
}

void main() {
  test('Symptoms uses one uncapped sliver-based vertical owner', () {
    final source = File(
      'lib/features/cycle/widgets/symptom_selector.dart',
    ).readAsStringSync();

    expect(RegExp(r'return CustomScrollView\(').allMatches(source).length, 1);
    expect(
      RegExp(r'return SingleChildScrollView\(').allMatches(source).length,
      1,
      reason: 'Only the horizontal category selector may remain.',
    );
    expect(source, contains('scrollDirection: Axis.horizontal'));
    expect(source, contains('SliverList('));
    expect(source, isNot(contains('return ListView.builder(')));
    expect(source, isNot(contains('maxHeight: MediaQuery')));
    expect(source, isNot(contains('Expanded(child: _buildSymptomsList())')));
  });

  testWidgets('Symptoms passes the strict 384-scenario geometry matrix', (
    tester,
  ) async {
    const widths = <double>[360, 390, 420, 440];
    const heights = <double>[667, 844];
    const scales = <double>[1.0, 1.3, 2.0];
    const themes = <Brightness>[Brightness.light, Brightness.dark];
    const locales = <Locale>[Locale('en'), Locale('ar')];
    const states = <String>['empty', 'realistic', 'long', 'dense'];

    var scenarios = 0;
    var failedScenarios = 0;
    var wrongVerticalOwnerScenarios = 0;
    var multipleActiveVerticalScenarios = 0;
    var endpointFailures = 0;
    var totalExceptions = 0;

    final distinctErrors = <String>{};
    final failureSamples = <String>[];
    final ownerFailureSamples = <String>[];
    final endpointFailureSamples = <String>[];

    for (final width in widths) {
      for (final height in heights) {
        for (final scale in scales) {
          for (final brightness in themes) {
            for (final locale in locales) {
              for (final state in states) {
                scenarios++;

                final scenario =
                    'W=${width.toInt()} '
                    'H=${height.toInt()} '
                    'scale=$scale '
                    'theme=${brightness.name} '
                    'locale=${locale.languageCode} '
                    'state=$state';

                tester.view.physicalSize = Size(width, height);
                tester.view.devicePixelRatio = 1;

                await tester.pumpWidget(
                  auditApp(
                    width: width,
                    height: height,
                    scale: scale,
                    brightness: brightness,
                    locale: locale,
                    symptoms: labelsFor(state, locale),
                  ),
                );

                final host = find.byType(SymptomSelector, skipOffstage: false);

                // MaterialApp can briefly expose only its Localizations shell
                // while a new locale/route is being installed. Wait for the
                // actual widget-under-test instead of assuming two pumps are
                // always sufficient.
                for (
                  var mountAttempt = 0;
                  mountAttempt < 30 && host.evaluate().isEmpty;
                  mountAttempt++
                ) {
                  await tester.pump(const Duration(milliseconds: 100));
                }

                expect(
                  host,
                  findsOneWidget,
                  reason: '$scenario failed to mount SymptomSelector',
                );

                final applicationScrollViews = find.descendant(
                  of: host,
                  matching: find.byWidgetPredicate(
                    (widget) =>
                        widget is CustomScrollView ||
                        widget is SingleChildScrollView ||
                        widget is ListView ||
                        widget is GridView,
                  ),
                );

                final verticalOwners = applicationScrollViews
                    .evaluate()
                    .map((element) => element.widget)
                    .where(isVerticalScrollView)
                    .toList();

                if (verticalOwners.length != 1) {
                  wrongVerticalOwnerScenarios++;

                  if (ownerFailureSamples.length < 30) {
                    ownerFailureSamples.add(
                      '$scenario owners='
                      '${verticalOwners.map((widget) => widget.runtimeType).toList()}',
                    );
                  }
                }

                final verticalScrollableFinder = find.descendant(
                  of: host,
                  matching: find.byWidgetPredicate(
                    (widget) =>
                        widget is Scrollable &&
                        (widget.axisDirection == AxisDirection.down ||
                            widget.axisDirection == AxisDirection.up),
                  ),
                );

                final verticalScrollableElements = verticalScrollableFinder
                    .evaluate()
                    .toList();

                if (verticalScrollableElements.length != 1) {
                  wrongVerticalOwnerScenarios++;

                  if (ownerFailureSamples.length < 30) {
                    ownerFailureSamples.add(
                      '$scenario runtimeVerticalScrollables='
                      '${verticalScrollableElements.length}',
                    );
                  }
                }

                final verticalStates = verticalScrollableElements
                    .whereType<StatefulElement>()
                    .map((element) => element.state)
                    .whereType<ScrollableState>()
                    .toList();

                final activeVerticalStates = verticalStates.where((state) {
                  final position = state.position;

                  return position.hasContentDimensions &&
                      position.maxScrollExtent > 0.5;
                }).toList();

                if (activeVerticalStates.length > 1) {
                  multipleActiveVerticalScenarios++;

                  if (ownerFailureSamples.length < 30) {
                    ownerFailureSamples.add(
                      '$scenario activeVerticalScrollables='
                      '${activeVerticalStates.length}',
                    );
                  }
                }

                if (verticalStates.length == 1 &&
                    activeVerticalStates.length == 1) {
                  final verticalState = activeVerticalStates.single;

                  final reachedEnd = await reachStableScrollEnd(
                    tester,
                    verticalState.position,
                  );

                  if (!reachedEnd) {
                    endpointFailures++;

                    if (endpointFailureSamples.length < 30) {
                      endpointFailureSamples.add(
                        '$scenario '
                        'pixels=${verticalState.position.pixels} '
                        'max=${verticalState.position.maxScrollExtent}',
                      );
                    }
                  }
                }

                final errors = drainExceptions(tester);

                if (errors.isNotEmpty) {
                  failedScenarios++;
                  totalExceptions += errors.length;

                  if (failureSamples.length < 30) {
                    failureSamples.add(scenario);
                  }

                  for (final error in errors) {
                    distinctErrors.add(summarize(error));
                  }
                }

                await tester.pumpWidget(const SizedBox.shrink());
                await tester.pump(const Duration(seconds: 2));
                await tester.pump();

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
    print('SYMPTOMS REPAIR VERIFICATION');
    print('============================');
    print('Scenarios:                          $scenarios');
    print('Failed render scenarios:            $failedScenarios');
    print('Total rendering exceptions:         $totalExceptions');
    print(
      'Wrong app vertical-owner scenarios: '
      '$wrongVerticalOwnerScenarios',
    );
    print(
      'Multiple active vertical scenarios: '
      '$multipleActiveVerticalScenarios',
    );
    print('Stable endpoint failures:            $endpointFailures');
    print('Distinct errors:                     ${distinctErrors.length}');

    if (ownerFailureSamples.isNotEmpty) {
      print('');
      print('OWNER FAILURE SCENARIOS');
      print('-----------------------');

      for (final sample in ownerFailureSamples) {
        print(sample);
      }
    }

    if (endpointFailureSamples.isNotEmpty) {
      print('');
      print('ENDPOINT FAILURE SCENARIOS');
      print('--------------------------');

      for (final sample in endpointFailureSamples) {
        print(sample);
      }
    }

    if (failureSamples.isNotEmpty) {
      print('');
      print('RENDER FAILURE SCENARIOS');
      print('------------------------');

      for (final sample in failureSamples) {
        print(sample);
      }
    }

    if (distinctErrors.isNotEmpty) {
      print('');
      print('DISTINCT ERRORS');
      print('---------------');

      for (final error in distinctErrors) {
        print('ERROR: $error');
      }
    }

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();

    expect(failedScenarios, 0);
    expect(totalExceptions, 0);
    expect(wrongVerticalOwnerScenarios, 0);
    expect(multipleActiveVerticalScenarios, 0);
    expect(endpointFailures, 0);
  });
}
