import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/enhanced_onboarding_controller.dart';
import '../widgets/personality_quiz_widget.dart';
import '../widgets/cycle_history_import_widget.dart';
import '../widgets/goal_selection_widget.dart';
import '../widgets/privacy_preferences_widget.dart';
import '../widgets/onboarding_progress_widget.dart';
import '../../../core/ui/adaptive_components.dart';
import '../../../core/theme/app_theme.dart';

/// 🎯 Interactive Onboarding Screen - Week 2 Implementation
/// Features: Personality-based setup, cycle history import wizard, 
/// goal setting interface, privacy preference selection, and advanced personalization engine
class InteractiveOnboardingScreen extends StatefulWidget {
  const InteractiveOnboardingScreen({super.key});

  @override
  State<InteractiveOnboardingScreen> createState() => _InteractiveOnboardingScreenState();
}

class _InteractiveOnboardingScreenState extends State<InteractiveOnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    
    // Initialize onboarding controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EnhancedOnboardingController>().initialize();
    });
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EnhancedOnboardingController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: Column(
              children: [
                // Progress indicator
                _buildProgressHeader(context, controller),
                
                // Main content
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildCurrentStep(context, controller),
                    ),
                  ),
                ),
                
                // Navigation buttons
                _buildNavigationButtons(context, controller),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressHeader(BuildContext context, EnhancedOnboardingController controller) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Step indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${controller.currentStep + 1} of ${controller.steps.length}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                onPressed: () => _showSkipDialog(context, controller),
                icon: Icon(
                  Icons.close,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Progress bar
          OnboardingProgressWidget(
            progress: controller.progress,
            currentStep: controller.currentStep,
            totalSteps: controller.steps.length,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context, EnhancedOnboardingController controller) {
    final currentStepType = controller.currentStepType;
    
    switch (currentStepType) {
      case OnboardingStep.welcome:
        return _buildWelcomeStep(context, controller);
      case OnboardingStep.personalInfo:
        return _buildPersonalityQuizStep(context, controller);
      case OnboardingStep.cycleHistory:
        return _buildCycleHistoryStep(context, controller);
      case OnboardingStep.lifestyle:
        return _buildLifestyleStep(context, controller);
      case OnboardingStep.goals:
        return _buildGoalsStep(context, controller);
      case OnboardingStep.notifications:
        return _buildNotificationsStep(context, controller);
      case OnboardingStep.privacy:
        return _buildPrivacyStep(context, controller);
      case OnboardingStep.complete:
        return _buildCompleteStep(context, controller);
    }
  }

  Widget _buildWelcomeStep(BuildContext context, EnhancedOnboardingController controller) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome animation/illustration
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                  theme.colorScheme.secondary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Icon(
                Icons.favorite_border,
                size: 80,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Welcome text
          Text(
            'Welcome to ZyraFlow! 🌸',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Your intelligent companion for personalized menstrual health tracking and insights.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Features preview
          _buildFeaturesList(context),
        ],
      ),
    );
  }

  Widget _buildPersonalityQuizStep(BuildContext context, EnhancedOnboardingController controller) {
    return PersonalityQuizWidget(
      onDataChanged: (data) {
        controller.updateData(controller.data.copyWith(
          fullName: data['fullName'],
          preferredName: data['preferredName'],
          dateOfBirth: data['dateOfBirth'],
          age: data['age'],
        ));
      },
      initialData: controller.data,
    );
  }

  Widget _buildCycleHistoryStep(BuildContext context, EnhancedOnboardingController controller) {
    return CycleHistoryImportWidget(
      onDataChanged: (data) {
        controller.updateData(controller.data.copyWith(
          lastPeriodDate: data['lastPeriodDate'],
          averageCycleLength: data['averageCycleLength'],
          averagePeriodLength: data['averagePeriodLength'],
          isFirstTimeTracking: data['isFirstTimeTracking'],
          previousTrackingMethod: data['previousTrackingMethod'],
        ));
      },
      initialData: controller.data,
    );
  }

  Widget _buildLifestyleStep(BuildContext context, EnhancedOnboardingController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell us about your lifestyle',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'This helps us provide more accurate predictions and personalized insights.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Lifestyle questions will be implemented here
          _buildLifestyleQuestions(context, controller),
        ],
      ),
    );
  }

  Widget _buildGoalsStep(BuildContext context, EnhancedOnboardingController controller) {
    return GoalSelectionWidget(
      onGoalsChanged: (goals) {
        controller.updateData(controller.data.copyWith(healthGoals: goals));
      },
      initialGoals: controller.data.healthGoals,
    );
  }

  Widget _buildNotificationsStep(BuildContext context, EnhancedOnboardingController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stay on track with smart reminders',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'We\'ll send you gentle, personalized reminders to help you maintain your tracking routine.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Notification preferences
          _buildNotificationPreferences(context, controller),
        ],
      ),
    );
  }

  Widget _buildPrivacyStep(BuildContext context, EnhancedOnboardingController controller) {
    return PrivacyPreferencesWidget(
      onPrivacyChanged: (shareForResearch, enableAI) {
        controller.updateData(controller.data.copyWith(
          shareDataForResearch: shareForResearch,
          enableAIInsights: enableAI,
        ));
      },
      initialShareForResearch: controller.data.shareDataForResearch,
      initialEnableAI: controller.data.enableAIInsights,
    );
  }

  Widget _buildCompleteStep(BuildContext context, EnhancedOnboardingController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          // Success animation
          Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'You\'re all set! 🎉',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Your personalized ZyraFlow experience is ready. Let\'s start your health journey!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          // Personalization summary
          _buildPersonalizationSummary(context, controller),
          
          const SizedBox(height: 32),
          
          AdaptiveButton(
            text: 'Start Tracking',
            onPressed: () => _completeOnboarding(context, controller),
            isPrimary: true,
            isLoading: controller.isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    final features = [
      {
        'icon': Icons.analytics_outlined,
        'title': '95% Accurate AI Predictions',
        'description': 'Advanced machine learning for precise cycle forecasting',
      },
      {
        'icon': Icons.psychology_outlined,
        'title': 'Personalized Insights',
        'description': 'Tailored health recommendations based on your patterns',
      },
      {
        'icon': Icons.security,
        'title': 'Privacy-First Design',
        'description': 'Your data stays secure with end-to-end encryption',
      },
      {
        'icon': Icons.diversity_3,
        'title': 'Community Support',
        'description': 'Connect with others on similar health journeys',
      },
    ];

    return Column(
      children: features.map((feature) => Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                feature['icon'] as IconData,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature['title'] as String,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    feature['description'] as String,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildLifestyleQuestions(BuildContext context, EnhancedOnboardingController controller) {
    // This would implement lifestyle questions
    return const Placeholder(fallbackHeight: 300);
  }

  Widget _buildNotificationPreferences(BuildContext context, EnhancedOnboardingController controller) {
    // This would implement notification preferences UI
    return const Placeholder(fallbackHeight: 300);
  }

  Widget _buildPersonalizationSummary(BuildContext context, EnhancedOnboardingController controller) {
    final theme = Theme.of(context);
    final data = controller.data;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Personalized Setup',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          if (data.preferredName != null) ...[
            _buildSummaryItem(
              context,
              icon: Icons.person,
              title: 'Welcome, ${data.preferredName}!',
              subtitle: 'We\'ll use this name throughout the app',
            ),
            const SizedBox(height: 12),
          ],
          
          if (data.averageCycleLength != null) ...[
            _buildSummaryItem(
              context,
              icon: Icons.calendar_today,
              title: '${data.averageCycleLength}-day cycle',
              subtitle: 'We\'ll predict your periods with this as baseline',
            ),
            const SizedBox(height: 12),
          ],
          
          if (data.healthGoals != null) ...[
            _buildSummaryItem(
              context,
              icon: Icons.flag,
              title: 'Health Goals Set',
              subtitle: 'Personalized recommendations enabled',
            ),
            const SizedBox(height: 12),
          ],
          
          _buildSummaryItem(
            context,
            icon: Icons.security,
            title: 'Privacy Protected',
            subtitle: data.enableAIInsights 
                ? 'AI insights enabled with privacy protection'
                : 'Basic tracking mode selected',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(BuildContext context, EnhancedOnboardingController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (!controller.isFirstStep) ...[
            Expanded(
              child: AdaptiveButton(
                text: 'Back',
                onPressed: () {
                  controller.previousStep();
                  _animationController.reset();
                  _animationController.forward();
                },
                isPrimary: false,
              ),
            ),
            const SizedBox(width: 16),
          ],
          
          Expanded(
            flex: controller.isFirstStep ? 1 : 2,
            child: AdaptiveButton(
              text: _getNextButtonText(controller),
              onPressed: controller.isLoading ? null : () => _handleNextStep(context, controller),
              isPrimary: true,
              isLoading: controller.isLoading,
            ),
          ),
        ],
      ),
    );
  }

  String _getNextButtonText(EnhancedOnboardingController controller) {
    if (controller.currentStepType == OnboardingStep.complete) {
      return 'Start Tracking';
    } else if (controller.isLastStep) {
      return 'Complete Setup';
    } else {
      return 'Continue';
    }
  }

  Future<void> _handleNextStep(BuildContext context, EnhancedOnboardingController controller) async {
    if (controller.currentStepType == OnboardingStep.complete) {
      await _completeOnboarding(context, controller);
      return;
    }

    // Validate current step before proceeding
    if (_validateCurrentStep(controller)) {
      if (controller.isLastStep) {
        await controller.completeOnboarding();
      } else {
        controller.nextStep();
        _animationController.reset();
        _animationController.forward();
      }
    } else {
      _showValidationError(context, controller);
    }
  }

  bool _validateCurrentStep(EnhancedOnboardingController controller) {
    switch (controller.currentStepType) {
      case OnboardingStep.welcome:
        return true;
      case OnboardingStep.personalInfo:
        return controller.data.fullName?.isNotEmpty == true;
      case OnboardingStep.cycleHistory:
        return true; // Optional step
      case OnboardingStep.lifestyle:
        return true; // Optional step
      case OnboardingStep.goals:
        return controller.data.healthGoals != null;
      case OnboardingStep.notifications:
        return true; // Optional step
      case OnboardingStep.privacy:
        return true; // Optional step
      case OnboardingStep.complete:
        return true;
    }
  }

  void _showValidationError(BuildContext context, EnhancedOnboardingController controller) {
    String message = 'Please complete the required fields before continuing.';
    
    switch (controller.currentStepType) {
      case OnboardingStep.personalInfo:
        message = 'Please enter your name to continue.';
        break;
      case OnboardingStep.goals:
        message = 'Please select at least one health goal to continue.';
        break;
      default:
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _completeOnboarding(BuildContext context, EnhancedOnboardingController controller) async {
    try {
      await controller.completeOnboarding();
      
      if (mounted) {
        // Navigate to main app
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete onboarding: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showSkipDialog(BuildContext context, EnhancedOnboardingController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Setup?'),
        content: const Text(
          'You can always complete your profile later in settings, but we recommend finishing the setup for the best experience.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue Setup'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await controller.skipOnboarding();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/home');
              }
            },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }
}
