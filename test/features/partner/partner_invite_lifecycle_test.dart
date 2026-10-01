import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('partner invitation send path publishes before send', () {
    final source = File(
      'lib/features/partner/services/partner_invite_actions.dart',
    ).readAsStringSync();

    final publish = source.indexOf('await _cloudGateway.publishInvitation(');
    final send = source.indexOf('await _cloudGateway.sendInvitation(');

    expect(publish, greaterThanOrEqualTo(0));
    expect(send, greaterThan(publish));

    expect(source, isNot(contains('FirebaseFunctions.instance.httpsCallable')));
  });

  test('partner acceptance delegates to secured cloud gateway', () {
    final source = File(
      'lib/features/partner/services/partner_invite_actions.dart',
    ).readAsStringSync();

    expect(source, contains('_cloudGateway.acceptInvitation(invitationCode)'));
  });
}
