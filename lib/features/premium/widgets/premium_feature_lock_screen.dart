import 'dart:ui';

import 'package:flutter/material.dart';

class PremiumLockFeature {
  final IconData icon;
  final String title;
  final String description;

  const PremiumLockFeature({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class PremiumFeatureLockScreen extends StatefulWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final List<PremiumLockFeature> features;
  final VoidCallback onBack;
  final VoidCallback onUpgrade;

  const PremiumFeatureLockScreen({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.features,
    required this.onBack,
    required this.onUpgrade,
  });

  @override
  State<PremiumFeatureLockScreen> createState() =>
      _PremiumFeatureLockScreenState();
}

class _PremiumFeatureLockScreenState extends State<PremiumFeatureLockScreen> {
  bool _entered = false;

  static const _background = Color(0xFF130C1B);
  static const _surface = Color(0xFF1F162B);
  static const _surfaceElevated = Color(0xFF251735);
  static const _pink = Color(0xFFFF5FA2);
  static const _purple = Color(0xFFD88EFF);
  static const _accent = Color(0xFFA855F7);

  static const _gradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [_pink, _purple],
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _entered = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final compact = media.size.height < 720;

    return Scaffold(
      backgroundColor: _background,
      body: Stack(
        children: [
          const Positioned.fill(child: _PremiumAmbientBackground()),
          SafeArea(
            child: AnimatedOpacity(
              opacity: _entered ? 1 : 0,
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOut,
              child: AnimatedSlide(
                offset: _entered ? Offset.zero : const Offset(0, 0.025),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _TopBar(onBack: widget.onBack)),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        compact ? 8 : 16,
                        20,
                        24,
                      ),
                      sliver: SliverList.list(
                        children: [
                          const _PremiumAnalyticsHero(),
                          SizedBox(height: compact ? 20 : 28),
                          _ProBadge(label: widget.eyebrow),
                          const SizedBox(height: 14),
                          Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: compact ? 28 : 32,
                              height: 1.08,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.9,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.70),
                              fontSize: 16,
                              height: 1.48,
                            ),
                          ),
                          SizedBox(height: compact ? 24 : 30),
                          ...widget.features.map(
                            (feature) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _FeatureGlassCard(feature: feature),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _UpgradeButton(onPressed: widget.onUpgrade),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: widget.onBack,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white.withValues(
                                alpha: 0.72,
                              ),
                            ),
                            child: const Text(
                              'Maybe Later',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const _TrustRow(),
                          const SizedBox(height: 26),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: Colors.white,
          ),
          const Expanded(
            child: Text(
              'Advanced Analytics Premium',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _ProBadge extends StatelessWidget {
  final String label;

  const _ProBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: _PremiumFeatureLockScreenState._gradient,
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4DFF5FA2),
              blurRadius: 24,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumAnalyticsHero extends StatelessWidget {
  const _PremiumAnalyticsHero();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Preview of premium analytics visualizations',
      image: true,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 430),
          height: 220,
          decoration: BoxDecoration(
            color: _PremiumFeatureLockScreenState._surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.11)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33FF5FA2),
                blurRadius: 48,
                spreadRadius: 3,
              ),
              BoxShadow(
                color: Color(0x26A855F7),
                blurRadius: 72,
                offset: Offset(0, 20),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: CustomPaint(
                    painter: _PremiumAnalyticsPreviewPainter(),
                  ),
                ),
                Positioned(
                  left: 18,
                  top: 18,
                  child: _MiniGlassLabel(
                    icon: Icons.auto_graph_rounded,
                    text: 'Pattern preview',
                  ),
                ),
                Positioned(
                  right: 18,
                  top: 18,
                  child: _MiniGlassLabel(
                    icon: Icons.lock_rounded,
                    text: 'Premium',
                  ),
                ),
                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 16,
                  child: Row(
                    children: const [
                      Expanded(
                        child: _MiniMetric(
                          label: 'CYCLE',
                          value: 'Patterns',
                          icon: Icons.timeline_rounded,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _MiniMetric(
                          label: 'MOOD',
                          value: 'Trends',
                          icon: Icons.insights_rounded,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _MiniMetric(
                          label: 'REPORTS',
                          value: 'Deeper',
                          icon: Icons.analytics_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniGlassLabel extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniGlassLabel({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: _PremiumFeatureLockScreenState._purple,
              ),
              const SizedBox(width: 6),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MiniMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xD9251735),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _PremiumFeatureLockScreenState._pink),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureGlassCard extends StatelessWidget {
  final PremiumLockFeature feature;

  const _FeatureGlassCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.055),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: _PremiumFeatureLockScreenState._gradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(color: Color(0x33FF5FA2), blurRadius: 18),
                  ],
                ),
                child: Icon(feature.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      feature.description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.62),
                        height: 1.35,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpgradeButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _UpgradeButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Unlock Premium',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(22),
          child: Ink(
            height: 58,
            decoration: BoxDecoration(
              gradient: _PremiumFeatureLockScreenState._gradient,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x55FF5FA2),
                  blurRadius: 28,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium_rounded, color: Colors.white),
                  SizedBox(width: 9),
                  Text(
                    'Unlock Premium',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrustRow extends StatelessWidget {
  const _TrustRow();

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: Colors.white.withValues(alpha: 0.48),
      fontSize: 11,
      height: 1.4,
      fontWeight: FontWeight.w500,
    );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              size: 14,
              color: Color(0xFFD88EFF),
            ),
            const SizedBox(width: 6),
            Text('Secure and private', style: style),
            const SizedBox(width: 14),
            const Icon(
              Icons.health_and_safety_outlined,
              size: 14,
              color: Color(0xFFD88EFF),
            ),
            const SizedBox(width: 6),
            Text('Not medical advice', style: style),
          ],
        ),
        const SizedBox(height: 7),
        Text(
          'Explore deeper insights from the health data you choose to track.',
          textAlign: TextAlign.center,
          style: style,
        ),
      ],
    );
  }
}

class _PremiumAmbientBackground extends StatelessWidget {
  const _PremiumAmbientBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: _PremiumFeatureLockScreenState._background,
        gradient: RadialGradient(
          center: Alignment(-0.7, -0.65),
          radius: 1.15,
          colors: [Color(0x33251735), Color(0x221F162B), Color(0xFF130C1B)],
          stops: [0, 0.48, 1],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 90,
            right: -90,
            child: _GlowOrb(
              size: 250,
              color: _PremiumFeatureLockScreenState._pink,
            ),
          ),
          Positioned(
            top: 370,
            left: -120,
            child: _GlowOrb(
              size: 280,
              color: _PremiumFeatureLockScreenState._accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.18),
        ),
      ),
    );
  }
}

class _PremiumAnalyticsPreviewPainter extends CustomPainter {
  const _PremiumAnalyticsPreviewPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    for (var i = 1; i < 6; i++) {
      final y = size.height * (0.18 + i * 0.105);
      canvas.drawLine(Offset(18, y), Offset(size.width - 18, y), grid);
    }

    final glow = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF5FA2), Color(0xFFD88EFF), Color(0xFFA855F7)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final line = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF5FA2), Color(0xFFD88EFF), Color(0xFFA855F7)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.06, size.height * 0.54)
      ..cubicTo(
        size.width * 0.19,
        size.height * 0.42,
        size.width * 0.26,
        size.height * 0.58,
        size.width * 0.38,
        size.height * 0.44,
      )
      ..cubicTo(
        size.width * 0.50,
        size.height * 0.30,
        size.width * 0.60,
        size.height * 0.52,
        size.width * 0.70,
        size.height * 0.36,
      )
      ..cubicTo(
        size.width * 0.80,
        size.height * 0.20,
        size.width * 0.89,
        size.height * 0.38,
        size.width * 0.96,
        size.height * 0.26,
      );

    canvas.drawPath(path, glow);
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
