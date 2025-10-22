/// Core user model
class User {
  final String id;
  final String email;
  final String name;
  final String? uid;  // Add uid for backward compatibility
  final String? displayName;  // Add displayName for tests
  final DateTime createdAt;
  final String? profileImageUrl;
  final Map<String, dynamic>? metadata;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.uid,
    this.displayName,
    required this.createdAt,
    this.profileImageUrl,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'uid': uid ?? id,
      'displayName': displayName ?? name,
      'created_at': createdAt.toIso8601String(),
      'profile_image_url': profileImageUrl,
      'metadata': metadata,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      uid: json['uid'],
      displayName: json['displayName'],
      createdAt: DateTime.parse(json['created_at']),
      profileImageUrl: json['profile_image_url'],
      metadata: json['metadata'],
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? uid,
    String? displayName,
    DateTime? createdAt,
    String? profileImageUrl,
    Map<String, dynamic>? metadata,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Add static email validation method for tests
  static bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    return emailRegExp.hasMatch(email);
  }
}
