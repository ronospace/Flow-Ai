import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('partner sync status label is flex constrained', () {
    final dashboard = File(
      'lib/features/partner/screens/partner_dashboard_screen.dart',
    ).readAsStringSync();

    final status = dashboard.indexOf("'Partner Sync Active'");
    expect(status, greaterThanOrEqualTo(0));

    final start = dashboard.lastIndexOf('child: Row(', status);
    expect(start, greaterThanOrEqualTo(0));

    final end = dashboard.indexOf('const SizedBox(height: 20)', status);
    expect(end, greaterThan(status));

    final block = dashboard.substring(start, end);

    expect(block, contains('mainAxisSize: MainAxisSize.max'));
    expect(block, contains('mainAxisAlignment: MainAxisAlignment.center'));
    expect(block, contains('Flexible('));
    expect(block, contains('maxLines: 1'));
    expect(block, contains('FittedBox('));
    expect(block, contains('fit: BoxFit.scaleDown'));
    expect(block, contains('softWrap: false'));
    expect(block, isNot(contains('TextOverflow.ellipsis')));
  });

  test(
    'authoritative cloud state is published before best-effort local cache',
    () {
      final service = File(
        'lib/features/partner/services/partner_service.dart',
      ).readAsStringSync();

      final loadStart = service.indexOf(
        'Future<void> _loadPartnership() async',
      );
      expect(loadStart, greaterThanOrEqualTo(0));

      final loadEnd = service.indexOf(
        '/// Load messages for current partnership',
        loadStart,
      );
      expect(loadEnd, greaterThan(loadStart));

      final loadBlock = service.substring(loadStart, loadEnd);

      final assignment = loadBlock.indexOf(
        '_currentPartnership = resolvedPartnership',
      );
      final cache = loadBlock.indexOf(
        'await _localService.cacheCloudPartnership',
      );

      expect(assignment, greaterThanOrEqualTo(0));
      expect(cache, greaterThan(assignment));

      expect(loadBlock, contains('try {'));
      expect(
        loadBlock,
        contains(
          'Local persistence is offline continuity only, never cloud truth.',
        ),
      );
    },
  );

  test('partner state resolves through authenticated cloud owner', () {
    final gateway = File(
      'lib/features/partner/services/partner_cloud_gateway.dart',
    ).readAsStringSync();

    final actions = File(
      'lib/features/partner/services/partner_invite_actions.dart',
    ).readAsStringSync();

    final service = File(
      'lib/features/partner/services/partner_service.dart',
    ).readAsStringSync();

    expect(gateway, contains("'getPartnerConnection'"));

    expect(gateway, contains('fetchCurrentPartnership()'));

    expect(actions, contains('_cloudGateway.fetchCurrentPartnership()'));

    expect(service, contains('await _inviteActions.fetchCurrentPartnership()'));

    expect(service, contains('cacheCloudPartnership'));
  });

  test(
    'direct Firestore partnership reads are not introduced into Flutter',
    () {
      final files = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));

      for (final file in files) {
        final source = file.readAsStringSync();

        expect(
          source.contains("collection('partnerConnections')"),
          false,
          reason: file.path,
        );

        expect(
          source.contains('collection("partnerConnections")'),
          false,
          reason: file.path,
        );
      }
    },
  );
}
