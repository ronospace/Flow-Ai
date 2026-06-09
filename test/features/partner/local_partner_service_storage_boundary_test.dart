import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('LocalPartnerService remains local-only', () {
    final source = File(
      'lib/features/partner/services/local_partner_service.dart',
    ).readAsStringSync();

    expect(
      source,
      isNot(contains('package:cloud_firestore/cloud_firestore.dart')),
    );
    expect(source, isNot(contains('FirebaseFirestore')));
    expect(source, isNot(contains(".collection('partnerInvites')")));

    expect(source, contains('await _saveInvitation(invitation);'));
    expect(source, contains('await _findInvitationByCode(invitationCode);'));
    expect(source, contains('await _removeInvitation(invitation.id);'));
    expect(source, contains('SharedPreferences'));
  });
}
