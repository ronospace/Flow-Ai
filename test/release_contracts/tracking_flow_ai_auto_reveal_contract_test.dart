import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('non-none Flow selection reveals AI panel without scaling grid', () {
    final tracking = File(
      'lib/features/cycle/screens/tracking_screen.dart',
    ).readAsStringSync();

    final picker = File(
      'lib/features/cycle/widgets/flow_intensity_picker.dart',
    ).readAsStringSync();

    expect(
      tracking,
      contains('final GlobalKey _flowAiInsightsKey = GlobalKey();'),
    );
    expect(tracking, contains('aiInsightsKey: _flowAiInsightsKey'));
    expect(tracking, contains('intensity != FlowIntensity.none'));
    expect(tracking, contains('WidgetsBinding.instance.addPostFrameCallback'));
    expect(tracking, contains('Scrollable.ensureVisible('));
    expect(
      tracking,
      contains('ScrollPositionAlignmentPolicy.keepVisibleAtEnd'),
    );

    expect(picker, contains('final Key? aiInsightsKey;'));
    expect(
      picker,
      contains("widget.aiInsightsKey ?? const ValueKey('flow-ai-insights')"),
    );

    expect(
      picker,
      contains('if (widget.selectedIntensity != FlowIntensity.none)'),
    );

    expect(tracking, contains('selectedFlowViewportBudget'));
    expect(picker, contains('selectedViewportHeight'));
    expect(picker, contains('FittedBox('));
    expect(picker, contains('BoxFit.scaleDown'));
  });
}
