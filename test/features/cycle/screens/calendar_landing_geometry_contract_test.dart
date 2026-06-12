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

    test('keeps light bounce and springs back after true scroll idle', () {
      expect(calendarScreen, contains('SingleChildScrollView'));
      expect(calendarScreen, contains('BouncingScrollPhysics'));
      expect(calendarScreen, contains('AlwaysScrollableScrollPhysics'));
      expect(calendarScreen, contains('ScrollController'));
      expect(
        calendarScreen,
        contains('NotificationListener<ScrollEndNotification>'),
      );
      expect(calendarScreen, contains('isScrollingNotifier'));
      expect(calendarScreen, contains('_attachCalendarLandingScrollListener'));
      expect(calendarScreen, contains('_handleCalendarLandingScrollIdle'));
      expect(calendarScreen, contains('_springBackToCalendarLanding'));
      expect(calendarScreen, contains('animateTo('));
      expect(calendarScreen, contains('0,'));
      expect(
        calendarScreen,
        contains('padding: AppLayout.calendarLandingScrollPadding'),
      );

      expect(calendarScreen, isNot(contains('scrollBottomPadding')));
      expect(calendarScreen, isNot(contains('bottomNavigationClearance')));
      expect(calendarScreen, isNot(contains('AppLayout.scrollBottomPadding')));
      expect(
        calendarScreen,
        isNot(contains('AppLayout.bottomNavigationClearance')),
      );
    });

    test('centralizes landing and spring-back geometry in AppLayout', () {
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
      expect(appLayout, contains('calendarLandingSpringBackTolerance'));
      expect(appLayout, contains('calendarLandingSpringBackDuration'));
      expect(appLayout, contains('calendarLandingSpringBackCurve'));
    });

    test('keeps current-cycle card as the bottom landing anchor', () {
      expect(calendarScreen, contains('_buildCurrentCycleInfo()'));
      expect(calendarScreen, contains('Current Cycle'));
      expect(calendarScreen, contains('Next Period'));
      expect(
        calendarScreen,
        contains('margin: AppLayout.calendarLandingSummaryCardMargin'),
      );
      expect(
        calendarScreen,
        contains('AppLayout.calendarLandingSpringBackDuration'),
      );
      expect(
        calendarScreen,
        contains('AppLayout.calendarLandingSpringBackCurve'),
      );
    });
  });
}
