import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../feelings/daily_feelings_tracker.dart';
import '../utils/app_logger.dart';

/// 🎨 Consumer Visual Engine
/// Advanced visual system adapted from Flow iQ for consumer wellness experience
/// Features mood-based color morphing, breathing animations, and wellness visualizations
class ConsumerVisualEngine {
  static final ConsumerVisualEngine _instance = ConsumerVisualEngine._internal();
  static ConsumerVisualEngine get instance => _instance;
  ConsumerVisualEngine._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Visual systems
  late MoodColorMorph _colorMorph;
  late BreathingAnimationEngine _breathingEngine;
  late WellnessVisualization _wellnessViz;
  late BiometricsRenderer _biometricsRenderer;

  // Animation controllers
  final List<AnimationController> _activeControllers = [];
  
  // Color palettes
  static const Map<MoodState, List<Color>> _moodPalettes = {
    MoodState.joyful: [
      Color(0xFFFFD700), // Gold
      Color(0xFFFF6B35), // Orange
      Color(0xFFFF1744), // Pink
      Color(0xFFE040FB), // Purple
    ],
    MoodState.calm: [
      Color(0xFF4FC3F7), // Light Blue
      Color(0xFF29B6F6), // Blue
      Color(0xFF26A69A), // Teal
      Color(0xFF66BB6A), // Green
    ],
    MoodState.energetic: [
      Color(0xFFFF5722), // Deep Orange
      Color(0xFFFF9800), // Orange
      Color(0xFFFFC107), // Amber
      Color(0xFFCDDC39), // Lime
    ],
    MoodState.reflective: [
      Color(0xFF9C27B0), // Purple
      Color(0xFF673AB7), // Deep Purple
      Color(0xFF3F51B5), // Indigo
      Color(0xFF2196F3), // Blue
    ],
    MoodState.peaceful: [
      Color(0xFF81C784), // Light Green
      Color(0xFF4CAF50), // Green
      Color(0xFF009688), // Teal
      Color(0xFF00ACC1), // Cyan
    ],
    MoodState.melancholy: [
      Color(0xFF607D8B), // Blue Grey
      Color(0xFF546E7A), // Blue Grey 600
      Color(0xFF455A64), // Blue Grey 700
      Color(0xFF37474F), // Blue Grey 800
    ],
    MoodState.neutral: [
      Color(0xFF9E9E9E), // Grey
      Color(0xFF757575), // Grey 600
      Color(0xFF616161), // Grey 700
      Color(0xFF424242), // Grey 800
    ],
  };

  /// Initialize the consumer visual engine
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      AppLogger.success('🎨 Initializing Consumer Visual Engine...');

      // Initialize visual systems
      _colorMorph = MoodColorMorph();
      _breathingEngine = BreathingAnimationEngine();
      _wellnessViz = WellnessVisualization();
      _biometricsRenderer = BiometricsRenderer();

      await Future.wait([
        _colorMorph.initialize(),
        _breathingEngine.initialize(),
        _wellnessViz.initialize(),
        _biometricsRenderer.initialize(),
      ]);

