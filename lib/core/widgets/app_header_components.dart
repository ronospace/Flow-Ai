import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Shared app back button for full-screen detail headers.
///
/// Keeps visual navigation consistent across custom headers and AppBars.
class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.onPressed,
    this.color,
    this.iconSize = 26,
  });

  final VoidCallback? onPressed;
  final Color? color;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      color: color ?? AppTheme.primaryRose,
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      icon: Icon(Icons.arrow_back_ios_new, size: iconSize),
    );
  }
}

/// Shared fitted title/subtitle block for dense screen headers.
///
/// Titles stay on one line by scaling down inside the available width.
/// Subtitles stay on one line and ellipsize if the screen is too narrow.
/// Shared soft square icon used as a trailing header accent/action.
class AppHeaderTrailingIcon extends StatelessWidget {
  const AppHeaderTrailingIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 24,
    this.padding = 10,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: size),
    );
  }
}

class AppHeaderTextBlock extends StatelessWidget {
  const AppHeaderTextBlock({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
    this.titleSpacing = 2,
  });

  final String title;
  final String subtitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final double titleSpacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(title, maxLines: 1, style: titleStyle),
        ),
        SizedBox(height: titleSpacing),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: subtitleStyle,
        ),
      ],
    );
  }
}
