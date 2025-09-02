import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated biometric pulse indicator with real-time value display
class BiometricPulseIndicator extends StatefulWidget {
  final double value;
  final String label;
  final Color? color;
  final double size;

  const BiometricPulseIndicator({
    Key? key,
    required this.value,
    required this.label,
    this.color,
    this.size = 60.0,
  }) : super(key: key);

  @override
  State<BiometricPulseIndicator> createState() => _BiometricPulseIndicatorState();
}

class _BiometricPulseIndicatorState extends State<BiometricPulseIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));

    _startAnimations();
  }

  void _startAnimations() {
    // Pulse animation based on heart rate value
    final heartRateDelay = _calculatePulseDelay(widget.value);
    
    _pulseController.repeat(reverse: true, period: Duration(milliseconds: heartRateDelay));
    _rippleController.repeat(period: Duration(milliseconds: heartRateDelay * 2));
  }

  int _calculatePulseDelay(double value) {
    // Calculate pulse delay based on value (assuming heart rate)
    if (widget.label.toLowerCase().contains('bpm') || widget.label.toLowerCase().contains('heart')) {
      // Convert BPM to milliseconds per beat
      return (60000 / value).round().clamp(400, 2000);
    } else {
      // Default pulse for other metrics
      return 1000;
    }
  }

  @override
  void didUpdateWidget(BiometricPulseIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _pulseController.stop();
      _rippleController.stop();
      _startAnimations();
    }
  }

  @override
  Widget build(BuildContext context) {
    final indicatorColor = widget.color ?? _getColorForMetric(widget.label);

    return SizedBox(
      width: widget.size + 20,
      height: widget.size + 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ripple effect
          AnimatedBuilder(
            animation: _rippleAnimation,
            builder: (context, child) {
              return Container(
                width: (widget.size + 20) * _rippleAnimation.value,
                height: (widget.size + 20) * _rippleAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: indicatorColor.withOpacity(0.3 * (1 - _rippleAnimation.value)),
                    width: 2,
                  ),
                ),
              );
            },
          ),
          
          // Pulse indicator
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        indicatorColor.withOpacity(0.8),
                        indicatorColor.withOpacity(0.4),
                        indicatorColor.withOpacity(0.1),
                      ],
                      stops: const [0.3, 0.7, 1.0],
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: indicatorColor,
                      boxShadow: [
                        BoxShadow(
                          color: indicatorColor.withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: _buildValueDisplay(),
                  ),
                ),
              );
            },
          ),

          // Additional pulse dots
          ..._buildPulseDots(indicatorColor),
        ],
      ),
    );
  }

  Widget _buildValueDisplay() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _formatValue(widget.value),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          widget.label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 8,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildPulseDots(Color color) {
    return List.generate(3, (index) {
      final delay = index * 200.0;
      
      return AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final delayedAnimation = math.sin(
            (_pulseController.value * 2 * math.pi) - (delay / 1000 * 2 * math.pi)
          );
          
          final scale = 0.3 + (delayedAnimation.abs() * 0.2);
          final opacity = 0.3 + (delayedAnimation.abs() * 0.4);
          
          return Positioned(
            top: 5 + (index * 8.0),
            right: 5,
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(opacity),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  String _formatValue(double value) {
    if (widget.label.toLowerCase().contains('°')) {
      return value.toStringAsFixed(1);
    } else if (value >= 100) {
      return value.toStringAsFixed(0);
    } else {
      return value.toStringAsFixed(1);
    }
  }

  Color _getColorForMetric(String label) {
    final labelLower = label.toLowerCase();
    
    if (labelLower.contains('bpm') || labelLower.contains('heart')) {
      return Colors.red;
    } else if (labelLower.contains('°c') || labelLower.contains('temp')) {
      return Colors.orange;
    } else if (labelLower.contains('hrv')) {
      return Colors.blue;
    } else if (labelLower.contains('%') || labelLower.contains('sleep')) {
      return Colors.purple;
    } else if (labelLower.contains('pressure')) {
      return Colors.green;
    } else if (labelLower.contains('glucose') || labelLower.contains('blood')) {
      return Colors.cyan;
    } else {
      return Colors.pink;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }
}
