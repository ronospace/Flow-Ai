import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/platform_service.dart';

/// Adaptive UI components that automatically adjust to platform conventions
class AdaptiveComponents {
  static final PlatformService _platformService = PlatformService();
  
  /// Adaptive scaffold with platform-specific navigation
  static Widget adaptiveScaffold({
    required BuildContext context,
    PreferredSizeWidget? appBar,
    Widget? body,
    Widget? floatingActionButton,
    Widget? bottomNavigationBar,
    Widget? drawer,
    Widget? endDrawer,
    Color? backgroundColor,
    bool extendBody = false,
    bool extendBodyBehindAppBar = false,
  }) {
    final platformInfo = _platformService.platformInfo;
    
    if (platformInfo.platform == TargetPlatform.iOS && platformInfo.isMobile) {
      return CupertinoPageScaffold(
        navigationBar: appBar as ObstructingPreferredSizeWidget?,
        backgroundColor: backgroundColor ?? CupertinoColors.systemBackground,
        child: SafeArea(
          child: body ?? const SizedBox.shrink(),
        ),
      );
    } else {
      return Scaffold(
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
        drawer: drawer,
        endDrawer: endDrawer,
        backgroundColor: backgroundColor,
        extendBody: extendBody,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
      );
    }
  }

  /// Adaptive app bar with platform-specific styling
  static PreferredSizeWidget adaptiveAppBar({
    required BuildContext context,
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool automaticallyImplyLeading = true,
    Color? backgroundColor,
    Color? foregroundColor,
    double? elevation,
    bool centerTitle = false,
  }) {
    final theme = Theme.of(context);
    final platformInfo = _platformService.platformInfo;
    
    if (platformInfo.platform == TargetPlatform.iOS && platformInfo.isMobile) {
      return CupertinoNavigationBar(
        middle: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: foregroundColor ?? theme.colorScheme.onSurface,
          ),
        ),
        trailing: actions != null && actions.isNotEmpty
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: actions,
              )
            : null,
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading,
        backgroundColor: backgroundColor ?? CupertinoColors.systemBackground,
      ) as PreferredSizeWidget;
    } else {
      return AppBar(
        title: Text(title),
        actions: actions,
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: elevation,
        centerTitle: centerTitle || platformInfo.platform == TargetPlatform.iOS,
        shape: platformInfo.isDesktop
            ? null
            : const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
      );
    }
  }

  /// Adaptive button with platform-specific styling
  static Widget adaptiveButton({
    required BuildContext context,
    required String text,
    required VoidCallback? onPressed,
    bool isPrimary = true,
    bool isDestructive = false,
    IconData? icon,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
  }) {
    final theme = Theme.of(context);
    final platformInfo = _platformService.platformInfo;
    
    if (platformInfo.platform == TargetPlatform.iOS && platformInfo.isMobile) {
      final buttonStyle = isDestructive
          ? CupertinoColors.destructiveRed
          : isPrimary
              ? theme.colorScheme.primary
              : CupertinoColors.systemBlue;
      
      return CupertinoButton(
        onPressed: onPressed,
        color: isPrimary ? buttonStyle : null,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: SizedBox(
          width: width,
          height: height,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: _platformService.getAdaptiveIconSize()),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isPrimary 
                      ? CupertinoColors.white 
                      : isDestructive
                          ? CupertinoColors.destructiveRed
                          : theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      final buttonStyle = _platformService.getAdaptiveButtonStyle(context);
      
      if (isPrimary) {
        return SizedBox(
          width: width,
          height: height ?? 48,
          child: ElevatedButton(
            onPressed: onPressed,
            style: buttonStyle.copyWith(
              backgroundColor: MaterialStateProperty.all(
                isDestructive ? theme.colorScheme.error : theme.colorScheme.primary,
              ),
              padding: MaterialStateProperty.all(
                padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: _platformService.getAdaptiveIconSize()),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        return SizedBox(
          width: width,
          height: height ?? 48,
          child: OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              shape: buttonStyle.shape?.resolve({}),
              side: BorderSide(
                color: isDestructive ? theme.colorScheme.error : theme.colorScheme.outline,
              ),
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: _platformService.getAdaptiveIconSize(),
                    color: isDestructive ? theme.colorScheme.error : theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isDestructive ? theme.colorScheme.error : theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  /// Adaptive text field with platform-specific styling
  static Widget adaptiveTextField({
    required BuildContext context,
    String? labelText,
    String? hintText,
    String? helperText,
    String? errorText,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    VoidCallback? onTap,
    bool obscureText = false,
    bool enabled = true,
    bool readOnly = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    int? maxLines = 1,
    int? maxLength,
    Widget? prefixIcon,
    Widget? suffixIcon,
    EdgeInsetsGeometry? padding,
  }) {
    final theme = Theme.of(context);
    final platformInfo = _platformService.platformInfo;
    
    if (platformInfo.platform == TargetPlatform.iOS && platformInfo.isMobile) {
      return Padding(
        padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (labelText != null) ...[
              Text(
                labelText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
            ],
            CupertinoTextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              onTap: onTap,
              obscureText: obscureText,
              enabled: enabled,
              readOnly: readOnly,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              maxLines: maxLines,
              maxLength: maxLength,
              placeholder: hintText,
              prefix: prefixIcon,
              suffix: suffixIcon,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: errorText != null
                      ? CupertinoColors.destructiveRed
                      : CupertinoColors.systemGrey4,
                ),
                color: enabled
                    ? CupertinoColors.tertiarySystemBackground
                    : CupertinoColors.systemGrey6,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            if (helperText != null || errorText != null) ...[
              const SizedBox(height: 4),
              Text(
                errorText ?? helperText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: errorText != null
                      ? CupertinoColors.destructiveRed
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ],
        ),
      );
    } else {
      return Padding(
        padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          onTap: onTap,
          obscureText: obscureText,
          enabled: enabled,
          readOnly: readOnly,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: maxLines,
          maxLength: maxLength,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            helperText: helperText,
            errorText: errorText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      );
    }
  }

  /// Adaptive switch with platform-specific styling
  static Widget adaptiveSwitch({
    required BuildContext context,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? label,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);
    final platformInfo = _platformService.platformInfo;
    
    Widget switchWidget;
    
    if (platformInfo.platform == TargetPlatform.iOS && platformInfo.isMobile) {
      switchWidget = CupertinoSwitch(
        value: value,
        onChanged: enabled ? onChanged : null,
        activeColor: theme.colorScheme.primary,
      );
    } else {
      switchWidget = Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
        activeColor: theme.colorScheme.primary,
      );
    }
    
    if (label != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: enabled
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ),
          const SizedBox(width: 16),
          switchWidget,
        ],
      );
    }
    
    return switchWidget;
  }

  /// Adaptive slider with platform-specific styling
  static Widget adaptiveSlider({
    required BuildContext context,
    required double value,
    required ValueChanged<double> onChanged,
    double min = 0.0,
    double max = 1.0,
    int? divisions,
    String? label,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);
    final platformInfo = _platformService.platformInfo;
    
    if (platformInfo.platform == TargetPlatform.iOS && platformInfo.isMobile) {
      return CupertinoSlider(
        value: value,
        onChanged: enabled ? onChanged : null,
        min: min,
        max: max,
        divisions: divisions,
        activeColor: theme.colorScheme.primary,
        thumbColor: theme.colorScheme.primary,
      );
    } else {
      return Slider(
        value: value,
        onChanged: enabled ? onChanged : null,
        min: min,
        max: max,
        divisions: divisions,
        label: label,
        activeColor: theme.colorScheme.primary,
        inactiveColor: theme.colorScheme.outline,
      );
    }
  }

  /// Adaptive segmented control
  static Widget adaptiveSegmentedControl<T extends Object>({
    required BuildContext context,
    required Map<T, String> options,
    required T selectedValue,
    required ValueChanged<T> onChanged,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);
    final platformInfo = _platformService.platformInfo;
    
    if (platformInfo.platform == TargetPlatform.iOS && platformInfo.isMobile) {
      return CupertinoSegmentedControl<T>(
        children: options.map(
          (key, value) => MapEntry(
            key,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        groupValue: selectedValue,
        onValueChanged: onChanged,
        selectedColor: theme.colorScheme.primary,
        unselectedColor: CupertinoColors.systemGrey6,
        borderColor: theme.colorScheme.outline,
      );
    } else {
      return SegmentedButton<T>(
        segments: options.entries.map((entry) {
          return ButtonSegment<T>(
            value: entry.key,
            label: Text(
              entry.value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
        selected: {selectedValue},
        onSelectionChanged: enabled
            ? (Set<T> selection) {
                if (selection.isNotEmpty) {
                  onChanged(selection.first);
                }
              }
            : null,
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }
  }

  /// Adaptive loading indicator
  static Widget adaptiveLoadingIndicator({
    required BuildContext context,
    double? size,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final platformInfo = _platformService.platformInfo;
    
    if (platformInfo.platform == TargetPlatform.iOS && platformInfo.isMobile) {
      return CupertinoActivityIndicator(
        radius: (size ?? 20) / 2,
        color: color ?? theme.colorScheme.primary,
      );
    } else {
      return SizedBox(
        width: size ?? 20,
        height: size ?? 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? theme.colorScheme.primary,
          ),
        ),
      );
    }
  }

  /// Adaptive dialog
  static Future<T?> showAdaptiveDialog<T>({
    required BuildContext context,
    required String title,
    required String content,
    List<AdaptiveDialogAction>? actions,
    bool barrierDismissible = true,
  }) {
    final platformInfo = _platformService.platformInfo;
    
    if (platformInfo.platform == TargetPlatform.iOS && platformInfo.isMobile) {
      return showCupertinoDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: actions?.map((action) {
              return CupertinoDialogAction(
                onPressed: action.onPressed,
                isDestructiveAction: action.isDestructive,
                isDefaultAction: action.isDefault,
                child: Text(action.text),
              );
            }).toList() ?? [],
          );
        },
      );
    } else {
      return showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: actions?.map((action) {
              return TextButton(
                onPressed: action.onPressed,
                style: TextButton.styleFrom(
                  foregroundColor: action.isDestructive
                      ? Theme.of(context).colorScheme.error
                      : action.isDefault
                          ? Theme.of(context).colorScheme.primary
                          : null,
                ),
                child: Text(
                  action.text,
                  style: TextStyle(
                    fontWeight: action.isDefault ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              );
            }).toList() ?? [],
          );
        },
      );
    }
  }

  /// Adaptive action sheet
  static Future<T?> showAdaptiveActionSheet<T>({
    required BuildContext context,
    required String title,
    String? message,
    required List<AdaptiveActionSheetAction<T>> actions,
    AdaptiveActionSheetAction<T>? cancelAction,
  }) {
    final platformInfo = _platformService.platformInfo;
    
    if (platformInfo.platform == TargetPlatform.iOS && platformInfo.isMobile) {
      return showCupertinoModalPopup<T>(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: Text(title),
            message: message != null ? Text(message) : null,
            actions: actions.map((action) {
              return CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop(action.value);
                  action.onPressed?.call();
                },
                isDestructiveAction: action.isDestructive,
                child: Text(action.text),
              );
            }).toList(),
            cancelButton: cancelAction != null
                ? CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.of(context).pop(cancelAction.value);
                      cancelAction.onPressed?.call();
                    },
                    child: Text(cancelAction.text),
                  )
                : null,
          );
        },
      );
    } else {
      return showModalBottomSheet<T>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      if (message != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          message,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
                const Divider(),
                ...actions.map((action) {
                  return ListTile(
                    title: Text(
                      action.text,
                      style: TextStyle(
                        color: action.isDestructive
                            ? Theme.of(context).colorScheme.error
                            : null,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop(action.value);
                      action.onPressed?.call();
                    },
                  );
                }),
                if (cancelAction != null) ...[
                  const Divider(),
                  ListTile(
                    title: Text(
                      cancelAction.text,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onTap: () {
                      Navigator.of(context).pop(cancelAction.value);
                      cancelAction.onPressed?.call();
                    },
                  ),
                ],
              ],
            ),
          );
        },
      );
    }
  }
}

