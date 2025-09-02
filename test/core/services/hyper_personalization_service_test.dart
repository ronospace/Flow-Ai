import 'package:flutter_test/flutter_test.dart';
import '../../../lib/core/models/personalization.dart';
import '../../../lib/core/models/user_profile.dart';
import '../../../lib/core/services/hyper_personalization_service.dart';

void main() {
  group('HyperPersonalizationService', () {
    test('adaptTone applies locale and supportive tone', () async {
      final svc = HyperPersonalizationService.instance;
      await svc.initialize();

      final msg = 'Rest & restore';
      // Spanish locale expectation: prefix + translated string present
      final adapted = svc.adaptTone(message: msg, targetLocale: 'es-ES', tone: ToneProfile.supportive);

      expect(adapted.contains('🤗 '), isTrue);
      expect(adapted.contains('Descansa y recupérate'), isTrue);
    });

    test('buildPhaseNotification returns localized payload', () async {
      final svc = HyperPersonalizationService.instance;
      await svc.initialize();

      final user = UserProfile(
        id: 'u1',
        age: 30,
        lifestyle: null,
        healthConcerns: const [],
        preferences: const {'locale': 'es'},
        personalizedBaselines: const {},
        adaptationHistory: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final payload = svc.buildPhaseNotification(phase: 'follicular', user: user);
      expect(payload.title.isNotEmpty, isTrue);
      expect(payload.body.isNotEmpty, isTrue);
      expect(payload.data?['locale'], equals('es'));
    });
  });
}

