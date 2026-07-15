import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String backend;
  late String client;

  setUpAll(() {
    backend = File(
      'functions/src/receipt_validation_http.ts',
    ).readAsStringSync();

    client = File(
      'lib/features/premium/services/receipt_validation_service.dart',
    ).readAsStringSync();
  });

  test('backend verifies Firebase identity before entitlement access', () {
    expect(backend, contains('from "firebase-admin/auth"'));
    expect(backend, contains('verifyIdToken(token, true)'));
    expect(
      backend,
      contains('const userId = await verifyAuthenticatedUser(request)'),
    );
    expect(
      backend,
      contains('persistValidatedEntitlement(userId, validationResult)'),
    );

    expect(backend, isNot(contains('readNonEmptyString(body.userId)')));
  });

  test('Apple and Google payload contracts match the mobile client', () {
    expect(backend, contains('readNonEmptyString(body.transactionId)'));
    expect(backend, contains('readNonEmptyString(body.environment)'));
    expect(backend, contains('readNonEmptyString(body.purchaseToken)'));
    expect(backend, contains('readNonEmptyString(body.packageName)'));

    expect(backend, isNot(contains('readNonEmptyString(body.receipt)')));
    expect(backend, isNot(contains('readNonEmptyString(body.platform)')));

    expect(client, contains("'transactionId': transactionId"));
    expect(client, contains("'purchaseToken': purchaseToken"));
    expect(client, contains("'packageName': packageName"));
    expect(client, isNot(contains("'userId':")));
    expect(client, isNot(contains("'platform':")));
    expect(client, isNot(contains("'receipt':")));
  });

  test('subscription status ownership is derived from verified identity', () {
    expect(
      backend,
      contains('const userId = await verifyAuthenticatedUser(request)'),
    );
    expect(
      backend,
      contains('const subscriptionsIndex = pathSegments.lastIndexOf'),
    );
    expect(backend, contains('.doc(userId)'));
    expect(backend, contains('.doc(subscriptionId)'));
    expect(backend, isNot(contains('const userId = pathSegments[0]')));
  });

  test('unauthenticated purchase and status requests fail closed', () {
    expect(backend, contains('error: "unauthenticated"'));

    expect(
      RegExp(r'sendJson\(response,\s*401,').allMatches(backend).length,
      greaterThanOrEqualTo(2),
    );
  });

  test('mobile client sends Firebase bearer tokens and retries once', () {
    expect(client, contains("'Authorization': 'Bearer \$token'"));
    expect(client, contains('user.getIdToken(forceRefresh)'));
    expect(client, contains('if (response.statusCode != 401)'));
    expect(client, contains('_authenticationHeaders(forceRefresh: true)'));
  });
}
