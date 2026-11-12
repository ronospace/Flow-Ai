import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final tracking = File(
    'lib/features/cycle/screens/tracking_screen.dart',
  ).readAsStringSync();

  final picker = File(
    'lib/features/cycle/widgets/flow_intensity_picker.dart',
  ).readAsStringSync();

  test('Track derives bounded selected Flow viewport budget', () {
    expect(tracking, contains('selectedFlowViewportBudget'));
    expect(tracking, contains('viewportConstraints.hasBoundedHeight'));
    expect(tracking, contains('selectedViewportHeight:'));
  });

  test('Flow subtracts actual rendered AI height from selected budget', () {
    expect(picker, contains('_aiSectionKey'));
    expect(picker, contains('aiRenderObject.size.height'));
    expect(picker, contains('viewportBudget - aiSectionHeight'));
  });

  test('selected grid keeps width and derives equal row height', () {
    expect(picker, contains('availableRowHeight'));
    expect(picker, contains('fixedVerticalChrome'));
    expect(picker, contains('rowCount'));
    expect(picker, contains("ValueKey('flow-selected-grid-budget')"));

    // Whole-grid FittedBox was the rejected implementation.
    final gridStart = picker.indexOf('Widget _buildResponsiveOptionGrid');
    final gridEnd = picker.indexOf('// ignore: unused_element', gridStart);

    final gridBlock = picker.substring(gridStart, gridEnd);

    expect(gridBlock, isNot(contains('FittedBox(')));
    expect(gridBlock, isNot(contains('BoxFit.scaleDown')));
  });
}
