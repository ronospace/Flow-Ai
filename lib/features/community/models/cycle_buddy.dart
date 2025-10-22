/// Cycle buddy model for community matching
class CycleBuddy {
  final String id;
  final String userId;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final int age;
  final String location;
  final List<String> interests;
  final List<String> commonSymptoms;
  final int cycleLength;
  final int? lutealPhaseLength;
  final bool isCurrentBuddy;
  final double compatibilityScore;
  final DateTime? lastActiveAt;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CycleBuddy({
    required this.id,
    required this.userId,
    required this.username,
    this.displayName,
    this.avatarUrl,
    required this.age,
    required this.location,
    this.interests = const [],
    this.commonSymptoms = const [],
    required this.cycleLength,
    this.lutealPhaseLength,
    this.isCurrentBuddy = false,
    this.compatibilityScore = 0.0,
    this.lastActiveAt,
    this.preferences = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  CycleBuddy copyWith({
    String? id,
    String? userId,
    String? username,
    String? displayName,
    String? avatarUrl,
    int? age,
    String? location,
    List<String>? interests,
    List<String>? commonSymptoms,
    int? cycleLength,
    int? lutealPhaseLength,
    bool? isCurrentBuddy,
    double? compatibilityScore,
    DateTime? lastActiveAt,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CycleBuddy(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      age: age ?? this.age,
      location: location ?? this.location,
      interests: interests ?? this.interests,
      commonSymptoms: commonSymptoms ?? this.commonSymptoms,
      cycleLength: cycleLength ?? this.cycleLength,
      lutealPhaseLength: lutealPhaseLength ?? this.lutealPhaseLength,
      isCurrentBuddy: isCurrentBuddy ?? this.isCurrentBuddy,
      compatibilityScore: compatibilityScore ?? this.compatibilityScore,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get effectiveDisplayName => displayName ?? username;

  bool get isActive {
    if (lastActiveAt == null) return false;
    return DateTime.now().difference(lastActiveAt!).inHours < 24;
  }

  String get activityStatus {
    if (lastActiveAt == null) return 'Never active';
    final difference = DateTime.now().difference(lastActiveAt!);
    
    if (difference.inMinutes < 5) return 'Online now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${difference.inDays ~/ 7}w ago';
  }

  String get compatibilityText {
    if (compatibilityScore >= 0.9) return 'Excellent match';
    if (compatibilityScore >= 0.8) return 'Great match';
    if (compatibilityScore >= 0.7) return 'Good match';
    if (compatibilityScore >= 0.6) return 'Fair match';
    return 'Low compatibility';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'age': age,
      'location': location,
      'interests': interests,
      'commonSymptoms': commonSymptoms,
      'cycleLength': cycleLength,
      'lutealPhaseLength': lutealPhaseLength,
      'isCurrentBuddy': isCurrentBuddy,
      'compatibilityScore': compatibilityScore,
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'preferences': preferences,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CycleBuddy.fromJson(Map<String, dynamic> json) {
    return CycleBuddy(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      age: json['age'] as int,
      location: json['location'] as String,
      interests: List<String>.from(json['interests'] as List? ?? []),
      commonSymptoms: List<String>.from(json['commonSymptoms'] as List? ?? []),
      cycleLength: json['cycleLength'] as int,
      lutealPhaseLength: json['lutealPhaseLength'] as int?,
      isCurrentBuddy: json['isCurrentBuddy'] as bool? ?? false,
      compatibilityScore: json['compatibilityScore'] as double? ?? 0.0,
      lastActiveAt: json['lastActiveAt'] != null
          ? DateTime.parse(json['lastActiveAt'] as String)
          : null,
      preferences: json['preferences'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CycleBuddy && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CycleBuddy(id: $id, username: $username, compatibility: $compatibilityScore)';
  }
}

/// Buddy request model
class BuddyRequest {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String fromUsername;
  final String? fromDisplayName;
  final String? fromAvatarUrl;
  final String message;
  final String status; // pending, accepted, declined
  final DateTime createdAt;
  final DateTime? respondedAt;

  const BuddyRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.fromUsername,
    this.fromDisplayName,
    this.fromAvatarUrl,
    required this.message,
    this.status = 'pending',
    required this.createdAt,
    this.respondedAt,
  });

  BuddyRequest copyWith({
    String? id,
    String? fromUserId,
    String? toUserId,
    String? fromUsername,
    String? fromDisplayName,
    String? fromAvatarUrl,
    String? message,
    String? status,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) {
    return BuddyRequest(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      fromUsername: fromUsername ?? this.fromUsername,
      fromDisplayName: fromDisplayName ?? this.fromDisplayName,
      fromAvatarUrl: fromAvatarUrl ?? this.fromAvatarUrl,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }

  String get senderName => fromDisplayName ?? fromUsername;
  
  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isDeclined => status == 'declined';

  String get timeAgoText {
    final difference = DateTime.now().difference(createdAt);
    
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${difference.inDays ~/ 7}w ago';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'fromUsername': fromUsername,
      'fromDisplayName': fromDisplayName,
      'fromAvatarUrl': fromAvatarUrl,
      'message': message,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }

  factory BuddyRequest.fromJson(Map<String, dynamic> json) {
    return BuddyRequest(
      id: json['id'] as String,
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      fromUsername: json['fromUsername'] as String,
      fromDisplayName: json['fromDisplayName'] as String?,
      fromAvatarUrl: json['fromAvatarUrl'] as String?,
      message: json['message'] as String,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['createdAt'] as String),
      respondedAt: json['respondedAt'] != null
          ? DateTime.parse(json['respondedAt'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BuddyRequest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BuddyRequest(id: $id, from: $fromUsername, status: $status)';
  }
}
