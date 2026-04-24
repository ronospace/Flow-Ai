import 'dart:async';
import 'package:flutter/foundation.dart';
import 'local_partner_service.dart';
import 'partner_invite_actions.dart';
import '../models/partner_service_models.dart';
export '../models/partner_service_models.dart';

/// Partner service - Uses local storage for partner features
/// Works offline without Firebase
class PartnerService extends ChangeNotifier {
  static final PartnerService _instance = PartnerService._internal();
  factory PartnerService() => _instance;
  PartnerService._internal() {
    debugPrint('✅ PartnerService: Using local partner service');
  }

  final LocalPartnerService _localService = LocalPartnerService();
  late final PartnerInviteActions _inviteActions = PartnerInviteActions(
    _localService,
  );
  final bool _firebaseAvailable = false;

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
  bool get isFirebaseAvailable => _firebaseAvailable;

  /// Initialize the partner service
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _localService.initialize();
      await _loadPartnership();
      await _loadMessages();
      await _loadCareActions();
      debugPrint('✅ PartnerService initialized');
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load partnership for current user
  Future<void> _loadPartnership() async {
    try {
      final partnership = await _localService.getCurrentPartnership();
      if (partnership != null) {
        // Convert model Partnership to service Partnership
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
    } catch (e) {
      debugPrint('Error loading partnership: $e');
    }
  }

  /// Load messages for current partnership
  Future<void> _loadMessages() async {
    if (_currentPartnership == null) return;

    try {
      final messages = await _localService.getMessages(_currentPartnership!.id);
      _messages = messages;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
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
    } catch (e) {
      debugPrint('Error loading care actions: $e');
    }
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
      final partnershipData = await _localService.acceptPartnerInvitation(
        invitationCode,
      );

      if (partnershipData != null) {
        // Reload partnership to get updated state
        await _loadPartnership();
        await _loadMessages();
        await _loadCareActions();
        notifyListeners();
        debugPrint('✅ Partnership accepted');
        return _currentPartnership;
      }

      _setError('Failed to accept invitation');
      return null;
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
      debugPrint('✅ Sharing settings updated');
    } catch (e) {
      _setError('Failed to update settings: $e');
    }
  }

  /// Generate AI insights for partner
  Future<void> generatePartnerInsights() async {
    // TODO: Implement AI insights generation based on shared data
    debugPrint('🔄 Generating partner insights...');
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
      debugPrint('✅ Partnership disconnected');
    } catch (e) {
      _setError('Failed to disconnect: $e');
    }
  }

  /// Get partner feature status
  Future<Map<String, dynamic>> getPartnerFeatureStatus() async {
    return {
      'firebaseAvailable': _firebaseAvailable,
      'partnerFeaturesEnabled': true, // Local service is enabled
      'hasActivePartnership': hasPartner,
      'message': 'Partner features available via local storage',
    };
  }

  /// Check if partner features are available
  bool get arePartnerFeaturesAvailable =>
      true; // Local service is always available

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
    debugPrint('🔄 PartnerService: Disposing service');
    super.dispose();
  }
}
