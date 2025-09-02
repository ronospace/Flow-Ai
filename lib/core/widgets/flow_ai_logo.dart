import 'package:flutter/material.dart';
import 'dart:math' as math;

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
        borderRadius: BorderRadius.circular(size * 0.22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.3, 0.6, 1.0],
          colors: [
            Color(0xFFE879F9), // Bright magenta
            Color(0xFFD946EF), // Deep rose
            Color(0xFFF97316), // Orange
            Color(0xFFA855F7), // Purple
          ],
        ),
        boxShadow: [
          // Primary shadow for depth
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          // Inner highlight for 3D effect
          BoxShadow(
            color: const Color(0xFFFBBF24).withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(-2, -2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.all(size * 0.05),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.17),
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.3),
            radius: 1.2,
            colors: [
              const Color(0xFFFFFFFF).withValues(alpha: 0.8),
              const Color(0xFFF8BBD9).withValues(alpha: 0.6),
              const Color(0xFFDDD6FE).withValues(alpha: 0.4),
              const Color(0xFFE879F9).withValues(alpha: 0.2),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Enhanced flower/cycle design
            Positioned.fill(
              child: CustomPaint(
                painter: FlowAiIconPainter(size: size),
              ),
            ),
            
            // Central AI symbol with enhanced styling
            Center(
              child: Container(
                width: size * 0.32,
                height: size * 0.32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size * 0.16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFFFFF),
                      Color(0xFFF8FAFC),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1F2937).withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Enhanced AI data points with glow effect
                    Positioned(
                      left: size * 0.07,
                      top: size * 0.07,
                      child: _buildEnhancedDataPoint(size, 0),
                    ),
                    Positioned(
                      right: size * 0.07,
                      top: size * 0.07,
                      child: _buildEnhancedDataPoint(size, 1),
                    ),
                    Positioned(
                      left: size * 0.07,
                      bottom: size * 0.07,
                      child: _buildEnhancedDataPoint(size, 2),
                    ),
                    Positioned(
                      right: size * 0.07,
                      bottom: size * 0.07,
                      child: _buildEnhancedDataPoint(size, 3),
                    ),
                    
                    // Enhanced central flow symbol
                    Center(
                      child: Container(
                        width: size * 0.14,
                        height: size * 0.14,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFE879F9),
                              Color(0xFFD946EF),
                              Color(0xFFA855F7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(size * 0.07),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD946EF).withValues(alpha: 0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          size: size * 0.08,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
  
  Widget _buildEnhancedDataPoint(double parentSize, int index) {
    final colors = [
      [const Color(0xFFE879F9), const Color(0xFFD946EF)], // Magenta to rose
      [const Color(0xFFF97316), const Color(0xFFEAB308)], // Orange to yellow
      [const Color(0xFFA855F7), const Color(0xFF7C3AED)], // Purple to violet
      [const Color(0xFF06B6D4), const Color(0xFF0891B2)], // Cyan to blue
    ];
    
    return Container(
      width: parentSize * 0.05,
      height: parentSize * 0.05,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors[index % colors.length],
        ),
        borderRadius: BorderRadius.circular(parentSize * 0.025),
        boxShadow: [
          BoxShadow(
            color: colors[index % colors.length][0].withValues(alpha: 0.4),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
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

/// Custom painter for the Flow Ai icon design with enhanced dimensional effects
class FlowAiIconPainter extends CustomPainter {
  final double size;
  
  FlowAiIconPainter({required this.size});
  
  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final radius = canvasSize.width * 0.28;
    
    // Enhanced petals with multiple gradient layers for depth
    final petalColors = [
      [const Color(0xFFE879F9), const Color(0xFFD946EF)], // Magenta
      [const Color(0xFFF97316), const Color(0xFFEAB308)], // Orange  
      [const Color(0xFFA855F7), const Color(0xFF7C3AED)], // Purple
      [const Color(0xFF06B6D4), const Color(0xFF3B82F6)], // Blue
    ];
    
    // Draw 8 enhanced petals in circular arrangement
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (math.pi / 180);
      final petalCenter = Offset(
        center.dx + radius * 0.6 * math.cos(angle),
        center.dy + radius * 0.6 * math.sin(angle),
      );
      
      final colorIndex = i % petalColors.length;
      
      // Create gradient paint for each petal
      final petalPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            petalColors[colorIndex][0].withValues(alpha: 0.7),
            petalColors[colorIndex][1].withValues(alpha: 0.4),
            petalColors[colorIndex][0].withValues(alpha: 0.2),
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(
          Rect.fromCenter(
            center: petalCenter,
            width: canvasSize.width * 0.22,
            height: canvasSize.width * 0.35,
          ),
        );
      
      // Draw petal with rounded rectangle for smoother appearance
      final petalRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: petalCenter,
          width: canvasSize.width * 0.18,
          height: canvasSize.width * 0.32,
        ),
        Radius.circular(canvasSize.width * 0.08),
      );
      
      canvas.drawRRect(petalRect, petalPaint);
      
      // Add subtle highlight to each petal for 3D effect
      final highlightPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.center,
          colors: [
            Colors.white.withValues(alpha: 0.3),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCenter(
            center: Offset(
              petalCenter.dx - canvasSize.width * 0.03,
              petalCenter.dy - canvasSize.width * 0.05,
            ),
            width: canvasSize.width * 0.1,
            height: canvasSize.width * 0.15,
          ),
        );
      
      final highlightRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(
            petalCenter.dx - canvasSize.width * 0.03,
            petalCenter.dy - canvasSize.width * 0.05,
          ),
          width: canvasSize.width * 0.08,
          height: canvasSize.width * 0.12,
        ),
        Radius.circular(canvasSize.width * 0.04),
      );
      
      canvas.drawRRect(highlightRect, highlightPaint);
    }
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate is! FlowAiIconPainter || oldDelegate.size != size;
  }
}

