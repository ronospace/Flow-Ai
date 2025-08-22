import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

/// Comprehensive app enhancements to make the FlowSense app more captivating
class AppEnhancements {
  
  /// Enhanced haptic feedback system
  static void lightHaptic() {
    HapticFeedback.lightImpact();
  }
  
  static void mediumHaptic() {
    HapticFeedback.mediumImpact();
  }
  
  static void heavyHaptic() {
    HapticFeedback.heavyImpact();
  }
  
  static void successHaptic() {
    HapticFeedback.mediumImpact();
  }
  
  static void errorHaptic() {
    HapticFeedback.heavyImpact();
  }
  
  static void selectionHaptic() {
    HapticFeedback.selectionClick();
  }
  
  /// Enhanced loading animations
  static Widget buildEnhancedLoader({
    Color? primaryColor,
    Color? secondaryColor,
    String? message,
    double size = 50.0,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    primaryColor ?? AppTheme.primaryRose,
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                .rotate(duration: 2000.ms),
              
              // Inner pulsing dot
              Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: secondaryColor ?? AppTheme.accentMint,
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.0, 1.0))
                .then(delay: 500.ms)
                .scale(begin: const Offset(1.0, 1.0), end: const Offset(0.5, 0.5)),
            ],
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.mediumGrey,
            ),
            textAlign: TextAlign.center,
          ).animate(onPlay: (controller) => controller.repeat())
            .fadeIn(duration: 1000.ms)
            .then(delay: 500.ms)
            .fadeOut(duration: 1000.ms),
        ],
      ],
    );
  }
  
  /// Enhanced button with micro-interactions
  static Widget buildEnhancedButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    double borderRadius = 16.0,
    EdgeInsetsGeometry? padding,
    bool isLoading = false,
    bool isEnabled = true,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        onPressed: isEnabled && !isLoading ? () {
          AppEnhancements.selectionHaptic();
          onPressed();
        } : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppTheme.primaryRose,
          foregroundColor: textColor ?? Colors.white,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: isEnabled ? 8 : 2,
          shadowColor: backgroundColor?.withValues(alpha: 0.3) ?? AppTheme.primaryRose.withValues(alpha: 0.3),
        ),
        child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(textColor ?? Colors.white),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
      ),
    ).animate()
      .scale(delay: 100.ms, duration: 200.ms)
      .fadeIn(duration: 300.ms);
  }
  
  /// Enhanced card with beautiful shadows and animations
  static Widget buildEnhancedCard({
    required Widget child,
    Color? backgroundColor,
    double borderRadius = 20.0,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    bool showShadow = true,
    List<Color>? gradientColors,
  }) {
    return Container(
      margin: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap != null ? () {
            AppEnhancements.lightHaptic();
            onTap();
          } : null,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: gradientColors == null ? (backgroundColor ?? Colors.white) : null,
              gradient: gradientColors != null ? LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ) : null,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: showShadow ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.5),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ] : null,
            ),
            child: child,
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 400.ms)
      .slideY(begin: 0.1, end: 0, duration: 400.ms);
  }
  
  /// Enhanced success animation
  static Widget buildSuccessAnimation({
    String? message,
    double size = 100.0,
    VoidCallback? onComplete,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.successGreen.withValues(alpha: 0.1),
            border: Border.all(
              color: AppTheme.successGreen,
              width: 3,
            ),
          ),
          child: Icon(
            Icons.check_rounded,
            color: AppTheme.successGreen,
            size: size * 0.6,
          ),
        ).animate(onComplete: (_) => onComplete?.call())
          .scale(begin: const Offset(0, 0), duration: 300.ms, curve: Curves.elasticOut)
          .then(delay: 200.ms)
          .shake(hz: 2, curve: Curves.easeInOut),
        
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.successGreen,
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 300.ms)
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.3, end: 0),
        ],
      ],
    );
  }
  
  /// Enhanced error animation
  static Widget buildErrorAnimation({
    String? message,
    double size = 100.0,
    VoidCallback? onComplete,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.warningOrange.withValues(alpha: 0.1),
            border: Border.all(
              color: AppTheme.warningOrange,
              width: 3,
            ),
          ),
          child: Icon(
            Icons.close_rounded,
            color: AppTheme.warningOrange,
            size: size * 0.6,
          ),
        ).animate(onComplete: (_) => onComplete?.call())
          .scale(begin: const Offset(0, 0), duration: 300.ms, curve: Curves.elasticOut)
          .then(delay: 200.ms)
          .shake(hz: 3, curve: Curves.easeInOut),
        
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.warningOrange,
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 300.ms)
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.3, end: 0),
        ],
      ],
    );
  }
  
  /// Enhanced input field with beautiful styling
  static Widget buildEnhancedTextField({
    required String hintText,
    required TextEditingController controller,
    IconData? prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onSuffixIconTap,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Function(String)? onChanged,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        maxLines: maxLines,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppTheme.mediumGrey) : null,
          suffixIcon: suffixIcon != null ? IconButton(
            onPressed: onSuffixIconTap,
            icon: Icon(suffixIcon, color: AppTheme.mediumGrey),
          ) : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppTheme.lightGrey.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppTheme.primaryRose,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppTheme.warningOrange,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .slideX(begin: 0.1, end: 0);
  }
  
  /// Enhanced page transitions
  static Route<T> createEnhancedRoute<T extends Object?>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOutCubic;
        
        final slideAnimation = animation.drive(
          Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: curve)),
        );
        
        final fadeAnimation = animation.drive(
          Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: curve)),
        );
        
        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }
}
