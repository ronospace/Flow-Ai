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
    expect(first.width, lessThan(190));

    expect(second.width, lessThan(190));

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
  testWidgets('measured 390 selected chips pair with exact rendered widths', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await mount(tester, 390, TextDirection.ltr);

    final first = tester.getRect(chip('Diarrhea'));
    final second = tester.getRect(chip('Cramps'));
    final long = tester.getRect(
      chip('Severe and persistent lower abdominal cramping'),
    );

    expect(first.width, closeTo(159.0, 0.1));
    expect(second.width, closeTo(159.0, 0.1));
    expect(long.width, closeTo(326.0, 0.1));
    expect((first.top - second.top).abs(), lessThanOrEqualTo(1));
    expect(second.left - first.right, closeTo(8.0, 0.1));
    expect(long.top, greaterThan(first.bottom));
    expect(tester.takeException(), isNull);

    await disposeTree(tester);
  });

  testWidgets('measured 360 selected chips stay full-width fallback', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await mount(tester, 360, TextDirection.ltr);

    final first = tester.getRect(chip('Diarrhea'));
    final second = tester.getRect(chip('Cramps'));

    expect(first.width, closeTo(296.0, 0.1));
    expect(second.width, closeTo(296.0, 0.1));
    expect(second.top, greaterThan(first.bottom));
    expect(tester.takeException(), isNull);

    await disposeTree(tester);
  });
  testWidgets(
    'proven readable selected chips keep label above severity and remove',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await mount(tester, 390, TextDirection.ltr);

      final firstChip = tester.getRect(chip('Diarrhea'));
      final secondChip = tester.getRect(chip('Cramps'));
      final longChip = tester.getRect(
        chip('Severe and persistent lower abdominal cramping'),
      );

      final firstLabel = tester.getRect(
        find.byKey(const ValueKey<String>('selected-symptom-label-Diarrhea')),
      );
      final secondLabel = tester.getRect(
        find.byKey(const ValueKey<String>('selected-symptom-label-Cramps')),
      );
      final longLabel = tester.getRect(
        find.byKey(
          const ValueKey<String>(
            'selected-symptom-label-Severe and persistent lower abdominal cramping',
          ),
        ),
      );
      final firstSeverity = tester.getRect(
        find.byKey(
          const ValueKey<String>('selected-symptom-severity-Diarrhea'),
        ),
      );
      final secondSeverity = tester.getRect(
        find.byKey(const ValueKey<String>('selected-symptom-severity-Cramps')),
      );
      final firstRemove = tester.getRect(
        find.byKey(const ValueKey<String>('selected-symptom-remove-Diarrhea')),
      );
      final secondRemove = tester.getRect(
        find.byKey(const ValueKey<String>('selected-symptom-remove-Cramps')),
      );

      expect(firstChip.width, closeTo(159.0, 0.1));
      expect(secondChip.width, closeTo(159.0, 0.1));
      expect(longChip.width, closeTo(326.0, 0.1));
      expect((firstChip.top - secondChip.top).abs(), lessThanOrEqualTo(1));
      expect(secondChip.left - firstChip.right, closeTo(8.0, 0.1));

      expect(firstLabel.height, lessThanOrEqualTo(26.1));
      expect(secondLabel.height, lessThanOrEqualTo(26.1));
      expect(longLabel.height, lessThanOrEqualTo(34.1));

      expect(firstSeverity.top, greaterThanOrEqualTo(firstLabel.bottom - 1));
      expect(secondSeverity.top, greaterThanOrEqualTo(secondLabel.bottom - 1));
      expect(firstRemove.width, closeTo(48.0, 0.1));
      expect(firstRemove.height, closeTo(48.0, 0.1));
      expect(secondRemove.width, closeTo(48.0, 0.1));
      expect(secondRemove.height, closeTo(48.0, 0.1));
      expect(
        (firstRemove.center.dy - firstChip.center.dy).abs(),
        lessThanOrEqualTo(1),
      );
      expect(
        (secondRemove.center.dy - secondChip.center.dy).abs(),
        lessThanOrEqualTo(1),
      );
      expect(firstLabel.center.dx, lessThan(firstChip.center.dx));
      expect(secondLabel.center.dx, lessThan(secondChip.center.dx));
      expect(longChip.top, greaterThan(firstChip.bottom));
      expect(tester.takeException(), isNull);

      await disposeTree(tester);
    },
  );
  testWidgets('selected chips use old compact measured 9px 5px chrome', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await mount(tester, 390, TextDirection.ltr);

    final chipFinder = chip('Cramps');
    final chipRect = tester.getRect(chipFinder);
    final emojiRect = tester.getRect(
      find.descendant(
        of: chipFinder,
        matching: find.byKey(
          const ValueKey<String>('selected-symptom-emoji-Cramps'),
        ),
      ),
    );
    final labelRect = tester.getRect(
      find.descendant(
        of: chipFinder,
        matching: find.byKey(
          const ValueKey<String>('selected-symptom-label-Cramps'),
        ),
      ),
    );
    final severityRect = tester.getRect(
      find.descendant(
        of: chipFinder,
        matching: find.byKey(
          const ValueKey<String>('selected-symptom-severity-Cramps'),
        ),
      ),
    );
    final removeRect = tester.getRect(
      find.descendant(
        of: chipFinder,
        matching: find.byKey(
          const ValueKey<String>('selected-symptom-remove-Cramps'),
        ),
      ),
    );

    expect(chipRect.width, closeTo(159.0, 0.1));
    expect(chipRect.height, lessThanOrEqualTo(62.0));
    expect(emojiRect.left - chipRect.left, closeTo(9.0, 0.1));
    expect(emojiRect.width, closeTo(18.0, 0.1));
    expect(labelRect.left, greaterThan(emojiRect.right));
    expect((severityRect.left - labelRect.left).abs(), lessThanOrEqualTo(1));
    expect(labelRect.center.dx, lessThan(chipRect.center.dx));
    expect(removeRect.width, closeTo(48.0, 0.1));
    expect(removeRect.height, closeTo(48.0, 0.1));
    expect(chipRect.right - removeRect.right, closeTo(5.0, 0.1));
    expect(tester.takeException(), isNull);

    await disposeTree(tester);
  });
}
