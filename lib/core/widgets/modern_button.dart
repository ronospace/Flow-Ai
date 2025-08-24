import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

enum ModernButtonType {
  primary,
  secondary,
  success,
  warning,
  danger,
  outline,
  ghost,
}

enum ModernButtonSize {
  small,
  medium,
  large,
}

class ModernButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ModernButtonType type;
  final ModernButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final List<Color>? gradientColors;

  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ModernButtonType.primary,
    this.size = ModernButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    this.padding,
    this.borderRadius,
    this.gradientColors,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _animationController.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _resetPress();
  }

  void _onTapCancel() {
    _resetPress();
  }

  void _resetPress() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.isLoading ? null : widget.onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.isExpanded ? double.infinity : null,
              height: _getHeight(),
              padding: widget.padding ?? _getPadding(),
              decoration: _getDecoration(theme, isEnabled),
              child: _buildContent(theme, isEnabled),
            ),
          ),
        );
      },
    );
  }

  double _getHeight() {
    switch (widget.size) {
      case ModernButtonSize.small:
        return 36;
      case ModernButtonSize.medium:
        return 44;
      case ModernButtonSize.large:
        return 48;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (widget.size) {
      case ModernButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case ModernButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ModernButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 10);
    }
  }

  BoxDecoration _getDecoration(ThemeData theme, bool isEnabled) {
    final colors = widget.gradientColors ?? _getGradientColors();
    
    switch (widget.type) {
      case ModernButtonType.primary:
        return BoxDecoration(
          gradient: isEnabled 
              ? LinearGradient(colors: colors)
              : LinearGradient(colors: [AppTheme.lightGrey, AppTheme.lightGrey]),
          borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
          boxShadow: isEnabled ? [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : null,
        );
        
      case ModernButtonType.secondary:
        return BoxDecoration(
          color: isEnabled ? theme.cardColor : AppTheme.lightGrey,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
          border: Border.all(
            color: isEnabled ? theme.dividerColor : AppTheme.lightGrey,
            width: 1,
          ),
          boxShadow: isEnabled ? [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        );
        
      case ModernButtonType.success:
        return BoxDecoration(
          gradient: isEnabled 
              ? const LinearGradient(colors: [AppTheme.successGreen, Color(0xFF4CAF50)])
              : LinearGradient(colors: [AppTheme.lightGrey, AppTheme.lightGrey]),
          borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
          boxShadow: isEnabled ? [
            BoxShadow(
              color: AppTheme.successGreen.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : null,
        );
        
      case ModernButtonType.warning:
        return BoxDecoration(
          gradient: isEnabled 
              ? const LinearGradient(colors: [AppTheme.warningOrange, Color(0xFFFF9800)])
              : LinearGradient(colors: [AppTheme.lightGrey, AppTheme.lightGrey]),
          borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
          boxShadow: isEnabled ? [
            BoxShadow(
              color: AppTheme.warningOrange.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : null,
        );
        
      case ModernButtonType.danger:
        return BoxDecoration(
          gradient: isEnabled 
              ? const LinearGradient(colors: [Colors.red, Color(0xFFE53E3E)])
              : LinearGradient(colors: [AppTheme.lightGrey, AppTheme.lightGrey]),
          borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
          boxShadow: isEnabled ? [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : null,
        );
        
      case ModernButtonType.outline:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
          border: Border.all(
            color: isEnabled ? colors.first : AppTheme.lightGrey,
            width: 2,
          ),
        );
        
      case ModernButtonType.ghost:
        return BoxDecoration(
          color: isEnabled ? colors.first.withValues(alpha: 0.1) : AppTheme.lightGrey.withValues(alpha: 0.1),
          borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
        );
    }
  }

  List<Color> _getGradientColors() {
    switch (widget.type) {
      case ModernButtonType.primary:
        return [AppTheme.primaryRose, AppTheme.primaryPurple];
      case ModernButtonType.secondary:
        return [AppTheme.secondaryBlue, AppTheme.accentMint];
      case ModernButtonType.success:
        return [AppTheme.successGreen, const Color(0xFF4CAF50)];
      case ModernButtonType.warning:
        return [AppTheme.warningOrange, const Color(0xFFFF9800)];
      case ModernButtonType.danger:
        return [Colors.red, const Color(0xFFE53E3E)];
      case ModernButtonType.outline:
      case ModernButtonType.ghost:
        return [AppTheme.primaryRose, AppTheme.primaryPurple];
    }
  }

  Widget _buildContent(ThemeData theme, bool isEnabled) {
    final textColor = _getTextColor(theme, isEnabled);
    final fontSize = _getFontSize();
    
    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: fontSize,
          height: fontSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(textColor),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: widget.isExpanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            color: textColor,
            size: fontSize,
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.text,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Color _getTextColor(ThemeData theme, bool isEnabled) {
    if (!isEnabled) {
      return AppTheme.mediumGrey;
    }
    
    switch (widget.type) {
      case ModernButtonType.secondary:
        return theme.textTheme.titleMedium?.color ?? AppTheme.darkGrey;
      case ModernButtonType.outline:
        return _getGradientColors().first;
      case ModernButtonType.ghost:
        return _getGradientColors().first;
      default:
        return Colors.white;
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case ModernButtonSize.small:
        return 14;
      case ModernButtonSize.medium:
        return 16;
      case ModernButtonSize.large:
        return 18;
    }
  }
}

// Convenience constructors for common button types
class ModernButtons {
  static Widget primary({
    required String text,
    required VoidCallback? onPressed,
    ModernButtonSize size = ModernButtonSize.medium,
    IconData? icon,
    bool isLoading = false,
    bool isExpanded = false,
  }) {
    return ModernButton(
      text: text,
      onPressed: onPressed,
      type: ModernButtonType.primary,
      size: size,
      icon: icon,
      isLoading: isLoading,
      isExpanded: isExpanded,
    );
  }

  static Widget success({
    required String text,
    required VoidCallback? onPressed,
    ModernButtonSize size = ModernButtonSize.medium,
    IconData? icon,
    bool isLoading = false,
    bool isExpanded = false,
  }) {
    return ModernButton(
      text: text,
      onPressed: onPressed,
      type: ModernButtonType.success,
      size: size,
      icon: icon,
      isLoading: isLoading,
      isExpanded: isExpanded,
    );
  }

  static Widget secondary({
    required String text,
    required VoidCallback? onPressed,
    ModernButtonSize size = ModernButtonSize.medium,
    IconData? icon,
    bool isLoading = false,
    bool isExpanded = false,
  }) {
    return ModernButton(
      text: text,
      onPressed: onPressed,
      type: ModernButtonType.secondary,
      size: size,
      icon: icon,
      isLoading: isLoading,
      isExpanded: isExpanded,
    );
  }

  static Widget outline({
    required String text,
    required VoidCallback? onPressed,
    ModernButtonSize size = ModernButtonSize.medium,
    IconData? icon,
    bool isLoading = false,
    bool isExpanded = false,
  }) {
    return ModernButton(
      text: text,
      onPressed: onPressed,
      type: ModernButtonType.outline,
      size: size,
      icon: icon,
      isLoading: isLoading,
      isExpanded: isExpanded,
    );
  }
}
