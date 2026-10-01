import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Settings delegates About to one central owner', () {
    final source = File(
      'lib/features/settings/screens/settings_screen.dart',
    ).readAsStringSync();

    expect(source, contains('AdaptiveMessages.showFlowAiAbout(context)'));
    expect(source, isNot(contains('showAboutDialog(')));
    expect(source, isNot(contains('app_runtime_metadata_service.dart')));
  });

  test('About dialog has one centered visual hierarchy', () {
    final source = File(
      'lib/core/ui/adaptive_messages.dart',
    ).readAsStringSync();

    expect(source, contains('maxWidth: 380'));
    expect(
      'textAlign: TextAlign.center'.allMatches(source).length,
      greaterThanOrEqualTo(4),
    );
    expect(source, contains('const SizedBox(height: 26)'));
  });

  test('About actions preserve equal professional geometry', () {
    final source = File(
      'lib/core/ui/adaptive_messages.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('flex: 6')));
    expect(source, isNot(contains('flex: 5')));

    expect('height: 48'.allMatches(source).length, greaterThanOrEqualTo(2));

    expect('FittedBox('.allMatches(source).length, greaterThanOrEqualTo(2));

    expect(
      'BoxFit.scaleDown'.allMatches(source).length,
      greaterThanOrEqualTo(2),
    );

    expect('maxLines: 1'.allMatches(source).length, greaterThanOrEqualTo(2));

    expect(
      'softWrap: false'.allMatches(source).length,
      greaterThanOrEqualTo(2),
    );
  });

  test('About uses runtime version and preserves LicensePage', () {
    final source = File(
      'lib/core/ui/adaptive_messages.dart',
    ).readAsStringSync();

    expect(source, contains('AppRuntimeMetadataService.instance.packageInfo'));
    expect(source, contains('applicationVersion: metadata.version'));
    expect(source, contains('showLicensePage('));
  });
}
