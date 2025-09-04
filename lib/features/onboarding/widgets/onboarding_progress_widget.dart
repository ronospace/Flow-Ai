import 'package:flutter/material.dart';

/// 📊 Onboarding Progress Widget - Visual Progress Tracking System
/// Features: Step indicators, progress bar, completion animation,
/// step navigation, and adaptive progress visualization
class OnboardingProgressWidget extends StatefulWidget {
  final double progress;
  final int currentStep;
  final int totalSteps;
  final List<String>? stepTitles;
  final bool showStepNumbers;
  final Color? primaryColor;
  final Color? backgroundColor;

  const OnboardingProgressWidget({
    super.key,
    required this.progress,
    required this.currentStep,
    required this.totalSteps,
    this.stepTitles,
    this.showStepNumbers = true,
    this.primaryColor,
    this.backgroundColor,
  });

  @override
  State<OnboardingProgressWidget> createState() => _OnboardingProgressWidgetState();
}

class _OnboardingProgressWidgetState extends State<OnboardingProgressWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticInOut,
    ));

    _pulseController.repeat(reverse: true);
    _updateProgress();
  }

  void _updateProgress() {
    _progressController.animateTo(widget.progress);
  }

  @override
  void didUpdateWidget(OnboardingProgressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _updateProgress();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = widget.primaryColor ?? theme.colorScheme.primary;
    final backgroundColor = widget.backgroundColor ?? theme.colorScheme.surface;

    return Column(
      children: [
        // Main progress bar
        _buildMainProgressBar(context, primaryColor, backgroundColor),
        
        const SizedBox(height: 16),
        
        // Step indicators
        _buildStepIndicators(context, primaryColor, backgroundColor),
        
        if (widget.stepTitles != null) ...[
          const SizedBox(height: 12),
          _buildStepTitle(context),
        ],
      ],
    );
  }

  Widget _buildMainProgressBar(BuildContext context, Color primaryColor, Color backgroundColor) {
    final theme = Theme.of(context);
    
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _progressAnimation.value * widget.progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    primaryColor.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepIndicators(BuildContext context, Color primaryColor, Color backgroundColor) {
    return Row(
      children: List.generate(widget.totalSteps, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: index == 0 || index == widget.totalSteps - 1 ? 0 : 4,
            ),
            child: _buildStepIndicator(
              context,
              index,
              primaryColor,
              backgroundColor,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStepIndicator(
    BuildContext context,
    int stepIndex,
    Color primaryColor,
    Color backgroundColor,
  ) {
    final theme = Theme.of(context);
    final isCompleted = stepIndex < widget.currentStep;
    final isCurrent = stepIndex == widget.currentStep;
    final isFuture = stepIndex > widget.currentStep;

    Color indicatorColor;
    Color textColor;
    IconData? icon;
    
    if (isCompleted) {
      indicatorColor = primaryColor;
      textColor = Colors.white;
      icon = Icons.check;
    } else if (isCurrent) {
      indicatorColor = primaryColor;
      textColor = Colors.white;
    } else {
      indicatorColor = theme.colorScheme.outline.withValues(alpha: 0.3);
      textColor = theme.colorScheme.onSurface.withValues(alpha: 0.5);
    }

    Widget indicatorChild;
    
    if (icon != null) {
      indicatorChild = Icon(
        icon,
        color: textColor,
        size: 16,
      );
    } else if (widget.showStepNumbers) {
      indicatorChild = Text(
        '${stepIndex + 1}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      indicatorChild = Container();
    }

    Widget indicator = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: indicatorColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: isCurrent
              ? primaryColor
              : theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Center(child: indicatorChild),
    );

    if (isCurrent) {
      indicator = AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: indicator,
          );
        },
      );
    }

    return Column(
      children: [
        indicator,
        
        if (widget.stepTitles != null && stepIndex < widget.stepTitles!.length) ...[
          const SizedBox(height: 8),
          Text(
            widget.stepTitles![stepIndex],
            style: theme.textTheme.bodySmall?.copyWith(
              color: isCurrent
                  ? primaryColor
                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildStepTitle(BuildContext context) {
    if (widget.stepTitles == null || widget.currentStep >= widget.stepTitles!.length) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final currentTitle = widget.stepTitles![widget.currentStep];
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.5),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        currentTitle,
        key: ValueKey(currentTitle),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Enhanced Progress Widget with Additional Features
class EnhancedOnboardingProgressWidget extends StatelessWidget {
  final double progress;
  final int currentStep;
  final int totalSteps;
  final List<String> stepTitles;
  final VoidCallback? onStepTap;
  final bool allowStepNavigation;
  final Color? accentColor;

  const EnhancedOnboardingProgressWidget({
    super.key,
    required this.progress,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitles,
    this.onStepTap,
    this.allowStepNavigation = false,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = accentColor ?? theme.colorScheme.primary;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              Text(
                '${(progress * 100).round()}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Progress visualization
          OnboardingProgressWidget(
            progress: progress,
            currentStep: currentStep,
            totalSteps: totalSteps,
            stepTitles: stepTitles,
            primaryColor: primaryColor,
          ),
          
          const SizedBox(height: 16),
          
          // Progress details
          _buildProgressDetails(context, theme, primaryColor),
        ],
      ),
    );
  }

  Widget _buildProgressDetails(BuildContext context, ThemeData theme, Color primaryColor) {
    final completedSteps = currentStep;
    final remainingSteps = totalSteps - currentStep - 1;
    
    return Row(
      children: [
        Expanded(
          child: _buildProgressStat(
            context,
            icon: Icons.check_circle,
            label: 'Completed',
            value: '$completedSteps',
            color: Colors.green,
          ),
        ),
        
        Expanded(
          child: _buildProgressStat(
            context,
            icon: Icons.radio_button_checked,
            label: 'Current',
            value: stepTitles[currentStep].split(' ').first,
            color: primaryColor,
          ),
        ),
        
        Expanded(
          child: _buildProgressStat(
            context,
            icon: Icons.pending,
            label: 'Remaining',
            value: '$remainingSteps',
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressStat(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        
        const SizedBox(height: 4),
        
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
