/// Authentication result model for handling login/signup responses
class AuthResult {
  final bool success;
  final String? userId;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? accessToken;
  final String? refreshToken;
  final String? error;
  final AuthProvider provider;
  final Map<String, dynamic>? additionalData;
  final DateTime timestamp;

  AuthResult({
    required this.success,
    this.userId,
    this.email,
    this.displayName,
    this.photoUrl,
    this.accessToken,
    this.refreshToken,
    this.error,
    this.provider = AuthProvider.local,
    this.additionalData,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Factory constructor for successful authentication
  factory AuthResult.success({
    required String userId,
    required AuthProvider provider,
    String? email,
    String? displayName,
    String? photoUrl,
    String? accessToken,
    String? refreshToken,
    Map<String, dynamic>? additionalData,
  }) {
    return AuthResult(
      success: true,
      userId: userId,
      provider: provider,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      accessToken: accessToken,
      refreshToken: refreshToken,
      additionalData: additionalData,
    );
  }

  /// Factory constructor for failed authentication
  factory AuthResult.failure({
    required String error,
    AuthProvider provider = AuthProvider.local,
    Map<String, dynamic>? additionalData,
  }) {
    return AuthResult(
      success: false,
      error: error,
      provider: provider,
      additionalData: additionalData,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'userId': userId,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'error': error,
      'provider': provider.name,
      'additionalData': additionalData,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create from JSON
  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      success: json['success'] ?? false,
      userId: json['userId'],
      email: json['email'],
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      error: json['error'],
      provider: AuthProvider.values.firstWhere(
        (p) => p.name == json['provider'],
        orElse: () => AuthProvider.local,
      ),
      additionalData: json['additionalData'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  /// Copy with new values
  AuthResult copyWith({
    bool? success,
    String? userId,
    String? email,
    String? displayName,
    String? photoUrl,
    String? accessToken,
    String? refreshToken,
    String? error,
    AuthProvider? provider,
    Map<String, dynamic>? additionalData,
    DateTime? timestamp,
  }) {
    return AuthResult(
      success: success ?? this.success,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      error: error ?? this.error,
      provider: provider ?? this.provider,
      additionalData: additionalData ?? this.additionalData,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'AuthResult(success: $success, userId: $userId, provider: $provider, error: $error)';
  }
}

/// Authentication providers
enum AuthProvider {
  local,
  firebase,
  apple,
  google,
  facebook,
}