/// Dialog action model
class AdaptiveDialogAction {
  final String text;
  final VoidCallback? onPressed;
  final bool isDefault;
  final bool isDestructive;

  const AdaptiveDialogAction({
    required this.text,
    this.onPressed,
    this.isDefault = false,
    this.isDestructive = false,
  });
}

/// Action sheet action model
class AdaptiveActionSheetAction<T> {
  final String text;
  final T value;
  final VoidCallback? onPressed;
  final bool isDestructive;

  const AdaptiveActionSheetAction({
    required this.text,
    required this.value,
    this.onPressed,
    this.isDestructive = false,
  });
}

/// Responsive breakpoints for adaptive layouts
class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }
}

/// Responsive widget builder
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context)? mobile;
  final Widget Function(BuildContext context)? tablet;
  final Widget Function(BuildContext context)? desktop;
  final Widget Function(BuildContext context) fallback;

  const ResponsiveBuilder({
    Key? key,
    this.mobile,
    this.tablet,
    this.desktop,
    required this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (ResponsiveBreakpoints.isDesktop(context) && desktop != null) {
      return desktop!(context);
    }
    if (ResponsiveBreakpoints.isTablet(context) && tablet != null) {
      return tablet!(context);
    }
    if (ResponsiveBreakpoints.isMobile(context) && mobile != null) {
      return mobile!(context);
    }
    return fallback(context);
  }
}
