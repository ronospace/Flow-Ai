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

    test('keeps light bounce but removes duplicated bottom-nav clearance', () {
      expect(calendarScreen, contains('SingleChildScrollView'));
      expect(calendarScreen, contains('BouncingScrollPhysics'));
      expect(calendarScreen, contains('AlwaysScrollableScrollPhysics'));
      expect(calendarScreen, contains('padding: EdgeInsets.zero'));

      expect(calendarScreen, isNot(contains('scrollBottomPadding')));
      expect(calendarScreen, isNot(contains('bottomNavigationClearance')));
      expect(calendarScreen, isNot(contains('AppLayout.')));
    });

    test('lets the shell own bottom navigation geometry', () {
      expect(appRouter, contains('extendBody: false'));
      expect(appRouter, contains('bottomNavigationBar: SafeArea'));
      expect(appRouter, contains('AppLayout.bottomNavigationHeight'));

      expect(appLayout, contains('bottomNavigationHeight = 72.0'));
      expect(appLayout, contains('bottomNavigationContentGap = 32.0'));
    });

    test('keeps current-cycle card as the bottom landing anchor', () {
      expect(calendarScreen, contains('_buildCurrentCycleInfo()'));
      expect(calendarScreen, contains('Current Cycle'));
      expect(calendarScreen, contains('Next Period'));
      expect(
        calendarScreen,
        contains('margin: const EdgeInsets.all(AppTheme.spaceXl)'),
      );
    });
  });
}
