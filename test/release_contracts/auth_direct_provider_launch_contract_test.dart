import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final choice = File(
    'lib/features/auth/screens/auth_choice_screen.dart',
  ).readAsStringSync();

  final auth = File(
    'lib/features/auth/screens/auth_screen.dart',
  ).readAsStringSync();

  final router = File('lib/core/routing/app_router.dart').readAsStringSync();

  final service = File(
    'lib/core/services/auth_service.dart',
  ).readAsStringSync();

  final coordinator = File(
    'lib/features/auth/services/'
    'auth_provider_coordinator.dart',
  ).readAsStringSync();

  test('Apple and Google do not enter AuthScreen first', () {
    expect(
      choice,
      isNot(contains("context.push('/auth/login?provider=\$provider')")),
    );

    expect(choice, contains('AuthProviderCoordinator().authenticate'));
  });

  test('email remains explicit', () {
    expect(choice, contains("'Continue with E-mail'"));
    expect(choice, contains("context.go('/auth')"));
  });

  test('provider query state is removed', () {
    expect(router, isNot(contains("state.uri.queryParameters['provider']")));

    expect(router, contains("path: '/auth/login'"));
  });

  test('AuthScreen no longer auto launches initial provider', () {
    expect(auth, isNot(contains('initialProvider')));
    expect(auth, isNot(contains('_handleInitialProvider')));
  });

  test('provider cancellation is explicit', () {
    expect(service, contains('final bool isCancelled;'));
    expect(service, contains('factory AuthResult.cancelled'));
    expect(service, contains('AuthorizationErrorCode.canceled'));
  });

  test('canonical post auth route remains centralized', () {
    expect(coordinator, contains('AppStateService().getPostAuthRoute('));
    expect(
      coordinator,
      contains('PendingDeepLinkService.consumePendingRoute()'),
    );
    expect(coordinator, contains('forceUserDataSync()'));
  });
}
