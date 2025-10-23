import 'package:flutter/material.dart';
import '../models/onboarding_data.dart';

/// Progress indicator for onboarding steps
class OnboardingProgress extends StatelessWidget {
  final OnboardingStep currentStep;
  final Function(OnboardingStep)? onStepTap;

  const OnboardingProgress({
    super.key,
    required this.currentStep,
    this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = OnboardingStep.values.where((step) => 
      step != OnboardingStep.welcome && step != OnboardingStep.complete).toList();
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Progress bar
          Row(
            children: [
              Text(
                'Step ${currentStep.index} of ${steps.length}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                '${(currentStep.progress * 100).round()}%',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: currentStep.progress,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              minHeight: 6,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Step indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: steps.map((step) {
              final isCurrentStep = step == currentStep;
              final isCompletedStep = step.index < currentStep.index;
              final isAccessible = step.index <= currentStep.index;
              
              return GestureDetector(
                onTap: isAccessible ? () => onStepTap?.call(step) : null,
                child: _StepIndicator(
                  step: step,
                  isActive: isCurrentStep,
                  isCompleted: isCompletedStep,
                  isAccessible: isAccessible,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final OnboardingStep step;
  final bool isActive;
  final bool isCompleted;
  final bool isAccessible;

  const _StepIndicator({
    required this.step,
    required this.isActive,
    required this.isCompleted,
    required this.isAccessible,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color getColor() {
      if (isCompleted) return theme.colorScheme.primary;
      if (isActive) return theme.colorScheme.primary;
      return theme.colorScheme.outline;
    }
    
    Color getBackgroundColor() {
      if (isCompleted) return theme.colorScheme.primaryContainer;
      if (isActive) return theme.colorScheme.primaryContainer;
      return theme.colorScheme.surface;
    }
    
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: getBackgroundColor(),
            shape: BoxShape.circle,
            border: Border.all(
              color: getColor(),
              width: 2,
            ),
          ),
          child: Icon(
            isCompleted ? Icons.check : step.icon,
            color: getColor(),
            size: 20,
          ),
        ),
        
        const SizedBox(height: 8),
        
        SizedBox(
          width: 60,
          child: Text(
            step.title.split(' ').first, // First word only
            style: theme.textTheme.labelSmall?.copyWith(
              color: isAccessible ? getColor() : theme.colorScheme.outline,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
