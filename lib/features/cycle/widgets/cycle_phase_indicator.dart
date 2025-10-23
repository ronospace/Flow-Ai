import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/cycle_data.dart';

class CyclePhaseIndicator extends StatelessWidget {
  final CyclePhase phase;
  final int currentDay;
  final int cycleLength;
  final bool isCompact;

  const CyclePhaseIndicator({
    super.key,
    required this.phase,
    required this.currentDay,
    required this.cycleLength,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final phaseInfo = _getPhaseInfo(phase);
    final progress = _calculateProgress();

    if (isCompact) {
      return _buildCompactIndicator(phaseInfo, progress);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            phaseInfo.color.withValues(alpha: 0.1),
            phaseInfo.color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: phaseInfo.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phase header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: phaseInfo.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    phaseInfo.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phaseInfo.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: phaseInfo.color,
                      ),
                    ),
                    Text(
                      'Day $currentDay of $cycleLength',
                      style: TextStyle(
                        color: AppTheme.mediumGrey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Progress circle
              SizedBox(
                width: 50,
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      backgroundColor: phaseInfo.color.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation(phaseInfo.color),
                      strokeWidth: 4,
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: phaseInfo.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            phaseInfo.description,
            style: TextStyle(
              color: AppTheme.mediumGrey,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Phase Progress',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: phaseInfo.color,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: phaseInfo.color.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation(phaseInfo.color),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildCompactIndicator(PhaseInfo phaseInfo, double progress) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: phaseInfo.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: phaseInfo.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            phaseInfo.emoji,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Text(
            phaseInfo.name,
            style: TextStyle(
              color: phaseInfo.color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 30,
            height: 4,
            decoration: BoxDecoration(
              color: phaseInfo.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              widthFactor: progress,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: phaseInfo.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateProgress() {
    final phaseRange = _getPhaseRange(phase, cycleLength);
    final dayInPhase = currentDay - phaseRange.start + 1;
    final phaseDuration = phaseRange.end - phaseRange.start + 1;
    
    return (dayInPhase / phaseDuration).clamp(0.0, 1.0);
  }

  PhaseRange _getPhaseRange(CyclePhase phase, int cycleLength) {
    switch (phase) {
      case CyclePhase.menstrual:
        return PhaseRange(1, 7);
      case CyclePhase.follicular:
        return PhaseRange(8, cycleLength ~/ 2);
      case CyclePhase.ovulation:
        return PhaseRange((cycleLength ~/ 2) + 1, (cycleLength ~/ 2) + 3);
      case CyclePhase.luteal:
        return PhaseRange((cycleLength ~/ 2) + 4, cycleLength);
      case CyclePhase.unknown:
        return PhaseRange(1, cycleLength);
    }
  }

  PhaseInfo _getPhaseInfo(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return PhaseInfo(
          name: 'Menstrual',
          emoji: '🩸',
          color: AppTheme.primaryRose,
          description: 'Your period is here. Focus on rest and self-care.',
        );
      case CyclePhase.follicular:
        return PhaseInfo(
          name: 'Follicular',
          emoji: '🌱',
          color: AppTheme.accentMint,
          description: 'Your energy is building. Great time to start new projects.',
        );
      case CyclePhase.ovulation:
        return PhaseInfo(
          name: 'Ovulation',
          emoji: '🥚',
          color: AppTheme.secondaryBlue,
          description: 'Peak fertility window. You may feel more social and confident.',
        );
      case CyclePhase.luteal:
        return PhaseInfo(
          name: 'Luteal',
          emoji: '🌙',
          color: AppTheme.primaryPurple,
          description: 'Winding down phase. Focus on completion and reflection.',
        );
      case CyclePhase.unknown:
        return PhaseInfo(
          name: 'Unknown',
          emoji: '❓',
          color: AppTheme.mediumGrey,
          description: 'Phase information is not available.',
        );
    }
  }
}

class PhaseInfo {
  final String name;
  final String emoji;
  final Color color;
  final String description;

  const PhaseInfo({
    required this.name,
    required this.emoji,
    required this.color,
    required this.description,
  });
}

class PhaseRange {
  final int start;
  final int end;

  const PhaseRange(this.start, this.end);
}
