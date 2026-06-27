import 'dart:io';

import 'package:flow_ai/core/services/cloud_data_deletion_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses the existing cloud identity and secured callable', () async {
    String? callableName;
    Map<String, dynamic>? callableData;

    final gateway = CloudDataDeletionGateway(
      currentUserId: () => 'firebase-user-123',
      invoke: (name, data) async {
        callableName = name;
        callableData = data;
        return {'ok': true, 'deletedDocuments': 7};
      },
    );

    final deleted = await gateway.deleteCurrentUserCloudData();

    expect(deleted, 7);
    expect(callableName, 'deleteMyCloudData');
    expect(callableData, isEmpty);
  });

  test('does not create a cloud identity when none exists', () async {
    var invoked = false;

    final gateway = CloudDataDeletionGateway(
      currentUserId: () => null,
      invoke: (name, data) async {
        invoked = true;
        return {'ok': true};
      },
    );

    await expectLater(
      gateway.deleteCurrentUserCloudData(),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'Cloud data deletion is temporarily unavailable.',
        ),
      ),
    );

    expect(invoked, isFalse);
  });

  test('rejects an unconfirmed backend response', () async {
    final gateway = CloudDataDeletionGateway(
      currentUserId: () => 'firebase-user-123',
      invoke: (name, data) async => {'ok': false},
    );

    await expectLater(
      gateway.deleteCurrentUserCloudData(),
      throwsA(isA<StateError>()),
    );
  });

  test('source never creates a replacement anonymous identity', () {
    final source = File(
      'lib/core/services/cloud_data_deletion_gateway.dart',
    ).readAsStringSync();

    expect(source, contains('FirebaseAuth.instance.currentUser'));
    expect(source, isNot(contains('ensureCloudIdentity')));
    expect(source, isNot(contains('signInAnonymously')));
  });
}
