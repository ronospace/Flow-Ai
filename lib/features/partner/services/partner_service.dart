import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/partner_models.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/local_user_service.dart';
import 'local_partner_service.dart';

/// Partner service - Uses local storage for partner features
/// Works offline without Firebase
class PartnerService extends ChangeNotifier {
  static final PartnerService _instance = PartnerService._internal();
  factory PartnerService() => _instance;
  PartnerService._internal() {
    debugPrint('✅ PartnerService: Using local partner service');
  }

  final LocalPartnerService _localService = LocalPartnerService();
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
      final actions = await _localService.getCareActions(_currentPartnership!.id);
      _careActions = actions;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading care actions: $e');
    }
  }

  /// Send invitation to partner
  Future<PartnerInvitation?> sendPartnerInvitation({
    required String inviteeEmail,
    String? inviteePhone,
    String? personalMessage,
  }) async {
    _setLoading(true);
    try {
      final invitation = await _localService.createPartnerInvitation(
        personalMessage: personalMessage,
      );
      
      if (invitation != null) {
        debugPrint('✅ Partner invitation created: ${invitation.invitationCode}');
      }
      
      return invitation;
    } catch (e) {
      _setError('Failed to create invitation: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Accept partner invitation
  Future<Partnership?> acceptPartnerInvitation(String invitationCode) async {
    _setLoading(true);
    try {
      final partnershipData = await _localService.acceptPartnerInvitation(invitationCode);
      
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
      await _localService.updateSharingSettings(_currentPartnership!.id, newSettings);
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
  bool get arePartnerFeaturesAvailable => true; // Local service is always available

  /// Get local partner data
  Map<String, dynamic> getLocalPartnerData() {
    return {
      'hasPartner': hasPartner,
      'messageCount': _messages.length,
      'careActionCount': _careActions.length,
      'insightCount': _insights.length,
      'lastActivity': _currentPartnership?.lastActiveAt?.toIso8601String(),
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

// Stub models for partner features (simplified versions)
class PartnerInvitation {
  final String id;
  final String inviterId;
  final String inviterName;
  final String? inviterEmail;
  final String inviteeEmail;
  final String? inviteePhone;
  final String invitationCode;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? message;

  PartnerInvitation({
    required this.id,
    required this.inviterId,
    required this.inviterName,
    this.inviterEmail,
    required this.inviteeEmail,
    this.inviteePhone,
    required this.invitationCode,
    required this.createdAt,
    required this.expiresAt,
    this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inviterId': inviterId,
      'inviterName': inviterName,
      'inviterEmail': inviterEmail,
      'inviteeEmail': inviteeEmail,
      'inviteePhone': inviteePhone,
      'invitationCode': invitationCode,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'message': message,
    };
  }

  factory PartnerInvitation.fromJson(Map<String, dynamic> json) {
    return PartnerInvitation(
      id: json['id'],
      inviterId: json['inviterId'],
      inviterName: json['inviterName'],
      inviterEmail: json['inviterEmail'],
      inviteeEmail: json['inviteeEmail'],
      inviteePhone: json['inviteePhone'],
      invitationCode: json['invitationCode'],
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      message: json['message'],
    );
  }
}

class Partnership {
  final String id;
  final String primaryUserId;
  final String partnerUserId;
  final String primaryUserName;
  final String partnerUserName;
  final String? primaryUserEmail;
  final String? partnerUserEmail;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final PartnerSharingSettings sharingSettings;

  Partnership({
    required this.id,
    required this.primaryUserId,
    required this.partnerUserId,
    required this.primaryUserName,
    required this.partnerUserName,
    this.primaryUserEmail,
    this.partnerUserEmail,
    required this.createdAt,
    required this.lastActiveAt,
    this.sharingSettings = const PartnerSharingSettings(),
  });

  Partnership copyWith({
    String? id,
    String? primaryUserId,
    String? partnerUserId,
    String? primaryUserName,
    String? partnerUserName,
    String? primaryUserEmail,
    String? partnerUserEmail,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    PartnerSharingSettings? sharingSettings,
  }) {
    return Partnership(
      id: id ?? this.id,
      primaryUserId: primaryUserId ?? this.primaryUserId,
      partnerUserId: partnerUserId ?? this.partnerUserId,
      primaryUserName: primaryUserName ?? this.primaryUserName,
      partnerUserName: partnerUserName ?? this.partnerUserName,
      primaryUserEmail: primaryUserEmail ?? this.primaryUserEmail,
      partnerUserEmail: partnerUserEmail ?? this.partnerUserEmail,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      sharingSettings: sharingSettings ?? this.sharingSettings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'primaryUserId': primaryUserId,
      'partnerUserId': partnerUserId,
      'primaryUserName': primaryUserName,
      'partnerUserName': partnerUserName,
      'primaryUserEmail': primaryUserEmail,
      'partnerUserEmail': partnerUserEmail,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
      'sharingSettings': sharingSettings.toJson(),
    };
  }

  factory Partnership.fromJson(Map<String, dynamic> json) {
    return Partnership(
      id: json['id'],
      primaryUserId: json['primaryUserId'],
      partnerUserId: json['partnerUserId'],
      primaryUserName: json['primaryUserName'],
      partnerUserName: json['partnerUserName'],
      primaryUserEmail: json['primaryUserEmail'],
      partnerUserEmail: json['partnerUserEmail'],
      createdAt: DateTime.parse(json['createdAt']),
      lastActiveAt: DateTime.parse(json['lastActiveAt']),
      sharingSettings: json['sharingSettings'] != null
          ? PartnerSharingSettings.fromJson(json['sharingSettings'])
          : const PartnerSharingSettings(),
    );
  }
}

class PartnerSharingSettings {
  final bool shareSymptoms;
  final bool shareMoodData;
  final bool sharePhysicalSymptoms;
  final bool sharePredictions;
  final bool allowInsights;
  final bool sendNotifications;
  final DateTime? lastUpdatedAt;

  const PartnerSharingSettings({
    this.shareSymptoms = true,
    this.shareMoodData = true,
    this.sharePhysicalSymptoms = true,
    this.sharePredictions = true,
    this.allowInsights = true,
    this.sendNotifications = true,
    this.lastUpdatedAt,
  });

  PartnerSharingSettings copyWith({
    bool? shareSymptoms,
    bool? shareMoodData,
    bool? sharePhysicalSymptoms,
    bool? sharePredictions,
    bool? allowInsights,
    bool? sendNotifications,
    DateTime? lastUpdatedAt,
  }) {
    return PartnerSharingSettings(
      shareSymptoms: shareSymptoms ?? this.shareSymptoms,
      shareMoodData: shareMoodData ?? this.shareMoodData,
      sharePhysicalSymptoms: sharePhysicalSymptoms ?? this.sharePhysicalSymptoms,
      sharePredictions: sharePredictions ?? this.sharePredictions,
      allowInsights: allowInsights ?? this.allowInsights,
      sendNotifications: sendNotifications ?? this.sendNotifications,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shareSymptoms': shareSymptoms,
      'shareMoodData': shareMoodData,
      'sharePhysicalSymptoms': sharePhysicalSymptoms,
      'sharePredictions': sharePredictions,
      'allowInsights': allowInsights,
      'sendNotifications': sendNotifications,
      'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
    };
  }

  factory PartnerSharingSettings.fromJson(Map<String, dynamic> json) {
    return PartnerSharingSettings(
      shareSymptoms: json['shareSymptoms'] ?? true,
      shareMoodData: json['shareMoodData'] ?? true,
      sharePhysicalSymptoms: json['sharePhysicalSymptoms'] ?? true,
      sharePredictions: json['sharePredictions'] ?? true,
      allowInsights: json['allowInsights'] ?? true,
      sendNotifications: json['sendNotifications'] ?? true,
      lastUpdatedAt: json['lastUpdatedAt'] != null
          ? DateTime.parse(json['lastUpdatedAt'])
          : null,
    );
  }
}

class PartnerMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String partnershipId;
  final PartnerMessageType type;
  final String content;
  final Map<String, dynamic>? metadata;
  final DateTime sentAt;
  final bool isRead;

  PartnerMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.partnershipId,
    required this.type,
    required this.content,
    this.metadata,
    required this.sentAt,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'partnershipId': partnershipId,
      'type': type.name,
      'content': content,
      'metadata': metadata,
      'sentAt': sentAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory PartnerMessage.fromJson(Map<String, dynamic> json) {
    return PartnerMessage(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      partnershipId: json['partnershipId'],
      type: PartnerMessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PartnerMessageType.text,
      ),
      content: json['content'],
      metadata: json['metadata'],
      sentAt: DateTime.parse(json['sentAt']),
      isRead: json['isRead'] ?? false,
    );
  }
}

class PartnerCareAction {
  final String id;
  final String partnershipId;
  final String performedByUserId;
  final String forUserId;
  final PartnerCareActionType type;
  final String title;
  final String? description;
  final Map<String, dynamic>? actionData;
  final DateTime performedAt;

  PartnerCareAction({
    required this.id,
    required this.partnershipId,
    required this.performedByUserId,
    required this.forUserId,
    required this.type,
    required this.title,
    this.description,
    this.actionData,
    required this.performedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partnershipId': partnershipId,
      'performedByUserId': performedByUserId,
      'forUserId': forUserId,
      'type': type.name,
      'title': title,
      'description': description,
      'actionData': actionData,
      'performedAt': performedAt.toIso8601String(),
    };
  }

  factory PartnerCareAction.fromJson(Map<String, dynamic> json) {
    return PartnerCareAction(
      id: json['id'],
      partnershipId: json['partnershipId'],
      performedByUserId: json['performedByUserId'],
      forUserId: json['forUserId'],
      type: PartnerCareActionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PartnerCareActionType.other,
      ),
      title: json['title'],
      description: json['description'],
      actionData: json['actionData'],
      performedAt: DateTime.parse(json['performedAt']),
    );
  }
}

class PartnerInsight {
  final String id;
  final String partnershipId;
  final PartnerInsightType type;
  final String title;
  final String content;
  final List<String> actionSuggestions;
  final DateTime generatedAt;
  final DateTime expiresAt;
  final bool isRead;

  PartnerInsight({
    required this.id,
    required this.partnershipId,
    required this.type,
    required this.title,
    required this.content,
    this.actionSuggestions = const [],
    required this.generatedAt,
    required this.expiresAt,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partnershipId': partnershipId,
      'type': type.name,
      'title': title,
      'content': content,
      'actionSuggestions': actionSuggestions,
      'generatedAt': generatedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory PartnerInsight.fromJson(Map<String, dynamic> json) {
    return PartnerInsight(
      id: json['id'],
      partnershipId: json['partnershipId'],
      type: PartnerInsightType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PartnerInsightType.supportSuggestion,
      ),
      title: json['title'],
      content: json['content'],
      actionSuggestions: List<String>.from(json['actionSuggestions'] ?? []),
      generatedAt: DateTime.parse(json['generatedAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      isRead: json['isRead'] ?? false,
    );
  }
}

// Enums
enum PartnershipStatus { invited, active, paused, ended }
enum PartnerMessageType { text, supportRequest, careAction, insight }
enum PartnerCareActionType { emotionalSupport, physicalCare, thoughtfulGesture, other }
enum PartnerInsightType { supportSuggestion, cycleUpdate, moodAlert, healthTip }
