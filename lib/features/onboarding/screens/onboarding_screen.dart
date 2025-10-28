import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../providers/onboarding_provider.dart';
import '../models/onboarding_step.dart';
import '../widgets/onboarding_page.dart';
import '../widgets/setup_form.dart';
import '../../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../../../generated/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
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
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Stack(
              children: [
                // Background gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.backgroundGradient(
                      theme.brightness == Brightness.dark,
                    ),
                  ),
                ),
                // Content
                Column(
                  children: [
                    // Progress indicator
                    _buildProgressIndicator(provider, theme),
                    // Page content
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          provider.setCurrentStep(index);
                          _animationController.reset();
                          _animationController.forward();
                        },
                        itemCount: provider.steps.length,
                        itemBuilder: (context, index) {
                          final step = provider.steps[index];
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: _buildStepContent(step, provider, theme, localizations),
                            ),
                          );
                        },
                      ),
                    ),
                    // Navigation buttons
                    _buildNavigationButtons(provider, theme, localizations),
                  ],
                ),
                // Loading overlay
                if (provider.isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(OnboardingProvider provider, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Skip button
          TextButton(
            onPressed: () => _skipOnboarding(provider),
            child: Text(
              'Skip',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          const Spacer(),
          // Progress dots
          Row(
            children: List.generate(
              provider.steps.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 8,
                width: index == provider.currentStep ? 24 : 8,
                decoration: BoxDecoration(
                  color: index == provider.currentStep
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const Spacer(),
          // Current step indicator
          Text(
            '${provider.currentStep + 1}/${provider.steps.length}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(
    OnboardingStep step,
    OnboardingProvider provider,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    if (step.type == OnboardingStepType.setup) {
      return SetupForm(
        onSave: (data) => _handleSetupSave(provider, data),
      );
    }
    
    return OnboardingPage(
      step: step,
      onPermissionRequest: () => _handlePermissionRequest(provider, step),
    );
  }

  Widget _buildNavigationButtons(
    OnboardingProvider provider,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back button
          if (!provider.isFirstStep)
            Expanded(
              child: OutlinedButton(
                onPressed: () => _previousStep(provider),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: theme.colorScheme.primary),
                ),
                child: Text(
                  localizations.previous,
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
            ),
          if (!provider.isFirstStep) const SizedBox(width: 12),
          // Next/Complete button
          Expanded(
            flex: provider.isFirstStep ? 1 : 1,
            child: ElevatedButton(
              onPressed: () => _nextStep(provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                provider.isLastStep ? localizations.getStarted : localizations.next,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep(OnboardingProvider provider) {
    if (provider.isLastStep) {
      _completeOnboarding(provider);
    } else {
      provider.nextStep();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep(OnboardingProvider provider) {
    provider.previousStep();
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding(OnboardingProvider provider) async {
    try {
      await provider.completeOnboarding();
      
      // Schedule welcome notification safely
      try {
        await provider.scheduleWelcomeNotification();
      } catch (notifError) {
        debugPrint('Warning: Could not schedule welcome notification: $notifError');
        // Continue anyway - notification failure shouldn't block completion
      }
      
      if (mounted) {
        // Add a small delay to ensure all services are ready
        await Future.delayed(const Duration(milliseconds: 100));
        
        if (mounted) {
          try {
            context.go('/home');
          } catch (navError) {
            debugPrint('Navigation error: $navError');
            // If navigation fails, try replacing current route
            if (mounted) {
              context.pushReplacement('/home');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Onboarding completion error: $e');
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        _showErrorMessage('${localizations.error}: $e');
      }
    }
  }

  Future<void> _skipOnboarding(OnboardingProvider provider) async {
    final localizations = AppLocalizations.of(context);
    final shouldSkip = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.skipForNow),
        content: const Text(
          'Are you sure you want to skip the setup? You can always change these settings later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(localizations.skipForNow),
          ),
        ],
      ),
    );

    if (shouldSkip == true) {
      await provider.skipOnboarding();
      if (mounted) {
        context.go('/home');
      }
    }
  }

  Future<void> _handlePermissionRequest(
    OnboardingProvider provider,
    OnboardingStep step,
  ) async {
    if (step.data?['permission'] == 'notifications') {
      final granted = await provider.requestNotificationPermission();
      if (granted && mounted) {
        final localizations = AppLocalizations.of(context);
        HapticFeedback.lightImpact();
        _showSuccessMessage('${localizations.notifications} ${localizations.success.toLowerCase()}!');
      }
    }
  }

  Future<void> _handleSetupSave(
    OnboardingProvider provider,
    Map<String, dynamic> data,
  ) async {
    try {
      await provider.saveUserPreferences(
        averageCycleLength: data['cycleLength'] ?? 28,
        averagePeriodLength: data['periodLength'] ?? 5,
        trackingGoals: List<String>.from(data['goals'] ?? []),
        reminderSettings: Map<String, bool>.from(data['reminders'] ?? {}),
      );
      
      // Handle demo data if enabled
      final useDemoData = data['useDemoData'] ?? false;
      if (useDemoData) {
        provider.setUseDemoData(true);
        if (mounted) {
          _showSuccessMessage('Demo data loaded! Explore the app with sample cycle data.');
        }
      }
      
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        HapticFeedback.lightImpact();
        if (!useDemoData) {
          _showSuccessMessage('${localizations.success}!');
        }
      }
    } catch (e) {
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        _showErrorMessage('${localizations.error}: $e');
      }
    }
  }
  
  /// Helper method to show success messages (works with both Material and Cupertino)
  void _showSuccessMessage(String message) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // Fallback to debug print if ScaffoldMessenger is not available
      debugPrint('Success: $message');
    }
  }
  
  /// Helper method to show error messages (works with both Material and Cupertino)
  void _showErrorMessage(String message) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // Fallback to debug print if ScaffoldMessenger is not available
      debugPrint('Error: $message');
    }
  }
}
