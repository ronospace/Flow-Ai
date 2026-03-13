import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/app_localizations.dart';
import 'dart:math' as math;

/// 🚀 Auth Choice Screen - Login, or Sign Up
/// Provides users with three clear options on app launch
class AuthChoiceScreen extends StatefulWidget {
  const AuthChoiceScreen({super.key});

  @override
  State<AuthChoiceScreen> createState() => _AuthChoiceScreenState();
}

class _AuthChoiceScreenState extends State<AuthChoiceScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _contentController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 2600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    context.go('/auth/login');
  }

  void _handleSignUp() {
    context.go('/auth/signup');
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          _buildAnimatedBackground(size),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Logo and title
                  _buildHeader(),

                  const SizedBox(height: 48),

                  // Choice buttons
                  _buildChoiceButtons(localizations),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(Size size) {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  AppTheme.primaryRose.withValues(alpha: 0.8),
                  AppTheme.primaryPurple.withValues(alpha: 0.9),
                  (math.sin(_backgroundController.value * math.pi * 2) + 1) / 2,
                )!,
                Color.lerp(
                  AppTheme.primaryPurple.withValues(alpha: 0.7),
                  AppTheme.secondaryBlue.withValues(alpha: 0.8),
                  (math.cos(
                            _backgroundController.value * math.pi * 2 +
                                math.pi / 3,
                          ) +
                          1) /
                      2,
                )!,
                Color.lerp(
                  AppTheme.secondaryBlue.withValues(alpha: 0.8),
                  AppTheme.accentMint.withValues(alpha: 0.6),
                  (math.sin(
                            _backgroundController.value * math.pi * 2 +
                                math.pi / 2,
                          ) +
                          1) /
                      2,
                )!,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.white.withValues(alpha: 0.95),
                Colors.white.withValues(alpha: 0.85),
                AppTheme.primaryRose.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryRose.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
                spreadRadius: 5,
              ),
            ],
          ),
          child: ShaderMask(
            shaderCallback: (bounds) {
              return const LinearGradient(
                colors: [
                  AppTheme.primaryRose,
                  AppTheme.primaryPurple,
                  AppTheme.accentMint,
                ],
              ).createShader(bounds);
            },
            child: const Icon(
              Icons.favorite_rounded,
              size: 60,
              color: Colors.white,
            ),
          ),
        ).animate().scale(delay: 300.ms, duration: 800.ms),

        const SizedBox(height: 24),

        // App name
        ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [Colors.white, Colors.white.withValues(alpha: 0.9)],
            ).createShader(bounds);
          },
          child: const Text(
            'Flow Ai',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1.5,
            ),
          ),
        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0),

        const SizedBox(height: 12),

        // Tagline
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: const Text(
            '💫 AI-Powered Menstrual Health',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ).animate().fadeIn(delay: 900.ms).slideX(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildChoiceButtons(AppLocalizations localizations) {
    return Column(
      children: [
        // Login Button
        _buildChoiceButton(
          title: localizations.login,
          subtitle: 'Access your existing account',
          icon: Icons.login_outlined,
          gradient: const LinearGradient(
            colors: [AppTheme.primaryPurple, AppTheme.primaryRose],
          ),
          onTap: _handleLogin,
          delay: 800,
        ),

        const SizedBox(height: 24),

        // Sign Up Button
        _buildChoiceButton(
          title: localizations.signUp,
          subtitle: 'Create a new account',
          icon: Icons.person_add_outlined,
          gradient: const LinearGradient(
            colors: [AppTheme.primaryRose, AppTheme.warningOrange],
          ),
          onTap: _handleSignUp,
          delay: 1000,
        ),
      ],
    );
  }

  Widget _buildChoiceButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
    required int delay,
  }) {
    return GestureDetector(
      onTap: () {
        debugPrint('🎯 Button tapped: $title');
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  debugPrint('🎯 InkWell tapped: $title');
                  HapticFeedback.mediumImpact();
                  onTap();
                },
                borderRadius: BorderRadius.circular(24),
                splashColor: Colors.white.withValues(alpha: 0.2),
                highlightColor: Colors.white.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: gradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(icon, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.8),
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withValues(alpha: 0.6),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.3, end: 0);
  }
}
