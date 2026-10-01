import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String router;

  setUpAll(() {
    router = File('lib/core/routing/app_router.dart').readAsStringSync();
  });

  test('banner loads use generation ownership', () {
    expect(router, contains('int _bannerLoadGeneration = 0;'));
    expect(router, contains('final generation = ++_bannerLoadGeneration;'));
    expect(router, contains('generation != _bannerLoadGeneration'));
  });

  test('route disallow and shell disposal invalidate stale loads', () {
    expect(
      '_bannerLoadGeneration++;'.allMatches(router).length,
      greaterThanOrEqualTo(2),
    );
  });

  test('loaded banner revalidates current entitlement and route', () {
    expect(
      router,
      contains(
        'final currentSubscription = context.read<SubscriptionProvider>();',
      ),
    );
    expect(
      router,
      contains('final currentRoute = GoRouterState.of(context).uri.path;'),
    );
    expect(router, contains('currentSubscription.isInitialized'));
    expect(router, contains('!currentSubscription.isPremium'));
    expect(router, contains('AdMobService.canShowBannerOnRoute(currentRoute)'));
  });

  test('stale failure callback cannot clear a newer banner load', () {
    expect(
      router,
      contains('if (!mounted || generation != _bannerLoadGeneration) return;'),
    );
  });
}
