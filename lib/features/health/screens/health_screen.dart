import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../generated/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/health_provider.dart';
import '../widgets/healthkit_connection_card.dart';
import '../../tracking/screens/enhanced_daily_feelings_tracker.dart';
import 'dart:math' as math;
import '../../../core/ui/app_geometry.dart';
import '../../../core/ui/app_upcoming_feature_status.dart';
import '../../../core/ui/app_section_action_button.dart';
import '../../../core/ui/app_section_carrier.dart';
import '../widgets/health_section_header.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen>
    with TickerProviderStateMixin {
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

    // Load HealthKit connection state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthProvider>().loadConnectionState();
    });
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
          gradient: AppTheme.backgroundGradient(
            theme.brightness == Brightness.dark,
          ),
        ),
        child: SafeArea(
          child: Consumer<HealthProvider>(
            builder: (context, healthProvider, child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHealthHeader(localizations),
                    const SizedBox(height: 18),

                    _buildHealthDashboard(localizations),
                    const SizedBox(height: 18),

                    _buildHealthInsightsSection(localizations),
                    const SizedBox(height: 18),

                    _buildSymptomTracker(localizations),
                    const SizedBox(height: 18),

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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.cardColor,
            AppTheme.successGreen.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.successGreen, AppTheme.accentMint],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.health_and_safety,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Overview',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your synced health data',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
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

  Widget _buildHealthDashboard(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHealthConnectionSection(),
        const SizedBox(height: 16),
        _buildHealthDataCoverageCard(),
        const SizedBox(height: 16),
        _buildBiometricMonitoringSection(localizations),
      ],
    );
  }

  Widget _buildHealthConnectionSection() {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppGeometry.carrierRadius,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.22),
        ),
      ),
      child: const HealthKitConnectionCard(),
    );
  }

  Widget _buildBiometricMonitoringSection(AppLocalizations localizations) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppGeometry.carrierRadius,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HealthSectionHeader(
            icon: Icons.monitor_heart_outlined,
            title: 'Biometric Monitoring',
          ),
          const SizedBox(height: 12),
          _buildBiometricGrid(localizations, showHeading: false),
        ],
      ),
    );
  }

  Widget _buildHealthDataCoverageCard() {
    final theme = Theme.of(context);
    final healthProvider = context.watch<HealthProvider>();
    final snapshot = healthProvider.snapshot;

    final hasObservedData = healthProvider.hasObservedHealthData;
    final coverage = (snapshot?.dataQuality ?? 0.0).clamp(0.0, 1.0).toDouble();
    final observedMetricTypes = snapshot?.metricProvenance.length ?? 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryRose.withValues(alpha: 0.1),
            AppTheme.primaryPurple.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: AppGeometry.carrierRadius,
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
                HealthSectionHeader(
                  icon: Icons.donut_large,
                  title: 'Data Coverage',
                ),
                const SizedBox(height: 8),
                Text(
                  hasObservedData
                      ? '${(coverage * 100).round()}% coverage'
                      : '0% coverage',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hasObservedData
                      ? '$observedMetricTypes observed metric '
                            '${observedMetricTypes == 1 ? 'type' : 'types'} · '
                            'availability coverage'
                      : 'No synced observations.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 78,
            height: 78,
            child: AnimatedBuilder(
              animation: _heartRateAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: HealthDataCoveragePainter(
                    coverage: hasObservedData ? coverage : 0.0,
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

  Widget _buildBiometricGrid(
    AppLocalizations localizations, {
    bool showHeading = true,
  }) {
    final theme = Theme.of(context);
    final snapshot = context.watch<HealthProvider>().snapshot;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeading) ...[
          Text(
            'Biometric Monitoring',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
        ],
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
              snapshot?.heartRate != null
                  ? '${snapshot!.heartRate!.round()} BPM'
                  : 'No data',
              Icons.favorite,
              AppTheme.primaryRose,
              _heartRateAnimation,
            ),
            _buildBiometricCard(
              'Temperature',
              snapshot?.bodyTemperature != null
                  ? snapshot!.bodyTemperature!.toStringAsFixed(1)
                  : 'No data',
              Icons.thermostat,
              AppTheme.warningOrange,
              _temperatureAnimation,
            ),
            _buildBiometricCard(
              'Sleep Duration',
              snapshot?.sleepHours != null
                  ? '${snapshot!.sleepHours!.toStringAsFixed(1)} h'
                  : 'No data',
              Icons.bedtime,
              AppTheme.secondaryBlue,
              _sleepAnimation,
            ),
            _buildBiometricCard(
              'Stress Level',
              'No data',
              Icons.psychology,
              AppTheme.accentMint,
              _heartRateAnimation,
              releaseLabel: 'Q4 2026',
              availability: AppFeatureAvailability.comingSoon,
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
    Animation<double> animation, {
    String? status,
    String? releaseLabel,
    AppFeatureAvailability availability = AppFeatureAvailability.active,
  }) {
    final theme = Theme.of(context);
    return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [theme.cardColor, color.withValues(alpha: 0.05)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
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
                          color: color.withValues(
                            alpha: 0.1 + (animation.value * 0.1),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: color, size: 24),
                      );
                    },
                  ),
                  const Spacer(),
                  if (releaseLabel != null &&
                      availability == AppFeatureAvailability.comingSoon)
                    AppUpcomingFeatureStatus(
                      releaseLabel: releaseLabel,
                      availability: availability,
                      compact: true,
                    )
                  else if (status != null && status.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppGeometry.radiusSm,
                        ),
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
        )
        .animate()
        .fadeIn(
          delay:
              (400 +
                      [72, 98, 82, 25].indexOf(
                            int.tryParse(
                                  value
                                      .split(' ')[0]
                                      .replaceAll(RegExp(r'[^0-9]'), ''),
                                ) ??
                                0,
                          ) *
                          100)
                  .ms,
        )
        .scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildHealthInsightsSection(AppLocalizations localizations) {
    final theme = Theme.of(context);
    final insights = [
      {
        'title': 'No insights yet',
        'description':
            'Insights will appear when enough real health data is available.',
        'type': 'neutral',
        'icon': Icons.info_outline,
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppGeometry.carrierRadius,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HealthSectionHeader(
            icon: Icons.insights_outlined,
            title: 'Health Insights',
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
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              insight['description'] as String,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(delay: (600 + insights.indexOf(insight) * 200).ms)
                .slideX(begin: 0.2, end: 0);
          }),
        ],
      ),
    );
  }

  void _openSymptomTracker() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            EnhancedDailyFeelingsTracker(selectedDate: DateTime.now()),
      ),
    );
  }

  Widget _buildSymptomTracker(AppLocalizations localizations) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            AppTheme.accentMint.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: AppGeometry.carrierRadius,
        border: Border.all(
          color: AppTheme.accentMint.withValues(alpha: 0.1),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HealthSectionHeader(
            icon: Icons.healing_outlined,
            title: 'Symptom Tracker',
          ),
          const SizedBox(height: 14),
          AppSectionContentCarrier(
            accentColor: AppTheme.accentMint,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: AppSectionActionButton(
                    label: 'Add Symptom',
                    icon: Icons.add,
                    onPressed: _openSymptomTracker,
                    accentColor: AppTheme.symptomActionRose,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                      [
                        'Headache',
                        'Fatigue',
                        'Mood Swings',
                        'Cramps',
                        'Bloating',
                        'Back Pain',
                      ].map((symptom) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(
                              AppGeometry.radiusSm,
                            ),
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(
                                alpha: 0.45,
                              ),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            symptom,
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildHealthGoals(AppLocalizations localizations) {
    final theme = Theme.of(context);
    final goals = <Map<String, Object>>[];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppGeometry.carrierRadius,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HealthSectionHeader(icon: Icons.flag_outlined, title: 'Health Goals'),
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
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (isCompleted)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.successGreen.withValues(
                                  alpha: 0.1,
                                ),
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
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: AppTheme.lightGrey.withValues(
                            alpha: 0.3,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isCompleted
                                ? AppTheme.successGreen
                                : AppTheme.primaryRose,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(delay: (1400 + goals.indexOf(goal) * 100).ms)
                .slideX(begin: 0.3, end: 0);
          }),
        ],
      ),
    );
  }
}

// Custom painter for health data coverage
class HealthDataCoveragePainter extends CustomPainter {
  final double coverage;
  final double animation;

  HealthDataCoveragePainter({required this.coverage, required this.animation});

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

    // Animated coverage ring
    final coveragePaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (coverage * 2 * math.pi * animation);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      coveragePaint,
    );

    // Pulsing effect
    if (animation > 0.7) {
      final pulsePaint = Paint()
        ..color = AppTheme.primaryRose.withValues(
          alpha: 0.2 - (animation - 0.7) * 0.2,
        )
        ..strokeWidth = 12
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(center, radius + (animation - 0.7) * 8, pulsePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
