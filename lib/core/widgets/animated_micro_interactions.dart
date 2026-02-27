import 'dart:ui' show ImageFilter;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:confetti/confetti.dart';

/// Advanced Micro-Interaction Widgets
/// Provides delightful, futuristic animations for user interactions

/// Shimmer loading effect
class ShimmerLoadingWidget extends StatelessWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerLoadingWidget({
    Key? key,
    required this.child,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 1500),
      child: child,
    );
  }
}

/// Confetti celebration effect
class ConfettiCelebration extends StatefulWidget {
  final Widget child;
  final bool isPlaying;
  final Duration duration;

  const ConfettiCelebration({
    Key? key,
    required this.child,
    this.isPlaying = false,
    this.duration = const Duration(seconds: 3),
  }) : super(key: key);

  @override
  State<ConfettiCelebration> createState() => _ConfettiCelebrationState();
}

class _ConfettiCelebrationState extends State<ConfettiCelebration> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: widget.duration);
    if (widget.isPlaying) {
      _confettiController.play();
    }
  }

  @override
  void didUpdateWidget(ConfettiCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _confettiController.play();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _confettiController.stop();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.1,
            colors: const [
              Color(0xFFC147E9),
              Color(0xFF4F46E5),
              Color(0xFF10B981),
              Color(0xFFF59E0B),
            ],
          ),
        ),
      ],
    );
  }
}

/// Magnetic button with haptic-like visual feedback
class MagneticButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double magneticDistance;

  const MagneticButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.magneticDistance = 20.0,
  }) : super(key: key);

  @override
  State<MagneticButton> createState() => _MagneticButtonState();
}

class _MagneticButtonState extends State<MagneticButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  Offset _offset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      final dx = details.localPosition.dx - widget.magneticDistance / 2;
      final dy = details.localPosition.dy - widget.magneticDistance / 2;

      // Calculate distance from center
      final distance = math.sqrt(dx * dx + dy * dy);

      if (distance < widget.magneticDistance) {
        // Apply magnetic effect
        _offset = Offset(
          dx * (1 - distance / widget.magneticDistance),
          dy * (1 - distance / widget.magneticDistance),
        );
      } else {
        _offset = Offset.zero;
      }
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      _offset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () => _controller.reverse(),
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: _offset,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

/// Glassmorphism card with blur effect
class GlassmorphismCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;

  const GlassmorphismCard({
    Key? key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(opacity),
              borderRadius: borderRadius ?? BorderRadius.circular(20),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Pulse animation widget
class PulseWidget extends StatefulWidget {
  final Widget child;
  final Color pulseColor;
  final Duration duration;

  const PulseWidget({
    Key? key,
    required this.child,
    this.pulseColor = const Color(0xFFC147E9),
    this.duration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  State<PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<PulseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.pulseColor.withOpacity(
                    0.5 * (1 - _animation.value),
                  ),
                  blurRadius: 20 * _animation.value,
                  spreadRadius: 5 * _animation.value,
                ),
              ],
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}
