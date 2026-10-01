import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../core/services/auth_service.dart';
import 'local_partner_service.dart';
import 'partner_invite_actions.dart';
import '../models/partner_service_models.dart';
export '../models/partner_service_models.dart';

/// Partner service coordinating local partner state with authenticated cloud
/// invitation publication, delivery, and acceptance.
class PartnerService extends ChangeNotifier {
  static final PartnerService _instance = PartnerService._internal();
  factory PartnerService() => _instance;
  PartnerService._internal() {}

  final LocalPartnerService _localService = LocalPartnerService();
  late final PartnerInviteActions _inviteActions = PartnerInviteActions(
    _localService,
  );
  Partnership? _currentPartnership;
  List<PartnerMessage> _messages = [];
  List<PartnerCareAction> _careActions = [];
  List<PartnerInsight> _insights = [];

  bool _isLoading = false;
  String? _error;

  // Getters
  Partnership? get currentPartnership => _currentPartnership;
  List<PartnerMessage> get messages => _messages;
  List<PartnerCareAction> get careActions => _careActions;
  List<PartnerInsight> get insights => _insights;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasPartner => _currentPartnership != null;
  bool get isFirebaseAvailable => AuthService().isFirebaseAvailable;

  /// Initialize the partner service
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _localService.initialize();
      await _loadPartnership();
      await _loadMessages();
      await _loadCareActions();
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load partnership for current user.
  ///
  /// Cloud is authoritative when reachable. Local storage remains a cache for
  /// offline continuity and local partner sub-features.
  Future<void> _loadPartnership() async {
    try {
      final cloudPartnership = await _inviteActions.fetchCurrentPartnership();

      if (cloudPartnership != null) {
        final resolvedPartnership = Partnership(
          id: cloudPartnership['id'],
          primaryUserId: cloudPartnership['userId1'],
          partnerUserId: cloudPartnership['userId2'],
          primaryUserName:
              cloudPartnership['customName1'] ?? cloudPartnership['userId1'],
          partnerUserName:
              cloudPartnership['customName2'] ?? cloudPartnership['userId2'],
          primaryUserEmail: null,
          partnerUserEmail: null,
          createdAt: DateTime.parse(cloudPartnership['establishedAt']),
          lastActiveAt: cloudPartnership['lastActiveAt'] != null
              ? DateTime.parse(cloudPartnership['lastActiveAt'])
              : DateTime.parse(cloudPartnership['establishedAt']),
          sharingSettings: const PartnerSharingSettings(),
        );

        // Authenticated cloud state is authoritative. Publish it first so a
        // secondary local-cache failure can never hide a valid partnership.
        _currentPartnership = resolvedPartnership;
        notifyListeners();

        try {
          await _localService.cacheCloudPartnership(cloudPartnership);
        } catch (_) {
          // Local persistence is offline continuity only, never cloud truth.
        }

        return;
      }
    } catch (_) {
      // Cloud failure must not destroy a previously verified local cache.
    }

    try {
      final partnership = await _localService.getCurrentPartnership();

      if (partnership != null) {
        _currentPartnership = Partnership(
          id: partnership.id,
          primaryUserId: partnership.userId1,
          partnerUserId: partnership.userId2,
          primaryUserName: partnership.customName1 ?? partnership.userId1,
          partnerUserName: partnership.customName2 ?? partnership.userId2,
          primaryUserEmail: null,
          partnerUserEmail: null,
          createdAt: partnership.establishedAt,
          lastActiveAt: partnership.lastActiveAt ?? partnership.establishedAt,
          sharingSettings: PartnerSharingSettings(
            shareSymptoms: partnership.privacySettings.shareDetailedSymptoms,
            shareMoodData: partnership.privacySettings.shareMoodData,
            sharePhysicalSymptoms: partnership.privacySettings.sharePainData,
            sharePredictions: partnership.privacySettings.sharePredictions,
            allowInsights: partnership.privacySettings.shareAIInsights,
            sendNotifications: partnership.privacySettings.allowNotifications,
          ),
        );

        notifyListeners();
      }
    } catch (_) {}
  }

  /// Load messages for current partnership
  Future<void> _loadMessages() async {
    if (_currentPartnership == null) return;

    try {
      final messages = await _localService.getMessages(_currentPartnership!.id);
      _messages = messages;
      notifyListeners();
    } catch (e) {}
  }

  /// Load care actions for current partnership
  Future<void> _loadCareActions() async {
    if (_currentPartnership == null) return;

    try {
      final actions = await _localService.getCareActions(
        _currentPartnership!.id,
      );
      _careActions = actions;
      notifyListeners();
    } catch (e) {}
  }

  /// Create invitation without sending email (QR / link flow)
  Future<PartnerInvitation> createPartnerInvitation({
    String? personalMessage,
  }) async {
    return _inviteActions.createInvitation(personalMessage: personalMessage);
  }

