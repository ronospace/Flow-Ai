import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PartnerService delegates Firebase availability to AuthService', () {
    final source = File(
      'lib/features/partner/services/partner_service.dart',
    ).readAsStringSync();

    expect(
      source,
      contains(
        'bool get isFirebaseAvailable => AuthService().isFirebaseAvailable;',
      ),
    );

    expect(
      source,
      contains('final firebaseAvailable = AuthService().isFirebaseAvailable;'),
    );

    expect(source, isNot(contains('final bool _firebaseAvailable = false;')));

    expect(
      source,
      isNot(contains('Partner features available via local storage')),
    );

    expect(source, isNot(contains('Works offline without Firebase')));
  });
}
