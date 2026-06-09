import 'package:flow_ai/features/partner/models/partner_service_models.dart';
import 'package:flow_ai/features/partner/services/partner_cloud_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  PartnerInvitation invitation() {
    return PartnerInvitation(
      id: 'inv-local-1',
      inviterId: 'local-user-1',
      inviterName: 'Amina',
      inviterEmail: 'amina@example.com',
      inviteeEmail: '',
      invitationCode: 'AB23CD',
      createdAt: DateTime.utc(2026, 6, 9),
      expiresAt: DateTime.utc(2026, 6, 16),
      message: 'Hello',
    );
  }

  test(
    'publish requires identity and sends actual invitation expiry',
    () async {
      final calls = <Map<String, dynamic>>[];
      final gateway = PartnerCloudGateway(
        ensureCloudIdentity: () async => Object(),
        invoke: (name, data) async {
          calls.add(<String, dynamic>{'name': name, 'data': data});
          return <String, dynamic>{'ok': true};
        },
      );

      final value = invitation();
      await gateway.publishInvitation(
        value,
        recipientEmail: ' PARTNER@EXAMPLE.COM ',
      );

      expect(calls, hasLength(1));
      expect(calls.single['name'], 'publishPartnerInvite');

      final data = calls.single['data'] as Map<String, dynamic>;
      expect(data['invitationCode'], 'AB23CD');
      expect(data['recipientEmail'], 'partner@example.com');
      expect(data['expiresAtMillis'], value.expiresAt.millisecondsSinceEpoch);
      expect(
        data['invitationLink'],
        'https://flow-ai-656b3.web.app/invite/AB23CD',
      );
    },
  );

  test('missing cloud identity blocks backend invocation', () async {
    var invoked = false;
    final gateway = PartnerCloudGateway(
      ensureCloudIdentity: () async => null,
      invoke: (name, data) async {
        invoked = true;
        return null;
      },
    );

    await expectLater(
      gateway.publishInvitation(invitation()),
      throwsA(isA<StateError>()),
    );
    expect(invoked, isFalse);
  });

  test('send normalizes recipient and uses secured callable', () async {
    String? calledName;
    Map<String, dynamic>? calledData;

    final gateway = PartnerCloudGateway(
      ensureCloudIdentity: () async => Object(),
      invoke: (name, data) async {
        calledName = name;
        calledData = data;
        return <String, dynamic>{'ok': true};
      },
    );

    await gateway.sendInvitation(
      invitation: invitation(),
      inviteeEmail: ' PARTNER@EXAMPLE.COM ',
      personalMessage: 'Welcome',
    );

    expect(calledName, 'sendPartnerInvite');
    expect(calledData?['email'], 'partner@example.com');
    expect(calledData?['personalMessage'], 'Welcome');
  });

  test('accept unwraps verified partnership response shape', () async {
    final partnership = <String, dynamic>{
      'id': 'partnership_a_b',
      'userId1': 'a',
      'userId2': 'b',
      'customName1': null,
      'customName2': null,
      'establishedAt': '2026-06-09T20:00:00.000Z',
      'status': 'active',
      'privacySettings': <String, dynamic>{},
      'lastActiveAt': '2026-06-09T20:00:00.000Z',
    };

    final gateway = PartnerCloudGateway(
      ensureCloudIdentity: () async => Object(),
      invoke: (name, data) async {
        expect(name, 'acceptPartnerInvite');
        expect(data['invitationCode'], 'AB23CD');
        return <String, dynamic>{'ok': true, 'partnership': partnership};
      },
    );

    expect(await gateway.acceptInvitation(' ab23cd '), partnership);
  });
}
