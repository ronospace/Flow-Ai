import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// Basic user service for user management and session handling
class UserService {
  static UserService? _instance;
  static UserService get instance {
    _instance ??= UserService._internal();
    return _instance!;
  }

  UserService._internal();

  SharedPreferences? _prefs;
  User? _currentUser;
  bool _isInitialized = false;

  /// Initialize the user service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadCurrentUser();
      _isInitialized = true;
      debugPrint('👤 User service initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize user service: $e');
    }
  }

  /// Get current user
  User? get currentUser => _currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => _currentUser != null;

  /// Set current user
  Future<void> setCurrentUser(User user) async {
    _currentUser = user;
    await _saveCurrentUser();
    debugPrint('👤 User set: ${user.id}');
  }

  /// Clear current user (logout)
  Future<void> clearCurrentUser() async {
    _currentUser = null;
    await _prefs?.remove('current_user');
    debugPrint('👤 User cleared');
  }

  /// Load current user from storage
  Future<void> _loadCurrentUser() async {
    try {
      final String? userJson = _prefs?.getString('current_user');
      if (userJson != null) {
        // In a real app, you would deserialize the user from JSON
        // For now, create a mock user
        _currentUser = User(
          id: 'mock_user_123',
          email: 'user@example.com',
          name: 'Mock User',
          createdAt: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('⚠️ Failed to load current user: $e');
    }
  }

  /// Save current user to storage
  Future<void> _saveCurrentUser() async {
    try {
      if (_currentUser != null) {
        // In a real app, you would serialize the user to JSON
        await _prefs?.setString('current_user', _currentUser!.id);
      }
    } catch (e) {
      debugPrint('⚠️ Failed to save current user: $e');
    }
  }
}

/// Basic user model
class User {
  final String id;
  final String email;
  final String name;
  final DateTime createdAt;
  final String? profileImageUrl;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
    this.profileImageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'profile_image_url': profileImageUrl,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
      profileImageUrl: json['profile_image_url'],
    );
  }
}
