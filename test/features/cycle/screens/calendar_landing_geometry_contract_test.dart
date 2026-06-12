import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Calendar landing geometry contract', () {
    late String calendarScreen;
    late String appRouter;
    late String appLayout;

    setUpAll(() {
      calendarScreen = File(
        'lib/features/cycle/screens/calendar_screen.dart',
      ).readAsStringSync();
      appRouter = File('lib/core/routing/app_router.dart').readAsStringSync();
      appLayout = File('lib/core/constants/app_layout.dart').readAsStringSync();
    });

    test('uses native scroll physics for top and bottom landing feel', () {
      expect(calendarScreen, contains('CustomScrollView'));
      expect(calendarScreen, contains('SliverPadding'));
      expect(calendarScreen, contains('SliverFillRemaining'));
      expect(calendarScreen, contains('fillOverscroll: true'));
      expect(calendarScreen, contains('hasScrollBody: false'));
      expect(calendarScreen, contains('BouncingScrollPhysics'));
      expect(calendarScreen, contains('AlwaysScrollableScrollPhysics'));
      expect(
        calendarScreen,
        contains('mainAxisAlignment: MainAxisAlignment.spaceBetween'),
      );

      expect(calendarScreen, isNot(contains('SingleChildScrollView')));
      expect(calendarScreen, isNot(contains('ScrollController')));
      expect(calendarScreen, isNot(contains('Listener')));
      expect(
        calendarScreen,
        isNot(contains('NotificationListener<ScrollEndNotification>')),
      );
      expect(calendarScreen, isNot(contains('animateTo(')));
      expect(calendarScreen, isNot(contains('jumpTo(')));
      expect(
        calendarScreen,
        isNot(contains('_requestCalendarLandingSpringBack')),
      );
      expect(calendarScreen, isNot(contains('_springBackToCalendarLanding')));
    });

    test(
      'centralizes landing geometry in AppLayout without custom animation',
      () {
        expect(appRouter, contains('extendBody: false'));
        expect(appRouter, contains('bottomNavigationBar: SafeArea'));
        expect(appRouter, contains('AppLayout.bottomNavigationHeight'));

        expect(appLayout, contains('bottomNavigationHeight = 72.0'));
        expect(appLayout, contains('bottomNavigationContentGap = 32.0'));
        expect(
          appLayout,
          contains('calendarLandingScrollPadding = EdgeInsets.zero'),
        );
        expect(appLayout, contains('calendarLandingSummaryCardMargin'));
        expect(
          calendarScreen,
          contains('padding: AppLayout.calendarLandingScrollPadding'),
        );

        expect(
          appLayout,
          isNot(contains('calendarLandingSpringBackTolerance')),
        );
        expect(appLayout, isNot(contains('calendarLandingSpringBackDuration')));
        expect(appLayout, isNot(contains('calendarLandingSpringBackCurve')));
      },
    );

    test('keeps current-cycle card as the bottom landing anchor', () {
      expect(calendarScreen, contains('_buildCurrentCycleInfo()'));
      expect(calendarScreen, contains('Current Cycle'));
      expect(calendarScreen, contains('Next Period'));
      expect(
        calendarScreen,
        contains('margin: AppLayout.calendarLandingSummaryCardMargin'),
      );
    });

    test('does not duplicate app-shell bottom navigation clearance', () {
      expect(calendarScreen, isNot(contains('scrollBottomPadding')));
      expect(calendarScreen, isNot(contains('bottomNavigationClearance')));
      expect(calendarScreen, isNot(contains('AppLayout.scrollBottomPadding')));
      expect(
        calendarScreen,
        isNot(contains('AppLayout.bottomNavigationClearance')),
      );
      expect(calendarScreen, isNot(contains('EdgeInsets.only(bottom:')));
    });
  });
}
