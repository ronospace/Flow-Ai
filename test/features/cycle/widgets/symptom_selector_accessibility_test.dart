import 'package:flow_ai/core/theme/app_theme.dart';
import 'package:flow_ai/features/cycle/widgets/symptom_selector.dart';
import 'package:flow_ai/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget accessibilityApp({
  required ValueChanged<Set<String>> onSymptomsChanged,
}) {
  const symptom = 'Severe and persistent lower abdominal cramping';

  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.lightTheme,
    home: MediaQuery(
      data: const MediaQueryData(
        size: Size(360, 667),
        textScaler: TextScaler.linear(2),
      ),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SymptomSelector(
              selectedSymptoms: const <String>{symptom},
              symptomSeverity: const <String, double>{symptom: 4},
              onSymptomsChanged: onSymptomsChanged,
              onSeverityChanged: (_, __) {},
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('selected symptom has an accessible removal control', (
    tester,
  ) async {
    const symptom = 'Severe and persistent lower abdominal cramping';
    Set<String>? updated;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    tester.view.physicalSize = const Size(360, 667);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(
      accessibilityApp(
        onSymptomsChanged: (value) {
          updated = value;
        },
      ),
    );

    await tester.pump(const Duration(seconds: 2));

    final selector = find.byType(SymptomSelector);
    expect(selector, findsOneWidget);

    final context = tester.element(selector);
    final tooltip =
        '${MaterialLocalizations.of(context).deleteButtonTooltip}: $symptom';
    final removeControl = find.byTooltip(tooltip);

    expect(removeControl, findsOneWidget);

    await tester.tap(removeControl);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5),
    );

    expect(updated, isNotNull);
    expect(updated, isEmpty);
  });
}