      _isInitialized = true;
      AppLogger.success('✅ Consumer Visual Engine initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize Consumer Visual Engine: $e');
      rethrow;
    }
  }

  /// Create mood-responsive background widget
  Widget createMoodResponsiveBackground({
    required MoodState moodState,
    required Widget child,
    double intensity = 1.0,
    bool animated = true,
  }) {
    if (!_isInitialized) {
      return child;
    }

    return _colorMorph.createMoodBackground(
      moodState: moodState,
      child: child,
      intensity: intensity,
      animated: animated,
    );
  }

  /// Create breathing animation widget
  Widget createBreathingAnimation({
    BreathingPattern pattern = BreathingPattern.relaxation,
    double size = 200,
    Color? color,
    VoidCallback? onCycleComplete,
  }) {
    if (!_isInitialized) {
      return Container();
    }

    return _breathingEngine.createBreathingWidget(
      pattern: pattern,
      size: size,
      color: color,
      onCycleComplete: onCycleComplete,
    );
  }

  /// Create wellness visualization chart
  Widget createWellnessChart({
    required String userId,
    WellnessChartType type = WellnessChartType.moodTrend,
    int daysBack = 14,
    double height = 200,
    Color? accentColor,
  }) {
    if (!_isInitialized) {
      return Container();
    }

    return _wellnessViz.createChart(
      userId: userId,
      type: type,
      daysBack: daysBack,
      height: height,
      accentColor: accentColor,
    );
  }

  /// Create floating biometric particles
  Widget createBiometricParticles({
    BiometricVisualization type = BiometricVisualization.heartRate,
    double? value,
    Color? color,
    Size size = const Size(300, 300),
  }) {
    if (!_isInitialized) {
      return Container();
    }

    return _biometricsRenderer.createParticleSystem(
      type: type,
      value: value,
      color: color,
      size: size,
    );
  }

  /// Get current mood state from feelings data
  MoodState getMoodStateFromFeelings(double feelingScore) {
    if (feelingScore >= 9) return MoodState.joyful;
    if (feelingScore >= 7) return MoodState.energetic;
    if (feelingScore >= 6) return MoodState.calm;
    if (feelingScore >= 5) return MoodState.neutral;
    if (feelingScore >= 4) return MoodState.reflective;
    if (feelingScore >= 2) return MoodState.melancholy;
    return MoodState.peaceful; // Low scores benefit from peaceful colors
  }

  /// Create shader-based gradient effect
  Widget createShaderGradient({
    required Widget child,
    required List<Color> colors,
    BlendMode blendMode = BlendMode.srcOver,
    bool animated = true,
  }) {
    return ShaderMask(
      blendMode: blendMode,
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: child,
    );
  }

  /// Create mathematical wave animation
  Widget createWaveAnimation({
    double height = 100,
    Color color = Colors.blue,
    double frequency = 1.0,
    double amplitude = 0.5,
    Duration period = const Duration(seconds: 3),
  }) {
    return WaveAnimationWidget(
      height: height,
      color: color,
      frequency: frequency,
      amplitude: amplitude,
      period: period,
    );
  }

  /// Register animation controller for cleanup
  void _registerController(AnimationController controller) {
    _activeControllers.add(controller);
  }

  /// Dispose all resources
  void dispose() {
    for (final controller in _activeControllers) {
      controller.dispose();
    }
    _activeControllers.clear();
    
    _colorMorph.dispose();
    _breathingEngine.dispose();
    _wellnessViz.dispose();
    _biometricsRenderer.dispose();
  }
}

/// Mood-based Color Morphing System
class MoodColorMorph {
  bool _isInitialized = false;
  Timer? _morphTimer;
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    AppLogger.success('🌈 Mood Color Morph initialized');
  }

  Widget createMoodBackground({
    required MoodState moodState,
    required Widget child,
    double intensity = 1.0,
    bool animated = true,
  }) {
    final palette = ConsumerVisualEngine._moodPalettes[moodState] ?? 
                   ConsumerVisualEngine._moodPalettes[MoodState.neutral]!;

    return AnimatedContainer(
      duration: animated ? const Duration(seconds: 2) : Duration.zero,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: intensity,
          colors: palette.map((c) => c.withOpacity(0.3 * intensity)).toList(),
          stops: List.generate(palette.length, (i) => i / (palette.length - 1)),
        ),
      ),
      child: child,
    );
  }

  void dispose() {
    _morphTimer?.cancel();
  }
}

/// Breathing Animation Engine
class BreathingAnimationEngine {
  bool _isInitialized = false;
  final List<AnimationController> _controllers = [];

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    AppLogger.success('🫁 Breathing Animation Engine initialized');
  }

  Widget createBreathingWidget({
    BreathingPattern pattern = BreathingPattern.relaxation,
    double size = 200,
    Color? color,
    VoidCallback? onCycleComplete,
  }) {
    return BreathingAnimationWidget(
      pattern: pattern,
      size: size,
      color: color ?? Colors.blue.withValues(alpha: 0.1),
      onCycleComplete: onCycleComplete,
    );
  }

  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
  }
}

