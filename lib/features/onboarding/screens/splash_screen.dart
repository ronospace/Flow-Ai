import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/app_state_service.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _pulseController;
  late Animation<double> _gradientAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize gradient animation controller
    _gradientController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();
    
    // Initialize pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_gradientController);
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _navigateToHome();
  }
  
  @override
  void dispose() {
    _gradientController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _navigateToHome() async {
    // Show splash for a longer duration for better branding and beautiful animation
    await Future.delayed(const Duration(seconds: 4));
    
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
    final theme = Theme.of(context);
    
    return Scaffold(
      body: AnimatedBuilder(
        animation: _gradientAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  // Transitional feminine colors that flow like a live wallpaper
                  Color.lerp(
                    AppTheme.primaryRose.withValues(alpha: 0.8),
                    AppTheme.primaryPurple.withValues(alpha: 0.9),
                    (math.sin(_gradientAnimation.value * math.pi * 2) + 1) / 2,
                  )!,
                  Color.lerp(
                    AppTheme.primaryPurple.withValues(alpha: 0.7),
                    AppTheme.secondaryBlue.withValues(alpha: 0.8),
                    (math.cos(_gradientAnimation.value * math.pi * 2 + math.pi / 3) + 1) / 2,
                  )!,
                  Color.lerp(
                    AppTheme.secondaryBlue.withValues(alpha: 0.8),
                    AppTheme.accentMint.withValues(alpha: 0.6),
                    (math.sin(_gradientAnimation.value * math.pi * 2 + math.pi / 2) + 1) / 2,
                  )!,
                  Color.lerp(
                    AppTheme.accentMint.withValues(alpha: 0.7),
                    AppTheme.primaryRose.withValues(alpha: 0.9),
                    (math.cos(_gradientAnimation.value * math.pi * 2 + math.pi) + 1) / 2,
                  )!,
                ],
                stops: const [0.0, 0.33, 0.66, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Floating particles for enhanced feminine effect
                ...List.generate(8, (index) {
                  final offset = _gradientAnimation.value * 2 * math.pi + (index * math.pi / 4);
                  return Positioned(
                    left: MediaQuery.of(context).size.width * 0.1 + 
                          (MediaQuery.of(context).size.width * 0.8) * 
                          (math.sin(offset) + 1) / 2,
                    top: MediaQuery.of(context).size.height * 0.1 + 
                         (MediaQuery.of(context).size.height * 0.8) * 
                         (math.cos(offset + index * 0.5) + 1) / 2,
                    child: Container(
                      width: 4 + (index % 3) * 2,
                      height: 4 + (index % 3) * 2,
                      decoration: BoxDecoration(
                        color: [
                          AppTheme.primaryRose.withValues(alpha: 0.3),
                          AppTheme.primaryPurple.withValues(alpha: 0.3),
                          AppTheme.accentMint.withValues(alpha: 0.3),
                        ][index % 3],
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
                
                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Pulsing App Icon with enhanced feminine design
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    theme.colorScheme.surface.withValues(alpha: 0.95),
                                    theme.colorScheme.surface.withValues(alpha: 0.85),
                                    AppTheme.primaryRose.withValues(alpha: 0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(35),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryRose.withValues(alpha: 0.3),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                    spreadRadius: 5,
                                  ),
                                  BoxShadow(
                                    color: AppTheme.primaryPurple.withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Heart icon with gradient
                                  ShaderMask(
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
                                      size: 70,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ).animate().scale(delay: 300.ms, duration: 800.ms),
                      
                      const SizedBox(height: 40),
                      
                      // App Name with enhanced styling
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white.withValues(alpha: 0.9),
                              AppTheme.accentMint.withValues(alpha: 0.8),
                            ],
                          ).createShader(bounds);
                        },
                        child: const Text(
                          'Flow Ai',
                          style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -1.5,
                            height: 1.1,
                          ),
                        ),
                      ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3, end: 0),
                      
                      const SizedBox(height: 12),
                      
                      // Enhanced tagline
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
                            fontSize: 18,
                            color: Colors.white,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ).animate().fadeIn(delay: 1200.ms).slideX(begin: 0.3, end: 0),
                      
                      const SizedBox(height: 60),
                      
                      // Enhanced loading indicator
                      Column(
                        children: [
                          const Text(
                            'Preparing your personalized experience...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: 200,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: const LinearProgressIndicator(
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 1600.ms),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
