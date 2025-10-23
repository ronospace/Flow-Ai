import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/safe_shadows.dart';
import 'dart:math' as math;

class MoodEnergySlider extends StatefulWidget {
  final String label;
  final double value;
  final Function(double) onChanged;
  final String emoji;
  final Color color;
  final double min;
  final double max;

  const MoodEnergySlider({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.emoji,
    required this.color,
    this.min = 1,
    this.max = 5,
  });

  @override
  State<MoodEnergySlider> createState() => _MoodEnergySliderState();
}

class _MoodEnergySliderState extends State<MoodEnergySlider> 
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _particleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticOut,
    ));
    
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_waveController);
    
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_particleController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _triggerPulse() {
    if (!_pulseController.isAnimating) {
      _pulseController.forward().then((_) {
        if (mounted) {
          _pulseController.reverse();
        }
      });
    }
  }

  String _getLevelText(double value) {
    switch (widget.label.toLowerCase()) {
      case 'mood':
        if (value <= 1) return 'Terrible';
        if (value <= 2) return 'Poor';
        if (value <= 3) return 'Okay';
        if (value <= 4) return 'Good';
        return 'Amazing';
      case 'energy':
        if (value <= 1) return 'Exhausted';
        if (value <= 2) return 'Tired';
        if (value <= 3) return 'Normal';
        if (value <= 4) return 'Energetic';
        return 'Vibrant';
      case 'pain level':
        if (value <= 1) return 'None';
        if (value <= 2) return 'Mild';
        if (value <= 3) return 'Moderate';
        if (value <= 4) return 'Severe';
        return 'Unbearable';
      default:
        return 'Level ${value.round()}';
    }
  }

  Color _getColorForValue(double value) {
    final intensity = (value - widget.min) / (widget.max - widget.min);
    
    if (widget.label.toLowerCase() == 'pain level') {
      // For pain, higher values are more intense (red)
      return Color.lerp(
        AppTheme.accentMint,
        AppTheme.primaryRose,
        intensity,
      ) ?? widget.color;
    } else {
      // For mood and energy, higher values are better (positive colors)
      return Color.lerp(
        widget.color.withValues(alpha: 0.5),
        widget.color,
        intensity,
      ) ?? widget.color;
    }
  }

  String _getPsychologyInsight(double value) {
    final type = widget.label.toLowerCase();
    
    if (type == 'mood') {
      switch (value.round()) {
        case 1:
          return 'Low mood detected. Consider gentle self-care activities and reach out for support if needed.';
        case 2:
          return 'Mild mood fluctuation is normal during your cycle. Try breathing exercises or light movement.';
        case 3:
          return 'Balanced emotional state. This is a great time for routine activities and planning.';
        case 4:
          return 'Positive mood pattern! Your hormones may be supporting emotional stability.';
        case 5:
          return 'Excellent mood! Consider journaling about what\'s working well in your routine.';
        default:
          return 'Track your mood patterns to understand your cycle better.';
      }
    } else if (type == 'energy') {
      switch (value.round()) {
        case 1:
          return 'Low energy is common during certain cycle phases. Prioritize rest and gentle nutrition.';
        case 2:
          return 'Moderate fatigue detected. Consider iron-rich foods and adequate sleep.';
        case 3:
          return 'Stable energy levels. Your body is maintaining good hormonal balance.';
        case 4:
          return 'High energy phase! Great time for challenging activities and exercise.';
        case 5:
          return 'Peak energy levels! Your cycle may be in an optimal phase for productivity.';
        default:
          return 'Energy tracking helps optimize your daily schedule around your cycle.';
      }
    } else {
      return 'Consistent tracking provides valuable insights into your wellbeing patterns.';
    }
  }
  
  List<Color> _getNeuralNetworkColors(double value) {
    final intensity = (value - widget.min) / (widget.max - widget.min);
    
    if (widget.label.toLowerCase() == 'mood') {
      return [
        Color.lerp(AppTheme.secondaryBlue.withValues(alpha: 0.5), AppTheme.primaryRose, intensity)!,
        Color.lerp(AppTheme.primaryPurple.withValues(alpha: 0.5), AppTheme.primaryPurple, intensity)!,
        Color.lerp(AppTheme.primaryRose.withValues(alpha: 0.5), AppTheme.accentMint, intensity)!,
      ];
    } else {
      return [
        Color.lerp(AppTheme.warningOrange.withValues(alpha: 0.5), AppTheme.accentMint, intensity)!,
        Color.lerp(AppTheme.accentMint.withValues(alpha: 0.5), AppTheme.secondaryBlue, intensity)!,
        Color.lerp(AppTheme.successGreen.withValues(alpha: 0.5), AppTheme.primaryRose, intensity)!,
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentColor = _getColorForValue(widget.value);
    final levelText = _getLevelText(widget.value);
    final neuralColors = _getNeuralNetworkColors(widget.value);
    final psychologyInsight = _getPsychologyInsight(widget.value);

    return Column(
      children: [
        // REVOLUTIONARY: Biometric-Style Visualization Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.surface,
                currentColor.withValues(alpha: 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: currentColor.withValues(alpha: 0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: currentColor.withValues(alpha: 0.15),
                blurRadius: 25,
                offset: const Offset(0, 12),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: theme.colorScheme.surface,
                blurRadius: 8,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Enhanced Header with Neural Activity Indicator
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Biometric Analysis',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.mediumGrey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  
                  // Neural Activity Indicator
                  Container(
                    width: 60,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: neuralColors,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        // Animated wave pattern
                        Positioned.fill(
                          child: CustomPaint(
                            painter: NeuralWavePainter(
                              colors: neuralColors,
                              animation: _waveAnimation,
                              value: widget.value,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          currentColor,
                          currentColor.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: currentColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      levelText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // REVOLUTIONARY: Biometric Center Display
              Stack(
                alignment: Alignment.center,
                children: [
                  // Neural network background pattern
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CustomPaint(
                      painter: NeuralNetworkPainter(
                        colors: neuralColors,
                        animation: _particleAnimation,
                        value: widget.value,
                        maxValue: widget.max,
                      ),
                    ),
                  ),
                  
                  // Pulsing rings based on value intensity
                  ...List.generate(3, (index) {
                    final radius = 50.0 + (index * 15);
                    final opacity = (widget.value / widget.max) * 0.3 * (3 - index) / 3;
                    
                    return AnimatedBuilder(
                      animation: _waveAnimation,
                      builder: (context, child) {
                        return Container(
                          width: radius + (_waveAnimation.value * 10),
                          height: radius + (_waveAnimation.value * 10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: currentColor.withValues(alpha: opacity),
                              width: 2,
                            ),
                          ),
                        );
                      },
                    );
                  }),
                  
                  // Central biometric display
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                currentColor.withValues(alpha: 0.8),
                                currentColor.withValues(alpha: 0.4),
                                currentColor.withValues(alpha: 0.1),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: currentColor.withValues(alpha: 0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Emoji display
                              Text(
                                widget.emoji,
                                style: const TextStyle(fontSize: 42),
                              ),
                              
                              // Value display
                              Positioned(
                                bottom: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    widget.value.toStringAsFixed(1),
                                    style: TextStyle(
                                      color: currentColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // REVOLUTIONARY: Enhanced Interactive Value Selectors
              Wrap(
                spacing: 12,
                children: List.generate(
                  (widget.max - widget.min + 1).round(),
                  (index) {
                    final indicatorValue = widget.min + index;
                    final isActive = widget.value.round() == indicatorValue.round();
                    final indicatorColor = _getColorForValue(indicatorValue);
                    
                    return GestureDetector(
                      onTap: () {
                        widget.onChanged(indicatorValue);
                        _triggerPulse();
                        HapticFeedback.mediumImpact();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.elasticOut,
                        width: isActive ? 55 : 45,
                        height: isActive ? 55 : 45,
                        decoration: BoxDecoration(
                          gradient: isActive 
                              ? LinearGradient(
                                  colors: [
                                    indicatorColor,
                                    indicatorColor.withValues(alpha: 0.8),
                                  ],
                                )
                              : null,
                          color: isActive ? null : indicatorColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: indicatorColor,
                            width: isActive ? 3 : 2,
                          ),
          boxShadow: isActive ? [
                            SafeShadows.safe(
                              color: indicatorColor.withValues(alpha: 0.5),
                              blurRadius: 15.0,
                              offset: const Offset(0, 6),
                              spreadRadius: 2.0,
                            ),
                            SafeShadows.safe(
                              color: theme.colorScheme.surface.withValues(alpha: 0.8),
                              blurRadius: 5.0,
                              offset: const Offset(0, 2),
                            ),
                          ] : [
                            SafeShadows.safe(
                              color: indicatorColor.withValues(alpha: 0.2),
                              blurRadius: 8.0,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Background pulse for active
                            if (isActive)
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                              ).animate(onPlay: (controller) => controller.repeat())
                                .fadeIn(duration: 800.ms)
                                .then(delay: 200.ms)
                                .fadeOut(duration: 800.ms),
                            
                            // Number display
                            Text(
                              indicatorValue.round().toString(),
                              style: TextStyle(
                                color: isActive ? theme.colorScheme.onPrimary : indicatorColor,
                                fontWeight: FontWeight.bold,
                                fontSize: isActive ? 20 : 16,
                              ),
                            ),
                          ],
                        ),
                      ).animate(delay: Duration(milliseconds: index * 100))
                        .fadeIn()
                        .scale(begin: const Offset(0.8, 0.8)),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 32),
              
              // REVOLUTIONARY: Advanced Biometric Slider
              SizedBox(
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background track with neural pattern
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            currentColor.withValues(alpha: 0.1),
                            currentColor.withValues(alpha: 0.3),
                            currentColor.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    
                    // Main slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.transparent,
                        inactiveTrackColor: Colors.transparent,
                        thumbColor: currentColor,
                        overlayColor: currentColor.withValues(alpha: 0.2),
                        thumbShape: BiometricSliderThumb(
                          color: currentColor,
                          value: widget.value,
                          maxValue: widget.max,
                          animation: _waveAnimation,
                          theme: theme,
                        ),
                        trackHeight: 12,
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 30),
                      ),
                      child: Slider(
                        value: widget.value,
                        min: widget.min,
                        max: widget.max,
                        divisions: ((widget.max - widget.min) * 2).round(),
                        onChanged: (value) {
                          widget.onChanged(value);
                          _triggerPulse();
                          HapticFeedback.mediumImpact();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              // Range labels with enhanced styling
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getLevelText(widget.min),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getColorForValue(widget.min),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Min',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.mediumGrey,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _getLevelText(widget.max),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getColorForValue(widget.max),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Max',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.mediumGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: 0.3, end: 0),
        
        const SizedBox(height: 20),
        
        // REVOLUTIONARY: AI Psychology Insights Panel
        Container(
          constraints: const BoxConstraints(minHeight: 120),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.secondaryBlue.withValues(alpha: 0.1),
                AppTheme.accentMint.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: currentColor.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.secondaryBlue.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.secondaryBlue, AppTheme.accentMint],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.secondaryBlue.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.psychology,
                      color: theme.colorScheme.onPrimary,
                      size: 20,
                    ),
                  ).animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 2500.ms)
                    .then(delay: 1000.ms),
                  
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Psychology Insights',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkGrey,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Personalized for your cycle',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.mediumGrey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Insight indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentMint.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: AppTheme.accentMint,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Text(
                  psychologyInsight,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    height: 1.5,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.3, end: 0),
      ],
    );
  }
}

/// REVOLUTIONARY: Neural Wave Painter for biometric visualization
class NeuralWavePainter extends CustomPainter {
  final List<Color> colors;
  final Animation<double> animation;
  final double value;

  NeuralWavePainter({
    required this.colors,
    required this.animation,
    required this.value,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final waveHeight = size.height * 0.3;
    final frequency = 4.0 + (value * 2);
    final path = Path();

    for (int i = 0; i < colors.length; i++) {
      paint.color = colors[i].withValues(alpha: 0.7);
      path.reset();
      
      final yOffset = size.height / 2 + (i - 1) * 3;
      
      for (double x = 0; x <= size.width; x += 1) {
        final y = yOffset + 
                 waveHeight * 
                 math.sin((x / size.width * frequency + animation.value + i * 0.5) * 2 * math.pi) * 
                 (value / 5.0);
        
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant NeuralWavePainter oldDelegate) {
    return oldDelegate.animation != animation ||
           oldDelegate.value != value;
  }
}

/// REVOLUTIONARY: Neural Network Painter for background pattern
class NeuralNetworkPainter extends CustomPainter {
  final List<Color> colors;
  final Animation<double> animation;
  final double value;
  final double maxValue;

  NeuralNetworkPainter({
    required this.colors,
    required this.animation,
    required this.value,
    required this.maxValue,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final nodeCount = (value * 3).round() + 3;
    final intensity = value / maxValue;

    // Draw neural nodes
    for (int i = 0; i < nodeCount; i++) {
      final angle = (i / nodeCount * 2 * math.pi) + (animation.value * 2 * math.pi);
      final radius = 25 + (i % 3) * 15 + (animation.value * 5);
      
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      if (x >= 0 && x <= size.width && y >= 0 && y <= size.height) {
        paint.color = colors[i % colors.length].withValues(alpha: 0.15 + intensity * 0.2);
        canvas.drawCircle(Offset(x, y), 3 + (intensity * 2), paint);
        
        // Draw connections
        if (i > 0) {
          final prevAngle = ((i-1) / nodeCount * 2 * math.pi) + (animation.value * 2 * math.pi);
          final prevRadius = 25 + ((i-1) % 3) * 15 + (animation.value * 5);
          final prevX = center.dx + prevRadius * math.cos(prevAngle);
          final prevY = center.dy + prevRadius * math.sin(prevAngle);
          
          final connectionPaint = Paint()
            ..color = colors[i % colors.length].withValues(alpha: 0.1 + intensity * 0.15)
            ..strokeWidth = 0.5
            ..style = PaintingStyle.stroke;
          
          canvas.drawLine(Offset(x, y), Offset(prevX, prevY), connectionPaint);
        }
      }
    }
    
    // Draw central pulse
    final pulseRadius = 20 + (intensity * 15) + (animation.value * 5);
    paint.color = colors.first.withValues(alpha: 0.08 + intensity * 0.1);
    canvas.drawCircle(center, pulseRadius, paint);
  }

  @override
  bool shouldRepaint(covariant NeuralNetworkPainter oldDelegate) {
    return oldDelegate.animation != animation ||
           oldDelegate.value != value;
  }
}

/// REVOLUTIONARY: Biometric Slider Thumb with neural visualization
class BiometricSliderThumb extends SliderComponentShape {
  final Color color;
  final double value;
  final double maxValue;
  final Animation<double> animation;
  final ThemeData theme;

  BiometricSliderThumb({
    required this.color,
    required this.value,
    required this.maxValue,
    required this.animation,
    required this.theme,
  }) : super();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(28, 28);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final intensity = this.value / maxValue;
    
    // Outer pulsing glow
    final outerGlowPaint = Paint()
      ..color = color.withValues(alpha: 0.2 + (animation.value * 0.2))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 20 + (animation.value * 5), outerGlowPaint);
    
    // Neural ring pattern
    for (int i = 0; i < 3; i++) {
      final ringRadius = 12 + (i * 3) + (animation.value * 2);
      final ringPaint = Paint()
        ..color = color.withValues(alpha: 0.3 - (i * 0.08))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(center, ringRadius, ringPaint);
    }
    
    // Main biometric thumb
    final gradientPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color,
          color.withValues(alpha: 0.8),
          color.withValues(alpha: 0.6),
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: 14))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 14, gradientPaint);
    
    // Inner biometric pattern
    final patternPaint = Paint()
      ..color = theme.colorScheme.onPrimary.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    // Draw biometric lines
    for (int i = 0; i < 6; i++) {
      final angle = (i / 6 * 2 * math.pi) + (animation.value * 2 * math.pi);
      final innerRadius = 4;
      final outerRadius = 10;
      
      final startX = center.dx + innerRadius * math.cos(angle);
      final startY = center.dy + innerRadius * math.sin(angle);
      final endX = center.dx + outerRadius * math.cos(angle);
      final endY = center.dy + outerRadius * math.sin(angle);
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        patternPaint,
      );
    }
    
    // Central pulse indicator
    final centerPaint = Paint()
      ..color = theme.colorScheme.onPrimary.withValues(alpha: 0.8 + (animation.value * 0.2))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 2 + (intensity * 2), centerPaint);
  }
}

/// Safe BoxShadow that prevents negative blur radius values
class _SafeBoxShadow extends BoxShadow {
  const _SafeBoxShadow({
    super.color,
    super.offset,
    double blurRadius = 0.0,
    double spreadRadius = 0.0,
    super.blurStyle,
  }) : super(
         blurRadius: blurRadius < 0 ? 0 : blurRadius,
         spreadRadius: spreadRadius < 0 ? 0 : spreadRadius,
       );

  @override
  BoxShadow scale(double factor) {
    return _SafeBoxShadow(
      color: color,
      offset: offset * factor,
      blurRadius: math.max(0.0, blurRadius * factor),
      spreadRadius: math.max(0.0, spreadRadius * factor),
      blurStyle: blurStyle,
    );
  }
}

/// Enhanced Custom Slider Thumb (kept for compatibility)
class CustomSliderThumb extends SliderComponentShape {
  final Color color;
  final double radius;
  final ThemeData theme;

  const CustomSliderThumb({
    required this.color,
    this.radius = 10,
    required this.theme,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(radius * 2, radius * 2);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    
    // Outer circle (glow effect)
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 1.5, glowPaint);
    
    // Main thumb
    final thumbPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, thumbPaint);
    
    // Inner highlight
    final highlightPaint = Paint()
      ..color = theme.colorScheme.onPrimary.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.6, highlightPaint);
  }
}
