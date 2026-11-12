import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flow_ai/core/models/cycle_data.dart';
import 'package:flow_ai/features/cycle/widgets/flow_intensity_picker.dart';
import 'package:flow_ai/generated/app_localizations.dart';

Widget harness() {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const Scaffold(body: SizedBox(width: 380, child: _HarnessBody())),
  );
}

class _HarnessBody extends StatelessWidget {
  const _HarnessBody();

  @override
  Widget build(BuildContext context) {
    return FlowIntensityPicker(
      selectedIntensity: FlowIntensity.none,
      onIntensitySelected: (_) {},
    );
  }
}

void main() {
  testWidgets('Flow subtitles render within two lines without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    final textWidgets = tester
        .widgetList<Text>(find.byType(Text))
        .where((widget) => widget.maxLines == 2)
        .toList();

    expect(
      textWidgets.length,
      greaterThanOrEqualTo(6),
      reason: 'Flow titles/subtitles must preserve bounded two-line text',
    );

    expect(tester.takeException(), isNull);
  });
}
