import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/app_state_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    // Show splash for a minimum of 2 seconds for branding
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      try {
        // Determine the appropriate route based on user state
        final route = await AppStateService().getInitialRoute();
        debugPrint('🚀 Navigating to: $route');
        
        if (mounted) {
          context.go(route);
        }
      } catch (e) {
        debugPrint('❌ Error determining route: $e');
        // Fallback to auth screen
        if (mounted) {
          context.go('/auth');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  size: 60,
                  color: AppTheme.primaryRose,
                ),
              ).animate().scale(delay: 300.ms, duration: 600.ms),
              
              const SizedBox(height: 30),
              
              // App Name
              const Text(
                'CycleAI',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: 10),
              
              // Tagline
              const Text(
                'AI-Powered Period Tracking',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  letterSpacing: 0.5,
                ),
              ).animate().fadeIn(delay: 900.ms),
              
              const SizedBox(height: 50),
              
              // Loading indicator
              const SizedBox(
                width: 60,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white30,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ).animate().fadeIn(delay: 1200.ms),
            ],
          ),
        ),
      ),
    );
  }
}
