import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../services/partner_service.dart';

class PartnerInvitationActions {
  static String generateInvitationLink(PartnerInvitation invitation) {
    return 'https://flowai.app/invite/${invitation.invitationCode}';
  }

  static Future<void> copyToClipboard(String text) {
    return Clipboard.setData(ClipboardData(text: text));
  }

  static Future<void> shareLink(PartnerInvitation invitation) {
    final link = generateInvitationLink(invitation);
    return Share.share(link);
  }
}