  /// Send invitation to partner
  Future<PartnerInvitation?> sendPartnerInvitation({
    required String inviteeEmail,
    String? inviteePhone,
    String? personalMessage,
  }) async {
    _setLoading(true);
    try {
      return await _inviteActions.sendInvitation(
        inviteeEmail: inviteeEmail,
        personalMessage: personalMessage,
      );
    } catch (e) {
      _setError('Failed to send invitation: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Accept partner invitation
  Future<Partnership?> acceptPartnerInvitation(String invitationCode) async {
    _setLoading(true);
    try {
      final partnershipData = await _inviteActions.acceptInvitation(
        invitationCode,
      );

      _currentPartnership = Partnership(
        id: partnershipData['id'],
        primaryUserId: partnershipData['userId1'],
        partnerUserId: partnershipData['userId2'],
        primaryUserName:
            partnershipData['customName1'] ?? partnershipData['userId1'],
        partnerUserName:
            partnershipData['customName2'] ?? partnershipData['userId2'],
        primaryUserEmail: null,
        partnerUserEmail: null,
        createdAt: DateTime.parse(partnershipData['establishedAt']),
        lastActiveAt: partnershipData['lastActiveAt'] != null
            ? DateTime.parse(partnershipData['lastActiveAt'])
            : DateTime.parse(partnershipData['establishedAt']),
        sharingSettings: const PartnerSharingSettings(),
      );

      // Publish authenticated backend truth before secondary local persistence.
      notifyListeners();

      try {
        await _localService.cacheCloudPartnership(partnershipData);
      } catch (_) {
        // Cache failure must not invalidate an accepted cloud partnership.
      }

      await _loadMessages();
      await _loadCareActions();
      return _currentPartnership;
    } catch (e) {
      _setError('Failed to accept invitation: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Send message to partner
  Future<PartnerMessage?> sendMessage({
    required String content,
    PartnerMessageType type = PartnerMessageType.text,
    Map<String, dynamic>? metadata,
  }) async {
    if (_currentPartnership == null) {
      _setError('No active partnership');
      return null;
    }

    try {
      await _localService.sendMessage(
        content: content,
        type: type,
        metadata: metadata,
      );

      // Reload messages
      await _loadMessages();

      // Return the most recent message
      if (_messages.isNotEmpty) {
        return _messages.first;
      }
      return null;
    } catch (e) {
      _setError('Failed to send message: $e');
      return null;
    }
  }

  /// Send care action to partner
  Future<PartnerCareAction?> sendCareAction({
    required PartnerCareActionType type,
    required String title,
    String? description,
    Map<String, dynamic>? actionData,
  }) async {
    if (_currentPartnership == null) {
      _setError('No active partnership');
      return null;
    }

    try {
      await _localService.sendCareAction(
        type: type,
        title: title,
        description: description,
        data: actionData,
      );

      // Reload care actions
      await _loadCareActions();

      // Return the most recent action
      if (_careActions.isNotEmpty) {
        return _careActions.first;
      }
      return null;
    } catch (e) {
      _setError('Failed to send care action: $e');
      return null;
    }
  }

  /// Update sharing settings
  Future<void> updateSharingSettings(PartnerSharingSettings newSettings) async {
    if (_currentPartnership == null) {
      _setError('No active partnership');
      return;
    }

    try {
      await _localService.updateSharingSettings(
        _currentPartnership!.id,
        newSettings,
      );
      await _loadPartnership();
    } catch (e) {
      _setError('Failed to update settings: $e');
    }
  }

  /// Generate AI insights for partner
  Future<void> generatePartnerInsights() async {
    // TODO: Implement AI insights generation based on shared data
    // For now, just reload data
    await _loadPartnership();
    await _loadMessages();
    await _loadCareActions();
  }

  /// Disconnect partnership
  Future<void> disconnectPartnership() async {
    if (_currentPartnership == null) return;

    try {
      await _localService.disconnectPartnership(_currentPartnership!.id);
      _currentPartnership = null;
      _messages.clear();
      _careActions.clear();
      _insights.clear();
      notifyListeners();
    } catch (e) {
      _setError('Failed to disconnect: $e');
    }
  }

  /// Get partner feature status
  Future<Map<String, dynamic>> getPartnerFeatureStatus() async {
    final firebaseAvailable = AuthService().isFirebaseAvailable;

    return {
      'firebaseAvailable': firebaseAvailable,
      'partnerFeaturesEnabled': firebaseAvailable,
      'hasActivePartnership': hasPartner,
      'message': firebaseAvailable
          ? 'Partner invitation services are available.'
          : 'Partner invitation services are temporarily unavailable.',
    };
  }

  /// Check whether authenticated partner invitation services are available.
  bool get arePartnerFeaturesAvailable => AuthService().isFirebaseAvailable;

  /// Get local partner data
  Map<String, dynamic> getLocalPartnerData() {
    return {
      'hasPartner': hasPartner,
      'messageCount': _messages.length,
      'careActionCount': _careActions.length,
      'insightCount': _insights.length,
      'lastActivity': _currentPartnership?.lastActiveAt.toIso8601String(),
    };
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
