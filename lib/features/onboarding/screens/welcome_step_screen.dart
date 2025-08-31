import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/app_localizations.dart';

class WelcomeStepScreen extends StatelessWidget {
  final VoidCallback? onNext;

  const WelcomeStepScreen({super.key, this.onNext});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.backgroundGradient(theme.brightness == Brightness.dark),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated logo/icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryPurple.withValues(alpha: 0.2),
                    AppTheme.primaryRose.withValues(alpha: 0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryPurple, AppTheme.primaryRose],
                  ),
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  size: 40,
                  color: theme.brightness == Brightness.dark 
                      ? Colors.white 
                      : Colors.white,
                ),
              ),
            ).animate()
                .scale(duration: 800.ms)
                .shimmer(delay: 1000.ms, duration: 2000.ms),

            const SizedBox(height: 40),

            // Welcome title
            Text(
              'Welcome to Flow Ai! 🌸',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : AppTheme.darkGrey,
              ),
              textAlign: TextAlign.center,
            ).animate(delay: 200.ms)
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 16),

            // Subtitle
            Text(
              'Your intelligent period and health tracking companion',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.brightness == Brightness.dark
                    ? Colors.white70
                    : AppTheme.mediumGrey,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ).animate(delay: 400.ms)
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 40),

            // Features highlight
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.1 : 0.9,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: AppTheme.primaryPurple,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'What you\'ll get:',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white
                              : AppTheme.darkGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ..._buildFeatureList(theme).map((feature) {
                    final index = _buildFeatureList(theme).indexOf(feature);
                    return feature.animate(delay: Duration(milliseconds: 600 + (index * 100)))
                        .fadeIn()
                        .slideX(begin: 0.3, end: 0);
                  }),
                ],
              ),
            ).animate(delay: 500.ms)
                .fadeIn()
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 40),

            // Get started button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRose,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                ),
                child: Text(
                  'Let\'s Get Started 🚀',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ).animate(delay: 1000.ms)
                .fadeIn()
                .slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFeatureList(ThemeData theme) {
    final features = [
      {'icon': Icons.psychology, 'text': 'AI-powered cycle predictions'},
      {'icon': Icons.health_and_safety, 'text': 'Comprehensive symptom tracking'},
      {'icon': Icons.insights, 'text': 'Personalized health insights'},
      {'icon': Icons.privacy_tip, 'text': 'Privacy-first data protection'},
    ];

    return features.map((feature) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                feature['icon'] as IconData,
                color: AppTheme.primaryPurple,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                feature['text'] as String,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white70
                      : AppTheme.mediumGrey,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