/// Wellness Data Visualization
class WellnessVisualization {
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    AppLogger.success('📊 Wellness Visualization initialized');
  }

  Widget createChart({
    required String userId,
    WellnessChartType type = WellnessChartType.moodTrend,
    int daysBack = 14,
    double height = 200,
    Color? accentColor,
  }) {
    return FutureBuilder<List<FeelingsDataPoint>>(
      future: _getWellnessData(userId, daysBack, type),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return WellnessChartWidget(
          data: snapshot.data!,
          type: type,
          height: height,
          accentColor: accentColor ?? Theme.of(context).primaryColor,
        );
      },
    );
  }

  Future<List<FeelingsDataPoint>> _getWellnessData(
    String userId,
    int daysBack,
    WellnessChartType type,
  ) async {
    final tracker = DailyFeelingsTracker.instance;
    return tracker.getFeelingsPattern(
      userId: userId,
      daysBack: daysBack,
    );
  }

  void dispose() {
    // Cleanup if needed
  }
}

/// Biometric Data Renderer
class BiometricsRenderer {
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    AppLogger.success('💓 Biometrics Renderer initialized');
  }

  Widget createParticleSystem({
    BiometricVisualization type = BiometricVisualization.heartRate,
    double? value,
    Color? color,
    Size size = const Size(300, 300),
  }) {
    return BiometricParticleSystem(
      type: type,
      value: value ?? _getDefaultValue(type),
      color: color ?? _getDefaultColor(type),
      size: size,
    );
  }

  double _getDefaultValue(BiometricVisualization type) {
    switch (type) {
      case BiometricVisualization.heartRate:
        return 75.0; // BPM
      case BiometricVisualization.breathingRate:
        return 16.0; // Breaths per minute
      case BiometricVisualization.stressLevel:
        return 0.3; // 0-1 scale
      case BiometricVisualization.energy:
        return 0.7; // 0-1 scale
    }
  }

  Color _getDefaultColor(BiometricVisualization type) {
    switch (type) {
      case BiometricVisualization.heartRate:
        return Colors.red.withValues(alpha: 0.1);
      case BiometricVisualization.breathingRate:
        return Colors.blue.withValues(alpha: 0.1);
      case BiometricVisualization.stressLevel:
        return Colors.orange.withValues(alpha: 0.1);
      case BiometricVisualization.energy:
        return Colors.green.withValues(alpha: 0.1);
    }
  }

  void dispose() {
    // Cleanup if needed
  }
}

// Custom Widgets

/// Breathing Animation Widget
class BreathingAnimationWidget extends StatefulWidget {
  final BreathingPattern pattern;
  final double size;
  final Color color;
  final VoidCallback? onCycleComplete;

  const BreathingAnimationWidget({
    super.key,
    required this.pattern,
    required this.size,
    required this.color,
    this.onCycleComplete,
  });

  @override
  State<BreathingAnimationWidget> createState() => _BreathingAnimationWidgetState();
}

class _BreathingAnimationWidgetState extends State<BreathingAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    final duration = _getPatternDuration(widget.pattern);
    _controller = AnimationController(duration: duration, vsync: this);

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.4,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCycleComplete?.call();
      }
    });

    _controller.repeat(reverse: true);
  }

  Duration _getPatternDuration(BreathingPattern pattern) {
    switch (pattern) {
      case BreathingPattern.relaxation:
        return const Duration(seconds: 4); // 4-4-4 breathing
      case BreathingPattern.energy:
        return const Duration(seconds: 2); // Quick energizing breath
      case BreathingPattern.focus:
        return const Duration(seconds: 6); // Deep focus breathing
      case BreathingPattern.sleep:
        return const Duration(seconds: 8); // Slow sleep breathing
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring
              Transform.scale(
                scale: _scaleAnimation.value * 1.2,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.color.withOpacity(_opacityAnimation.value * 0.3),
                      width: 2,
                    ),
                  ),
                ),
              ),
              // Inner circle
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: widget.size * 0.6,
                  height: widget.size * 0.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withOpacity(_opacityAnimation.value),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
              // Center dot
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Wave Animation Widget
class WaveAnimationWidget extends StatefulWidget {
  final double height;
  final Color color;
  final double frequency;
  final double amplitude;
  final Duration period;

  const WaveAnimationWidget({
    super.key,
    required this.height,
    required this.color,
    required this.frequency,
    required this.amplitude,
    required this.period,
  });

  @override
  State<WaveAnimationWidget> createState() => _WaveAnimationWidgetState();
}

