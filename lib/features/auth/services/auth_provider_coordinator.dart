import 'package:flow_ai/core/deeplinks/pending_deep_link_service.dart';
import 'package:flow_ai/core/services/app_state_service.dart';
import 'package:flow_ai/core/services/auth_service.dart';
import 'package:flow_ai/features/settings/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

enum AuthProviderType { apple, google }

class AuthProviderCoordinator {
  AuthProviderCoordinator({AuthService? authService})
    : _authService = authService ?? AuthService();

  final AuthService _authService;

  Future<AuthResult> authenticate({
    required BuildContext context,
    required AuthProviderType provider,
  }) async {
    if (!_authService.isInitialized) {
      await _authService.initialize();
    }

    final result = switch (provider) {
      AuthProviderType.apple => await _authService.signInWithApple(),
      AuthProviderType.google => await _authService.signInWithGoogle(),
    };

    if (!context.mounted || !result.isSuccess) {
      return result;
    }

    HapticFeedback.lightImpact();

    try {
      await context.read<SettingsProvider>().forceUserDataSync();
    } catch (_) {}

    if (!context.mounted) {
      return result;
    }

    final route = await AppStateService().getPostAuthRoute(
      isNewUser: result.isNewUser,
    );

    if (!context.mounted) {
      return result;
    }

    if (route == '/home') {
      final pending = PendingDeepLinkService.consumePendingRoute();
      context.go(pending ?? '/home');
      PendingDeepLinkService.clearPendingRoute();
      return result;
    }

    context.go(route);
    return result;
  }
}
