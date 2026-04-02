
class User {
  final String id;
  final String email;
  final String name;
  final String? uid;
  final String? displayName;
  final DateTime createdAt;
  final String? profileImageUrl;
  final Map<String,dynamic>? metadata;

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

  factory User.fromJson(Map<String,dynamic> json) => User(
    id: json['id'] ?? '',
    email: json['email'] ?? '',
    name: json['name'] ?? '',
    uid: json['uid'],
    displayName: json['displayName'],
    createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    profileImageUrl: json['profileImageUrl'],
    metadata: json['metadata'],
  );

  Map<String,dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'uid': uid,
    'displayName': displayName,
    'createdAt': createdAt.toIso8601String(),
    'profileImageUrl': profileImageUrl,
    'metadata': metadata,
  };
}
