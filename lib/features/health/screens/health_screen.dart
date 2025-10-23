import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../generated/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/health_provider.dart';
import 'dart:math' as math;

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> with TickerProviderStateMixin {
  late AnimationController _heartRateController;
  late AnimationController _temperatureController;
  late AnimationController _sleepController;
  late Animation<double> _heartRateAnimation;
  late Animation<double> _temperatureAnimation;
  late Animation<double> _sleepAnimation;

  @override
  void initState() {
    super.initState();
    
    _heartRateController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _temperatureController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _sleepController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
    _heartRateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_heartRateController);
    
    _temperatureAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_temperatureController);
    
    _sleepAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_sleepController);
  }

  @override
  void dispose() {
    _heartRateController.dispose();
    _temperatureController.dispose();
    _sleepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
        gradient: AppTheme.backgroundGradient(theme.brightness == Brightness.dark),
        ),
        child: SafeArea(
          child: Consumer<HealthProvider>(
            builder: (context, healthProvider, child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHealthHeader(localizations),
                    const SizedBox(height: 24),
                    
                    _buildHealthScoreCard(localizations),
                    const SizedBox(height: 24),
                    
                    _buildBiometricGrid(localizations),
                    const SizedBox(height: 24),
                    
                    _buildHealthInsightsSection(localizations),
                    const SizedBox(height: 24),
                    
                    _buildSymptomTracker(localizations),
                    const SizedBox(height: 24),
                    
                    _buildHealthGoals(localizations),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHealthHeader(AppLocalizations localizations) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.cardColor,
            AppTheme.successGreen.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.successGreen.withValues(alpha: 0.1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.successGreen, AppTheme.accentMint],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.health_and_safety,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Dashboard',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Comprehensive health monitoring',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  Widget _buildHealthScoreCard(AppLocalizations localizations) {
    final theme = Theme.of(context);
    final healthScore = 0.82; // Mock data
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryRose.withValues(alpha: 0.1),
            AppTheme.primaryPurple.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryRose.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Health Score',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(healthScore * 100).round()}/100',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryRose,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Excellent',
                    style: TextStyle(
                      color: AppTheme.successGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 100,
            height: 100,
            child: AnimatedBuilder(
              animation: _heartRateAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: HealthScorePainter(
                    score: healthScore,
                    animation: _heartRateAnimation.value,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.3, end: 0);
  }

  Widget _buildBiometricGrid(AppLocalizations localizations) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Biometric Monitoring',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.1,
          children: [
            _buildBiometricCard(
              'Heart Rate',
              '72 BPM',
              Icons.favorite,
              AppTheme.primaryRose,
              _heartRateAnimation,
              'Normal',
            ),
            _buildBiometricCard(
              'Temperature',
              '98.6°F',
              Icons.thermostat,
              AppTheme.warningOrange,
              _temperatureAnimation,
              'Normal',
            ),
            _buildBiometricCard(
              'Sleep Quality',
              '8.2/10',
              Icons.bedtime,
              AppTheme.secondaryBlue,
              _sleepAnimation,
              'Excellent',
            ),
            _buildBiometricCard(
              'Stress Level',
              'Low',
              Icons.psychology,
              AppTheme.accentMint,
              _heartRateAnimation,
              'Good',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBiometricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    Animation<double> animation,
    String status,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.cardColor,
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1 + (animation.value * 0.1)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  );
                },
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: AppTheme.successGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (400 + [72, 98, 82, 25].indexOf(int.tryParse(value.split(' ')[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0) * 100).ms)
     .scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildHealthInsightsSection(AppLocalizations localizations) {
    final theme = Theme.of(context);
    final insights = [
      {
        'title': 'Excellent Sleep Pattern',
        'description': 'Your sleep quality has improved by 15% this week. Keep maintaining your bedtime routine.',
        'type': 'positive',
        'icon': Icons.bedtime,
      },
      {
        'title': 'Heart Rate Variability',
        'description': 'Consider adding more cardio exercises to improve your heart rate variability.',
        'type': 'suggestion',
        'icon': Icons.favorite,
      },
      {
        'title': 'Hydration Reminder',
        'description': 'Your hydration levels are optimal. Continue drinking 8 glasses of water daily.',
        'type': 'neutral',
        'icon': Icons.water_drop,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Insights',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ...insights.map((insight) {
          Color getColor() {
            switch (insight['type']) {
              case 'positive':
                return AppTheme.successGreen;
              case 'suggestion':
                return AppTheme.warningOrange;
              default:
                return AppTheme.secondaryBlue;
            }
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: getColor().withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: getColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    insight['icon'] as IconData,
                    color: getColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight['title'] as String,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        insight['description'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.mediumGrey,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: (600 + insights.indexOf(insight) * 200).ms)
           .slideX(begin: 0.2, end: 0);
        }),
      ],
    );
  }

  Widget _buildSymptomTracker(AppLocalizations localizations) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            AppTheme.accentMint.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.accentMint.withValues(alpha: 0.1),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.accentMint, AppTheme.secondaryBlue],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.healing,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Symptom Tracker',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGrey,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                },
                child: Text(
                  'Add Symptom',
                  style: TextStyle(
                    color: AppTheme.accentMint,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              'Headache',
              'Fatigue',
              'Mood Swings',
              'Cramps',
              'Bloating',
              'Back Pain'
            ].map((symptom) {
              final isActive = ['Fatigue', 'Mood Swings'].contains(symptom);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive 
                      ? AppTheme.accentMint.withValues(alpha: 0.1)
                      : AppTheme.lightGrey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive 
                        ? AppTheme.accentMint
                        : AppTheme.mediumGrey.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  symptom,
                  style: TextStyle(
                    color: isActive ? AppTheme.accentMint : AppTheme.mediumGrey,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildHealthGoals(AppLocalizations localizations) {
    final theme = Theme.of(context);
    final goals = [
      {'title': 'Daily Steps', 'current': 8420, 'target': 10000, 'unit': 'steps'},
      {'title': 'Water Intake', 'current': 6, 'target': 8, 'unit': 'glasses'},
      {'title': 'Sleep Duration', 'current': 7.5, 'target': 8.0, 'unit': 'hours'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Goals',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.darkGrey,
          ),
        ),
        const SizedBox(height: 16),
        ...goals.map((goal) {
          final progress = (goal['current'] as num) / (goal['target'] as num);
          final isCompleted = progress >= 1.0;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCompleted 
                    ? AppTheme.successGreen.withValues(alpha: 0.3)
                    : AppTheme.lightGrey.withValues(alpha: 0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        goal['title'] as String,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkGrey,
                        ),
                      ),
                    ),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: AppTheme.successGreen,
                          size: 16,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${goal['current']} / ${goal['target']} ${goal['unit']}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mediumGrey,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: AppTheme.lightGrey.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? AppTheme.successGreen : AppTheme.primaryRose,
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: (1400 + goals.indexOf(goal) * 100).ms)
           .slideX(begin: 0.3, end: 0);
        }),
      ],
    );
  }
}

// Custom Painter for Health Score
class HealthScorePainter extends CustomPainter {
  final double score;
  final double animation;
  
  HealthScorePainter({required this.score, required this.animation});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    
    // Background ring
    final backgroundPaint = Paint()
      ..color = AppTheme.lightGrey.withValues(alpha: 0.3)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // Animated score ring
    final scorePaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final sweepAngle = (score * 2 * math.pi * animation);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      scorePaint,
    );
    
    // Pulsing effect
    if (animation > 0.7) {
      final pulsePaint = Paint()
        ..color = AppTheme.primaryRose.withValues(alpha: 0.2 - (animation - 0.7) * 0.2)
        ..strokeWidth = 12
        ..style = PaintingStyle.stroke;
      
      canvas.drawCircle(center, radius + (animation - 0.7) * 8, pulsePaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
