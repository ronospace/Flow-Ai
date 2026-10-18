import 'package:flutter/material.dart';

/// Central Flow Ai brand mark.
///
/// Uses the canonical production launch logo asset so every caller receives
/// the same visual identity.
class FlowAiLogo extends StatelessWidget {
  const FlowAiLogo({
    super.key,
    this.size = 100.0,
    this.showWordmark = true,
    this.layout = LogoLayout.horizontal,
    this.color,
    this.onTap,
  });

  final double size;
  final bool showWordmark;
  final LogoLayout layout;

  /// Retained for API compatibility with existing callers.
  ///
  /// The canonical image owns its production colors.
  final Color? color;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final icon = ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.25),
      child: Image.asset(
        'assets/images/flow_ai_launch_logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        semanticLabel: 'Flow Ai',
      ),
    );

    Widget content;

    if (!showWordmark) {
      content = icon;
    } else {
      final wordmark = Text(
        'Flow Ai',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      );

      content = switch (layout) {
        LogoLayout.horizontal => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            SizedBox(width: size * 0.2),
            wordmark,
          ],
        ),
        LogoLayout.vertical => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            SizedBox(height: size * 0.1),
            wordmark,
          ],
        ),
      };
    }

    if (onTap == null) {
      return content;
    }

    return GestureDetector(onTap: onTap, child: content);
  }
}

enum LogoLayout { horizontal, vertical }
