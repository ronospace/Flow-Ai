import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flow_ai/core/identity/active_account_scope.dart';

void main() {
  test('identity is resolved live across account switches', () async {
    var currentId = 'user_a';
    var calls = 0;

    ActiveAccountScope.instance.configure(() async {
      calls += 1;
      return currentId;
    });

    expect(await ActiveAccountScope.instance.requireUserId(), 'user_a');

    currentId = 'user_b';

    expect(await ActiveAccountScope.instance.requireUserId(), 'user_b');

    expect(calls, 2);
  });

  test('sentinel and absent identities fail closed', () async {
    for (final invalid in <String?>[
      null,
      '',
      '   ',
      'current_user',
      'unknown',
      'anonymous_user',
    ]) {
      ActiveAccountScope.instance.configure(() async => invalid);

      expect(ActiveAccountScope.instance.requireUserId(), throwsStateError);
    }
  });

  test('ownership changes immediately with active account', () async {
    var currentId = 'owner_a';

    ActiveAccountScope.instance.configure(() async => currentId);

    await ActiveAccountScope.instance.requireOwnership('owner_a');

    currentId = 'owner_b';

    expect(
      ActiveAccountScope.instance.requireOwnership('owner_a'),
      throwsStateError,
    );

    await ActiveAccountScope.instance.requireOwnership('owner_b');
  });

  test('scope is Android and iOS neutral', () {
    final source = File(
      'lib/core/identity/active_account_scope.dart',
    ).readAsStringSync();

    for (final forbidden in <String>[
      'dart:io',
      'Platform.',
      'Android',
      'Cupertino',
      'MethodChannel',
      'EventChannel',
      'firebase_auth',
      'auth_service',
      'database_service',
      'flutter/',
    ]) {
      expect(
        source.contains(forbidden),
        isFalse,
        reason: 'Neutral account scope contains $forbidden',
      );
    }
  });

  test('composition root binds live auth before runApp', () {
    final source = File('lib/main.dart').readAsStringSync();

    final bind = source.indexOf('_configureActiveAccountScope();');
    final run = source.indexOf('runApp(');

    expect(bind, greaterThanOrEqualTo(0));
    expect(run, greaterThan(bind));

    expect(source.contains('await authService.getCurrentUser()'), isTrue);

    expect(
      source.contains('activeUser is User && activeUser.isAnonymous'),
      isTrue,
    );
  });
}
