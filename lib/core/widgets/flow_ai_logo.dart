import 'package:flutter/material.dart';

/// Flow Ai Logo Widget - Provides consistent branding across the app
/// 
/// Supports different sizes, colors, and layouts for various use cases:
/// - App bars and headers
/// - Splash screens
/// - Authentication screens
/// - Settings and about pages
class FlowAiLogo extends StatelessWidget {
  const FlowAiLogo({
    super.key,
    this.size = 100.0,
    this.showWordmark = true,
    this.layout = LogoLayout.horizontal,
    this.color,
    this.onTap,
  });

  /// The size of the logo (applies to icon portion)
  final double size;
  
  /// Whether to show the text "Flow Ai" alongside the icon
  final bool showWordmark;
  
  /// Layout arrangement of icon and wordmark
  final LogoLayout layout;
  
  /// Optional color override (defaults to theme primary color)
  final Color? color;
  
  /// Optional tap handler for interactive logos
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logoColor = color ?? theme.colorScheme.primary;
    
    Widget logoContent;
    
    if (showWordmark) {
      logoContent = _buildWithWordmark(context, logoColor);
    } else {
      logoContent = _buildIconOnly(logoColor);
    }
    
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: logoContent,
      );
    }
    
    return logoContent;
  }
  
  Widget _buildIconOnly(Color logoColor) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFD946EF), // Deep Rose
            const Color(0xFFFB7185), // Soft Coral
            const Color(0xFFA855F7), // Lavender
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main flower/cycle design
          Positioned.fill(
            child: CustomPaint(
              painter: FlowAiIconPainter(),
            ),
          ),
          
          // Central AI symbol
          Center(
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(size * 0.15),
              ),
              child: Stack(
                children: [
                  // AI data points
                  Positioned(
                    left: size * 0.08,
                    top: size * 0.08,
                    child: _buildDataPoint(size),
                  ),
                  Positioned(
                    right: size * 0.08,
                    top: size * 0.08,
                    child: _buildDataPoint(size),
                  ),
                  Positioned(
                    left: size * 0.08,
                    bottom: size * 0.08,
                    child: _buildDataPoint(size),
                  ),
                  Positioned(
                    right: size * 0.08,
                    bottom: size * 0.08,
                    child: _buildDataPoint(size),
                  ),
                  
                  // Flow symbol
                  Center(
                    child: Icon(
                      Icons.auto_awesome,
                      size: size * 0.12,
                      color: const Color(0xFFD946EF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDataPoint(double parentSize) {
    return Container(
      width: parentSize * 0.04,
      height: parentSize * 0.04,
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(parentSize * 0.02),
      ),
    );
  }
  
  Widget _buildWithWordmark(BuildContext context, Color logoColor) {
    final theme = Theme.of(context);
    
    final wordmark = Text(
      'Flow Ai',
      style: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: logoColor,
        letterSpacing: -0.5,
      ),
    );
    
    final icon = _buildIconOnly(logoColor);
    
    switch (layout) {
      case LogoLayout.horizontal:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            SizedBox(width: size * 0.2),
            wordmark,
          ],
        );
        
      case LogoLayout.vertical:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            SizedBox(height: size * 0.1),
            wordmark,
          ],
        );
    }
  }
}

/// Layout options for logo presentation
enum LogoLayout {
  horizontal,
  vertical,
}

/// Custom painter for the Flow Ai icon design
class FlowAiIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;
    
    // Create petals representing cycle phases
    final petalPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFF8BBD9).withValues(alpha: 0.8),
          const Color(0xFFDDD6FE).withValues(alpha: 0.4),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    // Draw 8 petals in circular arrangement
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (3.14159 / 180); // Convert to radians
      final petalCenter = Offset(
        center.dx + radius * 0.7 * cos(angle),
        center.dy + radius * 0.7 * sin(angle),
      );
      
      canvas.drawOval(
        Rect.fromCenter(
          center: petalCenter,
          width: size.width * 0.25,
          height: size.width * 0.4,
        ),
        petalPaint,
      );
    }
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Helper function for trigonometric calculations
double cos(double radians) => 
    [1.0, 0.707, 0.0, -0.707, -1.0, -0.707, 0.0, 0.707][
      ((radians * 180 / 3.14159) / 45).round() % 8
    ];
    
double sin(double radians) =>
    [0.0, 0.707, 1.0, 0.707, 0.0, -0.707, -1.0, -0.707][
      ((radians * 180 / 3.14159) / 45).round() % 8
    ];
