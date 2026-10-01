import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/core/services/production_analytics_service.dart',
  ).readAsStringSync();

  test('production analytics never restores a previous account implicitly', () {
    expect(source, contains('_userId = userId;'));
    expect(
      source,
      isNot(contains('_userId = userId ?? _prefs?.getString(_keyUserId)')),
    );
  });

  test('authenticated account changes clear prior attributed events', () {
    expect(
      source,
      contains('Future<void> setAuthenticatedUser(String? userId)'),
    );
    expect(source, contains('if (_userId == userId) return;'));
    expect(source, contains('await _prefs?.remove(_keyAppEvents);'));
    expect(source, contains('await _prefs?.remove(_keySessionData);'));
    expect(
      source,
      isNot(contains("static const String _keyUserId")),
      reason: 'Raw analytics user identity must never be persisted.',
    );
    expect(
      source,
      isNot(contains('setString(_keyUserId')),
      reason: 'Raw analytics user identity must never enter local storage.',
    );
    expect(source, contains('_userId = userId;'));
  });

  test('privacy clear removes persisted analytics identity', () {
    final clearStart = source.indexOf(
      'Future<void> clearAnalyticsData() async',
    );
    expect(clearStart, greaterThanOrEqualTo(0));

    final clearBlock = source.substring(
      clearStart,
      (clearStart + 500).clamp(0, source.length),
    );

    expect(clearBlock, contains('remove(_keyAppEvents)'));
    expect(clearBlock, contains('remove(_keySessionData)'));
    expect(clearBlock, contains('_userId = null'));
    expect(
      source,
      isNot(contains("static const String _keyUserId")),
      reason: 'Privacy design must not create a persisted analytics identity.',
    );
  });

  test('AuthService binds analytics at central account boundaries', () {
    final auth = File('lib/core/services/auth_service.dart').readAsStringSync();

    final storePos = auth.indexOf(
      'Future<void> _storeUserData(Map<String, dynamic> userData)',
    );
    expect(storePos, greaterThanOrEqualTo(0));

    final storeBlock = auth.substring(
      storePos,
      (storePos + 700).clamp(0, auth.length),
    );

    expect(
      storeBlock,
      contains("ProductionAnalyticsService().setAuthenticatedUser("),
    );
    expect(storeBlock, contains("userData['uid']?.toString()"));

    final clearPos = auth.indexOf('Future<void> _clearAllUserData() async');
    expect(clearPos, greaterThanOrEqualTo(0));

    final clearBlock = auth.substring(
      clearPos,
      (clearPos + 500).clamp(0, auth.length),
    );

    expect(
      clearBlock,
      contains('ProductionAnalyticsService().setAuthenticatedUser(null)'),
    );
  });

  test('AuthService reconciles analytics scope during startup', () {
    final auth = File('lib/core/services/auth_service.dart').readAsStringSync();

    expect(auth, contains('Future<void> _syncAnalyticsAccountScope() async'));
    expect(auth, contains('final account = await getCurrentUser();'));
    expect(auth, contains('account?.uid?.toString()'));

    final initPos = auth.indexOf('Future<void> initialize() async');
    expect(initPos, greaterThanOrEqualTo(0));

    final initBlock = auth.substring(
      initPos,
      (initPos + 2800).clamp(0, auth.length),
    );

    expect(
      RegExp(
        r'_isInitialized = true;\s*'
        r'await _syncAnalyticsAccountScope\(\);',
      ).allMatches(initBlock).length,
      greaterThanOrEqualTo(2),
    );
  });
}
