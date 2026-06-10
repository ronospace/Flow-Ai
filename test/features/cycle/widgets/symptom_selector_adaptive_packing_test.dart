import 'package:flow_ai/core/theme/app_theme.dart';
import 'package:flow_ai/features/cycle/widgets/symptom_selector.dart';
import 'package:flow_ai/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const symptoms = <String>[
  'Diarrhea',
  'Cramps',
  'Severe and persistent lower abdominal cramping',
];

Widget harness(TextDirection direction) {
  return MaterialApp(
    locale: direction == TextDirection.rtl
        ? const Locale('ar')
        : const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.lightTheme,
    home: Directionality(
      textDirection: direction,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 760,
            child: SymptomSelector(
              selectedSymptoms: symptoms.toSet(),
              symptomSeverity: const <String, double>{
                'Diarrhea': 2,
                'Cramps': 4,
                'Severe and persistent lower abdominal cramping': 3,
              },
              onSymptomsChanged: (_) {},
              onSeverityChanged: (_, __) {},
            ),
          ),
        ),
      ),
    ),
  );
}

Finder chip(String symptom) =>
    find.byKey(ValueKey<String>('selected-symptom-$symptom'));

Future<void> mount(
  WidgetTester tester,
  double width,
  TextDirection direction,
) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  await tester.pumpWidget(harness(direction));
  await tester.pump(const Duration(seconds: 2));
}

Future<void> disposeTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  await tester.pump(const Duration(seconds: 3));

  expect(
    tester.takeException(),
    isNull,
    reason:
        'Unmounting the animated symptom selector must not hide exceptions.',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('selected symptoms pack adaptively across LTR and RTL', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await mount(tester, 440, TextDirection.ltr);

    var first = tester.getRect(chip('Diarrhea'));
    var second = tester.getRect(chip('Cramps'));
    var long = tester.getRect(
      chip('Severe and persistent lower abdominal cramping'),
    );

    expect((first.top - second.top).abs(), lessThanOrEqualTo(1));
    expect(first.right, lessThanOrEqualTo(second.left + 1));
    expect(long.top, greaterThan(first.bottom));
    expect(long.width, greaterThan(first.width * 1.8));
    expect(tester.takeException(), isNull);

    await disposeTree(tester);

    await mount(tester, 360, TextDirection.ltr);

    first = tester.getRect(chip('Diarrhea'));
    second = tester.getRect(chip('Cramps'));

    expect(second.top, greaterThan(first.bottom));
    expect(tester.takeException(), isNull);

    await disposeTree(tester);

    await mount(tester, 440, TextDirection.rtl);

    first = tester.getRect(chip('Diarrhea'));
    second = tester.getRect(chip('Cramps'));

    expect((first.top - second.top).abs(), lessThanOrEqualTo(1));
    expect(first.center.dx, greaterThan(second.center.dx));
    expect(tester.takeException(), isNull);

    await disposeTree(tester);
  });
}
