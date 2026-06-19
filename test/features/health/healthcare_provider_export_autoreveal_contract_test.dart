import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const targetPath =
      'lib/features/healthcare/screens/'
      'healthcare_provider_portal_screen.dart';

  final source = File(targetPath).readAsStringSync();

  test('permanent success card owns a stable reveal anchor', () {
    expect(
      source,
      contains('final GlobalKey _exportSuccessKey = GlobalKey();'),
    );
    expect(source, contains('key: _exportSuccessKey'));
    expect(source, contains('_buildExportSuccessCard(context, theme)'));
  });

  test('success reveals the full card after state layout', () {
    expect(source, contains('WidgetsBinding.instance.addPostFrameCallback'));
    expect(source, contains('Scrollable.ensureVisible('));
    expect(source, contains('alignment: 1.0'));
    expect(source, contains('ScrollPositionAlignmentPolicy.keepVisibleAtEnd'));

    final successStart = source.indexOf('if (result.success)');
    final shareStart = source.indexOf(
      'Future<void> _shareExport()',
      successStart,
    );
    final successBranch = source.substring(successStart, shareStart);

    expect(successBranch, contains('setState('));
    expect(successBranch, contains('_revealExportSuccessCard();'));
    expect(
      successBranch.indexOf('_revealExportSuccessCard();'),
      greaterThan(successBranch.indexOf('setState(')),
    );
  });

  test('landing uses responsive widget geometry', () {
    final revealStart = source.indexOf('void _revealExportSuccessCard()');
    final exportStart = source.indexOf(
      'Future<void> _exportData()',
      revealStart,
    );
    final revealMethod = source.substring(revealStart, exportStart);

    expect(revealMethod, isNot(contains('jumpTo(')));
    expect(revealMethod, isNot(contains('animateTo(')));
    expect(revealMethod, isNot(contains('maxScrollExtent')));
    expect(revealMethod, isNot(contains('MediaQuery.of(context).size.height')));
  });

  test('Share, permanent success and genuine errors remain', () {
    expect(source, contains('Export Successful!'));
    expect(source, contains('_shareExport'));
    expect(source, contains('Export failed:'));
    expect(source, contains('Failed to share:'));
    expect(source, isNot(contains('Health data exported successfully!')));
  });
}
