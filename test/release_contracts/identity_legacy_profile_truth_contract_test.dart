import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legacy identity compatibility does not invent profile data', () {
    final userService = File(
      'lib/core/services/user_service.dart',
    ).readAsStringSync();
    final localService = File(
      'lib/core/services/local_user_service.dart',
    ).readAsStringSync();

    expect(userService, isNot(contains('createMockUser')));
    expect(userService, isNot(contains('mock_user_')));

    for (final fabricated in [
      'age: 25,',
      "lifestyle: 'active',",
      'weight: 65.0,',
      'height: 165.0,',
    ]) {
      expect(userService, isNot(contains(fabricated)));
    }

    expect(
      localService,
      isNot(contains('TODO: Implement proper conversion if needed')),
    );

    expect(
      localService,
      contains('Future<UserProfile?> getUser(String userId)'),
    );
    expect(localService, contains('id: localUser.uid'));
    expect(localService, contains('displayName: localUser.displayName'));
    expect(localService, contains('createdAt: localUser.createdAt'));
    expect(localService, contains('updatedAt: localUser.lastUpdated'));
  });
}