class _WaveAnimationWidgetState extends State<WaveAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.period, vsync: this);
    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(double.infinity, widget.height),
          painter: WavePainter(
            animationValue: _controller.value,
            color: widget.color,
            frequency: widget.frequency,
            amplitude: widget.amplitude,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Wave Painter
class WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final double frequency;
  final double amplitude;

  WavePainter({
    required this.animationValue,
    required this.color,
    required this.frequency,
    required this.amplitude,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    final waveHeight = size.height * amplitude;
    final centerY = size.height / 2;
    final phase = animationValue * 2 * math.pi;

    path.moveTo(0, centerY);

    for (double x = 0; x <= size.width; x += 1) {
      final y = centerY + waveHeight * math.sin((x / size.width) * frequency * 2 * math.pi + phase);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Wellness Chart Widget
class WellnessChartWidget extends StatelessWidget {
  final List<FeelingsDataPoint> data;
  final WellnessChartType type;
  final double height;
  final Color accentColor;

  const WellnessChartWidget({
    super.key,
    required this.data,
    required this.type,
    required this.height,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: CustomPaint(
        size: Size(double.infinity, height),
        painter: WellnessChartPainter(
          data: data,
          color: accentColor,
        ),
      ),
    );
  }
}

/// Wellness Chart Painter
class WellnessChartPainter extends CustomPainter {
  final List<FeelingsDataPoint> data;
  final Color color;

  WellnessChartPainter({
    required this.data,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    final stepX = size.width / (data.length - 1);

    // Find min/max for scaling
    final scores = data.map((d) => d.score).toList();
    final minScore = scores.reduce(math.min);
    final maxScore = scores.reduce(math.max);
    final scoreRange = maxScore - minScore;

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normalizedScore = scoreRange > 0 
          ? (data[i].score - minScore) / scoreRange
          : 0.5;
      final y = size.height - (normalizedScore * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Draw point
      canvas.drawCircle(Offset(x, y), 4, 
          Paint()..color = color..style = PaintingStyle.fill);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Biometric Particle System
class BiometricParticleSystem extends StatefulWidget {
  final BiometricVisualization type;
  final double value;
  final Color color;
  final Size size;

  const BiometricParticleSystem({
    super.key,
    required this.type,
    required this.value,
    required this.color,
    required this.size,
  });

  @override
  State<BiometricParticleSystem> createState() => _BiometricParticleSystemState();
}

class _BiometricParticleSystemState extends State<BiometricParticleSystem>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _generateParticles();
    _controller.repeat();
  }

  void _generateParticles() {
    final particleCount = _getParticleCount();
    final random = math.Random();

    for (int i = 0; i < particleCount; i++) {
      _particles.add(Particle(
        x: random.nextDouble() * widget.size.width,
        y: random.nextDouble() * widget.size.height,
        size: random.nextDouble() * 6 + 2,
        speed: random.nextDouble() * 2 + 1,
        opacity: random.nextDouble() * 0.7 + 0.3,
      ));
    }
  }

  int _getParticleCount() {
    switch (widget.type) {
      case BiometricVisualization.heartRate:
        return (widget.value / 10).round().clamp(5, 20);
      case BiometricVisualization.breathingRate:
        return (widget.value * 2).round().clamp(8, 30);
      case BiometricVisualization.stressLevel:
        return (widget.value * 50).round().clamp(10, 40);
      case BiometricVisualization.energy:
        return (widget.value * 30).round().clamp(15, 50);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: widget.size,
          painter: ParticlePainter(
            particles: _particles,
            color: widget.color,
            animationValue: _controller.value,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Particle Model
class Particle {
  double x, y;
  final double size;
  final double speed;
  final double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

/// Particle Painter
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Color color;
  final double animationValue;

  ParticlePainter({
    required this.particles,
    required this.color,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = color.withOpacity(particle.opacity * (0.5 + 0.5 * math.sin(animationValue * 2 * math.pi)))
        ..style = PaintingStyle.fill;

      // Update particle position based on animation
      final animatedY = particle.y + (particle.speed * animationValue * 50) % size.height;
      
      canvas.drawCircle(
        Offset(particle.x, animatedY),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Enums

enum MoodState {
  joyful,
  calm,
  energetic,
  reflective,
  peaceful,
  melancholy,
  neutral,
}

enum BreathingPattern {
  relaxation,
  energy,
  focus,
  sleep,
}

enum WellnessChartType {
  moodTrend,
  weeklyAverage,
  completionRate,
  insights,
}

enum BiometricVisualization {
  heartRate,
  breathingRate,
  stressLevel,
  energy,
}
