import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cloud and local erasure precede Firebase identity deletion', () {
    final source = File(
      'lib/core/services/auth_service.dart',
    ).readAsStringSync();

    final cloud = source.indexOf(
      'await CloudDataDeletionGateway().deleteCurrentUserCloudData();',
    );
    final local = source.indexOf('await _clearAllUserData();', cloud);
    final identity = source.indexOf('await account.delete();', cloud);

    expect(cloud, greaterThanOrEqualTo(0));
    expect(local, greaterThan(cloud));
    expect(identity, greaterThan(local));
    expect(source, contains('await DatabaseService().deleteDatabase();'));
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
