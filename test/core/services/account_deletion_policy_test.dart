import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('server identity authority is confirmed before local erasure', () {
    final auth = File('lib/core/services/auth_service.dart').readAsStringSync();
    final gateway = File(
      'lib/core/services/cloud_data_deletion_gateway.dart',
    ).readAsStringSync();
    final backend = File(
      'functions/src/partner_delete_callable.ts',
    ).readAsStringSync();

    expect(backend, contains("from \"firebase-admin/auth\";"));
    expect(backend, contains('await getAuth().deleteUser(uid);'));
    expect(backend, contains('identityDeleted: true'));
    expect(gateway, contains("response['identityDeleted'] != true"));

    final deleteStart = auth.indexOf('Future<AuthResult> deleteAccount()');
    expect(deleteStart, greaterThanOrEqualTo(0));

    final remote = auth.indexOf(
      'CloudDataDeletionGateway().deleteCurrentUserCloudData()',
      deleteStart,
    );
    final local = auth.indexOf('await _clearAllUserData();', remote);

    expect(remote, greaterThanOrEqualTo(0));
    expect(local, greaterThan(remote));

    final deleteMethod = auth.substring(deleteStart);

    expect(deleteMethod, isNot(contains('await account.delete();')));
    expect(deleteMethod, isNot(contains("requires-recent-login")));
  });

  test('external deletion page explains request and subscription handling', () {
    final page = File('docs/delete-account.html').readAsStringSync();

    expect(page, contains('privacy@flowai.app'));
    expect(page, contains('Delete Account'));
    expect(page, contains('does not automatically cancel'));
  });
  test('backend deletion removes persisted premium entitlements', () {
    final backend = File(
      'functions/src/partner_delete_callable.ts',
    ).readAsStringSync();

    expect(
      backend,
      contains('const ENTITLEMENTS_COLLECTION = "premiumEntitlements";'),
    );
    expect(
      backend,
      contains('const SUBSCRIPTIONS_COLLECTION = "subscriptions";'),
    );
    expect(
      backend,
      contains('await db.recursiveDelete(entitlementReference);'),
    );
    expect(
      backend,
      contains('documents.length + entitlementSubscriptions.size'),
    );
  });
  test('web hosting sources include real privacy and deletion pages', () {
    final privacy = File('web/privacy.html').readAsStringSync();
    final deletion = File('web/delete-account.html').readAsStringSync();

    expect(privacy, contains('Privacy Policy'));
    expect(privacy, contains('delete-account.html'));
    expect(deletion, contains('Delete your Flow AI account'));
    expect(deletion, contains('privacy@flowai.app'));
  });
}
