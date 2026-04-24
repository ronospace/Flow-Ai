import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class PressableAvatar extends StatefulWidget {
  final VoidCallback onTap;
  final String? displayName;
  final String? photoUrl;

  const PressableAvatar({
    super.key,
    required this.onTap,
    this.displayName,
    this.photoUrl,
  });

  @override
  State<PressableAvatar> createState() => _PressableAvatarState();
}

class _PressableAvatarState extends State<PressableAvatar>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  late final AnimationController _ringController;
  late final Animation<double> _ringAnimation;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _ringAnimation = CurvedAnimation(
      parent: _ringController,
      curve: Curves.easeInOut,
    );
    _ringController.repeat();
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => setState(() => _scale = 0.94);
  void _onTapUp(TapUpDetails details) => setState(() => _scale = 1.0);
  void _onTapCancel() => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photoUrl = widget.photoUrl;
    final displayName = widget.displayName;

    Widget avatarContent;

    if (photoUrl != null && photoUrl.isNotEmpty) {
      avatarContent = ClipOval(
        child: Image.network(
          photoUrl,
          width: 34,
          height: 34,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackIcon(theme),
        ),
      );
    } else if (displayName != null && displayName.trim().isNotEmpty) {
      avatarContent = Text(
        displayName.trim()[0].toUpperCase(),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.primary,
        ),
      );
    } else {
      avatarContent = _fallbackIcon(theme);
    }

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _ringController,
                builder: (_, __) {
                  return CustomPaint(
                    size: const Size(48, 48),
                    painter: AvatarRingPainter(_ringAnimation.value),
                  );
                },
              ),
              ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.55),
                          const Color(0xFFF3E8FF).withOpacity(0.35),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.45),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC850F2).withOpacity(0.16),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(child: avatarContent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackIcon(ThemeData theme) {
    return Icon(
      Icons.person_rounded,
      size: 19,
      color: theme.colorScheme.primary,
    );
  }
}

class AvatarRingPainter extends CustomPainter {
  final double progress;

  AvatarRingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.width / 2) - 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: const [
          Color(0x00FF6FA5),
          Color(0xFFFF6FA5),
          Color(0xFFC850F2),
          Color(0x00C850F2),
        ],
        stops: const [0.0, 0.25, 0.5, 1.0],
        transform: GradientRotation(progress * math.pi * 2),
      ).createShader(rect);

    canvas.drawArc(
      rect,
      progress * math.pi * 2,
      math.pi * 0.55,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant AvatarRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
