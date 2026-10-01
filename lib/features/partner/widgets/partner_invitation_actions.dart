import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../services/partner_service.dart';

class PartnerInvitationActions {
  static String generateInvitationLink(PartnerInvitation invitation) {
    return 'https://flowai-demo-project.web.app/invite/${invitation.invitationCode}';
  }

  static Future<void> copyToClipboard(String text) {
    return Clipboard.setData(ClipboardData(text: text));
  }

  static Future<void> shareLink(PartnerInvitation invitation) async {
    final link = generateInvitationLink(invitation);
    await SharePlus.instance.share(ShareParams(text: link));
  }
}
