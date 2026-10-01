import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PartnerService acceptance uses secured invitation lifecycle owner', () {
    final source = File(
      'lib/features/partner/services/partner_service.dart',
    ).readAsStringSync();

    expect(
      source,
      contains(
        'final partnershipData = await _inviteActions.acceptInvitation(',
      ),
    );

    expect(
      source,
      isNot(
        contains(
          'final partnershipData = await _localService.acceptPartnerInvitation(',
        ),
      ),
    );
  });
}
