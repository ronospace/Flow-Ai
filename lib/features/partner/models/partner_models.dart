import '../../../core/models/user_profile.dart';

/// Represents a partner connection request
class PartnerRequest {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String fromUserName;
  final String toUserName;
  final String? message;
  final DateTime createdAt;
  final PartnerRequestStatus status;

  const PartnerRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.fromUserName,
    required this.toUserName,
    this.message,
    required this.createdAt,
    required this.status,
  });

  factory PartnerRequest.fromJson(Map<String, dynamic> json) {
    return PartnerRequest(
      id: json['id'] as String,
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      fromUserName: json['fromUserName'] as String,
      toUserName: json['toUserName'] as String,
      message: json['message'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: PartnerRequestStatus.values.byName(json['status'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'fromUserName': fromUserName,
      'toUserName': toUserName,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
    };
  }

  PartnerRequest copyWith({
    String? id,
    String? fromUserId,
    String? toUserId,
    String? fromUserName,
    String? toUserName,
    String? message,
    DateTime? createdAt,
    PartnerRequestStatus? status,
  }) {
    return PartnerRequest(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      fromUserName: fromUserName ?? this.fromUserName,
      toUserName: toUserName ?? this.toUserName,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}

/// Status of a partner request
enum PartnerRequestStatus {
  pending,
  accepted,
  declined,
  cancelled,
}

/// Represents a partnership between two users
class Partnership {
  final String id;
  final String userId1;
  final String userId2;
  final String? customName1;
  final String? customName2;
  final DateTime establishedAt;
  final PartnershipStatus status;
  final PartnerPrivacySettings privacySettings;
  final DateTime? lastActiveAt;

  const Partnership({
    required this.id,
    required this.userId1,
    required this.userId2,
    this.customName1,
    this.customName2,
    required this.establishedAt,
    required this.status,
    required this.privacySettings,
    this.lastActiveAt,
  });

  factory Partnership.fromJson(Map<String, dynamic> json) {
    return Partnership(
      id: json['id'] as String,
      userId1: json['userId1'] as String,
      userId2: json['userId2'] as String,
      customName1: json['customName1'] as String?,
      customName2: json['customName2'] as String?,
      establishedAt: DateTime.parse(json['establishedAt'] as String),
      status: PartnershipStatus.values.byName(json['status'] as String),
      privacySettings: PartnerPrivacySettings.fromJson(
          json['privacySettings'] as Map<String, dynamic>),
      lastActiveAt: json['lastActiveAt'] != null
          ? DateTime.parse(json['lastActiveAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId1': userId1,
      'userId2': userId2,
      'customName1': customName1,
      'customName2': customName2,
      'establishedAt': establishedAt.toIso8601String(),
      'status': status.name,
      'privacySettings': privacySettings.toJson(),
      'lastActiveAt': lastActiveAt?.toIso8601String(),
    };
  }

  Partnership copyWith({
    String? id,
    String? userId1,
    String? userId2,
    String? customName1,
    String? customName2,
    DateTime? establishedAt,
    PartnershipStatus? status,
    PartnerPrivacySettings? privacySettings,
    DateTime? lastActiveAt,
  }) {
    return Partnership(
      id: id ?? this.id,
      userId1: userId1 ?? this.userId1,
      userId2: userId2 ?? this.userId2,
      customName1: customName1 ?? this.customName1,
      customName2: customName2 ?? this.customName2,
      establishedAt: establishedAt ?? this.establishedAt,
      status: status ?? this.status,
      privacySettings: privacySettings ?? this.privacySettings,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  String getPartnerName(String currentUserId) {
    if (currentUserId == userId1) {
      return customName2 ?? userId2;
    } else {
      return customName1 ?? userId1;
    }
  }

  String getPartnerId(String currentUserId) {
    return currentUserId == userId1 ? userId2 : userId1;
  }
}

/// Status of a partnership
enum PartnershipStatus {
  active,
  paused,
  ended,
}

/// Privacy settings for partner data sharing
class PartnerPrivacySettings {
  final bool shareBasicCycleInfo;
  final bool shareDetailedSymptoms;
  final bool shareMoodData;
  final bool shareEnergyLevels;
  final bool sharePainData;
  final bool shareAIInsights;
  final bool sharePredictions;
  final bool allowNotifications;
  final bool allowCareActions;
  final bool shareHistoricalData;
  final List<String> restrictedDataTypes;

  const PartnerPrivacySettings({
    this.shareBasicCycleInfo = true,
    this.shareDetailedSymptoms = false,
    this.shareMoodData = true,
    this.shareEnergyLevels = true,
    this.sharePainData = false,
    this.shareAIInsights = true,
    this.sharePredictions = true,
    this.allowNotifications = true,
    this.allowCareActions = true,
    this.shareHistoricalData = false,
    this.restrictedDataTypes = const [],
  });

  factory PartnerPrivacySettings.fromJson(Map<String, dynamic> json) {
    return PartnerPrivacySettings(
      shareBasicCycleInfo: json['shareBasicCycleInfo'] as bool? ?? true,
      shareDetailedSymptoms: json['shareDetailedSymptoms'] as bool? ?? false,
      shareMoodData: json['shareMoodData'] as bool? ?? true,
      shareEnergyLevels: json['shareEnergyLevels'] as bool? ?? true,
      sharePainData: json['sharePainData'] as bool? ?? false,
      shareAIInsights: json['shareAIInsights'] as bool? ?? true,
      sharePredictions: json['sharePredictions'] as bool? ?? true,
      allowNotifications: json['allowNotifications'] as bool? ?? true,
      allowCareActions: json['allowCareActions'] as bool? ?? true,
      shareHistoricalData: json['shareHistoricalData'] as bool? ?? false,
      restrictedDataTypes: List<String>.from(
          json['restrictedDataTypes'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shareBasicCycleInfo': shareBasicCycleInfo,
      'shareDetailedSymptoms': shareDetailedSymptoms,
      'shareMoodData': shareMoodData,
      'shareEnergyLevels': shareEnergyLevels,
      'sharePainData': sharePainData,
      'shareAIInsights': shareAIInsights,
      'sharePredictions': sharePredictions,
      'allowNotifications': allowNotifications,
      'allowCareActions': allowCareActions,
      'shareHistoricalData': shareHistoricalData,
      'restrictedDataTypes': restrictedDataTypes,
    };
  }

  PartnerPrivacySettings copyWith({
    bool? shareBasicCycleInfo,
    bool? shareDetailedSymptoms,
    bool? shareMoodData,
    bool? shareEnergyLevels,
    bool? sharePainData,
    bool? shareAIInsights,
    bool? sharePredictions,
    bool? allowNotifications,
    bool? allowCareActions,
    bool? shareHistoricalData,
    List<String>? restrictedDataTypes,
  }) {
    return PartnerPrivacySettings(
      shareBasicCycleInfo: shareBasicCycleInfo ?? this.shareBasicCycleInfo,
      shareDetailedSymptoms: shareDetailedSymptoms ?? this.shareDetailedSymptoms,
      shareMoodData: shareMoodData ?? this.shareMoodData,
      shareEnergyLevels: shareEnergyLevels ?? this.shareEnergyLevels,
      sharePainData: sharePainData ?? this.sharePainData,
      shareAIInsights: shareAIInsights ?? this.shareAIInsights,
      sharePredictions: sharePredictions ?? this.sharePredictions,
      allowNotifications: allowNotifications ?? this.allowNotifications,
      allowCareActions: allowCareActions ?? this.allowCareActions,
      shareHistoricalData: shareHistoricalData ?? this.shareHistoricalData,
      restrictedDataTypes: restrictedDataTypes ?? this.restrictedDataTypes,
    );
  }
}

/// Represents a message between partners
class PartnerMessage {
  final String id;
  final String partnershipId;
  final String senderId;
  final String receiverId;
  final String content;
  final PartnerMessageType type;
  final DateTime createdAt;
  final DateTime? readAt;
  final Map<String, dynamic>? metadata;

  const PartnerMessage({
    required this.id,
    required this.partnershipId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.createdAt,
    this.readAt,
    this.metadata,
  });

  factory PartnerMessage.fromJson(Map<String, dynamic> json) {
    return PartnerMessage(
      id: json['id'] as String,
      partnershipId: json['partnershipId'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      content: json['content'] as String,
      type: PartnerMessageType.values.byName(json['type'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partnershipId': partnershipId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  PartnerMessage copyWith({
    String? id,
    String? partnershipId,
    String? senderId,
    String? receiverId,
    String? content,
    PartnerMessageType? type,
    DateTime? createdAt,
    DateTime? readAt,
    Map<String, dynamic>? metadata,
  }) {
    return PartnerMessage(
      id: id ?? this.id,
      partnershipId: partnershipId ?? this.partnershipId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isRead => readAt != null;
}

/// Type of partner message
enum PartnerMessageType {
  text,
  careAction,
  cycleUpdate,
  reminder,
  supportive,
}

/// Represents a care action between partners
class CareAction {
  final String id;
  final String partnershipId;
  final String senderId;
  final String receiverId;
  final CareActionType type;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? data;

  const CareAction({
    required this.id,
    required this.partnershipId,
    required this.senderId,
    required this.receiverId,
    required this.type,
    required this.title,
    this.description,
    required this.createdAt,
    this.completedAt,
    this.data,
  });

  factory CareAction.fromJson(Map<String, dynamic> json) {
    return CareAction(
      id: json['id'] as String,
      partnershipId: json['partnershipId'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      type: CareActionType.values.byName(json['type'] as String),
      title: json['title'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partnershipId': partnershipId,
      'senderId': senderId,
      'receiverId': receiverId,
      'type': type.name,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'data': data,
    };
  }

  CareAction copyWith({
    String? id,
    String? partnershipId,
    String? senderId,
    String? receiverId,
    CareActionType? type,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? completedAt,
    Map<String, dynamic>? data,
  }) {
    return CareAction(
      id: id ?? this.id,
      partnershipId: partnershipId ?? this.partnershipId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      data: data ?? this.data,
    );
  }

  bool get isCompleted => completedAt != null;
}

/// Type of care action
enum CareActionType {
  reminder,
  support,
  gift,
  checkIn,
  symptomsHelp,
  emergency,
}
