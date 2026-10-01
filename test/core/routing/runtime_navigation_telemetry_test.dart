import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:flow_ai/core/routing/runtime_navigation_telemetry.dart';

void main() {
  testWidgets('tracks ShellRoute context.go through router delegate', (
    tester,
  ) async {
    late final GoRouter router;

    router = GoRouter(
      initialLocation: '/home',
      routes: [
        ShellRoute(
          builder: (context, state, child) => Scaffold(
            body: child,
            bottomNavigationBar: Row(
              children: [
                TextButton(
                  key: const ValueKey('home'),
                  onPressed: () => context.go('/home'),
                  child: const Text('Home'),
                ),
                TextButton(
                  key: const ValueKey('tracking'),
                  onPressed: () => context.go('/tracking'),
                  child: const Text('Tracking'),
                ),
              ],
            ),
          ),
          routes: [
            GoRoute(path: '/home', builder: (_, __) => const Text('HOME')),
            GoRoute(
              path: '/tracking',
              builder: (_, __) => const Text('TRACKING'),
            ),
          ],
        ),
      ],
    );

    RuntimeNavigationTelemetry.instance.attach(router);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(router.routerDelegate.currentConfiguration.uri.path, '/home');

    await tester.tap(find.byKey(const ValueKey('tracking')));
    await tester.pumpAndSettle();
    expect(router.routerDelegate.currentConfiguration.uri.path, '/tracking');

    await tester.tap(find.byKey(const ValueKey('home')));
    await tester.pumpAndSettle();
    expect(router.routerDelegate.currentConfiguration.uri.path, '/home');

    RuntimeNavigationTelemetry.instance.detach();
    router.dispose();
  });
}
