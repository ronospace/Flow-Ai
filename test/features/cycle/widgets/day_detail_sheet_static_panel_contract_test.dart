import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Calendar day detail panel contract', () {
    late String calendarScreen;
    late String dayDetailSheet;

    setUpAll(() {
      calendarScreen = File(
        'lib/features/cycle/screens/calendar_screen.dart',
      ).readAsStringSync();
      dayDetailSheet = File(
        'lib/features/cycle/widgets/day_detail_sheet.dart',
      ).readAsStringSync();
    });

    test('uses a static non-draggable modal entry point', () {
      expect(calendarScreen, contains('showModalBottomSheet'));
      expect(calendarScreen, contains('enableDrag: false'));
      expect(calendarScreen, contains('isDismissible: true'));
      expect(calendarScreen, contains('barrierColor: Colors.black.withValues'));
      expect(calendarScreen, contains('DayDetailSheet'));

      expect(calendarScreen, isNot(contains('DraggableScrollableSheet')));
    });

    test('renders day details as a fixed content-bounded panel', () {
      expect(dayDetailSheet, contains('maxPanelHeight'));
      expect(
        dayDetailSheet,
        contains('MediaQuery.sizeOf(context).height * 0.44'),
      );
      expect(dayDetailSheet, contains('ConstrainedBox'));
      expect(dayDetailSheet, contains('Flexible'));
      expect(dayDetailSheet, contains('SingleChildScrollView'));

      expect(dayDetailSheet, isNot(contains('DraggableScrollableSheet')));
      expect(dayDetailSheet, isNot(contains('initialChildSize')));
      expect(dayDetailSheet, isNot(contains('minChildSize')));
      expect(dayDetailSheet, isNot(contains('maxChildSize')));
      expect(dayDetailSheet, isNot(contains('scrollController')));
    });

    test('preserves selected-day actions', () {
      expect(dayDetailSheet, contains('Quick Actions'));
      expect(dayDetailSheet, contains('Log Data'));
      expect(dayDetailSheet, contains('View Insights'));
    });
  });
}
