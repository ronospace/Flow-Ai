import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Future feature notification truth', () {
    late String router;
    late String settings;
    late String card;
    late String aiCoach;

    setUpAll(() {
      router = File('lib/core/routing/app_router.dart').readAsStringSync();

      settings = File(
        'lib/features/settings/screens/settings_screen.dart',
      ).readAsStringSync();

      card = File(
        'lib/features/coming_soon/widgets/coming_soon_card.dart',
      ).readAsStringSync();

      aiCoach = File(
        'lib/features/insights/screens/ai_coach_screen.dart',
      ).readAsStringSync();
    });

    test('Product Roadmap remains reachable', () {
      expect(router, contains("path: '/future-plans'"));
      expect(settings, contains("context.push('/future-plans')"));
    });

    test('coming-soon default UX does not fabricate registration', () {
      expect(card, isNot(contains('Implement notification signup')));
      expect(
        card,
        isNot(contains("We'll notify you when this feature is ready!")),
      );
      expect(card, isNot(contains("child: const Text('Notify Me')")));
      expect(card, contains("child: const Text('Got it')"));
    });

    test('AI Coach does not fabricate a notification subscription', () {
      expect(aiCoach, isNot(contains('Notification Set')));
      expect(
        aiCoach,
        isNot(
          contains(
            "We'll notify you as soon as the AI Health Coach feature is available!",
          ),
        ),
      );
      expect(aiCoach, isNot(contains('_showNotificationDialog')));
      expect(aiCoach, isNot(contains('onNotifyMe:')));
    });
  });
}
