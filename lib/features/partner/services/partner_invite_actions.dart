import 'package:cloud_functions/cloud_functions.dart';
import '../models/partner_service_models.dart';
import 'local_partner_service.dart';

class PartnerInviteActions {
  final LocalPartnerService localService;
  PartnerInviteActions(this.localService);

  Future<PartnerInvitation> createInvitation({String? personalMessage}) {
    return localService.createPartnerInvitation(
      personalMessage: personalMessage,
    );
  }

  Future<PartnerInvitation?> sendInvitation({
    required String inviteeEmail,
    String? personalMessage,
  }) async {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(inviteeEmail)) {
      throw Exception('Invalid email address');
    }

    final invitation = await localService.createPartnerInvitation(
      personalMessage: personalMessage,
    );

    final code = invitation.invitationCode;
    final link = "https://flow-ai-656b3.web.app/invite/$code";

    final callable = FirebaseFunctions.instance.httpsCallable(
      'sendPartnerInvite',
    );
    await callable.call({
      'email': inviteeEmail,
      'personalMessage': personalMessage ?? '',
      'invitationCode': code,
      'invitationLink': link,
    });

    return invitation;
  }
}
