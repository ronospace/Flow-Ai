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

  final coordinator = File(
    'lib/features/auth/services/auth_provider_coordinator.dart',
  ).readAsStringSync();

  test('AuthChoice owns transient provider selection', () {
    expect(choice, contains('AuthProviderType? _activeProvider;'));
    expect(choice, contains('_activeProvider = providerType;'));
    expect(choice, contains('_activeProvider = null;'));
  });

  test('provider processing is top-level and mutually exclusive', () {
    final build = choice.indexOf('Widget build(BuildContext context)');
    final providerBranch = choice.indexOf(
      'if (_activeProvider != null)',
      build,
    );
    final processing = choice.indexOf(
      '_buildProviderProcessing()',
      providerBranch,
    );
    final story = choice.indexOf('_buildMessage()', processing);
    final actions = choice.indexOf('_buildEntryActions()', story);

    expect(build, greaterThanOrEqualTo(0));
    expect(providerBranch, greaterThan(build));
    expect(processing, greaterThan(providerBranch));
    expect(story, greaterThan(processing));
    expect(actions, greaterThan(story));

    final buildEnd = choice.indexOf('Widget _buildProviderProcessing()', build);

    final buildSource = choice.substring(build, buildEnd);

    expect(buildSource, isNot(contains('child: AnimatedSwitcher(')));
  });

  test('processing surface commits before provider orchestration', () {
    final state = choice.indexOf('_activeProvider = providerType;');
    final frame = choice.indexOf('await WidgetsBinding.instance.endOfFrame;');
    final nativeProvider = choice.indexOf(
      'await AuthProviderCoordinator().authenticate',
    );

    expect(state, greaterThanOrEqualTo(0));
    expect(frame, greaterThan(state));
    expect(nativeProvider, greaterThan(frame));
  });

  test('processing surface contains no duplicate provider action', () {
    final start = choice.indexOf('Widget _buildProviderProcessing()');
    final end = choice.indexOf('Widget _buildLaunchLogo()', start);

    expect(start, greaterThanOrEqualTo(0));
    expect(end, greaterThan(start));

    final processing = choice.substring(start, end);

    expect(processing, isNot(contains('SocialLoginButton')));
    expect(processing, isNot(contains('Continue with Apple')));
    expect(processing, isNot(contains('Continue with Google')));
    expect(processing, isNot(contains('Continue with E-mail')));
    expect(processing, isNot(contains('TextFormField')));
  });

  test('cancel and failure restore originating chooser mode', () {
    final start = choice.indexOf(
      'Future<void> _openProvider(String provider) async',
    );
    final end = choice.indexOf('void _openEmail()', start);
    final source = choice.substring(start, end);

    expect(source, contains('_activeProvider = null;'));
    expect(source, contains('if (result.isCancelled)'));
    expect(source, contains('result.error'));

    // Provider execution must not alter whether the user originated from
    // primary or expanded chooser mode.
    expect(source, isNot(contains('_showAllMethods =')));
  });

  test('success authority remains centralized in coordinator', () {
    expect(coordinator, contains('_authService.signInWithApple()'));
    expect(coordinator, contains('_authService.signInWithGoogle()'));
    expect(coordinator, contains('forceUserDataSync()'));
    expect(coordinator, contains('AppStateService().getPostAuthRoute('));
    expect(
      coordinator,
      contains('PendingDeepLinkService.consumePendingRoute()'),
    );
  });

  test('obsolete provider-routing architecture remains absent', () {
    expect(choice, isNot(contains('/auth/login?provider=')));
    expect(auth, isNot(contains('initialProvider')));
    expect(auth, isNot(contains('_handleInitialProvider')));
    expect(router, isNot(contains("queryParameters['provider']")));
  });
}
