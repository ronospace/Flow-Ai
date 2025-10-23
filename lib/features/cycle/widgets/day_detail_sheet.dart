import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/cycle_data.dart';
import '../screens/calendar_screen.dart';

class DayDetailSheet extends StatelessWidget {
  final DateTime selectedDate;
  final DayInfo dayInfo;

  const DayDetailSheet({
    super.key,
    required this.selectedDate,
    required this.dayInfo,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        _buildHeader(),
                        
                        const SizedBox(height: 24),
                        
                        // Day Information
                        if (dayInfo.cycleDay != null) ...[
                          _buildCycleInfo(),
                          const SizedBox(height: 24),
                        ],
                        
                        // Phase Information
                        if (dayInfo.phase != null) ...[
                          _buildPhaseInfo(),
                          const SizedBox(height: 24),
                        ],
                        
                        // Prediction Info
                        if (dayInfo.isPredicted) ...[
                          _buildPredictionInfo(),
                          const SizedBox(height: 24),
                        ],
                        
                        // Quick Actions
                        _buildQuickActions(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Date circle
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: dayInfo.color != null
                ? LinearGradient(
                    colors: [dayInfo.color!.withValues(alpha: 0.3), dayInfo.color!],
                  )
                : const LinearGradient(
                    colors: [AppTheme.lightGrey, AppTheme.mediumGrey],
                  ),
            shape: BoxShape.circle,
            border: dayInfo.isPredicted
                ? Border.all(color: AppTheme.secondaryBlue, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              '${selectedDate.day}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Date info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, MMMM d').format(selectedDate),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGrey,
                ),
              ),
              Text(
                DateFormat('y').format(selectedDate),
                style: TextStyle(
                  color: AppTheme.mediumGrey,
                  fontSize: 16,
                ),
              ),
              if (dayInfo.isPredicted)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.psychology,
                        size: 14,
                        color: AppTheme.secondaryBlue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'AI Prediction',
                        style: TextStyle(
                          color: AppTheme.secondaryBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  Widget _buildCycleInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: dayInfo.color?.withValues(alpha: 0.1) ?? AppTheme.lightGrey.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dayInfo.color?.withValues(alpha: 0.3) ?? AppTheme.lightGrey,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite_rounded,
                color: dayInfo.color ?? AppTheme.primaryRose,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Cycle Information',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: dayInfo.color ?? AppTheme.darkGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Cycle Day',
                  '${dayInfo.cycleDay}',
                  Icons.calendar_today,
                ),
              ),
              if (dayInfo.flowIntensity != null)
                Expanded(
                  child: _buildInfoItem(
                    'Flow',
                    dayInfo.flowIntensity!.displayName,
                    Icons.water_drop,
                  ),
                ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0);
  }

  Widget _buildPhaseInfo() {
    final phaseInfo = _getPhaseInfo(dayInfo.phase!);
    
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
          Row(
            children: [
              Text(
                phaseInfo.emoji,
                style: const TextStyle(fontSize: 24),
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
                      phaseInfo.description,
                      style: TextStyle(
                        color: AppTheme.mediumGrey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (phaseInfo.tips.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Tips for this phase:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: phaseInfo.color,
              ),
            ),
            const SizedBox(height: 8),
            ...phaseInfo.tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      color: phaseInfo.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        color: AppTheme.mediumGrey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildPredictionInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.secondaryBlue.withValues(alpha: 0.1),
            AppTheme.accentMint.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.secondaryBlue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.psychology,
                  color: AppTheme.secondaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Prediction',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryBlue,
                      ),
                    ),
                    Text(
                      'Based on your cycle patterns',
                      style: TextStyle(
                        color: AppTheme.mediumGrey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'This date is predicted based on your historical cycle data and AI analysis. Actual dates may vary.',
            style: TextStyle(
              color: AppTheme.mediumGrey,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkGrey,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Log Data',
                Icons.add_circle_rounded,
                AppTheme.primaryRose,
                () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                  context.go('/tracking');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'View Insights',
                Icons.insights_rounded,
                AppTheme.secondaryBlue,
                () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                  context.go('/insights');
                },
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.mediumGrey),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.mediumGrey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkGrey,
          ),
        ),
      ],
    );
  }

  PhaseInfo _getPhaseInfo(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return PhaseInfo(
          name: 'Menstrual Phase',
          emoji: '🩸',
          color: AppTheme.primaryRose,
          description: 'Your period is here. Focus on rest and self-care.',
          tips: [
            'Stay hydrated and eat iron-rich foods',
            'Use a heating pad for cramps',
            'Gentle exercise like walking or yoga',
            'Get plenty of rest',
          ],
        );
      case CyclePhase.follicular:
        return PhaseInfo(
          name: 'Follicular Phase',
          emoji: '🌱',
          color: AppTheme.accentMint,
          description: 'Your energy is building. Great time to start new projects.',
          tips: [
            'Try new workouts or activities',
            'Focus on goal setting',
            'Eat plenty of fresh foods',
            'Take advantage of higher energy',
          ],
        );
      case CyclePhase.ovulatory:
        return PhaseInfo(
          name: 'Ovulation Phase',
          emoji: '🥚',
          color: AppTheme.secondaryBlue,
          description: 'Peak fertility window. You may feel more social and confident.',
          tips: [
            'Great time for important meetings',
            'Social activities and networking',
            'High-intensity workouts',
            'Focus on communication',
          ],
        );
      case CyclePhase.luteal:
        return PhaseInfo(
          name: 'Luteal Phase',
          emoji: '🌙',
          color: AppTheme.primaryPurple,
          description: 'Winding down phase. Focus on completion and reflection.',
          tips: [
            'Finish up projects',
            'Practice self-reflection',
            'Eat comforting, nutritious foods',
            'Prepare for upcoming period',
          ],
        );
      case CyclePhase.unknown:
        return PhaseInfo(
          name: 'Unknown Phase',
          emoji: '❓',
          color: AppTheme.mediumGrey,
          description: 'Phase information is not available.',
          tips: [
            'Continue tracking your cycle for better insights',
          ],
        );
    }
  }
}

class PhaseInfo {
  final String name;
  final String emoji;
  final Color color;
  final String description;
  final List<String> tips;

  const PhaseInfo({
    required this.name,
    required this.emoji,
    required this.color,
    required this.description,
    required this.tips,
  });
}
