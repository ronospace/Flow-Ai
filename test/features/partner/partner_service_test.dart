import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flow_ai/features/partner/services/partner_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PartnerService', () {
    late PartnerService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = PartnerService();
    });

    test('createPartnerInvitation completes', () async {
      final result = await service.createPartnerInvitation(
        personalMessage: 'Hello',
      );

      expect(result, isNotNull);
    });

    test('sendPartnerInvitation resets loading state', () async {
      await service.sendPartnerInvitation(
        inviteeEmail: 'user@example.com',
        personalMessage: 'Hi there',
      );

      expect(service.isLoading, false);
    });

    test('getPartnerFeatureStatus returns expected keys', () async {
      final result = await service.getPartnerFeatureStatus();

      expect(result, contains('firebaseAvailable'));
      expect(result, contains('partnerFeaturesEnabled'));
      expect(result, contains('hasActivePartnership'));
      expect(result, contains('message'));
    });

    test('loading state is false after status check', () async {
      await service.getPartnerFeatureStatus();
      expect(service.isLoading, false);
    });
  });
}
