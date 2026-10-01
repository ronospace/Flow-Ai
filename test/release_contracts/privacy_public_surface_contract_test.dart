import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final privacy = File('web/privacy.html').readAsStringSync();
  final settings = File(
    'lib/features/settings/screens/settings_screen.dart',
  ).readAsStringSync();
  final healthDisclosure = File(
    'lib/features/health/widgets/healthkit_disclosure_banner.dart',
  ).readAsStringSync();

  const livePrivacy = 'https://flowai-demo-project.web.app/privacy.html';

  test('public privacy surface uses current Flow Ai branding', () {
    expect(privacy, contains('Flow Ai'));
    expect(privacy, isNot(contains('Flow AI')));
    expect(privacy, contains('ZyraFlow GmbH™'));
    expect(privacy, contains('© 2026 ZyraFlow GmbH™ All rights reserved.'));
  });

  test('privacy public surface has current presentation contract', () {
    expect(privacy, contains('September 25, 2026'));
    expect(privacy, contains('--rose: #f45b8d'));
    expect(privacy, contains('class="flow-footer"'));
    expect(privacy, contains('@media (max-width: 640px)'));
    expect(privacy, contains('@media (prefers-color-scheme: dark)'));
  });

  test('runtime privacy launchers use verified live endpoint', () {
    expect(settings, contains(livePrivacy));
    expect(healthDisclosure, contains(livePrivacy));
    expect(settings, isNot(contains('https://flowai.app/privacy')));
    expect(healthDisclosure, isNot(contains('https://flowai.app/privacy')));
  });
}
