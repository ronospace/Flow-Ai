import "package:cloud_firestore/cloud_firestore.dart";
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/local_user_service.dart';
import '../models/partner_models.dart'
    show Partnership, PartnershipStatus, PartnerPrivacySettings;
import 'partner_service.dart'
    show
        PartnerInvitation,
        PartnerMessage,
        PartnerMessageType,
        PartnerCareAction,
        PartnerCareActionType,
        PartnerInsight,
        PartnerInsightType,
        PartnerSharingSettings;

/// Local Partner Service
/// Provides partner sharing functionality using local storage (SharedPreferences)
/// Works without Firebase for offline/local partner connections
class LocalPartnerService {
  static final LocalPartnerService _instance = LocalPartnerService._internal();
  factory LocalPartnerService() => _instance;
  LocalPartnerService._internal();

  SharedPreferences? _prefs;
  static const String _partnershipsKey = 'local_partnerships';
  static const String _invitationsKey = 'local_invitations';
  static const String _messagesKey = 'local_partner_messages';
  static const String _careActionsKey = 'local_partner_care_actions';
  static const String _insightsKey = 'local_partner_insights';

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    debugPrint('✅ LocalPartnerService initialized');
  }

  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await initialize();
    }
  }

  /// Get current user info from LocalUserService
  Future<Map<String, String>> _getCurrentUserInfo() async {
    try {
      final userService = LocalUserService();
      final currentUser = await userService.getCurrentUser();
      if (currentUser != null) {
        return {
          'userId': currentUser.uid,
          'userName': currentUser.displayName,
          'userEmail': currentUser.email,
        };
      }
    } catch (e) {
      debugPrint('Error getting current user: $e');
    }

    // Fallback to prefs
    return {
      'userId':
          _prefs?.getString('current_user_id') ??
          'user_${DateTime.now().millisecondsSinceEpoch}',
      'userName': _prefs?.getString('current_user_name') ?? 'User',
      'userEmail': _prefs?.getString('current_user_email') ?? '',
    };
  }

  /// Create a partner invitation
  Future<PartnerInvitation> createPartnerInvitation({
    String? personalMessage,
    Duration expirationDuration = const Duration(days: 7),
  }) async {
    await _ensureInitialized();

    final userInfo = await _getCurrentUserInfo();
    final invitationCode = _generateInvitationCode();
    final now = DateTime.now();
    final invitation = PartnerInvitation(
      id: invitationCode,
      inviterId: userInfo['userId']!,
      inviterName: userInfo['userName']!,
      inviterEmail: userInfo['userEmail'],
      inviteeEmail: '',
      invitationCode: invitationCode,
      createdAt: now,
      expiresAt: now.add(expirationDuration),
      message: personalMessage,
    );

    await FirebaseFirestore.instance
        .collection('partner_invites')
        .doc(invitationCode)
        .set({
      'id': invitation.id,
      'inviterId': invitation.inviterId,
      'inviterName': invitation.inviterName,
      'inviterEmail': invitation.inviterEmail,
      'inviteeEmail': invitation.inviteeEmail,
      'invitationCode': invitation.invitationCode,
      'createdAt': invitation.createdAt.toIso8601String(),
      'expiresAt': invitation.expiresAt.toIso8601String(),
      'message': invitation.message,
      'status': 'pending',
    });

    debugPrint('✅ Partner invitation created in Firestore: $invitationCode');
    return invitation;
  }

  /// Accept partner invitation by code
  Future<Map<String, dynamic>?> acceptPartnerInvitation(
    String invitationCode,
  ) async {
    await _ensureInitialized();

    final userInfo = await _getCurrentUserInfo();
    final inviteeUserId = userInfo['userId']!;
    final code = invitationCode.trim().toUpperCase();

    final inviteRef = FirebaseFirestore.instance
        .collection('partner_invites')
        .doc(code);
    final inviteSnap = await inviteRef.get();

    if (!inviteSnap.exists) {
      debugPrint('❌ Invitation not found: $code');
      return null;
    }

    final data = inviteSnap.data()!;
    final inviterId = (data['inviterId'] ?? '').toString();
    final status = (data['status'] ?? 'pending').toString();
    final expiresAtRaw = (data['expiresAt'] ?? '').toString();

    if (inviterId.isEmpty) {
      debugPrint('❌ Invitation missing inviterId');
      return null;
    }
    if (status != 'pending') {
      debugPrint('❌ Invitation already used');
      return null;
    }
    if (inviterId == inviteeUserId) {
      debugPrint('❌ Cannot connect to yourself');
      return null;
    }
    if (expiresAtRaw.isEmpty || DateTime.now().isAfter(DateTime.parse(expiresAtRaw))) {
      debugPrint('❌ Invitation expired');
      return null;
    }

    final partnership = Partnership(
      id: 'partnership_${DateTime.now().millisecondsSinceEpoch}',
      userId1: inviterId,
      userId2: inviteeUserId,
      customName1: null,
      customName2: null,
      establishedAt: DateTime.now(),
      status: PartnershipStatus.active,
      privacySettings: const PartnerPrivacySettings(),
      lastActiveAt: DateTime.now(),
    );

    final batch = FirebaseFirestore.instance.batch();

    batch.set(
      FirebaseFirestore.instance.collection('partner_connections').doc(partnership.id),
      {
        'id': partnership.id,
        'userId1': partnership.userId1,
        'userId2': partnership.userId2,
        'customName1': partnership.customName1,
        'customName2': partnership.customName2,
        'establishedAt': partnership.establishedAt.toIso8601String(),
        'status': partnership.status.name,
        'privacySettings': partnership.privacySettings.toJson(),
        'lastActiveAt': partnership.lastActiveAt?.toIso8601String(),
      },
    );

    batch.update(inviteRef, {
      'status': 'accepted',
      'acceptedByUserId': inviteeUserId,
      'acceptedAt': DateTime.now().toIso8601String(),
    });

    await batch.commit();

    await _savePartnership(partnership);

    debugPrint('✅ Partnership created in Firestore: ${partnership.id}');
    return partnership.toJson();
  }

  /// Get partnership for current user
  Future<Partnership?> getCurrentPartnership() async {
    await _ensureInitialized();
    final userInfo = await _getCurrentUserInfo();
    final userId = userInfo['userId']!;
    final partnerships = await getAllPartnerships();
    try {
      return partnerships.firstWhere(
        (p) => p.userId1 == userId || p.userId2 == userId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get partnership for user (returns JSON for partner_service.dart compatibility)
  Future<Map<String, dynamic>?> getPartnershipForUser(String userId) async {
    await _ensureInitialized();
    final partnerships = await getAllPartnerships();
    try {
      final partnership = partnerships.firstWhere(
        (p) => p.userId1 == userId || p.userId2 == userId,
      );
      // Convert to partner_service.dart format
      return _convertPartnershipToServiceFormat(partnership);
    } catch (e) {
      return null;
    }
  }

  /// Convert Partnership (partner_models) to partner_service format
  /// Note: This returns the JSON in partner_models.dart format, which partner_service.dart
  /// should be able to use directly since it imports from partner_models.dart
  Map<String, dynamic> _convertPartnershipToServiceFormat(Partnership p) {
    // Actually, we should just return the partnership JSON as-is
    // since both use the same model from partner_models.dart
    return p.toJson();
  }

  /// Get partnership between two users
  Future<Partnership?> getPartnershipBetween(
    String userId1,
    String userId2,
  ) async {
    await _ensureInitialized();
    final partnerships = await getAllPartnerships();
    try {
      return partnerships.firstWhere(
        (p) =>
            (p.userId1 == userId1 && p.userId2 == userId2) ||
            (p.userId1 == userId2 && p.userId2 == userId1),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get all partnerships
  Future<List<Partnership>> getAllPartnerships() async {
    await _ensureInitialized();
    final jsonString = _prefs!.getString(_partnershipsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Partnership.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Error loading partnerships: $e');
      return [];
    }
  }

  /// Save partnership
  Future<void> _savePartnership(Partnership partnership) async {
    await _ensureInitialized();
    final partnerships = await getAllPartnerships();

    // Remove existing partnership if it exists
    partnerships.removeWhere((p) => p.id == partnership.id);

    // Add new partnership
    partnerships.add(partnership);

    // Save to storage
    final jsonList = partnerships.map((p) => p.toJson()).toList();
    await _prefs!.setString(_partnershipsKey, jsonEncode(jsonList));
  }

  /// Update partnership
  Future<void> updatePartnership(Partnership partnership) async {
    await _savePartnership(partnership);
  }

  /// Disconnect partnership
  Future<void> disconnectPartnership(String partnershipId) async {
    await _ensureInitialized();
    final partnerships = await getAllPartnerships();
    partnerships.removeWhere((p) => p.id == partnershipId);
    final jsonList = partnerships.map((p) => p.toJson()).toList();
    await _prefs!.setString(_partnershipsKey, jsonEncode(jsonList));
    debugPrint('✅ Partnership disconnected: $partnershipId');
  }

  /// Save invitation
  Future<void> _saveInvitation(PartnerInvitation invitation) async {
    await _ensureInitialized();
    final invitations = await _getAllInvitations();

    // Remove existing invitation with same code
    invitations.removeWhere(
      (i) => i.invitationCode == invitation.invitationCode,
    );

    invitations.add(invitation);

    final jsonList = invitations.map((i) => i.toJson()).toList();
    await _prefs!.setString(_invitationsKey, jsonEncode(jsonList));
  }

  /// Find invitation by code
  Future<PartnerInvitation?> _findInvitationByCode(String code) async {
    await _ensureInitialized();
    final invitations = await _getAllInvitations();
    try {
      return invitations.firstWhere((i) => i.invitationCode == code);
    } catch (e) {
      return null;
    }
  }

  /// Get all invitations
  Future<List<PartnerInvitation>> _getAllInvitations() async {
    await _ensureInitialized();
    final jsonString = _prefs!.getString(_invitationsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => PartnerInvitation.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Remove invitation
  Future<void> _removeInvitation(String invitationId) async {
    await _ensureInitialized();
    final invitations = await _getAllInvitations();
    invitations.removeWhere((i) => i.id == invitationId);
    final jsonList = invitations.map((i) => i.toJson()).toList();
    await _prefs!.setString(_invitationsKey, jsonEncode(jsonList));
  }

  /// Send message to partner
  Future<void> sendMessage({
    required String content,
    PartnerMessageType type = PartnerMessageType.text,
    Map<String, dynamic>? metadata,
  }) async {
    await _ensureInitialized();

    final partnership = await getCurrentPartnership();
    if (partnership == null) {
      throw Exception('No active partnership');
    }

    final userInfo = await _getCurrentUserInfo();
    final senderId = userInfo['userId']!;
    final receiverId = partnership.userId1 == senderId
        ? partnership.userId2
        : partnership.userId1;

    final message = PartnerMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      receiverId: receiverId,
      partnershipId: partnership.id,
      type: type,
      content: content,
      metadata: metadata,
      sentAt: DateTime.now(),
      isRead: false,
    );

    await _saveMessage(message);
    debugPrint('✅ Message sent: ${message.id}');
  }

  /// Get messages for partnership
  Future<List<PartnerMessage>> getMessages(String partnershipId) async {
    await _ensureInitialized();
    final messages = await _getAllMessages();
    return messages.where((m) => m.partnershipId == partnershipId).toList()
      ..sort((a, b) => b.sentAt.compareTo(a.sentAt));
  }

  /// Get messages for partnership (returns JSON list)
  Future<List<Map<String, dynamic>>> getMessagesForPartnership(
    String partnershipId,
  ) async {
    final messages = await getMessages(partnershipId);
    return messages.map((m) => m.toJson()).toList();
  }

  /// Save message
  Future<void> _saveMessage(PartnerMessage message) async {
    await _ensureInitialized();
    final messages = await _getAllMessages();
    messages.add(message);

    // Keep only last 1000 messages
    if (messages.length > 1000) {
      messages.sort((a, b) => b.sentAt.compareTo(a.sentAt));
      messages.removeRange(1000, messages.length);
    }

    final jsonList = messages.map((m) => m.toJson()).toList();
    await _prefs!.setString(_messagesKey, jsonEncode(jsonList));
  }

  /// Get all messages
  Future<List<PartnerMessage>> _getAllMessages() async {
    await _ensureInitialized();
    final jsonString = _prefs!.getString(_messagesKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => PartnerMessage.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Send care action
  Future<void> sendCareAction({
    required PartnerCareActionType type,
    required String title,
    String? description,
    Map<String, dynamic>? data,
  }) async {
    await _ensureInitialized();

    final partnership = await getCurrentPartnership();
    if (partnership == null) {
      throw Exception('No active partnership');
    }

    final userInfo = await _getCurrentUserInfo();
    final performedByUserId = userInfo['userId']!;
    final forUserId = partnership.userId1 == performedByUserId
        ? partnership.userId2
        : partnership.userId1;

    final careAction = PartnerCareAction(
      id: 'care_${DateTime.now().millisecondsSinceEpoch}',
      partnershipId: partnership.id,
      performedByUserId: performedByUserId,
      forUserId: forUserId,
      type: type,
      title: title,
      description: description,
      actionData: data,
      performedAt: DateTime.now(),
    );

    await _saveCareAction(careAction);
    debugPrint('✅ Care action sent: ${careAction.id}');
  }

  /// Update sharing settings
  Future<void> updateSharingSettings(
    String partnershipId,
    PartnerSharingSettings settings,
  ) async {
    await _ensureInitialized();
    final partnerships = await getAllPartnerships();
    try {
      final partnership = partnerships.firstWhere((p) => p.id == partnershipId);
      final updatedPrivacySettings = partnership.privacySettings.copyWith(
        shareDetailedSymptoms: settings.sharePhysicalSymptoms,
        shareMoodData: settings.shareMoodData,
        sharePainData: settings.sharePhysicalSymptoms,
        shareAIInsights: settings.allowInsights,
        sharePredictions: settings.sharePredictions,
        allowNotifications: settings.sendNotifications,
      );
      final updated = partnership.copyWith(
        privacySettings: updatedPrivacySettings,
        lastActiveAt: DateTime.now(),
      );
      await _savePartnership(updated);
      debugPrint('✅ Sharing settings updated');
    } catch (e) {
      debugPrint('❌ Partnership not found for update: $e');
    }
  }

  /// Get care actions for partnership
  Future<List<PartnerCareAction>> getCareActions(String partnershipId) async {
    await _ensureInitialized();
    final actions = await _getAllCareActions();
    return actions.where((a) => a.partnershipId == partnershipId).toList()
      ..sort((a, b) => b.performedAt.compareTo(a.performedAt));
  }

  /// Get care actions for partnership (returns JSON list)
  Future<List<Map<String, dynamic>>> getCareActionsForPartnership(
    String partnershipId,
  ) async {
    final actions = await getCareActions(partnershipId);
    return actions.map((a) => a.toJson()).toList();
  }

  /// Save care action
  Future<void> _saveCareAction(PartnerCareAction action) async {
    await _ensureInitialized();
    final actions = await _getAllCareActions();
    actions.add(action);

    // Keep only last 500 actions
    if (actions.length > 500) {
      actions.sort((a, b) => b.performedAt.compareTo(a.performedAt));
      actions.removeRange(500, actions.length);
    }

    final jsonList = actions.map((a) => a.toJson()).toList();
    await _prefs!.setString(_careActionsKey, jsonEncode(jsonList));
  }

  /// Get all care actions
  Future<List<PartnerCareAction>> _getAllCareActions() async {
    await _ensureInitialized();
    final jsonString = _prefs!.getString(_careActionsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => PartnerCareAction.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Generate invitation code
  String _generateInvitationCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Removed confusing chars
    final random = Random();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
