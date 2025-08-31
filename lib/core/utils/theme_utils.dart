import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Utility class for theme-aware color handling and dark mode consistency
class ThemeUtils {
  /// Get theme-aware text color for primary content
  static Color getPrimaryTextColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark 
        ? AppTheme.darkText 
        : AppTheme.lightText;
  }
  
  /// Get theme-aware text color for secondary content
  static Color getSecondaryTextColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark 
        ? AppTheme.darkTextSecondary 
        : AppTheme.lightTextSecondary;
  }
  
  /// Get theme-aware background color
  static Color getBackgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark 
        ? AppTheme.darkBackground 
        : AppTheme.lightBackground;
  }
  
  /// Get theme-aware surface color
  static Color getSurfaceColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark 
        ? AppTheme.darkSurface 
        : AppTheme.lightSurface;
  }
  
  /// Get theme-aware card color
  static Color getCardColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark 
        ? AppTheme.darkCard 
        : AppTheme.lightCard;
  }
  
  /// Get theme-aware white color (for icons, text on colored backgrounds)
  static Color getOnPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.onPrimary;
  }
  
  /// Get theme-aware shadow color
  static Color getShadowColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark 
        ? Colors.black.withValues(alpha: 0.5)
        : Colors.black.withValues(alpha: 0.1);
  }
  
  /// Get theme-aware container background with opacity
  static Color getContainerColor(BuildContext context, {double opacity = 0.9}) {
    return Theme.of(context).cardColor.withValues(alpha: opacity);
  }
  
  /// Get theme-aware border color
  static Color getBorderColor(BuildContext context, {double opacity = 0.2}) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark 
        ? AppTheme.darkTextSecondary.withValues(alpha: opacity)
        : AppTheme.lightTextSecondary.withValues(alpha: opacity);
  }
  
  /// Get theme-aware divider color
  static Color getDividerColor(BuildContext context) {
    return Theme.of(context).dividerColor;
  }
  
  /// Get theme-aware overlay color for modal backgrounds
  static Color getOverlayColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark 
        ? Colors.black.withValues(alpha: 0.8)
        : Colors.black.withValues(alpha: 0.5);
  }
  
  /// Get theme-aware gradient colors for backgrounds
  static List<Color> getBackgroundGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark 
        ? [AppTheme.darkBackground, AppTheme.darkSurface]
        : [const Color(0xFFFFF8F9), AppTheme.lightSurface];
  }
  
  /// Get theme-aware colors for success states
  static Color getSuccessColor(BuildContext context) {
    return AppTheme.successGreen;
  }
  
  /// Get theme-aware colors for warning states
  static Color getWarningColor(BuildContext context) {
    return AppTheme.warningOrange;
  }
  
  /// Get theme-aware colors for error states
  static Color getErrorColor(BuildContext context) {
    return AppTheme.errorRed;
  }
  
  /// Apply theme-aware box shadow
  static List<BoxShadow> getBoxShadow(BuildContext context, {
    Color? color,
    double blurRadius = 10,
    Offset offset = const Offset(0, 4),
    double opacity = 0.1,
  }) {
    final shadowColor = color ?? getShadowColor(context);
    return [
      BoxShadow(
        color: shadowColor.withValues(alpha: opacity),
        blurRadius: blurRadius,
        offset: offset,
      ),
    ];
  }
  
  /// Get theme-aware colors for input fields
  static Color getInputFillColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark 
        ? AppTheme.darkSurface
        : AppTheme.lightGrey;
  }
  
  /// Get theme-aware colors for disabled states
  static Color getDisabledColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark 
        ? AppTheme.darkTextSecondary.withValues(alpha: 0.5)
        : AppTheme.lightTextSecondary.withValues(alpha: 0.5);
  }
  
  /// Helper to create theme-aware gradients with brand colors
  static LinearGradient getBrandGradient({
    List<Color>? colors,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: colors ?? [AppTheme.primaryRose, AppTheme.primaryPurple],
    );
  }
  
  /// Get adaptive color based on theme brightness
  static Color getAdaptiveColor(BuildContext context, {
    required Color lightColor,
    required Color darkColor,
  }) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark ? darkColor : lightColor;
  }
  
  /// Check if current theme is dark mode
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
  
  /// Get theme-aware icon color
  static Color getIconColor(BuildContext context, {double opacity = 1.0}) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark 
        ? AppTheme.darkText.withValues(alpha: opacity)
        : AppTheme.lightText.withValues(alpha: opacity);
  }
  
  /// Get theme-aware placeholder text color
  static Color getPlaceholderColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark 
        ? AppTheme.darkTextSecondary.withValues(alpha: 0.7)
        : AppTheme.lightTextSecondary.withValues(alpha: 0.7);
  }
}

/// Extension methods for easier theme-aware color access
extension ThemeAwareColors on BuildContext {
  /// Get primary text color
  Color get primaryTextColor => ThemeUtils.getPrimaryTextColor(this);
  
  /// Get secondary text color  
  Color get secondaryTextColor => ThemeUtils.getSecondaryTextColor(this);
  
  /// Get background color
  Color get backgroundColor => ThemeUtils.getBackgroundColor(this);
  
  /// Get surface color
  Color get surfaceColor => ThemeUtils.getSurfaceColor(this);
  
  /// Get card color
  Color get cardColor => ThemeUtils.getCardColor(this);
  
  /// Get shadow color
  Color get shadowColor => ThemeUtils.getShadowColor(this);
  
  /// Get border color
  Color get borderColor => ThemeUtils.getBorderColor(this);
  
  /// Get divider color
  Color get dividerColor => ThemeUtils.getDividerColor(this);
  
  /// Check if dark mode
  bool get isDarkMode => ThemeUtils.isDarkMode(this);
  
  /// Get icon color
  Color get iconColor => ThemeUtils.getIconColor(this);
  
  /// Get placeholder color
  Color get placeholderColor => ThemeUtils.getPlaceholderColor(this);
}
