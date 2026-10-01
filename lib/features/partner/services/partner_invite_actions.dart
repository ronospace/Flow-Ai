import '../models/partner_service_models.dart';
import 'local_partner_service.dart';
import 'partner_cloud_gateway.dart';

class PartnerInviteActions {
  PartnerInviteActions(this.localService, {PartnerCloudGateway? cloudGateway})
    : _cloudGateway = cloudGateway ?? PartnerCloudGateway();

  final LocalPartnerService localService;
  final PartnerCloudGateway _cloudGateway;

  Future<PartnerInvitation> createInvitation({String? personalMessage}) async {
    final invitation = await localService.createPartnerInvitation(
      personalMessage: personalMessage,
    );

    await _cloudGateway.publishInvitation(invitation);
    return invitation;
  }

  Future<PartnerInvitation> sendInvitation({
    required String inviteeEmail,
    String? personalMessage,
  }) async {
    final invitation = await localService.createPartnerInvitation(
      personalMessage: personalMessage,
    );

    await _cloudGateway.publishInvitation(
      invitation,
      recipientEmail: inviteeEmail,
    );

    await _cloudGateway.sendInvitation(
      invitation: invitation,
      inviteeEmail: inviteeEmail,
      personalMessage: personalMessage,
    );

    return invitation;
  }

  Future<Map<String, dynamic>?> fetchCurrentPartnership() {
    return _cloudGateway.fetchCurrentPartnership();
  }

  Future<Map<String, dynamic>> acceptInvitation(String invitationCode) {
    return _cloudGateway.acceptInvitation(invitationCode);
  }
}
