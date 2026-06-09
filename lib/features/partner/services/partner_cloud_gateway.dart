import 'package:cloud_functions/cloud_functions.dart';

import '../../../core/services/auth_service.dart';
import '../models/partner_service_models.dart';

typedef CloudIdentityEnsurer = Future<Object?> Function();
typedef PartnerCallableInvoker =
    Future<Object?> Function(String name, Map<String, dynamic> data);

/// Dormant cloud boundary for partner invitation operations.
///
/// This gateway is intentionally not wired into the live partner service while Firebase
/// billing and backend deployment remain pending.
class PartnerCloudGateway {
  PartnerCloudGateway({
    CloudIdentityEnsurer? ensureCloudIdentity,
    PartnerCallableInvoker? invoke,
  }) : _ensureCloudIdentity =
           ensureCloudIdentity ?? (() => AuthService().ensureCloudIdentity()),
       _invoke = invoke ?? _defaultInvoke;

  final CloudIdentityEnsurer _ensureCloudIdentity;
  final PartnerCallableInvoker _invoke;

  static final RegExp _invitationCodePattern = RegExp(r'^[A-HJ-NP-Z2-9]{6}$');
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static Future<Object?> _defaultInvoke(
    String name,
    Map<String, dynamic> data,
  ) async {
    final callable = FirebaseFunctions.instance.httpsCallable(name);
    final result = await callable.call<Map<String, dynamic>>(data);
    return result.data;
  }

  Future<void> _requireCloudIdentity() async {
    final identity = await _ensureCloudIdentity();
    if (identity == null) {
      throw StateError('Cloud partner services are unavailable.');
    }
  }

  String _normalizeInvitationCode(String value) {
    final code = value.trim().toUpperCase();
    if (!_invitationCodePattern.hasMatch(code)) {
      throw ArgumentError.value(
        value,
        'invitationCode',
        'Invitation code must use the verified six-character format.',
      );
    }
    return code;
  }

  String _invitationLink(String invitationCode) {
    return 'https://flow-ai-656b3.web.app/invite/$invitationCode';
  }

  /// Publishes an already-created local invitation to the secured backend.
  Future<void> publishInvitation(
    PartnerInvitation invitation, {
    String? recipientEmail,
  }) async {
    await _requireCloudIdentity();

    final code = _normalizeInvitationCode(invitation.invitationCode);
    final normalizedRecipient = recipientEmail?.trim().toLowerCase() ?? '';

    await _invoke('publishPartnerInvite', <String, dynamic>{
      'invitationCode': code,
      'invitationLink': _invitationLink(code),
      'personalMessage': invitation.message ?? '',
      'inviterName': invitation.inviterName,
      'inviterEmail': invitation.inviterEmail ?? '',
      'recipientEmail': normalizedRecipient,
      'expiresAtMillis': invitation.expiresAt.millisecondsSinceEpoch,
    });
  }

  /// Sends an invitation that has already been published.
  Future<void> sendInvitation({
    required PartnerInvitation invitation,
    required String inviteeEmail,
    String? personalMessage,
  }) async {
    final normalizedEmail = inviteeEmail.trim().toLowerCase();
    if (!_emailPattern.hasMatch(normalizedEmail)) {
      throw ArgumentError.value(
        inviteeEmail,
        'inviteeEmail',
        'Invalid email address.',
      );
    }

    await _requireCloudIdentity();

    final code = _normalizeInvitationCode(invitation.invitationCode);

    await _invoke('sendPartnerInvite', <String, dynamic>{
      'email': normalizedEmail,
      'personalMessage': personalMessage ?? invitation.message ?? '',
      'invitationCode': code,
      'invitationLink': _invitationLink(code),
    });
  }

  /// Accepts an invitation and returns the legacy Partnership JSON shape.
  Future<Map<String, dynamic>> acceptInvitation(String invitationCode) async {
    await _requireCloudIdentity();

    final code = _normalizeInvitationCode(invitationCode);
    final raw = await _invoke('acceptPartnerInvite', <String, dynamic>{
      'invitationCode': code,
    });

    if (raw is! Map) {
      throw StateError('Invalid partner acceptance response.');
    }

    final response = Map<String, dynamic>.from(raw);
    final nestedPartnership = response['partnership'];

    if (nestedPartnership is Map) {
      return Map<String, dynamic>.from(nestedPartnership);
    }

    const requiredKeys = <String>{
      'id',
      'userId1',
      'userId2',
      'establishedAt',
      'status',
      'privacySettings',
    };

    if (!requiredKeys.every(response.containsKey)) {
      throw StateError('Partner acceptance response is incomplete.');
    }

    return response;
  }
}
