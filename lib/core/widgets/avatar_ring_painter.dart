import 'dart:math' as math;
import 'package:flutter/material.dart';

class AvatarRingPainter extends CustomPainter {
  final double animation;

  AvatarRingPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final backgroundPaint = Paint()
      ..color = const Color(0xFFF6DDE8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    final arcPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF5FA2), Color(0xFFA855F7)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final startAngle = (-math.pi / 2) + (2 * math.pi * animation);
    final sweepAngle = math.pi * 1.15;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant AvatarRingPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
