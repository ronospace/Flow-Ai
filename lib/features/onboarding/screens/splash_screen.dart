import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/app_state_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/flow_ai_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 650),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
    );

    _entranceController.forward();
    _navigateToHome();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _navigateToHome() async {
    final minimumBrandTransition = Future<void>.delayed(
      const Duration(milliseconds: 900),
    );

    try {
      final routeFuture = AppStateService().getInitialRoute();

      final results = await Future.wait<Object?>([
        routeFuture,
        minimumBrandTransition,
      ]);

      if (!mounted) return;

      context.go(results.first! as String);
    } catch (_) {
      await minimumBrandTransition;

      if (mounted) {
        context.go('/auth/choice');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient(isDark),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FlowAiLogo(size: 120, showWordmark: false),
                    const SizedBox(height: 24),
                    Text(
                      'Flow Ai',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontFamily: 'PlayfairDisplay',
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.8,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
