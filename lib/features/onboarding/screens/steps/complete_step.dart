import 'package:flutter/material.dart';
import '../../../../core/widgets/modern_button.dart';

/// Completion step for onboarding flow
class CompleteStep extends StatefulWidget {
  final VoidCallback onGetStarted;
  
  const CompleteStep({
    super.key,
    required this.onGetStarted,
  });

  @override
  State<CompleteStep> createState() => _CompleteStepState();
}

class _CompleteStepState extends State<CompleteStep> 
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _confettiAnimation;

  @override
  void initState() {
    super.initState();
    
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _confettiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeOut,
    ));
    
    // Start animations
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _confettiController.forward();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Spacer(),
          
          // Success animation
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.check,
                size: 80,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Success message
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  children: [
                    Text(
                      'Setup Complete!',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      'Welcome to your personalized menstrual health journey',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
          
          const SizedBox(height: 40),
          
          // Feature summary
          FadeTransition(
            opacity: _confettiAnimation,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'You\'re all set with:',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildFeatureSummary(
                    context,
                    Icons.timeline,
                    'Personalized cycle tracking',
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildFeatureSummary(
                    context,
                    Icons.insights,
                    'AI-powered health insights',
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildFeatureSummary(
                    context,
                    Icons.notifications_active,
                    'Smart reminders and predictions',
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildFeatureSummary(
                    context,
                    Icons.security,
                    'Private and secure data',
                  ),
                ],
              ),
            ),
          ),
          
          const Spacer(),
          
          // Get started button
          AnimatedBuilder(
            animation: _confettiAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * _confettiAnimation.value),
                child: SizedBox(
                  width: double.infinity,
                  child: ModernButton(
                    text: 'Start Tracking',
                    onPressed: widget.onGetStarted,
                    type: ModernButtonType.primary,
                    size: ModernButtonSize.large,
                    icon: Icons.arrow_forward,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // Additional message
          FadeTransition(
            opacity: _confettiAnimation,
            child: Text(
              'You can always update your preferences in Settings',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFeatureSummary(
    BuildContext context,
    IconData icon,
    String text,
  ) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Icon(
          Icons.check_circle,
          size: 16,
          color: theme.colorScheme.primary,
        ),
      ],
    );
  }
}
